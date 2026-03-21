# Margo Review: Simplify Path References in Nefario Skill

## Verdict: ADVISE

The plan is proportional to the problem: 4 path references need fixing, and the plan touches exactly those 4 references plus 1 file move. No scope creep, no new dependencies, no new abstractions. Two concerns worth noting before execution.

## Findings

### 1. TEMPLATE.md move: justified but verify the coupling claim (LOW)

Moving `docs/history/nefario-reports/TEMPLATE.md` into `skills/nefario/` is presented as making the skill "self-contained." This is a reasonable simplification -- the template is only consumed by the skill, so co-locating it eliminates a cross-directory dependency.

However, lines 289-290 of SKILL.md reference `docs/history/nefario-reports/` as the **report directory** (where reports are *written*). The template currently lives alongside the reports it generates. After the move, the template lives in `skills/nefario/` while reports are written to `docs/history/nefario-reports/`. This is fine architecturally (template is source, reports are output), but confirm no other file references `docs/history/nefario-reports/TEMPLATE.md` outside SKILL.md.

**Action**: Grep the full repo for `TEMPLATE.md` references before executing. If references exist outside SKILL.md (e.g., in CLAUDE.md memory, docs, or other agents), update them too.

### 2. Risk item #1 (symlink resolution) is real and undertreated (MEDIUM)

The plan identifies a MEDIUM risk: `${CLAUDE_SKILL_DIR}/../../docs/commit-workflow.md` will resolve incorrectly if `${CLAUDE_SKILL_DIR}` returns the symlink path (`~/.claude/skills/nefario`) rather than the resolved target. The mitigation is "test after implementation."

This risk does NOT affect the TEMPLATE.md references (co-located, so `${CLAUDE_SKILL_DIR}/TEMPLATE.md` works either way). It ONLY affects the `commit-workflow.md` link on line 1795.

**Simpler alternative**: For the commit-workflow.md reference, instead of `${CLAUDE_SKILL_DIR}/../../docs/commit-workflow.md`, just use the plain filename `commit-workflow.md` as an inline reference (not a link), since the consuming agent will locate the file via the project's working directory anyway. The current broken relative link `../../../docs/commit-workflow.md` is already non-functional -- a plain-text reference like `docs/commit-workflow.md (relative to project root)` would be equally useful and immune to symlink resolution behavior.

If the team wants to keep it as a resolvable path, then the symlink behavior of `${CLAUDE_SKILL_DIR}` must be verified BEFORE execution, not after. Converting a broken link into a differently-broken link is not progress.

## Complexity Budget

| Item | Column | Cost |
|------|--------|------|
| File move (TEMPLATE.md) | N/A (repo-internal) | 0 |
| Variable substitution (3 refs) | N/A (no new tech) | 0 |
| Link fix (1 ref) | N/A (bug fix) | 0 |

Total: 0 new complexity. This is a pure simplification. No new technology, no new dependencies, no new abstractions.

## Summary

The plan is lean and well-scoped. The two items above are non-blocking: (1) verify no external TEMPLATE.md references are missed, and (2) consider whether the commit-workflow.md link should use a simpler reference pattern to avoid symlink resolution risk. Neither warrants blocking execution.
