MODE: META-PLAN

You are creating a meta-plan — a plan for who should help plan.

## Task
<github-issue>
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
</github-issue>

## Working Directory
/Users/ben/github/benpeter/2despicable/3

## External Skill Discovery
Before analyzing the task, scan for project-local skills. If skills are
discovered, include an "External Skill Integration" section in your meta-plan
(see your Core Knowledge for the output format).

## Instructions
1. Read relevant files to understand the codebase context
2. Discover external skills:
   a. Scan .claude/skills/ and .skills/ in the working directory for SKILL.md files
   b. Read frontmatter (name, description) for each discovered skill
   c. For skills whose description matches the task domain, classify as
      ORCHESTRATION or LEAF (see External Skill Integration in your Core Knowledge)
   d. Check the project's CLAUDE.md for explicit skill preferences
   e. Include discovered skills in your meta-plan output
3. Analyze the task against your delegation table
4. Identify which specialists should be CONSULTED FOR PLANNING
   (not execution — planning). These are agents whose domain
   expertise is needed to create a good plan.
5. For each specialist, write a specific planning question that
   draws on their unique expertise.
6. Return the meta-plan in the structured format.
7. Write your complete meta-plan to `/var/folders/3k/bfjvvz9s6dvdn_hvlhvr8lc00000gn/T/nefario-scratch-FHCBRb/remove-software-docs-phase35/phase1-metaplan.md`
