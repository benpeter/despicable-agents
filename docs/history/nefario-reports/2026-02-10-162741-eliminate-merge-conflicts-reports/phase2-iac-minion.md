# Domain Plan Contribution: iac-minion

## Planning Question

What is the simplest GitHub Actions workflow to regenerate
`docs/history/nefario-reports/index.md` on push to main? Should it be a
separate workflow or added to the existing `vibe-coded-badge.yml`? What
permissions does it need? How should it handle empty commits (no index
changes)? Should it also run on PR events for preview?

## Recommendations

### Separate workflow, not merged into vibe-coded-badge

Create a dedicated `.github/workflows/regenerate-report-index.yml`. Reasons:

1. **Single responsibility**: `vibe-coded-badge.yml` handles badge updates. Index
   regeneration is an unrelated concern. Mixing them couples unrelated failure
   modes -- a badge action failure should not block index regeneration and vice
   versa.

2. **Independent triggers**: The badge workflow only triggers on `push` to
   `main`. The index workflow may need path filtering (only run when report files
   change) which is easier to reason about in isolation.

3. **Clarity**: A developer reading the workflows directory can understand what
   each workflow does from its name. `regenerate-report-index.yml` is
   self-documenting.

4. **Minimal cost**: A second workflow YAML adds zero operational complexity.
   GitHub Actions runs jobs independently regardless.

### Workflow design

The workflow should be minimal -- check out, run the script, commit if changed:

```yaml
name: Regenerate Report Index

on:
  push:
    branches: [main]
    paths:
      - 'docs/history/nefario-reports/**.md'
      - 'docs/history/nefario-reports/build-index.sh'

permissions:
  contents: write

jobs:
  regenerate-index:
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@11bd71901bbe5b1630ceea73d27597364c9af683 # v4.2.2

      - name: Regenerate index
        run: bash docs/history/nefario-reports/build-index.sh

      - name: Commit if changed
        run: |
          git config user.name "github-actions[bot]"
          git config user.email "41898282+github-actions[bot]@users.noreply.github.com"
          git add docs/history/nefario-reports/index.md
          git diff --cached --quiet || git commit -m "docs: regenerate nefario report index [skip ci]"
          git push
```

### Key design decisions explained

**Path filter**: The `paths` filter ensures the workflow only runs when report
files actually change, not on every push to main. This avoids unnecessary
workflow runs when unrelated files are pushed. The filter includes
`build-index.sh` itself so that changes to the generation script also trigger a
rebuild.

**Pinned checkout action**: `actions/checkout` is pinned to full SHA
(`11bd71901bbe5b1630ceea73d27597364c9af683` = v4.2.2) per supply chain security
best practice. The version comment documents which release the SHA corresponds
to.

**Empty commit handling**: The `git diff --cached --quiet || git commit ...`
pattern is the idiomatic way to handle "commit only if something changed." The
`git diff --cached --quiet` command exits 0 if the staging area has no changes
(no commit needed) and exits 1 if there are changes (commit proceeds). The `||`
short-circuits: if the diff is clean, the commit is skipped entirely. No empty
commit is ever created.

**`[skip ci]` in the commit message**: This is critical to prevent an infinite
trigger loop. Without it, the workflow's own commit would trigger another push
event, which could trigger the workflow again. The `[skip ci]` marker tells
GitHub Actions to skip workflow runs for this commit. This is the standard
pattern for auto-commit workflows.

**Bot identity for commits**: Using `github-actions[bot]` with its well-known
email (`41898282+github-actions[bot]@users.noreply.github.com`) is the standard
identity for automated commits. It clearly signals in the git log that the
commit was machine-generated.

**Permissions**: `contents: write` is the only permission needed. This matches
the existing `vibe-coded-badge.yml` pattern. The workflow reads the repo
(checkout), runs a local script, and pushes a commit. No secrets, no external
API calls, no artifacts.

**No `fetch-depth: 0`**: Unlike the vibe-coded-badge workflow, this workflow
does not need full git history. The default shallow clone (`fetch-depth: 1`) is
sufficient because `build-index.sh` reads files from the working tree, not from
git history. This makes checkout faster.

### Do NOT run on PR events

Running on PR events for "preview" is unnecessary and introduces complexity:

1. **No write access on PRs from forks**: PRs from forks run with read-only
   permissions by default. The workflow could not commit a preview index even if
   we wanted it to.

2. **`index.md` is gitignored**: Once index.md is in `.gitignore`, it will not
   appear in PR diffs regardless. There is nothing to "preview."

3. **No value**: The index is a mechanical derivative of report frontmatter.
   Previewing it does not help review the report itself.

4. **YAGNI**: If someone wants to verify the index locally, they run
   `build-index.sh`. That is sufficient.

## Proposed Tasks

### Task 1: Create the GitHub Actions workflow file

**What**: Create `.github/workflows/regenerate-report-index.yml` with the
workflow definition above.

**Deliverable**: `.github/workflows/regenerate-report-index.yml`

**Dependencies**: None. This can be created independently. However, it should be
merged in the same commit/PR as the `.gitignore` change (Task 2 from
devx-minion's plan) to ensure atomicity -- the workflow should not run before
`index.md` is gitignored, and `index.md` should not be gitignored before the
workflow exists to regenerate it.

### Task 2: Verify build-index.sh runs correctly on ubuntu-latest

**What**: Confirm that `build-index.sh` uses only POSIX shell features available
on Ubuntu (the GitHub Actions runner OS). The script header says
`#!/bin/sh` and claims POSIX compatibility. Verify there are no bashisms or
macOS-specific behavior (e.g., BSD sed vs GNU sed).

**Deliverable**: Verification result (pass/fail). The script already looks clean
-- it uses `grep`, `sed`, `sort`, `printf`, `mv`, all of which are POSIX. The
`sed` patterns are basic (no extended regex flags). This is a 2-minute review,
not a rewrite.

**Dependencies**: None.

## Risks and Concerns

### Risk 1: Race condition between merge and workflow run (LOW)

If two PRs merge to main in quick succession, the second merge's push event
fires while the first workflow run is still in progress. The second run checks
out `main` at a newer commit that includes both sets of reports. When the first
run tries to push its commit, the push fails because `main` has moved forward.

**Mitigation**: The `concurrency` key can serialize runs:

```yaml
concurrency:
  group: regenerate-report-index
  cancel-in-progress: false
```

This queues the second run instead of running it concurrently. However, this may
be premature -- the race is only possible when two PRs merge within seconds of
each other, and even then the second workflow run will succeed and produce the
correct index. I recommend adding the `concurrency` key as a defensive measure
since it is a single line and costs nothing, but it is not strictly required for
correctness. The second run always produces the right result.

**Recommendation**: Include the `concurrency` block. It costs nothing and
eliminates a class of transient failures.

### Risk 2: Path filter does not match on first commit (LOW)

When `index.md` is first removed from tracking via `git rm --cached` and added
to `.gitignore`, the same commit should include the new workflow YAML. On that
first push to main, the path filter may or may not trigger depending on whether
the `git rm --cached` of `index.md` counts as a change under the `paths` filter
for `.md` files.

**Mitigation**: This is a one-time transition concern. If the workflow does not
trigger on the initial commit, it will trigger on the next report commit. The
index simply stays absent until then, which is fine -- `index.md` is gitignored
and will be regenerated on the next relevant push.

### Risk 3: Branch protection rules blocking bot pushes (LOW)

If the `main` branch has protection rules that require PRs or status checks for
all pushes, the bot's direct `git push` will be rejected.

**Mitigation**: The existing `vibe-coded-badge.yml` already uses the same
pattern (`git push` from a workflow with `contents: write`). If that workflow
works, this one will too. If branch protection is added later, both workflows
need the same fix (use a GitHub App token or a PAT with bypass permissions).

## Additional Agents Needed

None. The current team (iac-minion for CI/CD, devx-minion for developer workflow
changes) covers all aspects of this task. The security, docs, and UX review
agents in Phase 3.5 are sufficient for validation.
