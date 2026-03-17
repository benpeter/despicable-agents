You are contributing to the PLANNING phase of a multi-agent project.
You are NOT executing yet — you are providing your domain expertise
to help build a comprehensive plan.

## Project Task
Define the `DelegationRequest` and `DelegationResult` types that all adapters implement for the nefario orchestrator's multi-harness delegation.

## Your Planning Question
The `DelegationRequest` and `DelegationResult` types will be consumed by: (1) the nefario orchestrator during Phase 4 execution routing, (2) the Codex CLI adapter (Issue 2.1), (3) the Aider adapter (Issue 3.2), (4) the result summarization service (Issue 3.1), and (5) the routing config loader (Issue 1.2). From the orchestrator and multi-agent architecture perspective:
(a) What fields does the orchestrator actually need from `DelegationResult` to make routing and gating decisions?
(b) Does the orchestrator need to distinguish between "task completed with wrong output" vs "adapter crashed"?
(c) Should the prompt in `DelegationRequest` be the raw specialist prompt or should it include metadata about which phase/gate the task belongs to?
(d) Is there any information the orchestrator currently extracts from TaskUpdate/SendMessage that would be lost if not captured in these types?

## Context
Read these files for context:
- /Users/ben/github/benpeter/despicable-agents/.claude/worktrees/external-harness/nefario/AGENT.md (Phase 4 execution patterns, TaskList polling, SendMessage result collection)
- /Users/ben/github/benpeter/despicable-agents/.claude/worktrees/external-harness/docs/external-harness-integration.md (current delegation model table, gap analysis)
- /Users/ben/github/benpeter/despicable-agents/.claude/worktrees/external-harness/docs/external-harness-roadmap.md (downstream consumer context)

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

6. Write your complete contribution to /var/folders/3k/bfjvvz9s6dvdn_hvlhvr8lc00000gn/T//nefario-scratch-6xYwvg/adapter-interface-definition/phase2-ai-modeling-minion.md
