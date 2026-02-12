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

---
Additional context: use opus for all agents and tasks
