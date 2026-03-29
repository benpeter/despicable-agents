## Domain Plan Contribution: devx-minion

### Recommendations

#### 1. YAML Parsing: Use `yq` (Mike Farah's Go version), with install gating

**Recommendation**: `yq` (the Go binary, not python-yq).

**Rationale by elimination**:

- **Pure awk**: The project's `assemble.sh` demonstrates excellent awk usage for structured Markdown parsing. However, YAML has edge cases that make a pure-awk parser brittle in production: multi-line strings (`|`, `>`), quoted values containing colons, nested maps, and comment handling. The routing config is simple *today*, but a hand-rolled awk YAML parser will break the first time someone adds a comment containing a colon or a model name containing spaces. The maintenance cost exceeds the dependency cost.

- **Python script**: System Python (3.9.6) is available but PyYAML is *not* installed. Requiring `pip install pyyaml` introduces a dependency management problem the project does not currently have (no `requirements.txt`, no venv, no pip anywhere in the project). Python's stdlib has no YAML parser. This option either requires a new dependency mechanism or a hand-rolled parser with the same brittleness as awk.

- **`yq` (Go binary)**: Single statically-linked binary. No runtime dependencies. Available via `brew install yq` (macOS), `apt install yq` (Debian/Ubuntu), or direct download. Already the de facto standard for YAML processing in shell scripts. Outputs JSON, which the existing hooks already consume via `jq` (see `commit-point-check.sh`, `track-file-changes.sh`). The project already depends on `jq` -- adding `yq` is consistent.

**Install gating pattern**: The config loader script should check for `yq` at the top and produce a clear install instruction if missing:

```bash
if ! command -v yq &>/dev/null; then
  echo "Error: yq is required for routing config but not found." >&2
  echo "" >&2
  echo "Install it:" >&2
  echo "  brew install yq        # macOS" >&2
  echo "  apt install yq         # Debian/Ubuntu" >&2
  echo "  https://github.com/mikefarah/yq#install  # other" >&2
  exit 1
fi
```

This follows the project's existing pattern: `install.sh` and `assemble.sh` rely on tools being present (awk, bash) without bundling them. `yq` is the same class of dependency.

**Important**: The loader must verify it has the Mike Farah Go version (not the Python wrapper). A quick `yq --version` check for `mikefarah` or version `4.x` prevents confusion with the Python `yq` package which has different syntax.

#### 2. Config Loader Architecture: Single Shell Script, JSON Intermediate

The config loader should be a single shell script (`lib/load-routing-config.sh` or similar) that:

1. Checks for `.nefario/routing.yml` at project root; if absent, emits a static JSON default and exits 0.
2. Optionally reads user-level config at `~/.nefario/routing.yml`.
3. Uses `yq` to convert YAML to JSON.
4. Performs validation in a structured sequence (see below).
5. Emits a resolved JSON config to stdout for consumption by the routing dispatch.

This follows the project convention: `assemble.sh` reads structured input, validates, transforms, and writes output. The loader does the same for YAML.

The zero-config path is the shortest code path:

```bash
if [[ ! -f "$PROJECT_ROUTING_CONFIG" ]]; then
  # Zero-config: everything routes to claude-code
  echo '{"default":"claude-code","groups":{},"agents":{},"model-mapping":{}}'
  exit 0
fi
```

No log message, no warning, no hint. Silent default. The user who has never heard of routing configs should never see output from this loader.

#### 3. Validation Sequence and Error Message Design

Validation should run in a strict order so that the first error is always the most actionable. Do not collect all errors and dump them -- stop at the first category of failure. (Rationale: a missing `default` field makes all subsequent group/agent validation meaningless.)

**Validation order:**

1. **Syntax validation**: `yq` exits non-zero on malformed YAML. Capture its stderr, prefix with the file path, and present a structured error.

2. **Required field check**: `default` is the only required field. If absent, error with what the file should contain.

3. **Known harness names**: Validate that every harness name referenced in `default`, `groups`, `agents`, and `model-mapping` keys is from the known set. Start with `claude-code`, `codex`, `aider` -- the set defined in the roadmap. This is a hardcoded allowlist in the loader, not user-configurable (adding a harness means writing an adapter, which means updating the loader).

4. **Model-mapping completeness**: If a harness is referenced for routing but has no `model-mapping` entry, warn (not error). The adapter can fall back to a sensible default per the adapter interface spec ("If the routing config has no model-mapping entry for a tier, the adapter should apply a sensible default").

5. **Capability gating**: For each agent routed to a non-claude-code harness, load that agent's `tools:` from its AGENT.md frontmatter and check against the harness capability set. Hard error on mismatch.

6. **Group name validation**: If `groups:` references a group name that does not match any known group, warn. (See the group naming recommendation below -- this depends on whether groups are canonical or arbitrary.)

**Error message format -- three components, always:**

Every error follows this template:

```
Error: <what went wrong>

  in: .nefario/routing.yml
  <specific location if applicable>

<how to fix -- concrete, copy-pasteable>
```

**Example error messages:**

```
Error: Unknown harness "codex-cli" in agents.frontend-minion

  in: .nefario/routing.yml, line 12

Known harness names: claude-code, codex, aider
Did you mean "codex"?
```

Wait -- the scope says "No 'did you mean?' suggestions." So:

```
Error: Unknown harness "codex-cli" in agents.frontend-minion

  in: .nefario/routing.yml

Known harness names: claude-code, codex, aider
```

Still actionable: the user sees the full list and can self-correct.

**Capability gating error (the key acceptance criterion):**

```
Error: Capability mismatch for security-minion routed to aider

  in: .nefario/routing.yml

  security-minion requires: Read, Glob, Grep, Bash, WebSearch, WebFetch, Write, Edit
  aider supports:           Read, Write, Edit
  unsupported:              Glob, Grep, Bash, WebSearch, WebFetch

Route security-minion to a harness that supports these tools,
or remove the agent-level override to use the default harness.
```

This shows: what the agent needs, what the harness provides, the delta, and two concrete actions. No guessing, no vague "check your config."

#### 4. Zero-Config Design: Invisible Until Needed

The zero-config path must satisfy three properties:

- **Silent**: No output, no log, no hint about routing.yml existing.
- **Fast**: File-existence check + static JSON emit. No yq, no validation.
- **Correct**: Every agent routes to `claude-code`, which is the current behavior.

The progressive disclosure ladder is:

1. **No file** -- everything is claude-code (current behavior, zero friction)
2. **`default: claude-code`** -- explicit but identical to zero-config (user is learning the config)
3. **`default: codex`** -- switch everything to one external harness
4. **`default: codex` + `agents:` overrides** -- mix harnesses per agent
5. **Full config with groups and model-mapping** -- power user

Each step adds exactly one concept. No step requires understanding the steps below it.

#### 5. Group Naming: Use Canonical Kebab-Case IDs from the Agent Roster

The power-user example in the feasibility study uses `code-writers` and `data-analysts` as group names. These do not match the canonical group names in nefario's agent roster ("Development & Quality Minions", "Infrastructure & Data Minions", etc.).

**Recommendation**: Define canonical kebab-case group IDs derived from the roster headings:

| Roster Heading | Config Group ID |
|---|---|
| The Boss | `boss` |
| Governance | `governance` |
| Protocol & Integration Minions | `protocol-integration` |
| Infrastructure & Data Minions | `infrastructure-data` |
| Intelligence Minions | `intelligence` |
| Development & Quality Minions | `development-quality` |
| Security & Observability Minions | `security-observability` |
| Design & Documentation Minions | `design-documentation` |
| Web Quality Minions | `web-quality` |

**Why canonical, not arbitrary**: Arbitrary groupings require the config to define membership (which agents belong to which group), adding a second indirection layer. Canonical groups have membership defined by the roster -- the loader resolves group membership by reading which group each agent belongs to. This eliminates a class of config errors (typo in agent-to-group assignment) and keeps the config surface minimal.

**Why kebab-case**: Matches YAML key conventions, is grep-friendly, and avoids quoting requirements in YAML (spaces in keys require quotes).

The updated power-user example becomes:

```yaml
default: claude-code

groups:
  development-quality: codex
  infrastructure-data: aider

agents:
  security-minion: claude-code
```

The mapping from group ID to agent membership is maintained by the loader (reading from the agent roster or a static mapping). When the roster changes, the mapping updates. Users never specify which agents are in which group -- that is the domain model's job.

#### 6. User-Level Override: Shallow Merge, Not Deep

User-level config at `~/.nefario/routing.yml` should merge shallowly with project-level:

- `default`: user wins
- `groups`: user entries override project entries for the same group key; project-only keys preserved
- `agents`: user entries override project entries for the same agent key; project-only keys preserved
- `model-mapping`: user entries override project entries for the same harness key (entire harness block replaced, not individual tier merges)

**Why shallow, not deep**: Deep merge on `model-mapping` would mean a user could override just `opus` for a harness while inheriting `sonnet` from the project config. This creates invisible coupling -- the user does not see the full mapping they are getting. Shallow merge (replace the whole harness block) is predictable: if you override a harness's model-mapping, you own all of it.

**Why user wins for `default`**: The user-level override's purpose is personal preference. If a project says `default: codex` but a user prefers claude-code, the user should be able to override without forking the project config.

#### 7. Config File Location

Project-level: `.nefario/routing.yml` (as proposed in the feasibility study). The `.nefario/` directory is a natural namespace for nefario-specific project config, separate from `.claude/` (which is Claude Code's namespace).

User-level: `~/.nefario/routing.yml`. Symmetric with the project-level path. Created manually by the user; never auto-generated.

Both paths should be documented in the schema reference. The loader should log (to stderr, not stdout) which files it loaded, but only when at least one file exists:

```
# Only when a config file is found and loaded:
routing: loaded .nefario/routing.yml
routing: loaded ~/.nefario/routing.yml (user override)
```

### Proposed Tasks

#### Task 1: Define the YAML Schema as a Documented Reference
**Deliverable**: A new doc page (`docs/routing-config.md`) containing:
- Annotated YAML examples (minimal, intermediate, power-user)
- Field table for each section (default, groups, agents, model-mapping)
- Resolution order explanation with examples
- Capability gating explanation
- User-level override merge semantics
- Known harness names and their capability sets
- Known group IDs and their agent membership

**Dependencies**: Consultation 2 (api-design-minion) for capability vocabulary; Consultation 3 (ai-modeling-minion) for group naming decision.

#### Task 2: Implement the Config Loader Shell Script
**Deliverable**: `lib/load-routing-config.sh` (or agreed-upon location) that:
- Checks for and reads `.nefario/routing.yml` and `~/.nefario/routing.yml`
- Merges user-level over project-level (shallow merge)
- Validates in the defined sequence
- Emits resolved JSON to stdout
- Exits 0 on success, 1 on validation error, 2 on missing dependency (yq)
- Zero-config path emits static JSON default without requiring yq

**Dependencies**: Task 1 (schema definition); `yq` as external dependency.

#### Task 3: Implement Capability Gating
**Deliverable**: A capability registry (hardcoded in the loader or a companion data file) mapping each known harness to its supported tool set. Validation logic that compares agent `tools:` frontmatter against the registry and produces the structured error format described above.

**Dependencies**: Task 2 (loader structure); api-design-minion consultation for capability vocabulary.

**Harness capability sets (initial, derived from feasibility study):**

| Harness | Supported Tools |
|---|---|
| `claude-code` | Read, Write, Edit, Bash, Glob, Grep, WebSearch, WebFetch (full set) |
| `codex` | Read, Write, Edit, Bash, Glob, Grep (no WebSearch, no WebFetch -- verify during M2 validation) |
| `aider` | Read, Write, Edit (file edit only -- no Bash, no Glob, no Grep, no WebSearch, no WebFetch) |

#### Task 4: Write Tests for the Config Loader
**Deliverable**: Test suite (likely `bats` for shell testing, matching the project's shell-first approach) covering:
- Zero-config (no file) produces correct JSON default
- Minimal config (`default: claude-code`) loads and validates
- Power-user config loads and validates
- Unknown harness name produces correct error
- Capability mismatch produces correct error (the web-research-agent-to-aider case)
- Malformed YAML produces correct error with file path
- User-level override merge produces expected result
- Missing `yq` produces install instructions

**Dependencies**: Tasks 2 and 3.

### Risks and Concerns

1. **`yq` version fragmentation**: There are two tools named `yq` -- Mike Farah's Go version (the standard) and Andrey Kislyuk's Python wrapper. They have incompatible syntax. The loader MUST detect which version is installed. Mitigation: version check at startup (`yq --version` parsing). If the wrong version is detected, emit an actionable error naming the correct package.

2. **Capability registry staleness**: The hardcoded capability sets for `codex` and `aider` are based on the feasibility study assessment, not validated against actual tool behavior. The M2 (Codex) and M3 (Aider) validation milestones will confirm or correct these. The registry should be easy to update (a single location, not scattered across logic). If capabilities are wrong, the gating will either reject valid configs (false positive -- user gets a confusing error) or accept invalid configs (false negative -- task fails at runtime). False positives are preferable -- they are caught at config load time and produce an error the user can override.

3. **Group membership drift**: If the agent roster changes (agents added, moved between groups, groups renamed), the canonical group-to-agent mapping in the loader becomes stale. Mitigation: derive the mapping from the agent roster source (the plan or the nefario AGENT.md domain section) rather than hardcoding it. Alternatively, generate the mapping as part of `assemble.sh` or the build pipeline.

4. **macOS system `awk` limitations**: The project's existing awk usage in `assemble.sh` is compatible with macOS BSD awk (not gawk). Any awk used in the config loader must also be BSD-compatible. However, since the recommendation is `yq` + `jq`, awk dependency is minimal in the loader itself.

5. **YAML anchor/alias attacks**: YAML supports anchors (`&`) and aliases (`*`) which can create exponential expansion (billion laughs). `yq` (Go version) has sane defaults and does not expand recursive anchors. Still, the loader should reject configs that use anchors/aliases -- there is no legitimate use case in a routing config this simple. A `grep -q '&\|*' "$config_file"` pre-check is sufficient.

### Additional Agents Needed

- **test-minion**: Should advise on the test framework choice (bats vs. plain shell test scripts) and test structure for the acceptance criteria. The meta-plan already includes this as a cross-cutting concern, but test-minion should be consulted during planning, not just review.

- **ux-strategy-minion**: Already included in the meta-plan. Should validate the progressive disclosure ladder (zero-config through power-user) and confirm the error message format serves the user journey from "I just broke something" to "I know how to fix it."

No additional specialists beyond what the meta-plan already identified.
