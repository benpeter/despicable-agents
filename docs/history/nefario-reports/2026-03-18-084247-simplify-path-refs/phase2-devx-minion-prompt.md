You are contributing to the PLANNING phase of a multi-agent project.
You are NOT executing yet — you are providing your domain expertise
to help build a comprehensive plan.

## Project Task

Use ${CLAUDE_SKILL_DIR} to simplify path references in nefario skill.

Claude Code 2.1.69 added the `${CLAUDE_SKILL_DIR}` variable, which lets skills reference
their own directory in SKILL.md content. This removes the need for runtime path detection logic.

The nefario skill uses detection logic and relative paths to locate co-located files
(e.g., the report template at `docs/history/nefario-reports/TEMPLATE.md`). Some of this
path resolution could be simplified by using the new variable.

Audit `skills/nefario/SKILL.md` for path references that could be replaced with
`${CLAUDE_SKILL_DIR}/...` and simplify accordingly. This should reduce fragility when
the skill is symlinked to `~/.claude/skills/nefario`.

## Your Planning Question

What path references in `skills/nefario/SKILL.md` can safely be replaced with
`${CLAUDE_SKILL_DIR}`-based paths? For each candidate:
1. What is the current reference and its line number?
2. What should it become?
3. What are the symlink resolution implications?
4. Are there any references that should explicitly NOT be changed (and why)?

Also consider: should any referenced files be moved INTO the skill directory
to make `${CLAUDE_SKILL_DIR}` paths simpler (e.g., TEMPLATE.md)?

## Context

The skill is at `skills/nefario/SKILL.md` in the repo.
It is symlinked: `~/.claude/skills/nefario` → `/Users/ben/github/benpeter/despicable-agents/skills/nefario`
`readlink -f ~/.claude/skills/nefario/` resolves to `/Users/ben/github/benpeter/despicable-agents/skills/nefario`

Key path references found in SKILL.md:
- Line 1795: `[commit-workflow.md](../../../docs/commit-workflow.md)` (relative markdown link, depth looks wrong)
- Lines 2375, 2446: `docs/history/nefario-reports/TEMPLATE.md` (cwd-relative prose references)
- Line 946: `TEMPLATE.md` (shorthand reference)
- Lines 288-290: Report directory detection (cwd-relative output paths)

## Instructions
1. Read the SKILL.md file to verify the path references
2. Apply your domain expertise to the planning question
3. Identify risks, dependencies, and requirements from your perspective
4. Return your contribution in the structured format below

## Domain Plan Contribution: devx-minion

### Recommendations

### Proposed Tasks

### Risks and Concerns

### Additional Agents Needed

Write your complete contribution to `/var/folders/3k/bfjvvz9s6dvdn_hvlhvr8lc00000gn/T//nefario-scratch-ie2V0C/simplify-path-refs/phase2-devx-minion.md`
