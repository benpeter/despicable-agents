You are updating the Team Approval Gate's "Adjust team" response handling
in the nefario orchestration skill to support re-runs on substantial
roster changes.

## Task
Replace the current steps 3-5 of the "Adjust team" response handling
(SKILL.md, currently around lines 465-471) with a branching flow based
on the adjustment classification definition that was just added (around
lines 428-452).

## File
/Users/ben/github/benpeter/2despicable/2/skills/nefario/SKILL.md

## Current Flow (steps 3-5, to be replaced)
```
3. For added agents, nefario generates planning questions (lightweight
   inference from task context, not a full re-plan).
4. Re-present the gate with the updated team for confirmation.
5. Cap at 2 adjustment rounds. If the user requests a third adjustment,
   present the current team with only Approve/Reject options and a note:
   "Adjustment cap reached (2 rounds). Approve this team or reject to
   abandon."
```

## New Flow

Replace steps 3-5 with:

3. Classify the adjustment per the adjustment classification definition.

4a. **Minor path (1-2 changes)**: For added agents, generate planning
    questions (lightweight inference from task context, not a full
    re-plan). For removed agents, drop their planning questions.
    Re-present the gate with the updated team.

4b. **Substantial path (3+ changes)**: Re-run Phase 1 by spawning
    nefario with `MODE: META-PLAN`. The re-run prompt receives:
    - The original task description (same `original-prompt`)
    - The original meta-plan (read from `$SCRATCH_DIR/{slug}/phase1-metaplan.md`)
    - The user's adjustment as a structured delta (e.g., "Added:
      security-minion, observability-minion. Removed: frontend-minion.")
    - A constraint directive:
      - Keep the same scope and task description
      - Preserve external skill integration decisions unless the team
        change removes all agents relevant to a skill's domain
      - Generate planning consultations for ALL agents in the revised team
      - Re-evaluate the cross-cutting checklist against the new team
      - Produce output at the same depth and format as the original
      - Do NOT change the fundamental scope of the task
      - Do NOT add agents the user did not request (beyond cross-cutting
        requirements)

    Write re-run output to `$SCRATCH_DIR/{slug}/phase1-metaplan-rerun.md`.
    Use the re-run output (not the original) going forward.

    After the re-run completes, re-present the Team Approval Gate with
    the updated team and a delta summary line:
    "Refreshed for team change (+N, -M). Planning questions regenerated."

    The re-presented gate uses the same AskUserQuestion structure (same
    header, same options). No new gate type is introduced.

5. Cap at 2 adjustment rounds. A re-run counts as the same adjustment
   round that triggered it, not an additional round. Cap at 1 re-run per
   gate (per adjustment classification definition). If the user requests
   a third adjustment, present with Approve/Reject only.

## CONDENSE Line

After a re-run completes, update the CONDENSE line:
```
Planning: refreshed for team change (+N, -M) | consulting <agents> (pending approval)
```

## Key Design Decisions (do NOT deviate)
- The re-run is invisible system behavior -- no user decision about
  whether to re-run. The user sees "refreshed for team change" in the
  re-presented gate, not "re-running Phase 1."
- No override keywords. The user's control is through Approve/Adjust/Reject
  at the re-presented gate.
- Context-aware re-run (carries original meta-plan as context), not a
  fresh start.
- Re-run counts as the same adjustment round.
- 1 re-run cap per gate.

## What NOT to Do
- Do NOT modify the Team Approval Gate format or AskUserQuestion structure
- Do NOT add override keywords ("lightweight", "re-run")
- Do NOT expose the threshold number to the user
- Do NOT modify the "Approve team" or "Reject" response handling
- Do NOT modify the adjustment classification definition (already added)
- Do NOT touch any other sections of SKILL.md

## After Completing
Mark task #2 as completed via TaskUpdate. Send a message to the team lead with:
- File paths with change scope and line counts
- 1-2 sentence summary of what was produced
