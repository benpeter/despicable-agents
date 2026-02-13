# Domain Plan Contribution: lucy

## Recommendations

### 1. The cross-gate inconsistency is acceptable given the explicit scope boundary

The issue explicitly scopes out the Phase 3.5 Reviewer Approval Gate. After this change, the Team Approval Gate will always re-run on any roster change, while the Reviewer Approval Gate retains the minor/substantial classification. This is a deliberate, bounded inconsistency -- not an accidental one.

Justification: The two gates operate in fundamentally different contexts. The Team gate triggers a META-PLAN re-run via a subagent spawn (expensive, high impact on downstream planning questions). The Reviewer gate performs an in-session re-evaluation of discretionary pool members (cheap, no subagent spawn, rationale-only output). The cost/benefit calculus that makes "always re-run" sensible for the Team gate does not automatically transfer to the Reviewer gate. The issue's reasoning -- "planning questions directly shape Phase 2 specialist focus" -- is specific to Team composition, not reviewer composition.

However, the shared "adjustment classification" definition block (SKILL.md lines 524-549) currently serves BOTH gates. If the Team gate no longer uses the classification, the definition block becomes Reviewer-gate-only. This has a documentation integrity implication: the definition says "When a user adjusts team or reviewer composition" but will only apply to reviewer composition. The definition must be updated or relocated to avoid a stale cross-reference.

### 2. No AGENT.md files reference the minor/substantial distinction

Confirmed via grep across all `**/AGENT.md` files. The `nefario/AGENT.md` contains zero references to "adjustment classification," "minor path," "substantial path," or "lightweight path." No AGENT.md cleanup is required.

### 3. `the-plan.md` contains zero references to the adjustment classification

Confirmed. The only match for "classification" in `the-plan.md` is the unrelated gate classification matrix (reversibility/blast radius). No `the-plan.md` changes are needed.

### 4. `docs/orchestration.md` line 385 MUST be updated

This file explicitly describes the minor/substantial branching for the Team Approval Gate's "Adjust team" option:

> "Nefario interprets the request against the 27-agent roster and classifies the adjustment by magnitude: minor changes (1-2 agents) use a lightweight path that generates questions for added agents only, while substantial changes (3+ agents) trigger a Phase 1 META-PLAN re-run to regenerate planning artifacts for the full updated team."

This must be rewritten to reflect the new behavior: any roster change triggers a full Phase 1 re-run.

Line 79 also references the classification for the Reviewer gate:

> "Adjustment classification follows the same magnitude-based branching as the Team Approval Gate: minor changes apply directly, while substantial changes trigger an in-session re-evaluation..."

After this change, the Reviewer gate can no longer claim it "follows the same magnitude-based branching as the Team Approval Gate" because the Team gate no longer uses magnitude-based branching. This sentence must be updated to describe the Reviewer gate's classification on its own terms.

### 5. The shared adjustment classification definition must be narrowed

The definition block at SKILL.md lines 524-549 currently opens with:

> "**Adjustment classification**: When a user adjusts team or reviewer composition, count total agent changes..."

After this change, the Team gate no longer uses this classification. The definition should be:
- Narrowed to scope it to the Reviewer Approval Gate only, OR
- Removed entirely if the Reviewer gate's minor/substantial logic is inlined into its own section

Either approach works. Inlining is slightly cleaner since the shared definition was justified by DRYing across two consumers, and after this change there is only one consumer.

### 6. Cap constraints remain coherent after removing classification

The "1 re-run cap per gate" constraint currently has a fallback clause: "If a second substantial adjustment occurs at the same gate, use the lightweight path." After this change, every adjustment triggers a re-run (not just substantial ones), so the re-run cap triggers more readily:
- Adjustment 1: full re-run
- Adjustment 2: re-run cap already reached from adjustment 1; what happens?

The current fallback says "use the lightweight path." But the entire point of this issue is that the lightweight path produces stale questions. The plan must define what happens on a second adjustment when the re-run cap is reached. Options:
- **(a)** Allow 1 re-run per adjustment round (effectively re-run cap = 2 since there are 2 adjustment rounds). This aligns with the spirit of "any change triggers re-run."
- **(b)** Keep re-run cap at 1. On the second adjustment, use some degraded path (but NOT the lightweight path, since that is being eliminated). For example: apply the delta without re-running, and note to the user that a re-run was not performed.
- **(c)** On the second adjustment, if the re-run cap is reached, the 2-round cap also limits the user to Approve/Reject only, so no path decision is needed.

Option (c) needs verification. The current spec says: "Cap at 2 adjustment rounds. A re-run counts as the same adjustment round that triggered it, not an additional round." So:
- Round 1: adjust -> re-run (counts as round 1)
- Round 2: adjust -> re-run cap reached, but this IS round 2, which is the last permitted round

The 2-round cap and the 1-re-run cap interact such that the second adjustment is the LAST adjustment. After round 2, only Approve/Reject is offered. So the question is only: what happens on adjustment 2 (the final round) when the re-run cap is reached?

The plan MUST explicitly address this interaction. My recommendation: change the re-run cap to match the adjustment round cap (i.e., allow 1 re-run per adjustment round, so 2 re-runs max across the gate's lifetime). This is the simplest behavior: every adjustment triggers a re-run, period. The 2-round cap prevents abuse.

### 7. The "re-run cap reached" CONDENSE line references the lightweight path

SKILL.md line 545-546: `"Using lightweight path (re-run cap reached)."` This CONDENSE line text must be updated since the lightweight path is being removed.

## Proposed Tasks

### Task 1: Update SKILL.md Team Approval Gate adjustment handling

- **What**: Remove the minor/substantial branching from the Team gate section (lines 562-604). Replace with a single path: any non-zero roster change triggers a full Phase 1 re-run. Preserve the no-op clause (0 changes). Update the re-run cap semantics (see recommendation 6). Remove or update the CONDENSE line referencing "lightweight path."
- **Deliverables**: Updated SKILL.md Team Approval Gate section
- **Dependencies**: Should be done after or concurrently with the adjustment classification definition update (Task 2), since the Team gate references the definition

### Task 2: Update or remove the shared adjustment classification definition

- **What**: The definition at SKILL.md lines 524-549 currently serves both gates. Narrow it to the Reviewer gate only (rename to "Reviewer adjustment classification" or similar, remove "team" from the opening sentence), OR inline it into the Reviewer gate section and remove the shared block. Update all back-references in the Reviewer gate section (lines 1009, 1041) accordingly.
- **Deliverables**: Updated SKILL.md adjustment classification definition (narrowed or inlined)
- **Dependencies**: None (but coordinate with Task 1 and Task 3 to avoid merge conflicts)

### Task 3: Update `docs/orchestration.md`

- **What**: Rewrite line 385 to describe the new behavior (any Team gate adjustment triggers a full re-run; no classification). Rewrite line 79 to describe the Reviewer gate's classification on its own terms, without referencing the Team gate's (now-removed) classification.
- **Deliverables**: Updated `docs/orchestration.md` lines 79 and 385
- **Dependencies**: After Tasks 1 and 2 are defined (so the docs match the spec)

### Task 4: Verify no AGENT.md references need updating

- **What**: Confirm (already done in this review) that no AGENT.md files reference the minor/substantial adjustment classification. This task is a verification-only step, not an edit.
- **Deliverables**: Verification confirmation (no files to change)
- **Dependencies**: None

## Risks and Concerns

### RISK 1: Re-run cap / adjustment round cap interaction (MEDIUM)

The current spec's re-run cap fallback ("use the lightweight path") becomes incoherent when the lightweight path is removed. If the plan does not explicitly define the fallback behavior for a capped re-run, the implementing agent will have to invent one, risking inconsistency.

**Mitigation**: The plan must specify the cap interaction explicitly. Recommendation: allow 1 re-run per adjustment round (2 total), eliminating the need for a fallback path.

### RISK 2: Stale cross-reference in shared definition (LOW)

If the shared adjustment classification definition is left unchanged (still mentioning "team or reviewer"), it creates a misleading reference: the Team gate no longer uses it. This is a documentation consistency issue, not a runtime bug, but it will confuse future readers and agents.

**Mitigation**: Task 2 addresses this directly.

### RISK 3: `docs/orchestration.md` Reviewer gate sentence becomes stale (LOW)

Line 79 says the Reviewer gate "follows the same magnitude-based branching as the Team Approval Gate." After this change, this statement is false. If Task 3 is omitted or done carelessly, the architecture doc will be inconsistent with SKILL.md.

**Mitigation**: Task 3 addresses this directly. The reviewer should verify that line 79 no longer cross-references the Team gate's behavior.

### RISK 4: History reports reference the old behavior (NOT A RISK)

Files under `docs/history/nefario-reports/2026-02-12-180836-rerun-on-roster-changes/` extensively reference the minor/substantial classification. These are historical records of a past execution and should NOT be updated. They accurately describe what was done at that time.

## Additional Agents Needed

None. The current team is sufficient for this scope. The changes are confined to SKILL.md and docs/orchestration.md, which are nefario's orchestration spec files. No code is produced, no tests are needed, no security surface is affected. A devx-minion or similar spec-editing agent can execute the SKILL.md changes; a software-docs-minion can handle the orchestration.md update. Governance review (lucy, margo) at Phase 3.5 is standard.
