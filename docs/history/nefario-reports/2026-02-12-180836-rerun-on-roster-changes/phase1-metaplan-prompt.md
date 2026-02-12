MODE: META-PLAN

You are creating a meta-plan — a plan for who should help plan.

## Task

<github-issue>
**Outcome**: When a user adjusts team composition at either the Team Approval Gate or the Reviewer Approval Gate (Phase 3.5), substantial roster changes trigger a re-run of the relevant planning phase so that questions and review coverage reflect the updated composition. At the Team Approval Gate, substantial specialist changes re-run the meta-plan to produce planning questions matching the revised team's domain coverage. At the Reviewer Approval Gate, substantial reviewer changes re-run reviewer identification so that discretionary rationales and domain signals align with the actual reviewer set. This prevents shallow inference from missing important cross-domain interactions that the original planning would have surfaced with the revised composition.

**Success criteria**:
- Team Approval Gate "Adjust team" flow offers a meta-plan re-run path (not just lightweight question generation)
- Reviewer Approval Gate "Adjust reviewers" flow offers a reviewer re-identification path when changes are substantial
- Minor adjustments (1-2 agents changed) still use the fast lightweight path by default at both gates
- Substantial adjustments (3+ agents changed) default to or recommend re-run at both gates
- Re-runs produce output with the same depth as the original phase
- No additional approval gates introduced (re-runs feed back into the existing gate)

**Scope**:
- In: Team Approval Gate "Adjust team" handling in SKILL.md, Reviewer Approval Gate "Adjust reviewers" handling in SKILL.md, nefario AGENT.md if meta-plan mode needs changes
- Out: Phase 2/3 specialist logic, Phase 5 code review, other approval gates, nefario core orchestration flow
</github-issue>

---
Additional context: use opus for everything and make sure the ai-modeling-minion is part of the planning and architecture review teams

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
7. Write your complete meta-plan to /var/folders/3k/bfjvvz9s6dvdn_hvlhvr8lc00000gn/T//nefario-scratch-mhoPIa/rerun-on-roster-changes/phase1-metaplan.md
