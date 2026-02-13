You are updating `skills/nefario/SKILL.md` to add phase context to the
status line and AskUserQuestion gate headers. This closes an orientation
gap where users lose "where am I?" awareness during nefario orchestration.

## Context

The nefario orchestration skill has a status file mechanism
(`/tmp/nefario-status-$SID`) that shows task context in the Claude Code
status line. Currently the file is written ONCE at orchestration start
(Phase 1, lines 362-368) and never updated. AskUserQuestion gates use
generic single-word headers ("Team", "Gate", "Plan") with no phase context.

The status line is hidden during AskUserQuestion prompts, and the gate
headers have no phase info -- so users lose orientation in both UI states.

## Changes Required

### A. Phase-prefixed status file writes at every phase boundary

**Format**: `P<N> <Name> | <summary>`

Phase-to-label mapping:
- P1 Meta-Plan
- P2 Planning
- P3 Synthesis
- P3.5 Review
- P4 Execution

Examples:
- `P1 Meta-Plan | Build MCP server with OAuth support...`
- `P2 Planning | Build MCP server with OAuth support...`
- `P4 Execution | Build MCP server with OAuth support...`

**Summary length**: Change the truncation from 48 characters to 40
characters. Update the character budget math near line 363:
- Old: "Truncate to 48 characters; if truncated, append '...' (so 'Nefario: ' 9-char prefix + 48 + 3 = 60 chars max)"
- New: "Truncate to 40 characters; if truncated, append '...' (prefix ~16 chars + ' | ' 3 chars + 40 + 3 = ~62 chars max)"

**Where to add writes**: At each phase boundary, BEFORE the phase
announcement marker (the `**--- Phase N: Name ---**` line). The sequence
at every phase boundary must be:
1. Write status file (silent shell command)
2. Print phase announcement marker

Specific locations in SKILL.md:

1. **Phase 1** (around lines 362-368): Refactor existing write to use the new
   format. The status write should use `P1 Meta-Plan | $summary`. Update the
   `echo "$summary"` line to `echo "P1 Meta-Plan | $summary"`.

2. **Phase 2 start**: Add a status write instruction BEFORE the Phase 2
   section heading. The instruction should say to update the status file:
   ```sh
   SID=$(cat /tmp/claude-session-id 2>/dev/null)
   echo "P2 Planning | $summary" > /tmp/nefario-status-$SID
   ```

3. **Phase 3 start**: Add a status write instruction BEFORE the Phase 3
   section. Use `P3 Synthesis | $summary`.

4. **Phase 3.5 start**: Add a status write instruction. Use
   `P3.5 Review | $summary`.

5. **Phase 4 start**: Add a status write instruction. Use
   `P4 Execution | $summary`.

The write pattern at each boundary is:
```sh
SID=$(cat /tmp/claude-session-id 2>/dev/null)
echo "P<N> <Name> | $summary" > /tmp/nefario-status-$SID
```
Do NOT extract this into a helper function -- inline it at each boundary.

**Mid-execution gate status update**: When presenting a Phase 4 approval
gate, update the status file to reflect the gate state:
```
P4 Gate | <gate task title, max 40 chars>
```
After the gate is resolved (approved/rejected/skipped), revert to:
```
P4 Execution | $summary
```
Only primary gates trigger status updates -- follow-up gates (Post-exec,
Confirm) do NOT update the status file.

### B. Phase-prefixed AskUserQuestion headers

Update the `header` field of the 8 PRIMARY gates to use `P<N> <Label>` format.
The 4 FOLLOW-UP gates keep their existing headers unchanged.

Header mapping (all must be <= 12 characters):

| Current Header | Proposed Header | Chars | Phase | Type |
|---|---|---|---|---|
| `"Team"` | `"P1 Team"` | 8 | 1 | Primary |
| `"Review"` | `"P3.5 Review"` | 11 | 3.5 | Primary |
| `"Impasse"` | `"P3 Impasse"` | 11 | 3.5 | Primary |
| `"Plan"` | `"P3.5 Plan"` | 10 | 3.5 | Primary |
| `"Gate"` | `"P4 Gate"` | 7 | 4 | Primary |
| `"Calibrate"` | `"P4 Calibrate"` | 13 -- OVER LIMIT | 4 | Primary |
| `"Security"` | `"P5 Security"` | 11 | 5 | Primary |
| `"Issue"` | `"P5 Issue"` | 8 | 5 | Primary |
| `"Post-exec"` | `"Post-exec"` | 9 | 4 | Follow-up (unchanged) |
| `"Confirm"` | `"Confirm"` | 7 | 4 | Follow-up (unchanged) |
| `"PR"` | `"PR"` | 2 | wrap-up | Follow-up (unchanged) |
| `"Existing PR"` | `"Existing PR"` | 11 | wrap-up | Follow-up (unchanged) |

IMPORTANT: "P4 Calibrate" is 13 chars which exceeds the 12-char limit.
Use "P4 Calibr." (11 chars) instead to stay within the constraint.

Notes:
- `"P3 Impasse"` drops the `.5` because "Impasse" only occurs in Phase 3.5
  -- the label is unambiguous. This saves 2 chars.
- `"P3.5 Plan"` uses `P3.5` because the Plan gate sits at the Phase 3.5 /
  Phase 4 boundary after architecture review completes.

### C. Task title in Phase 4 Gate question field

For the mid-execution approval gate (header: "P4 Gate"), modify the
`question` field specification. Currently the question uses "the DECISION line from the brief".
Change to:
```
question: "Task N: <task title>" followed by " -- " and the DECISION line
```
Example: `Task 2: Add OAuth token refresh -- Accept token rotation strategy using refresh_token grant`

This applies ONLY to the "P4 Gate" AskUserQuestion. Other gates keep
their existing question format.

### D. Add a character limit note

After the header mapping changes, add a brief inline note near the Team
Approval Gate section (around the first AskUserQuestion definition) documenting
the constraint:

> Note: AskUserQuestion `header` values must not exceed 12 characters.
> The `P<N> <Label>` convention reserves 3-5 chars for the phase prefix.

## Files to modify

- `skills/nefario/SKILL.md` -- all changes are in this single file

## What NOT to do

- Do NOT modify despicable-statusline SKILL.md
- Do NOT add status writes for Phases 5-8 (dark kitchen) -- out of scope
- Do NOT change the phase announcement markers themselves
- Do NOT change the Visual Hierarchy section
- Do NOT extract status writes into a shell helper function
- Do NOT modify the wrap-up cleanup logic (the `rm -f /tmp/nefario-status-$SID` line)
- Do NOT change question text for any gate other than "P4 Gate"

## Verification

After making changes:
1. Confirm all 8 primary gate headers are <= 12 characters
2. Confirm status file write instructions exist at Phases 1, 2, 3, 3.5, and 4 boundaries
3. Confirm each status write comes BEFORE its corresponding phase announcement marker
4. Confirm the Phase 4 Gate question format includes "Task N: <title> -- "
5. Confirm the 4 follow-up gates (Post-exec, Confirm, PR, Existing PR) are unchanged
6. Confirm the summary truncation is updated from 48 to 40 characters

When you finish your task, mark it completed with TaskUpdate and send a message to the team lead with:
- File paths with change scope and line counts
- 1-2 sentence summary of what was produced