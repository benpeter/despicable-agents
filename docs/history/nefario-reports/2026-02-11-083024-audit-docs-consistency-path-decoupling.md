---
task: "Fix documentation inconsistencies after path decoupling"
date: 2026-02-11
outcome: completed
agents-consulted: 4
agents-executed: 2
gates: 0
files-changed: 5
outstanding-items: 2
---

## Executive Summary

Fixed 4 documentation inconsistencies across 5 files remaining after PR #20 (decouple self-referential path assumptions). All changes are text-only edits to markdown documentation, totaling ~15 lines changed.

## Original Prompt

Audit documentation consistency after path decoupling. Ensure all documentation files are consistent with the changes introduced in PR #20 (decouple self-referential path assumptions), so that readers encounter no stale references to hardcoded paths, no contradictions between docs about scratch directories or report directories, and uniform use of `$SCRATCH_DIR` and cwd-relative detection conventions.

## Changes

### docs/compaction-strategy.md
- Fixed directory structure diagram (lines 33-39) to match SKILL.md's actual `nefario-scratch-XXXXXX` + `{slug}/` subdirectory pattern. Previous diagram showed `nefario-{slug}-XXXXXX` flat structure.

### docs/decisions.md
- Added Note row to Decision 21 (line 278) cross-referencing Decision 26, following the existing annotation pattern from Decision 14. Indicates scratch file path convention is superseded while compaction checkpoint design remains current.

### CLAUDE.md
- Updated line 61: changed report format reference from `docs/history/nefario-reports/TEMPLATE.md` to `skills/nefario/SKILL.md`, reflecting that SKILL.md is the operational authority.

### docs/orchestration.md
- Updated line 474: clarified that SKILL.md is the operational report format authority and TEMPLATE.md is a human-readable reference.

### README.md
- Simplified line 124: removed "(preserved as companion directories in PRs)" parenthetical from the Context Window Pressure limitation description. Internal mechanism detail not appropriate for user-facing documentation.

## Decisions

### Conflict: Scope breadth (margo: 2 tasks vs lucy: 5 tasks)
Resolved at 4 tasks. margo correctly identified compaction-strategy.md and Decision 21 as necessary. Lucy and software-docs-minion correctly identified the TEMPLATE.md authority contradiction (CLAUDE.md and orchestration.md vs SKILL.md) and README parenthetical as genuine issues. commit-workflow.md hardcoded `main` references excluded as a separate concern.

### Conflict: TEMPLATE.md disposition
software-docs-minion recommended adding a header note to TEMPLATE.md itself. Excluded as belt-and-suspenders -- the role clarification in referencing documents (CLAUDE.md, orchestration.md) is sufficient.

## Agent Contributions

### Planning Phase
| Agent | Role | Key Recommendation |
|-------|------|-------------------|
| software-docs-minion | Architecture docs | 3 stale items: Decision 21, orchestration.md TEMPLATE.md claim, CLAUDE.md reference |
| user-docs-minion | User-facing docs | README.md parenthetical misleading; using-nefario.md already clean |
| lucy | Consistency | 6 findings across 4 dimensions; TEMPLATE.md authority contradiction most significant |
| margo | Simplicity | Only 2 files genuinely need changes; risk of over-engineering |

### Review Phase
| Agent | Verdict | Notes |
|-------|---------|-------|
| security-minion | APPROVE | No security implications for doc-only changes |
| test-minion | ADVISE | Recommended verification grep checks (incorporated) |
| ux-strategy-minion | APPROVE | Changes improve clarity and reduce cognitive load |
| software-docs-minion | APPROVE | Cross-references verified accurate |
| lucy | APPROVE | All success criteria covered; convention compliance confirmed |
| margo | ADVISE | Accepted 4-task scope; flagged CLAUDE.md as high-traffic file |

### Execution Phase
| Agent | Task | Outcome |
|-------|------|---------|
| software-docs-minion | Tasks 1-3 (compaction-strategy, Decision 21, TEMPLATE.md refs) | Completed |
| user-docs-minion | Task 4 (README.md simplification) | Completed |

## Verification

- Code review: 3 APPROVE (code-review-minion, lucy, margo)
- Tests: 14/14 passed (test-no-hardcoded-paths.sh)
- Documentation: skipped (this task IS the documentation update)

## Outstanding Items

- [ ] `docs/commit-workflow.md`: 5+ hardcoded `main` references need updating to dynamic default branch detection (separate PR)
- [ ] `nefario/scratch/` directory: still exists on disk with legacy files; cleanup is not a documentation task (separate PR)

## Working Files

Companion directory: `docs/history/nefario-reports/2026-02-11-083024-audit-docs-consistency-path-decoupling/`

Files:
- prompt.md
- phase1-metaplan.md
- phase2-software-docs-minion.md
- phase2-user-docs-minion.md
- phase2-lucy.md
- phase2-margo.md
- phase3-synthesis.md
