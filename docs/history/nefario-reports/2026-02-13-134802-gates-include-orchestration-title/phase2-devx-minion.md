# Domain Plan Contribution: devx-minion

## Recommendations

### Convention: Suffix line with `$summary` as a visual anchor

The run title goes on a **dedicated trailing line** of the `question` field, separated by a newline, formatted as a muted label:

```
Run: $summary
```

This is a **suffix line**, not an inline prefix or bracket. The rationale:

1. **Prefix brackets destroy scannability.** A prefix like `[fix gate titles] Task N: ...` front-loads the same 40 characters on every gate, pushing the actual decision content to the right. In a multi-gate session, the user's eye has to skip past the same prefix every time. This is the worst outcome for the "anomaly detection" scanning pattern the plan approval gate already optimizes for.

2. **Inline suffixes bloat already-long questions.** The P4 Gate question is `Task N: <task title> -- DECISION` which is already multi-part. Appending ` | fix gate titles...` creates a single unbreathable line.

3. **A trailing line is always the same shape.** It becomes a consistent, predictable footer that the user learns to glance at once and ignore when they are in single-session mode. In multi-session mode, it is always in the same position -- bottom of the question -- so the eye knows exactly where to look.

4. **The `header` field stays untouched.** At 12 characters max, there is no room for run context. The `header` already carries the phase prefix (`P4 Gate`, `P5 Issue`, etc.) which is the right use of that field -- it tells you WHAT KIND of decision, while the trailing line tells you WHICH RUN.

### Use `$summary`, not `slug`

- `$summary` is the human-readable task description fragment (e.g., "Include run title in all gates"). It reads naturally.
- `slug` is the kebab-case machine identifier (e.g., `gates-include-orchestration-title`). It reads like a URL.
- The status line already uses `$summary`. Consistency means the user sees the same identifier in the status line and in the gate question. No translation needed.
- The `$summary` is already capped at 40 characters, so it will not blow out the question width.

### Format specification

The `question` field for every gate becomes:

```
<existing question content>

Run: $summary
```

Where:
- The existing question content is preserved exactly as-is (no rewriting of existing questions).
- A blank line separates the question from the run context line.
- `Run:` is the label. Short, unambiguous, grep-friendly.
- `$summary` is the same variable already used in the status line (40-char max, established in Phase 1, preserved across compaction).

### Post-exec gate: add task-level context too

The post-exec gate is the worst offender because it has zero referent. Apply the convention AND fix the question content:

**Before:**
```
question: "Post-execution phases for this task?"
```

**After:**
```
question: "Post-execution phases for Task N: <task title>?\n\nRun: $summary"
```

This gives the post-exec gate both task-level identity (which task was just approved) and run-level identity (which orchestration session). The task reference is critical because post-exec immediately follows a P4 Gate approval -- the user needs to know which task's post-execution they are configuring.

### Calibration gate: add run context

The calibration gate ("5 consecutive approvals without changes. Gates well-calibrated?") is currently context-free. Apply the standard convention:

**Before:**
```
question: "5 consecutive approvals without changes. Gates well-calibrated?"
```

**After:**
```
question: "5 consecutive approvals without changes. Gates well-calibrated?\n\nRun: $summary"
```

### Gates with "partial" context: still apply the convention

Gates like P1 Team, P3.5 Review, and P3.5 Plan already include a task/plan summary in the question. But that summary is gate-specific content (what you are deciding on), not a run identifier. Adding the `Run:` line is not redundant -- it explicitly marks the orchestration context. In single-session mode the duplication is harmless (same line, easy to ignore). In multi-session mode it is the anchor the user needs.

### Before/After for all 12 gates

| Gate | header (unchanged) | Current `question` | Proposed `question` |
|------|-------------------|--------------------|---------------------|
| P1 Team | "P1 Team" | `<1-sentence task summary>` | `<1-sentence task summary>\n\nRun: $summary` |
| P3.5 Review | "P3.5 Review" | `<1-sentence plan summary>` | `<1-sentence plan summary>\n\nRun: $summary` |
| P3 Impasse | "P3 Impasse" | `<disagreement description>` | `<disagreement description>\n\nRun: $summary` |
| P3.5 Plan | "P3.5 Plan" | `<orientation line goal summary>` | `<orientation line goal summary>\n\nRun: $summary` |
| P4 Gate | "P4 Gate" | `Task N: <task title> -- DECISION` | `Task N: <task title> -- DECISION\n\nRun: $summary` |
| Post-exec | "Post-exec" | `Post-execution phases for this task?` | `Post-execution phases for Task N: <task title>?\n\nRun: $summary` |
| P4 Calibrate | "P4 Calibrate" | `5 consecutive approvals without changes. Gates well-calibrated?` | `5 consecutive approvals without changes. Gates well-calibrated?\n\nRun: $summary` |
| P5 Security | "P5 Security" | `<finding description>` | `<finding description>\n\nRun: $summary` |
| P5 Issue | "P5 Issue" | `<finding description from brief>` | `<finding description from brief>\n\nRun: $summary` |
| PR | "PR" | `Create PR for nefario/<slug>?` | `Create PR for nefario/<slug>?\n\nRun: $summary` |
| Existing PR | "Existing PR" | `PR #N exists on this branch. Update its description with this run's changes?` | `PR #N exists on this branch. Update its description with this run's changes?\n\nRun: $summary` |
| Confirm (reject) | "Confirm" | `Reject <task title>?\n\n<dependent tasks>\n\nAlternative: ...` | `Reject <task title>?\n\n<dependent tasks>\n\nAlternative: ...\n\nRun: $summary` |

Note: The Confirm gate (the secondary reject-confirmation gate inside P4 Gate) is the 12th gate. The issue audit lists 11 but the meta-plan mentions 12 -- the Confirm gate should also get the run context since it is a separate AskUserQuestion.

### Why not `\n\nRun: $summary` as a SKILL.md template variable?

Tempting to define a `$run_line` variable to DRY the 12 instances. But SKILL.md does not have a template engine -- it is a specification document read by the LLM. Adding a "variable" would just be a "replace this marker" instruction that adds complexity. The 12 instances are better as explicit specifications, each showing exactly what the LLM should produce. Repetition in specifications is clarity, not waste.

## Proposed Tasks

### Task 1: Add `Run:` line convention and update all 12 gates

**What to do:** Edit `skills/nefario/SKILL.md` to:
1. Add a convention definition near the AskUserQuestion header-cap note (around line 503) explaining the `Run: $summary` trailing line convention.
2. Update each of the 12 AskUserQuestion `question` field specifications to include `\n\nRun: $summary` as a trailing line.
3. For the post-exec gate specifically, also change the question content from `"Post-execution phases for this task?"` to `"Post-execution phases for Task N: <task title>?"` (adding the task-level referent).

**Deliverables:**
- Updated `skills/nefario/SKILL.md` with all 12 gates modified
- Convention definition added as a note/rule near existing AskUserQuestion constraints

**Dependencies:** None. This is a single-file edit.

**Estimated scope:** 12 localized edits in one file + 1 convention definition paragraph. Low risk, high consistency.

## Risks and Concerns

1. **Newline rendering in AskUserQuestion.** The convention assumes `\n\n` in the `question` field renders as a blank line in the terminal prompt. If AskUserQuestion collapses whitespace or does not support multiline `question` fields, the `Run:` line would merge into the question text and look messy. **Mitigation:** The P4 Gate reject-confirmation question already uses multiline formatting (the dependent tasks list), so AskUserQuestion appears to support it. The ai-modeling-minion specialist (who understands Claude Code tool behavior) should confirm this.

2. **Near-duplication in P1 Team and P3.5 gates.** The P1 Team question is already `<1-sentence task summary>` and `$summary` is derived from the same source. In some cases the question and the `Run:` line will show nearly identical text. **Mitigation:** This is acceptable. The `Run:` label is a consistent visual anchor that the user learns to look for. Even if the content is similar, the label provides certainty ("this is the run identifier") rather than ambiguity ("is this the run title or the gate-specific description?"). Consistency across all 12 gates matters more than eliminating cosmetic overlap in 2-3 of them.

3. **Question length for already-long gates.** The Existing PR gate question is already 78 characters. Adding `\n\nRun: $summary` adds up to 46 more characters (but on a separate line, so it does not affect the primary line's readability). The only risk is if the total `question` field has an undocumented length limit. **Mitigation:** No length limit is documented, and the Confirm gate already uses multi-paragraph content. Low risk.

## Additional Agents Needed

None. The current team (devx-minion + ux-strategy-minion) plus the ai-modeling-minion already included covers the judgment calls. The ai-modeling-minion can confirm the multiline `question` rendering assumption (Risk 1 above). No additional specialists needed for a specification-only change.
