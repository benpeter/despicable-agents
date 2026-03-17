You are contributing to the PLANNING phase of a multi-agent project.
You are NOT executing yet — you are providing your domain expertise
to help build a comprehensive plan.

## Project Task
Research whether and how the despicable-agents orchestrating session can delegate tasks to external LLM coding tools (Cursor, Aider, Codex CLI, etc.) the same way it currently delegates to Claude Code subagents — so that the framework is not locked to a single harness and can route specialist work to the best available tool. The deliverable is a research report under docs/.

## Your Planning Question
Review the task description and success criteria against the planned research scope. Specifically: (1) Does the research plan fully cover all six success criteria from the issue (tool inventory, AGENT.md mapping, feasibility assessment, gap analysis, recommendation, docs placement)? (2) Are there signs of scope drift — areas where the planning team might over-invest in implementation detail, tool advocacy, or architectural proposals beyond what the issue asks for (a research report, not a design doc)? (3) The research must stay tool-neutral and vendor-neutral (Apache 2.0 publishable). What conventions from the project's CLAUDE.md and existing docs should the research report respect? (4) Are the boundaries between in-scope (research) and out-of-scope (implementation, orchestrator changes) sufficiently clear in the planning questions to prevent drift during execution?

## Context
Read these files for context:
- CLAUDE.md (project rules including publishability constraints)
- docs/architecture.md (design philosophy)
- The other five planning questions are assigned to: ai-modeling-minion (delegation abstraction), gru (tool landscape), devx-minion (wrapper DX), mcp-minion (protocol layer), software-docs-minion (report structure)

The six success criteria from the issue:
1. Inventory of LLM coding tools and their context-injection mechanisms
2. Analysis of how AGENT.md knowledge maps to each tool's instruction format
3. Feasibility assessment: can a delegation wrapper start an external tool, inject agent knowledge, and collect results
4. Gap analysis: what the current Agent tool provides vs. what a wrapper can replicate
5. Clear recommendation: feasible now / feasible with constraints / not yet feasible
6. Research written to a new doc under docs/

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

6. Write your complete contribution to `/var/folders/3k/bfjvvz9s6dvdn_hvlhvr8lc00000gn/T//nefario-scratch-kifrP8/use-outside-harnesses/phase2-lucy.md`
