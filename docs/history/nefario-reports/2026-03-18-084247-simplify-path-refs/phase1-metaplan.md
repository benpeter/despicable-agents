# Meta-Plan: Simplify Path References in Nefario Skill

## Task Analysis

Replace hardcoded relative/cwd-relative path references in `skills/nefario/SKILL.md` with
`${CLAUDE_SKILL_DIR}`-based paths where appropriate. This improves reliability when the skill
is symlinked to `~/.claude/skills/nefario` and invoked from any project directory.

## Path Reference Audit

### Candidates for ${CLAUDE_SKILL_DIR} replacement

1. **Line 1795**: `[commit-workflow.md](../../../docs/commit-workflow.md)`
   - Relative markdown link with incorrect depth (`../../../` = 3 levels up from `skills/nefario/`, overshoots repo root)
   - Fix: `${CLAUDE_SKILL_DIR}/../../docs/commit-workflow.md`

2. **Line 2375**: `docs/history/nefario-reports/TEMPLATE.md` (prose reference)
   - cwd-relative, breaks when invoked from non-despicable-agents project
   - Fix: `${CLAUDE_SKILL_DIR}/../../docs/history/nefario-reports/TEMPLATE.md`

3. **Line 2446**: Same as #2 (second reference to template)

4. **Line 946**: `TEMPLATE.md` (shorthand prose reference in advisory section)
   - Should use consistent full path

### References that should STAY cwd-relative

- **Lines 288-290**: Report directory detection (`docs/nefario-reports/`, `docs/history/nefario-reports/`)
  - These are OUTPUT locations — reports go into the current project, not the skill's source repo
  - Correctly cwd-relative

### References that are not file paths (no change)

- Lines 1895, 2174: Generic prose references to file patterns, not actual paths

## Specialists Needed

1. **devx-minion**: CLI/skill structure expertise, ${CLAUDE_SKILL_DIR} behavior, symlink implications

## Cross-cutting Checklist

- Testing: Verify ${CLAUDE_SKILL_DIR} substitution works in markdown link context
- Security: No new attack surface (path references only)
- Usability: N/A (internal skill file)
- Documentation: N/A (the change IS to the orchestration doc)
- Observability: N/A

## External Skills

No external skills detected (project-local skills despicable-lab, despicable-prompter, despicable-statusline
are not relevant to this task).
