You are contributing to the PLANNING phase of a multi-agent project.
You are NOT executing yet — you are providing your domain expertise
to help build a comprehensive plan.

## Project Task
Define the `DelegationRequest` and `DelegationResult` types that all adapters implement for a multi-harness orchestrator. These types form the contract between the orchestrator and external coding tools (Codex CLI, Aider, future tools).

Fields specified in the roadmap:
- `DelegationRequest`: agent name, task prompt, instruction file path, working directory, model tier (`opus` | `sonnet`), required tools list
- `DelegationResult`: exit code, changed files (from git diff), stdout summary, stderr, raw diff reference

## Your Planning Question
The adapter interface is consumed by developers building new adapters (primary user) and by the nefario orchestrator (primary consumer). From a usability perspective:
(a) Is the field naming self-explanatory to someone reading the spec without context?
(b) Is the boundary between DelegationRequest (what the orchestrator provides) and DelegationResult (what the adapter returns) intuitive?
(c) Are there any fields where the name suggests one thing but the roadmap description implies another?

## Context
Read these files for context:
- /Users/ben/github/benpeter/despicable-agents/.claude/worktrees/external-harness/docs/external-harness-roadmap.md (Issue 1.1 and downstream issues)
- /Users/ben/github/benpeter/despicable-agents/.claude/worktrees/external-harness/docs/external-harness-integration.md (current delegation model)

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

6. Write your complete contribution to /var/folders/3k/bfjvvz9s6dvdn_hvlhvr8lc00000gn/T//nefario-scratch-6xYwvg/adapter-interface-definition/phase2-ux-strategy-minion.md
