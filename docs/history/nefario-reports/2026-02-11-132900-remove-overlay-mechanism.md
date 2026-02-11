---
task: "Remove overlay mechanism, hand-maintain nefario"
source-issue: 32
date: 2026-02-11
duration: ~20 min
status: completed
slug: remove-overlay-mechanism
---

## Executive Summary

Removed the overlay mechanism from the despicable-agents project (Option B from issue #32). Deleted ~2,900 lines of infrastructure that served only 1 of 27 agents. Marked nefario as hand-maintained. Added Decision 27 encoding the "one-agent rule": do not build infrastructure for patterns until 2+ agents exhibit the need.

## Original Prompt

Remove the overlay mechanism (Option B: hand-maintain nefario). Delete all overlay infrastructure and mark nefario as hand-maintained. ~2,900 lines of infrastructure for 1 of 27 agents violates YAGNI, KISS, and Lean-and-Mean.

## Execution

### Tasks Completed (10)

| # | Task | Agent | Outcome |
|---|------|-------|---------|
| 1 | Delete overlay artifacts | general-purpose | 5 files + tests/ dir deleted |
| 2 | Remove x-fine-tuned from nefario/AGENT.md | general-purpose | 1 line removed |
| 3 | Move overlay-decision-guide to history | general-purpose | git mv to docs/history/ |
| 4 | Simplify despicable-lab SKILL.md | devx-minion | Overlay branching removed, nefario skip added (-14 lines) |
| 5 | Update agent-anatomy.md | software-docs-minion | Overlay section removed (258 -> 62 lines) |
| 6 | Update build-pipeline.md | software-docs-minion | Merge Step removed, simplified (-12 lines) |
| 7 | Add Decision 27, supersede D9/D16 | software-docs-minion | D27 added, D9/D16 status updated |
| 8 | Update architecture.md + deployment.md | software-docs-minion | Table row + 1 line updated |
| 9 | Remove x-fine-tuned from the-plan.md | general-purpose | Comment lines removed (user-approved override) |
| 10 | Verify no stale references | general-purpose | All 7 search terms clean, all 7 existence checks pass |

### Files Changed

**Deleted** (5 files + 1 directory):
- `validate-overlays.sh` (659 lines)
- `nefario/AGENT.generated.md` (434 lines)
- `nefario/AGENT.overrides.md` (311 lines)
- `docs/override-format-spec.md` (660 lines)
- `docs/validate-overlays-spec.md` (400 lines)
- `tests/` (entire directory: 4 scripts, 1 README, 10 fixture directories)

**Moved**:
- `docs/overlay-decision-guide.md` -> `docs/history/overlay-decision-guide.md`

**Modified** (8 files):
- `nefario/AGENT.md` -- removed x-fine-tuned from frontmatter
- `.claude/skills/despicable-lab/SKILL.md` -- removed overlay branching, added nefario skip (134 -> 120 lines)
- `docs/agent-anatomy.md` -- removed overlay section (258 -> 62 lines)
- `docs/build-pipeline.md` -- removed Merge Step (190 -> 178 lines)
- `docs/decisions.md` -- added D27, updated D9/D16 status (356 -> 372 lines)
- `docs/architecture.md` -- updated sub-documents table row
- `docs/deployment.md` -- simplified file reference
- `the-plan.md` -- removed x-fine-tuned comment (user-approved override of issue constraint)

## Decisions

### Decision 27: Remove Overlay Mechanism, Hand-Maintain Nefario

- **Choice**: Remove overlay entirely. Apply "one-agent rule".
- **Supersedes**: Decision 9 (Overlay Files), Decision 16 (Validation-Only Drift Detection)
- **Rationale**: ~2,900 lines serving 1 agent violates YAGNI/KISS/Lean-and-Mean
- **Consequences**: Simpler pipeline, reduced learning curve. Trade-off: nefario spec drift undetected by tooling.

## Agent Contributions

### Planning Phase

| Agent | Recommendation |
|-------|---------------|
| devx-minion | SKILL.md has 3 overlay touchpoints; add nefario skip with clear error messaging |
| software-docs-minion | 6 docs need updates with 13 cross-reference locations; D27 follows Nygard table format |

### Review Phase (Architecture)

| Agent | Verdict | Key Finding |
|-------|---------|------------|
| security-minion | APPROVE | Pure deletion, no security implications |
| test-minion | ADVISE | No test for skip condition (consistent with project approach) |
| ux-strategy-minion | APPROVE | Error messaging meets information-needs pattern |
| software-docs-minion | ADVISE | Cross-reference audit, decision formatting |
| lucy | BLOCK -> APPROVE | 2 files missing from deletion list (docs/override-format-spec.md, docs/validate-overlays-spec.md) -- fixed in revision |
| margo | APPROVE | Net strongly negative complexity budget |

### Review Phase (Code)

| Agent | Verdict | Key Finding |
|-------|---------|------------|
| code-review-minion | APPROVE | Clean implementation, no security issues |
| lucy | ADVISE | D15 Consequences references AGENT.overrides.md (accepted: decisions are immutable) |
| margo | APPROVE | No new complexity introduced |

## Verification

Verification: code review passed (2 APPROVE, 1 ADVISE). Skipped: tests (none exist).

Verification sweep: All 7 search terms clean across active project files. All 7 file existence checks pass. Only expected hits in immutable history files and decision records.

## Working Files

Companion directory: `docs/history/nefario-reports/2026-02-11-132900-remove-overlay-mechanism/`

Files:
- `prompt.md` -- original task description
- `phase1-metaplan.md` -- nefario meta-plan
- `phase2-devx-minion.md` -- devx-minion planning contribution
- `phase2-software-docs-minion.md` -- software-docs-minion planning contribution
- `phase3-synthesis.md` -- synthesized execution plan
- `phase3.5-lucy.md` -- lucy architecture review (BLOCK, then APPROVE after revision)
- `phase3.5-test-minion.md` -- test-minion architecture review (ADVISE)
- `phase3.5-software-docs-minion.md` -- software-docs-minion architecture review (ADVISE)
- `phase5-code-review-minion.md` -- code review findings
- `phase5-lucy.md` -- lucy code review findings
- `phase5-margo.md` -- margo code review findings
