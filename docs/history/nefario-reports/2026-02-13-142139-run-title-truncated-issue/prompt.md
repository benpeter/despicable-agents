The fix to #83 (PR #96, commit 394e4dc) added `\n\nRun: $summary` to all AskUserQuestion gates in SKILL.md. The `$summary` value is established in Phase 1 and is capped at 40 characters (designed for the status line). This means the run title shown in gates is also truncated to 40 chars.

Question: Is the truncation necessary in the gate context? Gates have more space than the status line. Should we keep a full-length summary for use in gates while keeping the truncated version for the status line?

Action: Create a GitHub issue for this (low priority). If priority labels aren't available, create a "nice-to-have" label.
