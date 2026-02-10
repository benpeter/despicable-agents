# Meta-Plan: Eliminate Merge Conflicts from Nefario Execution Reports

## Context Analysis

The current report workflow has a remaining merge-conflict vector: `index.md` is
committed to the repo and regenerated during every nefario wrap-up (SKILL.md
step 7). When two branches produce reports concurrently, both modify `index.md`,
causing a conflict on merge.

The prior orchestration (report 135438) already solved the filename collision
problem by moving from sequence numbers (NNN) to timestamps (HHMMSS). But the
index file remains a committed, locally-regenerated artifact.

**Files involved**:
- `docs/history/nefario-reports/index.md` -- the conflict source
- `docs/history/nefario-reports/build-index.sh` -- the idempotent regeneration script
- `skills/nefario/SKILL.md` -- wrap-up step 7 calls build-index.sh
- `docs/history/nefario-reports/TEMPLATE.md` -- step 14 says to run build-index.sh
- `docs/orchestration.md` -- line 530 describes the index as a derived view
- `CLAUDE.md` -- references "regenerate the index by running build-index.sh"
- `.gitignore` -- does NOT currently ignore index.md
- `.github/workflows/vibe-coded-badge.yml` -- existing workflow (pattern reference)

**Core approach**: Gitignore `index.md`, create a GitHub Action to regenerate it
on push to main, and remove the index regeneration step from the nefario
orchestration workflow. The index becomes a CI-only artifact that is never
committed from branches.

## Meta-Plan

### Planning Consultations

#### Consultation 1: CI/CD Workflow for Index Regeneration

- **Agent**: iac-minion
- **Planning question**: What is the simplest GitHub Actions workflow to
  regenerate `docs/history/nefario-reports/index.md` on push to main? The
  workflow should: (1) check out the repo, (2) run the existing POSIX shell
  `build-index.sh` script, (3) commit and push the regenerated index.md if it
  changed. Consider: should this be a separate workflow or added to the existing
  `vibe-coded-badge.yml`? What permissions does it need? How should it handle
  the case where the commit would be empty (no index changes)? Should it also
  run on PR events so contributors can preview the index?
- **Context to provide**: `.github/workflows/vibe-coded-badge.yml` (existing
  workflow pattern), `docs/history/nefario-reports/build-index.sh` (the script
  to run), `.gitignore` (current state)
- **Why this agent**: iac-minion owns GitHub Actions and CI/CD pipeline design.
  The workflow needs to auto-commit, which has permission and infinite-loop
  subtleties.

#### Consultation 2: Developer Workflow and Skill Update

- **Agent**: devx-minion
- **Planning question**: What changes are needed across the nefario skill,
  TEMPLATE.md, CLAUDE.md, and orchestration docs to remove the index
  regeneration step from the local orchestration workflow? Specifically:
  (1) SKILL.md wrap-up step 7 currently calls build-index.sh -- should it be
  removed entirely or replaced with a no-op note?
  (2) TEMPLATE.md step 14 says to regenerate the index -- how should this
  change?
  (3) CLAUDE.md references "regenerate the index by running build-index.sh" --
  what should it say instead?
  (4) orchestration.md line 530 describes the index -- how should the
  description change?
  Also: should `index.md` be deleted from the repo (tracked removal + gitignore)
  or just gitignored going forward? What is the cleanest transition for anyone
  with a local clone?
- **Context to provide**: `skills/nefario/SKILL.md` (lines 854-862, wrap-up
  steps), `docs/history/nefario-reports/TEMPLATE.md` (line 345-348, index
  section), `CLAUDE.md` (lines 59-62), `docs/orchestration.md` (line 530)
- **Why this agent**: devx-minion owns CLI/developer workflow design and
  configuration file updates. The transition must be smooth for anyone who has
  the repo cloned -- the index disappearing from git could confuse if not
  documented.

### Cross-Cutting Checklist

- **Testing**: Exclude from planning. The deliverables are a GitHub Actions
  workflow YAML and doc/config edits. There is no application code to unit test.
  Phase 6 will verify the shell script still runs (build-index.sh is unchanged).
  A manual verification step (run the workflow, check the output) is sufficient.

- **Security**: Exclude from planning. The GitHub Action needs `contents: write`
  permission (same as the existing vibe-coded-badge workflow). No new secrets,
  no new attack surface, no user input processing. Standard Phase 3.5 review by
  security-minion will catch any permission misconfiguration.

- **Usability -- Strategy**: Include in execution review only (Phase 3.5). The
  change simplifies the developer workflow by removing a manual step. No
  planning input needed -- the UX improvement is self-evident (fewer steps =
  better). ux-strategy-minion will confirm during architecture review.

- **Usability -- Design**: Exclude. No user-facing interfaces are produced.

- **Documentation**: Include via devx-minion consultation above. The doc updates
  ARE the deliverable -- devx-minion is planning the exact changes to SKILL.md,
  TEMPLATE.md, CLAUDE.md, and orchestration.md. software-docs-minion will review
  during Phase 3.5.

- **Observability**: Exclude. No runtime components, services, or APIs. The
  GitHub Action is a CI job with built-in GitHub Actions logging.

### Anticipated Approval Gates

**One gate**: The combined approach (gitignore + GitHub Action + doc updates)
should be presented as a single approval gate before execution. This is LOW
blast radius (easy to reverse: re-commit index.md, revert gitignore) and LOW
reversibility cost, so it could arguably skip a gate. However, it touches the
orchestration workflow that governs all future nefario runs, so a single gate is
warranted under the supplementary rule (judgment call with multiple valid
approaches).

Gate candidates considered:
1. "Gitignore index.md vs. keep committing it" -- this is the core decision
2. "Separate workflow vs. extend existing" -- iac-minion's recommendation

These are tightly coupled and should be consolidated into one gate.

### Rationale

Two specialists are consulted:

1. **iac-minion**: Owns GitHub Actions. The CI workflow is the core technical
   deliverable. Getting the auto-commit pattern right (permissions, empty commit
   handling, avoiding infinite trigger loops) requires CI/CD domain expertise.

2. **devx-minion**: Owns developer workflow and configuration. The changes span
   four documentation/configuration files that define how nefario orchestration
   works. Getting the transition right (what to remove, what to add, how to
   handle the tracked-to-untracked file transition) requires developer experience
   expertise.

Other agents considered but excluded from planning:
- **software-docs-minion**: The doc changes are configuration/workflow docs, not
  architecture docs. devx-minion covers this. software-docs-minion reviews in
  Phase 3.5.
- **security-minion**: Standard GitHub Actions permissions. Reviews in Phase 3.5.
- **data-minion**: No data architecture involved. The index is a flat file
  regenerated from frontmatter -- data-minion was consulted in the prior
  iteration (report 135438) and the data model is unchanged.

### Scope

**In scope**:
- Add `docs/history/nefario-reports/index.md` to `.gitignore`
- Remove `index.md` from git tracking (`git rm --cached`)
- Create a GitHub Actions workflow to regenerate `index.md` on push to main
- Remove index regeneration from SKILL.md wrap-up sequence
- Update TEMPLATE.md index section
- Update CLAUDE.md orchestration reports reference
- Update orchestration.md index description

**Out of scope**:
- Report content or template changes (other than the index regeneration step)
- Changes to build-index.sh itself (it works correctly)
- Nefario orchestration logic (phases, planning, execution)
- Report filename convention (already solved by report 135438)
- Anything related to the skill behavior outside of report index generation
