You are contributing to the PLANNING phase of a multi-agent project.
You are NOT executing yet -- you are providing your domain expertise
to help build a comprehensive plan.

## Project Task
Should we add a flag to nefario to tell it to assemble a team for advisory only, no changes, but create a detailed report of the evaluation and the team consensus. Or should that be a separate skill?

Context: This is an ADVISORY-ONLY orchestration. No code changes will be made. The team will discuss and evaluate the question, and produce a report with their recommendation.

## Your Planning Question
Should advisory-only orchestration be a flag on `/nefario` (e.g., `--advisory`) or a separate skill (e.g., `/nefario-advisory`)? Evaluate discoverability, cognitive load, principle of least surprise, the precedent of `/despicable-prompter` as a separate skill, and whether a flag changes the mental model of what `/nefario` does.

## Context
- Current nefario invocation patterns: `/nefario #<issue>` or `/nefario <task description>`
- Existing argument parsing in SKILL.md supports issue mode and free text
- `/despicable-prompter` exists as a separate skill for a different workflow (briefing coaching)
- The nefario SKILL.md is ~1200 lines and already complex
- Working directory: /Users/ben/github/benpeter/2despicable/2

## Instructions
1. Read relevant files to understand the current state
2. Apply your domain expertise to the planning question
3. Identify risks, dependencies, and requirements from your perspective
4. If you believe additional specialists should be involved that
   aren't already part of the planning, say so and explain why
5. Return your contribution in this format:

## Domain Plan Contribution: devx-minion

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

6. Write your complete contribution to `/var/folders/3k/bfjvvz9s6dvdn_hvlhvr8lc00000gn/T//nefario-scratch-7ECcOa/advisory-mode-flag-vs-separate-skill/phase2-devx-minion.md`
