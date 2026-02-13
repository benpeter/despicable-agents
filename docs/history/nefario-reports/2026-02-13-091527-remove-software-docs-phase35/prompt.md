**Outcome**: Phase 3.5 Architecture Review drops from 6 to 5 mandatory reviewers by removing software-docs-minion, and Phase 8 (Documentation) self-derives its work order from the synthesis plan and execution outcomes instead of merging two sources. This eliminates one agent call per orchestration and removes divergence-flagging complexity from Phase 8 — without risk, since missed docs notes are cheap to fix post-execution.

**Success criteria**:
- ALWAYS reviewers list is: security-minion, test-minion, ux-strategy-minion, lucy, margo
- software-docs-minion no longer runs during Phase 3.5
- Phase 3.5 no longer produces phase3.5-docs-checklist.md
- Phase 8 derives its checklist solely from synthesis plan + execution outcomes
- Phase 8 assigns owner tags and priority itself (single-source, no divergence flagging)
- software-docs-minion custom Phase 3.5 prompt removed from SKILL.md
- user-docs-minion remains in the discretionary Phase 3.5 reviewer pool (unchanged)
- Cross-cutting checklist "Documentation (ALWAYS)" item in Phase 1 remains (unchanged)
- All artifacts updated: the-plan.md, nefario AGENT.md, nefario SKILL.md, docs/orchestration.md
- the-plan.md changes pass the gate (see Constraints)

**Scope**:
- In: Phase 3.5 reviewer list (the-plan.md, SKILL.md, AGENT.md, docs/orchestration.md), software-docs-minion Phase 3.5 prompt, Phase 8 checklist derivation logic, scratch directory structure docs
- Out: Phase 8 sub-steps (8a, 8b) and agent spawning logic, user-docs-minion discretionary role, Phase 1 cross-cutting checklist, software-docs-minion's own agent definition

**Constraints**:
- Use opus for all agents
- Human owner approves modification of the-plan.md for this task (CLAUDE.md override)
- the-plan.md gate: before committing changes to the-plan.md, present a diff summary to the user for explicit approval. Only the Phase 3.5 reviewer list and Phase 8 checklist derivation sections may be touched — any unrelated changes are grounds for rejection
