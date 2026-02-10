---
type: nefario-report
version: 2
date: "2026-02-10"
time: "15:12:09"
task: "Preserve scratch files in nefario execution reports"
mode: full
agents-involved: [nefario, devx-minion, software-docs-minion, ux-strategy-minion, security-minion, test-minion, lucy, margo]
task-count: 3
gate-count: 0
outcome: completed
---

# Preserve scratch files in nefario execution reports

## Summary

Added working file preservation to nefario execution reports. Scratch files (meta-plans, specialist contributions, synthesis documents) are now copied to a companion directory alongside each report at wrap-up, with a collapsible "Working Files" section in the report linking to them. This preserves the full decision trail for post-hoc inspection.

## Task

<details>
<summary>Original task (expand)</summary>

> Preserve scratch files in nefario execution reports.
>
> Right now, nefario orchestration produces a bunch of intermediate artifacts during planning
> (meta-plan drafts, specialist contributions, synthesis documents) that live in
> nefario/scratch/{slug}/. These files are gitignored and ephemeral -- they disappear when the
> session ends or the scratch directory is cleaned up.
>
> But these files ARE the decision trail. They show why the plan looks the way it does. When I
> review a nefario execution report later, I want to be able to trace back through the planning
> artifacts that produced it.
>
> Make nefario preserve these scratch files alongside the execution report. The report should
> link to them so the full planning history is inspectable after the fact.
>
> Success looks like:
> - Each execution report has a companion directory with all scratch files from that run
> - The report itself links to these files (or the directory)
> - TEMPLATE.md is updated so future reports include this
> - Existing reports are unaffected
> - The build-index.sh script still works correctly

</details>

## Decisions

#### "Working Files" Over "Scratch Files"

**Rationale**:
- "Scratch" implies disposability, contradicting the preservation goal
- "Working Files" communicates "intermediate work products" without disposability connotation
- Internal directory remains `nefario/scratch/` (internal convention unchanged)

**Alternatives Rejected**:
- "Scratch Files": sends contradictory signal about preserved content

#### Collapsible Section with Directory Link + Flat File List

**Rationale**:
- Progressive disclosure serves two audiences: PR reviewers (collapsed) and investigators (expanded)
- Directory link provides single entry point; file list provides orientation
- `Phase N: label` format is self-describing to the target audience

**Alternatives Rejected**:
- Manifest table with "Contents" column: over-engineered, requires parsing logic in SKILL.md
- Individual links only (no directory link): false affordance for PR reviewers

#### Placement After Process Detail, Before Metrics

**Rationale**:
- Working files are raw archival material, belong after all synthesized content
- Inverted pyramid principle: curated content first, raw reference last
- Placing between Agent Contributions and Execution would interrupt the narrative flow

**Alternatives Rejected**:
- Between Agent Contributions and Execution: interrupts "who contributed" to "what was produced" flow

#### Timestamp Captured Once at Wrap-up Start

**Rationale**:
- Both companion directory and report filename must share the exact same timestamp
- Capturing once eliminates R1 (timestamp mismatch risk)

**Alternatives Rejected**:
- Capture at each usage point: creates mismatch risk between directory and filename

**Conflict Resolutions**: Three conflicts resolved between specialist recommendations (file linking format, section name, section placement). All resolutions chose the simpler or better-justified option. See synthesis document for full rationale.

## Agent Contributions

<details>
<summary>Agent Contributions (3 planning, 6 review)</summary>

### Planning

**devx-minion**: Designed scratch file collection lifecycle -- copy before report, full `cp -r`, skip if empty.
- Adopted: companion directory naming, timestamp unification, security check step
- Risks flagged: timestamp mismatch (mitigated by capturing once)

**software-docs-minion**: Designed report template section -- collapsible with flat bulleted list and phase labels.
- Adopted: `Phase N: label` format, backward compatibility by absence, no version bump
- Risks flagged: slug mismatch, git bloat

**ux-strategy-minion**: Shaped UX strategy -- progressive disclosure, naming, placement.
- Adopted: "Working Files" naming, placement after Process Detail, directory link
- Risks flagged: repo bloat, link fragility

### Architecture Review

**security-minion**: ADVISE. Recommended strengthening the secret-check note with specific patterns (API keys, tokens, passwords, connection strings, private keys). Incorporated into Task 1.

**test-minion**: APPROVE. No concerns.

**ux-strategy-minion**: APPROVE. No concerns.

**software-docs-minion**: APPROVE. No concerns.

**lucy**: APPROVE. All 5 user requirements traceable to tasks; no scope creep; CLAUDE.md compliant.

**margo**: APPROVE. Proportional to the problem; YAGNI/KISS clean; zero new dependencies.

</details>

## Execution

### Files Created/Modified

| File Path | Action | Description |
|-----------|--------|-------------|
| skills/nefario/SKILL.md | modified | Added working file collection step (5) and timestamp capture (2) to wrap-up sequence |
| docs/history/nefario-reports/TEMPLATE.md | modified | Added Working Files section (8), renumbered Metrics (9), updated checklist |

### Approval Gates

None. All changes are additive documentation/config with low blast radius and easy reversibility.

## Process Detail

<details>
<summary>Process Detail</summary>

### Phases Executed

| Phase | Agents |
|-------|--------|
| Meta-plan | nefario |
| Specialist Planning | devx-minion, software-docs-minion, ux-strategy-minion |
| Synthesis | nefario |
| Architecture Review | security-minion, test-minion, ux-strategy-minion, software-docs-minion, lucy, margo |
| Execution | devx-minion (2 tasks), software-docs-minion (1 task) |
| Code Review | (skipped -- documentation-only changes) |
| Test Execution | (skipped -- no executable code produced) |
| Deployment | (skipped -- not requested) |
| Documentation | (skipped -- documentation was the primary deliverable) |

### Verification

| Phase | Result |
|-------|--------|
| Code Review | (skipped -- documentation-only changes) |
| Test Execution | build-index.sh compatibility verified manually (Task 3) |
| Deployment | (skipped -- not requested) |
| Documentation | 2 files modified (SKILL.md, TEMPLATE.md) |

### Timing

| Phase | Duration |
|-------|----------|
| Meta-plan | ~2m |
| Specialist Planning | ~3m |
| Synthesis | ~3m |
| Architecture Review | ~5m |
| Execution | ~4m |
| Code Review | (skipped) |
| Test Execution | ~1m (build-index.sh verification) |
| Deployment | (skipped) |
| Documentation | (included in execution) |
| **Total** | **~18m** |

### Outstanding Items

None

</details>

## Working Files

<details>
<summary>Working files (5 files)</summary>

Companion directory: [2026-02-10-151209-preserve-scratch-files-nefario-reports/](./2026-02-10-151209-preserve-scratch-files-nefario-reports/)

- [Phase 1: Meta-plan](./2026-02-10-151209-preserve-scratch-files-nefario-reports/phase1-metaplan.md)
- [Phase 2: devx-minion](./2026-02-10-151209-preserve-scratch-files-nefario-reports/phase2-devx-minion.md)
- [Phase 2: software-docs-minion](./2026-02-10-151209-preserve-scratch-files-nefario-reports/phase2-software-docs-minion.md)
- [Phase 2: ux-strategy-minion](./2026-02-10-151209-preserve-scratch-files-nefario-reports/phase2-ux-strategy-minion.md)
- [Phase 3: Synthesis](./2026-02-10-151209-preserve-scratch-files-nefario-reports/phase3-synthesis.md)

</details>

## Metrics

| Metric | Value |
|--------|-------|
| Date | 2026-02-10 |
| Task | Preserve scratch files in nefario execution reports |
| Duration | ~18m |
| Outcome | completed |
| Planning Agents | 3 agents consulted |
| Review Agents | 6 reviewers |
| Execution Agents | 2 agents spawned (3 tasks) |
| Gates Presented | 0 |
| Files Changed | 0 created, 2 modified |
| Outstanding Items | 0 |
