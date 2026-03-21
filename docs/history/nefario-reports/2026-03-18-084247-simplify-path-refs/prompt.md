Use ${CLAUDE_SKILL_DIR} to simplify path references in nefario skill

## Context

Claude Code 2.1.69 added the `${CLAUDE_SKILL_DIR}` variable, which lets skills reference their own directory in SKILL.md content. This removes the need for runtime path detection logic.

## Current State

The nefario skill uses detection logic and relative paths to locate co-located files (e.g., the report template at `docs/history/nefario-reports/TEMPLATE.md`). Some of this path resolution could be simplified by using the new variable.

## Proposed Change

Audit `skills/nefario/SKILL.md` for path references that could be replaced with `${CLAUDE_SKILL_DIR}/...` and simplify accordingly. This should reduce fragility when the skill is symlinked to `~/.claude/skills/nefario`.

## Source

Claude Code changelog: 2.1.69 — "Added `${CLAUDE_SKILL_DIR}` variable for skills to reference their own directory in SKILL.md content"
