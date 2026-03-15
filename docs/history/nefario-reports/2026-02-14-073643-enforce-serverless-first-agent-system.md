---
type: nefario-report
version: 3
date: "2026-02-14"
time: "07:36:43"
task: "Enforce serverless-first stance across agent system"
mode: full
agents-involved: [iac-minion, margo, lucy, edge-minion, security-minion, test-minion, ux-strategy-minion, code-review-minion, nefario]
skills-used: [despicable-lab]
task-count: 7
gate-count: 1
outcome: completed
---

# Enforce serverless-first stance across agent system

## Summary

Shifted the agent system from topology-neutral deployment evaluation to a serverless-first default. iac-minion's Step 0 now starts with a blocking concern gate (5 concerns), margo's complexity budget actively penalizes self-managed infrastructure when serverless alternatives exist, the CLAUDE.md template encodes serverless as the omission default, and lucy enforces serverless-first compliance in plan reviews. This is an incremental pass on top of PR #123, which established the structural foundation but produced topology-neutral framing instead of the intended serverless-first stance.

## Original Prompt

> Enforce serverless-first stance across agent system
>
> **Outcome**: The agent system actively prefers serverless for all deployments unless specific blocking concerns exist (persistent connections, long-running processes, compliance-mandated infrastructure control, cost optimization at scale). This is not a suggestion or one option among equals -- it's the default, rooted in the Helix Manifesto's "lean and mean" and "ops reliability wins" principles. The first question is always "can this be done serverless without blocking concerns?" If yes, serverless. If no, document why not.
>
> **Success criteria**:
> - iac-minion's Step 0 starts with "serverless unless blocked" -- not a neutral evaluation of equal options
> - margo's complexity budget actively penalizes self-managed infrastructure when a serverless alternative exists without blocking concerns
> - CLAUDE.md template encodes serverless-first as the strong default, not an optional suggestion
> - The framing is "why NOT serverless?" (justify deviation), not "which topology fits?" (neutral evaluation)
> - Agents remain usable for non-serverless work -- the preference is strong, not a hard block
>
> **Constraints**:
> - Incremental pass on branch nefario/fix-serverless-bias, on top of PR #123
> - The Helix Manifesto is the philosophical anchor: serverless = lean and mean, linear scalability, ops reliability
> - "Don't hardcode serverless-first" (from issue #91's What NOT to do) was about not making agents unusable for non-serverless cases -- it was NOT about avoiding a strong preference

## Key Design Decisions

#### Edge-first sub-preference within serverless

**Rationale**:
- Edge platforms (Cloudflare Workers, Vercel Edge, Fastly Compute) align with the Helix Manifesto latency principle ("<300ms fast. Always.")
- Near-zero cold starts and global distribution make edge serverless the ideal default within serverless

**Alternatives Rejected**:
- Mandatory edge-first evaluation tier: rejected because it adds decision complexity (a second mandatory gate between "serverless" and "which serverless") that margo would flag as over-engineering

#### 5th blocking concern: execution environment constraints

**Rationale**:
- Native binaries and CPU/memory limits beyond platform maximums are genuinely distinct from the existing four blocking concerns
- These represent hard platform capability gaps, not workload characteristics

**Alternatives Rejected**:
- Including storage access patterns: rejected because storage is a data architecture decision (data-minion's domain), not a compute topology decision
- Including cold start latency: rejected because it's addressable via edge platforms or provisioned concurrency, not a blocking concern

#### Decision 31 for policy supersession

**Rationale**:
- The 2026-02-13 advisory (PR #123) explicitly chose topology-neutral framing
- Without a Decision 31 entry, future reviewers would find contradictory guidance with no record of evolution

**Alternatives Rejected**:
- Silently superseding PR #123 without documentation: rejected because it breaks the governance audit trail

### Conflict Resolutions

1. **Edge-minion's mandatory edge-first tier vs. margo's simplicity principle**: Edge-minion proposed a mandatory edge-first evaluation step. Resolved as a recommendation within iac-minion's Step 0 ("prefer edge platforms when latency sensitivity is high"), not a mandatory gate.

2. **Edge-minion's 3 new blocking concerns vs. iac-minion's 4**: One of edge-minion's three (execution environment constraints) was genuinely distinct and included. Cold start latency is addressed by the edge recommendation. Storage access patterns are data-minion's domain.

## Phases

### Phase 1: Meta-Plan

Nefario analyzed the task and identified 6 initial specialists. After user review, the team was adjusted to 4: iac-minion (core Step 0 restructure), margo (complexity budget enforcement), lucy (governance and documentation), and edge-minion (edge-first sub-preference within serverless). Three specialists were dropped (ux-strategy-minion, software-docs-minion, test-minion) because the changes are agent behavioral text, not user-facing interfaces or executable code.

### Phase 2: Specialist Planning

Four specialists contributed in parallel. iac-minion proposed restructuring Step 0 with a two-tier checklist (blocking concern gate first, then validation dimensions). Margo proposed three surgical changes to the complexity budget and framing rules. Lucy recommended rewriting the CLAUDE.md template, adding Decision 31, and creating a governance compliance check. Edge-minion proposed a 5th blocking concern (execution environment constraints), an edge-first sub-preference within serverless, and a sequential escape cascade.

### Phase 3: Synthesis

Specialist input was merged into a 7-task execution plan with 1 approval gate on the-plan.md changes. Three design decisions were resolved: edge-first as recommendation (not mandatory tier), Decision 31 for policy supersession, and the 5th blocking concern scoped to exclude storage. The plan organized into 4 execution batches based on dependencies.

### Phase 3.5: Architecture Review

Five mandatory reviewers participated: security-minion (APPROVE -- no attack surface changes), test-minion (APPROVE -- verification steps well-constructed), ux-strategy-minion (ADVISE -- blocking concern list repeated 7+ locations, Task 7 should run check-only), lucy (APPROVE -- intent alignment confirmed, Decision 31 properly documented), margo (ADVISE -- Task 7 redundant with Task 2, 7 tasks over-engineered for the change).

### Phase 4: Execution

Batch 1 ran Tasks 1, 4, 5 in parallel. Task 1 (the-plan.md) completed and passed the approval gate with surgical changes to iac-minion and margo specs. Tasks 4 (CLAUDE.md template) and 5 (Decision 31) completed concurrently. After gate approval, Batch 2 ran Tasks 2, 3, and 6 in parallel -- iac-minion AGENT.md/RESEARCH.md rewrite, margo AGENT.md updates, and lucy AGENT.md compliance check. Task 7 was simplified to an inline version check (per reviewer advisory) confirming iac-minion x-plan-version 2.1 matches spec-version 2.1.

### Phase 5: Code Review

Three reviewers (code-review-minion, lucy, margo) all returned ADVISE. All three independently flagged the same finding: `docs/claudemd-template.md` listed only 4 of 5 blocking concerns, missing "execution environment constraints." Lucy additionally caught "proven" vs "measured" terminology drift. Both issues were auto-fixed and committed.

### Phase 6: Test Execution

Skipped (no test infrastructure in this repository, no tests produced).

### Phase 7: Deployment

Skipped (not requested).

### Phase 8: Documentation

Skipped (documentation produced as execution deliverables: Tasks 4 and 5).

<details>
<summary>Agent Contributions (4 planning, 5 review)</summary>

### Planning

**iac-minion**: Proposed restructuring Step 0 with a two-tier checklist: Tier 1 blocking concern gate (5 concerns) checked first, Tier 2 validation dimensions for refinement only. Topology cascade with documented escalation.
- Adopted: Full Step 0 restructure, identity line change, blocking concern gate format
- Risks flagged: Over-rotation to serverless dogma if escape hatches are not prominent

**margo**: Proposed three surgical changes to complexity budget and framing rules. Burden-of-proof paragraph, framing rule #1 amendment (self-managed = disproportion signal), framing rule #3 refinement (escalation to gru).
- Adopted: All three changes plus new checklist step
- Risks flagged: none

**lucy**: Proposed CLAUDE.md template rewrite (omission = serverless default), Decision 31 entry, governance compliance check (ADVISE severity), cross-doc consistency audit.
- Adopted: All recommendations
- Risks flagged: Contradiction with PR #123 advisory requires explicit supersession record

**edge-minion**: Proposed 5th blocking concern (execution environment constraints), edge-first sub-preference within serverless, sequential escape cascade.
- Adopted: 5th blocking concern (scoped to exclude storage), edge-first as recommendation
- Risks flagged: Cold start sensitivity should be mitigated, not blocked

### Architecture Review

**security-minion**: APPROVE. No new attack surface, secrets, or authentication changes. Compliance-mandated infrastructure control escape hatch correctly preserves security-driven deviation.

**test-minion**: APPROVE. Verification steps well-constructed for Markdown-only changes. 10 grep-checkable assertions covering all key semantic shifts.

**ux-strategy-minion**: ADVISE. Blocking concern list repeated 7+ locations with no canonical source (maintenance risk). Task 7 should run check-only to avoid overwriting hand-edits. "Topology-Neutral" heading in margo's BTA creates minor framing contradiction (not in scope).

**lucy**: APPROVE. Intent alignment confirmed. Decision 31 properly documents supersession. Strong-default-not-hard-block framing preserved. Versioning handled correctly.

**margo**: ADVISE. Task 7 redundant with Task 2. 7 tasks with 4 batches disproportionate for a preference change (could be 3 tasks). Task 3 prompt says "three surgical modifications" but lists 5 changes.

### Code Review

**code-review-minion**: ADVISE. `docs/claudemd-template.md` line 17 missing 5th blocking concern. Auto-fixed. All other cross-agent consistency checks pass.

**lucy**: ADVISE. Same claudemd-template.md finding plus "proven" vs "measured" terminology drift. Both auto-fixed. Convention adherence and intent alignment confirmed.

**margo**: ADVISE. Blocking concern list enumerated 7 times across files. Acceptable as behavioral reinforcement. Same claudemd-template.md finding. Pre-change topology-neutral framing retained in RESEARCH.md sections outside the updated subsection.

</details>

## Execution

### Tasks

| # | Task | Agent | Status |
|---|------|-------|--------|
| 1 | Update the-plan.md specs (iac-minion + margo) | iac-minion | completed |
| 2 | Rewrite iac-minion AGENT.md + RESEARCH.md | iac-minion | completed |
| 3 | Update margo AGENT.md (complexity budget + framing rules) | margo | completed |
| 4 | Rewrite CLAUDE.md template (serverless default framing) | lucy | completed |
| 5 | Add Decision 31 to decisions.md | lucy | completed |
| 6 | Update lucy AGENT.md (serverless-first compliance check) | lucy | completed |
| 7 | Verify iac-minion via /despicable-lab --check | inline | completed |

### Files Changed

| File | Action | Description |
|------|--------|-------------|
| [the-plan.md](../../../../the-plan.md) | modified | iac-minion spec: serverless-first identity, Step 0 restructure, research focus. margo spec: new remit bullet. |
| [minions/iac-minion/AGENT.md](../../../../minions/iac-minion/AGENT.md) | modified | Identity line, Step 0 rewrite with blocking concern gate, frontmatter bump to 2.1 |
| [minions/iac-minion/RESEARCH.md](../../../../minions/iac-minion/RESEARCH.md) | modified | Deployment strategy section: neutrality replaced with serverless-first default |
| [margo/AGENT.md](../../../../margo/AGENT.md) | modified | Burden-of-proof paragraph, framing rules #1/#3 amended, new checklist step 7 |
| [lucy/AGENT.md](../../../../lucy/AGENT.md) | modified | Serverless-first compliance check (step 6), CLAUDE.md directives bullet |
| [docs/claudemd-template.md](../../../../docs/claudemd-template.md) | modified | Serverless-default framing: omission = serverless, examples regrouped |
| [docs/decisions.md](../../../../docs/decisions.md) | modified | Decision 31: serverless-first default, supersedes topology-neutral stance |

### Approval Gates

| Gate Title | Agent | Confidence | Outcome | Rounds |
|------------|-------|------------|---------|--------|
| Update the-plan.md specs | iac-minion | HIGH | approved | 1 |

#### Update the-plan.md specs

**Decision**: Shift iac-minion spec from topology-neutral to serverless-first and add burden-of-proof remit to margo spec.
**Rationale**: iac-minion identity shifts from "evaluating serverless vs. container vs. self-managed" to "default to serverless; evaluate deviation only when blocking concerns exist." Research focus now lists 5 blocking concerns. Margo remit adds explicit enforcement.
**Rejected**: Keeping topology-neutral framing (false neutrality, status quo bias toward familiar infrastructure).

## Decisions

#### Update the-plan.md specs (iac-minion + margo)

**Decision**: Encode serverless-first as the default deployment stance in both iac-minion and margo specs within the-plan.md.
**Rationale**: The spec is the source of truth for agent behavior. Changing the identity and Step 0 in the spec ensures all downstream artifacts (AGENT.md, RESEARCH.md) align. Consolidating both spec changes into one gated task reduces gate fatigue.
**Rejected**: Scatter changes across multiple gates (more review overhead for no additional safety).
**Confidence**: HIGH
**Outcome**: approved

## Verification

| Phase | Result |
|-------|--------|
| Code Review | ADVISE: 2 findings auto-fixed (missing 5th blocking concern in CLAUDE.md template, "proven" vs "measured" terminology drift) |
| Test Execution | Skipped (no test infrastructure) |
| Deployment | Skipped (not requested) |
| Documentation | Covered by execution tasks (CLAUDE.md template, Decision 31) |

<details>
<summary>Session resources (2 skills)</summary>

### External Skills

| Skill | Classification | Recommendation | Tasks Used |
|-------|---------------|----------------|------------|
| /despicable-lab | ORCHESTRATION | Version check for iac-minion spec consistency | Task 7 |

### Skills Invoked

- `/nefario` -- orchestration workflow
- `/despicable-lab` -- iac-minion version check (Task 7, simplified to inline check)

Context compaction: 1 event

</details>

<details>
<summary>Working files (37 files)</summary>

Companion directory: [2026-02-14-073643-enforce-serverless-first-agent-system/](./2026-02-14-073643-enforce-serverless-first-agent-system/)

- [Original Prompt](./2026-02-14-073643-enforce-serverless-first-agent-system/prompt.md)

**Outputs**
- [Phase 1: Meta-plan](./2026-02-14-073643-enforce-serverless-first-agent-system/phase1-metaplan.md)
- [Phase 1: Meta-plan (re-run)](./2026-02-14-073643-enforce-serverless-first-agent-system/phase1-metaplan-rerun.md)
- [Phase 2: iac-minion](./2026-02-14-073643-enforce-serverless-first-agent-system/phase2-iac-minion.md)
- [Phase 2: margo](./2026-02-14-073643-enforce-serverless-first-agent-system/phase2-margo.md)
- [Phase 2: lucy](./2026-02-14-073643-enforce-serverless-first-agent-system/phase2-lucy.md)
- [Phase 2: edge-minion](./2026-02-14-073643-enforce-serverless-first-agent-system/phase2-edge-minion.md)
- [Phase 3: Synthesis](./2026-02-14-073643-enforce-serverless-first-agent-system/phase3-synthesis.md)
- [Phase 3.5: security-minion](./2026-02-14-073643-enforce-serverless-first-agent-system/phase3.5-security-minion.md)
- [Phase 3.5: test-minion](./2026-02-14-073643-enforce-serverless-first-agent-system/phase3.5-test-minion.md)
- [Phase 3.5: ux-strategy-minion](./2026-02-14-073643-enforce-serverless-first-agent-system/phase3.5-ux-strategy-minion.md)
- [Phase 3.5: lucy](./2026-02-14-073643-enforce-serverless-first-agent-system/phase3.5-lucy.md)
- [Phase 3.5: margo](./2026-02-14-073643-enforce-serverless-first-agent-system/phase3.5-margo.md)
- [Phase 5: code-review-minion](./2026-02-14-073643-enforce-serverless-first-agent-system/phase5-code-review-minion.md)
- [Phase 5: lucy](./2026-02-14-073643-enforce-serverless-first-agent-system/phase5-lucy.md)
- [Phase 5: margo](./2026-02-14-073643-enforce-serverless-first-agent-system/phase5-margo.md)

**Prompts**
- [Phase 1: Meta-plan prompt](./2026-02-14-073643-enforce-serverless-first-agent-system/phase1-metaplan-prompt.md)
- [Phase 1: Meta-plan re-run prompt](./2026-02-14-073643-enforce-serverless-first-agent-system/phase1-metaplan-rerun-prompt.md)
- [Phase 2: iac-minion prompt](./2026-02-14-073643-enforce-serverless-first-agent-system/phase2-iac-minion-prompt.md)
- [Phase 2: margo prompt](./2026-02-14-073643-enforce-serverless-first-agent-system/phase2-margo-prompt.md)
- [Phase 2: lucy prompt](./2026-02-14-073643-enforce-serverless-first-agent-system/phase2-lucy-prompt.md)
- [Phase 2: edge-minion prompt](./2026-02-14-073643-enforce-serverless-first-agent-system/phase2-edge-minion-prompt.md)
- [Phase 3: Synthesis prompt](./2026-02-14-073643-enforce-serverless-first-agent-system/phase3-synthesis-prompt.md)
- [Phase 3.5: security-minion prompt](./2026-02-14-073643-enforce-serverless-first-agent-system/phase3.5-security-minion-prompt.md)
- [Phase 3.5: test-minion prompt](./2026-02-14-073643-enforce-serverless-first-agent-system/phase3.5-test-minion-prompt.md)
- [Phase 3.5: ux-strategy-minion prompt](./2026-02-14-073643-enforce-serverless-first-agent-system/phase3.5-ux-strategy-minion-prompt.md)
- [Phase 3.5: lucy prompt](./2026-02-14-073643-enforce-serverless-first-agent-system/phase3.5-lucy-prompt.md)
- [Phase 3.5: margo prompt](./2026-02-14-073643-enforce-serverless-first-agent-system/phase3.5-margo-prompt.md)
- [Phase 4: iac-minion Task 1 prompt](./2026-02-14-073643-enforce-serverless-first-agent-system/phase4-iac-minion-task1-prompt.md)
- [Phase 4: iac-minion Task 2 prompt](./2026-02-14-073643-enforce-serverless-first-agent-system/phase4-iac-minion-task2-prompt.md)
- [Phase 4: margo Task 3 prompt](./2026-02-14-073643-enforce-serverless-first-agent-system/phase4-margo-task3-prompt.md)
- [Phase 4: lucy Task 4 prompt](./2026-02-14-073643-enforce-serverless-first-agent-system/phase4-lucy-task4-prompt.md)
- [Phase 4: lucy Task 5 prompt](./2026-02-14-073643-enforce-serverless-first-agent-system/phase4-lucy-task5-prompt.md)
- [Phase 4: lucy Task 6 prompt](./2026-02-14-073643-enforce-serverless-first-agent-system/phase4-lucy-task6-prompt.md)
- [Phase 5: code-review-minion prompt](./2026-02-14-073643-enforce-serverless-first-agent-system/phase5-code-review-minion-prompt.md)
- [Phase 5: lucy prompt](./2026-02-14-073643-enforce-serverless-first-agent-system/phase5-lucy-prompt.md)
- [Phase 5: margo prompt](./2026-02-14-073643-enforce-serverless-first-agent-system/phase5-margo-prompt.md)

</details>
