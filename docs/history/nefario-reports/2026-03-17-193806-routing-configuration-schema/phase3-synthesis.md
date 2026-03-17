## Delegation Plan

**Team name**: routing-config
**Description**: Define YAML schema for `.nefario/routing.yml`, implement config loader with validation and capability gating, write tests, and document the spec.

### Conflict Resolutions

Before presenting tasks, I must resolve four points where specialists disagreed:

**1. Error reporting: first-category-fail vs. batch-all-errors**

devx-minion recommends "stop at the first category of failure" (ordered: syntax, then required fields, then harness names, then capability gating). ux-strategy-minion recommends "collect all validation errors and report them together."

Resolution: **Category-batched.** Validate in devx-minion's ordered sequence, but within each category, report ALL errors of that category before stopping. If YAML syntax is broken, report only the parse error (subsequent validation is impossible). If syntax is valid, run all structural checks and report every violation together. This satisfies ux-strategy-minion's "no fix-one-reload-fix-another cycle" within each category while respecting devx-minion's "first broken category is actionable" principle.

**2. User-level merge semantics: shallow-per-block vs. full replacement**

security-minion recommends full replacement (if user config exists, it entirely replaces project config -- simpler, more secure). devx-minion and ai-modeling-minion recommend shallow-per-section merge (user `groups:` replaces project `groups:`, but other sections are preserved). ux-strategy-minion agrees with per-block replacement.

Resolution: **Shallow-per-section merge** (devx/ai-modeling/ux-strategy position). Full replacement (security's position) forces users to copy the entire project config when they only want to override one section, creating maintenance burden and drift. The trust concern is valid but addressed by: (a) user sections override project sections (user always wins), (b) startup log shows which file contributed which sections. The shallow merge is predictable: "my file wins for any section I define."

**3. User-level config path: `~/.nefario/` vs. `~/.claude/nefario/`**

devx-minion proposes `~/.nefario/routing.yml`. ux-strategy-minion proposes `~/.claude/nefario/routing.yml` (keeps agent-related config under `~/.claude/`).

Resolution: **`~/.claude/nefario/routing.yml`** (ux-strategy position). Users already know `~/.claude/` as the despicable-agents config root (agents, skills, hooks all live there). A separate `~/.nefario/` top-level directory is discoverable but disconnected from the existing hierarchy. Recognition over recall.

**4. Codex capability set: `[Read, Write, Edit, Bash]` vs. `[Read, Write, Edit, Bash, Glob, Grep]`**

devx-minion lists Codex as `Read, Write, Edit, Bash, Glob, Grep` (6 tools). api-design-minion lists Codex as `Read, Write, Edit, Bash` (4 tools).

Resolution: **`[Read, Write, Edit, Bash, Glob, Grep]`** (devx-minion's set). Codex CLI runs in a sandbox with shell access; `Glob` and `Grep` are achievable via `Bash` (find, grep commands). The capability set represents what the tool can functionally accomplish, not its native tool API. This is consistent with the feasibility study's assessment. If M2 validation reveals otherwise, the registry is a one-line change.

---

### Task 1: Implement Config Loader with Validation
- **Agent**: devx-minion
- **Delegation type**: standard
- **Model**: sonnet
- **Mode**: default
- **Blocked by**: none
- **Approval gate**: yes
- **Gate reason**: The config loader is the foundation for all routing. Its schema, validation order, merge semantics, and error format are hard-to-reverse decisions that all downstream tasks depend on.
- **Gate rationale**: |
    Chosen: Shell script using yq + jq, category-batched validation, shallow-per-section merge, hardcoded capability registry
    Over: (a) Pure awk parser (rejected: brittle for YAML edge cases), (b) Python loader (rejected: no PyYAML installed, adds dependency management), (c) Deep merge semantics (rejected: invisible coupling between files)
    Why: yq is the de facto standard for shell YAML processing, consistent with existing jq usage; category-batched validation gives actionable errors without fix-reload cycles; shallow merge is predictable.
- **Prompt**: |
    ## Task: Implement Config Loader for `.nefario/routing.yml`

    You are implementing the config loader for nefario's external harness routing system. This is Issue #139 on the external-harness branch.

    ### Context

    The despicable-agents orchestrator routes tasks to external LLM coding tools (Codex CLI, Aider, etc.) based on configuration in `.nefario/routing.yml`. This loader reads, validates, merges, and emits that configuration as JSON for consumption by the routing dispatch.

    Key reference documents (read these for context):
    - `docs/adapter-interface.md` -- defines `DelegationRequest`/`DelegationResult` types, especially `required_agent_tools` and `model_tier` fields
    - `docs/external-harness-roadmap.md` -- issue #139 scope and acceptance criteria
    - `docs/external-harness-integration.md` -- feasibility study, tool capabilities

    ### What to Build

    Create `lib/load-routing-config.sh` -- a self-contained bash script that:

    1. **Checks for yq** (Mike Farah Go version, v4+). If missing, exits with code 2 and actionable install instructions. Verify it is the Go version, not the Python wrapper.

    2. **Zero-config path**: If `.nefario/routing.yml` does not exist (at the project root), emit the static default JSON and exit 0:
       ```json
       {"default":"claude-code","groups":{},"agents":{},"model-mapping":{}}
       ```
       No yq required for zero-config. No log, no warning, no hint. Silent.

    3. **Reads config files**:
       - Project-level: `${PROJECT_ROOT}/.nefario/routing.yml`
       - User-level (optional): `~/.claude/nefario/routing.yml`
       Both paths must be canonicalized via `realpath`. Reject if the resolved path escapes its expected root (project root for project-level, `$HOME` for user-level). Do NOT follow symlinks for the `.nefario/` directory itself within a project.

    4. **Merges user-level over project-level** using shallow-per-section merge:
       - `default`: user replaces project (single scalar)
       - `groups`: user entries override matching project keys; project-only keys preserved
       - `agents`: same as groups
       - `model-mapping`: user replaces entire harness block (not individual tiers)
       If user-level file does not exist, project-level stands alone.

    5. **Validates in category order** (stop at first failing category, but report ALL errors within that category):

       a. **Syntax**: yq parse. On failure, report parse error with file path.

       b. **File size**: Reject files > 64KB.

       c. **Required field**: `default` is required when the file exists. Error: show what the file should contain.

       d. **Harness name allowlist**: Every harness reference in `default`, `groups.*`, `agents.*`, and `model-mapping` keys must be from: `claude-code`, `codex`, `aider`. Hard error on unknown names, listing valid options.

       e. **Group name validation**: Every key in `groups:` must be a canonical group ID. Valid IDs and their members:

       | Group ID | Members |
       |----------|---------|
       | `boss` | gru |
       | `governance` | lucy, margo |
       | `protocol-integration` | mcp-minion, oauth-minion, api-design-minion, api-spec-minion |
       | `infrastructure-data` | iac-minion, edge-minion, data-minion |
       | `intelligence` | ai-modeling-minion |
       | `development-quality` | frontend-minion, test-minion, debugger-minion, devx-minion, code-review-minion |
       | `security-observability` | security-minion, observability-minion |
       | `design-documentation` | ux-strategy-minion, ux-design-minion, software-docs-minion, user-docs-minion, product-marketing-minion |
       | `web-quality` | accessibility-minion, seo-minion, sitespeed-minion |

       Hardcode this mapping in the loader. Hard error on unknown group names with the list of valid group IDs.

       f. **Agent name validation**: Every key in `agents:` must be a known agent name from the roster (all 27 agents: gru, nefario, lucy, margo, + 23 minions). Hard error on unknown names.

       g. **Model-mapping validation**: Tier keys must be `opus` or `sonnet`. Model ID values must match `[a-zA-Z0-9._-]+` (no spaces, shell metacharacters, control chars, null bytes). No value may exceed 256 chars.

       h. **Capability gating**: For each agent routed to a non-claude-code harness (directly via `agents:` or via `groups:` resolution), load that agent's `tools:` field from its AGENT.md frontmatter and check against the harness capability set. If the agent's AGENT.md has no `tools:` field, treat as requiring ALL tools (full set). Hard error on mismatch showing: agent name, target harness, required tools, supported tools, unsupported tools, and fix suggestion.

       Capability registry (hardcoded):
       ```
       claude-code: Read, Write, Edit, Bash, Glob, Grep, WebSearch, WebFetch
       codex:       Read, Write, Edit, Bash, Glob, Grep
       aider:       Read, Write, Edit
       ```

    6. **Emits resolved JSON** to stdout. The JSON contains the merged, validated config.

    7. **Logs to stderr** (not stdout) when config files are loaded:
       ```
       routing: loaded .nefario/routing.yml
       routing: loaded ~/.claude/nefario/routing.yml (user override)
       ```
       No log when zero-config (no files found).

    8. **Resolution function**: Implement a `resolve` subcommand or function that takes an agent name and returns `{"harness": "...", "model": "..."}`. Resolution order: agent > group > default > implicit `claude-code`. For model resolution: check `model-mapping` for the resolved harness + the agent's tier. If no mapping, use sensible defaults:
       ```
       claude-code: opus=claude-opus-4-6, sonnet=claude-sonnet-4-5
       codex: opus=o3, sonnet=o4-mini
       aider: opus=claude-opus-4-6, sonnet=claude-sonnet-4-5
       ```

    ### CLI Interface

    The script must accept these arguments for testability:
    - `--project-config PATH` -- override project config path (default: `${PWD}/.nefario/routing.yml`)
    - `--user-config PATH` -- override user config path (default: `~/.claude/nefario/routing.yml`)
    - `--agent-dir PATH` -- root directory containing agent AGENT.md files (default: derived from script location or passed explicitly)
    - `--resolve AGENT_NAME` -- resolve a single agent's routing and print JSON
    - `--tier TIER` -- model tier for resolve (opus|sonnet, default: sonnet)
    - No arguments: load, validate, emit full resolved config JSON

    Exit codes: 0 = success, 1 = validation error, 2 = missing dependency (yq/jq).

    ### Error Message Format

    Every validation error follows this template:
    ```
    Error: <what went wrong>

      in: <file path>

    <how to fix -- concrete, copy-pasteable when possible>
    ```

    For capability gating specifically:
    ```
    Error: Capability mismatch for <agent> routed to <harness>

      in: .nefario/routing.yml

      <agent> requires: <tool1, tool2, ...>
      <harness> supports: <tool1, tool2, ...>
      unsupported:        <tool1, tool2, ...>

    Route <agent> to a harness that supports these tools,
    or remove the agent-level override to use the default harness.
    ```

    When multiple errors exist within a category, report all of them with a count header:
    ```
    .nefario/routing.yml: 3 errors found

      Error: ...
      Error: ...
      Error: ...
    ```

    ### Security Constraints

    - YAML anchors/aliases: Reject configs containing `&` or `*` anchor syntax. No legitimate use case for this simple config. A pre-parse grep check is sufficient.
    - File size: Reject files > 64KB before parsing.
    - Path validation: Canonicalize all config paths via `realpath`. Reject paths that escape expected roots.
    - No custom YAML tags: yq handles this safely by default.
    - Character validation on all string values as specified above.

    ### File Location

    Create the script at: `lib/load-routing-config.sh`

    The `lib/` directory does not exist yet -- create it.

    ### What NOT to Do

    - Do NOT create a JSON Schema for the config
    - Do NOT add "did you mean?" fuzzy matching suggestions
    - Do NOT add CI/CD environment variable overrides
    - Do NOT add a `capabilities:` section to the YAML schema
    - Do NOT use Python, Node, or any runtime beyond bash + yq + jq
    - Do NOT add arbitrary/user-defined group names -- groups are canonical only
    - Do NOT validate model IDs against provider catalogs (they are opaque strings)
    - Do NOT write documentation (separate task handles this)
    - Do NOT write tests (separate task handles this)

    ### Deliverables

    - `lib/load-routing-config.sh` -- the config loader script (executable, `#!/usr/bin/env bash`)
    - A minimal example config at `.nefario/routing.example.yml` showing the zero-to-power-user progression as YAML comments
- **Deliverables**: `lib/load-routing-config.sh`, `.nefario/routing.example.yml`
- **Success criteria**: Script loads and validates the example configs; zero-config path emits default JSON without requiring yq; capability gating rejects a WebSearch agent routed to aider; exit codes match spec; all error messages follow the three-component format.

### Task 2: Write Tests for Config Loader
- **Agent**: test-minion
- **Delegation type**: standard
- **Model**: sonnet
- **Mode**: default
- **Blocked by**: Task 1
- **Approval gate**: no
- **Prompt**: |
    ## Task: Write Tests for the Routing Config Loader

    You are writing the test suite for `lib/load-routing-config.sh` -- the routing config loader for nefario's external harness integration (Issue #139).

    ### Context

    Read these files for context:
    - `lib/load-routing-config.sh` -- the config loader you are testing
    - `.nefario/routing.example.yml` -- example configs produced by Task 1
    - `.claude/hooks/test-hooks.sh` -- the existing test pattern to follow EXACTLY

    ### Test Pattern

    Follow the `test-hooks.sh` pattern precisely:
    - `#!/usr/bin/env bash` with `set -euo pipefail`
    - `TESTS_PASSED` / `TESTS_FAILED` counters
    - `pass()` and `fail()` helper functions
    - `cleanup` trap for temp directories
    - `make_temp()` helper
    - Summary line: `"Results: N passed, M failed"`
    - Exit code = number of failures (0 = all pass)

    ### Test Strategy

    Black-box integration tests. Treat the loader as an opaque binary: give it config files, check stdout (JSON), stderr (errors), and exit codes. Do NOT source the loader and call internal functions.

    Use `--project-config` and `--user-config` flags to point at fixture files in temp directories. Use `--agent-dir` to point at a minimal set of mock AGENT.md files (create them in the temp directory with just the `tools:` frontmatter field).

    ### Test Fixtures

    Create static YAML fixtures in `tests/fixtures/routing/`. Each fixture tests one thing:

    | Fixture | Content | Expected |
    |---------|---------|----------|
    | (no file) | -- | exit 0, JSON `{"default":"claude-code","groups":{},"agents":{},"model-mapping":{}}` |
    | `minimal.yml` | `default: claude-code` | exit 0, loads without error |
    | `default-codex.yml` | `default: codex` | exit 0, all agents resolve to codex |
    | `with-groups.yml` | default + groups block | exit 0, group members resolve correctly |
    | `with-agents.yml` | default + agents block | exit 0, agent overrides resolve correctly |
    | `full-power-user.yml` | all four sections | exit 0, resolution order correct |
    | `malformed.yml` | broken YAML (unclosed quote) | exit 1, error mentions parse failure |
    | `missing-default.yml` | groups only, no default | exit 1, error about missing default |
    | `unknown-harness.yml` | `default: does-not-exist` | exit 1, error lists valid harnesses |
    | `unknown-harness-agent.yml` | valid default, one agent with bad harness | exit 1, error names the agent |
    | `unknown-group.yml` | `groups: {code-writers: codex}` | exit 1, error lists valid groups |
    | `bad-capability.yml` | routes agent requiring WebSearch to aider | exit 1, error names agent, tools, harness |
    | `bad-model-id.yml` | model-mapping with shell chars in value | exit 1, error about invalid characters |
    | `empty-file.yml` | empty file (0 bytes) | exit 1, error about missing default (or treated as no-config) |
    | `oversized.yml` | generated: >64KB | exit 1, error about file size |

    ### Mock AGENT.md Files

    Create minimal mock AGENT.md files in a temp directory for capability gating tests:

    ```yaml
    ---
    name: test-web-agent
    tools:
      - Read
      - WebSearch
      - WebFetch
    ---
    ```

    ```yaml
    ---
    name: test-basic-agent
    tools:
      - Read
      - Write
      - Edit
    ---
    ```

    ```yaml
    ---
    name: test-no-tools-agent
    ---
    ```
    (No `tools:` field -- implies all tools, should fail on aider/codex)

    ### Specific Acceptance Criteria Tests

    These MUST be present and clearly labeled:

    **AC1: Minimal config loads without error**
    - Write `minimal.yml` to temp dir
    - Run loader with `--project-config`
    - Assert exit 0
    - Assert stdout is valid JSON with `default: claude-code`

    **AC2: Power-user config loads without error**
    - Write `full-power-user.yml` with groups, agents, model-mapping
    - Run loader
    - Assert exit 0
    - Assert resolution order: agent override > group > default

    **AC3: Capability gating rejects bad routing**
    - Write config routing test-web-agent to aider
    - Run loader with mock agent dir
    - Assert exit 1
    - Assert stderr contains "test-web-agent"
    - Assert stderr contains "WebSearch"
    - Assert stderr contains "aider"

    **AC4: Zero-config defaults to claude-code**
    - Point loader at non-existent config path
    - Assert exit 0
    - Assert JSON output has `default: claude-code`

    ### Edge Case Tests

    1. Resolution order: agent in both `agents:` and via `groups:` -- agent wins
    2. Model-mapping partial: only some harnesses have mapping -- others use defaults
    3. User-level override: `--user-config` overrides sections from `--project-config`
    4. Missing yq: Mock yq absence (rename PATH or use env), verify exit 2 and install instructions
    5. YAML anchors: Config with `&` anchor syntax is rejected
    6. Empty `groups:` section: loads without error (no-op)
    7. Agent with no `tools:` field routed to aider: fails (requires all tools)

    ### File Location

    - Test script: `tests/test-routing-config.sh`
    - Fixtures: `tests/fixtures/routing/*.yml`

    The `tests/` directory does not exist yet -- create it.

    ### What NOT to Do

    - Do NOT use bats, shunit2, pytest, or any test framework
    - Do NOT source the loader and test internal functions
    - Do NOT duplicate the capability registry data -- test the loader's behavior
    - Do NOT write documentation
    - Do NOT modify the config loader itself
- **Deliverables**: `tests/test-routing-config.sh`, `tests/fixtures/routing/*.yml`
- **Success criteria**: All fixture tests pass; all 4 acceptance criteria have dedicated labeled tests; edge cases covered; test script follows test-hooks.sh pattern exactly; exit code = failure count.

### Task 3: Document the Routing Configuration Spec
- **Agent**: software-docs-minion
- **Delegation type**: standard
- **Model**: sonnet
- **Mode**: default
- **Blocked by**: Task 1
- **Approval gate**: no
- **Prompt**: |
    ## Task: Document the Routing Configuration Specification

    You are writing the specification document for `.nefario/routing.yml` -- the routing config for nefario's external harness integration (Issue #139).

    ### Context

    Read these files for context and pattern reference:
    - `lib/load-routing-config.sh` -- the implemented config loader (source of truth for validation rules)
    - `.nefario/routing.example.yml` -- example configs
    - `docs/adapter-interface.md` -- follow this document's pattern EXACTLY (Format Decision, examples first, field tables, semantics notes)
    - `docs/architecture.md` -- the hub document where you will add a link
    - `docs/external-harness-roadmap.md` -- issue #139 context
    - `docs/external-harness-integration.md` -- feasibility study context

    ### What to Build

    Create `docs/routing-config.md` following the adapter-interface.md pattern:

    1. **Navigation header**: `[< Back to Architecture Overview](architecture.md) | [Adapter Interface](adapter-interface.md)`

    2. **Title and intro**: "Routing Configuration" -- one paragraph explaining what routing config does and who it is for.

    3. **Format Decision**: Explain why Markdown field tables with YAML examples, not JSON Schema or TypeScript (same rationale as adapter-interface.md).

    4. **Progressive Examples** (examples first, then field tables):

       **Minimal Example** -- `default: claude-code` only. Show the YAML, explain this is the explicit equivalent of zero-config.

       **Group Routing Example** -- default + groups. Show routing `development-quality` to `codex`.

       **Full Example** -- all four sections. Use canonical group IDs and demonstrate resolution order with inline comments.

    5. **Field Tables** (one per section):
       - `default` -- required, string, harness name from allowlist
       - `groups` -- optional, map of canonical group ID to harness name
       - `agents` -- optional, map of agent name to harness name
       - `model-mapping` -- optional, map of harness name to tier-model pairs

    6. **Resolution Order**: Algorithm description: agent > group > default > implicit claude-code. Include edge case: what happens when an agent appears in both `agents:` and its group is in `groups:` (agent wins).

    7. **Capability Gating**: Explain what it is, when it runs (load time), the capability registry (table showing each harness and its supported tools), and example error message format.

    8. **Zero-Config Behavior**: No file = everything routes to claude-code. Silent, fast, no yq required.

    9. **User-Level Override**: Path (`~/.claude/nefario/routing.yml`), merge semantics (shallow per-section), trust model (user overrides project).

    10. **Canonical Group IDs**: Table of all 9 group IDs and their agent members.

    11. **Validation Errors**: Example error messages for each category (syntax, missing default, unknown harness, capability mismatch).

    12. **Fields Considered and Excluded**: Document these YAGNI exclusions with brief rationale:
        - JSON Schema output
        - "Did you mean?" suggestions
        - CI/CD environment variable overrides
        - User-editable `capabilities:` section
        - Arbitrary/user-defined group names

    13. **Stability Note**: "This specification is part of Milestone 1 and may evolve as Milestone 2 (Codex) and Milestone 3 (Aider) validate the routing surface."

    ### Cross-Links to Add

    a. Add a row to `docs/architecture.md`'s "Contributor / Architecture" table:
       `| [Routing Configuration](routing-config.md) | `.nefario/routing.yml` schema, resolution order, capability gating, zero-config behavior |`

    b. Add link in `docs/external-harness-roadmap.md` under issue #139:
       `**Specification**: [Routing Configuration](routing-config.md)` (mirroring how #138 links to adapter-interface.md)

    c. Add link in `docs/external-harness-integration.md`'s "Routing and Configuration" section:
       "For the full specification, see [Routing Configuration](routing-config.md)."

    ### What NOT to Do

    - Do NOT invent schema features not implemented in the loader
    - Do NOT add implementation details (code snippets from the loader)
    - Do NOT create a separate "trust model" document -- the trust model section lives within this doc
    - Do NOT modify the config loader or test files
    - Do NOT create a JSON Schema or TypeScript definition

    ### Deliverables

    - `docs/routing-config.md` -- the specification document
    - Updated `docs/architecture.md` -- one new row in the sub-documents table
    - Updated `docs/external-harness-roadmap.md` -- specification link under #139
    - Updated `docs/external-harness-integration.md` -- cross-link to spec
- **Deliverables**: `docs/routing-config.md`, updated cross-links in 3 existing docs
- **Success criteria**: Doc follows adapter-interface.md pattern; all field tables match implemented behavior; examples are valid YAML that the loader would accept; cross-links work; YAGNI exclusions documented.

---

### Cross-Cutting Coverage

- **Testing**: Task 2 (test-minion) covers all acceptance criteria and edge cases with integration tests following the established test-hooks.sh pattern.
- **Security**: Incorporated directly into Task 1 prompt. security-minion's recommendations (file size limits, path canonicalization, character allowlists, anchor rejection, trust hierarchy logging) are all encoded as validation requirements in the loader spec. Separate security task not needed -- the security surface is the validation logic itself.
- **Usability -- Strategy**: ux-strategy-minion's recommendations are incorporated: progressive disclosure ladder, canonical group IDs (recognition over recall), category-batched error reporting, startup routing summary log line. No separate task needed -- these are design decisions baked into the loader and doc specs.
- **Usability -- Design**: Not applicable. No UI components are produced -- this is a YAML config file and shell script. No ux-design-minion or accessibility-minion needed.
- **Documentation**: Task 3 (software-docs-minion) creates the standalone spec doc with cross-links to the architecture hub.
- **Observability**: Not applicable. This is a config loader that runs at orchestration startup, not a production service. The startup log lines (routing status) serve the diagnostic role without requiring logging/metrics/tracing infrastructure.

### Architecture Review Agents

- **Mandatory** (5): security-minion, test-minion, ux-strategy-minion, lucy, margo
- **Discretionary picks**:
  - software-docs-minion: Task 3 produces documentation that defines the routing contract. Review ensures doc accuracy matches implementation and follows the adapter-interface.md pattern.
    Review focus: Field table accuracy, example YAML validity, cross-link completeness.
- **Not selected**:
  - ux-design-minion: No UI components produced. Config is YAML-edited, errors are terminal output.
  - accessibility-minion: No web-facing UI. Terminal output only.
  - sitespeed-minion: No web-facing runtime. Config loads at orchestration startup.
  - observability-minion: Single startup-time script, not a runtime service. Diagnostic logging is built into the loader.
  - user-docs-minion: End users do not interact with routing config directly -- this is a developer/operator surface. software-docs-minion covers it.

### Decisions

- **Error batching strategy**
  Chosen: Category-batched (report all errors within first failing category)
  Over: Stop-at-first-error (devx-minion) and report-all-errors (ux-strategy-minion)
  Why: Category-batched gives the best of both -- actionable (no meaningless errors from later categories) and efficient (no fix-one-reload cycles within a category)

- **User-level config path**
  Chosen: `~/.claude/nefario/routing.yml`
  Over: `~/.nefario/routing.yml` (devx-minion), `~/.config/nefario/routing.yml` (security-minion mentioned XDG)
  Why: Users already know `~/.claude/` as the despicable-agents config root. Recognition over recall. Consistent with agent/skill deployment paths.

- **User-level merge semantics**
  Chosen: Shallow-per-section merge (user sections replace corresponding project sections; unspecified sections inherit)
  Over: Full replacement (security-minion) where user config entirely replaces project config
  Why: Full replacement forces users to copy and maintain the entire project config for one-section overrides. Shallow merge is predictable and used by comparable tools (Docker Compose, npm config).

- **Codex capability set**
  Chosen: `[Read, Write, Edit, Bash, Glob, Grep]` (6 tools)
  Over: `[Read, Write, Edit, Bash]` (4 tools, api-design-minion)
  Why: Glob/Grep are achievable via Bash in Codex's sandboxed environment. Consistent with feasibility study assessment. One-line change if M2 validation shows otherwise.

### Risks and Mitigations

1. **yq version fragmentation** (HIGH likelihood, MEDIUM impact): Two incompatible tools named `yq` exist. Mitigation: Loader verifies Mike Farah Go version via `yq --version` parsing at startup. Actionable error if wrong version detected.

2. **Capability registry staleness** (MEDIUM likelihood, LOW impact): Hardcoded tool lists for codex/aider may not match actual tool behavior. Mitigation: False positives (blocking valid routing) are preferable to false negatives (allowing invalid routing). Registry is a single location, one-line update per harness. M2/M3 validation milestones will confirm.

3. **Group membership drift** (LOW likelihood, LOW impact): If agent roster changes, hardcoded group mapping becomes stale. Mitigation: Mapping is a single data structure in the loader. Add a test (in Task 2) that verifies group mapping against discovered AGENT.md files.

4. **AGENT.md access at load time** (MEDIUM likelihood, MEDIUM impact): Capability gating requires reading AGENT.md frontmatter. If agents are not installed (symlinks missing), gating fails. Mitigation: Loader accepts `--agent-dir` flag for explicit agent root. Clear error when an agent's AGENT.md cannot be found. For agents with no `tools:` field, treat as requiring all tools (documented behavior).

5. **Model ID typos invisible until invocation** (MEDIUM likelihood, LOW impact): Model IDs are opaque strings; `claude-opus-4-6` vs `claude-opus-4.6` passes validation but fails at adapter invocation time. Mitigation: Accepted risk for M1. Document that model IDs are validated only by character pattern, not against provider catalogs.

### Execution Order

```
Phase 1 (Gate):  Task 1 -- Config Loader Implementation
                  |
                  v
            [APPROVAL GATE: Schema + Loader]
                  |
                  v
Phase 2 (Parallel): Task 2 -- Tests  |  Task 3 -- Documentation
```

Batch 1: Task 1 (devx-minion). Blocked by nothing. Produces the loader.
Gate: User reviews the schema decisions embedded in the implementation.
Batch 2: Task 2 (test-minion) and Task 3 (software-docs-minion) run in parallel, both depending on Task 1's output.

### Verification Steps

After all tasks complete:
1. Run `bash tests/test-routing-config.sh` -- all tests pass (exit 0)
2. Run `bash lib/load-routing-config.sh` with no `.nefario/routing.yml` -- outputs zero-config JSON
3. Create `.nefario/routing.yml` with `default: claude-code` -- loads without error
4. Create a config routing an agent with WebSearch to aider -- produces capability gating error
5. Verify `docs/routing-config.md` links work from `docs/architecture.md`
6. Verify cross-links in `docs/external-harness-roadmap.md` and `docs/external-harness-integration.md`
