You are updating the architecture documentation to reflect changes made
to the Team Approval Gate and Reviewer Approval Gate adjustment flows.

## Task
Update docs/orchestration.md to document the re-run behavior added to
both approval gates. This file is the architecture reference that
describes the same gates documented procedurally in SKILL.md.

## File
/Users/ben/github/benpeter/2despicable/2/docs/orchestration.md

## What Changed (read the updated SKILL.md for exact wording)

Read the updated SKILL.md at
/Users/ben/github/benpeter/2despicable/2/skills/nefario/SKILL.md
to understand the exact changes. Then update orchestration.md to reflect:

1. **Adjustment classification definition**: A new shared definition was added
   to SKILL.md (around lines 428-455). orchestration.md should briefly mention
   that adjustment magnitude determines processing depth (minor = lightweight,
   substantial = re-run), without duplicating the full procedural definition.

2. **Team Approval Gate section**: The "Adjust team" flow now branches on
   classification. Substantial changes (3+ agents) trigger a Phase 1 META-PLAN
   re-run; minor changes (1-2) use lightweight question generation. Add a brief
   note to the existing Team Approval Gate description.

3. **Reviewer Approval Gate section** (around line 78): The "Adjust reviewers"
   flow now branches similarly. Substantial changes trigger in-session
   re-evaluation of all discretionary reviewers; minor changes apply directly.
   Add a brief note.

4. **Mermaid sequence diagram**: Evaluate whether the diagram needs updating.
   The re-run paths are internal to the "Adjust" response handling -- the
   diagram already shows the adjust flow. If the existing diagram adequately
   represents the flow (adjust is still adjust, just with more internal
   processing), leave it unchanged.

## Style Constraints
- orchestration.md is an architecture overview, NOT a procedural spec.
  Keep additions brief and high-level. One or two sentences per section.
- Match the existing document's tone and formatting.
- Do NOT duplicate the detailed procedural flow from SKILL.md.
- Reference SKILL.md for implementation details where appropriate.

## What NOT to Do
- Do NOT rewrite existing sections -- add to them minimally
- Do NOT add implementation details that belong in SKILL.md
- Do NOT modify sections unrelated to the Team and Reviewer gates
- Do NOT modify any other files

## After Completing
Mark task #4 as completed via TaskUpdate. Send a message to the team lead with:
- File paths with change scope and line counts
- 1-2 sentence summary of what was produced
