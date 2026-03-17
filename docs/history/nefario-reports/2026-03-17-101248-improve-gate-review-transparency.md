---
type: nefario-report
version: 3
date: "2026-03-17"
time: "10:12:48"
task: "Improve gate review transparency — surface decision rationale at ALL gate types"
mode: advisory
agents-involved: [nefario, ux-strategy-minion, ai-modeling-minion, lucy, software-docs-minion]
task-count: 0
gate-count: 0
outcome: completed
docs-debt: none
---

# Improve gate review transparency — surface decision rationale at ALL gate types

## Summary

Second advisory run (first was too conservative — only targeted Execution Plan gate). This run evaluates ALL four gate types using real session data from 17+ nefario production sessions. The team recommends a universal Chosen/Over/Why micro-format applied at density proportional to each gate's decision scope. Four artifacts need changes: SKILL.md, AGENT.md, TEMPLATE.md, docs/orchestration.md. This is convergence on the existing mid-execution gate philosophy, not new design.

## Original Prompt

> Look through the documentation format in ../web-resource-ledger/docs/evolution/ and also check the CLAUDE[.local].md files that make that happen. Currently, this project's gate reviews are opaque - they don't really give the user an idea of what the team has discussed and what the user is supposed to decide, so the user will have to check the scratch dir and find out. This format comes way closer, even if in how it's used, it's documentation in hindsight. But I want the team to evaluate how the gates can be improved so that the user has the rationale of the decisions they are supposed to make in front of them and can make a meaningful decision.
>
> (Second run) I sort of disagree. The mid-execution gates aren't great either to base decisions on. Make sure the team looks through web-resource-ledger claude code sessions in ~/.claude to see how the gates are presented and how it's hard without context to use these, even the mid-execution ones.

## Key Design Decisions

#### Chosen/Over/Why as universal micro-format for all gate types

**Rationale**:
- All four specialists independently converge on this three-field pattern
- It mechanically enforces transparency: "it is not possible to write a Chosen/Over/Why entry without stating the rejected alternative" (lucy)
- Already proven in concept by the mid-execution gate spec and WRL decisions.md
- Density scales with scope: Team gets 2-3 entries, Reviewer gets per-member rationales, Exec Plan gets structured decisions

**Alternatives Rejected**:
- Exec Plan gate only (previous advisory): User explicitly overrode — all gates need attention
- Per-gate custom formats: Rejected in favor of consistency; same structure, proportional depth
- Absorbing RISKS into DECISIONS (lucy): Risks are informational, not choices; merging dilutes the format

#### CONFLICTS RESOLVED renamed to DECISIONS

**Rationale**:
- The current label implies adversarial agents and process dysfunction
- Many synthesis decisions are trade-offs or scope choices, not conflicts
- "DECISIONS" is neutral and accurate

**Alternatives Rejected**:
- Keep "CONFLICTS RESOLVED": Misrepresents uncontested trade-offs as conflicts

#### Mid-execution gate: quality guidance, not format redesign

**Rationale**:
- The spec format is structurally sound (RATIONALE + Rejected is already Chosen/Over/Why in bullet form)
- Zero production instances exist — redesigning an untested format is premature
- Add good/bad RATIONALE examples + explicit agent prompt instructions + synthesis "Gate rationale" fallback field

**Alternatives Rejected**:
- Structural APPROACH block replacing RATIONALE (ux-strategy-minion): Premature when the existing format is untested
- No changes at all: Agent prompts don't currently instruct rationale reporting, so even the existing format won't produce good output

#### Planning questions excluded from Team gate

**Rationale**:
- The user's decision is "are the right specialists included?" not "what will nefario ask them?"
- Planning questions add +2 lines/agent (gate grows from 10-16 to 25-30 lines) for implementation detail that doesn't aid composition decisions

**Alternatives Rejected**:
- Show planning questions as sub-lines per agent (ai-modeling-minion): Too verbose, wrong information for the decision at hand

### Conflict Resolutions

Three conflicts resolved during synthesis:

1. **Planning questions at Team gate**: ux-strategy-minion's "exclude" adopted over ai-modeling-minion's "include." Planning questions are implementation detail.

2. **Advisory OVER/WAS lines**: software-docs-minion's "no change" adopted. Advisories are modifications (CHANGE/WHY), not binary choices (Chosen/Over/Why).

3. **RISKS absorption into DECISIONS**: Kept separate. Risks are informational ("could go wrong + mitigation"), not decisions ("chose X over Y").

## Phases

### Phase 1: Meta-Plan

Same 4-specialist team as previous advisory (ux-strategy-minion, ai-modeling-minion, lucy, software-docs-minion), approved without re-gating per user directive. An additional research step extracted real gate presentations from 3 nefario production sessions — these showed Team gates as roster-only, Execution Plan conflicts as one-liners, Reviewer gates as thin rosters, and zero mid-execution gate instances.

### Phase 2: Specialist Planning

All four specialists received the real gate examples as context, along with explicit reframing that ALL gate types need improvement (not just Execution Plan).

**ux-strategy-minion**: Proposed universal Chosen/Over/Why micro-format. Team: NOT SELECTED (notable) block. Reviewer: per-member exclusion rationales. Exec Plan: rename CONFLICTS→DECISIONS. Mid-execution: structured APPROACH block. Strongest insight: the self-containment test ("decidable without clicking Details").

**ai-modeling-minion**: Traced data flow pipeline and identified where rationale is lost per gate type. Team: meta-plan has the data, gate doesn't render it. Exec Plan: synthesis allows free-text conflicts, no structure. Mid-execution: agent prompts don't ask for rationale. Confirmed compaction survival — no checkpoint changes needed.

**lucy**: Reframed as convergence on existing philosophy. The mid-execution gate spec IS the target pattern — the other three gates just don't implement it. Recommended examples-first for mid-execution gate (don't redesign untested format). Strongest insight: Chosen/Over/Why is an enforcement mechanism.

**software-docs-minion**: Mapped 4-artifact impact. Chose/Over/Why is a simplification (shared micro-format) with two exceptions: advisories (modifications, not choices) and mandatory reviewers (unconditional, not decisions). TEMPLATE.md needs broadening to capture all gate types.

### Phase 3: Synthesis

Strong consensus across all specialists. Three conflicts resolved (planning questions, advisory format, RISKS absorption). Before/after examples produced for all four gate types. Implementation path: 4 tasks (one per artifact), AGENT.md before SKILL.md (upstream before rendering).

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

**ux-strategy-minion**: Universal Chosen/Over/Why micro-format. Self-containment test as quality bar. Line budgets: Team 10-16, Reviewer 7-13, Exec Plan 35-55, Mid-execution 12-18.
- Adopted: Chosen/Over/Why format, NOT SELECTED (notable), CONFLICTS→DECISIONS rename, self-containment test
- Risks flagged: Gate bloat if all gates grow simultaneously; decision fatigue if every exclusion becomes a decision

**ai-modeling-minion**: Data flow pipeline analysis across all 4 gates. Identified exactly where rationale is lost per gate type. Compaction survival confirmed.
- Adopted: Data flow fixes (meta-plan rendering, structured conflicts, agent prompt instructions, Gate rationale fallback field)
- Risks flagged: Mid-execution is highest effort (3 touch points); agent prompt compliance uncertain

**lucy**: Convergence framing. Philosophy is correct, implementation is under-scoped. Chosen/Over/Why as enforcement mechanism. Examples-first for mid-execution.
- Adopted: Convergence approach, examples-first for mid-execution, AGENT.md consistency anchor
- Risks flagged: Over-engineering if uniform density forced on lightweight gates

**software-docs-minion**: 4-artifact impact map. Shared micro-format with exceptions (advisories, mandatory reviewers). TEMPLATE.md broadening. orchestration.md gate philosophy preamble.
- Adopted: Artifact impact analysis, exception rules, TEMPLATE.md broadening strategy
- Risks flagged: Report bloat for simple orchestrations; TEMPLATE.md version bump ripple effect

</details>

## Team Recommendation

**Adopt Chosen/Over/Why as a universal decision micro-format across all four gate types, with density proportional to each gate's decision scope. The changes are convergence on an existing philosophy, not new design.**

### Consensus

| Position | Agents | Strength |
|----------|--------|----------|
| Chosen/Over/Why micro-format for all gates | All 4 | Strong — independent convergence |
| Density proportional to decision scope | All 4 | Strong — unanimous |
| Rename CONFLICTS RESOLVED to DECISIONS | All 4 | Strong — unanimous |
| Mid-execution: examples + agent instructions, not format redesign | lucy, ai-modeling, software-docs | Strong — 3 of 4 |
| Planning questions excluded from Team gate | ux-strategy, lucy, software-docs | Moderate — ai-modeling dissents |
| RISKS stays separate from DECISIONS | ux-strategy, ai-modeling, software-docs | Moderate — lucy dissents |

### When to Revisit

1. If the first production session with enriched gates shows that agents produce shallow RATIONALE at mid-execution gates despite examples and instructions
2. If Team gate "NOT SELECTED (notable)" entries consistently surprise users (meta-plan excerpting quality is poor)
3. If Execution Plan gate DECISIONS section regularly hits the 5-entry cap, suggesting the cap is too low
4. If users report scanning fatigue at the enriched Execution Plan gate (45 lines may exceed one terminal screen)

### Strongest Arguments

**For universal Chosen/Over/Why (adopted)**:

| Argument | Agent |
|----------|-------|
| Mechanically enforces transparency — cannot write a C/O/W entry without stating the rejected alternative | lucy |
| Gates currently present conclusions without reasoning; the format fixes this structurally | ux-strategy-minion |
| Data already exists at each pipeline stage; the problem is rendering, not generation | ai-modeling-minion |
| Shared micro-format simplifies the spec (one pattern, not four) | software-docs-minion |

**For mid-execution format redesign (not adopted, but preserved)**:

| Argument | Agent |
|----------|-------|
| Structured APPROACH block with labeled fields is more scannable than bullet-list RATIONALE | ux-strategy-minion |
| The existing format's bullet syntax is less visually consistent with the new Chosen/Over/Why at other gates | ux-strategy-minion |

## Session Resources

<details>
<summary>Session resources (1 skills)</summary>

### Skills Invoked

- `/nefario` -- advisory orchestration workflow

Context compaction: 0 events

</details>

## Working Files

<details>
<summary>Working files (12 files)</summary>

Companion directory: [2026-03-17-101248-improve-gate-review-transparency/](./2026-03-17-101248-improve-gate-review-transparency/)

- [Original Prompt](./2026-03-17-101248-improve-gate-review-transparency/prompt.md)

**Outputs**
- [Phase 1: Meta-plan](./2026-03-17-101248-improve-gate-review-transparency/phase1-metaplan.md)
- [Phase 2: ux-strategy-minion](./2026-03-17-101248-improve-gate-review-transparency/phase2-ux-strategy-minion.md)
- [Phase 2: ai-modeling-minion](./2026-03-17-101248-improve-gate-review-transparency/phase2-ai-modeling-minion.md)
- [Phase 2: lucy](./2026-03-17-101248-improve-gate-review-transparency/phase2-lucy.md)
- [Phase 2: software-docs-minion](./2026-03-17-101248-improve-gate-review-transparency/phase2-software-docs-minion.md)
- [Phase 3: Synthesis](./2026-03-17-101248-improve-gate-review-transparency/phase3-synthesis.md)
- [Gate examples (auto-skipped sessions)](./2026-03-17-101248-improve-gate-review-transparency/gate-examples.md)
- [Gate interactions (real user sessions)](./2026-03-17-101248-improve-gate-review-transparency/gate-interactions.md)

**Prompts**
- [Phase 2: ux-strategy-minion prompt](./2026-03-17-101248-improve-gate-review-transparency/phase2-ux-strategy-minion-prompt.md)
- [Phase 2: ai-modeling-minion prompt](./2026-03-17-101248-improve-gate-review-transparency/phase2-ai-modeling-minion-prompt.md)
- [Phase 2: lucy prompt](./2026-03-17-101248-improve-gate-review-transparency/phase2-lucy-prompt.md)
- [Phase 2: software-docs-minion prompt](./2026-03-17-101248-improve-gate-review-transparency/phase2-software-docs-minion-prompt.md)

</details>
