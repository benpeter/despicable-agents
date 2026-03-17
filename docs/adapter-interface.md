[< Back to Architecture Overview](architecture.md) | [External Harness Roadmap](external-harness-roadmap.md)

# Adapter Interface Definition

This document defines `DelegationRequest` and `DelegationResult` -- the shared types that all external harness adapters (Codex CLI, Aider, and future tools) must conform to. The orchestrator produces `DelegationRequest` and consumes `DelegationResult`; adapters are the bridge between them and the external tool. No adapter-specific fields appear in these types.

This is the deliverable for Issue 1.1 of the external harness roadmap. All subsequent issues (1.2, 1.3, 2.1, 2.2, 3.1, 3.2, 3.3) implement against this document.

---

## Format Decision

Types are defined as Markdown field tables with YAML examples. TypeScript interface notation and JSON Schema were considered and rejected:

- **TypeScript** would be appropriate if these types were consumed by a TypeScript runtime. The adapter layer integrates into the existing shell/scripting approach; no TypeScript runtime is being introduced (see "No TypeScript orchestrator" in the roadmap YAGNI constraints).
- **JSON Schema** adds tooling overhead (validators, generators) for no present benefit. Validation is implemented by the config loader (Issue 1.2) reading from these field tables, not from a machine-readable schema.
- **Markdown field tables** match the pattern used throughout this documentation (see `agent-anatomy.md`), keep the format human and LLM-readable without tooling, and live in version control alongside the implementation. The "Type" column uses plain-English type descriptors rather than language-specific syntax.

---

## Field Names Refined from Roadmap

The roadmap (Issue 1.1) used working names. This spec refines them for clarity. Readers cross-referencing the roadmap should use this table to orient:

| Roadmap Name | Spec Name | Why Renamed |
|---|---|---|
| `instruction_file_path` | `translated_instruction_path` | Communicates that Issue 1.3 already produced this file; prevents adapter authors from duplicating translation logic |
| `stdout_summary` | `task_summary` | Field contains semantic summary regardless of source (parsed stdout or LLM-generated); name describes meaning, not provenance |
| `raw_diff_reference` | `raw_diff_path` | Pins representation as a file path, eliminating ambiguity (file path vs. git ref vs. inline content) |
| `required_tools` | `required_agent_tools` | Disambiguates from tools the adapter itself needs |

---

## DelegationRequest

The orchestrator constructs a `DelegationRequest` for each task being routed to an external tool. The adapter receives this as its sole input and must not make planning or routing decisions from it.

### Example

```yaml
# DelegationRequest example: routing a documentation task to software-docs-minion via Codex adapter
agent_name: software-docs-minion
task_prompt: |
  Update docs/adapter-interface.md to reflect the renamed fields confirmed
  during Codex adapter validation. Specifically: rename `instruction_file_path`
  to `translated_instruction_path` in all field tables and YAML examples.
  Do not change prose sections that explain the renaming rationale.
translated_instruction_path: /tmp/nefario-session-a3f7/software-docs-minion.AGENTS.md
working_directory: /Users/ben/github/benpeter/despicable-agents
model_tier: sonnet
required_agent_tools:
  - Read
  - Edit
timeout_ms: 900000
```

### Field Table

| Field | Required | Type | Description |
|---|---|---|---|
| `agent_name` | yes | string | Canonical agent name matching the AGENT.md frontmatter `name` field (e.g., `frontend-minion`). Used for routing config resolution. |
| `task_prompt` | yes | string | The complete task prompt, already stripped of Claude Code-specific instructions (TaskUpdate, SendMessage, scratch directory conventions). The adapter passes this to the external tool unchanged. |
| `translated_instruction_path` | yes | string | Absolute path to the tool-native instruction file produced by the AGENT.md translator (Issue 1.3). The adapter passes this to the tool and cleans it up after invocation. The adapter does NOT translate AGENT.md itself -- that is already done before the adapter is called. |
| `working_directory` | yes | string | Absolute path to the working directory. The adapter invokes the tool in this directory. See "Validate working_directory" in the behavioral contract for validation requirements. |
| `model_tier` | yes | string (enum: `opus`, `sonnet`) | Quality-intent signal, not a model ID. The adapter resolves this to a provider-specific model ID via the routing config's `model-mapping` section. Uses the existing project vocabulary matching AGENT.md frontmatter convention. |
| `required_agent_tools` | yes | list of strings | Tool capabilities the AI agent needs during execution (e.g., `["Bash", "Read", "Edit"]`). Used for capability gating: the routing config loader (Issue 1.2) validates that the target harness supports these tools before routing. |
| `timeout_ms` | no | integer | Maximum wall-clock execution time in milliseconds. The adapter enforces this and terminates the tool process if exceeded. Default: 1800000 (30 minutes). |

### Semantics Notes

**`task_prompt` must not be modified by the adapter.** The adapter is permitted only the formatting adjustments strictly required by the target tool's invocation interface (e.g., writing the prompt to a temp file for `--message-file`). Any content rewriting is out of scope for adapters.

**`working_directory` validation is the adapter's responsibility.** See "Validate working_directory" in the behavioral contract for the full validation procedure.

**`model_tier` is a routing hint, not a constraint.** If the routing config has no `model-mapping` entry for a tier, the adapter should apply a sensible default for the target tool rather than failing. The mapping is resolved at adapter initialization, not per-request.

---

## DelegationResult

The adapter constructs a `DelegationResult` after the external tool exits (or is terminated). The orchestrator reads this to determine success, collect changed files, and incorporate the task summary into the plan.

### Example: Success

```yaml
# DelegationResult example: successful documentation update via Codex adapter
exit_code: 0
success: true
changed_files:
  - path: docs/adapter-interface.md
    action: modified
    lines_added: 12
    lines_removed: 8
  - path: docs/external-harness-roadmap.md
    action: modified
    lines_added: 4
    lines_removed: 4
task_summary: >
  Updated field names in docs/adapter-interface.md and docs/external-harness-roadmap.md
  to match the renamed fields confirmed during Codex adapter validation.
duration_ms: 47200
```

### Example: Failure

```yaml
# DelegationResult example: failure -- tool exited non-zero
exit_code: 1
success: false
changed_files: []
stderr: |
  Error: AGENTS.md references unknown tool capability 'WebSearch'
  Codex does not support WebSearch in headless mode.
  Aborting task to avoid partial execution.
  [last 3 lines of 31 lines captured]
duration_ms: 3100
```

### Field Table

| Field | Required | Type | Description |
|---|---|---|---|
| `exit_code` | yes | integer | Raw process exit code. 0 typically means success, but interpretation is adapter-specific. Preserved for debugging and diagnostics. |
| `success` | yes | boolean | Normalized success signal. The adapter sets this based on exit code and tool-specific semantics (e.g., Aider returning 1 for "no changes needed" may still be success). The orchestrator reads `success`, not `exit_code`, for routing decisions. See "Success Normalization Constraints" below. |
| `changed_files` | yes | list of FileChange (see below) | Files modified during execution, collected via `git diff --name-status --numstat` against a pre-invocation git ref. Empty list is valid (task may have made no file changes). |
| `task_summary` | yes (when `success` is true) | string | Human-readable summary of what the task accomplished (1-2 sentences). May come from parsed structured output (Codex `--output-schema`) or LLM-generated summarization (Aider via Issue 3.1). Describes the semantic outcome, not the mechanical changes. |
| `stderr` | no | string | Raw stderr output, truncated to the last 50 lines. Useful for diagnosing failures. |
| `raw_diff_path` | no | string | Absolute file path to the saved full unified diff. Written by the adapter for debugging. The orchestrator does not process this -- it exists for human inspection and the review gate. See "Create temporary files with restricted permissions" in the behavioral contract. |
| `duration_ms` | no | integer | Wall-clock execution time in milliseconds. Measured from tool invocation start to completion or timeout. |

### Semantics Notes

**`success` is the orchestrator's signal; `exit_code` is for diagnostics.** The orchestrator must not reinterpret `exit_code` independently. The adapter owns exit code semantics for its tool.

**`task_summary` is required on success.** If the tool does not produce structured output, the adapter must generate a summary (via Issue 3.1 for Aider, via `--output-schema` for Codex). An absent `task_summary` on a successful result is a contract violation.

**`changed_files` reflects git state, not tool claims.** Collect changed files via `git diff --name-status --numstat` against the pre-invocation HEAD ref, not from tool output. This ensures accuracy regardless of what the tool reports.

---

## FileChange

Sub-type used in `DelegationResult.changed_files`. Each entry represents one file that was modified during the tool invocation.

| Field | Required | Type | Description |
|---|---|---|---|
| `path` | yes | string | File path relative to `working_directory`. |
| `action` | yes | string (enum: `added`, `modified`, `deleted`, `renamed`) | What happened to this file. Sourced from `git diff --name-status`. |
| `lines_added` | yes | integer | Lines added. From `git diff --numstat`. 0 for deleted files. |
| `lines_removed` | yes | integer | Lines removed. From `git diff --numstat`. 0 for added files. |

For `renamed` files, `lines_added` and `lines_removed` reflect content changes after renaming. Both are 0 for a pure rename with no content change. Source: `git diff --numstat` output for `R`-status files.

---

## Adapter Behavioral Contract

This section defines what adapters must and must not do. It is a boundary specification, not a lifecycle guide. Step-by-step invocation choreography belongs to the adapter implementation issues (2.1 and 3.2).

### What Adapters Must Do

**Validate `working_directory`.** Canonicalize (resolve symlinks), then verify the resolved path falls within an allowlisted root (project repository root or an explicitly configured base path). Reject requests whose canonicalized path resolves outside the allowed root. This check must run at invocation time, not only at construction time.

**Use argument vector invocation.** Invoke external tools using argument vector APIs (`execv`-family, subprocess with list args, `child_process.execFile`) -- never via shell string interpolation of `task_prompt`. This prevents shell command injection (CWE-78) when the task prompt contains shell metacharacters.

**Clean up temporary files on both success and failure.** Use `trap` or an equivalent mechanism to ensure the translated instruction file is deleted regardless of exit path. Leaving instruction files on disk leaks system prompt content.

**Create temporary files with restricted permissions.** The translated instruction file and `raw_diff_path` must be created with mode 0600 (or equivalent) in a session-scoped subdirectory under a secure temp location. Do not create these files in `working_directory`.

**Enforce `timeout_ms`.** Terminate the tool process if the wall-clock limit is exceeded. Set `success: false` on timeout; collect whatever partial results are available.

**Source secrets from the host environment or a dedicated secret store.** Never read credentials from `DelegationRequest`. Never include credential values in any `DelegationResult` field.

### Error Handling

If the adapter itself cannot invoke the tool (binary not found, permission denied, `working_directory` not accessible), return a `DelegationResult` with `success: false`, `exit_code: -1`, and diagnostic information in `stderr`. Do not propagate an unhandled exception.

If timeout is triggered, terminate the tool process, return `success: false`, and include whatever `changed_files` and `stderr` are available at the point of termination.

Temporary files must be cleaned up even when the adapter returns an error result.

### Success Normalization Constraints

The following failure categories must always produce `success: false`, regardless of adapter-specific exit code normalization:

1. Tool process terminated by signal (exit code < 0 or process was signaled)
2. Tool binary not found or not executable
3. `working_directory` not accessible at invocation time
4. Timeout triggered

Normalizing a non-zero exit code to `success: true` is permitted only for exit codes that are documented as non-error conditions by the specific tool (e.g., Aider exit 1 = "no changes needed").

### What Adapters Must Not Do

- Modify `task_prompt` beyond formatting strictly required for tool invocation
- Pass `task_prompt` as an interpolated shell string; use argument vector invocation
- Make planning or routing decisions (the orchestrator's job)
- Commit to git unless the tool does so automatically (if a tool auto-commits, document this behavior but do not prevent it)
- Read or interpret approval gate metadata; the adapter is unaware of orchestration phases
- Include credential values in any `DelegationResult` field, especially `stderr` or `task_summary`
- Log or surface credential-bearing environment variables in diagnostic output

---

## Fields Considered and Excluded

These fields were proposed during synthesis and excluded from the interface. The rationale is recorded here so future contributors understand the decision without re-litigating it.

| Field | Proposed by | Excluded because |
|---|---|---|
| `auto_approve` | Prior synthesis | Always true for headless delegation. A field that is never false carries no information. |
| `context_files` | api-design-minion | Only Aider uses `--read` for reference files. Deferred to Milestone 3 when the Aider adapter validates the need. |
| `requires_rationale` | ai-modeling-minion | Couples the adapter to orchestration concepts (approval gates). The orchestrator can embed rationale instructions in the task prompt instead. |
| `rationale` | ai-modeling-minion | Not mechanically extractable. Depends on structured output or LLM inference. Can be part of result summarization (Issue 3.1) without being a typed field. |
| `adapter_error` | ai-modeling-minion | `success: false` with diagnostic `stderr` covers this case. The orchestrator does not yet distinguish infrastructure failure from task failure in its error handling. |
| `environment` | Prior synthesis | Passes environment variables to subprocess. Security concern: API keys would appear in delegation requests, violating the constraint that adapters source their own secrets. |
| `status` enum | api-design-minion | Three-value enum (`completed`/`failed`/`timeout`) does not add information beyond `success` boolean + `exit_code`. Timeout is distinguishable by context if needed. |
| `token_usage` | N/A | Out of scope per roadmap (M7 at earliest). |

This list captures decisions from the initial design. Future field proposals should be evaluated against current needs, not against this list.

---

## Stability Note

This interface is expected to evolve based on Codex (Milestone 2) and Aider (Milestone 3) validation. Issue 3.4 explicitly includes an interface health check. Fields may be added (non-breaking) or adjusted (documented as breaking) based on adapter implementation experience.
