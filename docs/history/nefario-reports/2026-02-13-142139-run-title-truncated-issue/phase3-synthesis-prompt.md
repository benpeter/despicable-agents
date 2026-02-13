MODE: SYNTHESIS
ADVISORY: true

You are synthesizing an advisory report. This is an advisory-only orchestration -- no code will be written, no branches created, no PRs opened.

## Original Task
The fix to #83 (PR #96, commit 394e4dc) added `\n\nRun: $summary` to all AskUserQuestion gates in SKILL.md. The `$summary` value is established in Phase 1 and is capped at 40 characters (designed for the status line). This means the run title shown in gates is also truncated to 40 chars.

Question: Is the truncation necessary in the gate context? Gates have more space than the status line. Should we keep a full-length summary for use in gates while keeping the truncated version for the status line?

Action: Create a GitHub issue for this (low priority). If priority labels aren't available, create a "nice-to-have" label.

## Investigation Findings

### Root Cause
In SKILL.md Phase 1 (line ~389-391):
```
Extract a status summary from the first line of the user's task description.
Truncate to 40 characters; if truncated, append "..."
```

This `$summary` variable is defined once with a 40-char cap. The cap was designed for the status line sentinel file, where the total line budget is ~64 chars (`⚗︎ P1 Meta-Plan | ` prefix + 40 char summary + `...`).

### The #83 Fix
PR #96 added `\n\nRun: $summary` to all AskUserQuestion `question` fields. It reuses the same 40-char-capped `$summary`. Gates display in a dialog/prompt UI that has substantially more horizontal and vertical space than the status line.

### Answer to User's Question
Yes, the run title is truncated because `$summary` is only available truncated. There is a single variable, defined once with a 40-char cap, reused everywhere. The truncation is appropriate for the status line but unnecessary for gates.

### Proposed Fix
Introduce a second variable (e.g., `$summary_full`) that retains the complete first line of the task description (or a reasonable longer cap, e.g., 120 chars). Use `$summary_full` in gate `question` fields. Keep `$summary` (40-char) for the status line.

Alternatively, increase `$summary` to a higher cap that works for both contexts, though this may make the status line too long.

## Instructions
1. Produce an advisory report with executive summary, team consensus, recommendations, and next steps
2. Write your complete advisory synthesis to /var/folders/3k/bfjvvz9s6dvdn_hvlhvr8lc00000gn/T//nefario-scratch-DohQin/run-title-truncated-issue/phase3-synthesis.md
