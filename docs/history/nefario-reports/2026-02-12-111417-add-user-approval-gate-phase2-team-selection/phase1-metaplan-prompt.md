MODE: META-PLAN

You are creating a meta-plan — a plan for who should help plan.

## Task

<github-issue>
**Outcome**: Before nefario dispatches specialists for planning, the user sees which agents were selected and can approve, adjust, or veto the team composition. This prevents wasted compute on specialists the user considers irrelevant and gives the user visibility into orchestration decisions early.

**Success criteria**:
- After Phase 2 team selection, nefario presents the chosen specialists with rationale before proceeding
- User can approve the team as-is, remove specialists, or add specialists not initially selected
- Phase 2 does not proceed to specialist dispatch until the user confirms
- Existing Phase 3.5 architecture review gate continues to work unchanged

**Scope**:
- In: Nefario SKILL.md orchestration flow, Phase 2 team selection logic, approval gate UX
- Out: Phase 3.5 review gate changes, agent AGENT.md files, the-plan.md, adding new agents
</github-issue>

## Working Directory
/Users/ben/github/benpeter/despicable-agents

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
7. Write your complete meta-plan to `/var/folders/3k/bfjvvz9s6dvdn_hvlhvr8lc00000gn/T//nefario-scratch-ymv695/add-user-approval-gate-phase2-team-selection/phase1-metaplan.md`
