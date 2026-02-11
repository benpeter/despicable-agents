# Meta-Plan: Reconcile PR #21 with PR #20 Changes

## Analysis

This is a **mechanical merge conflict resolution**, not a feature development task.

### Conflict Surface

- **Single conflicting file**: `skills/nefario/SKILL.md`
- **Nature of conflict**: PR #20 (now merged to main) replaced `$SCRATCH_DIR`-based
  temp directory paths with `nefario/scratch/`-relative paths throughout SKILL.md.
  PR #21 added status-line task summary features (sentinel files, `description`
  field prefixes, `activeForm` conventions) to the same file. The changes touch
  overlapping line regions but are **semantically independent** -- PR #21's additions
  need to be applied on top of PR #20's path model, not the old `$SCRATCH_DIR` model.
- **Non-conflicting files**: PR #21 also adds 8 report files under
  `docs/history/nefario-reports/2026-02-10-215954-status-line-task-summary-nefario/`.
  These do not overlap with any files from PR #20.

### Conflict Resolution Strategy

The resolution is straightforward:
1. Checkout `nefario/status-line-task-summary-nefario`
2. Merge `main` into it
3. Resolve the single SKILL.md conflict by keeping PR #20's path model
   (`nefario/scratch/` instead of `$SCRATCH_DIR`) while preserving all of
   PR #21's status-line additions
4. Verify no content from either PR is lost
5. Run existing tests

### Risk Assessment

- **Primary risk**: Accidentally dropping status-line additions during conflict
  resolution, or reverting PR #20's path changes. Both are detectable by
  post-merge diff inspection.
- **Secondary risk**: None. The changes are semantically independent.

## Planning Consultations

**None required.**

This task does not benefit from specialist planning consultation. The reasons:

1. **Single file, mechanical conflict**: The conflict is in one file, between two
   sets of changes that are semantically independent (path model vs. status-line
   features). The resolution strategy is unambiguous: take PR #20's paths + PR #21's
   status-line additions.
2. **No architectural decisions**: There are no design choices to make. Both PRs
   are already approved and merged/ready; we are just combining them.
3. **No domain expertise needed**: Understanding the SKILL.md structure is
   sufficient, and the diff analysis above already provides full context.
4. **Verification is simple**: Post-merge, check that (a) no `$SCRATCH_DIR`
   references remain (PR #20's intent), (b) all status-line additions are present
   (PR #21's intent), and (c) tests pass.

## Cross-Cutting Checklist

- **Testing**: Not applicable for planning. Existing tests will be run post-merge
  as verification (part of success criteria).
- **Security**: Not applicable. No new attack surface, auth changes, or user input
  handling. This is a merge of already-reviewed changes.
- **Usability -- Strategy**: Not applicable. No user-facing changes are being
  designed; we are combining two already-approved change sets.
- **Usability -- Design**: Not applicable. No UI changes.
- **Documentation**: Not applicable for planning. The report files from PR #21
  merge cleanly without conflicts.
- **Observability**: Not applicable. No runtime components.

## Anticipated Approval Gates

**Zero gates.** This is a conflict resolution merge with no design decisions. The
success criteria are objective and verifiable:
- No merge conflicts remain
- All PR #20 changes present (no `$SCRATCH_DIR` references in merged result)
- All PR #21 changes present (status-line features intact)
- Tests pass

## Rationale

Specialist planning adds overhead without value for mechanical merge conflict
resolution. The conflict is well-understood from the diff analysis, the resolution
strategy is unambiguous, and verification is objective.

## Scope

- **In scope**: Merging main into `nefario/status-line-task-summary-nefario`,
  resolving the SKILL.md conflict, verifying completeness and test passage.
- **Out of scope**: New features, refactoring beyond conflict resolution, changes
  to PR #20's already-merged work, modifications to any file not affected by the
  merge.

## Recommendation

**Skip to direct execution.** This task should proceed as MODE: PLAN (simplified
process) rather than full specialist consultation. The execution plan is:

1. `git checkout nefario/status-line-task-summary-nefario`
2. `git merge origin/main` (will conflict on SKILL.md)
3. Resolve SKILL.md: keep PR #20's `nefario/scratch/` path model + PR #21's
   status-line additions
4. Verify: grep for `$SCRATCH_DIR` (should be zero), grep for `nefario-status-`
   sentinel (should be present), check status-line description prefixes present
5. `git add skills/nefario/SKILL.md && git commit` (merge commit)
6. Run tests if any exist
7. Push to update PR #21
