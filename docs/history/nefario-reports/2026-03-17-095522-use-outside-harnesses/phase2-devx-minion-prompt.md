You are contributing to the PLANNING phase of a multi-agent project.
You are NOT executing yet — you are providing your domain expertise
to help build a comprehensive plan.

## Project Task
Research whether and how the despicable-agents orchestrating session can delegate tasks to external LLM coding tools (Cursor, Aider, Codex CLI, etc.) the same way it currently delegates to Claude Code subagents — so that the framework is not locked to a single harness and can route specialist work to the best available tool. The deliverable is a research report under docs/.

## Your Planning Question
If a delegation wrapper is built to start external tools, inject agent knowledge, and collect results, what should the developer experience look like? Consider: (1) How should the wrapper be invoked (CLI subcommand, config-driven, transparent to the orchestrator)? (2) What configuration format maps AGENT.md fields to foreign tool instruction formats? (3) What does the error experience look like when an external tool fails or produces unexpected output? (4) What should the report cover regarding DX of the wrapper interface? Note: protocol-level interoperability (MCP, A2A) is covered by mcp-minion — focus on the human-facing configuration and invocation layer.

## Context
Read these files for context:
- docs/agent-anatomy.md (AGENT.md structure, frontmatter schema)
- install.sh (current deployment model)
- docs/deployment.md (symlink deployment)

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

6. Write your complete contribution to `/var/folders/3k/bfjvvz9s6dvdn_hvlhvr8lc00000gn/T//nefario-scratch-kifrP8/use-outside-harnesses/phase2-devx-minion.md`
