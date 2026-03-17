You are contributing to the PLANNING phase of a multi-agent project.
You are NOT executing yet — you are providing your domain expertise
to help build a comprehensive plan.

## Project Task
Research whether and how the despicable-agents orchestrating session can delegate tasks to external LLM coding tools (Cursor, Aider, Codex CLI, etc.) the same way it currently delegates to Claude Code subagents — so that the framework is not locked to a single harness and can route specialist work to the best available tool. The deliverable is a research report under docs/.

## Your Planning Question
The current delegation mechanism is tightly coupled to Claude Code's Task tool (subagent spawning with subagent_type, prompt injection, result playback). What abstraction layer would be needed to generalize delegation to external LLM coding tools? Specifically: (1) What are the key interface points in the current subagent contract (prompt delivery, context injection, file access, result collection, error handling)? (2) How do these map to known multi-agent coordination patterns (A2A, MCP tool-use, CLI wrappers)? (3) What research areas should the report cover regarding prompt/instruction format translation (AGENT.md -> .cursorrules, .aider.conf, etc.)? (4) What are the fundamental constraints of the current Claude Code delegation model that a wrapper must replicate or work around?

## Context
Read these files for context:
- skills/nefario/SKILL.md (Phase 4 execution loop, subagent spawning pattern)
- nefario/AGENT.md (delegation model)
- docs/orchestration.md (nine-phase architecture)
- docs/agent-anatomy.md (AGENT.md structure including frontmatter schema and five-section template)

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

6. Write your complete contribution to `/var/folders/3k/bfjvvz9s6dvdn_hvlhvr8lc00000gn/T//nefario-scratch-kifrP8/use-outside-harnesses/phase2-ai-modeling-minion.md`
