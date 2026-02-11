# Margo Review: Stay on Feature Branch After PR

VERDICT: APPROVE

## Assessment

The changes are a textbook simplification: removing an automatic `git checkout <default-branch> && git pull --rebase` action and replacing it with "stay on feature branch, hint the command in the summary." This is strictly less behavior, less code, and less risk of surprising the developer.

### Complexity delta: negative (good)

- **Removed**: an automatic branch switch at session end (an action with side effects)
- **Added**: nothing new -- only rephrased existing text to reflect the simpler behavior
- **Net**: fewer moving parts, fewer failure modes (e.g., dirty working tree blocking checkout)

### Scope check

Three files changed, all directly related to the feature branch workflow:
- `skills/nefario/SKILL.md` -- the canonical orchestration skill (wrap-up steps and commit flow)
- `docs/commit-workflow.md` -- the design doc
- `docs/decisions.md` -- the decision record

No new abstractions, no new dependencies, no technology additions. Task count matches request scope exactly.

### Consistency check

All references across the three changed files are internally consistent:
- SKILL.md line 1278: "Stay on the feature branch (no checkout)."
- SKILL.md line 1134: "The session stays on the feature branch."
- SKILL.md line 1279: hint to return included in final summary
- commit-workflow.md line 50: "stays on the feature branch" with escape hatch
- commit-workflow.md mermaid diagram line 93: "Stays on nefario/<slug> branch"
- decisions.md line 233: "stay on feature branch after PR"
- decisions.md line 236: "final summary includes escape hatch to return to default branch"

No stale references to the old "return to default branch" automatic behavior found in any of the three files. The `commit-workflow-security.md` file is unaffected (its only checkout reference is about branch creation, not wrap-up).

## Findings

No blocking or advisory findings. The change is minimal, focused, and removes complexity rather than adding it.
