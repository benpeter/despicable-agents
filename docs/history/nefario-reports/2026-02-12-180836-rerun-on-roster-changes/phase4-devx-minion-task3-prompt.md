You are updating the Reviewer Approval Gate's "Adjust reviewers" response
handling in the nefario orchestration skill to support re-evaluation on
substantial reviewer changes.

## Task
Expand the current "Adjust reviewers" response handling (SKILL.md) with
a branching flow based on the adjustment classification definition
(around lines 428-452).

## File
/Users/ben/github/benpeter/2despicable/2/skills/nefario/SKILL.md

## Current Flow (to be replaced)
Find the "Adjust reviewers" response handling. It currently reads something like:
```
"Adjust reviewers": User provides freeform adjustment. Constrained to the
6-member discretionary pool. If the user requests an agent outside the pool,
note it is not a Phase 3.5 reviewer and offer the closest match from the pool.
Cap at 2 adjustment rounds, same as the Team Approval Gate. After adjustment,
spawn the final approved set.
```

## New Flow

Replace with:

**"Adjust reviewers"**:
1. User provides freeform adjustment. Constrained to the 6-member
   discretionary pool. If the user requests an agent outside the pool,
   note it is not a Phase 3.5 reviewer and offer the closest match.
   Validate agent references against the known discretionary pool
   before interpretation.

2. Classify the adjustment per the adjustment classification definition
   (count changes within the discretionary pool only -- mandatory
   reviewers are never affected).

3a. **Minor path (1-2 changes)**: Apply changes directly. Keep existing
    rationales for unchanged reviewers. For added reviewers, generate a
    plan-grounded rationale matching the format of the original picks.
    For user-added reviewers with no domain signal match in the plan,
    note: "User-requested; no direct domain signal in plan."
    Re-present the Reviewer Approval Gate with updated picks.

3b. **Substantial path (3+ changes)**: Re-evaluate all 6 discretionary
    pool members against the delegation plan, producing fresh rationales.
    This is a nefario-internal operation (no subagent spawn) -- the
    calling session re-runs the domain signal evaluation from the
    "Identify Reviewers" section. User-requested additions are treated
    as hard constraints (always included); nefario re-evaluates the
    remaining pool slots.

    Re-present the Reviewer Approval Gate with updated discretionary
    picks and a delta summary: "Reviewers refreshed for substantial
    change (+N, -M). Rationales regenerated."

    No scratch file is produced for the reviewer re-evaluation -- the
    output is the re-presented gate itself.

    CONDENSE line after re-evaluation:
    ```
    Reviewers: refreshed for reviewer change (+N, -M) | N mandatory + M discretionary (pending approval)
    ```

4. Cap at 2 adjustment rounds. A re-run counts as the same adjustment
   round (per adjustment classification definition). Cap at 1 re-run
   per gate. If the user requests a third adjustment, present with
   Approve/Skip only and a note: "Adjustment cap reached (2 rounds)."

## Key Design Decisions
- Reviewer re-evaluation is lighter than Team gate re-run -- no subagent
  spawn, no mode change. It is an in-session re-evaluation of the
  discretionary pool against the delegation plan.
- User-requested reviewer additions are hard constraints -- nefario never
  overrides the user's explicit choices, even if no domain signal matches.
- The mandatory 5 reviewers are never affected by adjustments.
- Same invisible classification, same cap semantics as the Team gate.
- No scratch file produced (explicit per lucy advisory).
- CONDENSE line template included (symmetric with Team gate per lucy advisory).

## What NOT to Do
- Do NOT modify the Reviewer Approval Gate format or AskUserQuestion structure
- Do NOT allow modifications to the mandatory reviewer set
- Do NOT spawn nefario as a subagent for reviewer re-evaluation
- Do NOT expose the threshold to the user
- Do NOT modify the "Approve reviewers" or "Skip review" handling
- Do NOT modify the adjustment classification definition
- Do NOT touch any other sections of SKILL.md

## After Completing
Mark task #3 as completed via TaskUpdate. Send a message to the team lead with:
- File paths with change scope and line counts
- 1-2 sentence summary of what was produced
