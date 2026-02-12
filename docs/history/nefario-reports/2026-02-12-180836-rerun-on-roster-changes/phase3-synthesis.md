## Delegation Plan

**Team name**: rerun-on-roster-changes
**Description**: Add re-run option when roster changes significantly at team and reviewer approval gates

### Conflict Resolutions

**Adjustment cap interaction with re-runs**

The specialists disagree on whether a re-run resets the 2-round adjustment counter:

- **devx-minion + ux-strategy-minion**: A re-run counts toward the same adjustment round. The user initiated one "adjust" action; the system chose to re-run internally. Round count tracks user-initiated adjustment requests, not system processing steps.
- **lucy**: A re-run should reset the adjustment counter because it is effectively a fresh pass through the phase.

**Resolution**: Side with devx-minion and ux-strategy-minion. A re-run counts as the same adjustment round that triggered it. Rationale:

1. The user's mental model is "I adjusted once" regardless of how thorough the system's response was. Resetting the counter creates a silent behavior difference that the user cannot predict or observe.
2. Lucy's concern about infinite loops is valid but addressed differently: we cap at 1 re-run per gate (as lucy also recommends). Combined with the 2-round adjustment cap, the worst case is: adjust round 1 (with re-run) -> adjust round 2 (with re-run) -> cap reached. That is 2 user-initiated adjustments, each potentially with a re-run -- bounded and predictable.
3. The re-run cap (max 1 per gate) prevents the infinite loop risk that motivated lucy's reset suggestion, without the confusing counter-reset behavior.

**Override mechanism visibility**

- **devx-minion**: Offer explicit override keywords ("lightweight" / "re-run") after classification announcement.
- **ux-strategy-minion**: Make the re-run entirely invisible to the user -- no override, no threshold exposure, no secondary decision point.

**Resolution**: Side with ux-strategy-minion. The re-run is a system behavior, not a user decision. Rationale:

1. The user already has the Adjust/Approve/Reject options at the re-presented gate. If they disagree with the re-run result, they can adjust again (within cap) or reject.
2. Adding override keywords creates a secondary decision point that the issue explicitly excludes ("no additional approval gates introduced").
3. Exposing the threshold ("4 changes, re-running...") leaks implementation details that increase cognitive load without improving user control -- the user controls the WHAT (team composition), the system handles the HOW (processing thoroughness).

**Re-run output file naming**

- **ai-modeling-minion**: Write to `phase1-metaplan-rerun.md` (preserve original as audit artifact).
- **devx-minion**: Overwrite `phase1-metaplan.md` (avoid stale artifacts).

**Resolution**: Use `phase1-metaplan-rerun.md` per ai-modeling-minion. The original meta-plan is referenced by the calling session's context and the scratch directory serves as an audit trail. Overwriting creates a risk of stale in-context references.

### Task 1: Add adjustment classification definition to SKILL.md
- **Agent**: devx-minion
- **Delegation type**: standard
- **Model**: opus
- **Mode**: default
- **Blocked by**: none
- **Approval gate**: no
- **Prompt**: |
    You are updating the nefario orchestration skill specification to add a
    shared definition for classifying adjustment magnitude at approval gates.

    ## Task
    Add an "Adjustment Classification" definition block to SKILL.md. This
    definition is referenced by both the Team Approval Gate and the Reviewer
    Approval Gate adjustment handling.

    ## Location
    File: `/Users/ben/github/benpeter/2despicable/2/skills/nefario/SKILL.md`

    Insert the definition BEFORE the "Adjust team" response handling section
    (currently around line 428), as a subsection within or just before the
    Team Approval Gate section. It should be positioned so both gate sections
    can reference it by name.

    ## Content to Add

    Add a block with these exact semantics (adapt the formatting to match
    SKILL.md's existing style):

    **Adjustment classification**: When a user adjusts team or reviewer
    composition, count total agent changes (additions + removals).
    - **Minor** (1-2 changes): Use the lightweight path -- generate planning
      questions for added agents only, keep existing artifacts for unchanged
      agents.
    - **Substantial** (3+ changes): Use the re-run path -- re-execute the
      relevant planning phase to regenerate artifacts for the full updated
      composition.

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
- **Deliverables**: New "Adjustment Classification" definition block in SKILL.md, positioned before the gate response handling sections
- **Success criteria**: Both gate sections can reference "adjustment classification" by name; the definition covers threshold, cap rules, and round-counting semantics

### Task 2: Restructure "Adjust team" response handling in SKILL.md
- **Agent**: devx-minion
- **Delegation type**: standard
- **Model**: opus
- **Mode**: default
- **Blocked by**: Task 1
- **Approval gate**: yes
- **Gate reason**: This changes the Team Approval Gate flow -- a hard-to-reverse behavioral contract with downstream impact on Phase 1 re-runs and Phase 2 specialist spawning. Multiple valid approaches exist (invisible re-run vs. explicit override, context-aware vs. fresh re-run).
- **Prompt**: |
    You are updating the Team Approval Gate's "Adjust team" response handling
    in the nefario orchestration skill to support re-runs on substantial
    roster changes.

    ## Task
    Replace the current steps 3-5 of the "Adjust team" response handling
    (SKILL.md, currently around lines 439-445) with a branching flow based
    on the adjustment classification definition added in Task 1.

    ## File
    `/Users/ben/github/benpeter/2despicable/2/skills/nefario/SKILL.md`

    ## Current Flow (steps 3-5)
    ```
    3. For added agents, nefario generates planning questions (lightweight
       inference from task context, not a full re-plan).
    4. Re-present the gate with the updated team for confirmation.
    5. Cap at 2 adjustment rounds. [...]
    ```

    ## New Flow

    Replace steps 3-5 with:

    3. Classify the adjustment per the adjustment classification definition.

    4a. **Minor path (1-2 changes)**: For added agents, nefario generates
        planning questions (lightweight inference from task context, not a
        full re-plan). For removed agents, drop their planning questions.
        Re-present the gate with the updated team.

    4b. **Substantial path (3+ changes)**: Re-run Phase 1 by spawning
        nefario with `MODE: META-PLAN`. The re-run receives:
        - The original task description (same `original-prompt`)
        - The original meta-plan (from `$SCRATCH_DIR/{slug}/phase1-metaplan.md`)
        - The user's adjustment as a structured delta (e.g., "Added:
          security-minion, observability-minion. Removed: frontend-minion.")
        - A constraint directive:
          - Keep the same scope and task description
          - Preserve external skill integration decisions unless invalidated
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
    - Do NOT modify the adjustment classification definition (Task 1)
    - Do NOT touch any other sections of SKILL.md
- **Deliverables**: Updated "Adjust team" response handling section in SKILL.md with minor/substantial branching flow
- **Success criteria**: The "Adjust team" flow branches on classification; substantial changes spawn a META-PLAN re-run with context; re-run output goes to a separate file; gate is re-presented with delta summary; cap and round-counting semantics are explicit

### Task 3: Restructure "Adjust reviewers" response handling in SKILL.md
- **Agent**: devx-minion
- **Delegation type**: standard
- **Model**: opus
- **Mode**: default
- **Blocked by**: Task 1
- **Approval gate**: no
- **Prompt**: |
    You are updating the Reviewer Approval Gate's "Adjust reviewers" response
    handling in the nefario orchestration skill to support re-evaluation on
    substantial reviewer changes.

    ## Task
    Expand the current "Adjust reviewers" response handling (SKILL.md,
    currently around lines 693-697) with a branching flow based on the
    adjustment classification definition added in Task 1.

    ## File
    `/Users/ben/github/benpeter/2despicable/2/skills/nefario/SKILL.md`

    ## Current Flow
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

    4. Cap at 2 adjustment rounds. A re-run counts as the same adjustment
       round (per adjustment classification definition). Cap at 1 re-run
       per gate. After cap, present Approve/Skip only.

    ## Key Design Decisions
    - Reviewer re-evaluation is lighter than Team gate re-run -- no subagent
      spawn, no mode change. It is an in-session re-evaluation of the
      discretionary pool against the delegation plan.
    - User-requested reviewer additions are hard constraints -- nefario never
      overrides the user's explicit choices, even if no domain signal matches.
    - The mandatory 5 reviewers are never affected by adjustments.
    - Same invisible classification, same cap semantics as the Team gate.

    ## What NOT to Do
    - Do NOT modify the Reviewer Approval Gate format or AskUserQuestion structure
    - Do NOT allow modifications to the mandatory reviewer set
    - Do NOT spawn nefario as a subagent for reviewer re-evaluation
    - Do NOT expose the threshold to the user
    - Do NOT modify the "Approve reviewers" or "Skip review" handling
    - Do NOT modify the adjustment classification definition (Task 1)
    - Do NOT touch any other sections of SKILL.md
- **Deliverables**: Updated "Adjust reviewers" response handling section in SKILL.md with minor/substantial branching flow
- **Success criteria**: The "Adjust reviewers" flow branches on classification; substantial changes trigger in-session reviewer re-evaluation; user additions are hard constraints; rationales are plan-grounded; cap and round-counting semantics match the Team gate

### Task 4: Update docs/orchestration.md
- **Agent**: software-docs-minion
- **Delegation type**: standard
- **Model**: opus
- **Mode**: default
- **Blocked by**: Task 2, Task 3
- **Approval gate**: no
- **Prompt**: |
    You are updating the architecture documentation to reflect changes made
    to the Team Approval Gate and Reviewer Approval Gate adjustment flows.

    ## Task
    Update `docs/orchestration.md` to document the re-run behavior added to
    both approval gates. This file is the architecture reference that
    describes the same gates documented procedurally in SKILL.md.

    ## File
    `/Users/ben/github/benpeter/2despicable/2/docs/orchestration.md`

    ## What Changed (read the updated SKILL.md for exact wording)

    Read the updated SKILL.md at
    `/Users/ben/github/benpeter/2despicable/2/skills/nefario/SKILL.md`
    to understand the exact changes. Then update orchestration.md to reflect:

    1. **Team Approval Gate section** (around line 386): The "Adjust team"
       description currently says "generates planning questions for any added
       agents." Update to mention that substantial changes (3+) trigger a
       Phase 1 re-run, while minor changes (1-2) use the existing lightweight
       path. Keep it brief -- one sentence addition, not a full specification.
       The SKILL.md is the procedural spec; orchestration.md is the
       architecture overview.

    2. **Reviewer Approval Gate** (around line 78): Currently says
       "adjust discretionary picks (constrained to the 6-member pool,
       2-round adjustment cap)." Add a brief note about substantial changes
       triggering reviewer re-evaluation.

    3. **Mermaid sequence diagram** (lines 173-304): Evaluate whether the
       diagram needs updating. The re-run paths are internal to the "Adjust"
       response handling -- the diagram already shows
       `User->>Main: Approve / Adjust / Reject` and
       `User->>Main: Approve / Adjust / Skip review`. If the existing
       diagram adequately represents the flow (adjust is still adjust, just
       with more internal processing), leave it unchanged with a brief
       rationale comment in your output. If the re-run loop-back is
       architecturally significant enough to show, add a minimal annotation.

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
- **Deliverables**: Updated Team Approval Gate section, Reviewer Approval Gate section, and mermaid diagram (if needed) in docs/orchestration.md
- **Success criteria**: orchestration.md accurately reflects the re-run behavior at both gates; additions are brief and architectural (not procedural); no contradiction between orchestration.md and SKILL.md

### Cross-Cutting Coverage

- **Testing**: No executable code produced. All changes are to specification documents (SKILL.md, docs/orchestration.md). Testing is covered by Phase 3.5 architecture review (test-minion reviews the spec for testability and coverage implications). No Phase 6 test execution needed.
- **Security**: No attack surface changes. The re-run mechanism processes the same user input (agent names from a fixed roster) through the same validation. No new auth, APIs, or user input handling. security-minion reviews in Phase 3.5 as mandatory reviewer.
- **Usability -- Strategy**: Covered in planning (ux-strategy-minion contributed). Key decisions incorporated: invisible classification, no override mechanism, "refresh" framing, same-gate re-presentation.
- **Usability -- Design**: Not applicable. No UI components, visual layouts, or interaction patterns are produced. The changes are to CLI text output within existing gate structures.
- **Documentation**: Task 4 (software-docs-minion) updates docs/orchestration.md. No user-facing documentation needed -- these are internal orchestration changes not visible to end users beyond the gate interaction they already experience.
- **Observability**: Not applicable. No runtime components, services, or APIs are produced.

### Architecture Review Agents
- **Mandatory** (5): security-minion, test-minion, software-docs-minion, lucy, margo
- **Discretionary picks**:
  - ai-modeling-minion: Tasks 2 and 3 define prompt templates and context-passing strategies for nefario re-spawning; ai-modeling-minion's prompt engineering expertise ensures the re-run prompt design is sound (user explicitly requested this agent).
- **Not selected**: ux-strategy-minion (contributed during planning, no UI artifacts produced), ux-design-minion (no UI components), accessibility-minion (no web-facing UI), sitespeed-minion (no runtime components), observability-minion (no runtime components), user-docs-minion (no end-user documentation changes)

### Risks and Mitigations

1. **Re-run latency at Team gate** (30-60s opus spawn). The user is in an interactive adjustment flow and may expect fast response. Mitigation: the heartbeat mechanism already shows activity during subagent spawns. The CONDENSE line uses "refreshing" language to set expectations. If latency proves problematic in practice, the threshold can be raised to 4+ in a future iteration.

2. **Stale in-context references after re-run**. The calling session's context contains the original meta-plan text from Phase 1. After a re-run writes to `phase1-metaplan-rerun.md`, the session must read the re-run file to populate the re-presented gate. Mitigation: Task 2's prompt explicitly instructs that the re-presented gate must reference the re-run output file, not in-context original.

3. **Scope drift on re-run**. Even with constraints, the re-spawned nefario could subtly reframe the task if team changes imply a different interpretation. Mitigation: constraint directive explicitly prohibits scope changes; re-run output goes through the same Team Approval Gate, giving the user a second look.

4. **Re-run cap interaction with adjustment cap**. With 1 re-run cap per gate and 2 adjustment rounds, the worst case is 2 adjustments (each potentially with a re-run) before cap. This is bounded and predictable. If a substantial adjustment occurs after the re-run cap is reached, the lightweight path is used with a CONDENSE note.

5. **SKILL.md and docs/orchestration.md consistency**. These files describe the same gates. Task 4 depends on Tasks 2-3 to ensure it documents the final state. The dependency chain enforces this ordering.

### Execution Order

```
Batch 1 (parallel-safe):
  Task 1: Add adjustment classification definition to SKILL.md

Batch 2 (parallel, both depend on Task 1):
  Task 2: Restructure "Adjust team" response handling [APPROVAL GATE]
  Task 3: Restructure "Adjust reviewers" response handling

Batch 3 (depends on Tasks 2, 3):
  Task 4: Update docs/orchestration.md
```

Gate position: After Task 2 completes, before Task 4 can proceed. Task 3 does not gate Task 4 independently but is a dependency (Task 4 needs to document both changes).

### Verification Steps

1. Read the updated SKILL.md and verify both gate sections reference the adjustment classification definition consistently.
2. Verify the "Adjust team" flow has explicit branching on classification with re-run mechanics (context blocks, output file, constraint directive, cap semantics).
3. Verify the "Adjust reviewers" flow has parallel branching with in-session re-evaluation (no subagent spawn), user additions as hard constraints, plan-grounded rationales.
4. Verify docs/orchestration.md mentions re-run behavior at both gates without duplicating SKILL.md procedural detail.
5. Verify no new AskUserQuestion calls or gate types were introduced.
6. Verify cap semantics: re-run counts as same round, 1 re-run cap per gate, 2 adjustment round cap preserved.
7. Cross-check SKILL.md and orchestration.md for contradictions.
