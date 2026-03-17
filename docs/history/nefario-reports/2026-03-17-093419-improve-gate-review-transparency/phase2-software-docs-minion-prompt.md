You are contributing to the PLANNING phase of a multi-agent project.
You are NOT executing yet — you are providing your domain expertise
to help build a comprehensive plan.

## Advisory Context
This is an advisory-only orchestration. Your contribution will feed
into a team recommendation, not an execution plan. Focus on analysis,
trade-offs, and recommendations rather than implementation tasks.

## Project Task
Improve gate review transparency in the nefario orchestration system so users see decision rationale at gates instead of checking scratch files.

Currently, the nefario approval gates present task lists, agent names, counts, and brief summaries — but NOT the reasoning, trade-offs, rejected alternatives, or conflict resolutions from the specialist team discussions. The user must navigate to scratch files to understand what the team actually discussed. The gates are oriented toward "here's what we'll do" not "here's what we debated and why."

## Your Planning Question
If gate presentations are enriched with decision rationale, how does this affect: (a) the nefario execution report template (TEMPLATE.md), which has "Key Design Decisions" and "Decisions" sections that may overlap with gate content, (b) docs/orchestration.md which describes the gate workflow, and (c) the AGENT.md gate specification sections? Identify which documentation artifacts need updates and whether enriched gates create redundancy with the report format.

Also consider:
- The SKILL.md is the primary artifact that defines gate rendering format
- The AGENT.md defines synthesis output format (what information is available)
- The report template defines post-hoc documentation format
- If gates now show decisions, does the report still need a separate "Key Design Decisions" section, or does it become a compilation of gate decisions?

## Context
Read the following files:
- `/Users/ben/github/benpeter/despicable-agents/skills/nefario/SKILL.md` — the full orchestration workflow including gate formats and report generation
- `/Users/ben/github/benpeter/despicable-agents/nefario/AGENT.md` — nefario system prompt including synthesis output format
- `/Users/ben/github/benpeter/despicable-agents/docs/history/nefario-reports/TEMPLATE.md` — the execution report template
- `/Users/ben/github/benpeter/despicable-agents/docs/orchestration.md` — documentation of the orchestration workflow
- `/Users/ben/github/benpeter/despicable-agents/docs/architecture.md` — hub document for architecture docs

## Instructions
1. Read relevant files to understand the current state
2. Apply your domain expertise to the planning question
3. Identify risks, dependencies, and requirements from your perspective
4. If you believe additional specialists should be involved that
   aren't already part of the planning, say so and explain why
5. Return your contribution in this format:

## Domain Plan Contribution: software-docs-minion

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
6. Write your complete contribution to `/var/folders/3k/bfjvvz9s6dvdn_hvlhvr8lc00000gn/T//nefario-scratch-W8Aayk/improve-gate-review-transparency/phase2-software-docs-minion.md`
