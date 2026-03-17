You are contributing to the PLANNING phase of a multi-agent project.
You are NOT executing yet — you are providing your domain expertise
to help build a comprehensive plan.

## Project Task
Research whether and how the despicable-agents orchestrating session can delegate tasks to external LLM coding tools (Cursor, Aider, Codex CLI, etc.) the same way it currently delegates to Claude Code subagents — so that the framework is not locked to a single harness and can route specialist work to the best available tool. The deliverable is a research report under docs/.

## Your Planning Question
MCP provides a standardized protocol for tool invocation across hosts. Could MCP serve as the inter-agent communication layer between the orchestrating session and external coding tools? Assess: (1) Can external coding tools expose or consume MCP interfaces? (2) Is MCP appropriate for long-running coding tasks (vs. short tool calls)? (3) What about A2A (Agent-to-Agent protocol) as an alternative? (4) What protocol-level research should the report cover for result collection back to the orchestrating session? Note: the DX of configuring and invoking the wrapper is covered by devx-minion — focus on the protocol layer (message formats, transport, completion signals, error propagation).

## Context
Read these files for context:
- minions/mcp-minion/AGENT.md (MCP architecture, transport mechanisms)
- docs/orchestration.md (current result flow from subagents to main session)

## Instructions
1. Read relevant files to understand the current state
2. Apply your domain expertise to the planning question
3. Identify risks, dependencies, and requirements from your perspective
4. If you believe additional specialists should be involved that
   aren't already part of the planning, say so and explain why
5. Return your contribution in this format:

## Domain Plan Contribution: mcp-minion

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

6. Write your complete contribution to `/var/folders/3k/bfjvvz9s6dvdn_hvlhvr8lc00000gn/T//nefario-scratch-kifrP8/use-outside-harnesses/phase2-mcp-minion.md`
