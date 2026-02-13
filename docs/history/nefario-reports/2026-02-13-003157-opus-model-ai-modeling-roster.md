---
type: nefario-report
version: 3
date: "2026-02-13"
time: "00:31:57"
task: "Fix structural serverless bias in agent system"
source-issue: 91
mode: full
agents-involved: [ai-modeling-minion, devx-minion, edge-minion, lucy, margo, ux-strategy-minion, user-docs-minion, test-minion, security-minion, software-docs-minion, code-review-minion]
skills-used: [despicable-lab]
task-count: 7
gate-count: 2
outcome: completed
---

# Fix structural serverless bias in agent system

## Summary

Addressed three structural gaps in the agent system identified in issue #91: iac-minion had zero serverless knowledge, margo's complexity budget penalized novelty without accounting for operational burden, and the delegation table had no serverless routing. Four coordinated spec changes to the-plan.md, one CLAUDE.md deployment template, documentation updates, and agent rebuilds via /despicable-lab produce a topology-neutral system where serverless, container, and self-managed deployments are evaluated on workload criteria rather than encoded preferences.

## Original Prompt

> #91 use opus for all agents, make ai-modeling part of the roster

## Key Design Decisions

#### Topology Neutrality Over "Serverless Default"

**Rationale**:
- Issue #91's solution section proposed "Serverless is the default for greenfield" as a Principles line for iac-minion
- This conflicts with the issue's own "What NOT to do" section: "Do NOT hardcode 'serverless-first'"
- Resolved in favor of neutrality: iac-minion evaluates workload criteria and recommends based on fit, not topology preference

**Alternatives Rejected**:
- "Serverless-first with escalation path": creates opposite bias, contradicts issue's own constraints

#### Two-Column Budget Over Multi-Dimension Scoring

**Rationale**:
- margo's complexity budget needed to distinguish operational burden from build-time novelty
- Two-column model (self-managed vs managed) adds one dimension to existing four-row budget
- Follows KISS: same conceptual structure, minimal additional complexity

**Alternatives Rejected**:
- ai-modeling-minion's two-dimension model with lifetime weight multipliers: over-engineered for a heuristic budget

#### Task-Type Naming for Delegation Table

**Rationale**:
- Existing table uses task-type descriptions ("Infrastructure provisioning", "CI/CD pipelines")
- New rows use same convention: "Deployment strategy selection" and "Platform deployment configuration"
- Prevents pre-classifying work by solution before the strategy decision happens

**Alternatives Rejected**:
- "Serverless platform configuration": solution-category naming breaks table convention

### Conflict Resolutions

1. **Delegation table naming**: devx-minion wins over edge-minion -- task-type descriptions, not solution-category descriptions
2. **Nefario regeneration**: lucy wins -- include as rebuild target (data-staleness, not spec change) because stale delegation table makes the routing fix dead on arrival
3. **Complexity budget model**: margo's two-column wins over ai-modeling's two-dimension -- simpler, stays closer to existing format. Three concepts adopted from ai-modeling: shared vocabulary, operational-burden-is-continuous framing, explicit selection reasoning requirement

## Phases

### Phase 1: Meta-Plan

Nefario analyzed issue #91 and identified five planning specialists: ai-modeling-minion (system prompt design for deployment strategy), devx-minion (developer experience, CLAUDE.md template), edge-minion (boundary clarification), lucy (governance alignment), and margo (simplicity enforcement). Team was adjusted per user request: iac-minion removed (subject of the changes, not a planner), software-docs-minion removed, lucy and margo added as planning consultants. Phase 1 was re-run to generate planning questions for the adjusted team.

### Phase 2: Specialist Planning

Five specialists contributed in parallel. ai-modeling-minion proposed a two-dimension complexity model and shared vocabulary. devx-minion focused on CLAUDE.md template ergonomics and delegation table naming conventions. edge-minion provided boundary clarification for full-stack serverless platforms. lucy flagged nefario's stale delegation table as a critical gap. margo recommended the simpler two-column budget model. Second-round planning was not needed.

### Phase 3: Synthesis

Nefario consolidated into a 7-task execution plan across 4 batches with 2 approval gates. Three conflicts were resolved (see above). The plan correctly separated spec changes (Batch 1) from dependent work (delegation table, docs, rebuilds). External skill /despicable-lab was classified as ORCHESTRATION with a DEFERRED task.

### Phase 3.5: Architecture Review

Six reviewers (5 mandatory + 1 discretionary user-docs-minion) reviewed the plan. No BLOCKs. Five ADVISE verdicts incorporated: lucy flagged spec-version 2.0 for iac-minion (remit expansion = major version) and Task 6 reassignment to software-docs-minion; margo trimmed proportionality heuristic from 5 signals to 2-3; ux-strategy collapsed four HTML comment categories to one; user-docs moved "when to omit" guidance to top of template; test-minion added measurable neutrality criteria. Security-minion APPROVEd with no concerns.

### Phase 4: Execution

Batch 1 (parallel): Tasks 1-3 (spec updates) and Task 5 (template) completed. Both approval gates presented and approved. Batch 2: Task 4 (delegation table) completed. Batch 3: Task 6 (docs staleness, reassigned to software-docs-minion) completed. Batch 4: Task 7 (/despicable-lab rebuild) rebuilt iac-minion, margo, edge-minion, and updated nefario's delegation table.

### Phase 5: Code Review

Three reviewers (code-review-minion, lucy, margo) in parallel. All ADVISE. One critical finding from both code-review-minion and lucy: devx-minion was missing from "Deployment strategy selection" supporting column in both the-plan.md and nefario/AGENT.md. Auto-fixed. margo noted iac-minion's 10-dimension evaluation checklist and margo's definitional prose are slightly over-specified but not blocking.

### Phase 6: Test Execution

Skipped (no test infrastructure for spec/documentation files).

### Phase 7: Deployment

Skipped (not requested).

### Phase 8: Documentation

Skipped (documentation needs already covered by Tasks 5 and 6).

<details>
<summary>Agent Contributions (5 planning, 6 review, 3 code review)</summary>

### Planning

**ai-modeling-minion**: Proposed two-dimension complexity model and shared vocabulary for deployment topology.
- Adopted: shared vocabulary (self-managed, managed, serverless), explicit selection reasoning requirement, operational-burden-is-continuous framing
- Risks flagged: over-correction toward serverless, hybrid cases not being binary

**devx-minion**: Focused on CLAUDE.md template ergonomics and delegation table naming conventions.
- Adopted: task-type naming for delegation rows, template as optional prose section
- Risks flagged: template bias toward one topology through example ordering

**edge-minion**: Boundary clarification for full-stack serverless platforms.
- Adopted: clear split between edge-layer behavior (edge-minion) and deployment configuration (iac-minion)
- Risks flagged: wrangler.toml shared ownership ambiguity

**lucy**: Flagged nefario's stale delegation table and versioning conventions.
- Adopted: nefario rebuild target, spec-version 2.0 for iac-minion, Task 6 reassignment
- Risks flagged: nefario routing from stale table (R3)

**margo**: Recommended simpler two-column budget model over multi-dimension scoring.
- Adopted: two-column model, infrastructure proportionality heuristic with 2-3 examples
- Risks flagged: over-specified heuristics calcifying into checklists

### Architecture Review

**security-minion**: APPROVE. No concerns.

**test-minion**: ADVISE. Added measurable neutrality criteria for verification (term frequency balance, scoring invariants, boundary symmetry).

**ux-strategy-minion**: ADVISE. Collapsed four HTML comment categories to one, recommended minimal example, user-facing language for default behavior explanation.

**lucy**: ADVISE. Flagged spec-version 2.0 for iac-minion, Task 6 reassignment from lucy to software-docs-minion, deviation from issue's "serverless default" language.

**margo**: ADVISE. Trimmed proportionality heuristic from 5 to 2-3 examples, added spec/AGENT.md boundary constraint for Task 2.

**user-docs-minion**: ADVISE. Moved "when to omit" guidance to top, added discoverability links, recommended hybrid example.

### Code Review

**code-review-minion**: ADVISE. Found devx-minion missing from delegation table supporting column (auto-fixed). Confirmed topology neutrality achieved.

**lucy**: ADVISE. Same delegation table finding. Confirmed spec-version 2.0 correct per convention. No intent drift.

**margo**: ADVISE. iac-minion's 10-dimension checklist slightly over-specified but proportional to the spec change. Template is a net simplicity win.

</details>

## Execution

### Tasks

| # | Task | Agent | Status |
|---|------|-------|--------|
| 1 | Update iac-minion spec in the-plan.md | ai-modeling-minion | completed |
| 2 | Update margo spec in the-plan.md | ai-modeling-minion | completed |
| 3 | Update edge-minion spec in the-plan.md | ai-modeling-minion | completed |
| 4 | Update delegation table in the-plan.md | ai-modeling-minion | completed |
| 5 | Create CLAUDE.md deployment template | devx-minion | completed |
| 6 | Check and update docs for staleness | software-docs-minion | completed |
| 7 | Rebuild affected agents via /despicable-lab | DEFERRED (despicable-lab) | completed |

### Files Changed

| File | Action | Description |
|------|--------|-------------|
| [the-plan.md](../../../the-plan.md) | modified | iac-minion spec v2.0, margo spec v1.1, edge-minion spec v1.1, +2 delegation table rows |
| [docs/claudemd-template.md](../../../docs/claudemd-template.md) | created | CLAUDE.md deployment template with balanced examples |
| [docs/agent-catalog.md](../../../docs/agent-catalog.md) | modified | Updated iac-minion, margo, edge-minion descriptions |
| [docs/architecture.md](../../../docs/architecture.md) | modified | Added claudemd-template.md link |
| [minions/iac-minion/AGENT.md](../../../minions/iac-minion/AGENT.md) | modified | Rebuilt v2.0: serverless platforms, Step 0 deployment strategy |
| [minions/iac-minion/RESEARCH.md](../../../minions/iac-minion/RESEARCH.md) | modified | Added serverless research (+174 lines) |
| [margo/AGENT.md](../../../margo/AGENT.md) | modified | Rebuilt v1.1: two-column budget, infrastructure proportionality |
| [margo/RESEARCH.md](../../../margo/RESEARCH.md) | modified | Added operational complexity research (+152 lines) |
| [minions/edge-minion/AGENT.md](../../../minions/edge-minion/AGENT.md) | modified | Rebuilt v1.1: boundary clarification |
| [minions/edge-minion/RESEARCH.md](../../../minions/edge-minion/RESEARCH.md) | modified | Added boundary clarification research (+20 lines) |
| [nefario/AGENT.md](../../../nefario/AGENT.md) | modified | Added 2 delegation table rows |

### Approval Gates

| Gate Title | Agent | Confidence | Outcome | Rounds |
|------------|-------|------------|---------|--------|
| iac-minion spec update | ai-modeling-minion | HIGH | approved | 1 |
| margo spec update | ai-modeling-minion | HIGH | approved | 1 |

## Decisions

#### iac-minion Spec Update (Gate 1)

**Decision**: Expand iac-minion remit to include serverless platforms and deployment strategy selection. Bump spec-version to 2.0.
**Rationale**: Remit expansion adds serverless as a peer technology without removing existing Docker/Terraform content. Research Focus covers both "when serverless wins" and "when it's wrong". Boundary with edge-minion uses symmetric terms.
**Rejected**: Issue #91's "Serverless is the default for greenfield" Principles line -- conflicts with issue's own constraints.
**Confidence**: HIGH
**Outcome**: approved

#### margo Spec Update (Gate 2)

**Decision**: Expand margo's complexity assessment to include operational burden. Add infrastructure proportionality to research focus. Keep spec compact; AGENT.md design intent flows through build pipeline.
**Rationale**: Surgical spec change (1 bullet expansion + 3 research topics) seeds the build pipeline to produce two-column budget and proportionality heuristic in the AGENT.md.
**Rejected**: Inserting full two-column table and framing rules as literal spec text -- over-engineers the spec, blurs spec/AGENT.md boundary.
**Confidence**: HIGH
**Outcome**: approved

## Verification

| Phase | Result |
|-------|--------|
| Code Review | 3 ADVISE, 0 BLOCK. 1 finding auto-fixed (devx-minion missing from delegation table). |
| Test Execution | Skipped (no test infrastructure for spec/documentation files) |
| Deployment | Skipped (not requested) |
| Documentation | Skipped (covered by Tasks 5 and 6) |

<details>
<summary>Session Resources (2 skills)</summary>

### External Skills

| Skill | Classification | Recommendation | Tasks Used |
|-------|---------------|----------------|------------|
| /despicable-lab | ORCHESTRATION | Agent rebuild pipeline for spec-bumped agents | Task 7 |

### Skills Invoked

- `/nefario` -- orchestration workflow
- `/despicable-lab` -- agent rebuild pipeline (Task 7: iac-minion, margo, edge-minion, nefario)

Context compaction: 2 events

</details>

<details>
<summary>Working files (41 files)</summary>

Companion directory: [2026-02-13-003157-opus-model-ai-modeling-roster/](./2026-02-13-003157-opus-model-ai-modeling-roster/)

- [Original Prompt](./2026-02-13-003157-opus-model-ai-modeling-roster/prompt.md)

**Outputs**
- [Phase 1: Meta-plan](./2026-02-13-003157-opus-model-ai-modeling-roster/phase1-metaplan.md)
- [Phase 1: Meta-plan re-run](./2026-02-13-003157-opus-model-ai-modeling-roster/phase1-metaplan-rerun.md)
- [Phase 2: ai-modeling-minion](./2026-02-13-003157-opus-model-ai-modeling-roster/phase2-ai-modeling-minion.md)
- [Phase 2: devx-minion](./2026-02-13-003157-opus-model-ai-modeling-roster/phase2-devx-minion.md)
- [Phase 2: edge-minion](./2026-02-13-003157-opus-model-ai-modeling-roster/phase2-edge-minion.md)
- [Phase 2: lucy](./2026-02-13-003157-opus-model-ai-modeling-roster/phase2-lucy.md)
- [Phase 2: margo](./2026-02-13-003157-opus-model-ai-modeling-roster/phase2-margo.md)
- [Phase 3: Synthesis](./2026-02-13-003157-opus-model-ai-modeling-roster/phase3-synthesis.md)
- [Phase 3.5: lucy](./2026-02-13-003157-opus-model-ai-modeling-roster/phase3.5-lucy.md)
- [Phase 3.5: margo](./2026-02-13-003157-opus-model-ai-modeling-roster/phase3.5-margo.md)
- [Phase 3.5: test-minion](./2026-02-13-003157-opus-model-ai-modeling-roster/phase3.5-test-minion.md)
- [Phase 3.5: user-docs-minion](./2026-02-13-003157-opus-model-ai-modeling-roster/phase3.5-user-docs-minion.md)
- [Phase 3.5: ux-strategy-minion](./2026-02-13-003157-opus-model-ai-modeling-roster/phase3.5-ux-strategy-minion.md)
- [Phase 5: code-review-minion](./2026-02-13-003157-opus-model-ai-modeling-roster/phase5-code-review-minion.md)
- [Phase 5: lucy](./2026-02-13-003157-opus-model-ai-modeling-roster/phase5-lucy.md)
- [Phase 5: margo](./2026-02-13-003157-opus-model-ai-modeling-roster/phase5-margo.md)
- [Phase 8: Checklist](./2026-02-13-003157-opus-model-ai-modeling-roster/phase8-checklist.md)

**Prompts**
- [Phase 1: Meta-plan prompt](./2026-02-13-003157-opus-model-ai-modeling-roster/phase1-metaplan-prompt.md)
- [Phase 1: Meta-plan re-run prompt](./2026-02-13-003157-opus-model-ai-modeling-roster/phase1-metaplan-rerun-prompt.md)
- [Phase 2: ai-modeling-minion prompt](./2026-02-13-003157-opus-model-ai-modeling-roster/phase2-ai-modeling-minion-prompt.md)
- [Phase 2: devx-minion prompt](./2026-02-13-003157-opus-model-ai-modeling-roster/phase2-devx-minion-prompt.md)
- [Phase 2: edge-minion prompt](./2026-02-13-003157-opus-model-ai-modeling-roster/phase2-edge-minion-prompt.md)
- [Phase 2: lucy prompt](./2026-02-13-003157-opus-model-ai-modeling-roster/phase2-lucy-prompt.md)
- [Phase 2: margo prompt](./2026-02-13-003157-opus-model-ai-modeling-roster/phase2-margo-prompt.md)
- [Phase 3: Synthesis prompt](./2026-02-13-003157-opus-model-ai-modeling-roster/phase3-synthesis-prompt.md)
- [Phase 3.5: lucy prompt](./2026-02-13-003157-opus-model-ai-modeling-roster/phase3.5-lucy-prompt.md)
- [Phase 3.5: margo prompt](./2026-02-13-003157-opus-model-ai-modeling-roster/phase3.5-margo-prompt.md)
- [Phase 3.5: test-minion prompt](./2026-02-13-003157-opus-model-ai-modeling-roster/phase3.5-test-minion-prompt.md)
- [Phase 3.5: user-docs-minion prompt](./2026-02-13-003157-opus-model-ai-modeling-roster/phase3.5-user-docs-minion-prompt.md)
- [Phase 3.5: ux-strategy-minion prompt](./2026-02-13-003157-opus-model-ai-modeling-roster/phase3.5-ux-strategy-minion-prompt.md)
- [Phase 4: ai-modeling-task1 prompt](./2026-02-13-003157-opus-model-ai-modeling-roster/phase4-ai-modeling-task1-prompt.md)
- [Phase 4: ai-modeling-task2 prompt](./2026-02-13-003157-opus-model-ai-modeling-roster/phase4-ai-modeling-task2-prompt.md)
- [Phase 4: ai-modeling-task3 prompt](./2026-02-13-003157-opus-model-ai-modeling-roster/phase4-ai-modeling-task3-prompt.md)
- [Phase 4: devx-task5 prompt](./2026-02-13-003157-opus-model-ai-modeling-roster/phase4-devx-task5-prompt.md)
- [Phase 4: softwaredocs-task6 prompt](./2026-02-13-003157-opus-model-ai-modeling-roster/phase4-softwaredocs-task6-prompt.md)
- [Phase 5: code-review-minion prompt](./2026-02-13-003157-opus-model-ai-modeling-roster/phase5-code-review-minion-prompt.md)
- [Phase 5: lucy prompt](./2026-02-13-003157-opus-model-ai-modeling-roster/phase5-lucy-prompt.md)
- [Phase 5: margo prompt](./2026-02-13-003157-opus-model-ai-modeling-roster/phase5-margo-prompt.md)

</details>
