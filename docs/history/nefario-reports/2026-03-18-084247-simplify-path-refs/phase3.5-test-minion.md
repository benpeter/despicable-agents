# Test-Minion Review: simplify-path-refs

## Verdict: ADVISE

## Domain Assessment

This is a text-only change to a SKILL.md file and a file move. No application code, no
executable logic, no test framework is appropriate. The project has no automated test suite
and the change does not introduce one.

The meaningful verification here is manual and structural, not automated.

## Risks Within My Domain

**The synthesis flags a real risk worth tracking**: if `${CLAUDE_SKILL_DIR}` resolves to the
symlink path (`~/.claude/skills/nefario`) rather than the target (`~/github/benpeter/
despicable-agents/skills/nefario`), the Task 2 fix becomes:

```
~/.claude/skills/nefario/../../docs/commit-workflow.md
→ ~/.claude/docs/commit-workflow.md   (wrong — file does not exist there)
```

TEMPLATE.md is co-located after the move, so Task 1 is symlink-safe regardless.

## What Should Be Verified After Execution

These are manual spot checks, not automated tests:

1. `skills/nefario/TEMPLATE.md` exists and content matches the moved file
2. `docs/history/nefario-reports/TEMPLATE.md` is gone from git
3. The three updated SKILL.md references grep-match `${CLAUDE_SKILL_DIR}/TEMPLATE.md`
4. The commit-workflow.md link on line 1795 resolves correctly — invoke the skill
   from a project directory and confirm the path reaches `docs/commit-workflow.md`

Item 4 cannot be verified by static analysis alone. The synthesis correctly flags it as
medium risk and says "test after implementation." I agree — the implementer should do a
quick live test of that specific link before the PR is merged.

## Recommendation

ADVISE: proceed, but make the post-execution check on the commit-workflow.md link
explicit in the task instructions to devx-minion. The move (Task 1) is safe. Task 2 carries
the symlink resolution risk identified in the synthesis — it should be validated before the
PR is merged, not assumed correct.
