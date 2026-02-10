---
type: nefario-report
version: 2
date: "2026-02-10"
time: "16:30:14"
task: "Preserve original prompt in nefario reports and PR descriptions"
mode: full
agents-involved: [nefario, devx-minion, software-docs-minion, security-minion, test-minion, ux-strategy-minion, lucy, margo, code-review-minion]
task-count: 1
gate-count: 0
outcome: completed
---

# Preserve original prompt in nefario reports and PR descriptions

## Summary

Added original prompt preservation to the nefario orchestration workflow. The report template's "Task" section is renamed to "Original Prompt" (which propagates to PR descriptions automatically since PR bodies derive from report bodies), and a standalone `prompt.md` file is written to the scratch directory in Phase 1 for inclusion in the report's companion directory. Security scan patterns were expanded to cover modern credential formats.

## Original Prompt

> Preserve original prompt in PR descriptions and nefario reports
>
> **Outcome**: The full original user prompt (the `/nefario` briefing) is captured in both the git PR description and the nefario execution report, and is also saved as a standalone file in the report directory. This ensures traceability from intent to implementation — reviewers can see exactly what was asked for without digging through conversation history.
>
> **Success criteria**:
> - PR description template includes a dedicated section for the original prompt
> - Nefario execution report template includes a dedicated section for the original prompt
> - Original prompt is written as a separate file (e.g., `prompt.md`) alongside the report in `docs/history/nefario-reports/`
> - Existing reports are not retroactively modified
>
> **Scope**:
> - In: PR creation flow in nefario skill, report template (`TEMPLATE.md`), nefario orchestration instructions
> - Out: Despicable-prompter skill itself, agent AGENT.md files, install.sh, the-plan.md

## Decisions

#### Rename "Task" to "Original Prompt"

**Rationale**:
- "Original Prompt" is clearer than "Task" for the section's purpose
- Rename propagates to PR descriptions automatically (PR body = report body minus frontmatter)
- Zero duplication — one section serves both report and PR

**Alternatives Rejected**:
- Keep "Task" heading + add cross-reference link: extra indirection, less clear
- Separate PR-specific section: DRY violation, would need separate maintenance

#### Plain Markdown for prompt.md

**Rationale**:
- Matches existing companion file format (no frontmatter)
- Metadata already lives in report frontmatter — duplicating in prompt.md violates DRY
- No tooling needs to discover prompt.md by parsing frontmatter (YAGNI)

**Alternatives Rejected**:
- YAML frontmatter in prompt.md: DRY violation, YAGNI for tooling discovery

**Conflict Resolutions**: None

## Agent Contributions

<details>
<summary>Agent Contributions (2 planning, 6 review, 3 code review)</summary>

### Planning

**devx-minion**: Recommended writing prompt.md to scratch dir in Phase 1, renaming "Task" to "Original Prompt" in TEMPLATE.md, and updating Working Files guidance.
- Adopted: All three recommendations
- Risks flagged: None

**software-docs-minion**: Recommended plain markdown for prompt.md, cross-ref link approach, checklist and orchestration.md updates.
- Adopted: Plain markdown format, checklist updates, orchestration.md updates
- Risks flagged: None

### Architecture Review

**security-minion**: ADVISE. Recommended explicit "already-sanitized" wording, expanded scan patterns (ghp_, github_pat_, AKIA), and PR body secret scan.

**test-minion**: APPROVE. No concerns — build-index.sh reads frontmatter not headings.

**ux-strategy-minion**: APPROVE. "Original Prompt" is clearer than "Task", good progressive disclosure.

**software-docs-minion**: ADVISE. Recommended against hardcoded line numbers, explicit checklist renumbering, cross-reference consistency check.

**lucy**: ADVISE. PR description traceability should be explicit, not implicit.

**margo**: APPROVE. Minimum necessary work, good YAGNI discipline.

### Code Review

**code-review-minion**: ADVISE. Secret scan regex could use word boundaries (accepted as defensive). Format spec clarity could improve (non-blocking).

**lucy**: ADVISE. Found stale "report's Task section" reference in SKILL.md and missing checklist step 4a in TEMPLATE.md. Both auto-fixed.

**margo**: ADVISE. Same two findings as lucy. Confirmed changes are minimal and proportional.

</details>

## Execution

### Files Created/Modified

| File Path | Action | Description |
|-----------|--------|-------------|
| skills/nefario/SKILL.md | modified | Added prompt.md writing in Phase 1, expanded security scan patterns, added PR body secret scan |
| docs/history/nefario-reports/TEMPLATE.md | modified | Renamed "Task" to "Original Prompt", added checklist step 4a, updated Working Files labels |
| docs/orchestration.md | modified | Updated "Task" to "Original Prompt" in Section 5, added prompt.md mention |

### Approval Gates

None

## Process Detail

<details>
<summary>Process Detail</summary>

### Phases Executed

| Phase | Agents |
|-------|--------|
| Meta-plan | nefario |
| Specialist Planning | devx-minion, software-docs-minion |
| Synthesis | nefario |
| Architecture Review | security-minion, test-minion, ux-strategy-minion, software-docs-minion, lucy, margo |
| Execution | devx-minion (1 task) |
| Code Review | code-review-minion, lucy, margo |
| Test Execution | (skipped -- markdown-only changes, no tests) |
| Deployment | (skipped -- not requested) |
| Documentation | (skipped -- empty checklist, changes are documentation themselves) |

### Verification

| Phase | Result |
|-------|--------|
| Code Review | 0 BLOCK, 2 ADVISE -- both auto-fixed |
| Test Execution | (skipped -- markdown-only changes) |
| Deployment | (skipped -- not requested) |
| Documentation | (skipped -- empty checklist) |

### Timing

| Phase | Duration |
|-------|----------|
| Meta-plan | ~2m |
| Specialist Planning | ~3m |
| Synthesis | ~3m |
| Architecture Review | ~4m |
| Execution | ~3m |
| Code Review | ~2m |
| Test Execution | (skipped) |
| Deployment | (skipped) |
| Documentation | (skipped) |
| **Total** | **~17m** |

### Outstanding Items

None

</details>

## Working Files

<details>
<summary>Working files (11 files)</summary>

Companion directory: [2026-02-10-163014-preserve-original-prompt-in-reports/](./2026-02-10-163014-preserve-original-prompt-in-reports/)

- [Phase 1: Meta-plan](./2026-02-10-163014-preserve-original-prompt-in-reports/phase1-metaplan.md)
- [Phase 2: devx-minion](./2026-02-10-163014-preserve-original-prompt-in-reports/phase2-devx-minion.md)
- [Phase 2: software-docs-minion](./2026-02-10-163014-preserve-original-prompt-in-reports/phase2-software-docs-minion.md)
- [Phase 3: Synthesis](./2026-02-10-163014-preserve-original-prompt-in-reports/phase3-synthesis.md)
- [Phase 3.5: lucy](./2026-02-10-163014-preserve-original-prompt-in-reports/phase3.5-lucy.md)
- [Phase 3.5: security-minion](./2026-02-10-163014-preserve-original-prompt-in-reports/phase3.5-security-minion.md)
- [Phase 3.5: software-docs-minion](./2026-02-10-163014-preserve-original-prompt-in-reports/phase3.5-software-docs-minion.md)
- [Phase 5: code-review-minion](./2026-02-10-163014-preserve-original-prompt-in-reports/phase5-code-review-minion.md)
- [Phase 5: lucy](./2026-02-10-163014-preserve-original-prompt-in-reports/phase5-lucy.md)
- [Phase 5: margo](./2026-02-10-163014-preserve-original-prompt-in-reports/phase5-margo.md)
- [Original Prompt](./2026-02-10-163014-preserve-original-prompt-in-reports/prompt.md)

</details>

## Metrics

| Metric | Value |
|--------|-------|
| Date | 2026-02-10 |
| Task | Preserve original prompt in nefario reports and PR descriptions |
| Duration | ~17m |
| Outcome | completed |
| Planning Agents | 2 agents consulted |
| Review Agents | 6 reviewers |
| Execution Agents | 1 agent spawned |
| Gates Presented | 0 |
| Files Changed | 0 created, 3 modified |
| Outstanding Items | 0 items |
