# Lucy Review: Status Line Task Summary in Nefario SKILL.md

## Original Request (verbatim)
"Show task summary in status line during nefario execution"

## Requirements Extracted
1. Task summary visible in status line
2. During nefario execution (lifecycle: created at start, removed at end)

## Traceability

| Requirement | Plan Element | Status |
|---|---|---|
| Task summary in status line | Sentinel file `/tmp/nefario-status-${slug}` (lines 140-146) | COVERED |
| Visible during execution | Created Phase 1 (line 144), cleaned up wrap-up step 11 (line 981) | COVERED |
| Summary in Task descriptions | `description` field prefix "Nefario: ..." (lines 167, 208, 267, 351, 764) | COVERED |
| Summary in activeForm | `activeForm` instruction at Phase 4 Setup (lines 586-588) | COVERED |

## CLAUDE.md Compliance

- English: All additions are in English. PASS.
- YAGNI: Inline comment only, no documentation section. PASS.
- KISS: Sentinel file pattern mirrors the existing commit marker pattern (`/tmp/claude-commit-orchestrated-${CLAUDE_SESSION_ID}`). Creation at start, cleanup at end. Simple and consistent. PASS.
- No PII/secrets: File contains only a task summary string. PASS.

## Drift Analysis

- **Scope creep**: None detected. The five change points (summary extraction, sentinel write, description prefixes, activeForm instruction, sentinel cleanup) are the minimal set needed to surface the summary.
- **Over-engineering**: No. The sentinel file pattern is the simplest possible IPC mechanism for an external status line script to read. It follows the existing `/tmp/claude-commit-orchestrated-*` marker convention.
- **Gold-plating**: No documentation section was added -- the inline comment is the only explanation. Consistent with YAGNI.
- **Feature substitution**: None. The feature delivered matches the feature requested.

## Findings

- [ADVISE] `skills/nefario/SKILL.md`:599 -- The Phase 4 execution loop task spawn template (line 599 `description: <short summary>`) does not show the "Nefario: <summary>" prefix pattern. Lines 147-148 say to use the summary in Task `description` fields "throughout the orchestration," but the execution loop spawn template at line 599 still says just `<short summary>`. The pre-execution phases (lines 167, 208, 267, 351) and Phase 5 (line 764) all use the `"Nefario: ..."` prefix. This is a consistency gap -- the execution loop template is arguably the most important one for the user to see the summary in their status line during the longest phase.
  AGENT: devx-minion
  FIX: Change line 599 from `description: <short summary>` to `description: "Nefario: <summary> -- <short task summary>"` (or a similar pattern matching the activeForm instruction at line 586). Alternatively, add an inline note at line 599 clarifying that `<short summary>` should follow the "Nefario: <summary>" prefix convention established at lines 147-148.

- [NIT] `skills/nefario/SKILL.md`:141 -- The truncation rule says "Truncate to 51 characters; if truncated, append '...'" and the parenthetical explains the math ("Nefario: " prefix + summary stays within 60 chars). "Nefario: " is 9 characters + 51 = 60. But with "..." appended on truncation, the total would be 9 + 51 + 3 = 63. The 60-char budget only works if the 51 includes the "..." when truncated, which is not what the text says. Clarify: truncate to 48 characters and append "..." (48 + 3 = 51 content chars + 9 prefix = 60), or state the 51-char limit includes the ellipsis.
  AGENT: devx-minion
  FIX: Change to "Truncate to 48 characters and append '...' (so 'Nefario: ' prefix + 51 chars of summary stays within 60 chars)" or explicitly state "Truncate to 51 characters including the '...' suffix."

## Verdict

VERDICT: ADVISE

Two minor issues found. The ADVISE finding (execution loop description consistency) is a real gap that could cause the summary to not appear in the status line during Phase 4 execution -- the phase where it matters most. The NIT is a math clarification. Neither blocks the change; both can be addressed in a follow-up commit.
