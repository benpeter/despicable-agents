---
type: nefario-report
version: 3
date: "2026-02-13"
time: "19:19:53"
task: "Make all nefario advisories self-contained and readable in isolation"
source-issue: 111
mode: full
agents-involved: [software-docs-minion, ux-strategy-minion, ai-modeling-minion, lucy, margo, security-minion, test-minion, code-review-minion]
task-count: 4
gate-count: 2
outcome: completed
---

# Make all nefario advisories self-contained and readable in isolation

## Summary

Updated the advisory verdict format across all nefario surfaces to ensure every advisory is readable without referencing invisible session context. Added SCOPE field to ADVISE and BLOCK verdicts, established content rules preventing plan-internal references, and aligned 5 files with the canonical format definition. All changes are to prompt text and documentation templates -- no executable code modified.

## Original Prompt

> Make all nefario advisories self-contained and readable in isolation (#111, use opus for all agents)

## Key Design Decisions

#### Add SCOPE field vs. instructions-only approach

**Rationale**:
- Reviewer verdict format had no labeled slot for the artifact name -- reviewers wrote `TASK: Task 3` with no artifact anchor
- A labeled slot (SCOPE) produces better format compliance than prose instructions alone, per prompt engineering practice
- 4-of-5 specialists recommended a structural field; margo's content-quality constraints were adopted as complement

**Alternatives Rejected**:
- Instructions-only (margo): insufficient because reviewer verdicts lack a task-title anchor at the point of authoring
- XML tags (ai-modeling-minion): declined per KISS; plain-text labels with examples are sufficient for LLM consumers

#### SCOPE naming over SUBJECT/ARTIFACT/TARGET

**Rationale**:
- Aligns with documentation terminology ("scope of impact")
- Less generic than SUBJECT, more inclusive than ARTIFACT (covers concepts and flows, not just files)

**Alternatives Rejected**:
- SUBJECT: too generic
- ARTIFACT: too narrow (excludes concepts like "OAuth flow")

#### Preserve 3-line gate cap

**Rationale**:
- SCOPE replaces the `Task N: <task title>` header line, not added below it
- Gate format stays at 3 content lines: header (SCOPE + task ref), CHANGE, WHY

**Alternatives Rejected**:
- 4-line cap (lucy): unnecessary since SCOPE replaces rather than extends the header

### Conflict Resolutions

1. **New field (SCOPE) vs. instructions-only**: Resolved in favor of SCOPE with margo's content-quality constraints adopted in full. Margo's position depended on task titles reliably naming artifacts, which they do in synthesis output but not in reviewer verdicts.

2. **3-line cap vs. 4-line cap**: Preserved 3-line cap. SCOPE replaces the task-title header line (no net line addition).

3. **XML tags vs. plain-text labels**: Resolved in favor of plain-text per KISS. ai-modeling-minion acknowledged this trade-off.

## Phases

### Phase 1: Meta-Plan

Nefario identified 4 specialists for planning: software-docs-minion (documentation architecture), ux-strategy-minion (cognitive load analysis), ai-modeling-minion (prompt engineering), and lucy (governance alignment). The task scope was clear: update advisory format across all rendering surfaces to be self-contained.

### Phase 2: Specialist Planning

Five specialists contributed (including margo, added in second round). software-docs-minion proposed the SCOPE field and mapped all 5 advisory surfaces. ux-strategy-minion applied Krug's three-question test to validate the self-containment requirement. ai-modeling-minion analyzed prompt engineering for format compliance. lucy identified the AGENT.md-to-SKILL.md consistency requirement. margo argued for instructions-only, providing content-quality constraints that were adopted wholesale.

### Phase 3: Synthesis

Nefario resolved the central conflict (SCOPE field vs. instructions-only) in favor of SCOPE with margo's content rules as complement. The plan produced 4 tasks across 2 batches with 2 gates, all assigned to software-docs-minion on opus. The RECOMMENDATION field was eliminated (merged into CHANGE) per software-docs-minion and lucy's recommendation.

### Phase 3.5: Architecture Review

Six reviewers ran in parallel (5 mandatory + 1 discretionary ai-modeling-minion). Results: 3 APPROVE (security-minion, test-minion, ux-strategy-minion), 3 ADVISE (margo, ai-modeling-minion, lucy), 0 BLOCK. Four advisories were consolidated and folded into Task 2's prompt before execution.

### Phase 4: Execution

Batch 1 (Task 1: nefario/AGENT.md) completed and was approved at gate. Batch 2 (Tasks 2-4) ran in parallel. Task 2 (SKILL.md, largest task with 5 sections) completed with all 4 advisories incorporated. Tasks 3 (lucy/margo AGENT.md) and 4 (TEMPLATE.md) completed quickly. All 4 tasks completed successfully.

### Phase 5: Code Review

Three reviewers ran in parallel: code-review-minion, lucy, margo. All returned ADVISE (0 BLOCK). Findings were minor and non-blocking: code-review-minion noted all examples use `[security]` domain and BLOCK example placement is ambiguous; lucy flagged inline summary as missed (false positive -- intentionally unchanged per margo advisory); margo noted example duplication across prompts (intentional for self-contained templates).

### Phase 6: Test Execution

Skipped (user-requested --skip-tests; no executable code changed).

### Phase 7: Deployment

Skipped (not applicable).

### Phase 8: Documentation

Skipped (no checklist items -- all changes are documentation/prompt text; derivative doc TEMPLATE.md already updated as Task 4).

## Agent Contributions

<details>
<summary>Agent Contributions (5 planning, 6 review, 3 code review)</summary>

### Planning

**software-docs-minion**: Proposed SCOPE field, mapped all 5 advisory surfaces, designed the SCOPE-first gate format.
- Adopted: SCOPE field, surface mapping, RECOMMENDATION elimination
- Risks flagged: dual-definition drift between AGENT.md and SKILL.md

**ux-strategy-minion**: Applied Krug's three-question test ("what site, what page, what section") to validate self-containment.
- Adopted: recognition-over-recall analysis, self-containment test criteria
- Risks flagged: none

**ai-modeling-minion**: Analyzed prompt engineering for structured output compliance from reviewer agents.
- Adopted: good/bad example pair strategy, labeled-slot compliance principle
- Risks flagged: XML tags recommended but declined per KISS

**lucy**: Identified AGENT.md-to-SKILL.md consistency requirement and original user request path addition.
- Adopted: cross-reference note, original user request path in reviewer prompts
- Risks flagged: TASK field routing dependency

**margo**: Argued for instructions-only approach; provided content-quality constraints.
- Adopted: self-containment test, no plan-internal references rule, one-sentence-per-field
- Risks flagged: over-engineering risk from structural changes

### Architecture Review

**security-minion**: APPROVE. No concerns.

**test-minion**: APPROVE. No concerns.

**ux-strategy-minion**: APPROVE. No concerns.

**margo**: ADVISE. SCOPE: Inline summary template in SKILL.md. CHANGE: Keep simple `ADVISE(details)` format instead of expanding to SCOPE/CHANGE/WHY. WHY: Inline summaries are compressed one-liner status indicators; structured multi-field format is over-fitted for this surface.

**ai-modeling-minion**: ADVISE.
- SCOPE: Bad example in reviewer prompt template. CHANGE: Fix to use labeled fields with vague/plan-internal content. WHY: Current bad example teaches format-presence vs content-quality, which is the wrong distinction.
- SCOPE: BLOCK verdict in reviewer prompt. CHANGE: Add one concrete BLOCK example. WHY: BLOCK verdicts halt execution and deserve equal compliance guidance.

**lucy**: ADVISE.
- SCOPE: BLOCK verdict in reviewer prompt. CHANGE: Add one concrete BLOCK example. WHY: No example risks inconsistent BLOCK formatting.
- SCOPE: ux-strategy-minion Write-your-verdict-to path. CHANGE: Preserve output path when replacing Instructions section. WHY: Section B replacement risks silently dropping this line.

### Code Review

**code-review-minion**: ADVISE. SCOPE: Reviewer prompt examples in SKILL.md. CHANGE: All examples use [security] domain tag; BLOCK example placement inside ADVISE section is ambiguous. WHY: Non-security reviewers don't see domain variation in examples.

**lucy**: ADVISE. SCOPE: Inline summary template in SKILL.md. CHANGE: Flagged as missed update. WHY: False positive -- intentionally unchanged per margo advisory incorporated before execution.

**margo**: ADVISE. SCOPE: Example content in SKILL.md reviewer prompts. CHANGE: 48 lines duplicated between generic and ux-strategy prompts. WHY: Intentional trade-off for self-contained templates; extraction would add reference mechanism.

</details>

## Execution

### Tasks

| # | Task | Agent | Status |
|---|------|-------|--------|
| 1 | Update verdict format in [nefario/AGENT.md](../../nefario/AGENT.md) | software-docs-minion | completed |
| 2 | Update all advisory surfaces in [SKILL.md](../../skills/nefario/SKILL.md) | software-docs-minion | completed |
| 3 | Update lucy and margo AGENT.md output standards | software-docs-minion | completed |
| 4 | Update execution report template ([TEMPLATE.md](./TEMPLATE.md)) | software-docs-minion | completed |

### Files Changed

| File | Action | Description |
|------|--------|-------------|
| [nefario/AGENT.md](../../nefario/AGENT.md) | modified | ADVISE format: SCOPE/CHANGE/WHY/TASK; BLOCK: +SCOPE; content rules; RECOMMENDATION eliminated (+27/-6) |
| [skills/nefario/SKILL.md](../../skills/nefario/SKILL.md) | modified | 5 advisory surfaces updated: reviewer prompts with examples, gate format, Phase 5 instruction (+105/-12) |
| [lucy/AGENT.md](../../lucy/AGENT.md) | modified | Self-contained findings bullet in Output Standards (+1) |
| [margo/AGENT.md](../../margo/AGENT.md) | modified | Self-contained findings bullet in Output Standards (+1) |
| [docs/history/nefario-reports/TEMPLATE.md](./TEMPLATE.md) | modified | ADVISE line format uses SCOPE/CHANGE/WHY in Agent Contributions (+7/-3) |

### Approval Gates

| Gate Title | Agent | Confidence | Outcome | Rounds |
|------------|-------|------------|---------|--------|
| Update verdict format in nefario/AGENT.md | software-docs-minion | HIGH | approved | 1 |
| Update all advisory surfaces in SKILL.md | software-docs-minion | HIGH | approved | 1 |

## Decisions

#### Update verdict format in nefario/AGENT.md

**Decision**: Canonical advisory format updated with SCOPE/CHANGE/WHY/TASK fields, RECOMMENDATION eliminated.
**Rationale**: SCOPE provides the labeled slot that guarantees every advisory names its subject at the point of authoring. Content rules prevent plan-internal references. RECOMMENDATION merged into CHANGE (functionally identical).
**Rejected**: XML tags (KISS violation), instructions-only (insufficient for reviewer verdicts that lack task-title context).
**Confidence**: HIGH
**Outcome**: approved

#### Update all advisory surfaces in SKILL.md

**Decision**: All 5 advisory surfaces aligned with canonical format; 4 Phase 3.5 advisories incorporated.
**Rationale**: Consistent format across all rendering surfaces ensures self-containment regardless of where an advisory is read. Advisories from architecture review incorporated: inline summary kept simple, bad example fixed, BLOCK example added, ux-strategy output path preserved.
**Rejected**: Expanding inline summary to full structured format (over-fitted for compressed one-liner per margo).
**Confidence**: HIGH
**Outcome**: approved

## Verification

| Phase | Result |
|-------|--------|
| Code Review | 3 ADVISE (all minor, no BLOCK) |
| Test Execution | Skipped (user-requested) |
| Deployment | Skipped (not applicable) |
| Documentation | Skipped (no checklist items) |

## Session Resources

<details>
<summary>Session resources (0 skills)</summary>

### Skills Invoked

- `/nefario` -- orchestration workflow

Context compaction: 2 events

</details>

## Working Files

<details>
<summary>Working files (34 files)</summary>

Companion directory: [2026-02-13-191953-self-contained-advisories/](./2026-02-13-191953-self-contained-advisories/)

- [Original Prompt](./2026-02-13-191953-self-contained-advisories/prompt.md)

**Outputs**
- [Phase 1: Meta-plan](./2026-02-13-191953-self-contained-advisories/phase1-metaplan.md)
- [Phase 2: ai-modeling-minion](./2026-02-13-191953-self-contained-advisories/phase2-ai-modeling-minion.md)
- [Phase 2: lucy](./2026-02-13-191953-self-contained-advisories/phase2-lucy.md)
- [Phase 2: margo](./2026-02-13-191953-self-contained-advisories/phase2-margo.md)
- [Phase 2: software-docs-minion](./2026-02-13-191953-self-contained-advisories/phase2-software-docs-minion.md)
- [Phase 2: ux-strategy-minion](./2026-02-13-191953-self-contained-advisories/phase2-ux-strategy-minion.md)
- [Phase 3: Synthesis](./2026-02-13-191953-self-contained-advisories/phase3-synthesis.md)
- [Phase 3.5: ai-modeling-minion](./2026-02-13-191953-self-contained-advisories/phase3.5-ai-modeling-minion.md)
- [Phase 3.5: lucy](./2026-02-13-191953-self-contained-advisories/phase3.5-lucy.md)
- [Phase 3.5: margo](./2026-02-13-191953-self-contained-advisories/phase3.5-margo.md)
- [Phase 3.5: security-minion](./2026-02-13-191953-self-contained-advisories/phase3.5-security-minion.md)
- [Phase 3.5: test-minion](./2026-02-13-191953-self-contained-advisories/phase3.5-test-minion.md)
- [Phase 3.5: ux-strategy-minion](./2026-02-13-191953-self-contained-advisories/phase3.5-ux-strategy-minion.md)
- [Phase 5: code-review-minion](./2026-02-13-191953-self-contained-advisories/phase5-code-review-minion.md)
- [Phase 5: lucy](./2026-02-13-191953-self-contained-advisories/phase5-lucy.md)
- [Phase 5: margo](./2026-02-13-191953-self-contained-advisories/phase5-margo.md)

**Prompts**
- [Phase 1: Meta-plan prompt](./2026-02-13-191953-self-contained-advisories/phase1-metaplan-prompt.md)
- [Phase 2: ai-modeling-minion prompt](./2026-02-13-191953-self-contained-advisories/phase2-ai-modeling-minion-prompt.md)
- [Phase 2: lucy prompt](./2026-02-13-191953-self-contained-advisories/phase2-lucy-prompt.md)
- [Phase 2: margo prompt](./2026-02-13-191953-self-contained-advisories/phase2-margo-prompt.md)
- [Phase 2: software-docs-minion prompt](./2026-02-13-191953-self-contained-advisories/phase2-software-docs-minion-prompt.md)
- [Phase 2: ux-strategy-minion prompt](./2026-02-13-191953-self-contained-advisories/phase2-ux-strategy-minion-prompt.md)
- [Phase 3: Synthesis prompt](./2026-02-13-191953-self-contained-advisories/phase3-synthesis-prompt.md)
- [Phase 3.5: ai-modeling-minion prompt](./2026-02-13-191953-self-contained-advisories/phase3.5-ai-modeling-minion-prompt.md)
- [Phase 3.5: lucy prompt](./2026-02-13-191953-self-contained-advisories/phase3.5-lucy-prompt.md)
- [Phase 3.5: margo prompt](./2026-02-13-191953-self-contained-advisories/phase3.5-margo-prompt.md)
- [Phase 3.5: security-minion prompt](./2026-02-13-191953-self-contained-advisories/phase3.5-security-minion-prompt.md)
- [Phase 3.5: test-minion prompt](./2026-02-13-191953-self-contained-advisories/phase3.5-test-minion-prompt.md)
- [Phase 3.5: ux-strategy-minion prompt](./2026-02-13-191953-self-contained-advisories/phase3.5-ux-strategy-minion-prompt.md)
- [Phase 4: Task 1 prompt](./2026-02-13-191953-self-contained-advisories/phase4-software-docs-minion-task1-prompt.md)
- [Phase 4: Task 2 prompt](./2026-02-13-191953-self-contained-advisories/phase4-software-docs-minion-task2-prompt.md)
- [Phase 4: Task 3 prompt](./2026-02-13-191953-self-contained-advisories/phase4-software-docs-minion-task3-prompt.md)
- [Phase 4: Task 4 prompt](./2026-02-13-191953-self-contained-advisories/phase4-software-docs-minion-task4-prompt.md)

</details>
