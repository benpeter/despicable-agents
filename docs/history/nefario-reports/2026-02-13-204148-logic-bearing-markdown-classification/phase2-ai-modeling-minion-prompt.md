You are contributing to the PLANNING phase of a multi-agent project.
You are NOT executing yet -- you are providing your domain expertise to help build a comprehensive plan.

## Project Task

Nefario misclassifies logic-bearing markdown files (phase-skipping and team assembly).

Nefario's orchestration currently treats all .md files as "documentation." This causes two problems:
1. Phase-skipping: Phase 5 code review is skipped for changes to AGENT.md, SKILL.md, RESEARCH.md because they are classified as "docs-only"
2. Team assembly: ai-modeling-minion is not included in Phase 1 team assembly when the task involves modifying agent system prompts or orchestration rules in .md files

The fix must:
- Define a classification boundary between "logic-bearing markdown" and "documentation-only markdown"
- Fix the Phase 5 skip conditional in skills/nefario/SKILL.md
- Fix the Phase 1 team assembly logic in nefario/AGENT.md
- Document the boundary for future contributors

## Your Planning Question

This project defines its agent system through markdown files (AGENT.md = system prompts, SKILL.md = orchestration rules, RESEARCH.md = domain knowledge). The orchestrator currently misclassifies these as "docs" during phase-skipping and team assembly. From your perspective as a prompt engineering and multi-agent architecture specialist:

1. What criteria distinguish "logic-bearing markdown" (system prompts, orchestration rules, agent definitions) from "documentation markdown" (README, user guides, changelogs)? Propose a classification that is clear enough for an LLM reading it as a system prompt instruction to apply consistently.

2. Should the classification be based on file naming conventions (AGENT.md, SKILL.md), directory location (agent directories), content heuristics (presence of structured sections like "Identity", "Working Patterns"), or a combination? Consider that future contributors may add new logic-bearing file types.

3. When the orchestrator decides which specialists to consult for a task, what signals should trigger ai-modeling-minion inclusion beyond the current delegation table entries? Specifically, how should the delegation table or task decomposition principles be amended to capture the "modifying agent definitions = prompt engineering work" mapping?

4. Are there edge cases where a file could be both (e.g., RESEARCH.md that informs a prompt but is also human-readable documentation)? How should edge cases be resolved -- in favor of "logic-bearing" (conservative, ensures review) or "documentation" (permissive, avoids unnecessary review)?

Note: lucy will separately assess whether the classification aligns with stated project conventions and the issue's intent. Focus your contribution on the domain-expert view of what makes something "prompt engineering work" vs "documentation."

## Context

Read these files to understand the codebase:
- nefario/AGENT.md -- delegation table (lines 106-198), task decomposition principles
- skills/nefario/SKILL.md -- Phase 5 skip conditional (lines 1638-1710)
- minions/ai-modeling-minion/AGENT.md -- your own scope definition

## Instructions
1. Read relevant files to understand the current state
2. Apply your domain expertise to the planning question
3. Identify risks, dependencies, and requirements from your perspective
4. If you believe additional specialists should be involved that aren't already part of the planning, say so and explain why
5. Return your contribution in this format:

## Domain Plan Contribution: ai-modeling-minion

### Recommendations
<your expert recommendations for this aspect of the task>

### Proposed Tasks
<specific tasks that should be in the execution plan>
For each task: what to do, deliverables, dependencies

### Risks and Concerns
<things that could go wrong from your domain perspective>

### Additional Agents Needed
<any specialists not yet involved who should be, and why>
(or "None" if the current team is sufficient)

6. Write your complete contribution to /var/folders/3k/bfjvvz9s6dvdn_hvlhvr8lc00000gn/T/nefario-scratch-MpyVGO/logic-bearing-markdown-classification/phase2-ai-modeling-minion.md
