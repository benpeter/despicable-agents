You are updating the nefario orchestration skill specification to add a
shared definition for classifying adjustment magnitude at approval gates.

## Task
Add an "Adjustment Classification" definition block to SKILL.md. This
definition is referenced by both the Team Approval Gate and the Reviewer
Approval Gate adjustment handling.

## Location
File: /Users/ben/github/benpeter/2despicable/2/skills/nefario/SKILL.md

Insert the definition BEFORE the "Adjust team" response handling section
(currently around line 428), as a new sub-heading within the Team Approval
Gate section. It should be positioned so both gate sections can reference
it by name.

## Content to Add

Add a block with these exact semantics (adapt the formatting to match
SKILL.md's existing style):

**Adjustment classification**: When a user adjusts team or reviewer
composition, count total agent changes (additions + removals). A
replacement (swap agent X for agent Y) counts as 2 changes (1 removal +
1 addition).

- **Minor** (1-2 changes): Use the lightweight path -- generate planning
  questions for added agents only, keep existing artifacts for unchanged
  agents.
- **Substantial** (3+ changes): Use the re-run path -- re-execute the
  relevant planning phase to regenerate artifacts for the full updated
  composition.

If the user's adjustment results in 0 net changes (e.g., adds and then
removes the same agent, or the freeform input resolves to no changes),
treat as a no-op: re-present the gate unchanged with a note "No changes
detected."

Rules:
- Classification is internal. Never surface the threshold number or the
  classification to the user.
- A re-run counts as the same adjustment round that triggered it, not an
  additional round toward the 2-round cap.
- Cap at 1 re-run per gate. If a second substantial adjustment occurs at
  the same gate, use the lightweight path with a note in the CONDENSE
  line: "Using lightweight path (re-run cap reached)."
- The user controls composition (WHAT changes). The system controls
  processing thoroughness (HOW the change is processed). No override
  mechanism.

## Style Constraints
- Match SKILL.md's existing formatting conventions (headers, emphasis,
  indentation).
- Keep it concise -- this is a reference definition, not a tutorial.
- Use the term "adjustment classification" consistently so both gate
  sections can reference it by that name.

## What NOT to Do
- Do NOT modify the "Adjust team" or "Adjust reviewers" response handling
  sections -- those are handled by separate tasks.
- Do NOT add any new AskUserQuestion calls or approval gates.
- Do NOT add percentage-based or relative thresholds.
- Do NOT add override keywords or user-facing threshold exposure.

## After Completing
Mark task #1 as completed via TaskUpdate. Send a message to the team lead with:
- File paths with change scope
- 1-2 sentence summary of what was produced
