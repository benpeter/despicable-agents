# Synthesis: Simplify Path References in Nefario Skill

## Executive Summary

Replace 3 path references in `skills/nefario/SKILL.md` with `${CLAUDE_SKILL_DIR}`-based paths,
and move `TEMPLATE.md` into the skill directory for self-containment. The change fixes a broken
relative link and makes the skill work reliably when invoked from any project directory.

## Execution Plan

### Task 1: Move TEMPLATE.md into skill directory
**Agent**: devx-minion (sonnet, bypassPermissions)
**Dependencies**: none

Move `docs/history/nefario-reports/TEMPLATE.md` to `skills/nefario/TEMPLATE.md`.
Update the two prose references in SKILL.md (lines 2375, 2446) from
`docs/history/nefario-reports/TEMPLATE.md` to `${CLAUDE_SKILL_DIR}/TEMPLATE.md`.
Update the shorthand reference on line 946 to use `${CLAUDE_SKILL_DIR}/TEMPLATE.md`
for consistency.

Also update install.sh if needed (it already symlinks the entire directory, so no change
needed there).

**Deliverables:**
- `skills/nefario/TEMPLATE.md` (moved file)
- `docs/history/nefario-reports/TEMPLATE.md` removed (git mv)
- 3 references updated in `skills/nefario/SKILL.md`

### Task 2: Fix commit-workflow.md link
**Agent**: devx-minion (sonnet, bypassPermissions)
**Dependencies**: Task 1 (same file being edited)

Replace the broken relative link on line 1795:
- FROM: `[commit-workflow.md](../../../docs/commit-workflow.md)`
- TO: `[commit-workflow.md](${CLAUDE_SKILL_DIR}/../../docs/commit-workflow.md)`

This fixes the broken 3-level-up relative path and anchors it to the skill directory.

**Deliverables:**
- 1 reference updated in `skills/nefario/SKILL.md`

### Task 3: Update memory index
**Agent**: main session (no spawn)
**Dependencies**: Tasks 1-2

Update MEMORY.md to reflect new TEMPLATE.md location.

**Deliverables:**
- Updated memory entry

## Conflict Resolutions

None. Single specialist, no conflicts.

## Risks

1. **${CLAUDE_SKILL_DIR} symlink resolution** (MEDIUM): If the variable returns the symlink
   path rather than the resolved path, `${CLAUDE_SKILL_DIR}/../../docs/commit-workflow.md`
   will point to `~/.claude/docs/commit-workflow.md` (wrong). TEMPLATE.md move is unaffected
   (co-located). Mitigation: test after implementation.

## Approval Gates

None. Two sequential tasks modifying the same file, no decision points needed.
