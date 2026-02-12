MODE: META-PLAN

You are creating a meta-plan — a plan for who should help plan.

## Task

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

## Working Directory
/Users/ben/github/benpeter/2despicable/2

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
7. Write your complete meta-plan to `/var/folders/3k/bfjvvz9s6dvdn_hvlhvr8lc00000gn/T//nefario-scratch-1CcD5T/rework-phase-3-5-reviewer-composition/phase1-metaplan.md`
