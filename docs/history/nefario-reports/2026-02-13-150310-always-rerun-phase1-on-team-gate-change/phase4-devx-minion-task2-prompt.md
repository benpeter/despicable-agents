You are editing `skills/nefario/SKILL.md` to fix the Reviewer Approval Gate
after the shared adjustment classification definition was removed in Task 1.

## Context

Task 1 removed the shared "Adjustment classification" block that was previously
at lines 524-549. The Reviewer Approval Gate (Phase 3.5) references this shared
definition in two places with "the adjustment classification definition" and
"per adjustment classification definition". These are now dangling references.
The Reviewer gate STILL uses the minor/substantial distinction (this is
explicitly out of scope for change). You need to inline the classification
definition into the Reviewer gate section so it is self-contained.

## What to Do

**1. Replace the dangling reference at step 2.**

Find and replace: "Classify the adjustment per the adjustment classification definition
(count changes within the discretionary pool only -- mandatory reviewers are
never affected)."

With an inline definition:

2. Count total reviewer changes within the discretionary pool (additions +
   removals; mandatory reviewers are never affected). A replacement counts as
   2 changes. If 0 net changes, treat as a no-op: re-present the gate
   unchanged with "No changes detected." A no-op does not count as an
   adjustment round.
   - **Minor** (1-2 changes): Go to step 3a.
   - **Substantial** (3+ changes): Go to step 3b.

**2. Fix the cap rule at step 4.**

Find and replace: "A re-run counts as the same adjustment round (per adjustment
classification definition). Cap at 1 re-run per gate."

With: "A re-evaluation counts as the same adjustment round that triggered it,
not an additional round. Cap at 1 re-evaluation per gate. If a second
substantial adjustment occurs, use the minor path."

**3. Add a rules note after step 4:**
- Classification is internal. Never surface the threshold number or
  classification label to the user.
- The user controls reviewer composition. The system controls processing
  thoroughness. No override mechanism.

## What NOT to Do

- Do NOT change the Reviewer gate's behavior. It KEEPS its minor/substantial
  distinction. You are only inlining the definition that was previously shared.
- Do NOT touch the Team Approval Gate section (already updated by Task 1).
- Do NOT touch `docs/orchestration.md` (Task 3 handles that).
- Do NOT modify any AGENT.md files or `the-plan.md`.

## Files to Edit

- `/Users/ben/github/benpeter/2despicable/2/skills/nefario/SKILL.md`

## Deliverables

Updated SKILL.md Reviewer Approval Gate section with self-contained
classification definition (no dangling references to the removed shared block).

## Success Criteria

- No references to "the adjustment classification definition" or "per
  adjustment classification definition" remain in the Reviewer gate section
- The Reviewer gate's minor/substantial behavior is preserved exactly
- The inlined definition includes: change counting, replacement = 2, 0 = no-op,
  threshold (1-2 = minor, 3+ = substantial)
- Classification rules (internal, no override) are present in the Reviewer
  gate section

When you finish your task, mark it completed with TaskUpdate and send a message to the team lead with:
- File paths with change scope and line counts (e.g., "src/auth.ts (new OAuth flow, +142 lines)")
- 1-2 sentence summary of what was produced
