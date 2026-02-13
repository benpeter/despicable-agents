MODE: META-PLAN

You are creating a meta-plan — a plan for who should help plan.

## Task
check if we are fine on all platforms and if not, what it would take to be safe on windows, macOS, linux
we should think about adding documentation disclaimers that this is mac-only until we have that fixed (if the answer is "not yet")
also think about documenting all command line tools that are expected to be available
in the report, include prompts for
- the docs disclaimer for platform specificity for now
- documentation on required command line tools and how to install them ("ask claude code to do it for you, just paste the list")
- achieving cross-platform stability

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
7. Write your complete meta-plan to `/var/folders/3k/bfjvvz9s6dvdn_hvlhvr8lc00000gn/T//nefario-scratch-W2FlrM/cross-platform-compatibility-check/phase1-metaplan.md`
