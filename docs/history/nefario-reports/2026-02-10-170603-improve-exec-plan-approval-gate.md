---
type: nefario-report
version: 2
date: "2026-02-10"
time: "17:06:03"
task: "Improve execution plan approval gate clarity"
mode: full
agents-involved: [ux-strategy-minion, devx-minion, software-docs-minion, security-minion, test-minion, lucy, margo]
task-count: 4
gate-count: 2
outcome: completed
---

# Improve execution plan approval gate clarity

## Summary

Defined a structured execution plan approval gate format that presents the full plan with self-contained advisory context at the Phase 3.5/Phase 4 boundary. The gate uses progressive disclosure (orientation, task list, advisories, reference) with a two-field delta model (CHANGE/WHY) for advisories, enabling informed approve/reject decisions without cross-referencing session history.

## Original Prompt

> Improve execution plan approval gate clarity
>
> **Outcome**: The execution plan approval gate shows the full execution plan and provides enough context for each incorporated advisory that the user can make an informed approve/reject decision without hunting through session history. Currently the gate is opaque -- it omits the plan and lists advisory summaries that are meaningless without their original context.
>
> **Success criteria**:
> - Execution plan is displayed in full at the approval gate
> - Each incorporated ADVISE verdict includes enough context to understand what it means and why it was adopted (not just a cryptic one-liner referencing task numbers)
> - User can approve or reject the execution plan based solely on what the gate presents, without needing to cross-reference session IDs or prior phases
>
> **Scope**:
> - In: Nefario SKILL.md gate formatting, AGENT.md execution plan presentation logic
> - Out: Other gates (meta-plan, synthesis), phase ordering, verdict format changes, AGENT.generated.md/overrides.md rebuild

## Decisions

#### Progressive Disclosure over Flat Dump

**Rationale**:
- Users need anomaly detection (spotting surprises), not comprehensive reading
- Progressive disclosure lets users scan at their preferred depth
- Flat dump of the full synthesis would exceed usable terminal output

**Alternatives Rejected**:
- Full synthesis dump: too long, buries important signals in implementation detail
- Summary-only: insufficient context for informed decisions

#### Two-Field Advisory Delta (CHANGE/WHY)

**Rationale**:
- Two fields (CHANGE, WHY) provide enough context for approval decisions
- ORIGINAL field was considered and rejected -- adds complexity without proportional value
- Domain attribution (testing, security) is more meaningful than agent attribution (test-minion)

**Alternatives Rejected**:
- Three-field model (CHANGE/WHY/ORIGINAL): unnecessary complexity per margo review
- Agent-attributed advisories: the concern domain matters more than which agent raised it

#### Three Response Options (No Skip)

**Rationale**:
- Plan-level gate requires a definitive decision before execution begins
- "Skip" (defer review) makes sense for individual deliverables, not entire plans
- Keeps cognitive load low at the highest-stakes decision point

**Gate outcome**: approved
**Confidence**: HIGH

**Conflict Resolutions**:
- Gate options (3 vs 4): ux-strategy-minion proposed 4 options including "Approve with deployment." Resolved in favor of 3 -- deployment opt-in is a separate decision handled post-execution.
- Advisory attribution (domain vs agent): ux-strategy-minion recommended domain attribution, devx-minion used agent names in examples. Resolved in favor of domain attribution.
- Layer nomenclature (4 layers vs 2 tiers): Resolved to use plain section names with soft line budget guidance, avoiding both numbered layers and rigid tiers.

## Agent Contributions

<details>
<summary>Agent Contributions (2 planning, 6 review)</summary>

### Planning

**ux-strategy-minion**: Designed progressive disclosure information architecture for anomaly detection; advisory delta model; cognitive load budget.
- Adopted: Progressive disclosure sections, delta model for advisories, domain attribution
- Risks flagged: Content overflow for complex plans (mitigated with advisory caps)

**devx-minion**: Analyzed terminal constraints driving format decisions; recommended flat text over HTML; inline advisory blocks with context.
- Adopted: Terminal-optimized format, flat text, compact task list format
- Risks flagged: Advisory delta requires synthesis-time data (mitigated by adding fields to ADVISE verdict)

### Architecture Review

**security-minion**: APPROVE. No concerns.

**test-minion**: ADVISE. Recommended verifiable assertions for gate format compliance; accepted as non-blocking.

**ux-strategy-minion**: ADVISE. Recommended standardizing advisories as separate block (not inline) and specifying "Request changes" workflow; both adopted.

**software-docs-minion**: ADVISE. Noted potential TEMPLATE.md updates needed; tracked as non-blocking follow-up.

**lucy**: ADVISE. Justified scope expansion for Tasks 2 and 3 (communication protocol and ADVISE verdict format); both necessary for consistency.

**margo**: ADVISE. Dropped "4-layer" nomenclature in favor of plain sections; reduced ADVISE fields from 3 to 2 (dropped ORIGINAL); both adopted.

</details>

## Execution

### Files Created/Modified

| File Path | Action | Description |
|-----------|--------|-------------|
| skills/nefario/SKILL.md | modified | Added Execution Plan Approval Gate section; updated communication protocol |
| nefario/AGENT.md | modified | Added TASK/CHANGE fields to ADVISE verdict format |
| docs/orchestration.md | modified | Added plan gate documentation; distinguished from mid-execution gates |

### Approval Gates

| Gate Title | Agent | Confidence | Outcome | Rounds |
|------------|-------|------------|---------|--------|
| Execution plan gate spec | nefario | HIGH | approved | 1 |
| Task 1 deliverable | nefario | HIGH | approved | 1 |

#### Execution Plan Gate Spec

**Decision**: Progressive disclosure with two-field advisory delta, 3 response options, soft line budget.
**Rationale**: Optimizes for anomaly detection at the highest-stakes decision point; balances context with brevity.
**Rejected**: Flat synthesis dump, summary-only, 4 response options with deployment.

#### Task 1 Deliverable

**Decision**: Accept SKILL.md gate format section as core specification for remaining tasks.
**Rationale**: Clean implementation matching all advisory-incorporated requirements; verified before proceeding.
**Rejected**: N/A (first-round approval).

## Process Detail

<details>
<summary>Process Detail</summary>

### Phases Executed

| Phase | Agents |
|-------|--------|
| Meta-plan | nefario |
| Specialist Planning | ux-strategy-minion, devx-minion |
| Synthesis | nefario |
| Architecture Review | security-minion, test-minion, ux-strategy-minion, software-docs-minion, lucy, margo |
| Execution | devx-minion (3 tasks), software-docs-minion (1 task) |
| Code Review | (skipped -- specification and documentation changes only) |
| Test Execution | (skipped -- no executable code) |
| Deployment | (skipped -- not requested) |
| Documentation | (covered by Task 4) |

### Verification

| Phase | Result |
|-------|--------|
| Code Review | (skipped -- spec/docs changes only) |
| Test Execution | (skipped -- no executable code) |
| Deployment | (skipped -- not requested) |
| Documentation | 3 files modified |
| Cross-file Consistency | Verified: SKILL.md gate format, AGENT.md ADVISE fields, orchestration.md references all align |

### Timing

| Phase | Duration |
|-------|----------|
| Meta-plan | ~2m |
| Specialist Planning | ~5m |
| Synthesis | ~4m |
| Architecture Review | ~6m |
| Execution | ~4m |
| **Total** | **~21m** |

### Outstanding Items

- [ ] Consider TEMPLATE.md updates to document plan gate vs mid-execution gate in report format (non-blocking, flagged by software-docs-minion)

</details>

## Working Files

<details>
<summary>Working files (10 files)</summary>

Companion directory: [2026-02-10-170603-improve-exec-plan-approval-gate/](./2026-02-10-170603-improve-exec-plan-approval-gate/)

- [Original Prompt](./2026-02-10-170603-improve-exec-plan-approval-gate/prompt.md)
- [Phase 1: Meta-plan](./2026-02-10-170603-improve-exec-plan-approval-gate/phase1-metaplan.md)
- [Phase 2: ux-strategy-minion](./2026-02-10-170603-improve-exec-plan-approval-gate/phase2-ux-strategy-minion.md)
- [Phase 2: devx-minion](./2026-02-10-170603-improve-exec-plan-approval-gate/phase2-devx-minion.md)
- [Phase 3: Synthesis](./2026-02-10-170603-improve-exec-plan-approval-gate/phase3-synthesis.md)
- [Phase 3.5: test-minion](./2026-02-10-170603-improve-exec-plan-approval-gate/phase3.5-test-minion.md)
- [Phase 3.5: ux-strategy-minion](./2026-02-10-170603-improve-exec-plan-approval-gate/phase3.5-ux-strategy-minion.md)
- [Phase 3.5: software-docs-minion](./2026-02-10-170603-improve-exec-plan-approval-gate/phase3.5-software-docs-minion.md)
- [Phase 3.5: lucy](./2026-02-10-170603-improve-exec-plan-approval-gate/phase3.5-lucy.md)
- [Phase 3.5: margo](./2026-02-10-170603-improve-exec-plan-approval-gate/phase3.5-margo.md)

</details>

## Metrics

| Metric | Value |
|--------|-------|
| Date | 2026-02-10 |
| Task | Improve execution plan approval gate clarity |
| Duration | ~21m |
| Outcome | completed |
| Planning Agents | 2 agents consulted |
| Review Agents | 6 reviewers |
| Execution Agents | 2 agents spawned |
| Gates Presented | 2 of 2 approved |
| Files Changed | 0 created, 3 modified |
| Outstanding Items | 1 item |
