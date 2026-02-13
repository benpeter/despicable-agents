You are updating `docs/orchestration.md` to reflect changes made to the Team
Approval Gate in SKILL.md (Task 1). You are also verifying that no AGENT.md
files need updating.

## Context

The Team Approval Gate in SKILL.md has been simplified: any roster change now
triggers a full Phase 1 re-run. The minor/substantial classification has been
removed from the Team gate. The Reviewer Approval Gate STILL uses the
minor/substantial classification (unchanged behavior).

## What to Do

**1. Rewrite the "Adjust team" description at line 385 of docs/orchestration.md.**

The current text describes minor/substantial classification and magnitude-based
branching. Replace with text that describes the new behavior:
- Any non-zero roster change triggers a full Phase 1 META-PLAN re-run
- No classification or magnitude-based branching
- Re-run regenerates planning questions for the full updated team
- Still capped at 2 adjustment rounds
- Reference SKILL.md for procedural details

Keep the same structure and tone as the surrounding text. Keep it concise.

**2. Rewrite the Reviewer gate cross-reference at line 79 of docs/orchestration.md.**

The current text says the Reviewer gate "follows the same magnitude-based
branching as the Team Approval Gate." That statement is now false since the
Team gate no longer uses magnitude-based branching. Rewrite that sentence to
describe the Reviewer gate's own behavior on its own terms:
- Minor reviewer adjustments (1-2 changes) apply directly
- Substantial reviewer adjustments (3+ changes) trigger re-evaluation of all
  discretionary pool members
- Do NOT reference the Team gate's behavior

**3. Verify AGENT.md files.**

Confirm that no AGENT.md files reference "minor path," "substantial path,"
"lightweight path," or "adjustment classification" in the context of gate
adjustment handling. (Pre-verified: no matches found. State this confirmation
in your deliverable.)

## What NOT to Do

- Do NOT modify SKILL.md (already handled by Tasks 1 and 2).
- Do NOT modify any AGENT.md files (no changes needed).
- Do NOT modify `the-plan.md`.
- Do NOT modify history docs under `docs/history/`.
- Do NOT change the Reviewer gate's behavior description -- just fix the
  cross-reference so it stands on its own.

## Files to Edit

- `/Users/ben/github/benpeter/2despicable/2/docs/orchestration.md` (lines 79 and 385)

## Deliverables

1. Updated `docs/orchestration.md` line 385 (Team gate description)
2. Updated `docs/orchestration.md` line 79 (Reviewer gate cross-reference)
3. Verification note: no AGENT.md files require changes

## Success Criteria

- Line 385 describes "any change triggers full re-run" without referencing
  minor/substantial/lightweight
- Line 79 describes the Reviewer gate's adjustment classification on its own
  terms without referencing the Team gate
- No AGENT.md files were modified
- The tone and depth match the surrounding documentation

When you finish your task, mark it completed with TaskUpdate and send a message to the team lead with:
- File paths with change scope and line counts (e.g., "src/auth.ts (new OAuth flow, +142 lines)")
- 1-2 sentence summary of what was produced
