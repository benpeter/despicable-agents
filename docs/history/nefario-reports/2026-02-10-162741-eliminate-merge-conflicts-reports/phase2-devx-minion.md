# Domain Plan Contribution: devx-minion

## Recommendations

### 1. Tracked Removal + Gitignore (not gitignore-only)

The cleanest transition is a two-step tracked removal:

1. Add `docs/history/nefario-reports/index.md` to `.gitignore`
2. Remove it from tracking with `git rm --cached docs/history/nefario-reports/index.md`
3. Commit both changes together

This is better than gitignore-only because:
- Gitignore only affects untracked files. If index.md is already tracked, `.gitignore` alone does nothing -- git continues tracking it.
- The `git rm --cached` removes it from the index without deleting the local file, so anyone who runs `build-index.sh` locally still gets their local copy.
- For existing clones: after pulling this change, index.md disappears from tracking. If they had local modifications, git will warn them. Since index.md is a derived file, losing local changes to it is harmless.
- No special migration steps needed for existing clones. `git pull` handles it.

### 2. SKILL.md Wrap-up Changes

The current wrap-up sequence (lines 854-866) has index regeneration as step 7:

```
7. **Regenerate index** by running `docs/history/nefario-reports/build-index.sh`
```

**Recommendation: Remove step 7 entirely and renumber.** Do not replace with a comment or no-op note. A commented-out step creates confusion about whether it should be un-commented. The wrap-up sequence should only contain steps the orchestrator actually executes. The fact that CI handles the index is documented elsewhere (TEMPLATE.md, orchestration.md) -- it does not belong in an executable procedure.

After removal, the wrap-up steps become:

| Current | New | Description |
|---------|-----|-------------|
| 7. Regenerate index | (removed) | |
| 8. Commit the report | 7. Commit the report | |
| 9. Offer PR creation | 8. Offer PR creation | |
| 10. Return to main | 9. Return to main | |
| 11. Present report path | 10. Present report path | |
| 12. Send shutdown_request | 11. Send shutdown_request | |
| 13. TeamDelete | 12. TeamDelete | |
| 14. Report final status | 13. Report final status | |

Also update the earlier reference in the "Verify and report" step (current step 9, line 859) which says "write report, update index, present to user" -- change to "write report, present to user".

### 3. TEMPLATE.md Changes

The "Index File Update" section (lines 342-355) currently instructs the report writer to run `build-index.sh` after writing the report. The section also contains valuable context about the index being idempotent and a derived view.

**Recommendation: Rewrite the section** to explain that the index is CI-generated, not locally generated. Keep the explanation of what the script does (for contributors who want to preview locally) but make clear it is not part of the orchestration workflow.

Proposed replacement for the "Index File Update" section:

```markdown
## Index File

The report index (`docs/history/nefario-reports/index.md`) is a derived view
generated automatically by CI on push to main. It is not committed from branches
and is not part of the orchestration workflow.

The index is built by `docs/history/nefario-reports/build-index.sh`, which reads
YAML frontmatter from all report files and produces a chronological table. The
script is idempotent -- running it multiple times produces the same output.

To preview the index locally: `docs/history/nefario-reports/build-index.sh`
```

Also update the "Report Writing Checklist" at the bottom. Current step 14:

```
14. Regenerate index by running docs/history/nefario-reports/build-index.sh
```

**Remove step 14 entirely.** The checklist should end at step 13 (Write Metrics). The index is CI-managed.

### 4. CLAUDE.md Changes

The current "Orchestration Reports" section (lines 58-62):

```markdown
## Orchestration Reports

After completing nefario orchestration (conversations involving META-PLAN or SYNTHESIS phases),
generate an execution report following the template at `docs/history/nefario-reports/TEMPLATE.md` and
regenerate the index by running `docs/history/nefario-reports/build-index.sh`.
```

**Recommendation: Remove the index regeneration instruction.** The sentence should end after the template reference. CLAUDE.md is read by every agent -- it should not contain stale instructions about a step that no longer happens locally.

Proposed replacement:

```markdown
## Orchestration Reports

After completing nefario orchestration (conversations involving META-PLAN or SYNTHESIS phases),
generate an execution report following the template at `docs/history/nefario-reports/TEMPLATE.md`.
The report index is regenerated automatically by CI on push to main.
```

### 5. orchestration.md Changes

Section 5 "Execution Reports" (lines 527-530) describes the index:

```markdown
### Index

All reports are cataloged in `docs/history/nefario-reports/index.md`, a table listing date, time, task summary (as a link to the report), outcome, and agent count. The index is a derived view, regenerated by `docs/history/nefario-reports/build-index.sh` from report frontmatter. It provides a chronological view of all orchestration runs for cross-run analysis.
```

**Recommendation: Update to reflect CI-based regeneration.** The description of what the index contains is still accurate. Only the regeneration mechanism changes.

Proposed replacement:

```markdown
### Index

All reports are cataloged in `docs/history/nefario-reports/index.md`, a table listing date, time, task summary (as a link to the report), outcome, and agent count. The index is a derived view, regenerated automatically by CI (GitHub Actions) on push to main. The build script (`docs/history/nefario-reports/build-index.sh`) can also be run locally to preview the index. It provides a chronological view of all orchestration runs for cross-run analysis.
```

### 6. Transition Experience for Existing Clones

The transition is seamless and requires no manual action from anyone with an existing clone:

1. They pull the branch containing these changes.
2. Git removes index.md from tracking (because of `git rm --cached`).
3. Their local index.md file remains on disk (untracked, now gitignored).
4. Next time CI runs on main, the index is regenerated and visible on GitHub.
5. If they want a local index, they can run `build-index.sh` themselves.

There is no "gotcha" here. The worst case is someone notices index.md disappeared from `git status` and wonders why. The commit message and PR description should mention this explicitly.

## Proposed Tasks

### Task 1: Remove index.md from git tracking and add to gitignore

- **What**: Add `docs/history/nefario-reports/index.md` to `.gitignore`. Run `git rm --cached docs/history/nefario-reports/index.md` to untrack it.
- **Deliverables**: Updated `.gitignore`, index.md removed from git index
- **Dependencies**: None (can run first)

### Task 2: Update SKILL.md wrap-up sequence

- **What**: Remove step 7 (index regeneration) from the wrap-up sequence. Renumber steps 8-14 to 7-13. Update the "Verify and report" step reference in step 9 (line 859) to remove "update index" from the description.
- **Deliverables**: Updated `skills/nefario/SKILL.md`
- **Dependencies**: None (independent of Task 1)

### Task 3: Update TEMPLATE.md

- **What**: Rewrite the "Index File Update" section to describe CI-based regeneration. Remove step 14 from the Report Writing Checklist.
- **Deliverables**: Updated `docs/history/nefario-reports/TEMPLATE.md`
- **Dependencies**: None (independent)

### Task 4: Update CLAUDE.md

- **What**: Remove the `build-index.sh` instruction from the Orchestration Reports section. Add a note that the index is CI-generated.
- **Deliverables**: Updated `CLAUDE.md`
- **Dependencies**: None (independent)

### Task 5: Update orchestration.md

- **What**: Update the Index subsection in Section 5 to describe CI-based regeneration instead of local regeneration.
- **Deliverables**: Updated `docs/orchestration.md`
- **Dependencies**: None (independent)

Note: Tasks 1-5 are all independent of each other and of the GitHub Actions workflow (which iac-minion will plan). They can be executed in parallel or as a single batch. Given the small scope (one-line to paragraph-level edits in 5 files), a single agent could handle all 5 in one task to minimize orchestration overhead.

**Consolidation recommendation**: Tasks 2-5 are all documentation edits with no interdependencies. They should be a single execution task assigned to one agent (devx-minion or software-docs-minion) to avoid the overhead of spawning 4 agents for 4 paragraph edits. Task 1 (git operations) is a separate concern and should be its own task.

## Risks and Concerns

### Risk 1: Stale local index after transition (LOW)

After the transition, developers who previously relied on a local index.md will have a stale copy. This is a non-issue because: (a) the index is viewable on GitHub via the main branch, (b) anyone who wants a local copy can run `build-index.sh`, and (c) the index is not used by any tooling -- it is a human-readable catalog.

**Mitigation**: The TEMPLATE.md update includes instructions for local preview.

### Risk 2: CI workflow must not trigger itself (MEDIUM)

The GitHub Action that commits the regenerated index must not trigger another workflow run, creating an infinite loop. The standard fix is using a GitHub App token or `[skip ci]` in the commit message. This is iac-minion's domain, but devx-minion flags it as a concern to ensure it is addressed in the CI workflow design.

**Mitigation**: Defer to iac-minion's plan for the workflow. Verify during Phase 3.5 review.

### Risk 3: Window where index.md does not exist on main (LOW)

Between the PR merging (which removes index.md from tracking) and the CI workflow running (which regenerates it), there is a brief window where index.md does not exist on the main branch. This is a few seconds at most and is harmless -- the index is informational, not functional.

**Mitigation**: Accept as negligible. The CI workflow runs on push to main, so the gap is the duration of the workflow itself.

### Risk 4: build-index.sh output path must remain stable (LOW)

The CI workflow and the local preview both depend on `build-index.sh` writing to `docs/history/nefario-reports/index.md`. If the script's output path changes, both break. Since build-index.sh is out of scope for this task (and works correctly), this is a future maintenance concern, not an immediate risk.

**Mitigation**: None needed now. The script's behavior is stable.

## Additional Agents Needed

None. The two-agent consultation (iac-minion for CI workflow, devx-minion for developer workflow and documentation) covers the full scope. The standard Phase 3.5 reviewers (security-minion, test-minion, ux-strategy-minion, software-docs-minion, lucy, margo) will catch any gaps during architecture review.
