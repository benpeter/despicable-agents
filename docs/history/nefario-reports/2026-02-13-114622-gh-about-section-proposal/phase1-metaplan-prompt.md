MODE: META-PLAN

You are creating a meta-plan -- a plan for who should help plan.

## Task

Propose description, website, and topics for the GitHub "About" section of the despicable-agents repo.

Current state: The About section is completely empty (no description, no website URL, no topics).

Repo context:
- Name: despicable-agents
- Owner: benpeter
- URL: https://github.com/benpeter/despicable-agents
- License: Apache 2.0
- Primary language: Shell
- Content: 27 specialist agents for Claude Code, organized as team with orchestrator (nefario), governance (lucy, margo), and 23 domain-specialist minions
- Key features: phased orchestration, research-backed domain experts, built-in governance gates, execution reports
- Built on Claude Code Agent Teams

The GitHub About section has three fields:
1. **Description** -- short text (max ~350 chars) shown below repo name
2. **Website** -- URL shown as link
3. **Topics** -- tags for discoverability (lowercase, hyphenated)

This is an advisory-only orchestration. Focus on analysis, trade-offs, and recommendations.

## Working Directory

/Users/ben/github/benpeter/2despicable/2

## External Skill Discovery

Before analyzing the task, scan for project-local skills in .claude/skills/ and .skills/.

## Instructions

1. Read relevant files to understand the codebase context
2. Discover external skills:
   a. Scan .claude/skills/ and .skills/ in the working directory for SKILL.md files
   b. Read frontmatter (name, description) for each discovered skill
   c. For skills whose description matches the task domain, classify as ORCHESTRATION or LEAF
   d. Check the project's CLAUDE.md for explicit skill preferences
   e. Include discovered skills in your meta-plan output
3. Analyze the task against your delegation table
4. Identify which specialists should be CONSULTED FOR PLANNING (not execution -- planning). These are agents whose domain expertise is needed to create a good recommendation.
5. For each specialist, write a specific planning question that draws on their unique expertise.
6. Return the meta-plan in the structured format.
7. Write your complete meta-plan to /var/folders/3k/bfjvvz9s6dvdn_hvlhvr8lc00000gn/T//nefario-scratch-q2AEa6/gh-about-section-proposal/phase1-metaplan.md
