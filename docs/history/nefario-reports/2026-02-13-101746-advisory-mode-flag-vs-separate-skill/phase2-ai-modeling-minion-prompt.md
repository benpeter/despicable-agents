You are contributing to the PLANNING phase of a multi-agent project.
You are NOT executing yet -- you are providing your domain expertise
to help build a comprehensive plan.

## Project Task
Should we add a flag to nefario to tell it to assemble a team for advisory only, no changes, but create a detailed report of the evaluation and the team consensus. Or should that be a separate skill?

Context: This is an ADVISORY-ONLY orchestration. No code changes will be made. The team will discuss and evaluate the question, and produce a report with their recommendation.

## Your Planning Question
Which of the nine phases apply to advisory mode? Is advisory mode "stop after Phase 3 and format as a report"? Does it need Phase 3.5 review? Should it be a new MODE: ADVISORY or a modification of existing flow? Evaluate whether it is architecturally a mode or a structurally different process.

## Context
- Nefario's nine-phase architecture: Meta-plan -> Specialist Planning -> Synthesis -> Architecture Review -> Execution -> Code Review -> Test Execution -> Deployment -> Documentation
- Current modes: META-PLAN, SYNTHESIS, PLAN
- Advisory would skip Phases 4-8 (no execution, no code review, no tests, no deployment, no docs)
- The question is whether advisory is just "phases 1-3 + report" or something structurally different
- Working directory: /Users/ben/github/benpeter/2despicable/2
- Read the nefario SKILL.md and the-plan.md for full architecture context

## Instructions
1. Read relevant files to understand the current state
2. Apply your domain expertise to the planning question
3. Identify risks, dependencies, and requirements from your perspective
4. If you believe additional specialists should be involved that
   aren't already part of the planning, say so and explain why
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

6. Write your complete contribution to `/var/folders/3k/bfjvvz9s6dvdn_hvlhvr8lc00000gn/T//nefario-scratch-7ECcOa/advisory-mode-flag-vs-separate-skill/phase2-ai-modeling-minion.md`
