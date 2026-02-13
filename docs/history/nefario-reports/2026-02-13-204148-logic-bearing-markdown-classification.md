---
type: nefario-report
version: 3
date: "2026-02-13"
time: "20:41:48"
task: "Fix logic-bearing markdown misclassification in nefario orchestrator"
source-issue: 62
mode: full
agents-involved: [ai-modeling-minion, lucy, ux-strategy-minion, software-docs-minion, security-minion, test-minion, margo, code-review-minion]
task-count: 3
gate-count: 1
outcome: completed
---

# Fix logic-bearing markdown misclassification in nefario orchestrator

## Summary

Nefario's orchestration treated all `.md` files as documentation, causing Phase 5 code review to be incorrectly skipped for logic-bearing files (AGENT.md, SKILL.md, RESEARCH.md, CLAUDE.md) and ai-modeling-minion to be excluded from team assembly for agent/orchestration tasks. This fix introduces a filename-based classification boundary at the Phase 5 skip conditional in SKILL.md, adds delegation table entries in AGENT.md to route agent prompt and orchestration rule tasks to ai-modeling-minion, and aligns vocabulary across reference documentation.

## Original Prompt

> Nefario misclassifies logic-bearing markdown files (phase-skipping and team assembly).
>
> Nefario's orchestration currently treats all .md files as "documentation." This causes two problems:
> 1. Phase-skipping: Phase 5 code review is skipped for changes to AGENT.md, SKILL.md, RESEARCH.md because they are classified as "docs-only"
> 2. Team assembly: ai-modeling-minion is not included in Phase 1 team assembly when the task involves modifying agent system prompts or orchestration rules in .md files
>
> Success criteria:
> - Changes to AGENT.md, SKILL.md, RESEARCH.md, and similar logic-bearing markdown files are NOT classified as docs-only
> - Docs-only classification still applies to genuinely documentation-only changes (e.g., README prose, user guides, changelog entries)
> - The distinction is clear and documented so future contributors understand the boundary
> - When a task involves modifying agent system prompts or orchestration logic (even in .md files), ai-modeling-minion is included in team assembly during Phase 1
> - More broadly: specialist selection in Phase 1 considers the semantic content of files, not just their extension
>
> Additional context: make the ai-modeling-minion part of the roster from the outset and run all agents on opus.

## Key Design Decisions

#### Filename-Primary Classification (Not Content Heuristics)

**Rationale**:
- Classification uses an enumerated filename list (AGENT.md, SKILL.md, RESEARCH.md, CLAUDE.md) with directory context as tiebreaker
- Deterministic, compact, and zero-fragility -- no scanning for YAML frontmatter or prompt-like patterns
- Matches the project's existing naming conventions perfectly

**Alternatives Rejected**:
- Extension-based classification (.md = documentation): Rejected because system prompts and orchestration rules use .md extension but are functionally code -- this is the exact bug being fixed
- Content-analysis heuristics (scan for YAML frontmatter, prompt patterns): Rejected because it is fragile, adds prompt complexity, and produces inconsistent results across sessions

#### Canonical Definition at Point of Application

**Rationale**:
- The classification definition lives inline at the Phase 5 skip conditional in SKILL.md, exactly where the decision is applied
- An AI agent executing Phase 5 reads SKILL.md, not AGENT.md -- no cross-referencing needed
- Other files get vocabulary alignment only, not the full definition

**Alternatives Rejected**:
- Dual definition in both AGENT.md and SKILL.md: Rejected due to drift risk between two classification taxonomies in different files
- Separate classification document: Rejected as over-engineering for a 5-row lookup table

### Conflict Resolutions

**Definition placement**: ai-modeling-minion recommended AGENT.md; software-docs-minion recommended SKILL.md only. Resolved in favor of SKILL.md (point of application). AGENT.md gets vocabulary alignment and delegation table entries.

**Delegation table rows**: ai-modeling-minion proposed 3 rows; lucy proposed 1. Resolved as 2 rows -- "Agent system prompt modification" and "Orchestration rule changes" -- eliminating redundancy while covering the gap.

**Documentation scope**: software-docs-minion proposed 5 deliverables. Resolved as 3 (then reduced to 2 per margo/lucy advisory): SKILL.md canonical definition, AGENT.md vocabulary + delegation, docs/orchestration.md + docs/decisions.md alignment. docs/agent-anatomy.md cross-reference dropped as non-sequitur.

## Phases

### Phase 1: Meta-Plan

Nefario identified 4 specialists for planning: ai-modeling-minion (classification criteria), lucy (intent alignment and convention enforcement), ux-strategy-minion (user experience of phase-skipping), and software-docs-minion (documentation placement and format). The user adjusted the initial team by swapping devx-minion for lucy, and Phase 1 was re-run with the revised team. Two external skills were discovered (despicable-lab, despicable-statusline) but neither was relevant to the task.

### Phase 2: Specialist Planning

All 4 specialists contributed on opus. ai-modeling-minion defined the filename-primary classification with directory context as tiebreaker and conservative default (4 proposed tasks). lucy confirmed a simple enumerated filename list is proportional per YAGNI/KISS and flagged the-plan.md divergence for human owner (3 proposed tasks). ux-strategy-minion recommended keeping phase-skip silent during execution (dark kitchen pattern), adding a parenthetical explanation in wrap-up, and never surfacing classification labels to users (2 proposed tasks). software-docs-minion recommended the canonical definition in SKILL.md only, with vocabulary alignment elsewhere, using a 3-part inline structure with classification table and worked examples (5 proposed tasks). No additional agents were recommended.

### Phase 3: Synthesis

Specialist input was merged into a 3-task execution plan with 1 approval gate. Key conflict resolutions: SKILL.md wins for definition placement, 2 delegation table rows (not 3), and documentation scope reduced from 5 to 4 deliverables (later reduced to 2 files per advisory). The plan was compact: Batch 1 runs Tasks 1 and 2 in parallel (AGENT.md and SKILL.md), gated on Task 2 (classification boundary), then Batch 2 runs Task 3 (docs vocabulary alignment).

### Phase 3.5: Architecture Review

Five mandatory reviewers assessed the plan. security-minion: APPROVE -- classification boundary is security-positive (reduces review-skipping risk). test-minion: ADVISE -- recommended adding mixed-file and CLAUDE.md-only verification scenarios. ux-strategy-minion: APPROVE -- journey coherence maintained, no cognitive load increase. lucy: ADVISE -- flagged D5 contradiction (conflict resolution dropped it but Task 3 still included it), narrative inconsistency about supporting agents. margo: ADVISE -- classification table slightly over-specified but acceptable at ~10 lines, docs/agent-anatomy.md cross-reference worth dropping. All advisories were incorporated: D5 dropped from Task 3, 2 verification scenarios added, informational notes preserved for human owner.

### Phase 4: Execution

Batch 1 executed Tasks 1 and 2 in parallel on opus. Task 1 (ai-modeling-minion): added 2 delegation table rows at AGENT.md lines 137-138, File-Domain Awareness principle at line 269, and updated Phase 5 summary at line 768. Task 2 (ai-modeling-minion): replaced the Phase 5 skip conditional at SKILL.md line 1674 with the full classification boundary (definition + 5-row table + operational rule + jargon guardrail), updated skip conditional at lines 1650-1651, updated wrap-up verification summary at both locations with parenthetical explanation format and new verification scenarios. Gate auto-approved per user directive. Batch 2 executed Task 3 (software-docs-minion): updated docs/orchestration.md Phase 5 description at line 122, added Decision 30 to docs/decisions.md.

### Phase 5: Code Review

Three reviewers assessed the implementation on opus. code-review-minion: APPROVE -- all changes correct and consistent, old "no code files" phrasing eliminated, the-plan.md untouched. lucy: APPROVE -- all 7 success criteria pass, no drift detected, classification proportional. margo: APPROVE -- implementation proportional, single point of truth, compact format, clean vocabulary transition.

### Phase 6: Test Execution

Skipped (no executable code produced, no test infrastructure in project).

### Phase 7: Deployment

Skipped (not requested).

### Phase 8: Documentation

Skipped (documentation covered in Task 3 execution).

## Agent Contributions

<details>
<summary>Agent Contributions (4 planning, 5 architecture review, 3 code review)</summary>

### Planning

**ai-modeling-minion**: Defined filename-primary classification with directory context as tiebreaker and conservative default for edge cases.
- Adopted: classification table structure, 2 delegation table rows (consolidated from 3), File-Domain Awareness principle
- Risks flagged: RESEARCH.md classification surprise, over-classification false positives

**lucy**: Confirmed simple enumerated filename list is proportional per YAGNI/KISS principles.
- Adopted: simplicity validation, the-plan.md divergence flagging
- Risks flagged: the-plan.md divergence needs human owner reconciliation

**ux-strategy-minion**: Recommended dark kitchen preservation, parenthetical wrap-up explanation, outcome language guardrail.
- Adopted: wrap-up parenthetical format, jargon guardrail sentence, no user-facing classification labels
- Risks flagged: none

**software-docs-minion**: Recommended canonical definition at point of use in SKILL.md, vocabulary-only alignment elsewhere.
- Adopted: SKILL.md as canonical location, 3-part inline structure, Decision 30 entry
- Risks flagged: dual-classification-taxonomy drift risk

### Architecture Review

**security-minion**: APPROVE. Classification boundary is security-positive -- reduces risk of skipping review for behavior-affecting files.

**test-minion**: ADVISE. Recommended adding mixed-file and CLAUDE.md-only verification scenarios to strengthen coverage of most likely misclassification paths.

**ux-strategy-minion**: APPROVE. Journey coherence maintained, zero cognitive load increase, no feature creep.

**lucy**: ADVISE. Flagged D5 (agent-anatomy.md) contradiction between conflict resolution and Task 3 instructions. Flagged narrative inconsistency about supporting agent assignment on delegation row 2.

**margo**: ADVISE. Classification table slightly over-specified but acceptable. File-Domain Awareness principle mildly overlaps delegation rows but adds explanatory value. docs/agent-anatomy.md cross-reference worth dropping.

### Code Review

**code-review-minion**: APPROVE. All changes correct and consistent. Old "no code files" phrasing eliminated from all modified files. the-plan.md confirmed untouched.

**lucy**: APPROVE. All 7 success criteria pass. No drift, proportional classification, consistent vocabulary across all files.

**margo**: APPROVE. Zero complexity budget spent. Single point of truth, compact format, clean vocabulary transition.

</details>

## Execution

### Tasks

| # | Task | Agent | Status |
|---|------|-------|--------|
| 1 | Add delegation table entries and file-domain awareness principle to AGENT.md | ai-modeling-minion | completed |
| 2 | Define classification boundary and fix Phase 5 skip conditional in SKILL.md | ai-modeling-minion | completed |
| 3 | Align vocabulary in docs/orchestration.md and docs/decisions.md | software-docs-minion | completed |

### Files Changed

| File | Action | Description |
|------|--------|-------------|
| [nefario/AGENT.md](../../nefario/AGENT.md) | modified | Added 2 delegation table rows, File-Domain Awareness principle, updated Phase 5 summary |
| [skills/nefario/SKILL.md](../../skills/nefario/SKILL.md) | modified | Added classification boundary definition (table + definition + operational rule), updated skip conditionals, updated wrap-up verification summary format |
| [docs/orchestration.md](../orchestration.md) | modified | Updated Phase 5 description with logic-bearing markdown vocabulary |
| [docs/decisions.md](../decisions.md) | modified | Added Decision 30: Logic-Bearing Markdown Classification |

### Approval Gates

| Gate Title | Agent | Confidence | Outcome | Rounds |
|------------|-------|------------|---------|--------|
| Classification boundary in SKILL.md | ai-modeling-minion | HIGH | approved | 0 |

## Decisions

#### Classification Boundary in SKILL.md

**Decision**: Approve the filename-based classification boundary that classifies AGENT.md, SKILL.md, RESEARCH.md, and CLAUDE.md as logic-bearing markdown requiring Phase 5 code review.
**Rationale**: The classification is deterministic, compact (~20 lines), placed at the point of application, and uses the project's existing naming conventions. Conservative default (run review when ambiguous) ensures false negatives are minimized.
**Rejected**: Extension-based classification (the bug being fixed); content-analysis heuristics (fragile, inconsistent across sessions).
**Confidence**: HIGH
**Outcome**: approved (auto-approved per user directive, with lucy governance review confirming all success criteria pass)

## Verification

| Phase | Result |
|-------|--------|
| Code Review | 3 APPROVE (code-review-minion, lucy, margo) |
| Test Execution | Skipped (no executable code produced) |
| Deployment | Skipped (not requested) |
| Documentation | Covered in Task 3 execution |

## Session Resources

<details>
<summary>Session resources (1 skill)</summary>

### Skills Invoked

- `/nefario` -- orchestration workflow

Context compaction: 1 event

</details>

## Working Files

<details>
<summary>Working files (31 files)</summary>

Companion directory: [2026-02-13-204148-logic-bearing-markdown-classification/](./2026-02-13-204148-logic-bearing-markdown-classification/)

- [Original Prompt](./2026-02-13-204148-logic-bearing-markdown-classification/prompt.md)

**Outputs**
- [Phase 1: Meta-plan](./2026-02-13-204148-logic-bearing-markdown-classification/phase1-metaplan.md)
- [Phase 1: Meta-plan re-run](./2026-02-13-204148-logic-bearing-markdown-classification/phase1-metaplan-rerun.md)
- [Phase 2: ai-modeling-minion](./2026-02-13-204148-logic-bearing-markdown-classification/phase2-ai-modeling-minion.md)
- [Phase 2: lucy](./2026-02-13-204148-logic-bearing-markdown-classification/phase2-lucy.md)
- [Phase 2: software-docs-minion](./2026-02-13-204148-logic-bearing-markdown-classification/phase2-software-docs-minion.md)
- [Phase 2: ux-strategy-minion](./2026-02-13-204148-logic-bearing-markdown-classification/phase2-ux-strategy-minion.md)
- [Phase 3: Synthesis](./2026-02-13-204148-logic-bearing-markdown-classification/phase3-synthesis.md)
- [Phase 3.5: security-minion](./2026-02-13-204148-logic-bearing-markdown-classification/phase3.5-security-minion.md)
- [Phase 3.5: test-minion](./2026-02-13-204148-logic-bearing-markdown-classification/phase3.5-test-minion.md)
- [Phase 3.5: ux-strategy-minion](./2026-02-13-204148-logic-bearing-markdown-classification/phase3.5-ux-strategy-minion.md)
- [Phase 3.5: lucy](./2026-02-13-204148-logic-bearing-markdown-classification/phase3.5-lucy.md)
- [Phase 3.5: margo](./2026-02-13-204148-logic-bearing-markdown-classification/phase3.5-margo.md)
- [Phase 5: code-review-minion](./2026-02-13-204148-logic-bearing-markdown-classification/phase5-code-review-minion.md)
- [Phase 5: lucy](./2026-02-13-204148-logic-bearing-markdown-classification/phase5-lucy.md)
- [Phase 5: margo](./2026-02-13-204148-logic-bearing-markdown-classification/phase5-margo.md)

**Prompts**
- [Phase 1: Meta-plan prompt](./2026-02-13-204148-logic-bearing-markdown-classification/phase1-metaplan-prompt.md)
- [Phase 1: Meta-plan re-run prompt](./2026-02-13-204148-logic-bearing-markdown-classification/phase1-metaplan-rerun-prompt.md)
- [Phase 2: ai-modeling-minion prompt](./2026-02-13-204148-logic-bearing-markdown-classification/phase2-ai-modeling-minion-prompt.md)
- [Phase 2: lucy prompt](./2026-02-13-204148-logic-bearing-markdown-classification/phase2-lucy-prompt.md)
- [Phase 2: software-docs-minion prompt](./2026-02-13-204148-logic-bearing-markdown-classification/phase2-software-docs-minion-prompt.md)
- [Phase 2: ux-strategy-minion prompt](./2026-02-13-204148-logic-bearing-markdown-classification/phase2-ux-strategy-minion-prompt.md)
- [Phase 3: Synthesis prompt](./2026-02-13-204148-logic-bearing-markdown-classification/phase3-synthesis-prompt.md)
- [Phase 3.5: security-minion prompt](./2026-02-13-204148-logic-bearing-markdown-classification/phase3.5-security-minion-prompt.md)
- [Phase 3.5: test-minion prompt](./2026-02-13-204148-logic-bearing-markdown-classification/phase3.5-test-minion-prompt.md)
- [Phase 3.5: ux-strategy-minion prompt](./2026-02-13-204148-logic-bearing-markdown-classification/phase3.5-ux-strategy-minion-prompt.md)
- [Phase 3.5: lucy prompt](./2026-02-13-204148-logic-bearing-markdown-classification/phase3.5-lucy-prompt.md)
- [Phase 3.5: margo prompt](./2026-02-13-204148-logic-bearing-markdown-classification/phase3.5-margo-prompt.md)
- [Phase 4: ai-modeling-minion Task 1 prompt](./2026-02-13-204148-logic-bearing-markdown-classification/phase4-ai-modeling-minion-task1-prompt.md)
- [Phase 4: ai-modeling-minion Task 2 prompt](./2026-02-13-204148-logic-bearing-markdown-classification/phase4-ai-modeling-minion-task2-prompt.md)
- [Phase 4: software-docs-minion Task 3 prompt](./2026-02-13-204148-logic-bearing-markdown-classification/phase4-software-docs-minion-task3-prompt.md)

</details>
