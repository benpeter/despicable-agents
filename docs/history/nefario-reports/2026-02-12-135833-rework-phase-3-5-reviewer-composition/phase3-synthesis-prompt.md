MODE: SYNTHESIS

You are synthesizing specialist planning contributions into a
final execution plan.

## Original Task

<github-issue>
**Outcome**: Phase 3.5 Architecture Review uses a smaller mandatory roster (5 ALWAYS) and a discretionary pool (6 conditional reviewers) selected by nefario and approved by the user before spawning. This reduces wasted compute on irrelevant reviews, gives the user control over reviewer composition, and aligns 3.5 with the same approval gate pattern introduced in Phase 2 (#48).

**Success criteria**:
- ALWAYS roster is exactly: security-minion, test-minion, software-docs-minion, lucy, margo
- Discretionary pool is exactly: ux-strategy-minion, ux-design-minion, accessibility-minion, sitespeed-minion, observability-minion, user-docs-minion
- Nefario presents discretionary picks with one-line rationale each; user approves before spawning
- software-docs-minion 3.5 role narrowed to documentation impact checklist (not full review)
- Phase 8 documentation phase consumes the 3.5 checklist as its work order
- test-minion remains ALWAYS with unchanged behavior
- All changes reflected in nefario AGENT.md, SKILL.md, and docs/orchestration.md

**Scope**:
- In: Phase 3.5 reviewer triggering rules, ALWAYS/conditional roster, software-docs-minion 3.5 role, Phase 8 checklist handoff, nefario AGENT.md, SKILL.md, orchestration docs
- Out: Phase 2 approval gate (handled by #48), reviewer agent AGENT.md files, the-plan.md, Phase 5/6 post-execution phases

**Constraints**:
- Depends on #48 (Phase 2 approval gate) — both introduce the same user-approval-before-spawning pattern
- Analysis at nefario/scratch/phase3.5-team-composition-analysis.md
</github-issue>

---
Additional context: use opus for all agents and tasks

## Specialist Contributions

Read the following scratch files for full specialist contributions:
- /var/folders/3k/bfjvvz9s6dvdn_hvlhvr8lc00000gn/T//nefario-scratch-1CcD5T/rework-phase-3-5-reviewer-composition/phase2-ux-strategy-minion.md
- /var/folders/3k/bfjvvz9s6dvdn_hvlhvr8lc00000gn/T//nefario-scratch-1CcD5T/rework-phase-3-5-reviewer-composition/phase2-devx-minion.md
- /var/folders/3k/bfjvvz9s6dvdn_hvlhvr8lc00000gn/T//nefario-scratch-1CcD5T/rework-phase-3-5-reviewer-composition/phase2-lucy.md
- /var/folders/3k/bfjvvz9s6dvdn_hvlhvr8lc00000gn/T//nefario-scratch-1CcD5T/rework-phase-3-5-reviewer-composition/phase2-ai-modeling-minion.md

## Key consensus across specialists:

## Summary: ux-strategy-minion
Phase: planning
Recommendation: Reuse Phase 2 gate pattern with lighter weight (6-10 lines), header "Review" not "Team", "Skip review" not "Reject", mandatory reviewers as flat fact line, plan-grounded rationales max 60 chars.
Tasks: 3 -- Gate UX design for Phase 3.5; software-docs-minion checklist output format; Visual weight hierarchy docs
Risks: Gate echo rubber-stamping (MEDIUM); "Skip review" misuse (LOW)
Conflicts: none

## Summary: devx-minion
Phase: planning
Recommendation: Checklist as single artifact (markdown checkboxes with owner tags, scope, file paths, priority), Phase 8 becomes merge operation supplementing 3.5 checklist with execution outcomes, gate inserts between "Identify Reviewers" and "Spawn Reviewers" with auto-skip when no discretionary triggered.
Tasks: 5 -- SKILL.md Phase 3.5 update; software-docs-minion narrowed prompt; Phase 8 merge logic; AGENT.md update; orchestration.md update
Risks: Checklist staleness if execution deviates (MEDIUM); interaction fatigue from third gate (LOW)
Conflicts: none

## Summary: lucy
Phase: planning
Recommendation: No governance conflict — cross-cutting checklist governs planning (Phases 1-4), Phase 3.5 review has own triggering rules. Add one clarifying sentence to cross-cutting checklist. software-docs-minion narrowing satisfies ALWAYS if Phase 8 consumes checklist. Two small spillovers: synthesis output template and cross-cutting clarification.
Tasks: 4 -- Architecture Review section update; cross-cutting clarification; synthesis output template update; Phase 8 reconciliation
Risks: user-docs-minion is NEW to 3.5 (not reclassified); referenced analysis file doesn't exist; fourth gate type risks approval fatigue
Conflicts: none

## Summary: ai-modeling-minion
Phase: planning
Recommendation: Use heuristic analysis with domain signal table (one signal per discretionary reviewer) rather than hardcoded conditionals. Forced yes/no enumeration with one-line rationale. Reuses Phase 1 meta-plan reasoning pattern. Three gate options: Approve/Adjust/Skip discretionary.
Tasks: 6 -- AGENT.md roster update; AGENT.md synthesis format; SKILL.md Phase 3.5 gate; SKILL.md software-docs prompt; SKILL.md Phase 8 merge; orchestration.md
Risks: Selection quality dependent on plan analysis; rationale quality variable
Conflicts: none

## External Skills Context
No external skills detected relevant to this task. Two discovered (despicable-lab, despicable-statusline) but neither overlaps with the domain.

## Instructions
1. Review all specialist contributions
2. Resolve any conflicts between recommendations
3. Incorporate risks and concerns into the plan
4. Create the final execution plan in structured format
5. Ensure every task has a complete, self-contained prompt
6. All agents and tasks must use model: opus (per user directive)
7. Write your complete delegation plan to `/var/folders/3k/bfjvvz9s6dvdn_hvlhvr8lc00000gn/T//nefario-scratch-1CcD5T/rework-phase-3-5-reviewer-composition/phase3-synthesis.md`
