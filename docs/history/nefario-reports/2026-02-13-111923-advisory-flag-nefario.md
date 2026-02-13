---
type: nefario-report
version: 3
date: "2026-02-13"
time: "11:19:23"
task: "Add --advisory flag to /nefario for advisory-only orchestrations"
source-issue: 89
mode: full
agents-involved: [nefario, devx-minion, ai-modeling-minion, software-docs-minion, security-minion, test-minion, ux-strategy-minion, lucy, margo, code-review-minion]
task-count: 5
gate-count: 1
outcome: completed
---

# Add --advisory flag to /nefario for advisory-only orchestrations

## Summary

Added `--advisory` flag to the `/nefario` skill, enabling recommendation-only orchestrations that run phases 1-3 and produce an advisory report without any code changes, branch creation, or PR. The implementation uses an orthogonal `ADVISORY: true` directive (not a new MODE) to keep the mode axis clean, with changes across three files: AGENT.md (+67 lines), SKILL.md (+170 lines), and TEMPLATE.md (+50 lines). Documentation updated in README, using-nefario guide, and orchestration architecture docs.

## Original Prompt

> ## Problem
>
> Advisory-only orchestrations (assembling a specialist team for evaluation and report, no code changes) are a frequent use case. Currently, the user must manually type directives like "do not change anything, just create a report" every time. This is repetitive friction that a flag would eliminate.
>
> **This is not YAGNI.** The pattern is well-established through regular use. The user repeatedly crafts the same natural language guardrails to prevent execution and ensure a meaningful report is produced. A flag codifies proven behavior.
>
> ## Proposal
>
> Add `--advisory` as a flag on `/nefario`. When present:
>
> - Phases 1-2 run identically (meta-plan, specialist planning)
> - Phase 3 produces a recommendation synthesis instead of an execution plan
> - Phases 3.5-8 are skipped (no architecture review, no execution, no code review, no tests, no deployment, no docs)
> - A report is generated with `mode: advisory` frontmatter
> - No branch is created, no PR is opened
> - Reports go to `docs/history/nefario-reports/` with the same naming convention
>
> ## Acceptance Criteria
>
> - [ ] `/nefario --advisory <task>` runs Phases 1-3 and produces an advisory report
> - [ ] `/nefario --advisory #<issue>` works with issue mode
> - [ ] Advisory reports use `mode: advisory` in frontmatter
> - [ ] No branch creation, no commits, no PR for advisory runs
> - [ ] Report template handles advisory sections (no execution, no verification, no files changed)

## Key Design Decisions

#### ADVISORY: true directive instead of MODE: ADVISORY

**Rationale**:
- MODE is a phase selector (META-PLAN, SYNTHESIS, PLAN). Advisory changes what the synthesis produces, not which phase runs.
- Orthogonal design composes cleanly: `MODE: PLAN` + `ADVISORY: true` works without a 5th mode.
- Avoids combinatorial explosion as modes grow.

**Alternatives Rejected**:
- MODE: ADVISORY-SYNTHESIS (devx-minion): Would require MODE: ADVISORY-PLAN for the combination. Conflates two axes.

#### No Phase 1 changes for advisory mode

**Rationale**:
- Phase 1's job is "who should weigh in" -- identical for advisory and execution.
- The current orchestration itself ran Phase 1 identically, proving the point.

**Alternatives Rejected**:
- Full advisory context blocks in Phase 1 and Phase 2 (devx-minion): Phase 1 context unnecessary; Phase 2 gets a lightweight 3-line note only.

### Conflict Resolutions

Two conflicts resolved during synthesis:

1. **MODE: ADVISORY-SYNTHESIS vs ADVISORY: true**: devx-minion proposed a new mode; ai-modeling-minion proposed an orthogonal directive. Resolved in favor of orthogonal directive per rationale above.

2. **Phase 1/2 advisory context**: devx-minion recommended advisory context blocks in both phases; ai-modeling-minion argued neither needs changes. Compromise: no Phase 1 changes, lightweight 3-line Phase 2 note.

## Phases

### Phase 1: Meta-Plan

Nefario identified three specialists: devx-minion (SKILL.md integration, CLI flag design), ai-modeling-minion (synthesis/mode architecture), and software-docs-minion (report template design). Two project-local skills were discovered (despicable-lab, despicable-statusline) but neither was relevant. Governance agents (lucy, margo) were excluded from planning -- the prior advisory report already established alignment, and they participate as mandatory Phase 3.5 reviewers.

### Phase 2: Specialist Planning

Three specialists contributed in parallel. devx-minion provided precise insertion points across 14 SKILL.md locations, designed the position-independent flag parsing with content boundary protection, and specified the advisory wrap-up sequence. ai-modeling-minion resolved the central architectural question (orthogonal directive vs. new mode) and mapped the advisory synthesis output format. software-docs-minion analyzed the existing report template section-by-section against the exemplar advisory report and recommended single-template with conditionals over a separate template file. No additional agents were recommended.

### Phase 3: Synthesis

Nefario synthesized into a 5-task plan with 1 gate. Two conflicts were resolved: the MODE question (in favor of ai-modeling-minion's orthogonal directive) and the Phase 1/2 context question (compromise: Phase 2 only, lightweight). The plan assigns all SKILL.md and AGENT.md work to devx-minion (CLI/specification domain) and TEMPLATE.md work to software-docs-minion.

### Phase 3.5: Architecture Review

Five mandatory reviewers examined the plan. security-minion and test-minion APPROVED. ux-strategy-minion ADVISED removing the Phase 2 advisory context as unnecessary (kept as optional experiment). lucy ADVISED fixing a commit behavior ambiguity in acceptance criteria and noting a template mode enum inconsistency. margo ADVISED folding Task 5 into an earlier task (kept for gate sequencing). No discretionary reviewers were needed.

### Phase 4: Execution

Five tasks executed in four batches. Tasks 1 (AGENT.md) and 4 (TEMPLATE.md) ran in parallel. Task 2 (flag parsing) and Task 3 (synthesis/termination/wrap-up) ran sequentially. The gate after Task 3 confirmed the core behavioral specification. Task 5 (description update) was executed directly by the orchestrator.

### Phase 5: Code Review

Three reviewers (code-review-minion, lucy, margo) examined the output. code-review-minion APPROVED. lucy and margo both ADVISED fixing the same issue: a missing branch-point guard between the advisory synthesis section and the standard post-synthesis instructions. Both findings were auto-fixed. lucy also found the skeleton's mode enum was not updated to include `advisory` -- also fixed.

### Phase 6: Test Execution

Skipped (no test infrastructure for markdown specification files).

### Phase 7: Deployment

Skipped (not requested).

### Phase 8: Documentation

Three documentation files updated: README.md (advisory example in Examples section), docs/using-nefario.md (advisory tip with usage examples), and docs/orchestration.md (advisory mode paragraph in architecture section).

<details>
<summary>Agent Contributions (3 planning, 5 review)</summary>

### Planning

**devx-minion**: Designed precise insertion points for SKILL.md, position-independent flag parsing, advisory wrap-up sequence, and status line ADV prefix.
- Adopted: Flag parsing design, advisory termination and wrap-up specification, status line convention
- Risks flagged: Core Rules conflict (explicit exception needed), scope creep (advisory-to-execution conversion), SKILL.md growth (~8%)

**ai-modeling-minion**: Resolved MODE architecture question. ADVISORY: true as orthogonal directive, not new mode. Designed seven-section advisory synthesis output format.
- Adopted: Orthogonal directive design, advisory output format, no Phase 1 changes
- Risks flagged: MODE/ADVISORY orthogonality documentation clarity

**software-docs-minion**: Analyzed template section-by-section. Single template with conditionals, not separate file. Team Recommendation section as core advisory deliverable.
- Adopted: Single-template approach, Team Recommendation section structure, conditional inclusion rules
- Risks flagged: Template conditional complexity if more modes are added

### Architecture Review

**security-minion**: APPROVE. No concerns -- advisory mode reduces capability (no code execution).

**test-minion**: APPROVE. Three-tier verification strategy (structural, consistency, manual integration) matches specification changes.

**ux-strategy-minion**: ADVISE. Recommended removing Phase 2 advisory context as unnecessary. Kept as optional experiment.

**lucy**: ADVISE. Found commit behavior ambiguity in acceptance criteria (resolved: report commit is correct intent). Found template mode enum inconsistency (fixed).

**margo**: ADVISE. Recommended folding Task 5 into earlier task (kept for gate sequencing). Noted advisory report format is somewhat rigid for v1 (mitigated by "optional" subsections).

### Code Review

**code-review-minion**: APPROVE. Clean orthogonal design, correct control flow, DRY compliance.

**lucy**: ADVISE. Found missing branch-point guard between advisory synthesis and standard post-synthesis path (fixed). Found skeleton mode enum not updated (fixed).

**margo**: ADVISE. Found same branch-point ambiguity as lucy (fixed). Noted intentional specification duplication in wrap-up is acceptable for LLM reliability.

</details>

## Execution

### Tasks

| # | Task | Agent | Status |
|---|------|-------|--------|
| 1 | Update AGENT.md with advisory directive and synthesis format | devx-minion | completed |
| 2 | Add flag parsing and advisory context to SKILL.md | devx-minion | completed |
| 3 | Add advisory synthesis, termination, and wrap-up to SKILL.md | devx-minion | completed |
| 4 | Update report template for advisory mode | software-docs-minion | completed |
| 5 | Update SKILL.md description for advisory capability | orchestrator | completed |

### Files Changed

| File | Action | Description |
|------|--------|-------------|
| [nefario/AGENT.md](../../nefario/AGENT.md) | modified | Advisory Directive section, advisory output format in SYNTHESIS, PLAN advisory note (+67 lines) |
| [skills/nefario/SKILL.md](../../skills/nefario/SKILL.md) | modified | Flag parsing, Core Rules exception, Phase 2 advisory context, advisory synthesis prompt, advisory termination, advisory wrap-up, description update, branch-point guard (+170 lines) |
| [docs/history/nefario-reports/TEMPLATE.md](./TEMPLATE.md) | modified | mode: advisory enum, Team Recommendation section, conditional rules, formatting notes, checklist steps (+50 lines) |
| [README.md](../../README.md) | modified | Advisory mode example in Examples section (+3 lines) |
| [docs/using-nefario.md](../using-nefario.md) | modified | Advisory tip with usage examples (+8 lines) |
| [docs/orchestration.md](../orchestration.md) | modified | Advisory mode paragraph in architecture section (+2 lines) |

### Approval Gates

| Gate Title | Agent | Confidence | Outcome | Rounds |
|------------|-------|------------|---------|--------|
| Advisory synthesis, termination, and wrap-up | devx-minion | HIGH | approved | 1 |

## Decisions

#### Advisory synthesis, termination, and wrap-up

**Decision**: Advisory flow diverges at Phase 3 synthesis with ADVISORY: true directive, skips all execution phases, and wraps up with report-only output.
**Rationale**: Orthogonal directive avoids mode explosion. Advisory wrap-up commits report to current branch. Firm boundary against mid-session conversion.
**Rejected**: MODE: ADVISORY-SYNTHESIS (would require 5th mode for PLAN+ADVISORY combination).
**Confidence**: HIGH
**Outcome**: approved

## Verification

| Phase | Result |
|-------|--------|
| Code Review | 2 ADVISE findings auto-fixed (branch-point guard, template mode enum) |
| Test Execution | Skipped (no test infrastructure for specification files) |
| Deployment | Skipped (not requested) |
| Documentation | 3 files updated (README.md, using-nefario.md, orchestration.md) |

## Working Files

<details>
<summary>Working files (31 files)</summary>

Companion directory: [2026-02-13-111923-advisory-flag-nefario/](./2026-02-13-111923-advisory-flag-nefario/)

- [Original Prompt](./2026-02-13-111923-advisory-flag-nefario/prompt.md)

**Outputs**
- [Phase 1: Meta-plan](./2026-02-13-111923-advisory-flag-nefario/phase1-metaplan.md)
- [Phase 2: devx-minion](./2026-02-13-111923-advisory-flag-nefario/phase2-devx-minion.md)
- [Phase 2: ai-modeling-minion](./2026-02-13-111923-advisory-flag-nefario/phase2-ai-modeling-minion.md)
- [Phase 2: software-docs-minion](./2026-02-13-111923-advisory-flag-nefario/phase2-software-docs-minion.md)
- [Phase 3: Synthesis](./2026-02-13-111923-advisory-flag-nefario/phase3-synthesis.md)
- [Phase 3.5: security-minion](./2026-02-13-111923-advisory-flag-nefario/phase3.5-security-minion.md)
- [Phase 3.5: test-minion](./2026-02-13-111923-advisory-flag-nefario/phase3.5-test-minion.md)
- [Phase 3.5: ux-strategy-minion](./2026-02-13-111923-advisory-flag-nefario/phase3.5-ux-strategy-minion.md)
- [Phase 3.5: lucy](./2026-02-13-111923-advisory-flag-nefario/phase3.5-lucy.md)
- [Phase 3.5: margo](./2026-02-13-111923-advisory-flag-nefario/phase3.5-margo.md)
- [Phase 5: code-review-minion](./2026-02-13-111923-advisory-flag-nefario/phase5-code-review-minion.md)
- [Phase 5: lucy](./2026-02-13-111923-advisory-flag-nefario/phase5-lucy.md)
- [Phase 5: margo](./2026-02-13-111923-advisory-flag-nefario/phase5-margo.md)

**Prompts**
- [Phase 1: Meta-plan prompt](./2026-02-13-111923-advisory-flag-nefario/phase1-metaplan-prompt.md)
- [Phase 2: devx-minion prompt](./2026-02-13-111923-advisory-flag-nefario/phase2-devx-minion-prompt.md)
- [Phase 2: ai-modeling-minion prompt](./2026-02-13-111923-advisory-flag-nefario/phase2-ai-modeling-minion-prompt.md)
- [Phase 2: software-docs-minion prompt](./2026-02-13-111923-advisory-flag-nefario/phase2-software-docs-minion-prompt.md)
- [Phase 3: Synthesis prompt](./2026-02-13-111923-advisory-flag-nefario/phase3-synthesis-prompt.md)
- [Phase 3.5: security-minion prompt](./2026-02-13-111923-advisory-flag-nefario/phase3.5-security-minion-prompt.md)
- [Phase 3.5: test-minion prompt](./2026-02-13-111923-advisory-flag-nefario/phase3.5-test-minion-prompt.md)
- [Phase 3.5: ux-strategy-minion prompt](./2026-02-13-111923-advisory-flag-nefario/phase3.5-ux-strategy-minion-prompt.md)
- [Phase 3.5: lucy prompt](./2026-02-13-111923-advisory-flag-nefario/phase3.5-lucy-prompt.md)
- [Phase 3.5: margo prompt](./2026-02-13-111923-advisory-flag-nefario/phase3.5-margo-prompt.md)
- [Phase 4: devx-minion Task 1 prompt](./2026-02-13-111923-advisory-flag-nefario/phase4-devx-minion-task1-prompt.md)
- [Phase 4: devx-minion Task 2 prompt](./2026-02-13-111923-advisory-flag-nefario/phase4-devx-minion-task2-prompt.md)
- [Phase 4: devx-minion Task 3 prompt](./2026-02-13-111923-advisory-flag-nefario/phase4-devx-minion-task3-prompt.md)
- [Phase 4: software-docs-minion prompt](./2026-02-13-111923-advisory-flag-nefario/phase4-software-docs-minion-prompt.md)
- [Phase 5: code-review-minion prompt](./2026-02-13-111923-advisory-flag-nefario/phase5-code-review-minion-prompt.md)
- [Phase 5: lucy prompt](./2026-02-13-111923-advisory-flag-nefario/phase5-lucy-prompt.md)
- [Phase 5: margo prompt](./2026-02-13-111923-advisory-flag-nefario/phase5-margo-prompt.md)

</details>
