MODE: META-PLAN

You are creating a meta-plan -- a plan for who should help plan.

## Task

Two GitHub issues to implement together, both targeting `skills/nefario/SKILL.md`:

### Issue #112: feat(nefario): embed context usage in compaction AskUserQuestion gates

When AskUserQuestion fires at compaction checkpoints, it occludes the status line. The user can't see context usage percentage. Solution: parse the `<system_warning>` Token usage attachment (format: `Token usage: {used}/{total}; {remaining} remaining`) and embed context percentage in the AskUserQuestion question text.

Files to change: `skills/nefario/SKILL.md` -- both compaction checkpoint gates (post-Phase 3 and post-Phase 3.5)

### Issue #110: feat(nefario): add pbcopy clipboard support to compaction checkpoints

Add `pbcopy` clipboard copy to both compaction checkpoint gates so the `/compact` command is automatically on the clipboard when the gate fires. Mac-only is acceptable. Keep the printed code block as visible fallback.

Files to change: `skills/nefario/SKILL.md` -- both compaction checkpoint gates

## Working Directory
/Users/ben/github/benpeter/2despicable/3

## External Skill Discovery
Scan .claude/skills/ and .skills/ for SKILL.md files.

## Instructions
1. Read relevant files to understand the codebase context
2. Discover external skills
3. Analyze the task against your delegation table
4. Identify which specialists should be CONSULTED FOR PLANNING (not execution -- planning)
5. For each specialist, write a specific planning question
6. Return the meta-plan in the structured format
7. Write your complete meta-plan to /var/folders/3k/bfjvvz9s6dvdn_hvlhvr8lc00000gn/T//nefario-scratch-2d9adF/compaction-gate-context-clipboard/phase1-metaplan.md
