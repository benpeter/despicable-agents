## Delegation Plan

**Team name**: adapter-interface-definition
**Description**: Define the `DelegationRequest` and `DelegationResult` types as a Markdown specification document, with field tables, YAML examples, and behavioral contract. No implementation code -- types and contracts only.

---

### Conflict Resolutions

**Conflict 1: Format -- TS interface notation vs. Markdown field tables**

api-design-minion recommended TypeScript interface syntax as specification notation. devx-minion explicitly recommended against it, arguing: (a) the codebase is pure Markdown and shell with no TypeScript anywhere, (b) the roadmap says "No TypeScript orchestrator," (c) the existing precedent in `docs/agent-anatomy.md` uses YAML examples + field tables, (d) the consumers are humans and LLMs reading Markdown, not compilers.

- **Chosen**: Markdown field tables with YAML examples (devx-minion's recommendation)
- **Over**: TypeScript interface notation as spec language (api-design-minion's recommendation)
- **Why**: The codebase convention is authoritative. `docs/agent-anatomy.md` already defines a structured contract (AGENT.md frontmatter schema) using exactly the YAML-example + field-table pattern. Following this pattern creates consistency for adapter authors. TypeScript notation in a codebase with zero TypeScript files creates false expectations. The "Type" column in field tables uses plain-English type descriptors (`string`, `integer`, `list of FileChange`) -- unambiguous without a type system.

**Conflict 2: Status representation -- status enum vs. adapter_error boolean vs. success boolean**

Three proposals:
- api-design-minion: `status` enum (`completed | failed | timeout`) alongside raw `exitCode`
- ai-modeling-minion: `adapter_error` boolean alongside `exitCode` (three-state: success/failure/error)
- ux-strategy-minion: `success` boolean alongside `exitCode`

- **Chosen**: `success` boolean + raw `exit_code` integer. No enum, no `adapter_error` boolean.
- **Over**: Three-value `status` enum (api-design-minion); `adapter_error` boolean (ai-modeling-minion)
- **Why**: The orchestrator makes binary decisions: proceed or handle failure. A `success` boolean lets the adapter normalize tool-specific exit code semantics (e.g., Aider returning 1 for "no changes needed" which is not failure) so the orchestrator never needs per-tool exit code knowledge. This is the strongest argument from ux-strategy-minion -- without it, the abstraction leaks. The `adapter_error` boolean adds a third state (infra failure vs. task failure) that the orchestrator does not yet handle differently -- both cases surface to the user as a blocked task. Per YAGNI, the two-state `success` boolean is sufficient. The `status` enum adds vocabulary (`completed`, `timeout`) without adding information beyond what `success` + `exit_code` already convey. If the orchestrator needs to distinguish timeout from task failure later (M8 hardening), adding `timed_out: boolean` is a non-breaking additive change. Keep `exit_code` as the raw integer for debugging and adapter-specific diagnostics.

**Conflict 3: Additional fields beyond roadmap scope**

Proposals for fields not in the roadmap's Issue 1.1 scope:
- api-design-minion: `timeout` (request), `contextFiles` (request)
- ai-modeling-minion: `rationale` (result), `adapter_error` (result), `duration_ms` (result), `requires_rationale` (request)
- ux-strategy-minion: `duration_ms` (result), `success` (result)

Assessment against YAGNI:

| Proposed Field | Include? | Rationale |
|----------------|----------|-----------|
| `timeout_ms` (request) | Yes | Referenced in Issues 2.1 and 3.2 acceptance criteria. Adapters need this; omitting forces adapter-specific hardcoding. |
| `success` (result) | Yes | Resolved in Conflict 2 above. Required to prevent abstraction leakage. |
| `duration_ms` (result) | Yes | Consensus across ai-modeling-minion and ux-strategy-minion. Costs nothing; avoids breaking change when M4 progress monitoring needs it. |
| `context_files` (request) | No | Only Aider uses `--read` for reference files. Can be added when the Aider adapter (M3) validates the need. |
| `requires_rationale` (request) | No | The orchestrator can embed rationale instructions in the task prompt itself. A boolean flag on the request couples the adapter to orchestration concepts (approval gates) that are nefario-internal. |
| `rationale` (result) | No | Not mechanically extractable. Depends on structured output (Codex) or LLM inference (Aider). Can be part of result summarization (Issue 3.1) without being a typed field. |
| `adapter_error` (result) | No | Resolved in Conflict 2. `success` boolean is sufficient. |

- **Chosen**: Add `timeout_ms`, `success`, `duration_ms`. Exclude `context_files`, `requires_rationale`, `rationale`, `adapter_error`.
- **Over**: Including all proposed fields (maximalist approach)
- **Why**: The three included fields are either consensus (duration_ms), required for abstraction integrity (success), or referenced by downstream acceptance criteria (timeout_ms). The excluded fields either have no consumer in M1-M4 or can be added non-breakingly when a concrete use case validates them. This follows the roadmap's YAGNI constraint.

---

### Field Naming Resolutions

ux-strategy-minion identified four naming issues. Resolutions:

| Original Name | ux-strategy Recommendation | Resolution | Rationale |
|---------------|---------------------------|------------|-----------|
| `instruction_file_path` | `translated_instruction_path` | Accept rename | "Translated" communicates that Issue 1.3 already produced this file. Prevents adapter authors from duplicating translation. |
| `stdout_summary` | `task_summary` | Accept rename | The field contains a semantic summary regardless of source (parsed stdout for Codex, LLM-generated for Aider). Name should describe meaning, not provenance. |
| `raw_diff_reference` | Specify representation | Use `raw_diff_path` | Pin as a file path to a saved unified diff. Eliminates the ambiguity (file path vs. git ref vs. inline content). |
| `required_tools` | `required_agent_tools` | Accept rename | Disambiguates from tools the adapter itself needs. |

---

### Task 1: Write `docs/adapter-interface.md`

- **Agent**: software-docs-minion
- **Delegation type**: standard
- **Model**: sonnet
- **Mode**: default
- **Blocked by**: none
- **Approval gate**: yes
- **Gate reason**: This document is the root contract for all Milestones 2-4. Every downstream adapter, config loader, and routing dispatcher implements against it. Mistakes here propagate to 9 downstream issues. Hard to reverse once adapters are built against it.
- **Gate rationale**:
    Chosen: Markdown field tables with YAML examples, following `docs/agent-anatomy.md` pattern
    Over: TypeScript interface notation (api-design-minion); JSON Schema (considered and rejected by devx-minion)
    Why: Matches codebase convention, consumers are humans and LLMs, no TypeScript in the project
- **Prompt**: |
    Create `docs/adapter-interface.md` -- the type definition and contract specification for the external harness adapter layer.

    ## Context

    You are writing the canonical contract document for despicable-agents' external harness integration. This document defines the `DelegationRequest` and `DelegationResult` types that all adapter implementations (Codex CLI, Aider, future tools) must conform to. It is Issue 1.1 of the external harness roadmap. Every downstream issue (1.2, 1.3, 2.1, 2.2, 3.1, 3.2, 3.3) implements against this document.

    ## Format

    Follow the existing `docs/agent-anatomy.md` pattern exactly:
    - YAML example block showing a realistic instance with all fields populated
    - Field table with columns: Field | Required | Type | Description
    - Semantics notes for anything the table cannot capture

    Use YAML pseudo-definitions in fenced code blocks. Do NOT use TypeScript interface notation or JSON Schema. The "Type" column uses plain-English type descriptors: `string`, `integer`, `boolean`, `list of strings`, `list of FileChange (see below)`.

    This is the format decision required by the roadmap -- include a brief "Format Decision" section documenting that Markdown field tables with YAML examples were chosen because the codebase is Markdown-native, consumers are humans and LLMs, and this matches the existing `agent-anatomy.md` pattern.

    ## Document Structure

    ```
    docs/adapter-interface.md
    +-- Back-link to architecture.md + external-harness-roadmap.md
    +-- Purpose (2-3 sentences: what these types are, who produces/consumes them)
    +-- Format Decision (why Markdown field tables, not TS or JSON Schema)
    +-- DelegationRequest
    |   +-- YAML example (realistic Codex delegation)
    |   +-- Field table
    |   +-- Semantics notes
    +-- DelegationResult
    |   +-- YAML example (success case)
    |   +-- YAML example (failure case)
    |   +-- Field table
    |   +-- Semantics notes
    +-- FileChange (sub-type for changed_files)
    |   +-- Field table
    +-- Adapter Behavioral Contract
    |   +-- Lifecycle (translate, invoke, collect, clean up)
    |   +-- Error handling (cleanup on failure, exit code propagation)
    |   +-- What adapters must NOT do
    +-- Fields Considered and Excluded (with rationale for each)
    +-- Stability Note
    ```

    ## DelegationRequest Fields

    Define these fields in the field table:

    | Field | Required | Type | Description |
    |-------|----------|------|-------------|
    | `agent_name` | yes | string | Canonical agent name matching AGENT.md frontmatter `name` field (e.g., `frontend-minion`). Used for routing config resolution. |
    | `task_prompt` | yes | string | The complete task prompt, already stripped of Claude Code-specific instructions (TaskUpdate, SendMessage, scratch directory conventions). The adapter passes this to the external tool as-is. |
    | `translated_instruction_path` | yes | string | Absolute path to the tool-native instruction file produced by the AGENT.md translator (Issue 1.3). The adapter passes this to the tool and cleans it up after invocation. The adapter does NOT translate AGENT.md itself -- that is already done before the adapter is called. |
    | `working_directory` | yes | string | Absolute, canonicalized path to the working directory. The adapter invokes the tool in this directory. Must be validated as an existing directory before invocation. |
    | `model_tier` | yes | string (enum: `opus`, `sonnet`) | Quality-intent signal, not a model ID. The adapter resolves this to a provider-specific model ID via the routing config's `model-mapping` section. Uses the existing project vocabulary (`opus`/`sonnet`) matching AGENT.md frontmatter convention. |
    | `required_agent_tools` | yes | list of strings | Tool capabilities the AI agent needs during execution (e.g., `["Bash", "Read", "Edit"]`). Used for capability gating: the routing config loader (Issue 1.2) validates that the target harness supports these tools before routing. |
    | `timeout_ms` | no | integer | Maximum wall-clock execution time in milliseconds. Adapter enforces this and terminates the tool if exceeded. Default: 1800000 (30 minutes). |

    ## DelegationResult Fields

    Define these fields in the field table:

    | Field | Required | Type | Description |
    |-------|----------|------|-------------|
    | `exit_code` | yes | integer | Raw process exit code. 0 typically means success, but interpretation is adapter-specific. Preserved for debugging and diagnostics. |
    | `success` | yes | boolean | Normalized success signal. The adapter sets this based on exit code and tool-specific semantics (e.g., Aider returning 1 for "no changes needed" may still be success). The orchestrator reads this field, not `exit_code`, for routing decisions. |
    | `changed_files` | yes | list of FileChange | Files modified during execution, collected via `git diff --name-status --numstat` against a pre-invocation git ref. Empty list is valid (task may have made no file changes). |
    | `task_summary` | yes (when success is true) | string | Human-readable summary of what the task accomplished (1-2 sentences). May come from parsed structured output (Codex `--output-schema`) or LLM-generated summarization (Aider via Issue 3.1). Describes the semantic outcome, not the mechanical changes. |
    | `stderr` | no | string | Raw stderr output, truncated to last 50 lines. Useful for diagnosing failures. |
    | `raw_diff_path` | no | string | Absolute file path to the saved full unified diff output. Written by the adapter for debugging. The orchestrator does not process this -- it exists for human inspection and the review gate. May be cleaned up after the orchestration session. |
    | `duration_ms` | no | integer | Wall-clock execution time in milliseconds. Measured from tool invocation start to completion/timeout. |

    ## FileChange Sub-Type

    | Field | Required | Type | Description |
    |-------|----------|------|-------------|
    | `path` | yes | string | File path relative to `working_directory`. |
    | `action` | yes | string (enum: `added`, `modified`, `deleted`, `renamed`) | What happened to this file. Sourced from `git diff --name-status`. |
    | `lines_added` | yes | integer | Lines added. From `git diff --numstat`. 0 for deleted files. |
    | `lines_removed` | yes | integer | Lines removed. From `git diff --numstat`. 0 for added files. |

    ## Adapter Behavioral Contract

    Document these behavioral expectations:

    **Lifecycle** (what an adapter must do, in order):
    1. Receive a `DelegationRequest`
    2. Capture pre-invocation git ref (`git rev-parse HEAD`)
    3. Place the translated instruction file (path provided in `translated_instruction_path`)
    4. Invoke the external tool with the task prompt in the working directory
    5. Wait for completion or timeout
    6. Collect results: exit code, git diff against pre-invocation ref, summary
    7. Clean up temporary files (translated instruction file)
    8. Return a `DelegationResult`

    **Error handling**:
    - Temporary files (translated instruction file) MUST be cleaned up on both success and failure (use trap or equivalent)
    - If the adapter itself crashes (cannot invoke tool, tool binary not found), set `success: false`, `exit_code: -1`, and include diagnostic info in `stderr`
    - If timeout is triggered, terminate the tool process, set `success: false`, and collect whatever partial results are available

    **What adapters must NOT do**:
    - Modify the task prompt beyond tool-specific formatting requirements
    - Make planning or routing decisions (that is the orchestrator's job)
    - Commit to git (some tools auto-commit; the adapter should document this behavior but not prevent it)
    - Read or interpret approval gate metadata (the adapter is unaware of orchestration phases)

    ## Fields Considered and Excluded

    Document these excluded fields with rationale:

    | Field | Proposed by | Excluded because |
    |-------|------------|-----------------|
    | `auto_approve` | Prior synthesis | Always true for headless delegation. A field that is never false carries no information. |
    | `context_files` | api-design-minion | Only Aider uses `--read` for reference files. Defer to Milestone 3 when the Aider adapter validates the need. |
    | `requires_rationale` | ai-modeling-minion | Couples the adapter to orchestration concepts (approval gates). The orchestrator can embed rationale instructions in the task prompt instead. |
    | `rationale` | ai-modeling-minion | Not mechanically extractable. Depends on structured output or LLM inference. Can be part of result summarization (Issue 3.1) without being a typed field. |
    | `adapter_error` | ai-modeling-minion | `success: false` with diagnostic `stderr` covers this case. The orchestrator does not yet distinguish infrastructure failure from task failure in its error handling. |
    | `environment` | Prior synthesis | Passes environment variables to subprocess. Security concern (API keys in delegation requests) without a concrete use case. |
    | `status` enum | api-design-minion | Three-value enum (`completed`/`failed`/`timeout`) does not add information beyond `success` boolean + `exit_code`. Timeout can be distinguished by `exit_code` if needed. |
    | `token_usage` | N/A | Out of scope per roadmap (M7 at earliest). |

    ## Stability Note

    Include a note: "This interface is expected to evolve based on Codex (Milestone 2) and Aider (Milestone 3) validation. Issue 3.4 explicitly includes an interface health check. Fields may be added (non-breaking) or adjusted (documented as breaking) based on adapter implementation experience."

    ## YAML Examples

    For the DelegationRequest example, use a realistic scenario: delegating a documentation task to `software-docs-minion` via a Codex adapter. Use real agent names from the project.

    For DelegationResult, show two examples:
    1. Success case: exit_code 0, success true, changed_files with 2 entries, task_summary populated
    2. Failure case: exit_code 1, success false, changed_files empty, stderr populated

    ## Cross-References

    - Start the document with: `[< Back to Architecture Overview](architecture.md) | [External Harness Roadmap](external-harness-roadmap.md)`
    - This follows the back-link pattern used by all docs in the project

    ## What NOT to Do

    - Do NOT use TypeScript interface notation or JSON Schema
    - Do NOT create a separate adapter authoring guide (YAGNI -- only two adapters in scope)
    - Do NOT add fields beyond those specified above
    - Do NOT include implementation details for any specific adapter (Codex or Aider)
    - Do NOT modify any file other than `docs/adapter-interface.md`

- **Deliverables**: `docs/adapter-interface.md` (new file)
- **Success criteria**:
    - Every field from the roadmap's Issue 1.1 scope appears with type, optionality, and description
    - Document follows the `agent-anatomy.md` pattern (YAML example + field table + notes)
    - Format decision is documented
    - Behavioral contract section covers lifecycle, error handling, and boundaries
    - "Fields Considered and Excluded" section documents rejected alternatives
    - Back-link to `architecture.md` and `external-harness-roadmap.md`

### Task 2: Link from architecture hub and roadmap

- **Agent**: software-docs-minion
- **Delegation type**: standard
- **Model**: sonnet
- **Mode**: default
- **Blocked by**: Task 1
- **Approval gate**: no
- **Prompt**: |
    Make two small edits to link the new `docs/adapter-interface.md` into the existing documentation structure.

    ## Edit 1: `docs/architecture.md`

    In the "Contributor / Architecture" table, add a new row for the adapter interface document. Add it after the "External Harness Roadmap" row:

    ```
    | [Adapter Interface](adapter-interface.md) | DelegationRequest/DelegationResult type definitions, adapter behavioral contract |
    ```

    ## Edit 2: `docs/external-harness-roadmap.md`

    In the Issue 1.1 section, after the "Acceptance criteria" list, add:

    ```
    **Specification**: [docs/adapter-interface.md](adapter-interface.md)
    ```

    This creates a forward pointer from the roadmap issue to the delivered specification.

    ## What NOT to Do

    - Do NOT modify `docs/adapter-interface.md`
    - Do NOT modify any other files
    - Do NOT change existing content in either file -- only add the specified lines

- **Deliverables**: Updated `docs/architecture.md` (one row added), updated `docs/external-harness-roadmap.md` (one line added)
- **Success criteria**:
    - `docs/architecture.md` contains a link to `adapter-interface.md` in the Contributor / Architecture table
    - `docs/external-harness-roadmap.md` Issue 1.1 section contains a link to the specification

---

### Cross-Cutting Coverage

- **Testing**: Not applicable. This task produces a specification document, not executable code or configuration. No tests to write or run. Phase 6 will confirm no test regressions.
- **Security**: Covered within Task 1's prompt. The behavioral contract section addresses: working directory must be an absolute canonicalized path, instruction file cleanup on crash (trap), exclusion of the `environment` field to avoid API keys in delegation requests. A dedicated security-minion review is unnecessary for a Markdown specification with no executable surface.
- **Usability -- Strategy**: Incorporated. ux-strategy-minion's field naming recommendations (4 renames) are adopted in the synthesis. The "cold read" validation recommended by ux-strategy is handled by the approval gate -- the user reviews the document before downstream work proceeds.
- **Usability -- Design**: Not applicable. No user-facing interface is produced.
- **Documentation**: This task IS the documentation. software-docs-minion is the primary agent. Task 2 handles cross-references.
- **Observability**: Not applicable. No runtime components are produced.

### Architecture Review Agents

- **Mandatory** (5): security-minion, test-minion, ux-strategy-minion, lucy, margo
- **Discretionary picks**:
    - None selected. This task produces a single Markdown specification document with no UI, no runtime components, no web-facing output, and no coordinated services. All discretionary reviewer domain signals (UI components, web-facing HTML, 2+ runtime components, user-facing changes) are absent.
- **Not selected**:
    - ux-design-minion: No UI components or interaction patterns produced
    - accessibility-minion: No web-facing HTML/UI produced
    - sitespeed-minion: No web-facing runtime code produced
    - observability-minion: No runtime components produced
    - user-docs-minion: No end-user-facing behavior changes; this is an internal architecture contract

### Decisions

- **Format for type definitions**
  Chosen: Markdown field tables with YAML examples (devx-minion)
  Over: TypeScript interface notation (api-design-minion)
  Why: Matches existing `agent-anatomy.md` pattern; codebase has zero TypeScript files; consumers are humans and LLMs, not compilers

- **Status representation**
  Chosen: `success` boolean + raw `exit_code` (ux-strategy-minion's core argument)
  Over: Three-value `status` enum (api-design-minion); `adapter_error` boolean (ai-modeling-minion)
  Why: Binary signal matches orchestrator's decision model; prevents abstraction leakage (orchestrator never needs per-tool exit code knowledge); third-state distinction deferred to M8 per YAGNI

- **Additional fields beyond roadmap**
  Chosen: Add `timeout_ms`, `success`, `duration_ms` only
  Over: Including `context_files`, `requires_rationale`, `rationale`, `adapter_error` (ai-modeling-minion, api-design-minion)
  Why: Three fields are either consensus, required for abstraction integrity, or referenced by downstream acceptance criteria. Remaining fields have no consumer in M1-M4 and can be added non-breakingly later.

- **Field naming**
  Chosen: Adopt ux-strategy-minion's four renames (`translated_instruction_path`, `task_summary`, `raw_diff_path`, `required_agent_tools`)
  Over: Original roadmap names (`instruction_file_path`, `stdout_summary`, `raw_diff_reference`, `required_tools`)
  Why: Eliminates name-meaning mismatches that would cause adapter authors to misunderstand field semantics on first read

### Risks and Mitigations

1. **Premature abstraction** (api-design-minion, software-docs-minion). The types are defined before any adapter implementation validates them. Mitigation: the stability note explicitly states the interface may evolve. Issue 3.4 includes an interface health check. Fields are kept minimal to reduce the surface area of potential changes.

2. **Spec-implementation drift** (devx-minion). With no type checker, adapter wrappers could diverge from the spec. Mitigation: acceptable for two adapters. Issue 3.4 (Aider validation) explicitly catches drift. If adapter count exceeds three, add shell-based field presence validation.

3. **Rationale quality degradation for external harnesses** (ai-modeling-minion). The orchestrator's approval gate briefs depend on agent-reported rationale. External harnesses cannot reliably provide "rejected alternatives" without structured output or post-hoc LLM inference. Mitigation: documented as known limitation. For high-stakes gated tasks, routing config should favor harnesses with structured output. This is an Issue 3.1 design consideration, not an Issue 1.1 concern.

4. **`success` boolean may be insufficient for retry logic** (api-design-minion). M8 hardening may need to distinguish timeout from task failure for retry decisions. Mitigation: adding `timed_out: boolean` later is a non-breaking additive change. Do not pre-build the retry taxonomy.

### Execution Order

```
Batch 1 (gated):  Task 1 -- Write docs/adapter-interface.md
                   [APPROVAL GATE -- user reviews the contract document]
Batch 2:          Task 2 -- Link from architecture hub and roadmap
```

### Verification Steps

After all tasks complete:
1. Confirm `docs/adapter-interface.md` exists and contains both type definitions with field tables
2. Confirm `docs/architecture.md` contains a link to `adapter-interface.md`
3. Confirm `docs/external-harness-roadmap.md` Issue 1.1 references the specification
4. Verify every field from the roadmap's Issue 1.1 scope section appears in the document
5. Verify no harness-specific fields are present (acceptance criteria)
6. Verify the document follows the `agent-anatomy.md` pattern (YAML example + field table)
