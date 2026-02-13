# Phase 3.5 Review: test-minion

## Verdict: ADVISE

The plan correctly identifies that no executable code is produced and therefore no automated tests apply. The six verification steps (lines 336-348) cover the primary scenarios well: logic-bearing files trigger review, docs-only files skip, team assembly routes correctly, old phrasing is removed, jargon is excluded from user output, and the-plan.md is untouched.

Two concerns:

- [test-coverage]: Missing mixed-file verification scenario
  SCOPE: Verification Steps (step 1-2 mental walkthroughs)
  CHANGE: Add a verification step for a mixed changeset: "Given a task that produces changes to both `README.md` and `minions/security-minion/AGENT.md`, would Phase 5 skip or run? Expected: RUN (at least one file is logic-bearing)." This is the most likely real-world scenario and exercises the "ALL files must be documentation-only" conditional that Task 2 introduces.
  WHY: Steps 1 and 2 test the pure cases (all logic-bearing, all docs-only). The mixed case is the one most prone to implementation error -- an agent could misread "skip if ALL files are documentation-only" as "skip if ANY file is documentation-only." Without a verification step that covers the mixed case explicitly, this regression path is unvalidated.
  TASK: Verification Steps (post-execution, affects confidence in Task 2)

- [test-coverage]: CLAUDE.md classification lacks a dedicated verification scenario
  SCOPE: Verification Steps (step 1-3 mental walkthroughs)
  CHANGE: Add a verification step: "Given a task that produces changes only to `CLAUDE.md`, would Phase 5 skip or run? Expected: RUN (CLAUDE.md is logic-bearing)." CLAUDE.md is worth a separate check because it appears at "(any location)" in the classification table, unlike the other logic-bearing files which are scoped to agent/skill directories. This makes it the most likely candidate for misclassification in edge cases.
  WHY: The existing verification steps test AGENT.md (step 1) and README.md + docs/ (step 2), but none test CLAUDE.md specifically. Since CLAUDE.md has a unique classification rule (location-independent), it deserves its own walkthrough to confirm the classification boundary handles it correctly.
  TASK: Verification Steps (post-execution, affects confidence in Task 2)

Both concerns are low-severity. The plan is sound and the existing verification steps cover the critical paths. These additions would close the two most likely gaps in a walkthrough-based verification approach.
