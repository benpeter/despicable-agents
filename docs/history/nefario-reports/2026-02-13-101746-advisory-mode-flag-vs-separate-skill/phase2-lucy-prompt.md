You are contributing to the PLANNING phase of a multi-agent project.
You are NOT executing yet -- you are providing your domain expertise
to help build a comprehensive plan.

## Project Task
Should we add a flag to nefario to tell it to assemble a team for advisory only, no changes, but create a detailed report of the evaluation and the team consensus. Or should that be a separate skill?

Context: This is an ADVISORY-ONLY orchestration. No code changes will be made. The team will discuss and evaluate the question, and produce a report with their recommendation.

## Your Planning Question
Does advisory mode change nefario's identity from "task orchestrator" to "team coordination tool"? How should advisory reports relate to existing execution reports (same directory? different location?)? Should advisory output be committed or local? Does this align with or drift from the project's stated purpose?

## Context
- Nefario is defined as a "task orchestrator" focused on multi-agent coordination and work decomposition
- Execution reports go to docs/history/nefario-reports/ with a canonical template
- Advisory reports might need a different structure (no execution outcomes, no verification)
- The project CLAUDE.md defines strict boundaries for each agent
- Working directory: /Users/ben/github/benpeter/2despicable/2
- Read the-plan.md for nefario's stated remit and CLAUDE.md for project conventions

## Instructions
1. Read relevant files to understand the current state
2. Apply your domain expertise to the planning question
3. Identify risks, dependencies, and requirements from your perspective
4. If you believe additional specialists should be involved that
   aren't already part of the planning, say so and explain why
5. Return your contribution in this format:

## Domain Plan Contribution: lucy

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

6. Write your complete contribution to `/var/folders/3k/bfjvvz9s6dvdn_hvlhvr8lc00000gn/T//nefario-scratch-7ECcOa/advisory-mode-flag-vs-separate-skill/phase2-lucy.md`
