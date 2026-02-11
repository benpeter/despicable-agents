# Meta-Plan: Remove Overlay Mechanism (Option B)

## Task Summary

Delete all overlay infrastructure (~2,900 lines) and mark nefario as hand-maintained. nefario/AGENT.md is already the fully merged result -- no content is lost. This is a cleanup/simplification task: delete files, update documentation, add a decision record, and simplify the build skill.

## Meta-Plan

### Planning Consultations

#### Consultation 1: Build Pipeline Simplification
- **Agent**: devx-minion
- **Planning question**: Given the scope of overlay references across the codebase (73 files match, though most are in `docs/history/` reports which should NOT be modified), what is the precise edit list for `/despicable-lab` SKILL.md? The current SKILL.md has overlay branching in Step 2 of the build process (lines 93-107: "For agents WITHOUT overrides" vs "For agents WITH overrides") and overlay drift detection in the version check section (lines 37-58). What should the simplified SKILL.md look like after removing all overlay logic and adding a nefario skip condition?
- **Context to provide**: `.claude/skills/despicable-lab/SKILL.md` (full file), `docs/build-pipeline.md` (Merge Step section and cross-check references), the issue scope constraints (do NOT modify the-plan.md or nefario/AGENT.md)
- **Why this agent**: devx-minion owns CLI/skill design and developer workflow. The SKILL.md edit is the most logic-intensive change -- it needs to correctly skip nefario while preserving the pipeline for 26 other agents.

#### Consultation 2: Documentation Update Strategy
- **Agent**: software-docs-minion
- **Planning question**: Six documentation files need updates (agent-anatomy.md, build-pipeline.md, decisions.md, architecture.md, deployment.md, overlay-decision-guide.md). For agent-anatomy.md specifically: after removing the ~130-line "Overlay Mechanism" section, should the document be retitled to just "Agent Anatomy" (as the issue specifies), and does the remaining content (AGENT.md Structure, RESEARCH.md Structure) stand on its own without any bridging text? For decisions.md: what should the new decision record look like that supersedes D9 and D16, including the "one-agent rule" constraint from lucy's recommendation? For deployment.md: line 43 mentions AGENT.generated.md and AGENT.overrides.md -- what should replace that sentence?
- **Context to provide**: `docs/agent-anatomy.md`, `docs/build-pipeline.md`, `docs/decisions.md` (D9 and D16 specifically), `docs/architecture.md` (sub-documents table), `docs/deployment.md` (line 43), `docs/overlay-decision-guide.md`
- **Why this agent**: software-docs-minion owns architecture documentation. Multiple interconnected docs need coordinated updates, and the decision record needs to follow the established format in decisions.md while capturing the right rationale.

### Cross-Cutting Checklist

- **Testing**: EXCLUDE from planning. The task deletes the entire test suite (`tests/fixtures/`, `tests/run-tests.sh`, `tests/README.md`) because it tests overlay validation which is being removed. There is no new code to test. The verification step (checking install.sh and other scripts for stale references) is a manual grep, not an automated test. test-minion will still review in Phase 3.5.
- **Security**: EXCLUDE from planning. No attack surface changes -- this is pure deletion of build infrastructure and documentation updates. No auth, secrets, user input, or new dependencies. security-minion will still review in Phase 3.5.
- **Usability -- Strategy**: EXCLUDE from planning consultation. This task has no user-facing behavior change -- it simplifies internal build infrastructure. The developer experience improvement (simpler mental model, fewer files to understand) is straightforward and does not need strategic UX analysis during planning. ux-strategy-minion will still review in Phase 3.5.
- **Usability -- Design**: EXCLUDE. No user-facing interfaces produced.
- **Documentation**: INCLUDED as Consultation 2 (software-docs-minion). Six documentation files need coordinated updates.
- **Observability**: EXCLUDE. No runtime components, services, or APIs involved.

### Anticipated Approval Gates

**Zero gates recommended.** Rationale:

This task is entirely prescribed by the issue. Every file to delete, every file to update, and the specific content changes are enumerated. The decision (Option B) has already been made by the user based on a thorough analysis document. All changes are:

1. **Easy to reverse**: File deletions are recoverable from git. Documentation edits are additive (decision record) or subtractive (removing sections). No schema changes, no API contracts, no data migrations.
2. **Low blast radius**: No downstream tasks depend on these changes. The overlay mechanism is being removed precisely because nothing depends on it except itself.

The only judgment-requiring artifact is the new decision record in decisions.md, but the issue prescribes its content (Option B chosen, rationale: KISS, include one-agent rule). The decision record format is established by 16 prior entries.

If synthesis produces a multi-task plan, individual task completion can be verified by the Phase 5 code review and Phase 3.5 architecture review without blocking gates.

### Rationale

Only two specialists are consulted for planning because this task is well-scoped deletion with documentation cleanup:

1. **devx-minion** is consulted because the SKILL.md edit requires understanding the build pipeline logic and correctly implementing the nefario skip condition without breaking the 26-agent pipeline. This is the only change with functional logic (as opposed to file deletion or prose editing).

2. **software-docs-minion** is consulted because six interconnected documentation files need coordinated updates, including a new decision record that must follow the established format and correctly reference/supersede two prior decisions.

Other agents (security, test, ux-strategy, observability) are not consulted for planning because their review concerns are adequately covered by Phase 3.5 mandatory review. The task produces no code, no runtime components, no user-facing interfaces, and no new attack surface. Their Phase 3.5 review will catch any issues the plan misses.

### Scope

**In scope**:
- Delete 6 files: `nefario/AGENT.generated.md`, `nefario/AGENT.overrides.md`, `validate-overlays.sh`, `docs/override-format-spec.md`, `docs/validate-overlays-spec.md`
- Delete 1 directory tree: `tests/fixtures/` (10 directories, 34 files) + `tests/run-tests.sh` + `tests/README.md` (entire `tests/` directory)
- Update 5 docs: `docs/agent-anatomy.md`, `docs/build-pipeline.md`, `docs/decisions.md`, `docs/architecture.md`, `docs/deployment.md`
- Move 1 doc: `docs/overlay-decision-guide.md` to `docs/history/`
- Update 1 skill: `.claude/skills/despicable-lab/SKILL.md`
- Remove `x-fine-tuned` from `nefario/AGENT.md` frontmatter
- Remove overlay references from `the-plan.md` frontmatter comment (lines 44-45)
- Verify: `install.sh` has no stale overlay references (confirmed clean by reading -- no overlay references found)
- Verify: No CI/scripts reference deleted files (need to check `.github/` if it exists)

**Out of scope**:
- Modifying `the-plan.md` agent specs (explicitly forbidden by constraints)
- Modifying `nefario/AGENT.md` system prompt content (explicitly forbidden -- only frontmatter `x-fine-tuned` removal)
- Modifying files in `docs/history/nefario-reports/` (historical reports are immutable records)
- Modifying `nefario/scratch/` files (session-specific, gitignored)
- Choosing between Option A/B/C (decision already made: Option B)
