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
Nefario's synthesis phase produces conflict resolutions, rationale, and rejected alternatives — but this information is structured for the delegation plan, not for user-facing gate presentation. What changes are needed to the synthesis output format (AGENT.md) and the SKILL.md gate presentation logic so that decision rationale flows from synthesis through to the gate? Should synthesis produce a separate "decisions summary" block? Should CONDENSE lines preserve decision rationale? How should reviewer verdicts feed into the gate's decision context? The goal: the calling session has the information it needs to populate a richer gate without re-reading scratch files.

Also consider: context window pressure. The inline summary template is ~80-120 tokens per agent. If we add decision rationale to inline summaries, they grow. Compaction checkpoints exist after Phase 3 and Phase 3.5. How do we ensure decision data survives compaction?

## Context
Read the following files to understand the data flow:
- `/Users/ben/github/benpeter/despicable-agents/skills/nefario/SKILL.md` — the full orchestration workflow, especially Phase 3 Synthesis, Inline Summary Template, Compaction Checkpoints, and Execution Plan Approval Gate
- `/Users/ben/github/benpeter/despicable-agents/nefario/AGENT.md` — nefario's system prompt including synthesis output format
- `/Users/ben/github/benpeter/web-resource-ledger/docs/evolution/0025-rfc3161-timestamps/decisions.md` — target quality for decision self-containment
- `/Users/ben/github/benpeter/web-resource-ledger/docs/evolution/0030-tsa-error-logging/process.md` — example showing how specialist positions are narrated

Current data flow:
1. Phase 2 specialists write full contributions to scratch files
2. Inline summaries (~80-120 tokens) are recorded in session context
3. Phase 3 synthesis reads scratch files + inline summaries, writes delegation plan to scratch
4. Compaction checkpoint after Phase 3 (discards specialist contributions)
5. Phase 3.5 reviewers read delegation plan from scratch, write verdicts to scratch
6. Compaction checkpoint after Phase 3.5 (discards review verdicts)
7. Execution Plan Approval Gate reads task list + advisory summaries from session context
8. Gate presents tasks, advisories, review summary — but NOT conflict resolutions or design decisions

The gap: steps 7-8 have access to task lists and advisory counts but not to the reasoning behind design choices.

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
6. Write your complete contribution to `/var/folders/3k/bfjvvz9s6dvdn_hvlhvr8lc00000gn/T//nefario-scratch-W8Aayk/improve-gate-review-transparency/phase2-ai-modeling-minion.md`
