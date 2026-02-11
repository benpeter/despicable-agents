Reconcile PR #21 with PR #20 changes on main

**Outcome**: PR #21 (status-line-task-summary-nefario) incorporates all changes from PR #20 (decouple-self-referential-assumptions) so that #21 is conflict-free and safe to merge to main.

**Success criteria**:
- Main is merged into nefario/status-line-task-summary-nefario without conflicts
- All status-line changes from #21 are preserved
- All changes from #20 (now on main) are incorporated
- Existing tests pass on the updated branch

**Scope**:
- In: Conflict resolution between #20 and #21 on skills/nefario/SKILL.md and any other overlapping files
- Out: New features, refactoring beyond conflict resolution, changes to #20's work
