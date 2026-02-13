You are contributing to the PLANNING phase of a multi-agent project.
You are NOT executing yet -- you are providing your domain expertise to help build a comprehensive plan.

## Project Task

Two GitHub issues to implement together, both targeting `skills/nefario/SKILL.md`:

### Issue #112: embed context usage in compaction AskUserQuestion gates
Parse `<system_warning>` Token usage (format: `Token usage: {used}/{total}; {remaining} remaining`) and embed context percentage in the AskUserQuestion question text at compaction checkpoints.

### Issue #110: add pbcopy clipboard support to compaction checkpoints
Add `pbcopy` to copy the `/compact` command to clipboard at compaction gates.

## Your Planning Question

Issue #112 requires parsing the `<system_warning>` token usage attachment (format: `Token usage: {used}/{total}; {remaining} remaining`) to extract context percentage. This attachment is injected by Claude Code after tool calls. What is the most robust way to instruct an agent (in a SKILL.md spec) to parse this data? Should the spec instruct the agent to look backward in its own context for the most recent `<system_warning>`, or make a lightweight tool call first to trigger a fresh warning? What graceful degradation should apply if the warning format changes or is absent? Note the issue's research found this is the only runtime-accessible source of context usage data.

## Context

Read `skills/nefario/SKILL.md` for the current compaction checkpoint implementations. The `<system_warning>` format is: `Token usage: {used}/{total}; {remaining} remaining`

## Instructions
1. Read relevant files to understand the current state
2. Apply your domain expertise to the planning question
3. Identify risks, dependencies, and requirements from your perspective
4. Return your contribution in the structured format
5. Write your complete contribution to /var/folders/3k/bfjvvz9s6dvdn_hvlhvr8lc00000gn/T//nefario-scratch-2d9adF/compaction-gate-context-clipboard/phase2-observability-minion.md
