---
type: nefario-report
version: 3
date: "2026-02-13"
time: "09:15:27"
task: "Remove software-docs-minion from mandatory Phase 3.5 reviewers, replace with ux-strategy-minion, simplify Phase 8 checklist derivation"
source-issue: 80
mode: full
agents-involved: [nefario, software-docs-minion, lucy, margo, security-minion, test-minion, code-review-minion]
task-count: 4
gate-count: 1
outcome: completed
---

# Remove software-docs-minion from mandatory Phase 3.5 reviewers, replace with ux-strategy-minion, simplify Phase 8 checklist derivation

## Summary

Swapped software-docs-minion for ux-strategy-minion in the mandatory Phase 3.5 Architecture Review roster across all four governing artifacts (the-plan.md, SKILL.md, AGENT.md, docs/orchestration.md). Simplified Phase 8 Documentation to derive its checklist solely from execution outcomes instead of merging a Phase 3.5 pre-analysis checklist with post-execution results. Code review caught and fixed stale references in README.md, docs/decisions.md, and a missed "6 discretionary" count in SKILL.md.

## Original Prompt

> **Outcome**: Phase 3.5 Architecture Review drops from 6 to 5 mandatory reviewers by removing software-docs-minion, and Phase 8 (Documentation) self-derives its work order from the synthesis plan and execution outcomes instead of merging two sources. This eliminates one agent call per orchestration and removes divergence-flagging complexity from Phase 8 — without risk, since missed docs notes are cheap to fix post-execution.
>
> **Success criteria**:
> - ALWAYS reviewers list is: security-minion, test-minion, ux-strategy-minion, lucy, margo
> - software-docs-minion no longer runs during Phase 3.5
> - Phase 3.5 no longer produces phase3.5-docs-checklist.md
> - Phase 8 derives its checklist solely from synthesis plan + execution outcomes
> - Phase 8 assigns owner tags and priority itself (single-source, no divergence flagging)
> - software-docs-minion custom Phase 3.5 prompt removed from SKILL.md
> - user-docs-minion remains in the discretionary Phase 3.5 reviewer pool (unchanged)
> - Cross-cutting checklist "Documentation (ALWAYS)" item in Phase 1 remains (unchanged)
> - All artifacts updated: the-plan.md, nefario AGENT.md, nefario SKILL.md, docs/orchestration.md
> - the-plan.md changes pass the gate (see Constraints)

## Key Design Decisions

#### Outcome-action table as single source for Phase 8

**Rationale**:
- The outcome-action table already existed and covered ~95% of documentation needs
- Scanning synthesis plan tasks first risks generating checklist items for planned-but-not-executed work
- Owner tags and priority are mechanical lookups from the table, not specialist judgment

**Alternatives Rejected**:
- Synthesis plan as primary driver: Rejected because it would re-introduce complexity by processing planned work that may not have been executed
- Doc agents self-assign owner tags: Rejected because tags are a mechanical lookup (lucy's recommendation)

#### Derivative documentation row added to SKILL.md outcome-action table

**Rationale**:
- software-docs-minion identified that ~5% of Phase 3.5 checklist value comes from spotting derivative docs (files that reference changed behavior but aren't plan deliverables)
- Adding one table row closes this gap mechanically without requiring a specialist agent call

**Alternatives Rejected**:
- No derivative-docs row (margo's YAGNI recommendation): Overridden because the gap is real and the mitigation is a single table row, not a new mechanism

### Conflict Resolutions

**ux-strategy-minion promotion**: Lucy flagged this as scope drift from the meta-plan during planning. The user's task description explicitly includes ux-strategy-minion in the success criteria mandatory list. User's task is authoritative — the promotion is in scope.

## Phases

### Phase 1: Meta-Plan

Nefario identified 2 specialists for planning consultation: software-docs-minion (the agent being removed, uniquely positioned to assess what Phase 3.5 checklist value would be lost) and lucy (intent alignment for Phase 8 single-source derivation). External skill scan found no relevant skills.

### Phase 2: Specialist Planning

software-docs-minion confirmed the removal is safe — approximately 95% of its Phase 3.5 output is mechanically derivable from the outcome-action table. The remaining 5% (derivative documentation consistency) can be addressed by adding one row to the table. lucy recommended the outcome-action table remain the primary driver for Phase 8 and that owner tags/priority be assigned by the orchestrator. Lucy also caught a count error in the issue text ("6 to 5" should reflect a composition change, not a count reduction) and flagged 14 specific locations across 4 files needing updates.

### Phase 3: Synthesis

Nefario produced a 4-task execution plan with 1 approval gate on the-plan.md (canonical spec). Tasks organized in 2 batches: Task 1 (the-plan.md, gated) then Tasks 2-4 (SKILL.md, AGENT.md, orchestration.md) in parallel. Conflict between lucy and the user's task on ux-strategy-minion promotion resolved in favor of the user's explicit success criteria.

### Phase 3.5: Architecture Review

5 mandatory reviewers (security-minion, test-minion, software-docs-minion, lucy, margo). No discretionary reviewers needed. All 3 APPROVE, 2 ADVISE, 0 BLOCK. Lucy flagged the derivative-docs row as scope addition. Margo flagged it as YAGNI. Both non-blocking.

### Phase 4: Execution

Batch 1: Task 1 (the-plan.md) completed by software-docs-minion. 4 targeted edits: Phase 3.5 description, mandatory table, discretionary table, pool size reference. Gate approved by user. Batch 2: Tasks 2-4 executed in parallel. All completed successfully. Total: 4 files changed in scope, +8/-11 lines (the-plan.md), +42/-90 lines (SKILL.md), +12/-12 lines (AGENT.md), +9/-9 lines (orchestration.md).

### Phase 5: Code Review

3 reviewers: code-review-minion (APPROVE), lucy (ADVISE — 3 findings), margo (ADVISE — 1 finding). Findings: (1) SKILL.md line 841 had stale "6 discretionary" reference, (2) README.md lines 14 and 64 still referenced software-docs-minion as mandatory, (3) decisions.md had stale pool size references. All 3 findings auto-fixed.

### Phase 6: Test Execution

Skipped (no test infrastructure in project).

### Phase 7: Deployment

Skipped (not requested).

### Phase 8: Documentation

Skipped (changes are self-documenting — the 4 target files are documentation/configuration artifacts).

<details>
<summary>Agent Contributions (2 planning, 5 review)</summary>

### Planning

**software-docs-minion**: Confirmed removal is safe. ~95% of Phase 3.5 checklist value is mechanically derivable from outcome-action table. Recommended derivative-docs row to close the 5% gap.
- Adopted: Derivative-docs row added to SKILL.md outcome-action table
- Risks flagged: Slightly less precise checklists for subtle documentation implications

**lucy**: Recommended outcome-action table as primary driver for Phase 8. Owner tags and priority assigned by orchestrator. Flagged 14 locations across 4 files for consistency.
- Adopted: Single-source derivation with orchestrator-assigned tags. Location checklist incorporated into task prompts.
- Risks flagged: Consistency risk across 4 files; count error in issue text

### Architecture Review

**security-minion**: APPROVE. No security concerns — documentation/configuration changes only.

**test-minion**: APPROVE. No executable code produced.

**software-docs-minion**: APPROVE. Plan has adequate documentation coverage. 1 SHOULD-priority ADR item identified.

**lucy**: ADVISE. Derivative-docs row is scope addition (noted, non-blocking). Agent assignment convention mismatch (non-blocking).

**margo**: ADVISE. YAGNI flag on derivative-docs row. Net complexity reduction confirmed.

### Code Review

**code-review-minion**: APPROVE. Cross-file consistency verified across all 4 changed files.

**lucy**: ADVISE. Found 3 stale references: SKILL.md "6 discretionary", README.md mandatory list (2 locations), decisions.md pool sizes.

**margo**: ADVISE. Found stale references in decisions.md. Confirmed changes are proportional and complexity-reducing.

</details>

## Execution

### Tasks

| # | Task | Agent | Status |
|---|------|-------|--------|
| 1 | Update the-plan.md (GATED) | software-docs-minion | completed |
| 2 | Update skills/nefario/SKILL.md | software-docs-minion | completed |
| 3 | Update nefario/AGENT.md | software-docs-minion | completed |
| 4 | Update docs/orchestration.md | software-docs-minion | completed |

### Files Changed

| File | Action | Description |
|------|--------|-------------|
| [the-plan.md](../../../the-plan.md) | modified | Swapped software-docs-minion for ux-strategy-minion in mandatory Phase 3.5 reviewers, updated discretionary pool |
| [skills/nefario/SKILL.md](../../../skills/nefario/SKILL.md) | modified | Replaced custom prompt, simplified Phase 8 merge to single-source, updated pool references |
| [nefario/AGENT.md](../../../nefario/AGENT.md) | modified | Updated mandatory reviewer table and synthesis template, removed exception paragraph |
| [docs/orchestration.md](../../../docs/orchestration.md) | modified | Updated reviewer tables and Phase 8 description |
| [README.md](../../../README.md) | modified | Updated mandatory reviewer list in 2 locations (code review fix) |
| [docs/decisions.md](../../../docs/decisions.md) | modified | Added update notes to Decisions 10, 12, 18; fixed pool size in Decision 15 (code review fix) |

### Approval Gates

| Gate Title | Agent | Confidence | Outcome | Rounds |
|------------|-------|------------|---------|--------|
| Update the-plan.md | software-docs-minion | HIGH | approved | 1 |

#### Update the-plan.md

**Decision**: Swap software-docs-minion for ux-strategy-minion in mandatory Phase 3.5 reviewers. Update discretionary pool from 6 to 5 members.
**Rationale**: Narrowly scoped changes (4 edits) matching the user's explicit success criteria. No other sections touched. Phase 8 description already described self-derivation.
**Rejected**: Adding derivative-docs row to the-plan.md outcome-action table (exceeds the-plan.md change scope constraint).
**Confidence**: HIGH
**Outcome**: approved

## Verification

| Phase | Result |
|-------|--------|
| Code Review | 3 findings auto-fixed (SKILL.md pool size, README.md reviewer list, decisions.md stale references) |
| Test Execution | Skipped (no test infrastructure) |
| Deployment | Skipped (not requested) |
| Documentation | Skipped (changes are self-documenting) |

## Working Files

<details>
<summary>Working files (24 files)</summary>

Companion directory: [2026-02-13-091527-remove-software-docs-phase35/](./2026-02-13-091527-remove-software-docs-phase35/)

- [Original Prompt](./2026-02-13-091527-remove-software-docs-phase35/prompt.md)

**Outputs**
- [Phase 1: Meta-plan](./2026-02-13-091527-remove-software-docs-phase35/phase1-metaplan.md)
- [Phase 2: software-docs-minion](./2026-02-13-091527-remove-software-docs-phase35/phase2-software-docs-minion.md)
- [Phase 2: lucy](./2026-02-13-091527-remove-software-docs-phase35/phase2-lucy.md)
- [Phase 3: Synthesis](./2026-02-13-091527-remove-software-docs-phase35/phase3-synthesis.md)
- [Phase 3.5: security-minion](./2026-02-13-091527-remove-software-docs-phase35/phase3.5-security-minion.md)
- [Phase 3.5: test-minion](./2026-02-13-091527-remove-software-docs-phase35/phase3.5-test-minion.md)
- [Phase 3.5: software-docs-minion](./2026-02-13-091527-remove-software-docs-phase35/phase3.5-software-docs-minion.md)
- [Phase 3.5: lucy](./2026-02-13-091527-remove-software-docs-phase35/phase3.5-lucy.md)
- [Phase 3.5: margo](./2026-02-13-091527-remove-software-docs-phase35/phase3.5-margo.md)
- [Phase 3.5: Docs checklist](./2026-02-13-091527-remove-software-docs-phase35/phase3.5-docs-checklist.md)

**Prompts**
- [Phase 1: Meta-plan prompt](./2026-02-13-091527-remove-software-docs-phase35/phase1-metaplan-prompt.md)
- [Phase 2: software-docs-minion prompt](./2026-02-13-091527-remove-software-docs-phase35/phase2-software-docs-minion-prompt.md)
- [Phase 2: lucy prompt](./2026-02-13-091527-remove-software-docs-phase35/phase2-lucy-prompt.md)
- [Phase 3: Synthesis prompt](./2026-02-13-091527-remove-software-docs-phase35/phase3-synthesis-prompt.md)
- [Phase 3.5: security-minion prompt](./2026-02-13-091527-remove-software-docs-phase35/phase3.5-security-minion-prompt.md)
- [Phase 3.5: test-minion prompt](./2026-02-13-091527-remove-software-docs-phase35/phase3.5-test-minion-prompt.md)
- [Phase 3.5: software-docs-minion prompt](./2026-02-13-091527-remove-software-docs-phase35/phase3.5-software-docs-minion-prompt.md)
- [Phase 3.5: lucy prompt](./2026-02-13-091527-remove-software-docs-phase35/phase3.5-lucy-prompt.md)
- [Phase 3.5: margo prompt](./2026-02-13-091527-remove-software-docs-phase35/phase3.5-margo-prompt.md)
- [Phase 4: Task 1 prompt](./2026-02-13-091527-remove-software-docs-phase35/phase4-software-docs-minion-task1-prompt.md)
- [Phase 4: Task 2 prompt](./2026-02-13-091527-remove-software-docs-phase35/phase4-software-docs-minion-task2-prompt.md)
- [Phase 4: Task 3 prompt](./2026-02-13-091527-remove-software-docs-phase35/phase4-software-docs-minion-task3-prompt.md)
- [Phase 4: Task 4 prompt](./2026-02-13-091527-remove-software-docs-phase35/phase4-software-docs-minion-task4-prompt.md)

</details>
