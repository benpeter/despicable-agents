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
+-- Back-link: [< Back to Architecture Overview](architecture.md) | [External Harness Roadmap](external-harness-roadmap.md)
+-- Purpose (2-3 sentences: what these types are, who produces/consumes them)
+-- Format Decision (why Markdown field tables, not TS or JSON Schema)
+-- Field Names Refined from Roadmap (mapping table)
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
|   +-- Boundary rules (what adapters must and must NOT do)
|   +-- Error handling (cleanup on failure, exit code propagation)
|   +-- Security requirements
+-- Fields Considered and Excluded (with rationale for each + decay clause)
+-- Stability Note
```

## Field Names Refined from Roadmap

The roadmap (Issue 1.1) used working names. This spec refines them for clarity. Include a mapping table early in the document so readers cross-referencing the roadmap can orient:

| Roadmap Name | Spec Name | Why Renamed |
|-------------|-----------|-------------|
| `instruction_file_path` | `translated_instruction_path` | Communicates that Issue 1.3 already produced this file; prevents adapter authors from duplicating translation |
| `stdout_summary` | `task_summary` | Field contains semantic summary regardless of source (parsed stdout or LLM-generated); name describes meaning, not provenance |
| `raw_diff_reference` | `raw_diff_path` | Pins representation as a file path, eliminating ambiguity (file path vs git ref vs inline content) |
| `required_tools` | `required_agent_tools` | Disambiguates from tools the adapter itself needs |

## DelegationRequest Fields

Define these fields in the field table:

| Field | Required | Type | Description |
|-------|----------|------|-------------|
| `agent_name` | yes | string | Canonical agent name matching AGENT.md frontmatter `name` field (e.g., `frontend-minion`). Used for routing config resolution. |
| `task_prompt` | yes | string | The complete task prompt, already stripped of Claude Code-specific instructions (TaskUpdate, SendMessage, scratch directory conventions). The adapter passes this to the external tool. |
| `translated_instruction_path` | yes | string | Absolute path to the tool-native instruction file produced by the AGENT.md translator (Issue 1.3). The adapter passes this to the tool and cleans it up after invocation. The adapter does NOT translate AGENT.md itself -- that is already done before the adapter is called. |
| `working_directory` | yes | string | Absolute, canonicalized path to the working directory with symlinks resolved. The adapter invokes the tool in this directory. Must be validated: canonicalize (resolve symlinks), then verify the resolved path falls within an allowlisted root (project repository root or explicitly configured base path). Reject requests whose canonicalized path resolves outside the allowed root. |
| `model_tier` | yes | string (enum: `opus`, `sonnet`) | Quality-intent signal, not a model ID. The adapter resolves this to a provider-specific model ID via the routing config's `model-mapping` section. Uses the existing project vocabulary (`opus`/`sonnet`) matching AGENT.md frontmatter convention. |
| `required_agent_tools` | yes | list of strings | Tool capabilities the AI agent needs during execution (e.g., `["Bash", "Read", "Edit"]`). Used for capability gating: the routing config loader (Issue 1.2) validates that the target harness supports these tools before routing. |
| `timeout_ms` | no | integer | Maximum wall-clock execution time in milliseconds. Adapter enforces this and terminates the tool if exceeded. Default: 1800000 (30 minutes). |

## DelegationResult Fields

Define these fields in the field table:

| Field | Required | Type | Description |
|-------|----------|------|-------------|
| `exit_code` | yes | integer | Raw process exit code. 0 typically means success, but interpretation is adapter-specific. Preserved for debugging and diagnostics. |
| `success` | yes | boolean | Normalized success signal. The adapter sets this based on exit code and tool-specific semantics (e.g., Aider returning 1 for "no changes needed" may still be success). The orchestrator reads this field, not `exit_code`, for routing decisions. See "Success Normalization Constraints" in the behavioral contract. |
| `changed_files` | yes | list of FileChange | Files modified during execution, collected via `git diff --name-status --numstat` against a pre-invocation git ref. Empty list is valid (task may have made no file changes). |
| `task_summary` | yes (when success is true) | string | Human-readable summary of what the task accomplished (1-2 sentences). May come from parsed structured output (Codex `--output-schema`) or LLM-generated summarization (Aider via Issue 3.1). Describes the semantic outcome, not the mechanical changes. |
| `stderr` | no | string | Raw stderr output, truncated to last 50 lines. Useful for diagnosing failures. |
| `raw_diff_path` | no | string | Absolute file path to the saved full unified diff output. Written by the adapter for debugging. The orchestrator does not process this -- it exists for human inspection and the review gate. Must be created with restricted permissions (mode 0600) in a session-scoped subdirectory under a secure temp location, not in the working directory itself. Must be cleaned up within the orchestration session; if the orchestrator does not consume this file within the session, the adapter is responsible for deletion. |
| `duration_ms` | no | integer | Wall-clock execution time in milliseconds. Measured from tool invocation start to completion/timeout. |

## FileChange Sub-Type

| Field | Required | Type | Description |
|-------|----------|------|-------------|
| `path` | yes | string | File path relative to `working_directory`. |
| `action` | yes | string (enum: `added`, `modified`, `deleted`, `renamed`) | What happened to this file. Sourced from `git diff --name-status`. |
| `lines_added` | yes | integer | Lines added. From `git diff --numstat`. 0 for deleted files. |
| `lines_removed` | yes | integer | Lines removed. From `git diff --numstat`. 0 for added files. |

## Adapter Behavioral Contract

Document these behavioral expectations. Focus on boundary rules and contracts -- NOT step-by-step lifecycle choreography (that belongs to the adapter implementation issues 2.1 and 3.2).

**Boundary rules -- what adapters MUST do**:
- Validate `working_directory`: canonicalize (resolve symlinks), verify the resolved path falls within an allowlisted root (project repository root or an explicitly configured base path). Reject requests whose canonicalized path resolves outside the allowed root.
- Invoke external tools using argument vector APIs (execv-family, subprocess with list args, child_process.execFile) -- never via shell string interpolation of `task_prompt`. This prevents shell command injection (CWE-78) when the task prompt contains metacharacters.
- Clean up temporary files (translated instruction file) on both success and failure (use trap or equivalent).
- Create temporary files (translated instruction file, raw diff) with restricted permissions (mode 0600 or equivalent) in a session-scoped subdirectory under a secure temp location, not in the working directory itself.
- Source their own secrets from the host environment or a dedicated secret store -- never from the `DelegationRequest`.
- Enforce `timeout_ms` by terminating the tool process if exceeded.

**Error handling**:
- Temporary files MUST be cleaned up on both success and failure (use trap or equivalent)
- If the adapter itself crashes (cannot invoke tool, tool binary not found), set `success: false`, `exit_code: -1`, and include diagnostic info in `stderr`
- If timeout is triggered, terminate the tool process, set `success: false`, and collect whatever partial results are available

**Success normalization constraints**: The following failure categories MUST always produce `success: false`, regardless of adapter-specific exit code normalization:
1. Tool process terminated by signal (exit code < 0 or signaled)
2. Tool binary not found or not executable
3. Working directory not accessible at invocation time
4. Timeout triggered

Normalize-to-success is only permitted for non-zero exit codes that are documented as non-error conditions by the specific tool (e.g., Aider exit 1 = "no changes needed").

**What adapters must NOT do**:
- Modify the task prompt beyond tool-specific formatting requirements
- Pass `task_prompt` as an interpolated shell string; always use argument vector invocation
- Make planning or routing decisions (that is the orchestrator's job)
- Commit to git (some tools auto-commit; the adapter should document this behavior but not prevent it)
- Read or interpret approval gate metadata (the adapter is unaware of orchestration phases)
- Include credential values in any DelegationResult field (especially `stderr` or `task_summary`)
- Log or surface credential-bearing environment variables in diagnostic output

## Fields Considered and Excluded

Document these excluded fields with rationale:

| Field | Proposed by | Excluded because |
|-------|------------|-----------------|
| `auto_approve` | Prior synthesis | Always true for headless delegation. A field that is never false carries no information. |
| `context_files` | api-design-minion | Only Aider uses `--read` for reference files. Defer to Milestone 3 when the Aider adapter validates the need. |
| `requires_rationale` | ai-modeling-minion | Couples the adapter to orchestration concepts (approval gates). The orchestrator can embed rationale instructions in the task prompt instead. |
| `rationale` | ai-modeling-minion | Not mechanically extractable. Depends on structured output or LLM inference. Can be part of result summarization (Issue 3.1) without being a typed field. |
| `adapter_error` | ai-modeling-minion | `success: false` with diagnostic `stderr` covers this case. The orchestrator does not yet distinguish infrastructure failure from task failure in its error handling. |
| `environment` | Prior synthesis | Passes environment variables to subprocess. Security concern: API keys would appear in delegation requests. Adapters source their own secrets from the host environment or a dedicated secret store, and must not log or surface credential-bearing environment variables in `stderr` or diagnostic output. |
| `status` enum | api-design-minion | Three-value enum (`completed`/`failed`/`timeout`) does not add information beyond `success` boolean + `exit_code`. Timeout can be distinguished by `exit_code` if needed. |
| `token_usage` | N/A | Out of scope per roadmap (M7 at earliest). |

After the table, add this decay clause: "This list captures decisions from the initial design. Future field proposals should be evaluated against current needs, not against this list."

## Stability Note

Include a note: "This interface is expected to evolve based on Codex (Milestone 2) and Aider (Milestone 3) validation. Issue 3.4 explicitly includes an interface health check. Fields may be added (non-breaking) or adjusted (documented as breaking) based on adapter implementation experience."

## YAML Examples

For the DelegationRequest example, use a realistic scenario: delegating a documentation task to `software-docs-minion` via a Codex adapter. Use real agent names from the project.

For DelegationResult, show two examples:
1. Success case: exit_code 0, success true, changed_files with 2 entries, task_summary populated, duration_ms populated
2. Failure case: exit_code 1, success false, changed_files empty, stderr populated

## Cross-References

- Start the document with: `[< Back to Architecture Overview](architecture.md) | [External Harness Roadmap](external-harness-roadmap.md)`
- This follows the back-link pattern used by all docs in the project (pipe-separated two-link format)

## What NOT to Do

- Do NOT use TypeScript interface notation or JSON Schema
- Do NOT create a separate adapter authoring guide (YAGNI -- only two adapters in scope)
- Do NOT add fields beyond those specified above
- Do NOT include implementation details for any specific adapter (Codex or Aider)
- Do NOT modify any file other than `docs/adapter-interface.md`
- Do NOT include a step-by-step lifecycle sequence in the behavioral contract (that belongs to implementation issues 2.1/3.2)
