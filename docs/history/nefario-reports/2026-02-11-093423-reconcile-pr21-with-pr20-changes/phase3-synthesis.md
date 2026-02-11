## Delegation Plan

**Team name**: reconcile-pr21
**Description**: Merge origin/main (with PR #20) into PR #21 branch, resolving SKILL.md conflict and running tests

### Task 1: Merge origin/main into PR #21 branch and resolve SKILL.md conflict

- **Agent**: general-purpose
- **Model**: sonnet
- **Mode**: bypassPermissions
- **Blocked by**: none
- **Approval gate**: no
- **Prompt**: |
    You are resolving a merge conflict between PR #20 (merged to origin/main) and
    PR #21 (open branch `nefario/status-line-task-summary-nefario`).

    ## Background

    **PR #20** ("Decouple toolkit from self-referential path assumptions") changed
    `skills/nefario/SKILL.md` on origin/main. The key changes relevant to this merge:
    - Replaced ALL `nefario/scratch/{slug}/` paths (29 occurrences) with
      `$SCRATCH_DIR/{slug}/` (31 occurrences on origin/main). The variable
      `$SCRATCH_DIR` is created via `mktemp -d` in a new "Path Resolution" section.
    - Added a "Path Resolution" section with: secure mktemp-based scratch directory
      creation, cwd-relative report directory detection, git repo detection
    - Renamed step 11 from "Return to main" to "Return to default branch" with
      dynamic default branch detection and git-repo conditional
    - Added scratch cleanup at wrap-up
    - Added pre-copy sanitization for credential patterns
    - Added CONDENSE line format showing actual resolved scratch path
    - Various other structural changes (report directory detection, inline report
      format reference, etc.)

    On origin/main, `nefario/scratch/` appears 0 times. `$SCRATCH_DIR` appears 31 times.

    **PR #21** ("Add task summary to status line during orchestration") changed
    `skills/nefario/SKILL.md` on a branch forked BEFORE PR #20 was merged.
    PR #21's changes are:
    - Add a sentinel file block after slug creation in Phase 1 (writes status
      summary to `/tmp/nefario-status-${slug}`)
    - Change Task `description` fields from generic strings to `"Nefario: <summary>"`
      format throughout (Phase 1, 2, 3, 3.5, 4, 5)
    - Add `activeForm` instructions in Phase 4 Setup (step 2, TaskCreate)
    - Add sentinel cleanup in step 11 (Return to main)

    On PR #21's branch, `nefario/scratch/` appears 29 times. `$SCRATCH_DIR` appears 0 times.

    These changes are **semantically independent**. The resolution is to keep
    PR #20's `$SCRATCH_DIR` path model (which is on origin/main, the merge target)
    and layer PR #21's status-line additions on top.

    ## Actual Conflict

    There is exactly ONE conflict region in SKILL.md, at step 11 (the
    "Return to main/default branch" section). The conflict is:

    - **PR #21 (HEAD)**: "Return to main" with sentinel cleanup line added
    - **PR #20 (origin/main)**: "Return to default branch" with dynamic branch
      detection and git-repo conditional

    All other PR #20 changes auto-merge cleanly because they touch different
    regions of the file.

    ## Steps

    1. **Update local main first** (your working directory is the real repo):
       ```sh
       cd /Users/ben/github/benpeter/2despicable/2
       git checkout main
       git pull --rebase origin main
       ```

    2. **Checkout the PR #21 branch**:
       ```sh
       git checkout nefario/status-line-task-summary-nefario
       ```

    3. **Merge origin/main**:
       ```sh
       git merge origin/main
       ```
       This will report a conflict in `skills/nefario/SKILL.md`.

    4. **Resolve the SKILL.md conflict**. Read the conflicted file. There is
       exactly one conflict region at step 11. The correct resolution combines
       BOTH sides:

       - Use PR #20's structure: "Return to default branch", conditional on
         git repo, dynamic branch detection
       - Add PR #21's sentinel cleanup line alongside the existing marker cleanup
       - The sentinel cleanup must appear ALONGSIDE the marker cleanup, not
         replacing it

       The resolved step 11 should read:

       ```markdown
       11. **Return to default branch** — after PR creation (or if declined),
           if in a git repo:
           Remove the orchestrated-session marker and status sentinel:
           `rm -f /tmp/claude-commit-orchestrated-${CLAUDE_SESSION_ID}`
           `rm -f /tmp/nefario-status-${slug}`
           Detect default branch:
           `git symbolic-ref refs/remotes/origin/HEAD 2>/dev/null | sed 's@^refs/remotes/origin/@@'`
           (fall back to `main`). Then: `git checkout <default-branch> && git pull --rebase`.
           Include branch name in final summary.
           If not in a git repo, skip this step.
       ```

       After resolving the conflict markers, save the file.

    5. **Stage and commit the merge**:
       ```sh
       git add skills/nefario/SKILL.md
       git commit --no-edit
       ```
       (Use the default merge commit message from git.)

    6. **Verify the result**:
       - Confirm `git merge-base --is-ancestor origin/main HEAD` returns 0
       - Run `grep -c 'nefario/scratch/' skills/nefario/SKILL.md` and confirm
         it returns 0 (PR #20 replaced all occurrences with `$SCRATCH_DIR`)
       - Run `grep -c 'SCRATCH_DIR' skills/nefario/SKILL.md` and confirm it
         returns a positive number (~31)
       - Confirm the sentinel file block is present in Phase 1 (search for
         `nefario-status`)
       - Confirm all 6 description field changes are present (search for
         `"Nefario:`)
       - Confirm the activeForm instruction is present in Phase 4 Setup
       - Confirm step 11 has both sentinel cleanup AND default branch detection
       - Confirm the "Path Resolution" section exists
       - Run `git log --oneline -5` to verify the merge commit exists

    ## What NOT to do
    - Do NOT modify any files other than `skills/nefario/SKILL.md`
    - Do NOT create new files
    - Do NOT push the branch (the calling session handles PR update)
    - Do NOT revert or lose any changes from either PR
    - Do NOT use `git checkout --theirs` or `--ours` (manual resolution required)
    - Do NOT introduce any `nefario/scratch/` hardcoded paths -- PR #20 removed
      ALL of them and they must stay removed

    ## Working Directory
    /Users/ben/github/benpeter/2despicable/2

- **Deliverables**: Merged `skills/nefario/SKILL.md` with both PRs' changes correctly integrated; clean merge commit on the PR #21 branch
- **Success criteria**:
  1. `git merge-base --is-ancestor origin/main HEAD` returns 0 (main is merged in)
  2. `grep -c 'nefario/scratch/' skills/nefario/SKILL.md` returns 0 (PR #20 removed all hardcoded scratch paths)
  3. `grep -c 'SCRATCH_DIR' skills/nefario/SKILL.md` returns ~31 (PR #20's path model preserved)
  4. `grep 'nefario-status' skills/nefario/SKILL.md` shows sentinel references (PR #21's additions preserved)
  5. All description fields show `"Nefario:` prefix format (PR #21's additions preserved)
  6. Step 11 has both sentinel cleanup and default branch detection (both PRs combined)

### Task 2: Run existing tests on the merged branch

- **Agent**: general-purpose
- **Model**: sonnet
- **Mode**: bypassPermissions
- **Blocked by**: Task 1
- **Approval gate**: no
- **Prompt**: |
    You are verifying that existing tests pass after a merge conflict resolution.
    The PR #21 branch (`nefario/status-line-task-summary-nefario`) has just had
    origin/main (containing PR #20's changes) merged in.

    ## Test Suite

    The repo has three test scripts:

    1. `tests/run-tests.sh` -- Overlay validation tests (10 fixtures). Tests
       the `validate-overlays.sh` script against synthetic fixtures.

    2. `tests/test-no-hardcoded-paths.sh` -- Static regression test that scans
       toolkit files for hardcoded self-referential paths. Added by PR #20.
       This test should PASS because PR #20's `$SCRATCH_DIR` decoupling is now
       on the branch.

    3. `tests/test-install-portability.sh` -- Portability test for install.sh
       using a temporary HOME directory. Added by PR #20. Tests that install
       and uninstall create/remove expected symlinks.

    ## Steps

    1. Ensure you are on the PR #21 branch:
       ```sh
       cd /Users/ben/github/benpeter/2despicable/2
       git branch --show-current
       ```
       Expected: `nefario/status-line-task-summary-nefario`

    2. Run each test suite and capture results:
       ```sh
       bash tests/run-tests.sh
       bash tests/test-no-hardcoded-paths.sh
       bash tests/test-install-portability.sh
       ```

    3. Report results: for each test script, report pass/fail and any failures.

    ## What NOT to do
    - Do NOT modify any files
    - Do NOT fix failing tests (report them; the calling session decides next steps)
    - Do NOT push the branch

    ## Working Directory
    /Users/ben/github/benpeter/2despicable/2

- **Deliverables**: Test execution results for all three test suites
- **Success criteria**:
  1. `tests/run-tests.sh` passes (10/10 fixtures)
  2. `tests/test-no-hardcoded-paths.sh` passes (no hardcoded paths detected)
  3. `tests/test-install-portability.sh` passes (install/uninstall portability)

### Cross-Cutting Coverage

- **Testing**: Covered by Task 2. Runs all three test suites (overlay validation, hardcoded path detection, install portability).
- **Security**: Not applicable -- no new attack surface. PR #21's sentinel file uses `chmod 600` (already reviewed). PR #20's `mktemp` and credential scanning are preserved by the merge.
- **Usability -- Strategy**: Not applicable -- no user-facing behavior change. Both PRs were independently reviewed for UX.
- **Usability -- Design**: Not applicable -- no UI changes.
- **Documentation**: Not applicable -- no doc changes beyond what's already in both PRs.
- **Observability**: Not applicable -- no runtime components.

### Architecture Review Agents

Not triggered. This is a mechanical merge conflict resolution with zero design decisions. Both PRs were independently reviewed before merge/PR creation. The only judgment call (keep PR #20's base, layer PR #21's additions) has a single correct answer because the changes are semantically independent. The sole conflict region is step 11, where the resolution is an obvious combination of both sides' changes.

### Conflict Resolutions

None between specialists. The merge conflict itself is resolved by combining both PRs' changes in step 11: PR #20's "Return to default branch" structure (dynamic branch detection, git-repo conditional) plus PR #21's sentinel cleanup line.

### Risks and Mitigations

- **Risk**: Merge resolution accidentally reverts PR #20 changes in the non-conflicting regions (e.g., `$SCRATCH_DIR` paths reverting to `nefario/scratch/`).
  **Mitigation**: The auto-merge handles non-conflicting regions correctly. Task 1 verification explicitly checks that `nefario/scratch/` count is 0 and `$SCRATCH_DIR` count is ~31. Task 2 runs `test-no-hardcoded-paths.sh` which will catch any reversions.

- **Risk**: Step 11 conflict resolution loses one side's changes (e.g., sentinel cleanup missing, or dynamic branch detection missing).
  **Mitigation**: Task 1 prompt provides the exact resolved text. Verification checks for both sentinel cleanup and default branch detection.

### Execution Order

```
Batch 1: Task 1 (merge + resolve + commit + verify)
Batch 2: Task 2 (run tests -- blocked by Task 1)
```

No approval gates. Success is objectively verifiable.

### Verification Steps

After Task 1 completes:
1. `git merge-base --is-ancestor origin/main HEAD` (exit 0 = main merged)
2. `grep -c 'nefario/scratch/' skills/nefario/SKILL.md` returns 0
3. `grep -c 'SCRATCH_DIR' skills/nefario/SKILL.md` returns ~31
4. `grep 'nefario-status' skills/nefario/SKILL.md` shows sentinel references
5. `git log --oneline -3` shows the merge commit

After Task 2 completes:
6. All three test suites pass (run-tests.sh, test-no-hardcoded-paths.sh, test-install-portability.sh)
