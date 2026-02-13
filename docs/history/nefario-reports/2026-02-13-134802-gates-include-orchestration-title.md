---
type: nefario-report
version: 3
date: "2026-02-13"
time: "13:48:02"
task: "Add run-title identifier to all AskUserQuestion gates"
source-issue: 83
mode: full
agents-involved: [nefario, devx-minion, ux-strategy-minion, ai-modeling-minion, security-minion, test-minion, lucy, margo, code-review-minion]
task-count: 1
gate-count: 1
outcome: completed
---

# Add run-title identifier to all AskUserQuestion gates

## Summary

Added a centralized run-title convention to the nefario SKILL.md so every AskUserQuestion gate includes the orchestration run title (`$summary`) as a trailing line. This ensures users can identify which orchestration run a gate belongs to, even when the status line is hidden -- critical for parallel nefario sessions in different terminals. The change is purely additive: 1 convention note, 5 literal-string gate updates, and 2 compaction focus string updates.

## Original Prompt

> All gates: include orchestration title in AskUserQuestion (GitHub issue #83)
>
> AskUserQuestion prompts hide the status line. When the status line is gone, the user loses context about which orchestration run they're looking at. This is especially bad when running parallel nefario sessions in different terminals. The post-exec gate is the worst offender ("Post-execution phases for this task?" -- no referent at all), but the issue is broader: none of the gates include the orchestration run title. Every AskUserQuestion gate should include the orchestration run title so the user always knows which run they're deciding on, even without the status line visible.

## Key Design Decisions

#### Suffix placement over prefix

**Rationale**:
- Headers and structured cards already provide top-of-prompt orientation -- the run identifier supplements rather than competes
- Suffix avoids rewriting any existing question content (zero editing judgment per gate)
- Consistent visual anchor: every gate gets the same `Run: $summary` footer, users learn one scan pattern
- Prefix approaches front-load 40 identical characters on every gate, pushing decision content rightward

**Alternatives Rejected**:
- Prefix (`$summary -- <question>`): Orientation-first argument valid, but outweighed by visual noise and existing top-of-prompt context from headers/cards
- Bracket prefix (`[$summary] <question>`): Same noise issue as prefix, plus brackets conflict with markdown link syntax in some renderers

#### Centralized convention + explicit literal-string updates (hybrid approach)

**Rationale**:
- A single convention note (5 lines) handles 7 template-style gates automatically
- 5 gates with full literal strings need explicit updates because the LLM reproduces verbatim strings
- DRYer than editing all 12 gates individually; more complete than centralized-only

**Alternatives Rejected**:
- All 12 explicit: Redundant for template-style gates where the LLM applies rules naturally
- Centralized only: Would miss literal-string gates that the LLM reproduces verbatim

#### $summary (not slug) as the run identifier

**Rationale**:
- Matches the status line identifier -- user sees the same text everywhere
- Natural language is instantly recognizable when switching between parallel sessions
- Already established in session context and reinforced by status file writes at every phase

**Alternatives Rejected**:
- `slug` (kebab-case): System-internal encoding requiring mental translation

### Conflict Resolutions

Three specialists proposed three different placement conventions (suffix, prefix, bracket prefix). Resolved in favor of suffix based on: (1) zero existing content changes, (2) no visual noise from repeated 40-char prefixes, (3) headers and structured cards already provide top-of-prompt context, (4) combines cleanly with centralized convention approach. The ux-strategy-minion's orientation-first argument for prefix was acknowledged as valid but outweighed by practical considerations.

## Phases

### Phase 1: Meta-Plan

Nefario identified 2 specialists for planning: devx-minion (CLI interaction design for gate formatting convention) and ux-strategy-minion (cognitive load and multi-session disambiguation). User adjusted the team to add ai-modeling-minion (prompt template design for LLM-executable specs). Two project-local skills discovered (despicable-lab, despicable-statusline) but neither relevant to the task.

### Phase 2: Specialist Planning

Three specialists contributed in parallel. devx-minion proposed a suffix convention (`\n\nRun: $summary` as trailing line), emphasizing zero content rewrites and consistent visual anchor. ux-strategy-minion proposed a prefix convention (`$summary -- <question>`), emphasizing orientation-first scanning. ai-modeling-minion proposed a bracket prefix (`[$summary] <question>`) with a centralized convention note for DRY spec design. All three agreed on using `$summary` (not slug) and leaving `header` fields unchanged.

### Phase 3: Synthesis

Nefario resolved the prefix-vs-suffix conflict in favor of suffix and adopted ai-modeling-minion's centralized convention approach. The final plan: 1 task (devx-minion), 1 gate. Single-file change to SKILL.md with 3 categories of edits: convention note, 5 literal-string gate updates, 2 compaction focus string updates. Gate count confirmed as 12 (the issue listed 11, but the Confirm reject-confirmation gate was identified as the 12th).

### Phase 3.5: Architecture Review

Five mandatory reviewers (security-minion, test-minion, ux-strategy-minion, lucy, margo). No discretionary reviewers needed. Results: 2 APPROVE (security-minion, margo), 3 ADVISE (test-minion: integration verification; ux-strategy-minion: near-duplication in P1 gate acknowledged; lucy: convention note formatting should match adjacent `> Note:` pattern). All ADVISE notes folded into the execution task prompt.

### Phase 4: Execution

devx-minion executed all 8 edits to SKILL.md in a single pass: convention note at lines 506-510, post-exec gate (line 1482), calibrate gate (line 1546), PR gate (line 1874), existing PR gate (line 2066), confirm gate (line 1514), and both compaction focus strings (lines 815, 1198). The diff was clean: +14/-6 lines, all in one file.

### Phase 5: Code Review

Three reviewers in parallel: code-review-minion, lucy, margo. All returned APPROVE with no findings. Verified: convention note formatting, all 5 gate updates, post-exec dual-context, compaction strings, no unintended changes.

### Phase 6: Test Execution

Skipped (no test infrastructure).

### Phase 7: Deployment

Skipped (not requested).

### Phase 8: Documentation

Skipped (empty checklist -- no derivative docs reference the changed gate question strings).

<details>
<summary>Agent Contributions (3 planning, 5 review)</summary>

### Planning

**devx-minion**: Proposed suffix convention (`\n\nRun: $summary` trailing line) for all gates. Identified multiline question support via existing P4 reject-confirmation gate. Found 12th gate (Confirm) missing from issue audit.
- Adopted: suffix placement, $summary identifier, header fields unchanged, post-exec dual-context
- Risks flagged: multiline question rendering (verified via existing gate)

**ux-strategy-minion**: Proposed prefix convention (`$summary -- <question>`) with 80-char truncation rule. Assessed cognitive load of different approaches. Validated post-exec as worst offender.
- Adopted: $summary over slug, leave header alone, post-exec needs both run and task context
- Risks flagged: near-duplication in P1 gate (accepted as trade-off for consistency)

**ai-modeling-minion**: Proposed centralized convention note near existing header constraint for DRY spec design. Recommended adding $summary to compaction focus strings.
- Adopted: centralized convention note approach, compaction focus string updates
- Risks flagged: LLM drift in late phases (mitigated by compaction preservation)

### Architecture Review

**security-minion**: APPROVE. No concerns.

**test-minion**: ADVISE. Suggested integration verification for multiline rendering. Non-blocking.

**ux-strategy-minion**: ADVISE. Acknowledged suffix approach maintains adequate orientation. Near-duplication in P1 acceptable.

**lucy**: ADVISE. Convention note should use `> Note:` format to match adjacent constraint. Scope and intent alignment verified.

**margo**: APPROVE. Plan is proportional. Hybrid approach is correct KISS tradeoff.

### Code Review

**code-review-minion**: APPROVE. All 8 edits verified correct and complete.

**lucy**: APPROVE. Convention adherence, intent alignment, and CLAUDE.md compliance all clean.

**margo**: APPROVE. Complexity cost is effectively zero. Change is proportional to problem.

</details>

## Execution

### Tasks

| # | Task | Agent | Status |
|---|------|-------|--------|
| 1 | Update SKILL.md with run-title convention and gate edits | devx-minion | completed |

### Files Changed

| File | Action | Description |
|------|--------|-------------|
| [skills/nefario/SKILL.md](../../../skills/nefario/SKILL.md) | modified | Added run-title convention note, 5 gate question updates, 2 compaction focus string updates (+14/-6 lines) |

### Approval Gates

| Gate Title | Agent | Confidence | Outcome | Rounds |
|------------|-------|------------|---------|--------|
| Update SKILL.md with run-title convention | devx-minion | HIGH | approved | 1 |

## Decisions

#### Update SKILL.md with run-title convention

**Decision**: Add `Run: $summary` trailing line to all 12 AskUserQuestion gates via centralized convention + 5 explicit literal-string updates.
**Rationale**: Suffix convention keeps existing question content untouched. Centralized rule + explicit literal-string updates is the DRY hybrid approach. Post-exec gate now has both task-level AND run-level context.
**Rejected**: Prefix approach (would front-load 40 identical chars on every gate, pushing decision content rightward).
**Confidence**: HIGH
**Outcome**: approved

## Verification

| Phase | Result |
|-------|--------|
| Code Review | 3 APPROVE, 0 findings |
| Test Execution | Skipped (no test infrastructure) |
| Deployment | Skipped (not requested) |
| Documentation | Skipped (empty checklist) |

## Working Files

<details>
<summary>Working files (28 files)</summary>

Companion directory: [2026-02-13-134802-gates-include-orchestration-title/](./2026-02-13-134802-gates-include-orchestration-title/)

- [Original Prompt](./2026-02-13-134802-gates-include-orchestration-title/prompt.md)

**Outputs**
- [Phase 1: Meta-plan](./2026-02-13-134802-gates-include-orchestration-title/phase1-metaplan.md)
- [Phase 2: devx-minion](./2026-02-13-134802-gates-include-orchestration-title/phase2-devx-minion.md)
- [Phase 2: ux-strategy-minion](./2026-02-13-134802-gates-include-orchestration-title/phase2-ux-strategy-minion.md)
- [Phase 2: ai-modeling-minion](./2026-02-13-134802-gates-include-orchestration-title/phase2-ai-modeling-minion.md)
- [Phase 3: Synthesis](./2026-02-13-134802-gates-include-orchestration-title/phase3-synthesis.md)
- [Phase 3.5: security-minion](./2026-02-13-134802-gates-include-orchestration-title/phase3.5-security-minion.md)
- [Phase 3.5: test-minion](./2026-02-13-134802-gates-include-orchestration-title/phase3.5-test-minion.md)
- [Phase 3.5: ux-strategy-minion](./2026-02-13-134802-gates-include-orchestration-title/phase3.5-ux-strategy-minion.md)
- [Phase 3.5: lucy](./2026-02-13-134802-gates-include-orchestration-title/phase3.5-lucy.md)
- [Phase 3.5: margo](./2026-02-13-134802-gates-include-orchestration-title/phase3.5-margo.md)
- [Phase 5: code-review-minion](./2026-02-13-134802-gates-include-orchestration-title/phase5-code-review-minion.md)
- [Phase 5: lucy](./2026-02-13-134802-gates-include-orchestration-title/phase5-lucy.md)
- [Phase 5: margo](./2026-02-13-134802-gates-include-orchestration-title/phase5-margo.md)

**Prompts**
- [Phase 1: Meta-plan prompt](./2026-02-13-134802-gates-include-orchestration-title/phase1-metaplan-prompt.md)
- [Phase 2: devx-minion prompt](./2026-02-13-134802-gates-include-orchestration-title/phase2-devx-minion-prompt.md)
- [Phase 2: ux-strategy-minion prompt](./2026-02-13-134802-gates-include-orchestration-title/phase2-ux-strategy-minion-prompt.md)
- [Phase 2: ai-modeling-minion prompt](./2026-02-13-134802-gates-include-orchestration-title/phase2-ai-modeling-minion-prompt.md)
- [Phase 3: Synthesis prompt](./2026-02-13-134802-gates-include-orchestration-title/phase3-synthesis-prompt.md)
- [Phase 3.5: security-minion prompt](./2026-02-13-134802-gates-include-orchestration-title/phase3.5-security-minion-prompt.md)
- [Phase 3.5: test-minion prompt](./2026-02-13-134802-gates-include-orchestration-title/phase3.5-test-minion-prompt.md)
- [Phase 3.5: ux-strategy-minion prompt](./2026-02-13-134802-gates-include-orchestration-title/phase3.5-ux-strategy-minion-prompt.md)
- [Phase 3.5: lucy prompt](./2026-02-13-134802-gates-include-orchestration-title/phase3.5-lucy-prompt.md)
- [Phase 3.5: margo prompt](./2026-02-13-134802-gates-include-orchestration-title/phase3.5-margo-prompt.md)
- [Phase 4: devx-minion prompt](./2026-02-13-134802-gates-include-orchestration-title/phase4-devx-minion-prompt.md)
- [Phase 5: code-review-minion prompt](./2026-02-13-134802-gates-include-orchestration-title/phase5-code-review-minion-prompt.md)
- [Phase 5: lucy prompt](./2026-02-13-134802-gates-include-orchestration-title/phase5-lucy-prompt.md)
- [Phase 5: margo prompt](./2026-02-13-134802-gates-include-orchestration-title/phase5-margo-prompt.md)

</details>
