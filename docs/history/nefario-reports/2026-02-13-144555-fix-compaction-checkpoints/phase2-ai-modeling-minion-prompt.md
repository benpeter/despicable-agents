You are contributing to the PLANNING phase of a multi-agent project.
You are NOT executing yet — you are providing your domain expertise
to help build a comprehensive plan.

## Project Task

Issue #87: Fix compaction checkpoints in the nefario orchestration skill.

The nefario orchestration skill manages multi-agent workflows across 9 phases. After Phase 3 (synthesis) and Phase 3.5 (architecture review), there are "compaction checkpoints" that suggest the user run `/compact` to reduce context window pressure before continuing. Currently these are non-functional blockquotes that flash by without pausing.

The proposed fix replaces them with AskUserQuestion gates that pause execution and offer clipboard copy of the /compact command.

## Your Planning Question

The compaction checkpoint is designed to manage context window pressure during multi-agent orchestration. From an LLM context management perspective:
1. Is the current approach (user-triggered /compact with a focus string) optimal for preserving orchestration state?
2. Should the focus string content be dynamically composed based on what's actually in context at that point, or is a static template sufficient?
3. How should the checkpoint interact with Claude Code's auto-compaction behavior? If auto-compaction fires during Phase 4, what orchestration state is at risk?
4. Are there better strategies for ensuring critical orchestration state survives compaction (e.g., writing state to disk before compaction)?

## Context

The SKILL.md already uses scratch files (`$SCRATCH_DIR/{slug}/`) to persist phase outputs to disk. Inline summaries (~80-120 tokens each) are kept in session context for quick reference. The focus string tells /compact what to preserve vs discard.

Current Phase 3 focus string:
```
Preserve: current phase (3.5 review next), synthesized execution plan, inline agent summaries, task list, approval gates, team name, branch name, $summary, scratch directory path. Discard: individual specialist contributions from Phase 2.
```

The SKILL.md is at `/Users/ben/github/benpeter/2despicable/3/skills/nefario/SKILL.md`.

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

6. Write your complete contribution to `/var/folders/3k/bfjvvz9s6dvdn_hvlhvr8lc00000gn/T//nefario-scratch-PKILQw/fix-compaction-checkpoints/phase2-ai-modeling-minion.md`
