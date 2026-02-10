---
type: nefario-report
version: 2
date: "2026-02-10"
time: "15:55:02"
task: "Improve nefario skill UX with structured prompts and quieter commit hooks"
mode: full
agents-involved: [ux-strategy-minion, ai-modeling-minion, devx-minion, security-minion, test-minion, software-docs-minion, lucy, margo, code-review-minion]
task-count: 4
gate-count: 1
outcome: completed
---

# Improve nefario skill UX with structured prompts and quieter commit hooks

## Summary

Converted four freeform text decision points in the nefario SKILL.md to Claude Code's `AskUserQuestion` structured prompts, and added a session-scoped marker file to suppress commit hook noise during orchestrated sessions. This reduces friction during nefario orchestration by replacing ambiguous text input with scannable multiple-choice options and keeps the session output clean.

## Task

> Improve nefario skill UX with structured prompts and quieter commit hooks — Outcome: The nefario orchestration skill provides a smoother interactive experience by using Claude Code's AskUserQuestion tool for user decisions instead of asking users to type freeform phrases, and the git commit hook no longer floods the main session with noise. This reduces friction during orchestration and keeps the session output clean and focused.

## Decisions

#### AskUserQuestion with Natural Language Parameter Anchors

**Rationale**:
- Natural language with parameter-name anchors (`header:`, `options:`, `multiSelect:`) is more resilient to schema changes than literal JSON
- Explicit tool naming ("Present using AskUserQuestion") ensures reliable tool invocation
- Inline instruction blocks at each decision point location keep SKILL.md self-documenting

**Alternatives Rejected**:
- Literal JSON tool call specs: fragile, breaks if parameter names change
- Centralized template block: adds indirection, harder to maintain

#### Follow-Up Post-Execution Menu (Gate Revision)

**Rationale**:
- User requested `--skip-post` be selectable rather than hidden in "Other" freeform input
- Follow-up AskUserQuestion after "Approve" provides a clean extension point for future skip options
- Two-step flow (approve → post-exec choice) is natural since post-execution is a separate concern

**Alternatives Rejected**:
- Hidden `--skip-post` via "Other" freeform input: not discoverable, power-user only
- 5th option on main gate: exceeds Hick's Law limit of 4 options

**Gate outcome**: approved (after 1 revision round)
**Confidence**: HIGH

#### Calibration Check Without Recommended Default

**Rationale**:
- Architecture review (ux-strategy-minion) identified that marking a recommended option on the calibration check enables rubber-stamping
- Forcing a conscious choice between "Gates are fine" and "Fewer gates next time" breaks the auto-approve pattern

#### Session-Scoped Marker File for Hook Suppression

**Rationale**:
- Follows existing marker file convention (`defer_marker`, `declined_marker`) in the hook
- Session-scoped (`/tmp/claude-commit-orchestrated-<session-id>`) prevents cross-session contamination
- 3-line early-exit guard is minimal and fail-safe (exit 0 = allow stop)

**Alternatives Rejected**:
- Environment variable detection: hooks don't receive custom env vars from SKILL.md
- Branch name pattern matching: fragile, false positives on similarly-named branches

#### Conflict Resolutions

None. All specialists aligned on approach. Minor disagreement on Tasks 3+4 scope (lucy: drop as YAGNI, margo: keep with monitoring) resolved by user decision to keep.

## Agent Contributions

<details>
<summary>Agent Contributions (3 planning, 6 review, 3 code review)</summary>

### Planning

**ux-strategy-minion**: Designed the 4 decision point conversions with option counts, ordering, and recommended defaults.
- Adopted: 4-option gate, 3-option verification, 2-option calibration (no recommended), 2-option PR
- Risks flagged: rubber-stamping acceleration, two-step "Request changes" friction

**ai-modeling-minion**: Recommended natural language parameter-name anchor pattern for SKILL.md instructions. Designed advisory guidance for AGENT.md files.
- Adopted: parameter-name anchors over JSON specs, advisory-only AGENT.md additions
- Risks flagged: AskUserQuestion schema instability, main session ignoring tool instructions

**devx-minion**: Designed session-scoped marker file pattern for hook suppression.
- Adopted: `/tmp/claude-commit-orchestrated-<session-id>` convention, 3-line early-exit guard
- Risks flagged: marker creation must be outside branch creation conditional

### Architecture Review

**security-minion**: APPROVE. No concerns.

**test-minion**: ADVISE. Recommended adding test case for orchestrated marker; adopted.

**ux-strategy-minion**: ADVISE. Recommended no recommended default on calibration check and minimal follow-up for "Request changes"; both adopted.

**software-docs-minion**: ADVISE. Recommended updating docs/orchestration.md; adopted in Phase 8.

**lucy**: ADVISE. Flagged Tasks 3+4 as scope creep; user decided to keep.

**margo**: ADVISE. Tasks 3+4 borderline speculative but acceptable. Reject confirmation acceptable given blast radius.

### Code Review (Phase 5)

**code-review-minion**: APPROVE. Production-ready, natural language specs resilient to schema changes.

**lucy**: APPROVE. Full intent alignment, convention adherence confirmed.

**margo**: APPROVE. Net simplification (complexity budget: -1 points).

</details>

## Execution

### Files Created/Modified

| File Path | Action | Description |
|-----------|--------|-------------|
| skills/nefario/SKILL.md | modified | 4 decision points converted to AskUserQuestion; marker lifecycle added |
| .claude/hooks/commit-point-check.sh | modified | 3-line orchestrated-session marker early-exit guard |
| docs/commit-workflow.md | modified | Hook composition section: marker suppression paragraph |
| tests/test-commit-hooks.sh | modified | New test for orchestrated marker + teardown cleanup |
| minions/ux-strategy-minion/AGENT.md | modified | "Structured Choice Presentation" subsection |
| minions/ai-modeling-minion/AGENT.md | modified | "Interactive Patterns in Skills" subsection |
| docs/orchestration.md | modified | Updated gate docs to reflect structured prompts |

### Approval Gates

| Gate Title | Agent | Confidence | Outcome | Rounds |
|------------|-------|------------|---------|--------|
| SKILL.md AskUserQuestion Decision Points | devx-minion | HIGH | approved | 2 (1 revision: --skip-post → follow-up menu) |

#### SKILL.md AskUserQuestion Decision Points

**Decision**: Four nefario decision points converted from freeform text to AskUserQuestion structured prompts.
**Rationale**: Structured choices reduce cognitive load, prevent input parsing errors, and make decision points scannable. Natural language parameter anchors are resilient to schema changes.
**Rejected**: "approve --skip-post" as visible 5th option (exceeds Hick's Law limit). Resolved: follow-up AskUserQuestion after "Approve" per user request.

## Process Detail

<details>
<summary>Process Detail</summary>

### Phases Executed

| Phase | Agents |
|-------|--------|
| Meta-plan | nefario |
| Specialist Planning | ux-strategy-minion, ai-modeling-minion, devx-minion |
| Synthesis | nefario |
| Architecture Review | security-minion, test-minion, ux-strategy-minion, software-docs-minion, lucy, margo |
| Execution | devx-minion (Tasks 1+2), ai-modeling-minion (Tasks 3+4) |
| Code Review | code-review-minion, lucy, margo |
| Test Execution | 19 pass, 0 fail, 0 skip |
| Deployment | (skipped -- not requested) |
| Documentation | nefario (docs/orchestration.md update) |

### Verification

| Phase | Result |
|-------|--------|
| Code Review | 0 BLOCK, 0 ADVISE, 3 APPROVE |
| Test Execution | 19 pass, 0 fail, 0 skip |
| Deployment | (skipped -- not requested) |
| Documentation | 1 file updated (docs/orchestration.md) |

### Timing

| Phase | Duration |
|-------|----------|
| Meta-plan | ~2m |
| Specialist Planning | ~3m (parallel) |
| Synthesis | ~3m |
| Architecture Review | ~2m (parallel) |
| Execution | ~4m (parallel) |
| Code Review | ~2m (parallel) |
| Test Execution | <1m |
| Documentation | ~1m |
| **Total** | **~18m** |

### Outstanding Items

None

</details>

## Working Files

<details>
<summary>Working files (9 files)</summary>

Companion directory: [2026-02-10-155502-nefario-ux-askuser-quiet-hooks/](./2026-02-10-155502-nefario-ux-askuser-quiet-hooks/)

- [Phase 1: Meta-plan](./2026-02-10-155502-nefario-ux-askuser-quiet-hooks/phase1-metaplan.md)
- [Phase 2: ux-strategy-minion](./2026-02-10-155502-nefario-ux-askuser-quiet-hooks/phase2-ux-strategy-minion.md)
- [Phase 2: ai-modeling-minion](./2026-02-10-155502-nefario-ux-askuser-quiet-hooks/phase2-ai-modeling-minion.md)
- [Phase 2: devx-minion](./2026-02-10-155502-nefario-ux-askuser-quiet-hooks/phase2-devx-minion.md)
- [Phase 3: Synthesis](./2026-02-10-155502-nefario-ux-askuser-quiet-hooks/phase3-synthesis.md)
- [Phase 3.5: Review Summary](./2026-02-10-155502-nefario-ux-askuser-quiet-hooks/phase3.5-review-summary.md)
- [Phase 5: code-review-minion](./2026-02-10-155502-nefario-ux-askuser-quiet-hooks/phase5-code-review-minion.md)
- [Phase 5: lucy](./2026-02-10-155502-nefario-ux-askuser-quiet-hooks/phase5-lucy.md)
- [Phase 5: margo](./2026-02-10-155502-nefario-ux-askuser-quiet-hooks/phase5-margo.md)

</details>

## Metrics

| Metric | Value |
|--------|-------|
| Date | 2026-02-10 |
| Task | Improve nefario skill UX with structured prompts and quieter commit hooks |
| Duration | ~18m |
| Outcome | completed |
| Planning Agents | 3 agents consulted |
| Review Agents | 6 reviewers (architecture) + 3 reviewers (code) |
| Execution Agents | 2 agents spawned |
| Gates Presented | 1 of 1 approved (1 revision round) |
| Files Changed | 0 created, 7 modified |
| Outstanding Items | 0 items |
