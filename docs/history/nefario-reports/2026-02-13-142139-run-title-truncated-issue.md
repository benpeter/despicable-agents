---
type: nefario-report
version: 3
date: "2026-02-13"
time: "14:21:39"
task: "Run title in approval gates is unnecessarily truncated to 40 chars"
source-issue: 83
mode: advisory
agents-involved: [nefario]
task-count: 0
gate-count: 0
outcome: completed
---

# Run title in approval gates is unnecessarily truncated to 40 chars

## Summary

Investigated why the run title shown in approval gates (added by the #83 fix, PR #96) appears truncated. Confirmed that `$summary` is defined once in Phase 1 with a 40-character cap designed for the status line, and gates reuse the same truncated value despite having ample display space. Created issue #97 with the `nice-to-have` label recommending a `$summary_full` variable for gate contexts.

## Original Prompt

> The fix to #83 shows the run title truncated. Is that because at this point it's only available truncated? Create an issue to fix this (low priority - if priorities aren't available, create a label "nice-to-have" and add it).

## Key Design Decisions

#### Single variable serves two display contexts

**Rationale**:
- `$summary` was designed for the status line sentinel file, where total line budget is ~64 chars
- The #83 fix reused `$summary` in gates because it was the only available run-title variable
- Gates have substantially more horizontal and vertical space than the status line

**Alternatives Rejected**:
- Increasing `$summary` cap globally: would make the status line too long

### Conflict Resolutions

None.

## Phases

### Phase 1: Meta-Plan

No specialists were selected. The task is fully scoped: investigate a specific truncation behavior in SKILL.md and create a GitHub issue. The investigation traced `$summary` from its Phase 1 definition (40-char cap, line ~389-391 of SKILL.md) through its reuse in gate `question` fields (added by PR #96, commit 394e4dc). Two project-local skills were discovered (despicable-lab, despicable-statusline) but neither was relevant.

### Phase 2: Specialist Planning

No specialists consulted. The investigation findings were unambiguous and required no domain expertise beyond reading SKILL.md.

### Phase 3: Synthesis

The advisory synthesis confirmed the root cause (single variable, two contexts) and recommended introducing `$summary_full` (120-char cap) for gate question fields while preserving `$summary` (40-char) for the status line. Issue #97 was created with labels `orchestration` and `nice-to-have`.

### Phase 3.5: Architecture Review

Skipped (advisory-only orchestration).

### Phase 4: Execution

Skipped (advisory-only orchestration).

### Phase 5: Code Review

Skipped (advisory-only orchestration).

### Phase 6: Test Execution

Skipped (advisory-only orchestration).

### Phase 7: Deployment

Skipped (advisory-only orchestration).

### Phase 8: Documentation

Skipped (advisory-only orchestration).

## Agent Contributions

<details>
<summary>Agent Contributions (0 planning)</summary>

### Planning

No specialists consulted.

</details>

## Team Recommendation

**Introduce `$summary_full` (120-char cap) in Phase 1 for use in gate `Run:` lines; keep `$summary` (40-char) for the status line.**

### Consensus

| Position | Agents | Strength |
|----------|--------|----------|
| Dual-variable approach (`$summary` + `$summary_full`) | nefario | High -- unambiguous root cause, clear fix |

### When to Revisit

1. If AskUserQuestion UI changes to constrain question field length
2. If the status line format changes to accommodate longer summaries
3. If compaction behavior affects `$summary_full` retention differently than `$summary`

### Strongest Arguments

**For dual-variable approach** (adopted):

| Argument | Agent |
|----------|-------|
| Gates have ample space; 40-char cap is a status-line constraint, not a gate constraint | nefario |
| Minimal change: add one variable definition in Phase 1, update ~10 `Run:` references | nefario |
| No risk to status line behavior (existing variable untouched) | nefario |

**For single variable with higher cap** (not adopted, but preserved):

| Argument | Agent |
|----------|-------|
| Simpler: one variable instead of two | nefario |
| Risk: higher cap may make status line too wide in some terminal configurations | nefario |

## Working Files

<details>
<summary>Working files (4 files)</summary>

Companion directory: [2026-02-13-142139-run-title-truncated-issue/](./2026-02-13-142139-run-title-truncated-issue/)

- [Original Prompt](./2026-02-13-142139-run-title-truncated-issue/prompt.md)

**Outputs**
- [Phase 1: Meta-plan](./2026-02-13-142139-run-title-truncated-issue/phase1-metaplan.md)
- [Phase 3: Synthesis](./2026-02-13-142139-run-title-truncated-issue/phase3-synthesis.md)

**Prompts**
- [Phase 3: Synthesis prompt](./2026-02-13-142139-run-title-truncated-issue/phase3-synthesis-prompt.md)

</details>
