---
type: nefario-report
version: 3
date: "2026-03-17"
time: "09:34:19"
task: "Improve gate review transparency — surface decision rationale at approval gates"
mode: advisory
agents-involved: [nefario, ux-strategy-minion, ai-modeling-minion, lucy, software-docs-minion]
task-count: 0
gate-count: 0
outcome: completed
docs-debt: none
---

# Improve gate review transparency — surface decision rationale at approval gates

## Summary

Advisory analysis of how to enrich nefario approval gates with decision rationale, trade-offs, and rejected alternatives. Four specialists analyzed the gap between current gate presentations (task-oriented) and the user's need (decision-oriented). The team recommends adding a structured DECISIONS section (Chosen/Over/Why format, max 4 entries) to the Execution Plan Approval Gate, fed by upstream changes to the synthesis output format, inline summary template, and compaction focus strings.

## Original Prompt

> Look through the documentation format in ../web-resource-ledger/docs/evolution/ and also check the CLAUDE[.local].md files that make that happen. Currently, this project's gate reviews are opaque - they don't really give the user an idea of what the team has discussed and what the user is supposed to decide, so the user will have to check the scratch dir and find out. This format comes way closer, even if in how it's used, it's documentation in hindsight. But I want the team to evaluate how the gates can be improved so that the user has the rationale of the decisions they are supposed to make in front of them and can make a meaningful decision.

## Key Design Decisions

#### DECISIONS section replaces RISKS + CONFLICTS RESOLVED

**Rationale**:
- The Execution Plan gate currently has separate RISKS and CONFLICTS RESOLVED blocks (2-6 lines combined) that present conclusions without structure
- A unified DECISIONS section using Chosen/Over/Why format absorbs both blocks while adding rejected alternatives — the "primary anti-rubber-stamping measure" per the spec's own Anti-Fatigue Rules
- Budget-neutral: absorbed lines offset the new section's 4-16 lines

**Alternatives Rejected**:
- Expanding existing RATIONALE block (software-docs-minion): rejected because the Execution Plan gate has no RATIONALE block — that exists only in mid-execution gates. Would require creating a structural analog from scratch rather than converging formats.
- Adding DECISIONS alongside RISKS and CONFLICTS (keeping existing blocks): rejected because it inflates gate size without removing redundancy.

#### Scope limited to Execution Plan gate (defer Team gate)

**Rationale**:
- The user's complaint centers on the Execution Plan gate where plan-level decisions are invisible
- Team gate decisions are lower-stakes (agent composition is easily reversed, low blast radius)
- lucy recommended extending to the Team gate, but deferring avoids scope creep per YAGNI

**Alternatives Rejected**:
- Enriching all gate types simultaneously (lucy): deferred, not rejected. Address the primary complaint first, evaluate whether the same pattern is needed at other gates based on real usage.

### Conflict Resolutions

Three conflicts resolved during synthesis:

1. **New section vs. existing block**: software-docs-minion preferred expanding existing structures; ux-strategy-minion and ai-modeling-minion favored a new DECISIONS section. Resolved: new section, because the Execution Plan gate has no equivalent RATIONALE block to expand into.

2. **Team gate scope**: lucy recommended extending changes to the Team Approval Gate. Resolved: deferred to avoid scope creep.

3. **UPCOMING DECISIONS preview block**: software-docs-minion proposed previewing mid-execution gate decisions at the plan gate. Resolved: rejected (YAGNI — the task list already shows which tasks are gated).

## Phases

### Phase 1: Meta-Plan

Nefario selected four specialists based on the specific expertise gaps: ux-strategy-minion for information architecture at the decision point, ai-modeling-minion for prompt engineering and data flow across the AGENT.md/SKILL.md pipeline, lucy for intent alignment (are enriched gates consistent with the stated gate philosophy?), and software-docs-minion for documentation coherence across the four affected artifacts.

Security, testing, and observability were excluded from planning — this is a prompt engineering change with no executable code, no attack surface, and no runtime components.

### Phase 2: Specialist Planning

**ux-strategy-minion** provided the UX framework: a Decisions Brief section with 0-4 entries using a compressed Chosen/Over/Why format. Key insight: the gate serves two reading modes — scanning (10-20 seconds, most approvals) and rationale (60-120 seconds, contested plans). The DECISIONS section is skippable for scanners and self-contained for rationale readers. Proposed absorbing RISKS and CONFLICTS into the section for budget neutrality.

**ai-modeling-minion** traced the full data pipeline and identified three gaps: (1) inline summary template lacks a Decisions field, so decisions are lost at compaction, (2) synthesis output lacks a Key Design Decisions table, so the calling session has no structured decision data, (3) compaction focus strings don't mention decisions, so the compactor has no signal to preserve them. Total context budget impact: ~270-590 tokens.

**lucy** reframed the problem as a consistency gap, not intent drift. Mid-execution gates already have RATIONALE + rejected alternatives + Confidence. The Execution Plan gate does not. The spec's own "Intuitive, Simple & Consistent" principle demands convergence. Recommended updating the "optimized for anomaly detection" phrasing in SKILL.md.

**software-docs-minion** mapped the documentation impact: four artifacts affected (SKILL.md, AGENT.md, TEMPLATE.md, orchestration.md). Identified the root cause as synthesis output lacking structured per-task gate rationale. Flagged the report redundancy risk: if gates show decisions, the report's Decisions section could become a copy.

### Phase 3: Synthesis

Skipped (advisory-only orchestration for Phases 3.5-8).

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
<summary>Agent Contributions (4 planning)</summary>

### Planning

**ux-strategy-minion**: Gate interaction design — Decisions Brief section with Chosen/Over/Why format, 4-entry cap, two reading modes (scanning + rationale), absorb RISKS/CONFLICTS.
- Adopted: Decisions Brief format, absorption of RISKS/CONFLICTS, line budget 25-50
- Risks flagged: Decision inflation if triage criteria are vague; gate bloat if cap is treated as target

**ai-modeling-minion**: Data flow analysis — inline summary Decisions field, synthesis Key Design Decisions table, compaction focus string updates, token budget impact ~270-590.
- Adopted: All four pipeline changes (inline summary, synthesis output, compaction strings, gate rendering)
- Risks flagged: Compaction not guaranteed to preserve decisions; specialist adoption of new Decisions field

**lucy**: Intent alignment — confirmed this is a consistency gap, not intent drift. Mid-execution gates already have the target pattern. Recommended "anomaly detection" phrasing update.
- Adopted: Consistency gap framing, phrasing update recommendation
- Risks flagged: Scope creep if all gate types are changed simultaneously

**software-docs-minion**: Documentation impact — four artifacts affected, report redundancy risk, root cause identification (synthesis lacks structured decision data).
- Adopted: Artifact impact map, TEMPLATE.md Key Design Decisions vs Decisions distinction
- Risks flagged: Report Decisions section becoming redundant copy of gate decisions

</details>

## Team Recommendation

**Add a structured DECISIONS section (Chosen/Over/Why, max 4 entries) to the Execution Plan Approval Gate, absorbing RISKS and CONFLICTS RESOLVED blocks, fed by upstream changes to synthesis output format, inline summaries, and compaction focus strings.**

### Consensus

| Position | Agents | Strength |
|----------|--------|----------|
| Add DECISIONS section to Execution Plan gate | All 4 specialists | Strong — unanimous on the gap and general approach |
| Use Chosen/Over/Why format with 4-entry cap | ux-strategy, ai-modeling, lucy | Strong — converged independently |
| Defer Team gate changes | ux-strategy, ai-modeling, software-docs | Moderate — lucy dissents (would include Team gate) |
| Process narrative stays in report, not gate | All 4 specialists | Strong — unanimous |

### When to Revisit

1. If users report the same opacity problem at the Team Approval Gate after the Execution Plan gate is enriched
2. If compaction routinely drops decision data despite updated focus strings (would need a different persistence mechanism)
3. If the 4-entry cap proves too low for complex multi-domain plans (e.g., consistently hitting cap with 6+ gate-worthy decisions)
4. If the enriched gate format causes approval fatigue (users approving faster, not slower, after the change)

### Strongest Arguments

**For DECISIONS section (adopted)**:

| Argument | Agent |
|----------|-------|
| Mid-execution gates already have RATIONALE+rejected alternatives — this is convergence, not new complexity | lucy |
| The information exists but doesn't reach the gate — this is a rendering fix, not a generation problem | ai-modeling-minion |
| Absorbing RISKS and CONFLICTS makes the change budget-neutral while increasing information density | ux-strategy-minion |
| Rejected alternatives are "the primary anti-rubber-stamping measure" per the spec's own rules | lucy |

**For extending to Team gate (not adopted, but preserved)**:

| Argument | Agent |
|----------|-------|
| "Intuitive, Simple & Consistent" demands all gates follow the same structural pattern | lucy |
| Team composition decisions can have significant downstream impact on plan quality | lucy |

## Session Resources

<details>
<summary>Session resources (1 skills)</summary>

### Skills Invoked

- `/nefario` -- advisory orchestration workflow

Context compaction: 0 events

</details>

## Working Files

<details>
<summary>Working files (13 files)</summary>

Companion directory: [2026-03-17-093419-improve-gate-review-transparency/](./2026-03-17-093419-improve-gate-review-transparency/)

- [Original Prompt](./2026-03-17-093419-improve-gate-review-transparency/prompt.md)

**Outputs**
- [Phase 1: Meta-plan](./2026-03-17-093419-improve-gate-review-transparency/phase1-metaplan.md)
- [Phase 2: ux-strategy-minion](./2026-03-17-093419-improve-gate-review-transparency/phase2-ux-strategy-minion.md)
- [Phase 2: ai-modeling-minion](./2026-03-17-093419-improve-gate-review-transparency/phase2-ai-modeling-minion.md)
- [Phase 2: lucy](./2026-03-17-093419-improve-gate-review-transparency/phase2-lucy.md)
- [Phase 2: software-docs-minion](./2026-03-17-093419-improve-gate-review-transparency/phase2-software-docs-minion.md)
- [Phase 3: Synthesis](./2026-03-17-093419-improve-gate-review-transparency/phase3-synthesis.md)

**Prompts**
- [Phase 1: Meta-plan prompt](./2026-03-17-093419-improve-gate-review-transparency/phase1-metaplan-prompt.md)
- [Phase 2: ux-strategy-minion prompt](./2026-03-17-093419-improve-gate-review-transparency/phase2-ux-strategy-minion-prompt.md)
- [Phase 2: ai-modeling-minion prompt](./2026-03-17-093419-improve-gate-review-transparency/phase2-ai-modeling-minion-prompt.md)
- [Phase 2: lucy prompt](./2026-03-17-093419-improve-gate-review-transparency/phase2-lucy-prompt.md)
- [Phase 2: software-docs-minion prompt](./2026-03-17-093419-improve-gate-review-transparency/phase2-software-docs-minion-prompt.md)
- [Phase 3: Synthesis prompt](./2026-03-17-093419-improve-gate-review-transparency/phase3-synthesis-prompt.md)

</details>
