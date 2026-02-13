You are contributing to the PLANNING phase of a multi-agent project.
You are NOT executing yet -- you are providing your domain expertise to help build a comprehensive plan.

## Project Task

Two GitHub issues to implement together, both targeting `skills/nefario/SKILL.md`:

### Issue #112: embed context usage in compaction AskUserQuestion gates
When AskUserQuestion fires at compaction checkpoints, it occludes the status line. The user can't see context usage percentage. Solution: parse `<system_warning>` Token usage (format: `Token usage: {used}/{total}; {remaining} remaining`) and embed context percentage in the AskUserQuestion question text.

### Issue #110: add pbcopy clipboard support to compaction checkpoints
Add `pbcopy` clipboard copy to both compaction checkpoint gates so the `/compact` command is on the clipboard when the gate fires. Mac-only acceptable. Keep printed code block as visible fallback.

Both changes target the same two sections in `skills/nefario/SKILL.md` -- the Compaction Checkpoint after Phase 3 (around line 796) and after Phase 3.5 (around line 1208).

## Your Planning Question

The compaction gates need two additions: (a) a context usage line like `[Context: 72% used -- 56k tokens remaining]` embedded in the AskUserQuestion question text, and (b) a `pbcopy` call that pre-loads the `/compact` command onto the clipboard before the gate fires. Given that AskUserQuestion occludes the status line and the user needs context info to decide, what is the best placement and formatting of the context percentage within the question text? Should it go before the existing question, after it, or replace part of it? Should the pbcopy be a silent Bash call before the AskUserQuestion, or should its success/failure be surfaced? Consider that the printed code block remains as fallback.

## Context

Read `skills/nefario/SKILL.md` lines 796-828 (Phase 3 compaction) and lines 1208-1240 (Phase 3.5 compaction) for the current gate implementations. Also read the AskUserQuestion conventions (header max 12 chars, question format, options format).

## Instructions
1. Read relevant files to understand the current state
2. Apply your domain expertise to the planning question
3. Identify risks, dependencies, and requirements from your perspective
4. Return your contribution in the structured format
5. Write your complete contribution to /var/folders/3k/bfjvvz9s6dvdn_hvlhvr8lc00000gn/T//nefario-scratch-2d9adF/compaction-gate-context-clipboard/phase2-devx-minion.md
