## Domain Plan Contribution: ux-strategy-minion

### Recommendations

#### 1. Use `$summary` (natural language), not `slug`

The identifier must answer one question: "Which orchestration is asking me this?" The user is context-switching between terminals running parallel nefario sessions. They need instant recognition, not decoding.

- **`$summary`** (e.g., "Gate titles include orchestration run") is natural language. Recognition is immediate -- the user reads it and knows which task they are deciding on. This maps directly to Nielsen's "match the real world" heuristic.
- **`slug`** (e.g., `gates-include-orchestration-title`) is system-internal encoding. It requires mental translation: kebab-case to meaning, abbreviations to concepts. This violates "recognition over recall" -- the user must recall which slug maps to which task.
- The status line already uses `$summary`. Using the same identifier in gates creates consistency across the orchestration. Switching to `slug` at decision points breaks the mapping the user has already built.

**Exception**: The PR gate already uses `slug` because the slug IS the decision context there (it is the branch name). That is correct -- the slug is the natural identifier in that context.

#### 2. Prefix the `question` field, do not replace content

The `question` field currently carries gate-specific context (task summaries, finding descriptions, decision text). This content is essential for the decision at hand. The run title should frame the question, not compete with it.

**Pattern**: Prefix the `question` with the run title, separated by a delimiter that creates visual hierarchy.

```
"$summary -- <existing question content>"
```

The double-dash creates a lightweight visual break. The user scans left-to-right: first the run identifier (which session?), then the gate-specific content (what decision?). This respects Krug's scanning behavior -- users don't read, they scan, and the leftmost content is scanned first.

**Why prefix, not suffix**: In a parallel-session scenario, the first thing the user needs to establish is WHICH run they are looking at. That is the orientation question. Once oriented, they evaluate the decision. Prefix puts orientation first. Suffix forces the user to read the entire question to find out which run it belongs to.

#### 3. Gate-by-gate analysis and information hierarchy

I have categorized each gate by how much additional context it needs and what the `question` field should become.

**Gates that already have partial run context (task summary in question):**

| Gate | Current question | Proposed question | Change rationale |
|------|-----------------|-------------------|------------------|
| P1 Team | `<1-sentence task summary>` | `$summary` | The task summary IS the run title at this point. Just ensure it uses the canonical `$summary` variable, not a re-derived summary. No prefix needed -- the content already identifies the run. |
| P3.5 Review | `<1-sentence plan summary>` | `$summary` | Same as P1. The plan summary should match `$summary` for consistency. |
| P3.5 Plan | `<orientation line goal summary>` | `$summary -- <goal summary detail if different>` | If the goal summary differs from `$summary`, prefix with `$summary`. If identical, just use `$summary`. |

**Gates that carry decision-specific content and need run context added:**

| Gate | Current question | Proposed question |
|------|-----------------|-------------------|
| P4 Gate | `Task N: <task title> -- DECISION` | `$summary -- Task N: <task title> -- DECISION` |
| Post-exec | `Post-execution phases for this task?` | `$summary -- Task N: <task title>` |
| P4 Calibrate | `5 consecutive approvals without changes. Gates well-calibrated?` | `$summary -- 5 consecutive approvals. Gates well-calibrated?` |
| P3 Impasse | disagreement description | `$summary -- <disagreement description>` |
| PR | `Create PR for nefario/<slug>?` | `$summary -- Create PR?` |
| Existing PR | `PR #N exists on this branch. Update its description...` | `$summary -- Update PR #N description?` |

**Gates with finding-specific content (P5):**

| Gate | Current question | Proposed question |
|------|-----------------|-------------------|
| P5 Security | the one-sentence finding description | `$summary -- <finding description>` |
| P5 Issue | the one-sentence finding description | `$summary -- <finding description>` |

#### 4. The Post-exec gate: worst offender, needs the most work

The current Post-exec gate question is `"Post-execution phases for this task?"` -- this has zero context about WHICH run or WHICH task. In a parallel session, the user literally cannot tell what they are deciding on.

The fix requires both run-level AND task-level context:

```
question: "$summary -- Task N: <task title>"
```

This gives the user: (1) which orchestration run, (2) which specific task within that run. The post-exec gate follows immediately after a P4 Gate approval for the same task, so the task title provides continuity -- the user just approved this task and now decides on its post-execution treatment.

The question does NOT need to repeat "Post-execution phases?" because the options themselves ("Run all", "Skip docs", etc.) make the decision type self-evident. The question's job is identification, not instruction. This follows the principle of minimizing cognitive load -- the options explain the choice, the question identifies the context.

#### 5. P5 gates: layering run context with findings

For P5 Security and P5 Issue gates, the finding description is the critical decision content. The user needs to evaluate a specific security issue or code review finding. The run title is orientation context, not the decision itself.

The prefix pattern works well here because there is always a structured decision card displayed ABOVE the AskUserQuestion (the `SECURITY FINDING` or `VERIFICATION ISSUE` brief). That card already contains detailed finding context. The `question` field serves as a compact summary line, not the primary information source.

So: `"$summary -- <finding description>"` gives the user orientation (which run) plus a reminder of the finding (which issue) in a single line. The detailed card above provides the full context for the actual decision.

The run title does NOT compete with the finding because they serve different cognitive functions: orientation vs. evaluation.

#### 6. Truncation strategy for long combined strings

`$summary` is up to 40 characters. Some existing `question` content can be long (P4 Gate includes task title + decision text). Combined strings could exceed comfortable scanning length.

**Rule**: If the combined `question` string exceeds 80 characters, truncate the gate-specific content (not `$summary`). The run identifier is always preserved in full. Gate-specific content can be truncated with "..." because the structured card above the question provides the complete details.

This respects the information hierarchy: orientation (full) > decision summary (truncated if needed) > decision detail (in the card above).

#### 7. Do NOT change the `header` field

The `header` field is constrained to 12 characters and serves a different function: phase identification. It tells the user WHERE they are in the workflow (P1, P3.5, P4, P5). Adding run context to `header` would either exceed the character limit or sacrifice phase identification. Both are bad trade-offs. Leave `header` as-is.

### Proposed Tasks

**Task 1: Update gate question specifications in SKILL.md**

- What: Modify each AskUserQuestion specification to include `$summary` prefix in the `question` field, following the gate-by-gate analysis above.
- Deliverables: Updated SKILL.md with new `question` field definitions for all 11 gates.
- Dependencies: None. This is the core specification change.
- Notes:
  - P1 Team and P3.5 Review: ensure they use the canonical `$summary` variable rather than re-deriving a summary.
  - Post-exec: add both `$summary` and task-level context (`Task N: <task title>`).
  - PR and Existing PR: simplify the gate-specific content since `$summary` now provides the task context that `slug` was partially providing.
  - P4 Calibrate: shorten the existing verbose question to stay within 80-char guidance.
  - All gates: apply the truncation rule (80 chars combined, truncate gate content not `$summary`).

**Task 2: Add truncation rule to the AskUserQuestion conventions section**

- What: Add a guideline near the existing `header` max-12-char rule specifying that `question` fields should prefix `$summary` for run identification, with an 80-character soft limit and truncation guidance.
- Deliverables: A small addition to the SKILL.md conventions section.
- Dependencies: Task 1 (the pattern should be established before the rule is documented).

### Risks and Concerns

1. **Question field length in the Claude Code UI**: The AskUserQuestion `question` field renders in the Claude Code terminal. If the terminal is narrow, long question strings will wrap awkwardly. The 80-character guideline mitigates this, but the actual rendering behavior should be verified. If the question wraps mid-`$summary`, the orientation benefit is lost.

2. **Redundancy with the structured card**: Several gates display a structured decision card (the bordered block with `TEAM:`, `APPROVAL GATE:`, `SECURITY FINDING:`, etc.) immediately above the AskUserQuestion. These cards already contain task context. Adding `$summary` to the `question` field creates some redundancy -- but this is intentional and correct. The card may scroll off-screen in a busy terminal, but the `question` field is always visible at the decision prompt. Redundancy here serves resilience, not waste.

3. **P1 Team gate timing**: At P1, `$summary` has just been derived. The user may not yet have a mental association with it. This is not a problem because the P1 gate IS where the user first encounters the summary -- it becomes the anchor. But it means the P1 gate's question should match `$summary` exactly, not paraphrase it, so the user builds the right mental model from the start.

4. **Inconsistency risk if `$summary` changes**: If `$summary` could be modified mid-session (e.g., after a team adjustment), gates before and after the change would show different identifiers. The current spec appears to fix `$summary` at Phase 1. Confirm this is enforced. If it can change, the orientation benefit breaks down.

### Additional Agents Needed

None. The task is a specification change to SKILL.md. The devx-minion (if included) can handle the implementation mechanics. No additional domain expertise is needed beyond what the current team provides.
