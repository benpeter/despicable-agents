MODE: META-PLAN

You are creating a meta-plan — a plan for who should help plan.

## Task

<github-issue>

**Outcome**: All documentation files are consistent with the rewritten README.md. No stale reviewer counts, no orphaned references, no terminology drift.

**Context**: The README was rewritten in PR #58. A Phase 8 audit identified inconsistencies in docs/ files that were out of scope for the README rewrite. This task addresses those findings.

**Success criteria**:
- All four MUST findings in decisions.md are resolved
- Both SHOULD findings are evaluated and addressed if warranted
- No new inconsistencies introduced
- ADR immutability respected (historical decisions get addendum notes, not rewrites)

**Scope**:
- In: docs/decisions.md, docs/orchestration.md, docs/architecture.md
- Out: README.md (already done), the-plan.md, AGENT.md files, skills/

**Findings to address**:

### MUST Fix (all in decisions.md)

1. **Decision 10 (line ~128)**: States "Six ALWAYS reviewers (security-minion, test-minion, ux-strategy-minion, software-docs-minion, lucy, margo)". ux-strategy-minion is now discretionary, not ALWAYS. Add an addendum note cross-referencing the rework decision.

2. **Decision 12 Consequences (line ~153)**: States "6 ALWAYS reviewers (expanded from 4 with lucy and margo in v1.5)". Now stale -- count is 5. Add addendum note.

3. **Decision 15 Consequences (line ~191)**: States "Every /nefario run incurs review cost (6 ALWAYS + 0-4 conditional reviewers)". This describes current behavior and is factually wrong. Update to "5 ALWAYS + 0-6 discretionary reviewers".

4. **Decision 20 Consequences (line ~262)**: States "Phase 3.5 minimum review cost increases (6 ALWAYS reviewers)". Add addendum note with corrected count.

### SHOULD Fix

5. **"Six cross-cutting dimensions" (orchestration.md lines 20, 44, 334; architecture.md line 113)**: Technically correct (the checklist HAS six dimensions, distinct from five reviewers). But the word "six" near reviewer discussions causes confusion. Consider adding a parenthetical clarification.

6. **"Six domain groups" (orchestration.md line ~318)**: States "all six domain groups" but the agent roster shows seven groups. Verify correct count against the-plan.md and fix if it's a pre-existing error.

</github-issue>

---
Additional context: The user wants user-docs-minion, software-docs-minion, and product-marketing-minion included in the specialist roster. All approvals are pre-given. Skip test and security post-exec phases.

## Working Directory
/Users/ben/github/benpeter/2despicable/2

## External Skill Discovery
Before analyzing the task, scan for project-local skills. If skills are discovered, include an "External Skill Integration" section in your meta-plan (see your Core Knowledge for the output format).

## Instructions
1. Read relevant files to understand the codebase context
2. Discover external skills:
   a. Scan .claude/skills/ and .skills/ in the working directory for SKILL.md files
   b. Read frontmatter (name, description) for each discovered skill
   c. For skills whose description matches the task domain, classify as ORCHESTRATION or LEAF (see External Skill Integration in your Core Knowledge)
   d. Check the project's CLAUDE.md for explicit skill preferences
   e. Include discovered skills in your meta-plan output
3. Analyze the task against your delegation table
4. Identify which specialists should be CONSULTED FOR PLANNING (not execution — planning). These are agents whose domain expertise is needed to create a good plan.
5. For each specialist, write a specific planning question that draws on their unique expertise.
6. Return the meta-plan in the structured format.
7. Write your complete meta-plan to `/var/folders/3k/bfjvvz9s6dvdn_hvlhvr8lc00000gn/T//nefario-scratch-T1yIjX/align-docs-with-readme/phase1-metaplan.md`
