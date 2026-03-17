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

A reference format exists in the web-resource-ledger project's evolution log (../web-resource-ledger/docs/evolution/), where each phase produces:
- `decisions.md` — structured decisions with Decision/Alternatives/Rationale/Resolution
- `process.md` — narrative of specialist arguments, disagreements, resolutions, human interventions

Each decision in that format is self-contained: you can read any single decision and understand what was chosen, what was rejected, and why. The goal is to bring this quality of information INTO the gates themselves.

## Your Planning Question
The Execution Plan Approval Gate currently presents 25-40 lines of task list, advisories, and review summary. The user also needs to see: (a) key design decisions from synthesis (conflict resolutions, rejected alternatives), (b) specialist disagreements that shaped the plan, and (c) enough context to make a meaningful approve/reject decision. How should this additional information be layered into the gate without overwhelming the user? Consider progressive disclosure depth, what belongs in the gate vs. linked detail, cognitive load at the decision point, and the difference between "scanning for anomalies" and "understanding rationale." Reference the WRL `decisions.md` format as a target for decision self-containment.

## Context
Read the following files to understand current gate formats and reference materials:
- `/Users/ben/github/benpeter/despicable-agents/skills/nefario/SKILL.md` — current gate format specs (search for "Execution Plan Approval Gate", "Team Approval Gate", "Reviewer Approval Gate", and the Phase 4 mid-execution gate format)
- `/Users/ben/github/benpeter/despicable-agents/nefario/AGENT.md` — nefario's core knowledge including gate classification
- `/Users/ben/github/benpeter/web-resource-ledger/docs/evolution/0025-rfc3161-timestamps/decisions.md` — example of self-contained decision format
- `/Users/ben/github/benpeter/web-resource-ledger/docs/evolution/0030-tsa-error-logging/decisions.md` — another decisions.md example
- `/Users/ben/github/benpeter/web-resource-ledger/docs/evolution/0025-rfc3161-timestamps/process.md` — example of process narrative showing specialist arguments

The current gate line budgets:
- Mid-execution gates: 12-18 lines (soft ceiling)
- Execution Plan Approval Gate: 25-40 lines (soft guidance)
- Team Approval Gate: 8-12 lines
- Reviewer Approval Gate: 6-10 lines

## Instructions
1. Read relevant files to understand the current state
2. Apply your domain expertise to the planning question
3. Identify risks, dependencies, and requirements from your perspective
4. If you believe additional specialists should be involved that
   aren't already part of the planning, say so and explain why
5. Return your contribution in this format:

## Domain Plan Contribution: ux-strategy-minion

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
6. Write your complete contribution to `/var/folders/3k/bfjvvz9s6dvdn_hvlhvr8lc00000gn/T//nefario-scratch-W8Aayk/improve-gate-review-transparency/phase2-ux-strategy-minion.md`
