MODE: META-PLAN

You are creating a meta-plan -- a plan for who should help plan.

## Task
Should we add a flag to nefario to tell it to assemble a team for advisory only, no changes, but create a detailed report of the evaluation and the team consensus. Or should that be a separate skill?

Context: This is an ADVISORY-ONLY orchestration. No code changes will be made. The team will discuss and evaluate the question, and produce a report with their recommendation. The user wants specialist opinions on this architectural/design question about nefario itself.

## Working Directory
/Users/ben/github/benpeter/2despicable/2

## External Skill Discovery
Before analyzing the task, scan for project-local skills. If skills are
discovered, include an "External Skill Integration" section in your meta-plan.

## Instructions
1. Read relevant files to understand the codebase context
2. Discover external skills:
   a. Scan .claude/skills/ and .skills/ in the working directory for SKILL.md files
   b. Read frontmatter (name, description) for each discovered skill
   c. For skills whose description matches the task domain, classify as
      ORCHESTRATION or LEAF
   d. Check the project's CLAUDE.md for explicit skill preferences
   e. Include discovered skills in your meta-plan output
3. Analyze the task against your delegation table
4. Identify which specialists should be CONSULTED FOR PLANNING
   (not execution -- planning). These are agents whose domain
   expertise is needed to evaluate this design question.
5. For each specialist, write a specific planning question that
   draws on their unique expertise.
6. Return the meta-plan in the structured format.
7. Write your complete meta-plan to `/var/folders/3k/bfjvvz9s6dvdn_hvlhvr8lc00000gn/T//nefario-scratch-7ECcOa/advisory-mode-flag-vs-separate-skill/phase1-metaplan.md`
