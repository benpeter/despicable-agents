## Domain Plan Contribution: ai-modeling-minion

### Recommendations

#### (a) What fields does the orchestrator need from `DelegationResult` to make routing and gating decisions?

After reading the Phase 4 execution loop in detail (SKILL.md lines 1577-1818), the orchestrator extracts exactly five categories of information from completed tasks. The `DelegationResult` must provide equivalents for each:

1. **Completion status (binary: success/failure).** The orchestrator uses TaskList to poll for task completion. It needs to know whether the task completed at all. An exit code (0 vs non-zero) is the correct abstraction -- simpler and more reliable than the current TaskList polling.

2. **Changed files with scope and line counts.** The SendMessage completion instruction (SKILL.md line 1647) asks agents to report "File paths with change scope and line counts (e.g., `src/auth.ts (new OAuth flow, +142 lines)`)". This populates the DELIVERABLE section of approval gates (line 1682-1684). The field should be a structured list, not freeform text: `{path, scope_description, lines_added, lines_removed}`. Git diff can provide path/lines mechanically; scope description requires either structured output from the harness or LLM-based summarization.

3. **Summary of what was produced (1-2 sentences).** Populates the `Summary:` line in the DELIVERABLE section and feeds into Phase 5-8 context. This is semantic, not mechanical -- it requires understanding the task prompt and what the diff accomplished.

4. **Rationale for approach decisions (for gated tasks only).** The SendMessage instruction (line 1649-1652) asks agents to report "the approach you chose, what alternative(s) you considered but rejected, and a brief reason for each rejection." This populates the RATIONALE section of approval gate briefs (line 1686-1689). This field is conditional -- only needed when the task has an approval gate. The orchestrator falls back to pre-execution gate rationale from synthesis if the agent does not report rationale (line 1720-1722), so this field can be optional.

5. **Duration / timing metadata.** Not currently collected from subagents, but external harnesses should capture wall-clock duration for operational visibility. The orchestrator does not use this for routing decisions today, but the report generation (SKILL.md line 2327-2331) tracks per-task outcomes, and duration is natural metadata. Include as optional.

**Recommended `DelegationResult` fields:**

| Field | Type | Required | Source |
|-------|------|----------|--------|
| `exit_code` | integer | yes | Process exit code |
| `changed_files` | `{path, lines_added, lines_removed}[]` | yes | `git diff --numstat` |
| `summary` | string | yes (for success) | Structured output (Codex) or LLM summarization (Aider) |
| `rationale` | string | no | Structured output (Codex) or LLM summarization (Aider) |
| `stderr` | string | no | Process stderr (truncated, last N lines) |
| `raw_diff` | string or file path | no | Reference to full unified diff |
| `duration_ms` | integer | no | Wall-clock execution time |
| `stdout` | string or file path | no | Raw stdout reference for debugging |

**Fields the orchestrator does NOT need:**

- Token usage or cost data (out of scope per roadmap -- M7 at earliest)
- Model used (the routing config already knows this)
- Intermediate progress events (consumed during execution for status display, not stored in the result)
- Tool call traces (internal to the harness)

#### (b) Does the orchestrator need to distinguish "task completed with wrong output" vs "adapter crashed"?

Yes, but with a pragmatic two-level distinction, not a rich error taxonomy.

The orchestrator's current error handling is thin (AGENT.md line 171): "Detection via TaskList polling and idle detection. No timeout, no structured error categories, no retry protocol." The external harness abstraction should improve on this minimally, not over-engineer it.

**Recommended status model -- three states:**

| Status | Meaning | Orchestrator action |
|--------|---------|-------------------|
| `success` | Exit code 0, output collected | Process result normally (gate, next batch, post-execution) |
| `failure` | Exit code non-zero, harness ran but task failed | Route to producing agent for fix (up to 2 rounds, matching Phase 5 cap). Log stderr for diagnostics. |
| `error` | Adapter itself crashed, timeout, or harness not found | Do NOT retry automatically. Surface to orchestrator with diagnostic info. The orchestrator presents this to the user as a blocked task. |

**Why not more granular?** The roadmap explicitly defers retry logic and structured error categories to M8 (Hardening). Designing a rich error taxonomy now violates YAGNI. The `failure` vs `error` distinction is the minimum needed for the orchestrator to decide "try to fix this" vs "this is an infrastructure problem."

**Implementation:** `exit_code` is the primary signal. `exit_code == 0` means success. `exit_code > 0` means failure (the harness ran, the task did not succeed). A special sentinel (e.g., `exit_code == -1` or a separate `adapter_error: true` boolean) indicates the adapter itself failed. I recommend a boolean `adapter_error` field rather than overloading exit codes, since external processes may use various non-zero codes that should all be treated as task failure.

#### (c) Should the prompt include metadata about phase/gate context?

**No.** The prompt should be the task prompt only -- no phase/gate metadata embedded in it.

The reasoning:

1. **The orchestrator already strips Claude Code-specific instructions** before passing to external harnesses (roadmap Issue 1.3). Phase/gate metadata is orchestrator-internal context that belongs in the same category.

2. **The external harness does not need to know it is part of a multi-phase orchestration.** It receives a self-contained task prompt, executes it, and returns a result. The orchestrator handles all phase/gate logic.

3. **Gate rationale is better collected via structured output or post-hoc summarization** than by asking the harness to understand orchestration concepts like "approval gates." The SendMessage instruction that asks for rationale (SKILL.md line 1649-1652) is a Claude Code-specific convention. For external harnesses, the equivalent is either:
   - Codex: use `--output-schema` to request a structured response that includes rationale fields
   - Aider: the LLM-based diff summarization service (Issue 3.1) can extract rationale from the diff + task prompt

4. **However, the `DelegationRequest` should carry gate metadata as a flag**, not embedded in the prompt. This tells the adapter "the orchestrator wants rationale for this task" without coupling the task prompt to orchestration concepts. The adapter can then decide how to collect rationale (structured output schema, post-hoc summarization, or not at all for harnesses that cannot provide it).

**Recommended approach:**

```
DelegationRequest:
  prompt: <pure task prompt, no orchestration metadata>
  requires_rationale: boolean  # true for gated tasks
```

The adapter uses `requires_rationale` to adjust its collection strategy (e.g., add rationale fields to `--output-schema` for Codex, add rationale extraction to the LLM summarization prompt for Aider).

#### (d) Information currently extracted from TaskUpdate/SendMessage that would be lost

After reading the Phase 4 execution loop carefully, the orchestrator extracts the following from TaskUpdate/SendMessage that could be lost if not captured in `DelegationResult`:

1. **Task completion signal (TaskUpdate).** Replaced by process exit. This is a clean improvement -- process exit is an unambiguous completion signal, more reliable than polling.

2. **File paths with scope and line counts (SendMessage).** Partially replaceable by `git diff --numstat` (paths and line counts). **The scope description ("new OAuth flow", "refactored error handling") is the part that would be lost** without structured output or LLM summarization. `git diff` gives you mechanical data; the semantic description of what changed requires understanding.

3. **1-2 sentence summary (SendMessage).** Would be lost entirely without structured output or LLM summarization. This is critical for gate briefs and post-execution reports.

4. **Approach rationale and rejected alternatives (SendMessage, for gated tasks).** Would be lost entirely. For Codex, recoverable via `--output-schema`. For Aider, recoverable via LLM summarization with explicit prompt engineering: "Given this task prompt and this diff, what approach was taken and what alternatives could have been considered?"

5. **Intermediate progress messages (SendMessage during execution).** The orchestrator uses these for heartbeat monitoring (SKILL.md line 206-207). For external harnesses: Codex provides JSONL streaming (usable for progress); Aider provides no progress stream. **This is an acceptable loss** -- the roadmap (Issue 4.2) already accepts that Aider is opaque until completion.

**Risk: LLM summarization quality for rationale.** Asking a small fast model to infer *rejected alternatives* from a diff is qualitatively harder than summarizing what changed. The diff shows what was done, not what was considered. For gated tasks routed to harnesses without structured output, rationale quality will be lower than what Claude Code subagents provide via SendMessage. This is an accepted tradeoff per the roadmap, but should be documented as a known limitation.

### Proposed Tasks

**Task 1: Define `DelegationRequest` type**

- What: Define the type with fields: `agent_name`, `prompt` (stripped of Claude Code instructions), `instruction_file_path`, `working_directory`, `model_tier` (enum: opus/sonnet), `required_tools` (string list), `requires_rationale` (boolean), `timeout_ms` (optional integer).
- Deliverable: Type definition in the project's chosen format (TypeScript interface, JSON Schema, or documented Markdown -- match codebase convention).
- Dependencies: None.

**Task 2: Define `DelegationResult` type**

- What: Define the type with fields: `exit_code` (integer), `adapter_error` (boolean), `changed_files` (list of `{path, lines_added, lines_removed}`), `summary` (string, required when exit_code == 0), `rationale` (optional string), `stderr` (optional string, last 50 lines), `raw_diff_path` (optional file path), `duration_ms` (optional integer), `stdout_path` (optional file path).
- Deliverable: Type definition matching Task 1 format.
- Dependencies: None (can be done in parallel with Task 1).

**Task 3: Document the mapping from current SendMessage/TaskUpdate signals to DelegationResult fields**

- What: Create a translation table showing how each piece of information the orchestrator currently extracts from TaskUpdate/SendMessage maps to the corresponding `DelegationResult` field, which fields can be populated mechanically (git diff), which require LLM summarization, and which degrade gracefully (rationale for non-gated tasks).
- Deliverable: Section in the type definition document.
- Dependencies: Tasks 1-2.

**Task 4: Define the adapter interface contract**

- What: Specify what an adapter must implement: a function that takes a `DelegationRequest` and returns a `DelegationResult`. Document pre-conditions (instruction file already written, working directory exists), post-conditions (temporary files cleaned up, git state is the delta), and error handling (adapter_error vs task failure). Include the `requires_rationale` behavior contract.
- Deliverable: Interface specification document.
- Dependencies: Tasks 1-2.

### Risks and Concerns

1. **Rationale quality degradation for external harnesses.** The orchestrator's approval gate briefs depend on agent-reported rationale (approach chosen, alternatives rejected). Claude Code subagents report this naturally via SendMessage. External harnesses can only provide this via structured output (Codex) or post-hoc LLM inference (Aider). Post-hoc inference from diffs cannot reliably determine what alternatives were *considered but not implemented*. This means gated tasks routed to Aider will have weaker gate briefs.

   *Mitigation:* Document as a known limitation. For high-stakes gated tasks, the routing config should favor harnesses with structured output or Claude Code. The `requires_rationale` flag lets the adapter know to try harder, but cannot guarantee quality.

2. **Scope description in changed_files.** The orchestrator's gate briefs show scope descriptions like "new OAuth flow" next to file paths. `git diff --numstat` provides path and line counts but not semantic scope. Without structured output or summarization, gates will show file paths and line counts only -- functional but less informative.

   *Mitigation:* The Result Summarization Service (Issue 3.1) can be extended to produce per-file scope descriptions, not just an overall summary. This adds ~200 tokens per file to the summarization prompt. Include this as a design consideration for Issue 3.1.

3. **Type format decision.** The roadmap says "Language/format matches the surrounding codebase (document the decision; do not assume)." The codebase is currently Markdown-based agent definitions with YAML frontmatter and shell scripts. There is no established programming language for the adapter layer. This decision blocks the exact syntax of the type definitions.

   *Mitigation:* Define types first as documented Markdown (human-readable specification), then translate to the chosen implementation language when the adapter implementation begins (Issue 2.1). The Markdown spec is the source of truth; the code is derived.

4. **`adapter_error` vs `exit_code` semantics.** Different external tools use different exit code conventions. Some tools return non-zero for "completed with warnings" or "partial success." The adapter must normalize these to the three-state model (success/failure/error). This normalization is per-adapter knowledge, not type-level knowledge.

   *Mitigation:* Document that exit code interpretation is adapter-specific. The type definition specifies the semantic contract; each adapter documents its exit code mapping.

### Additional Agents Needed

None. The current team is sufficient for type definition. The types are an API design task with orchestration context, not a frontend, security, or infrastructure concern. The downstream consumers (Codex adapter, Aider adapter, routing config, result summarization) will validate the types during their own implementation phases (Milestones 2-4).
