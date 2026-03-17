You are contributing to the PLANNING phase of a multi-agent project.
You are NOT executing yet — you are providing your domain expertise
to help build a comprehensive plan.

## Project Task
Research whether and how the despicable-agents orchestrating session can delegate tasks to external LLM coding tools (Cursor, Aider, Codex CLI, etc.) the same way it currently delegates to Claude Code subagents — so that the framework is not locked to a single harness and can route specialist work to the best available tool. The deliverable is a research report under docs/.

## Your Planning Question
What is the current landscape of LLM coding tools that could serve as delegation targets? For each major tool (Cursor, Aider, Codex CLI, Windsurf, Cline, Continue, Copilot CLI, and any emerging tools), assess: (1) CLI/API availability for programmatic invocation (can it be started headless?), (2) context/instruction injection mechanisms (system prompts, project rules, file context), (3) result collection capabilities (structured output, exit codes, file diffs), (4) maturity level (adopt/trial/assess/hold), (5) openness of the instruction format. What tools are feasible delegation targets today vs. which require waiting? Note: security implications of cross-tool trust boundaries and credential sharing are out of scope for this consultation — focus on capability inventory and maturity.

## Context
Read these files for context:
- gru/AGENT.md (technology radar framework)

## Instructions
1. Read relevant files to understand the current state
2. Apply your domain expertise to the planning question
3. Identify risks, dependencies, and requirements from your perspective
4. If you believe additional specialists should be involved that
   aren't already part of the planning, say so and explain why
5. Return your contribution in this format:

## Domain Plan Contribution: gru

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

6. Write your complete contribution to `/var/folders/3k/bfjvvz9s6dvdn_hvlhvr8lc00000gn/T//nefario-scratch-kifrP8/use-outside-harnesses/phase2-gru.md`
