## Domain Plan Contribution: test-minion

### Recommendations

#### Test Framework: Self-Contained Inline Test Script (No External Dependencies)

The project already has an established testing pattern in `.claude/hooks/test-hooks.sh` -- a self-contained bash test script with pass/fail reporting, temp directory management, and a cleanup trap. This is the right pattern for #139. Reasons:

1. **No new dependencies.** The project has no test framework, no package manager, no runtime beyond bash/awk. Introducing bats, shunit2, or pytest would add a dependency that conflicts with the project's "lean and mean" philosophy and the Helix Manifesto's minimize-dependencies principle.
2. **Proven convention.** The existing test-hooks.sh demonstrates that the team already writes and maintains self-contained test scripts. Following the same pattern means no learning curve, no new tooling, and reviewers already know the format.
3. **Sufficient for the scope.** The config loader has approximately 15-25 discrete test cases. A simple pass/fail framework with a counter and descriptive messages handles this cleanly. There is no need for test fixtures, parameterization, or parallel execution at this scale.

The test script should live at a location consistent with the config loader -- if the loader is at `.nefario/routing.sh` or similar, the test should be alongside it or in a `tests/` directory near the loader. A good candidate: `tests/test-routing-config.sh` or `.nefario/test-routing-config.sh`.

#### Test Architecture: Integration Tests Against Real YAML Files

The config loader's job is: read YAML, validate structure, resolve routes, check capabilities. These are all I/O-dependent operations that work best as integration tests exercising the real loader against crafted YAML fixtures.

Do NOT unit test internal functions by sourcing the loader script and calling functions in isolation. That couples tests to implementation details and makes refactoring painful. Instead, treat the loader as a black box: give it a YAML file and check what comes out (stdout, stderr, exit code).

**Test harness structure** (mirroring test-hooks.sh conventions):

```
tests/
  test-routing-config.sh     # test runner
  fixtures/
    minimal.yml              # default: claude-code
    power-user.yml           # full example from docs
    empty.yml                # empty file (not same as missing)
    malformed.yml            # invalid YAML syntax
    unknown-harness.yml      # references non-existent harness
    bad-capability.yml       # routes WebSearch agent to aider
    ...
```

Each fixture is a small, purpose-built YAML file. Fixtures are static files, not generated -- they document the contract through examples.

#### Capability Gating Test Strategy

Capability gating is the highest-risk validation feature because it cross-references two data sources: the agent's `tools:` frontmatter and the harness capability registry. Testing must cover:

1. **Positive case**: Agent with `tools: Read, Write, Edit` routed to any harness succeeds (all harnesses support basic file operations).
2. **Negative case (acceptance criteria)**: Agent with `tools: ... WebSearch, WebFetch` routed to Aider produces a clear error naming the unsupported tool(s) and the agent being routed.
3. **Multiple unsupported tools**: Error message lists ALL unsupported tools, not just the first one found.
4. **Harness supports all tools**: Agent with `tools: Read, Write, Edit, Bash` routed to Codex CLI succeeds.

For testing capability gating, the test should NOT parse real AGENT.md files -- that adds fragile filesystem coupling. Instead, the loader should accept the required tools list as input (matching the `required_agent_tools` field from `DelegationRequest`), and tests pass explicit tool lists. The acceptance criteria test becomes:

```bash
# Simulate routing gru (which requires WebSearch, WebFetch) to aider
result=$(route_agent --agent gru --tools "Read,Glob,Grep,WebSearch,WebFetch,Write,Edit" --harness aider 2>&1)
exit_code=$?
# Should fail with exit code != 0 and error naming WebSearch and WebFetch
```

#### Error Message Quality Tests

Config validation errors are a developer-facing UX surface. Every rejection test should assert not just that an error occurs but that the error message contains:
- The specific field or value that is invalid
- What was expected (valid options)
- Enough context to fix the problem without reading the source code

This is more important than it sounds -- config errors surface at orchestration startup, potentially after a complex setup. An error message like "invalid config" wastes time; "unknown harness 'codex-cli' in agents.frontend-minion -- valid harness names are: claude-code, codex, aider" saves it.

### Proposed Tasks

#### Task 1: Create Test Fixtures (YAML Files)

Create static YAML fixture files covering all validation paths. Each file should be minimal -- test one thing per fixture.

**Fixture inventory:**

| Fixture | Purpose | Expected outcome |
|---------|---------|-----------------|
| `missing` (no file) | Zero-config path | All routes resolve to claude-code |
| `minimal.yml` | `default: claude-code` only | Loads without error |
| `power-user.yml` | Full example from feasibility study docs | Loads without error, all routes resolve correctly |
| `empty.yml` | File exists but is empty | Treated as zero-config OR clear error (design decision) |
| `default-only-codex.yml` | `default: codex` | All routes resolve to codex |
| `malformed.yml` | Invalid YAML syntax (unclosed quote, bad indent) | Error with line number if parser supports it |
| `unknown-harness.yml` | `default: does-not-exist` | Error naming the unknown harness and listing valid options |
| `unknown-harness-agent.yml` | Valid default, one agent maps to unknown harness | Error naming the agent and the unknown harness |
| `unknown-agent-name.yml` | `agents:` section references agent name not in roster | Warning or error (design decision -- may depend on whether agent roster is available at load time) |
| `empty-groups.yml` | `groups:` key present but empty | Loads without error (empty section is a no-op) |
| `bad-capability.yml` | Routes agent with WebSearch requirement to aider | Hard error naming the agent, the unsupported tool(s), and the harness |
| `model-mapping-partial.yml` | `model-mapping` present for some harnesses, missing for others | Loads without error; missing mapping falls back to harness default |
| `duplicate-agent.yml` | Same agent appears in both `agents:` and resolves via `groups:` | Agent-level override takes precedence (test resolution order) |
| `override-merge.yml` | Pair of project + user config files for merge testing | User overrides apply correctly |

#### Task 2: Implement Test Runner Script

Follow the test-hooks.sh pattern exactly:
- `set -euo pipefail`
- `TESTS_PASSED` / `TESTS_FAILED` counters
- `pass()` and `fail()` helper functions
- `cleanup` trap for temp directories
- Summary line at end: `"Results: N passed, M failed"`
- Exit code = number of failures (0 = all pass)

Each test case should be:
1. Self-documenting with a descriptive test name
2. Self-contained -- no shared mutable state between tests
3. Fast -- YAML parsing of small files should be sub-second per test

#### Task 3: Write Tests for Each Acceptance Criterion

**AC1: Minimal config loads without error**
```
Test: minimal config (default: claude-code) loads and validates
  - Write minimal.yml to temp dir
  - Run loader against it
  - Assert exit code 0
  - Assert resolved route for any agent = claude-code
```

**AC2: Power-user config loads without error**
```
Test: power-user config loads and validates
  - Write power-user.yml (from docs/external-harness-integration.md example)
  - Run loader against it
  - Assert exit code 0
  - Assert frontend-minion resolves to codex (agent-level override)
  - Assert security-minion resolves to claude-code (agent-level override)
  - Assert any code-writers group member resolves to codex (group-level)
  - Assert an unmentioned agent resolves to claude-code (default)
```

**AC3: Capability gating rejects bad routing**
```
Test: capability gating rejects WebSearch agent routed to aider
  - Write config routing an agent to aider
  - Provide required tools including WebSearch
  - Run loader/validator
  - Assert exit code != 0
  - Assert stderr contains agent name
  - Assert stderr contains "WebSearch"
  - Assert stderr contains "aider"
```

**AC4: Zero-config defaults to claude-code**
```
Test: no config file present -> all routes to claude-code
  - Run loader with config path pointing to non-existent file
  - Assert exit code 0
  - Assert resolved route for any agent = claude-code
```

#### Task 4: Write Edge Case Tests

These are not acceptance criteria but catch regressions and document behavior for ambiguous inputs:

1. **Malformed YAML**: Loader exits non-zero with error mentioning YAML parse failure
2. **Unknown harness name**: Error lists valid harness names
3. **Empty file**: Clear behavior (either treat as zero-config or reject)
4. **Resolution order**: Agent override wins over group, group wins over default
5. **Model mapping missing for a harness**: Fallback behavior works (not a hard error)
6. **Config file with extra unknown keys**: Decide and test -- strict reject or lenient ignore with warning
7. **Harness name case sensitivity**: Is `Claude-Code` the same as `claude-code`? Test and document.
8. **Group with no members**: Empty group in `groups:` is a no-op, not an error
9. **YAML anchors and aliases**: If the parser supports them, test they work; if not, test they produce a clear error
10. **Very large config**: Not a real concern at this scale, but ensure no glob expansion or word splitting issues with agent names containing hyphens

### Risks and Concerns

**Risk 1: YAML Parser Choice Affects Testability**

If the loader uses `yq`, tests depend on `yq` being installed. If it uses a Python one-liner, tests depend on Python. If it uses pure awk, testing is easier (no external deps) but YAML parsing in awk is fragile. The test approach must match the implementation's parser choice.

**Mitigation**: The test script should assert the parser dependency is available at startup and skip with a clear message if not. The fixture files are parser-agnostic -- they are valid YAML regardless of which tool reads them.

**Risk 2: Capability Registry as a Test Dependency**

Capability gating tests need to know which tools each harness supports. If this data is hardcoded in the loader, tests must agree with that hardcoded data. If it lives in a separate file, tests read the same file.

**Mitigation**: Tests should NOT duplicate the capability list. They should exercise the loader's own validation, passing tool lists that are known to be unsupported (WebSearch on Aider) based on the documented gap analysis. If the capability data changes, the integration test remains valid because it tests the loader's behavior, not the data.

**Risk 3: No CI Integration Yet**

The project has no CI pipeline. The test script will be manually invoked. This means test failures are only caught when someone remembers to run the script.

**Mitigation**: Document how to run the test in the script header (matching test-hooks.sh convention: `# Usage: bash tests/test-routing-config.sh`). Consider adding a check to install.sh that runs validation tests before deploying (low priority, but would catch regressions).

**Risk 4: User-Level Override Path is Environment-Specific**

The user-level config override reads from a user-specific path (e.g., `~/.config/nefario/routing.yml`). Tests must not pollute the user's real config, and must work on any machine.

**Mitigation**: Tests should use environment variables or arguments to override the config search path, pointing to temp directories. This is the same pattern used in test-hooks.sh (which uses `CLAUDE_PROJECT_DIR` and `CLAUDE_SESSION_ID` to control paths).

### Additional Agents Needed

None beyond what is already planned in the meta-plan. The test approach described here is self-contained and does not require input from other agents. The key design decision that affects testing -- the YAML parser choice -- comes from devx-minion's consultation. Once that decision is made, the test implementation is straightforward.

One note for **devx-minion**: when designing the loader's CLI interface, please ensure it supports:
1. A flag or env var to override the config file path (so tests can point to fixtures)
2. A flag or env var to override the user-level config search path (so tests do not pollute real user config)
3. A "validate only" mode that loads and validates without producing routing output (or the validation happens as part of normal loading)
4. Structured exit codes: 0 = success, 1 = validation error, 2 = file not found (treated as zero-config), other = unexpected error

These are not test-specific features -- they are good CLI design that happens to make testing easy.
