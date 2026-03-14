---
type: nefario-report
version: 3
date: "2026-03-14"
time: "19:04:55"
task: "Fix post-exec gate UX: replace inverted skip-only multiSelect with explicit Run all single-select"
source-issue: 129
mode: full
agents-involved: [ux-strategy-minion, security-minion, test-minion, lucy, margo, nefario]
task-count: 1
gate-count: 0
outcome: completed
---

# Fix post-exec gate UX: replace inverted skip-only multiSelect with explicit Run all single-select

## Summary

Replaced the post-execution phase gate's `multiSelect: true` pattern (where selecting nothing was the happy path) with a `multiSelect: false` single-select offering "Run all" as the first recommended option. This eliminates the Claude Code "unanswered question" warning on the default path and makes the most common action visible and one-click.

## Original Prompt

> Fix post-exec gate UX: replace inverted skip-only multiSelect with explicit 'Run all' single-select
>
> **Outcome**: After approving a task gate, the user sees an explicit "Run all phases" option as the default choice, eliminating the current anti-pattern where the happy path (run everything) requires selecting nothing and triggering a Claude Code "you haven't answered all questions" warning.
>
> **Success criteria**:
> - "Run all phases" is the first, explicitly listed option marked as recommended
> - Confirming without changing selection runs all phases (no empty-selection semantics)
> - No Claude Code "unanswered question" warning on the default path
> - Freeform flag overrides still work
> - Existing skip combinations remain available as named options
>
> **Constraints**:
> - Must use AskUserQuestion with multiSelect: false (single-select)
> - Preserve freeform text override behavior for flag-style skips

## Key Design Decisions

#### 3-option single-select instead of 4

**Rationale**:
- AskUserQuestion supports 2-4 options. With 7 possible skip combinations and only 4 slots, we must choose the most useful presets.
- "Run all" (happy path), "Skip docs only" (most common skip, lowest risk), and "Skip all post-exec" (power-user fast path) cover the vast majority of use cases.
- Remaining combinations (skip-tests-only, skip-review-only, etc.) are accessible via freeform flags, which power users already know.

**Alternatives Rejected**:
- 4 options with "Skip docs + tests": Adds a rarely-used combination at the cost of cognitive load. Freeform `--skip-docs --skip-tests` covers this.
- Keep multiSelect with added "Run all" option: multiSelect still allows empty selection, not solving the core UX issue.

### Conflict Resolutions

Lucy flagged that the issue states "existing skip combinations remain available as named options" while the plan reduces named options from 7 (via multiSelect combos) to 3. This was resolved by noting the 4-option AskUserQuestion constraint makes full enumeration impossible, and freeform flags preserve all 7 combinations. The spirit of the requirement (no loss of capability) is met.

Lucy also noted `nefario/AGENT.md` is listed as out-of-scope in the issue. Change 3 (AGENT.md paragraph update) was dropped from execution to respect the stated boundary.

## Phases

### Phase 1: Meta-Plan

Nefario identified ux-strategy-minion as the sole planning specialist. The task is narrowly scoped to one AskUserQuestion block in SKILL.md — the only open design question was option set composition, which is a UX-strategy concern. No external skills were relevant.

### Phase 2: Specialist Planning

ux-strategy-minion recommended a 3-option single-select design following Hick's Law (fewer options = faster decisions) and satisficing behavior (users pick the first acceptable option). The option ordering was: "Run all" (recommended default), "Skip docs only" (most common skip), "Skip all post-exec" (power-user escape hatch). No additional agents were recommended.

### Phase 3: Synthesis

Nefario produced a single-task plan assigned to devx-minion with two changes in SKILL.md: the AskUserQuestion block replacement and the downstream consumption logic update. No approval gates were needed (single low-risk, easily reversible change).

### Phase 3.5: Architecture Review

Five mandatory reviewers ran in parallel. All approved except lucy (ADVISE): flagged the named-option reduction and AGENT.md scope violation. Both advisories were incorporated — AGENT.md change was dropped, and the option reduction was accepted with the rationale that freeform flags preserve all combinations.

### Phase 4: Execution

Single task executed directly: two Edit operations on `skills/nefario/SKILL.md`. The AskUserQuestion block was updated from multiSelect to single-select with 3 options, and the downstream consumption logic was rewritten to match the new label-based routing.

### Phase 5: Code Review

Skipped (user-requested via "all further approvals assumed").

### Phase 6: Test Execution

Skipped (no executable tests for prompt/instruction changes).

### Phase 7: Deployment

Skipped (not requested).

### Phase 8: Documentation

Skipped (user-requested).

## Agent Contributions

<details>
<summary>Agent Contributions (1 planning, 5 review)</summary>

### Planning

**ux-strategy-minion**: Recommended 3-option single-select replacing multiSelect. Applied Hick's Law and satisficing behavior analysis to determine optimal option set.
- Adopted: All recommendations (3-option set, ordering, labels)
- Risks flagged: Mid-frequency skip combinations less discoverable (mitigated by freeform flags)

### Architecture Review

**security-minion**: APPROVE. No concerns.

**test-minion**: APPROVE. No concerns.

**ux-strategy-minion**: APPROVE. No concerns.

**lucy**: ADVISE.
- SCOPE: Post-exec gate option set. CHANGE: Issue requirement "existing skip combinations remain available as named options" not fully met. WHY: 7 multiSelect combinations reduced to 3 named options; freeform flags cover the gap but are less discoverable.
- SCOPE: nefario/AGENT.md. CHANGE: Remove Change 3 (out of scope per issue). WHY: Issue explicitly lists AGENT.md as out-of-scope.

**margo**: APPROVE. No concerns.

</details>

## Execution

### Tasks

| # | Task | Agent | Status |
|---|------|-------|--------|
| 1 | Rewrite post-exec gate and consumption logic | orchestrator (direct) | completed |

### Files Changed

| File | Action | Description |
|------|--------|-------------|
| [skills/nefario/SKILL.md](../../skills/nefario/SKILL.md) | modified | Replaced multiSelect post-exec gate with single-select; updated downstream consumption logic |

### Approval Gates

No approval gates in this plan.

## Verification

| Phase | Result |
|-------|--------|
| Code Review | Skipped (user-requested) |
| Test Execution | Skipped (no executable tests) |
| Deployment | Skipped (not requested) |
| Documentation | Skipped (user-requested) |

## Session Resources

<details>
<summary>Session resources (1 skills)</summary>

### Skills Invoked

- `/nefario` -- orchestration workflow

Context compaction: 0 events

</details>

## Working Files

<details>
<summary>Working files (12 files)</summary>

Companion directory: [2026-03-14-190455-fix-post-exec-gate-ux/](./2026-03-14-190455-fix-post-exec-gate-ux/)

- [Original Prompt](./2026-03-14-190455-fix-post-exec-gate-ux/prompt.md)

**Outputs**
- [Phase 1: Meta-plan](./2026-03-14-190455-fix-post-exec-gate-ux/phase1-metaplan.md)
- [Phase 2: ux-strategy-minion](./2026-03-14-190455-fix-post-exec-gate-ux/phase2-ux-strategy-minion.md)
- [Phase 3: Synthesis](./2026-03-14-190455-fix-post-exec-gate-ux/phase3-synthesis.md)
- [Phase 3.5: security-minion](./2026-03-14-190455-fix-post-exec-gate-ux/phase3.5-security-minion.md)
- [Phase 3.5: test-minion](./2026-03-14-190455-fix-post-exec-gate-ux/phase3.5-test-minion.md)
- [Phase 3.5: ux-strategy-minion](./2026-03-14-190455-fix-post-exec-gate-ux/phase3.5-ux-strategy-minion.md)
- [Phase 3.5: lucy](./2026-03-14-190455-fix-post-exec-gate-ux/phase3.5-lucy.md)
- [Phase 3.5: margo](./2026-03-14-190455-fix-post-exec-gate-ux/phase3.5-margo.md)

**Prompts**
- [Phase 1: Meta-plan prompt](./2026-03-14-190455-fix-post-exec-gate-ux/phase1-metaplan-prompt.md)
- [Phase 2: ux-strategy-minion prompt](./2026-03-14-190455-fix-post-exec-gate-ux/phase2-ux-strategy-minion-prompt.md)
- [Phase 3: Synthesis prompt](./2026-03-14-190455-fix-post-exec-gate-ux/phase3-synthesis-prompt.md)

</details>
