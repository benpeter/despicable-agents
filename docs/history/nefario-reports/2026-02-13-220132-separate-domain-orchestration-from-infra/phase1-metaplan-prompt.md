MODE: META-PLAN

You are creating a meta-plan -- a plan for who should help plan.

## Task

<github-issue>
Outcome: A user forking despicable-agents for a non-software domain (e.g., regulatory compliance validation, corpus linguistics) can identify and replace only the domain-specific parts -- agent roster, phase definitions, gate/approval semantics, coordination patterns -- without needing to understand or modify the domain-independent infrastructure (skill discovery, tool plumbing, team mechanics, report generation). This makes the system a reusable orchestration framework rather than a software-development-specific tool.

Success criteria:
- Clear boundary exists between domain-specific configuration (agents, phases, gates, coordination semantics) and domain-independent infrastructure (skill mechanics, subagent spawning, message delivery, report format)
- A hypothetical domain adapter can define its own phase sequence, gate criteria, and agent roster without editing infrastructure files
- Documentation explains what a domain adapter must provide vs. what the framework handles
- Existing software-development behavior is preserved -- current agents and orchestration work identically after the separation

Scope:
- In: nefario SKILL.md orchestration logic, phase/gate definitions, agent roster selection, approval semantics, documentation of the separation boundary
- Out: Actually building non-software-domain agent sets (IVDR, linguistics, etc.), changing the agent file format (AGENT.md structure), modifying Claude Code platform integration

Constraints:
- Do not narrow or dismiss this work as YAGNI. The separation is a deliberate architectural investment in reusability, not speculative feature-building. The goal is making existing structure explicit and swappable, not adding new capabilities.
</github-issue>

## Working Directory
/Users/ben/github/benpeter/2despicable/3

## Pre-Selected Team
The user has pre-selected the following specialists for planning:
- ai-modeling-minion
- lucy
- margo
- devx-minion

Generate planning questions for EXACTLY these 4 specialists. Do not add or remove agents from this list.

## External Skill Discovery
Before analyzing the task, scan for project-local skills. If skills are discovered, include an "External Skill Integration" section in your meta-plan.

## Instructions
1. Read relevant files to understand the codebase context
2. Discover external skills:
   a. Scan .claude/skills/ and .skills/ in the working directory for SKILL.md files
   b. Read frontmatter (name, description) for each discovered skill
   c. For skills whose description matches the task domain, classify as ORCHESTRATION or LEAF
   d. Check the project's CLAUDE.md for explicit skill preferences
   e. Include discovered skills in your meta-plan output
3. Analyze the task against your delegation table
4. For each of the 4 pre-selected specialists, write a specific planning question that draws on their unique expertise
5. Return the meta-plan in the structured format
6. Write your complete meta-plan to /var/folders/3k/bfjvvz9s6dvdn_hvlhvr8lc00000gn/T//nefario-scratch-dV7OFI/separate-domain-orchestration-from-infra/phase1-metaplan.md
