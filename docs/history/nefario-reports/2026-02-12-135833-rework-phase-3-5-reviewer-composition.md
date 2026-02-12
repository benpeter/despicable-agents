---
type: nefario-report
version: 3
date: "2026-02-12"
time: "13:58:33"
task: "Rework Phase 3.5 reviewer composition with discretionary selection and approval gate"
source-issue: 49
mode: full
agents-involved: [ux-strategy-minion, devx-minion, lucy, ai-modeling-minion, security-minion, test-minion, software-docs-minion, margo, code-review-minion]
task-count: 4
gate-count: 2
outcome: completed
---

# Rework Phase 3.5 reviewer composition with discretionary selection and approval gate

## Summary

Restructured Phase 3.5 Architecture Review from a monolithic 6-ALWAYS + 4-conditional reviewer model to 5 mandatory + 6 discretionary reviewers with a user approval gate. The mandatory roster (security, test, software-docs, lucy, margo) always reviews; the discretionary pool (ux-strategy, ux-design, accessibility, sitespeed, observability, user-docs) is selected by nefario using a domain signal heuristic and approved by the user before spawning. software-docs-minion's Phase 3.5 role was narrowed to producing a documentation impact checklist consumed by Phase 8.

## Original Prompt

> Rework Phase 3.5 reviewer composition with discretionary selection and approval gate (issue #49). Use opus for all agents and tasks.

## Key Design Decisions

#### Domain Signal Table over Hardcoded Conditionals

**Rationale**:
- Nefario already performs contextual analysis in Phase 1 (meta-plan) for planning team selection; reusing that pattern for reviewer selection is natural
- Heuristic domain signals ("Plan includes user-facing workflow changes") are more robust than rigid pattern matching ("2+ tasks produce runtime components")
- Forced yes/no enumeration with rationale prevents over-inclusion while remaining flexible

**Alternatives Rejected**:
- Hardcoded conditionals: Brittle, cannot adapt to novel plan shapes
- Free-form selection without signals: No quality anchor for rationale text

#### "Skip review" over "Skip discretionary"

**Rationale**:
- "Skip discretionary" creates a half-measure -- mandatory reviewers still run, consuming compute and time
- The Execution Plan Approval Gate still provides a checkpoint, so skipping Phase 3.5 doesn't remove oversight
- "Skip review" correctly maps the control to the effect (Norman's mapping principle)

**Alternatives Rejected**:
- "Skip discretionary" (run mandatory only): Wastes compute when user's intent is to move fast
- "Reject" label: Implies finality; "Skip review" is more accurate

#### software-docs-minion ADVISE Ceiling

**Rationale**:
- Documentation gaps are addressed through the Phase 8 checklist, not by blocking the plan
- BLOCK is retained only for the rare case where the plan fundamentally cannot be documented

**Alternatives Rejected**:
- Full BLOCK capability: Creates documentation-triggered revision loops that delay execution for non-critical issues
- No BLOCK at all: Removes the safety valve for genuinely undocumentable plans

### Conflict Resolutions

1. **Gate header "Review" vs "Reviewers"**: Resolved in favor of "Review" (ux-strategy-minion). Single-word shift from Phase 2's "Team" signals different context without explanatory text.
2. **Discretionary selection method**: Resolved in favor of domain signal table (ai-modeling-minion) over lighter trigger rules (devx-minion). Heuristic anchors are more robust than text pattern matching.
3. **software-docs-minion BLOCK capability**: Resolved as ADVISE ceiling with extreme-case BLOCK (synthesis of devx-minion's full capability recommendation and ux-strategy-minion's no-BLOCK recommendation).

## Phases

### Phase 1: Meta-Plan

Nefario identified 3 initial specialists: ux-strategy-minion (approval gate interaction design), devx-minion (SKILL.md structure and checklist format), and lucy (governance alignment). User adjusted the team to add ai-modeling-minion (selection logic and prompt patterns). Two project-local skills discovered (despicable-lab, despicable-statusline) but neither overlapped with the task domain.

### Phase 2: Specialist Planning

Four specialists contributed in parallel. ux-strategy-minion designed the gate interaction model (6-10 lines, header "Review", "Skip review" semantics, plan-grounded rationales). devx-minion recommended the checklist as a single artifact with owner tags and Phase 8 as a merge operation. lucy confirmed no governance conflict between cross-cutting checklist (phases 1-4) and Phase 3.5 review, identified user-docs-minion as NEW to Phase 3.5, and flagged two small spillovers. ai-modeling-minion proposed the domain signal table with heuristic analysis and forced yes/no enumeration. No additional specialists were requested.

### Phase 3: Synthesis

Specialist input was merged into a 4-task sequential plan. Key conflict resolutions: "Skip review" over "Skip discretionary", domain signal table over hardcoded conditionals, "Review" header over "Reviewers", ADVISE ceiling for software-docs-minion. Two approval gates placed on Tasks 1 and 2 (roster definition and gate specification respectively). No specialist contributions were rejected entirely.

### Phase 3.5: Architecture Review

6 mandatory reviewers participated (all using opus per user directive). All returned ADVISE verdicts with no BLOCKs. Key advisories incorporated: annotate "NEVER skipped" for user-skip compatibility (lucy), add phase3.5-docs-checklist.md to scratch directory structure (software-docs-minion), improve "Skip review" description to mention Execution Plan gate still applies (ux-strategy-minion), drop "Not Applicable" section from checklist format (margo), add rationale examples to discretionary selection (ux-strategy-minion).

### Phase 4: Execution

4 tasks executed sequentially in 4 batches. Task 1 (devx-minion) updated [nefario/AGENT.md](../../nefario/AGENT.md) with new roster tables, synthesis template, cross-cutting clarification, and two advisory additions. Task 2 (devx-minion) rewrote [SKILL.md](../../skills/nefario/SKILL.md) Phase 3.5 with mandatory/discretionary split, Reviewer Approval Gate, and software-docs-minion checklist prompt. Task 3 (devx-minion) updated SKILL.md Phase 8 with merge logic consuming the Phase 3.5 checklist. Task 4 (software-docs-minion) updated [docs/orchestration.md](../../docs/orchestration.md) with new reviewer tables, gate description, Phase 8 checklist source, and Mermaid diagram. All tasks completed successfully.

### Phase 5: Code Review

Three reviewers in parallel. code-review-minion: APPROVE with 1 NIT (orchestration.md cross-cutting clarification note could be added). lucy: ADVISE with 2 expected divergences (the-plan.md not updated, explicitly out of scope per CLAUDE.md). margo: ADVISE with no blocking concerns; noted the implementation is proportional to the problem. No BLOCKs.

### Phase 6: Test Execution

Skipped (no executable code produced -- all changes are markdown specifications).

### Phase 7: Deployment

Skipped (not requested).

### Phase 8: Documentation

Skipped (orchestration.md update was Task 4 of execution -- documentation was the deliverable itself).

<details>
<summary>Agent Contributions (4 planning, 6 review, 3 code review)</summary>

### Planning

**ux-strategy-minion**: Designed Phase 3.5 gate interaction model reusing Phase 2 pattern but lighter weight.
- Adopted: 6-10 line target, "Review" header, "Skip review" semantics, plan-grounded rationales max 60 chars, auto-skip when 0 discretionary
- Risks flagged: Gate echo rubber-stamping (MEDIUM), "Skip review" misuse (LOW)

**devx-minion**: Designed checklist format and Phase 8 merge logic.
- Adopted: Markdown checkboxes with owner tags/scope/paths/priority, Phase 8 as merge operation supplementing 3.5 checklist, gate insertion between identify and spawn
- Risks flagged: Checklist staleness if execution deviates (MEDIUM), interaction fatigue from third gate (LOW)

**lucy**: Confirmed governance alignment and identified scope boundary issues.
- Adopted: Cross-cutting clarification sentence, user-docs-minion flagged as NEW, synthesis output template update
- Risks flagged: Referenced analysis file doesn't exist (LOW), fourth gate type risks approval fatigue (MEDIUM)

**ai-modeling-minion**: Designed discretionary selection logic using domain signal heuristics.
- Adopted: Domain signal table, forced yes/no enumeration with rationale, reuse of Phase 1 meta-plan reasoning pattern, three gate options
- Risks flagged: Selection quality dependent on plan analysis, rationale quality variable

### Architecture Review

**security-minion**: ADVISE. Three non-blocking warnings: sanitization on new checklist file (negligible risk since content is derivative), checklist injection vector (LOW, flows only to LLM agents), domain signal table trust boundary (no concern).

**test-minion**: ADVISE. Four non-blocking warnings: growing untested orchestration paths, SKILL.md edit regions safely separated, auto-skip path verification gap, domain signal table not testable by design.

**ux-strategy-minion**: ADVISE. Six non-blocking advisories: auto-skip CONDENSE wording, "Skip review" description should mention Execution Plan gate, rationale examples needed, gate budget monitoring heuristic.

**software-docs-minion**: ADVISE. One actionable warning: phase3.5-docs-checklist.md not listed in Scratch Directory Structure.

**lucy**: ADVISE. Two findings: "NEVER skipped" line contradicts new "Skip review" gate (annotation needed), Task 1 section D placement slightly imprecise (gated, acceptable).

**margo**: ADVISE. One suggestion: drop "Not Applicable" section from checklist format.

### Code Review

**code-review-minion**: APPROVE. All three files internally consistent. Gate specification complete. 1 NIT: orchestration.md could add cross-cutting clarification note.

**lucy**: ADVISE. Expected divergence with the-plan.md (out of scope per CLAUDE.md). All 11 issue requirements met with full traceability.

**margo**: ADVISE. Implementation proportional to problem. No YAGNI violations. Noted the-plan.md narrative divergence for future human update.

</details>

## Execution

### Tasks

| # | Task | Agent | Status |
|---|------|-------|--------|
| 1 | Update AGENT.md -- roster tables, synthesis template, cross-cutting clarification | devx-minion | completed |
| 2 | Update SKILL.md -- Phase 3.5 gate, reviewer identification, software-docs prompt | devx-minion | completed |
| 3 | Update SKILL.md -- Phase 8 checklist merge logic | devx-minion | completed |
| 4 | Update docs/orchestration.md | software-docs-minion | completed |

### Files Changed

| File Path | Action | Description |
|-----------|--------|-------------|
| [nefario/AGENT.md](../../nefario/AGENT.md) | modified | New ALWAYS/discretionary reviewer tables, synthesis template, cross-cutting clarification, verdict exception, "NEVER skipped" annotation (+35/-9) |
| [skills/nefario/SKILL.md](../../skills/nefario/SKILL.md) | modified | Phase 3.5 rewrite (mandatory/discretionary, Reviewer Approval Gate, software-docs prompt) + Phase 8 merge logic (+201/-31) |
| [docs/orchestration.md](../../docs/orchestration.md) | modified | Reviewer tables, gate description, Mermaid diagram, Phase 8 checklist source (+43/-24) |

### Approval Gates

| Gate Title | Agent | Confidence | Outcome | Rounds |
|------------|-------|------------|---------|--------|
| AGENT.md roster and synthesis template | devx-minion | HIGH | approved | 1 |
| SKILL.md Phase 3.5 gate specification | devx-minion | HIGH | approved | 1 |

## Decisions

#### AGENT.md Roster and Synthesis Template

**Decision**: AGENT.md defines 5 mandatory + 6 discretionary reviewers with domain signal table and cross-cutting clarification.
**Rationale**: Mandatory reviewers cover security, testing, docs impact, and governance (always needed). Discretionary pool uses domain signal heuristics instead of rigid conditionals. Cross-cutting clarification prevents governance confusion between planning inclusion and review inclusion.
**Rejected**: Keeping ux-strategy-minion as ALWAYS (issue #49 explicitly moves it to discretionary).
**Confidence**: HIGH
**Outcome**: approved

#### SKILL.md Phase 3.5 Gate Specification

**Decision**: SKILL.md Phase 3.5 implements mandatory/discretionary split with Reviewer Approval Gate and software-docs checklist prompt.
**Rationale**: Gate reuses Team Approval Gate pattern (AskUserQuestion, 3 options, 2-round adjust cap). "Skip review" gives full skip per conflict resolution. Checklist format uses owner tags for direct Phase 8 routing.
**Rejected**: "Skip discretionary" (half-measure that wastes compute on mandatory reviewers when user wants speed).
**Confidence**: HIGH
**Outcome**: approved

## Verification

| Phase | Result |
|-------|--------|
| Code Review | 1 APPROVE, 2 ADVISE. No blocking findings. |
| Test Execution | Skipped (no executable code produced) |
| Deployment | Skipped (not requested) |
| Documentation | Covered by Task 4 (orchestration.md update) |

<details>
<summary>Working Files (35 files)</summary>

Companion directory: [2026-02-12-135833-rework-phase-3-5-reviewer-composition/](./2026-02-12-135833-rework-phase-3-5-reviewer-composition/)

- [Original Prompt](./2026-02-12-135833-rework-phase-3-5-reviewer-composition/prompt.md)

**Outputs**
- [Phase 1: Meta-plan](./2026-02-12-135833-rework-phase-3-5-reviewer-composition/phase1-metaplan.md)
- [Phase 2: ux-strategy-minion](./2026-02-12-135833-rework-phase-3-5-reviewer-composition/phase2-ux-strategy-minion.md)
- [Phase 2: devx-minion](./2026-02-12-135833-rework-phase-3-5-reviewer-composition/phase2-devx-minion.md)
- [Phase 2: lucy](./2026-02-12-135833-rework-phase-3-5-reviewer-composition/phase2-lucy.md)
- [Phase 2: ai-modeling-minion](./2026-02-12-135833-rework-phase-3-5-reviewer-composition/phase2-ai-modeling-minion.md)
- [Phase 3: Synthesis](./2026-02-12-135833-rework-phase-3-5-reviewer-composition/phase3-synthesis.md)
- [Phase 3.5: security-minion](./2026-02-12-135833-rework-phase-3-5-reviewer-composition/phase3.5-security-minion.md)
- [Phase 3.5: test-minion](./2026-02-12-135833-rework-phase-3-5-reviewer-composition/phase3.5-test-minion.md)
- [Phase 3.5: ux-strategy-minion](./2026-02-12-135833-rework-phase-3-5-reviewer-composition/phase3.5-ux-strategy-minion.md)
- [Phase 3.5: software-docs-minion](./2026-02-12-135833-rework-phase-3-5-reviewer-composition/phase3.5-software-docs-minion.md)
- [Phase 3.5: lucy](./2026-02-12-135833-rework-phase-3-5-reviewer-composition/phase3.5-lucy.md)
- [Phase 3.5: margo](./2026-02-12-135833-rework-phase-3-5-reviewer-composition/phase3.5-margo.md)
- [Phase 5: code-review-minion](./2026-02-12-135833-rework-phase-3-5-reviewer-composition/phase5-code-review-minion.md)
- [Phase 5: lucy](./2026-02-12-135833-rework-phase-3-5-reviewer-composition/phase5-lucy.md)
- [Phase 5: margo](./2026-02-12-135833-rework-phase-3-5-reviewer-composition/phase5-margo.md)

**Prompts**
- [Phase 1: Meta-plan prompt](./2026-02-12-135833-rework-phase-3-5-reviewer-composition/phase1-metaplan-prompt.md)
- [Phase 2: ux-strategy-minion prompt](./2026-02-12-135833-rework-phase-3-5-reviewer-composition/phase2-ux-strategy-minion-prompt.md)
- [Phase 2: devx-minion prompt](./2026-02-12-135833-rework-phase-3-5-reviewer-composition/phase2-devx-minion-prompt.md)
- [Phase 2: lucy prompt](./2026-02-12-135833-rework-phase-3-5-reviewer-composition/phase2-lucy-prompt.md)
- [Phase 2: ai-modeling-minion prompt](./2026-02-12-135833-rework-phase-3-5-reviewer-composition/phase2-ai-modeling-minion-prompt.md)
- [Phase 3: Synthesis prompt](./2026-02-12-135833-rework-phase-3-5-reviewer-composition/phase3-synthesis-prompt.md)
- [Phase 3.5: security-minion prompt](./2026-02-12-135833-rework-phase-3-5-reviewer-composition/phase3.5-security-minion-prompt.md)
- [Phase 3.5: test-minion prompt](./2026-02-12-135833-rework-phase-3-5-reviewer-composition/phase3.5-test-minion-prompt.md)
- [Phase 3.5: ux-strategy-minion prompt](./2026-02-12-135833-rework-phase-3-5-reviewer-composition/phase3.5-ux-strategy-minion-prompt.md)
- [Phase 3.5: software-docs-minion prompt](./2026-02-12-135833-rework-phase-3-5-reviewer-composition/phase3.5-software-docs-minion-prompt.md)
- [Phase 3.5: lucy prompt](./2026-02-12-135833-rework-phase-3-5-reviewer-composition/phase3.5-lucy-prompt.md)
- [Phase 3.5: margo prompt](./2026-02-12-135833-rework-phase-3-5-reviewer-composition/phase3.5-margo-prompt.md)
- [Phase 4: Task 1 devx-minion prompt](./2026-02-12-135833-rework-phase-3-5-reviewer-composition/phase4-task1-devx-minion-prompt.md)
- [Phase 4: Task 2 devx-minion prompt](./2026-02-12-135833-rework-phase-3-5-reviewer-composition/phase4-task2-devx-minion-prompt.md)
- [Phase 4: Task 3 devx-minion prompt](./2026-02-12-135833-rework-phase-3-5-reviewer-composition/phase4-task3-devx-minion-prompt.md)
- [Phase 4: Task 4 software-docs prompt](./2026-02-12-135833-rework-phase-3-5-reviewer-composition/phase4-task4-software-docs-prompt.md)
- [Phase 5: code-review-minion prompt](./2026-02-12-135833-rework-phase-3-5-reviewer-composition/phase5-code-review-minion-prompt.md)
- [Phase 5: lucy prompt](./2026-02-12-135833-rework-phase-3-5-reviewer-composition/phase5-lucy-prompt.md)
- [Phase 5: margo prompt](./2026-02-12-135833-rework-phase-3-5-reviewer-composition/phase5-margo-prompt.md)

</details>
