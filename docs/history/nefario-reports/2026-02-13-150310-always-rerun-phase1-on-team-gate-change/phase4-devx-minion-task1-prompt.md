You are editing `skills/nefario/SKILL.md` to simplify the Team Approval Gate
adjustment handling. The goal: remove the minor/substantial classification and
make ANY non-zero roster change trigger a full Phase 1 re-run.

## Context

The current SKILL.md has a shared "adjustment classification" block (lines
524-549) that defines minor (1-2 changes) vs. substantial (3+ changes) paths.
The Team Approval Gate (lines 460-609) uses this classification to route
adjustments to either a lightweight path (minor) or a full Phase 1 re-run
(substantial). The Reviewer Approval Gate (lines 1002-1043) also references
this shared definition -- that gate is handled by Task 2, not this task.

## What to Do

**1. Remove the shared adjustment classification block (lines 524-549).**
Delete the entire block from "Adjustment classification:" through the Rules
section ending at line 549. This shared definition will be replaced by:
- A simpler inline definition in the Team gate section (this task)
- An inlined copy in the Reviewer gate section (Task 2, not your concern)

**2. Replace step 3 and steps 4a/4b with a unified flow.**

The new "Adjust team" response handling (starting at current line 551) should be:

1. (Keep as-is) Present freeform prompt.
2. (Keep as-is) Interpret against the 27-agent roster, validate references.
3. Count total agent changes (additions + removals). A replacement (swap
   agent X for agent Y) counts as 2 changes (1 removal + 1 addition). If 0
   net changes, treat as a no-op: re-present the gate unchanged with "No
   changes detected." A no-op does not count as an adjustment round.
4. Re-run Phase 1 by spawning nefario with `MODE: META-PLAN`. (This is the
   current step 4b content, promoted to be the only path.)

Preserve ALL of the current step 4b content exactly (lines 569-597):
- Write re-run prompt to scratch file
- Secret sanitization
- The re-run prompt inputs (original task, original meta-plan, structured delta)
- Write re-run output to scratch file
- Re-present gate with delta summary

**Add two enhancements to the re-run prompt** (from ai-modeling-minion):
- After the structured delta line, add: "Revised team: <comma-separated list
  of all agents in the final team>."
- After the "original meta-plan" input line, add framing: "The following
  meta-plan was produced for the original team. Use it as context for the
  revised plan, not as a template to minimally edit."
- Add one new constraint directive: "Design planning questions as a coherent
  set -- each question should address aspects that no other agent on the team
  covers, and questions should reference cross-cutting boundaries where
  relevant."

**3. Simplify the cap rules.**

Replace the current step 5 (lines 599-604) with:

5. Cap at 2 adjustment rounds. Each adjustment triggers a full Phase 1 re-run.
   A re-run counts as the same adjustment round that triggered it, not an
   additional round. If the user requests a third adjustment, present the
   current team with only Approve/Reject options and a note: "Adjustment cap
   reached (2 rounds). Approve this team or reject to abandon."

Remove the separate "Cap at 1 re-run per gate" rule entirely. The 2-round
adjustment cap provides the bound (at most 2 re-runs). Do NOT add any
fallback to a "mechanical" or "inline" adjustment path.

**4. Add a rules block after the cap rule:**
- A re-run counts as the same adjustment round that triggered it, not an
  additional round toward the 2-round cap.
- The user controls composition (WHAT changes). The system always re-runs
  Phase 1 (HOW the change is processed). No override mechanism.

**5. Update the CONDENSE line (line 191).**
Change: `After Phase 1 re-run (substantial team adjustment):`
To: `After Phase 1 re-run (team adjustment):`
The rest of the CONDENSE line format stays the same.

Remove any CONDENSE line referencing "lightweight path" or "re-run cap reached."

**6. Update the scratch directory comment (line 310).**
Change: `phase1-metaplan-rerun.md            # output from Phase 1 re-run (if substantial team adjustment)`
To: `phase1-metaplan-rerun.md            # output from Phase 1 re-run (if team adjustment)`

## What NOT to Do

- Do NOT touch the Reviewer Approval Gate section (lines 995-1049). Task 2
  handles that.
- Do NOT touch `docs/orchestration.md`. Task 3 handles that.
- Do NOT modify any AGENT.md files.
- Do NOT change the re-run prompt's core constraint directives (lines 579-587)
  beyond the three additions specified above.
- Do NOT add a "lightweight path" or "mechanical inline adjustment" fallback.
  The entire point is one path: always re-run.
- Do NOT modify `the-plan.md`.
- Do NOT modify history docs under `docs/history/`.

## Files to Edit

- `/Users/ben/github/benpeter/2despicable/2/skills/nefario/SKILL.md`

## Deliverables

Updated SKILL.md with:
- Shared adjustment classification block removed
- Steps 3/4a/4b collapsed into a single always-re-run flow
- Re-run prompt enhanced with team list, "context not template" framing, and
  coherence instruction
- Cap rules simplified to just the 2-round adjustment cap
- CONDENSE line updated
- Scratch directory comment updated

## Success Criteria

- No references to "minor path," "substantial path," "lightweight path," or
  "adjustment classification" remain in the Team Approval Gate section
- The shared adjustment classification block (previously lines 524-549) is gone
- Any non-zero roster change triggers a full Phase 1 re-run
- The 2-round adjustment cap is preserved and is the sole bound on re-runs
- The re-run prompt includes the full revised team list, "context not template"
  framing, and the coherence instruction
- The CONDENSE line and scratch directory comment no longer reference "substantial"

When you finish your task, mark it completed with TaskUpdate and send a message to the team lead with:
- File paths with change scope and line counts (e.g., "src/auth.ts (new OAuth flow, +142 lines)")
- 1-2 sentence summary of what was produced
