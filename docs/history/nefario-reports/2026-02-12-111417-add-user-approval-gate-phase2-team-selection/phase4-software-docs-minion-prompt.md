You are updating the orchestration architecture documentation to reflect
a new team approval gate added between Phase 1 and Phase 2.

## Task
Update `docs/orchestration.md` to document the new Team Approval Gate.

## What to Change

### Change 1: Update Phase 1 description (Section 1)

Find the text that says the meta-plan is informational and no user approval
is required before proceeding to Phase 2. Replace with text describing that
the meta-plan output is presented to the user via a Team Approval Gate before
Phase 2 proceeds. The user sees the selected specialists with rationale and
can approve, adjust the team, or reject the orchestration.

### Change 2: Add Team Approval Gate subsection (Section 3)

Find the section about approval gates. The intro paragraph currently describes
two types of gates. Update it to describe three types. Add a new subsection
"### Team Approval Gate" BEFORE the "### Execution Plan Approval Gate"
subsection. The three gate types are now:

1. Team Approval Gate -- occurs once, after Phase 1, before Phase 2
2. Execution Plan Approval Gate -- occurs once, after Phase 3.5, before Phase 4
3. Mid-execution gates -- occur during Phase 4

The Team Approval Gate subsection should document:
- **When it occurs**: After Phase 1 (Meta-Plan), before Phase 2 (Specialist Planning)
- **Purpose**: Visibility into team selection; prevents wasted compute on irrelevant specialists
- **Format**: Compact presentation (8-12 lines) with SELECTED agents (name + rationale), ALSO AVAILABLE list, and meta-plan link
- **Response options**: Approve team (recommended) / Adjust team / Reject
- **Adjust team workflow**: Freeform natural language, capped at 2 rounds
- **MODE: PLAN exemption**: Gate does not apply in MODE: PLAN (no specialists selected)

### Change 3: Update Mermaid diagram

Find the Mermaid sequence diagram. Add a Team Approval Gate interaction between
Phase 1 and Phase 2. Insert after the Phase 1 meta-plan return and before the
Phase 2 parallel consultation block. The interaction should show:
- A note: "Team Approval Gate"
- Main presenting team composition to User
- User responding with Approve / Adjust / Reject

## What NOT to Change

- Phase 3.5 Architecture Review section
- Execution Plan Approval Gate section (format, options, behavior unchanged)
- Mid-execution gates section
- Any other section of the document

## Context

Read these files:
- `docs/orchestration.md` -- the file you are modifying
- `skills/nefario/SKILL.md` -- read the new Team Approval Gate section
  (around lines 378-456) to ensure documentation accurately reflects the implementation

## Deliverables
- Updated `docs/orchestration.md` with Phase 1 description change, new Team Approval Gate subsection, and Mermaid diagram update

## Success Criteria
- The three gate types (team, plan, mid-execution) are clearly distinguished
- The Mermaid diagram shows the user interaction between Phase 1 and Phase 2
- Documentation matches the SKILL.md implementation

When you finish your task, mark it completed with TaskUpdate and
send a message to the team lead with:
- File paths with change scope and line counts
- 1-2 sentence summary of what was produced
