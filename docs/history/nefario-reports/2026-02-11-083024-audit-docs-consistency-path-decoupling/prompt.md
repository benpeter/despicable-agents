Audit documentation consistency after path decoupling

**Outcome**: All documentation files are consistent with the changes introduced in PR #20 (decouple self-referential path assumptions), so that readers encounter no stale references to hardcoded paths, no contradictions between docs about scratch directories or report directories, and uniform use of `$SCRATCH_DIR` and cwd-relative detection conventions.

**Success criteria**:
- No remaining references to hardcoded `nefario/scratch/` paths in docs (should be `$SCRATCH_DIR`)
- Scratch directory and report directory descriptions are consistent across all docs that mention them
- Cross-references between docs/orchestration.md, docs/deployment.md, docs/architecture.md, docs/compaction-strategy.md, and SKILL.md are accurate
- Terminology for the decoupled path model is uniform (no mix of old and new conventions)
- CLAUDE.md project instructions align with the new directory conventions

**Scope**:
- In: docs/*.md, skills/nefario/SKILL.md, CLAUDE.md, README.md, install.sh inline comments
- Out: AGENT.md system prompts, RESEARCH.md files, the-plan.md, nefario execution reports (docs/history/), test files

**Constraints**:
- Limit specialist involvement to software-docs-minion, user-docs-minion, lucy, and margo
- Stay in the scope of this PR (any changes go to the existing feature branch)
