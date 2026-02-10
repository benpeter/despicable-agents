---
type: nefario-report
version: 2
date: "2026-02-10"
time: "17:18:44"
task: "Replace --skip-post with granular per-phase skip flags"
mode: full
agents-involved: [nefario, devx-minion, ux-strategy-minion, security-minion, test-minion, software-docs-minion, lucy, margo, code-review-minion]
task-count: 4
gate-count: 0
outcome: completed
---

# Replace --skip-post with granular per-phase skip flags

## Summary

Replaced the binary "Run all / Skip post-execution" follow-up at approval gates with a flat 4-option single-select offering granular per-phase skip control (Skip docs, Skip tests, Skip review). Freeform flags (`--skip-docs`, `--skip-tests`, `--skip-review`, `--skip-post`) support multi-phase skip combinations. Users now make conscious, individual decisions about which verification phases to skip instead of being nudged into skipping all post-execution work.

## Original Prompt

> Replace --skip-post with granular skip flags in nefario skill
>
> **Outcome**: The nefario skill offers fine-grained control over which post-execution phases to skip, so that users make conscious, individual decisions about skipping docs, tests, and code review instead of being nudged into skipping all post-execution work with a single coarse flag.
>
> **Success criteria**:
> - `--skip-post` is replaced by individual flags (e.g., `--skip-docs`, `--skip-tests`, `--skip-review`)
> - Each flag independently controls its respective post-execution phase
> - Running nefario without any skip flags executes all post-execution phases (current default behavior preserved)
> - Multiple skip flags can be combined in a single invocation
> - SKILL.md documents the new flags
>
> **Scope**:
> - In: nefario SKILL.md flag parsing and phase-gating logic
> - Out: Post-execution phase implementations themselves, nefario planning phases, agent specs

## Decisions

#### Flat 4-Option Single-Select Over Two-Tier Progressive Disclosure

**Rationale**:
- AskUserQuestion supports 2-4 options; devx-minion's 5-option design exceeded this
- ux-strategy-minion proposed two-tier progressive disclosure, but `multiSelect: true` doesn't work in Claude Code's UI, making the second tier no more capable than a flat prompt with one extra click
- margo identified the flat 4-option as strictly simpler; user confirmed preference

**Alternatives Rejected**:
- Two-tier progressive disclosure (Run all / Customize -> secondary prompt): adds a click without adding capability since multi-select doesn't work in practice
- Flat 5-option single-select: exceeds AskUserQuestion's 4-option limit
- Freeform-only flags: discards the structured prompt infrastructure

#### --skip-post Preserved as Freeform Shorthand

**Rationale**:
- Both specialists recommended keeping `--skip-post` as a convenience shorthand for skip-all
- Removing it would break muscle memory for existing users
- Not exposed as a structured option (skip-all requires more intent via freeform text)

**Alternatives Rejected**:
- Full deprecation of --skip-post: unnecessary breakage
- --skip-post as a structured option: would nudge users toward skipping everything

#### Risk-Gradient Ordering

**Rationale**:
- Options ordered docs (lowest risk) -> tests -> review (highest risk)
- Users scanning top-to-bottom hit safe options first
- Serial position effect makes "Skip docs" the natural first choice among skip options

**Conflict Resolutions**: The core conflict (single-select vs. two-tier) was resolved by the `multiSelect: true` UI limitation discovery and margo's simplification recommendation, confirmed by user preference.

## Agent Contributions

<details>
<summary>Agent Contributions (2 planning, 6 review, 3 code review)</summary>

### Planning

**devx-minion**: Recommended flat 5-option single-select with freeform fallback. Established flag naming convention (`--skip-docs`, `--skip-tests`, `--skip-review`), dual-channel gating logic, and risk-gradient ordering.
- Adopted: flag names, risk-gradient ordering, freeform parallel channel, `--skip-post` as shorthand
- Risks flagged: AskUserQuestion 4-option limit (mitigated by dropping skip-all to freeform)

**ux-strategy-minion**: Recommended two-tier progressive disclosure with `multiSelect: true` secondary prompt. Established the invariant that run-all must remain one click.
- Adopted: one-click default invariant, no confirmation dialogs, no warning labels
- Risks flagged: `multiSelect: true` untested in codebase (confirmed non-functional by user)

### Architecture Review

**security-minion**: ADVISE. Recommended consequence signals in skip descriptions and verification of freeform skip visibility in CONDENSE line.

**test-minion**: APPROVE. No executable code produced; manual verification steps sufficient.

**ux-strategy-minion**: APPROVE. Flat 4-option preserves all UX principles from planning.

**software-docs-minion**: ADVISE. Recommended verification that AGENT.md and AGENT.overrides.md use identical text. Confirmed no additional docs needed.

**lucy**: ADVISE. Flagged --skip-post "replaced" vs "preserved" framing deviation from literal success criteria. Confirmed intent alignment.

**margo**: ADVISE. Recommended collapsing two-tier to flat 4-option (adopted). Recommended simplifying verification summary format.

### Code Review

**code-review-minion**: APPROVE. All flag-to-phase mappings consistent across files. Risk-gradient ordering correct. No security concerns.

**lucy**: ADVISE. Found third verification summary location (wrap-up step 7, lines 766-770) inconsistent with updated format. Auto-fixed.

**margo**: ADVISE. Same finding as lucy (wrap-up step 7). Confirmed changes are proportional with zero scope creep.

</details>

## Execution

### Files Created/Modified

| File Path | Action | Description |
|-----------|--------|-------------|
| skills/nefario/SKILL.md | modified | Follow-up prompt, gating logic, verification summary (3 locations) |
| docs/orchestration.md | modified | Two locations: post-exec description and gate response handling |
| nefario/AGENT.overrides.md | modified | Skip flag summary line |
| nefario/AGENT.md | modified | Skip flag summary line (mirrors overrides) |

### Approval Gates

None. All changes are easily reversible markdown edits with low blast radius.

## Process Detail

<details>
<summary>Process Detail</summary>

### Phases Executed

| Phase | Agents |
|-------|--------|
| Meta-plan | nefario |
| Specialist Planning | devx-minion, ux-strategy-minion |
| Synthesis | nefario |
| Architecture Review | security-minion, test-minion, ux-strategy-minion, software-docs-minion, lucy, margo |
| Execution | devx-minion (4 tasks) |
| Code Review | code-review-minion, lucy, margo |
| Test Execution | (skipped -- user-requested) |
| Deployment | (skipped -- not requested) |
| Documentation | software-docs-minion (checklist empty, no updates needed) |

### Verification

| Phase | Result |
|-------|--------|
| Code Review | 0 BLOCK, 2 ADVISE (1 finding auto-fixed: wrap-up step 7 consistency) |
| Test Execution | (skipped -- user-requested) |
| Deployment | (skipped -- not requested) |
| Documentation | Checklist empty, all docs already updated by execution tasks |

### Timing

| Phase | Duration |
|-------|----------|
| Meta-plan | ~2m |
| Specialist Planning | ~3m |
| Synthesis | ~3m |
| Architecture Review | ~2m |
| Execution | ~5m |
| Code Review | ~2m |
| Test Execution | (skipped) |
| Deployment | (skipped) |
| Documentation | ~1m |
| **Total** | **~18m** |

### Outstanding Items

None

</details>

## Working Files

<details>
<summary>Working files (13 files)</summary>

Companion directory: [2026-02-10-171844-replace-skip-post-granular-flags/](./2026-02-10-171844-replace-skip-post-granular-flags/)

- [Original Prompt](./2026-02-10-171844-replace-skip-post-granular-flags/prompt.md)
- [Phase 1: Meta-plan](./2026-02-10-171844-replace-skip-post-granular-flags/phase1-metaplan.md)
- [Phase 2: devx-minion](./2026-02-10-171844-replace-skip-post-granular-flags/phase2-devx-minion.md)
- [Phase 2: ux-strategy-minion](./2026-02-10-171844-replace-skip-post-granular-flags/phase2-ux-strategy-minion.md)
- [Phase 3: Synthesis](./2026-02-10-171844-replace-skip-post-granular-flags/phase3-synthesis.md)
- [Phase 3.5: security-minion](./2026-02-10-171844-replace-skip-post-granular-flags/phase3.5-security-minion.md)
- [Phase 3.5: software-docs-minion](./2026-02-10-171844-replace-skip-post-granular-flags/phase3.5-software-docs-minion.md)
- [Phase 3.5: lucy](./2026-02-10-171844-replace-skip-post-granular-flags/phase3.5-lucy.md)
- [Phase 3.5: margo](./2026-02-10-171844-replace-skip-post-granular-flags/phase3.5-margo.md)
- [Phase 5: code-review-minion](./2026-02-10-171844-replace-skip-post-granular-flags/phase5-code-review-minion.md)
- [Phase 5: lucy](./2026-02-10-171844-replace-skip-post-granular-flags/phase5-lucy.md)
- [Phase 5: margo](./2026-02-10-171844-replace-skip-post-granular-flags/phase5-margo.md)
- [Phase 8: checklist](./2026-02-10-171844-replace-skip-post-granular-flags/phase8-checklist.md)

</details>

## Metrics

| Metric | Value |
|--------|-------|
| Date | 2026-02-10 |
| Task | Replace --skip-post with granular per-phase skip flags |
| Duration | ~18m |
| Outcome | completed |
| Planning Agents | 2 agents consulted |
| Review Agents | 6 reviewers (architecture) + 3 reviewers (code) |
| Execution Agents | 1 agent (devx-minion, 4 tasks) |
| Gates Presented | 0 |
| Files Changed | 0 created, 4 modified |
| Outstanding Items | 0 |
