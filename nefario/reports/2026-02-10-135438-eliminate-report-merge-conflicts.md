---
type: nefario-report
version: 1
date: "2026-02-10"
time: "13:54:38"
task: "Eliminate merge conflicts in nefario report generation during parallel work"
mode: full
agents-involved: [nefario, devx-minion, data-minion, security-minion, test-minion, ux-strategy-minion, software-docs-minion, lucy, margo, code-review-minion]
task-count: 5
gate-count: 1
outcome: completed
---

| Metric | Value |
|--------|-------|
| Date | 2026-02-10 |
| Task | Eliminate merge conflicts in report generation |
| Duration | ~25m |
| Outcome | completed |
| Planning Agents | 2 agents consulted (devx-minion, data-minion) |
| Review Agents | 6 reviewers (Phase 3.5) + 3 reviewers (Phase 5) |
| Execution Agents | 5 agent instances spawned |
| Gates Presented | 1 of 1 approved |
| Files Changed | 1 created, 6 modified |
| Outstanding Items | 1 item |

## Executive Summary

Replaced sequential numbering (NNN) with local timestamps (HHMMSS) in report filenames and replaced manual index mutation with an idempotent `build-index.sh` script that regenerates `index.md` from YAML frontmatter. This eliminates both the TOCTOU race in sequence number assignment and merge conflicts on the shared index file when concurrent nefario sessions produce reports.

## Decisions

#### Timestamps Over Sequence Numbers

**Rationale**:
- Timestamps require no coordination between sessions (each reads its own clock)
- Sub-second collision probability is negligible given multi-minute orchestration runs
- Filenames remain human-readable and naturally sort by date and time

**Alternatives Rejected**:
- UUID-based filenames: not human-readable, don't sort chronologically
- Lock file protocol: doesn't solve git merge conflicts across branches
- Keep sequence numbers with retry: still has TOCTOU window, adds complexity

#### Generated Index Over Mutable Index

**Rationale**:
- Index is a derived view of data already present in report frontmatter
- Idempotent regeneration means any session can rebuild the full index
- Eliminates the concurrent-write problem entirely

**Alternatives Rejected**:
- Append-only index: still conflicts sometimes, loses newest-first ordering
- One-file-per-entry directory: adds file proliferation without benefit over frontmatter parsing

#### No Legacy Migration

**Rationale**:
- Original creation timestamps unavailable for 11 existing reports
- Fabricating timestamps would be misleading
- Dual-format handling in script is ~5 lines, acceptable complexity
- Legacy files naturally become smaller proportion over time

**Conflict Resolutions**: None. Specialists had complementary, non-overlapping recommendations.

## Phases Executed

| Phase | Agents |
|-------|--------|
| Meta-plan | nefario |
| Specialist Planning | devx-minion, data-minion |
| Synthesis | nefario |
| Architecture Review | security-minion, test-minion, ux-strategy-minion, software-docs-minion, lucy, margo |
| Execution | devx-minion (5 tasks) |
| Code Review | code-review-minion, lucy, margo |
| Test Execution | (skipped -- no tests exist) |
| Deployment | (skipped -- not requested) |
| Documentation | (skipped -- docs were the primary deliverables) |

## Files Created/Modified

| File Path | Action | Description |
|-----------|--------|-------------|
| nefario/reports/build-index.sh | created | POSIX shell script to regenerate index.md from report frontmatter |
| nefario/reports/TEMPLATE.md | modified | Naming convention: NNN to HHMMSS, frontmatter: sequence to time, index: script reference |
| skills/nefario/SKILL.md | modified | Wrap-up sequence: timestamp capture and build-index.sh regeneration |
| CLAUDE.md | modified | Orchestration Reports section: reference build-index.sh |
| docs/orchestration.md | modified | Section 5: HHMMSS naming, generated index description |
| docs/decisions.md | modified | Decision 25 added, Decision 14 forward reference |
| nefario/reports/index.md | regenerated | Now produced by build-index.sh from frontmatter |

## Approval Gates

| Gate Title | Agent | Confidence | Outcome | Rounds |
|------------|-------|------------|---------|--------|
| Naming + Index Strategy | nefario (synthesized) | HIGH | approved | 1 |

## Verification

| Phase | Result |
|-------|--------|
| Code Review | 0 BLOCK, 3 ADVISE -- all non-blocking (agent count edge cases, stale AGENT.md ref) |
| Test Execution | (skipped -- no tests exist) |
| Deployment | (skipped -- not requested) |
| Documentation | (skipped -- docs were the primary deliverables) |

## Outstanding Items

- [ ] Update nefario/AGENT.md and AGENT.overrides.md stale reference to NNN naming via /lab rebuild (lucy ADVISE, low priority)

## Timing

| Phase | Duration |
|-------|----------|
| Meta-plan | ~2m |
| Specialist Planning | ~2m |
| Synthesis | ~3m |
| Architecture Review | ~3m (1 BLOCK revision round) |
| Execution | ~10m |
| Code Review | ~2m |
| Test Execution | (skipped) |
| Deployment | (skipped) |
| Documentation | (skipped) |
| **Total** | **~25m** |
