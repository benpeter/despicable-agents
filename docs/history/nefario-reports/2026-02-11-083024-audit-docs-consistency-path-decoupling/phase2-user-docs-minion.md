## Domain Plan Contribution: user-docs-minion

### Recommendations

#### (1) README.md Line 124 -- "scratch files (preserved as companion directories in PRs)" -- Accuracy Assessment

This description is **partially accurate but misleading** after the path decoupling. Here is why:

- **Before decoupling**: Scratch files lived at `nefario/scratch/{slug}/` inside the project tree (gitignored). At wrap-up, they were copied to a companion directory alongside the report in `docs/history/nefario-reports/`. The phrase "preserved as companion directories in PRs" accurately described this flow because the scratch files started in the project tree and were explicitly collected into a git-tracked companion directory.

- **After decoupling**: Scratch files now live in `$TMPDIR` (system temp directory, completely outside the project tree). At wrap-up, they are still copied to companion directories alongside reports. The companion directory mechanism is intact. However, "scratch files (preserved as companion directories in PRs)" now creates a false mental model. A new user reading this would think scratch files are project-tree artifacts that get preserved. In reality, scratch files are ephemeral temp files that happen to get copied to companion directories if the orchestration completes successfully. The parenthetical makes the preservation sound like a property of scratch files themselves, when it is actually a property of the wrap-up process.

**Recommended fix**: Rephrase to focus on the user-visible behavior without exposing implementation detail. Something like: "The project uses temporary scratch files and compaction checkpoints to manage context, but very large plans may require manual intervention." The companion directory detail is too internal for a README limitations section -- users who care about traceability will find it in the orchestration docs.

#### (2) using-nefario.md -- Does It Need Updates?

**No updates needed.** The document is well-written at the right abstraction level for end users. It describes the nine phases from the user's perspective (what you experience, what you see, what action you take) without mentioning scratch files, paths, or internal mechanics. Specific observations:

- **"Working Directory" section (line 82-84)**: Correctly describes the CWD-relative behavior. "Nefario operates on whichever project your Claude Code session is in. Reports, feature branches, and commits all target the current working directory's project. No configuration is needed." This is exactly right and fully consistent with the decoupled model.
- **Phase descriptions**: Reference what the user sees ("You receive the plan for review"), not where files are stored. No path assumptions leak into user-facing descriptions.
- **Tips section**: All practical advice is implementation-agnostic.

This document is a model of good user documentation -- it stays at the task level and does not bleed implementation detail. No changes required.

#### (3) User-Facing Implications of the Path Change

There are **two user-facing implications** worth considering:

**A. Scratch files are no longer inspectable during orchestration** (minor but noticeable).

Previously, a curious or debugging user could run `ls nefario/scratch/` in a separate terminal to see what the orchestrator was writing. With `$TMPDIR`-based paths, the user would need to know the randomized temp path. The SKILL.md CONDENSE output does print the resolved path (e.g., "Scratch: /tmp/nefario-scratch-a3F9xK/my-slug/"), so the information is available, but it requires more effort. This is an acceptable tradeoff -- the old behavior was a side effect, not a feature -- but it could merit a brief mention in a troubleshooting context.

**B. Interrupted orchestrations no longer leave scratch files in the project tree** (positive change).

Previously, if an orchestration was interrupted, leftover scratch files would sit in `nefario/scratch/` until manually cleaned. Now they are in `$TMPDIR` and cleaned on reboot. This is a user-facing improvement, but unlikely to need documentation since the old behavior was never documented either.

Neither implication warrants changes to `using-nefario.md`. The README fix in recommendation (1) is the only user-facing documentation change needed.

### Proposed Tasks

#### Task 1: Fix README.md Context Window Pressure Description

**What to do**: Update README.md line 124 to accurately describe the post-decoupling behavior. Remove the parenthetical "(preserved as companion directories in PRs)" which describes an internal mechanism that changed. Replace with a simpler, accurate description.

**Current text**:
> Context window pressure. Complex orchestrations with many specialists can approach context limits. The project uses scratch files (preserved as companion directories in PRs) and compaction checkpoints, but very large plans may require manual intervention.

**Proposed text**:
> Context window pressure. Complex orchestrations with many specialists can approach context limits. The project uses temporary scratch files and compaction checkpoints to manage context, but very large plans may require manual intervention.

**Deliverable**: Updated README.md with the corrected limitation description.

**Dependencies**: None. This is a standalone text change.

#### Task 2: Fix docs/decisions.md Decision 21 Stale Path References

**What to do**: Decision 21 still contains two references to the old `nefario/scratch/{slug}/` path convention. While Decision 26 explicitly supersedes the scratch file portions of Decision 21, the old decision's text still contains the stale paths. This is a contributor-facing documentation issue, not a user-facing one, but it is within the audit scope.

**Stale references**:
- Line 274: `nefario/scratch/{slug}/` in the Choice field
- Line 277: `nefario/scratch/` (gitignored) in the Consequences field

**Recommended approach**: Add a brief note to Decision 21 indicating it was superseded by Decision 26 for the scratch file path convention. Do NOT rewrite historical decision text -- decisions are historical records. Instead, append a supersession note, for example: "Note: Scratch file paths were updated to `$TMPDIR`-based convention in Decision 26."

**Deliverable**: Updated `docs/decisions.md` with supersession annotation on Decision 21.

**Dependencies**: None.

#### Task 3: Verify docs/compaction-strategy.md Consistency (no changes expected)

**What to do**: Confirm that `docs/compaction-strategy.md` is consistent with the decoupled model. Based on my review, it already uses `$TMPDIR/nefario-{slug}-XXXXXX/` notation (line 33) and describes `mktemp -d` creation (line 30). No changes needed, but should be verified as part of the audit.

**Deliverable**: Verification confirmation (no file changes).

**Dependencies**: None.

### Risks and Concerns

1. **Decision record integrity risk**. Decision 21 contains stale paths, but design decisions are historical records. Editing the Choice or Consequences text risks making it look like the decision was always about `$TMPDIR` paths. The recommended approach (supersession annotation rather than text rewrite) preserves historical accuracy while preventing confusion.

2. **nefario/scratch/ directory still present in working tree**. The git status shows `nefario/scratch/` as an untracked directory. This is leftover from a pre-decoupling orchestration run. While not a documentation issue per se, if a new contributor clones the repo and sees this directory, they might think it is an active convention. The `.gitignore` entry for it has been removed (per Decision 26), so it would show up in `git status` as untracked. This directory should be removed from the working tree as a cleanup task (outside the documentation scope, but worth flagging).

3. **Companion directory concept is undocumented for users**. The concept of "companion directories" (scratch files copied alongside reports at wrap-up) is mentioned in README.md but not explained anywhere in user-facing docs. After the README fix in Task 1, this internal detail is no longer exposed in user-facing text, which is the correct approach -- it is a contributor/architecture concern documented in `docs/orchestration.md` and the SKILL.md.

4. **docs/history/ nefario reports contain old `nefario/scratch/` references**. The execution report for the decoupling itself (`2026-02-10-205010-decouple-self-referential-assumptions.md`) and its companion directory files naturally contain references to the old paths as historical record. These should NOT be updated -- they are accurate records of what was discussed and changed. The audit scope correctly excludes `docs/history/` nefario reports.

### Additional Agents Needed

None. The current team is sufficient. The changes are documentation-only and the scope is well-defined. software-docs-minion may want to verify that `docs/orchestration.md` and `docs/compaction-strategy.md` are consistent from an architecture documentation perspective, but those documents appear already updated based on my review.
