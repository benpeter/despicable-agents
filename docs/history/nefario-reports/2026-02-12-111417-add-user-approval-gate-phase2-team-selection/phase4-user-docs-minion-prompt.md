You are updating the user-facing guide for nefario to reflect a new
team approval gate.

## Task
Update `docs/using-nefario.md` to describe the new team confirmation
step in the user's journey.

## What to Change

### Change 1: Update Phase 1 description

Find the Phase 1 description that says something like "No action needed
from you -- this is informational." Replace with text that describes the
new user interaction: After nefario identifies the specialists, you see
the team with a brief rationale for each selection. You approve the team,
adjust it (add or remove specialists), or reject the orchestration. This
is a quick confirmation -- typically a one-click approve.

### Change 2: Update Phase 2 description

Find the Phase 2 description that starts with specialists being consulted
in parallel. Add a note that the specialists were confirmed by the user in
the preceding step.

## What NOT to Change

- Any other phase descriptions
- The "Tips for Success" section or similar advice sections
- Any section not directly about Phase 1 or Phase 2 workflow descriptions

## Tone and Style

This is a user-facing guide. Write for a developer who has never used
nefario before. Keep it conversational and practical. Do not use
internal terminology like "AskUserQuestion" or "CONDENSE line."

## Context

Read these files:
- `docs/using-nefario.md` -- the file you are modifying
- `skills/nefario/SKILL.md` -- read the new Team Approval Gate section
  (around lines 378-456) to understand what the user actually experiences

## Deliverables
- Updated `docs/using-nefario.md` with revised Phase 1 and Phase 2 descriptions

## Success Criteria
- A new user reading the guide understands they will be asked to confirm
  the team before specialist planning begins
- The description makes it clear this is a quick interaction, not a detailed review

When you finish your task, mark it completed with TaskUpdate and
send a message to the team lead with:
- File paths with change scope and line counts
- 1-2 sentence summary of what was produced
