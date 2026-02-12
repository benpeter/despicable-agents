## Domain Plan Contribution: lucy

### Recommendations

#### 1. Demoting ux-strategy-minion from ALWAYS to discretionary in Phase 3.5: No governance conflict, but requires explicit textual separation

The cross-cutting checklist (AGENT.md lines 257-272) and the Phase 3.5 review triggering rules (AGENT.md lines 546-571) are **two distinct mechanisms that currently conflate the same agent names but serve different purposes**. The question correctly identifies the separability:

- **Cross-cutting checklist** governs **planning inclusion** -- it tells nefario "when building a plan, evaluate these six dimensions and include the relevant agents in the execution plan or provide justification for exclusion." This operates during META-PLAN, SYNTHESIS, and PLAN modes (AGENT.md line 268).
- **Phase 3.5 review triggering rules** govern **plan review** -- they determine which agents perform an architecture review of the synthesized plan before execution begins. This is a quality gate, not a planning inclusion decision.

Currently, ux-strategy-minion appears as ALWAYS in **both** mechanisms. Demoting it from ALWAYS in Phase 3.5 does NOT violate the cross-cutting checklist, because:

1. The checklist says "ALWAYS include" for Usability -- Strategy. "Include" in checklist context means: include in the execution plan (as a task participant, planning consultant, or cross-cutting reviewer). It does not specifically mandate ALWAYS-status in the Phase 3.5 architecture review gate.
2. The checklist applies across all modes and phases (META-PLAN, SYNTHESIS, PLAN). Phase 3.5 review is a downstream gate that happens AFTER the checklist has been evaluated.

**However**, the current text creates an implicit expectation of alignment between the two mechanisms. If ux-strategy-minion is ALWAYS in the checklist but conditional in 3.5, a future reader (or nefario itself) could reasonably interpret this as contradictory. The fix is straightforward: add a clarifying sentence to the cross-cutting checklist section that explicitly states the checklist governs planning/execution inclusion, not Phase 3.5 review roster composition. Something like:

> _This checklist governs agent inclusion in planning and execution phases (1-4). Phase 3.5 architecture review has its own triggering rules (see Architecture Review section) which may differ._

This is a low-cost, high-clarity change that prevents future drift between the two mechanisms.

**Verdict on governance conflict: No conflict exists, but the textual separation must be made explicit to prevent future misinterpretation.**

#### 2. software-docs-minion: Narrowing the 3.5 role to a documentation impact checklist satisfies the ALWAYS-include requirement, with conditions

The cross-cutting checklist says software-docs-minion should be ALWAYS included (line 265). The proposal keeps software-docs-minion in the ALWAYS roster for Phase 3.5 but narrows its review scope to producing a "documentation impact checklist" instead of a full architecture documentation review.

This satisfies the requirement because:

1. software-docs-minion **remains ALWAYS in Phase 3.5** -- it is not demoted or removed. The ALWAYS status is preserved.
2. The narrowed scope is coherent with the two-phase documentation model: Phase 3.5 identifies WHAT documentation is affected (the checklist), and Phase 8 executes the actual documentation work (the full review/writing).
3. The checklist output from 3.5 directly feeds Phase 8 as a work order, creating a clean handoff without redundant effort.

**Conditions for this to work without governance issues:**

- The Phase 3.5 software-docs-minion prompt must explicitly state its scope is "documentation impact assessment" (what docs are affected, what type of update is needed), NOT "documentation quality review" or "architecture documentation completeness."
- The Phase 8 documentation phase must explicitly state it consumes the Phase 3.5 checklist as its input/work order. Currently, Phase 8 generates its own checklist at the Phase 7-to-8 boundary (SKILL.md lines 1253-1269). The plan must reconcile whether Phase 8 uses the 3.5 checklist, generates its own, or merges both.
- The 3.5 checklist format should be specified to ensure Phase 8 can consume it programmatically (e.g., table with columns: affected doc, change type, triggering task, priority).

**Risk: checklist gap between 3.5 and 8.** Currently Phase 8's checklist is generated from "execution outcomes" (SKILL.md line 1253). The Phase 3.5 checklist is generated from the "execution plan" (before execution). These may diverge -- execution may produce outcomes not anticipated by the plan. The plan should clarify that Phase 8 supplements the 3.5 checklist with execution-discovered items, rather than replacing it.

#### 3. AGENT.md change scope: Contained to Architecture Review section, with two necessary spillovers

The issue says "All changes reflected in nefario AGENT.md, SKILL.md, and docs/orchestration.md." I can confirm the AGENT.md changes should be containable to:

**Primary changes (Architecture Review section, AGENT.md lines 546-614):**
- Review triggering rules table: move ux-strategy-minion from ALWAYS to conditional, add user-docs-minion to conditional pool
- software-docs-minion row: update rationale to reflect narrowed scope (documentation impact checklist)
- Add text describing the discretionary selection + user approval gate pattern

**Synthesis template spillover (AGENT.md line 511):**
- The synthesis output template at line 511 currently says:
  `- **Always**: security-minion, test-minion, ux-strategy-minion, software-docs-minion, lucy, margo`
- This must be updated to reflect the new ALWAYS roster (remove ux-strategy-minion):
  `- **Always**: security-minion, test-minion, software-docs-minion, lucy, margo`
- And the conditional section needs to indicate nefario picks from the discretionary pool.

**Cross-cutting checklist clarification (AGENT.md lines 257-272):**
- As recommended in point 1 above, add a clarifying sentence distinguishing checklist inclusion from Phase 3.5 review roster. This is a one-line addition, not a structural change.

**Changes that should NOT cascade:**
- The delegation table (lines 96-187): No changes needed. Delegation routing is task-type-based, not review-roster-based.
- Model selection (lines 396-402): No changes needed unless the issue intends to change model assignments for discretionary reviewers.
- Post-execution phases (lines 672-688): No changes needed. Phase 5, 6, 7, 8 are unchanged.
- Invocation modes (lines 26-44): No changes.
- Task decomposition principles (lines 239-255): No changes.

### Proposed Tasks

**Task 1: Update Phase 3.5 review triggering rules in AGENT.md**
- What: Modify the Architecture Review section (lines 546-614) to split the reviewer roster into ALWAYS (5) and discretionary (6). Add the discretionary selection + user approval gate description. Update software-docs-minion rationale to reflect documentation impact checklist scope.
- Deliverables: Updated AGENT.md Architecture Review section
- Dependencies: None

**Task 2: Update synthesis template in AGENT.md**
- What: Update the `Architecture Review Agents` field in the synthesis output template (line 511) to reflect the new ALWAYS/discretionary split. The template should instruct nefario to list its discretionary picks with rationale.
- Deliverables: Updated synthesis template block in AGENT.md
- Dependencies: Task 1 (must know the final roster to update the template)

**Task 3: Add cross-cutting checklist clarification in AGENT.md**
- What: Add one clarifying sentence after line 272 distinguishing the cross-cutting checklist (planning/execution inclusion) from Phase 3.5 review roster composition. This prevents governance conflict from the ux-strategy-minion demotion.
- Deliverables: One sentence added to AGENT.md cross-cutting concerns section
- Dependencies: None

**Task 4: Update Phase 3.5 in SKILL.md**
- What: Update the "Identify Reviewers" section (SKILL.md lines 606-621) to reflect the new ALWAYS/discretionary split. Add the discretionary approval gate interaction (nefario proposes picks, user approves before spawning). Update the software-docs-minion reviewer prompt to scope it to documentation impact checklist only.
- Deliverables: Updated SKILL.md Phase 3.5 section
- Dependencies: Task 1 (roster definition), must align with #48 approval gate pattern

**Task 5: Update Phase 8 checklist handoff in SKILL.md**
- What: Update Phase 8 (SKILL.md lines 1253-1330) to reference the Phase 3.5 documentation impact checklist as input. Clarify that Phase 8 supplements (not replaces) the 3.5 checklist with execution-discovered items.
- Deliverables: Updated SKILL.md Phase 8 section
- Dependencies: Task 4 (must know the 3.5 checklist format)

**Task 6: Update docs/orchestration.md Phase 3.5 section**
- What: Update the Phase 3.5 section (orchestration.md lines 53-84) to reflect the new roster split, discretionary approval gate, and software-docs-minion role narrowing. Ensure the mermaid diagram still accurately represents the flow (it may need a sub-step for the discretionary approval gate within Phase 3.5).
- Deliverables: Updated orchestration.md
- Dependencies: Tasks 1, 4 (must reflect final design)

### Risks and Concerns

**Risk 1: Phase 3.5 discretionary gate adds a fourth approval gate type.** The system currently has three gate types: Team Approval (Phase 1), Execution Plan Approval (Phase 3.5/4 boundary), and Mid-Execution Gates (Phase 4). Adding a Phase 3.5 reviewer approval gate introduces a fourth. This risks approval fatigue (the anti-fatigue rules target 3-5 gates per plan, but those count mid-execution gates, not structural gates). The new gate should be lightweight -- one-shot approve/adjust, not the full decision brief format. Confirm that the interaction cost is minimal (display discretionary picks inline with rationale, user says "ok" or adjusts).

**Risk 2: Inconsistency with #48 dependency.** The issue states this "depends on #48" because both introduce the "user-approval-before-spawning" pattern. If #48 has not yet landed, the plan must either: (a) land after #48 and reference its pattern, or (b) define the pattern independently and reconcile later. Option (a) is cleaner. Verify #48 status before execution.

**Risk 3: user-docs-minion is in the discretionary pool (per issue success criteria) but is not currently in ANY Phase 3.5 role.** Currently, user-docs-minion does not appear in either the ALWAYS or conditional reviewers for Phase 3.5 (see AGENT.md lines 557-570 and SKILL.md lines 606-621). The issue adds it to the discretionary pool. This is scope expansion -- adding a NEW reviewer to Phase 3.5 that did not previously participate. The issue explicitly lists it in the discretionary pool ("user-docs-minion"), so this is intentional, but it should be flagged as a new capability, not just a reorganization.

**Risk 4: Checklist format mismatch between Phase 3.5 and Phase 8.** Phase 8 currently generates its own checklist from execution outcomes (SKILL.md line 1253). If Phase 3.5 produces a checklist in a different format or with different granularity, Phase 8 may not be able to consume it cleanly. The plan must specify the checklist format explicitly.

**Risk 5: Missing analysis file.** The issue references `nefario/scratch/phase3.5-team-composition-analysis.md` as prior analysis. This file does not exist at that path. Either it was not committed, or the path is wrong. The plan should not depend on this file; all decisions should be traceable to the issue body and the current source files.

### Additional Agents Needed

None. The current planning team is sufficient for this task. The changes are scoped to nefario orchestration artifacts (AGENT.md, SKILL.md, orchestration.md), which are nefario's own domain. Lucy's governance review (this contribution) covers alignment and convention concerns. No domain specialists beyond the planning team are needed because:

- No code is being written (only documentation/specification changes)
- No new agent AGENT.md files are being modified (issue explicitly scopes those out)
- The changes are internal orchestration mechanics, not domain-specific
