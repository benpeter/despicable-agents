## Delegation Plan

**Team name**: always-rerun-phase1-on-team-gate-change
**Description**: Simplify the Team Approval Gate adjustment handling in SKILL.md by removing the minor/substantial classification and always re-running Phase 1 on any roster change. Fix cross-references in the Reviewer gate and update orchestration docs.

### Conflict Resolution: Re-run Cap Behavior

**Conflict**: devx-minion and lucy recommend removing the 1-re-run cap entirely (the 2-round adjustment cap already bounds worst-case to 2 re-runs). ux-strategy-minion recommends keeping the 1-re-run cap with a mechanical inline fallback for the cap-exceeded case.

**Resolution**: Side with devx-minion and lucy. Remove the separate re-run cap. Rationale:

1. The issue's success criteria states "1 re-run cap per gate is preserved" -- but this refers to preserving bounded behavior, not necessarily the exact same cap mechanism. The 2-round adjustment cap already provides a hard bound: at most 2 adjustments, each triggering a re-run, so at most 2 re-runs. This is bounded and predictable.

2. The whole purpose of this change is that partial updates produce stale questions. Falling back to a mechanical inline adjustment on the second round reintroduces exactly the quality problem the issue is solving -- just under a different name. As ux-strategy-minion themselves acknowledged, users who adjust a second time "want it right, not fast."

3. Two caps with different fallback behaviors creates confusing interaction states. One cap (2 adjustment rounds) with a single behavior (always re-run) is simpler.

4. Token cost is negligible: ai-modeling-minion estimates $0.10-$0.20 per re-run. Two re-runs worst-case adds $0.20-$0.40, which is well under 5% of a typical orchestration cost.

**Important nuance**: The issue's success criteria says "1 re-run cap per gate is preserved." Our resolution effectively changes this to "bounded by the 2-round adjustment cap" which achieves the same goal (preventing unbounded re-runs) through a simpler mechanism. The execution task prompt must note this decision for the user's awareness at the approval gate.

### Task 1: Rewrite Team Approval Gate adjustment handling in SKILL.md
- **Agent**: devx-minion
- **Delegation type**: standard
- **Model**: opus
- **Mode**: default
- **Blocked by**: none
- **Approval gate**: yes
- **Gate reason**: This is the primary deliverable -- changes to the Team Approval Gate's adjustment handling directly affect how all future orchestrations process roster changes. Hard to reverse (behavioral change to a core gate), high blast radius (Tasks 2 and 3 depend on the exact text). Multiple valid approaches exist for the re-run cap resolution.
- **Prompt**: |
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
- **Deliverables**: Updated SKILL.md Team Approval Gate section
- **Success criteria**: grep for "minor path", "substantial path", "lightweight path", "adjustment classification" in the Team gate section returns zero matches; the unified flow is readable and complete

### Task 2: Inline Reviewer gate classification in SKILL.md
- **Agent**: devx-minion
- **Delegation type**: standard
- **Model**: opus
- **Mode**: default
- **Blocked by**: Task 1
- **Approval gate**: no
- **Prompt**: |
    You are editing `skills/nefario/SKILL.md` to fix the Reviewer Approval Gate
    after the shared adjustment classification definition was removed in Task 1.

    ## Context

    Task 1 removed the shared "Adjustment classification" block that was previously
    at lines 524-549. The Reviewer Approval Gate (Phase 3.5) at lines 1002-1043
    references this shared definition in two places:
    - Line 1009: "Classify the adjustment per the adjustment classification definition"
    - Line 1041: "per adjustment classification definition"

    These are now dangling references. The Reviewer gate STILL uses the
    minor/substantial distinction (this is explicitly out of scope for change).
    You need to inline the classification definition into the Reviewer gate section
    so it is self-contained.

    ## What to Do

    **1. Replace the dangling reference at step 2 (previously line 1009).**

    Replace: "Classify the adjustment per the adjustment classification definition
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

    **2. Fix the cap rule at step 4 (previously line 1040-1043).**

    Replace: "A re-run counts as the same adjustment round (per adjustment
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
- **Deliverables**: Updated SKILL.md Reviewer Approval Gate section with self-contained classification
- **Success criteria**: No dangling references to the removed shared definition; Reviewer gate behavior unchanged

### Task 3: Update docs/orchestration.md and verify AGENT.md references
- **Agent**: software-docs-minion
- **Delegation type**: standard
- **Model**: opus
- **Mode**: default
- **Blocked by**: Task 1
- **Approval gate**: no
- **Prompt**: |
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

    Current text (line 385):
    ```
    2. **Adjust team** -- Add or remove specialists before planning begins. The user provides freeform natural language (e.g., "add security-minion" or "drop lucy"). Nefario interprets the request against the 27-agent roster and classifies the adjustment by magnitude: minor changes (1-2 agents) use a lightweight path that generates questions for added agents only, while substantial changes (3+ agents) trigger a Phase 1 META-PLAN re-run to regenerate planning artifacts for the full updated team. See `skills/nefario/SKILL.md` for the adjustment classification definition and procedural details. Adjustment is capped at 2 rounds; after that, only Approve or Reject options remain.
    ```

    Replace with text that describes the new behavior:
    - Any non-zero roster change triggers a full Phase 1 META-PLAN re-run
    - No classification or magnitude-based branching
    - Re-run regenerates planning questions for the full updated team
    - Still capped at 2 adjustment rounds
    - Reference SKILL.md for procedural details

    Keep the same structure and tone as the surrounding text. Keep it concise.

    **2. Rewrite the Reviewer gate cross-reference at line 79 of docs/orchestration.md.**

    Current text (line 79):
    ```
    Before spawning reviewers, nefario presents its discretionary picks to the user via a Reviewer Approval Gate. The user can approve the reviewer set, adjust discretionary picks (constrained to the 5-member pool, 2-round adjustment cap), or skip architecture review entirely to proceed directly to the Execution Plan Approval Gate. Adjustment classification follows the same magnitude-based branching as the Team Approval Gate: minor changes apply directly, while substantial changes trigger an in-session re-evaluation of all discretionary pool members against the plan.
    ```

    The last sentence is now wrong -- the Team gate no longer uses magnitude-based
    branching. Rewrite that sentence to describe the Reviewer gate's own behavior
    on its own terms:
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
- **Deliverables**: Updated docs/orchestration.md (2 sections), AGENT.md verification confirmation
- **Success criteria**: No stale cross-references to the Team gate's removed classification; docs match the new SKILL.md behavior

### Cross-Cutting Coverage

- **Testing**: Not included. No executable code is produced -- all deliverables are documentation/spec edits. Verification is done via grep for stale terminology and manual review of consistency.
- **Security**: Not included. No attack surface, authentication, user input handling, or secrets management is affected. Changes are to orchestration spec text only.
- **Usability -- Strategy**: Included via ux-strategy-minion's planning contribution. Their core recommendation (always-re-run is correct, delta summary is sufficient for expectation management) is incorporated into the task prompts. No separate execution task needed -- the UX guidance is baked into the design decisions.
- **Usability -- Design**: Not included. No user-facing interfaces are produced.
- **Documentation**: Included as Task 3 (software-docs-minion updates orchestration.md). No user-docs-minion needed -- no end-user-facing documentation is affected.
- **Observability**: Not included. No runtime components, services, or APIs are produced.

### Architecture Review Agents

- **Mandatory** (5): security-minion, test-minion, ux-strategy-minion, lucy, margo
- **Discretionary picks**: none -- no tasks produce UI (ux-design-minion, accessibility-minion not needed), no web-facing runtime code (sitespeed-minion not needed), no runtime components (observability-minion not needed), no end-user-visible changes (user-docs-minion not needed)
- **Not selected**: ux-design-minion, accessibility-minion, sitespeed-minion, observability-minion, user-docs-minion

### Conflict Resolutions

**Re-run cap behavior** (detailed above): devx-minion + lucy (remove separate re-run cap, rely on 2-round adjustment cap) vs. ux-strategy-minion (keep 1-re-run cap with mechanical inline fallback). Resolved in favor of removing the separate cap. The mechanical inline fallback would reintroduce the quality problem this issue is solving. The 2-round cap provides a sufficient bound. Token cost is negligible ($0.20-$0.40 worst case per ai-modeling-minion's analysis).

**Note for approval gate**: The issue's success criteria says "1 re-run cap per gate is preserved." Our resolution effectively replaces this with "bounded by the 2-round adjustment cap." This achieves the same goal (preventing unbounded re-runs) through a simpler mechanism. The user should be aware of this deviation from the literal success criteria.

### Risks and Mitigations

1. **Reviewer gate dangling references (MEDIUM)**: Removing the shared adjustment classification block breaks the Reviewer gate's back-references. **Mitigation**: Task 2 inlines the classification into the Reviewer gate section. Task 2 is blocked by Task 1 to ensure the shared block is removed before inlining.

2. **Cross-gate inconsistency (LOW, accepted)**: After this change, the Team gate always re-runs while the Reviewer gate retains minor/substantial branching. All four specialists agree this is acceptable -- the gates have different cost profiles (subagent spawn vs. in-session evaluation). lucy's analysis: "This is a deliberate, bounded inconsistency -- not an accidental one." Tracked as potential follow-up but explicitly not in scope.

3. **History docs reference old behavior (NOT A RISK)**: Docs under `docs/history/` describe the minor/substantial classification as it existed when those reports were written. These are historical records and should not be updated. All specialists agree.

4. **Stale orchestration.md cross-reference (LOW)**: Line 79 currently says the Reviewer gate "follows the same magnitude-based branching as the Team Approval Gate." After this change, that statement is false. **Mitigation**: Task 3 explicitly rewrites this sentence.

### Execution Order

```
Batch 1 (parallel: none -- single task):
  Task 1: Rewrite Team Approval Gate adjustment handling [APPROVAL GATE]

Batch 2 (parallel after Task 1 approval):
  Task 2: Inline Reviewer gate classification
  Task 3: Update docs/orchestration.md

No further batches.
```

Gate position: After Task 1 completes, before Tasks 2 and 3 begin.

### Verification Steps

After all tasks complete:
1. `grep -n "minor path\|substantial path\|lightweight path\|adjustment classification" skills/nefario/SKILL.md` -- should return zero matches in the Team gate section (matches in Reviewer gate section are expected for "minor path" and "substantial path")
2. `grep -n "follows the same.*Team Approval Gate" docs/orchestration.md` -- should return zero matches
3. `grep -n "minor.*lightweight\|substantial.*re-run" docs/orchestration.md` -- should return zero matches in the Team gate description (line 385 area)
4. Read the updated Team gate section end-to-end to verify the flow is coherent: freeform prompt -> interpret -> count changes -> 0 = no-op -> non-zero = re-run -> 2-round cap
5. Read the updated Reviewer gate section to verify the inlined classification is complete and self-contained
6. Confirm no AGENT.md files were modified
