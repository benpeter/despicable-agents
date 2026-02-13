---
type: nefario-report
version: 3
date: "2026-02-13"
time: "03:28:18"
task: "Show current orchestration phase and task title in status line and gate messaging"
source-issue: 66
mode: full
agents-involved: [devx-minion, ux-strategy-minion, ux-design-minion, user-docs-minion, software-docs-minion, security-minion, test-minion, lucy, margo]
task-count: 2
gate-count: 0
outcome: completed
---

# Show current orchestration phase and task title in status line and gate messaging

## Summary

Added phase context to both the nefario status line and AskUserQuestion gate headers, closing the orientation gap where users lost "where am I?" awareness during orchestration. The status file now updates at every phase boundary with a `P<N> <Name> | <summary>` format, and 8 primary gate headers carry phase prefixes (e.g., "P1 Team", "P4 Gate"). Together, these ensure phase and task awareness is maintained regardless of whether the user sees the status line or a gate prompt.

## Original Prompt

> **Outcome**: Users always know which phase of nefario orchestration they are in and what task is being worked on, whether they are looking at the status line or responding to an approval gate. This closes the orientation gap where the status line is hidden during AskUserQuestion prompts, ensuring phase and task awareness is never lost regardless of UI state.
>
> **Success criteria**:
> - Nefario updates `/tmp/nefario-status-$sid` with the current phase followed by the task title at each phase boundary (e.g., "Phase 3: Synthesis | Restore phase announcements")
> - Status line displays both phase and task title during orchestration when visible
> - All AskUserQuestion gates include a contextual indicator of the current phase/step within their messaging
> - Phase and task context is visible in both the status line AND gate UI, so neither pathway loses orientation
> - Existing phase announcement markers (`**--- Phase N: Name ---**`) from #57 continue to work alongside the new mechanisms
>
> **Scope**:
> - In: Nefario SKILL.md phase transition logic, gate message templates, despicable-statusline skill
> - Out: Changing Claude Code's AskUserQuestion UI behavior, modifying status line during interviews, post-execution dark kitchen phases

## Key Design Decisions

#### Compact `P<N> Label` gate header format over explicit `Phase N -- Label`

**Rationale**:
- AskUserQuestion `header` field has a hard 12-character limit
- `Phase N -- Label` overflows for nearly every header (e.g., "Phase 3.5 -- Review" = 20 chars)
- Phase announcements in the conversation stream already use the full "Phase N: Name" format, so the gate header is a compact callback to established context

**Alternatives Rejected**:
- `Phase N -- Label` (ux-design-minion): Overflows 12-char limit for most headers
- Phase context in question text only: Headers are the first thing users scan; burying phase in question text loses the orientation benefit

#### Status file format `P<N> <Name> | <summary>` over alternatives

**Rationale**:
- Provides both phase number and semantic label in ~16 chars
- Task summary truncated from 48 to 40 chars to accommodate prefix while staying under ~62 chars total
- Status line command unchanged (reads file verbatim)

**Alternatives Rejected**:
- `P<N>: <summary>` (devx-minion): Loses semantic phase name, users see "P3:" with no context
- `Phase N: Name -- <summary>` (ux-design-minion): Prefix alone is 20+ chars, too long for status line

#### Dark kitchen phases (5-8) excluded from status updates

**Rationale**:
- Issue scope explicitly excludes "changes to post-execution dark kitchen phases"
- Can be addressed in a follow-up issue

**Alternatives Rejected**:
- Include dark kitchen updates (ux-design-minion): Valid point that status writes are infrastructure not output, but respecting scope boundary is more important

### Conflict Resolutions

None beyond the design decisions above. All four specialists aligned on direction; conflicts were about notation format, resolved by the 12-character constraint.

## Phases

### Phase 1: Meta-Plan

Nefario identified four specialists for planning: devx-minion for gate message template design, ux-strategy-minion for information density at the status line vs gate touchpoints, ux-design-minion for phase transition timing and status update placement, and user-docs-minion for documentation impact assessment. Three project-local skills discovered (despicable-lab, despicable-statusline, despicable-prompter); only despicable-statusline was potentially relevant but confirmed to need no changes.

### Phase 2: Specialist Planning

Four specialists contributed in parallel. devx-minion proposed the `P<N> Label` header format with an 8-primary/4-follow-up split. ux-strategy-minion designed the dual-channel orientation model (status line for ambient awareness, gate headers for active decisions) with a 32-char task summary recommendation. ux-design-minion recommended writing status before phase announcements and updating status during mid-execution gates. user-docs-minion identified three targeted edits to using-nefario.md. No additional agents were recommended.

### Phase 3: Synthesis

Nefario resolved four conflicts: header format (compact `P<N>` wins on 12-char constraint), status file format (ux-strategy's format wins for information density), dark kitchen exclusion (respecting scope boundary), and task summary length (compromise at 40 chars). Two tasks produced: SKILL.md changes and using-nefario.md documentation updates.

### Phase 3.5: Architecture Review

Six reviewers (5 mandatory + ux-strategy-minion discretionary). Five APPROVE verdicts (security, test, software-docs, margo, ux-strategy). One ADVISE from lucy: character count typo in header table (P3.5 Review listed as 12 chars, actually 11). Folded into execution as a correction.

### Phase 4: Execution

Two tasks executed sequentially. Task 1 (devx-minion): updated SKILL.md with phase-prefixed status writes at all 5 phase boundaries, 8 primary gate headers with P<N> prefix, mid-execution gate status updates, P4 Gate question with task title, and 12-char constraint note. Task 2 (user-docs-minion): updated using-nefario.md with three targeted edits reflecting phase-aware status line and gates.

### Phase 5: Code Review

Three reviewers (code-review-minion, lucy, margo) all returned ADVISE. Lucy and margo both flagged `"P4 Calibr."` should be `"P4 Calibrate"` (12 chars fits the limit). Auto-fixed in a follow-up commit. Code-review-minion noted docs refinement from specific format examples to experience-focused wording was appropriate per plan guidelines.

### Phase 6: Test Execution

Skipped (user request).

### Phase 7: Deployment

Skipped (not requested).

### Phase 8: Documentation

Documentation checklist reviewed. Items 1-2 (using-nefario.md edits, SKILL.md constraint note) already handled in Tasks 1-2. Items 3-5 (CHANGELOG, architecture docs, ADR) assessed: no CHANGELOG exists in the project, no architecture docs reference the old status format. All actionable items covered.

<details>
<summary>Agent Contributions (4 planning, 6 review)</summary>

### Planning

**devx-minion**: Proposed `P<N> Label` gate header format with 8 primary / 4 follow-up split. Identified P3.5 overflow handling and task title in P4 Gate question.
- Adopted: Header format, follow-up gate exemption, task title in question
- Risks flagged: 12-char header overflow for future gates

**ux-strategy-minion**: Designed dual-channel orientation model. Recommended status file format with phase label and shortened task summary.
- Adopted: Status file format, 32→40 char compromise, no task title in gate headers
- Risks flagged: Task summary recognizability at 32 chars (mitigated by 40-char compromise)

**ux-design-minion**: Recommended status write before phase announcement, mid-execution gate status updates, dark kitchen status writes.
- Adopted: Write-before-announce timing, mid-gate status updates
- Risks flagged: Sub-gate flicker if too granular

**user-docs-minion**: Identified three targeted using-nefario.md edits. Recommended documenting experience over mechanism.
- Adopted: All three edits, writing guidelines
- Risks flagged: Documentation staleness if format changes

### Architecture Review

**security-minion**: APPROVE. No new attack surface.

**test-minion**: APPROVE. Changes are specification/documentation only; verification steps adequate.

**software-docs-minion**: APPROVE. Documentation checklist produced with 5 items (2 already covered by tasks, 3 SHOULD/COULD).

**lucy**: ADVISE. Character count typo in header table (P3.5 Review: 12→11). Folded into execution.

**margo**: APPROVE. Well-scoped, proportional. Inline status writes correct YAGNI choice.

**ux-strategy-minion**: APPROVE. Dual-channel orientation model coherent.

### Code Review

**code-review-minion**: ADVISE. Docs refinement appropriate per plan guidelines.

**lucy**: ADVISE. P4 Calibr. should be P4 Calibrate. Auto-fixed.

**margo**: ADVISE. P4 Calibr. deviation noted. Mid-gate status variant worth monitoring.

</details>

## Execution

### Tasks

| # | Task | Agent | Status |
|---|------|-------|--------|
| 1 | Update SKILL.md -- phase-prefixed status writes + gate headers | devx-minion | completed |
| 2 | Update using-nefario.md -- document phase awareness | user-docs-minion | completed |

### Files Changed

| File | Action | Description |
|------|--------|-------------|
| [skills/nefario/SKILL.md](../../skills/nefario/SKILL.md) | modified | Phase-prefixed status writes at 5 boundaries, 8 gate headers with P<N> prefix, mid-gate status updates, P4 Gate task title, 12-char constraint note, summary truncation 48→40 |
| [docs/using-nefario.md](../using-nefario.md) | modified | Three edits: phase awareness sentence, status bar example with phase prefix, How It Works phase transition mention |

### Approval Gates

No approval gates were presented during execution. Both tasks are additive specification/documentation changes with low blast radius.

## Verification

| Phase | Result |
|-------|--------|
| Code Review | 3 ADVISE, 1 finding auto-fixed (P4 Calibr. → P4 Calibrate) |
| Test Execution | Skipped (user request) |
| Deployment | Skipped (not requested) |
| Documentation | Checklist items covered by Tasks 1-2; no additional docs needed |

## Working Files

<details>
<summary>Working files (34 files)</summary>

Companion directory: [2026-02-13-032818-show-phase-task-in-status-and-gates/](./2026-02-13-032818-show-phase-task-in-status-and-gates/)

- [Original Prompt](./2026-02-13-032818-show-phase-task-in-status-and-gates/prompt.md)

**Outputs**
- [Phase 1: Meta-plan](./2026-02-13-032818-show-phase-task-in-status-and-gates/phase1-metaplan.md)
- [Phase 2: devx-minion](./2026-02-13-032818-show-phase-task-in-status-and-gates/phase2-devx-minion.md)
- [Phase 2: ux-strategy-minion](./2026-02-13-032818-show-phase-task-in-status-and-gates/phase2-ux-strategy-minion.md)
- [Phase 2: ux-design-minion](./2026-02-13-032818-show-phase-task-in-status-and-gates/phase2-ux-design-minion.md)
- [Phase 2: user-docs-minion](./2026-02-13-032818-show-phase-task-in-status-and-gates/phase2-user-docs-minion.md)
- [Phase 3: Synthesis](./2026-02-13-032818-show-phase-task-in-status-and-gates/phase3-synthesis.md)
- [Phase 3.5: docs-checklist](./2026-02-13-032818-show-phase-task-in-status-and-gates/phase3.5-docs-checklist.md)
- [Phase 3.5: security-minion](./2026-02-13-032818-show-phase-task-in-status-and-gates/phase3.5-security-minion.md)
- [Phase 3.5: test-minion](./2026-02-13-032818-show-phase-task-in-status-and-gates/phase3.5-test-minion.md)
- [Phase 3.5: software-docs-minion](./2026-02-13-032818-show-phase-task-in-status-and-gates/phase3.5-software-docs-minion.md)
- [Phase 3.5: lucy](./2026-02-13-032818-show-phase-task-in-status-and-gates/phase3.5-lucy.md)
- [Phase 3.5: margo](./2026-02-13-032818-show-phase-task-in-status-and-gates/phase3.5-margo.md)
- [Phase 3.5: ux-strategy-minion](./2026-02-13-032818-show-phase-task-in-status-and-gates/phase3.5-ux-strategy-minion.md)
- [Phase 5: code-review-minion](./2026-02-13-032818-show-phase-task-in-status-and-gates/phase5-code-review-minion.md)
- [Phase 5: lucy](./2026-02-13-032818-show-phase-task-in-status-and-gates/phase5-lucy.md)
- [Phase 5: margo](./2026-02-13-032818-show-phase-task-in-status-and-gates/phase5-margo.md)

**Prompts**
- [Phase 1: Meta-plan prompt](./2026-02-13-032818-show-phase-task-in-status-and-gates/phase1-metaplan-prompt.md)
- [Phase 2: devx-minion prompt](./2026-02-13-032818-show-phase-task-in-status-and-gates/phase2-devx-minion-prompt.md)
- [Phase 2: ux-strategy-minion prompt](./2026-02-13-032818-show-phase-task-in-status-and-gates/phase2-ux-strategy-minion-prompt.md)
- [Phase 2: ux-design-minion prompt](./2026-02-13-032818-show-phase-task-in-status-and-gates/phase2-ux-design-minion-prompt.md)
- [Phase 2: user-docs-minion prompt](./2026-02-13-032818-show-phase-task-in-status-and-gates/phase2-user-docs-minion-prompt.md)
- [Phase 3: Synthesis prompt](./2026-02-13-032818-show-phase-task-in-status-and-gates/phase3-synthesis-prompt.md)
- [Phase 3.5: security-minion prompt](./2026-02-13-032818-show-phase-task-in-status-and-gates/phase3.5-security-minion-prompt.md)
- [Phase 3.5: test-minion prompt](./2026-02-13-032818-show-phase-task-in-status-and-gates/phase3.5-test-minion-prompt.md)
- [Phase 3.5: software-docs-minion prompt](./2026-02-13-032818-show-phase-task-in-status-and-gates/phase3.5-software-docs-minion-prompt.md)
- [Phase 3.5: lucy prompt](./2026-02-13-032818-show-phase-task-in-status-and-gates/phase3.5-lucy-prompt.md)
- [Phase 3.5: margo prompt](./2026-02-13-032818-show-phase-task-in-status-and-gates/phase3.5-margo-prompt.md)
- [Phase 3.5: ux-strategy-minion prompt](./2026-02-13-032818-show-phase-task-in-status-and-gates/phase3.5-ux-strategy-minion-prompt.md)
- [Phase 4: devx-minion prompt](./2026-02-13-032818-show-phase-task-in-status-and-gates/phase4-devx-minion-prompt.md)
- [Phase 4: user-docs-minion prompt](./2026-02-13-032818-show-phase-task-in-status-and-gates/phase4-user-docs-minion-prompt.md)
- [Phase 5: code-review-minion prompt](./2026-02-13-032818-show-phase-task-in-status-and-gates/phase5-code-review-minion-prompt.md)
- [Phase 5: lucy prompt](./2026-02-13-032818-show-phase-task-in-status-and-gates/phase5-lucy-prompt.md)
- [Phase 5: margo prompt](./2026-02-13-032818-show-phase-task-in-status-and-gates/phase5-margo-prompt.md)

</details>
