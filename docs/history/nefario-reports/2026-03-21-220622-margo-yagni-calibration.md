---
type: nefario-report
version: 3
date: "2026-03-21"
time: "22:06:22"
task: "Calibrate margo's YAGNI filter for roadmap-planned items"
source-issue: 151
mode: full
agents-involved: [ai-modeling-minion, software-docs-minion, lucy, margo, security-minion, test-minion, ux-strategy-minion, code-review-minion]
task-count: 4
gate-count: 2
outcome: completed
docs-debt: none
---

# Calibrate margo's YAGNI filter for roadmap-planned items

## Summary

Replaced margo's binary YAGNI justification test with a two-tier evaluation that distinguishes speculative features (no known consumer) from roadmap-planned items (concrete consumer on active roadmap). Speculative items are still excluded; roadmap-planned items with trivially non-breaking cost are accepted. This eliminates false positives like the `duration_ms` incident where a zero-cost field was flagged for deferral despite having a concrete M4 consumer.

## Original Prompt

> Margo: calibrate YAGNI for roadmap-planned items (GitHub issue #151). YAGNI should apply to speculative features with no known consumer, not to items on the active roadmap with concrete planned consumers. The question should be "do we know we'll need it?" not "do we need it today?"

## Key Design Decisions

#### Two-Tier YAGNI Evaluation

**Rationale**:
- YAGNI protects against speculative complexity, not planned delivery
- Binary YAGNI creates false positives for trivially non-breaking roadmap items
- A falsifiable evidence standard (named consumer + active roadmap + consumer-specified usage) prevents "roadmap-planned" from becoming a rubber stamp

**Alternatives Rejected**:
- Keep binary YAGNI: creates pointless churn for trivial additions with known consumers
- Full roadmap exemption: "it's on the roadmap" becomes a universal YAGNI bypass

#### Proportional Cost Scale

**Rationale**:
- Two tiers (trivially non-breaking vs. structurally complex) provide a clear binary boundary
- Default posture remains exclusion — uncertain cases are flagged

**Alternatives Rejected**:
- Three-tier scale with "moderate" tier (margo self-review): introduces hard-to-evaluate judgment call ("would this design change if the consumer evolves?")

### Decisions

- **Lucy AGENT.md changes**
  Chosen: No changes to lucy/AGENT.md
  Over: Adding roadmap-awareness to lucy's scope creep indicators
  Why: Lucy's existing language accommodates the distinction; duplicate governance logic creates divergence risk

- **CLAUDE.local.md override removal timing**
  Chosen: Remove in same PR (Task 4)
  Over: Defer to separate follow-up PR
  Why: Dual-source-of-truth problem; CLAUDE.local.md is local-only so zero blast radius

- **RESEARCH.md update**
  Chosen: Exclude from plan
  Over: Update margo/RESEARCH.md with backing research (ai-modeling-minion proposal)
  Why: AGENT.md change is self-explanatory; Decision 33 provides rationale. Adding scope without protective value.

## Phases

### Phase 1: Meta-Plan

Nefario identified ai-modeling-minion (prompt engineering for decision tree logic), lucy (governance alignment), margo (self-review), and software-docs-minion (decisions.md documentation) as planning specialists. Security, test, and UX specialists were deferred to Phase 3.5 review since the change is a governance prompt calibration with no attack surface or executable output.

### Phase 2: Specialist Planning

Four specialists contributed. ai-modeling-minion proposed the two-tier decision tree with concrete consumer criteria and citation requirement. lucy confirmed the change aligns with user intent and that her own AGENT.md needs no changes. margo's self-review proposed a three-tier scale (trivial/moderate/high) but this was narrowed to two tiers in synthesis. software-docs-minion confirmed Decision 33 scope and that high-level docs should NOT be updated (single-source-of-truth discipline).

### Phase 3: Synthesis

Nefario consolidated into a 4-task plan with 2 gates: (1) margo/AGENT.md with three surgical edits, (2) the-plan.md spec update, (3) Decision 33, (4) CLAUDE.local.md override removal. Key synthesis decisions: two-tier over three-tier scale, no lucy changes, override removal in same PR, no RESEARCH.md update.

### Phase 3.5: Architecture Review

Five mandatory reviewers (security-minion, test-minion, ux-strategy-minion, lucy, margo). No discretionary reviewers selected. Results: 2 APPROVE (test-minion, ux-strategy-minion), 3 ADVISE (security-minion, lucy, margo), 0 BLOCK. Six advisories incorporated: citation requirement for roadmap references, simplified Edit 3 cross-reference, concrete example replacing "interface addition", Decision 32 heading fix, Decision 33 verbosity trimming, absolute path for CLAUDE.local.md in worktree.

### Phase 4: Execution

Executed in 3 batches. Batch 1: Task 1 (margo/AGENT.md) completed and approved at gate. Batch 2: Task 2 (the-plan.md) and Task 4 (CLAUDE.local.md) ran in parallel; Task 2 approved at gate. Batch 3: Task 3 (Decision 33) completed. All 4 tasks completed successfully. 3 git commits produced.

### Phase 5: Code Review

Three reviewers (code-review-minion, lucy, margo). All returned ADVISE, no BLOCK. Key findings: code-review-minion noted label placement ambiguity for structurally complex roadmap items (non-blocking); margo confirmed the two-tier evaluation is proportional to the problem; lucy flagged CLAUDE.local.md override status in Decision 33 wording (non-blocking, file is gitignored). All findings accepted as-is — refinements for future iteration, not blockers.

### Phase 6: Test Execution

Skipped (no test infrastructure — agent prompt and documentation changes only).

### Phase 7: Deployment

Skipped (not requested).

### Phase 8: Documentation

Phase 8a assessment found 0 actionable items. All documentation needs addressed by Task 3 (Decision 33). High-level docs describe margo's role, not evaluation algorithm — no stale content. Phase 8b skipped (empty checklist).

<details>
<summary>Agent Contributions (4 planning, 5 review, 3 code review)</summary>

### Planning

**ai-modeling-minion**: Proposed two-tier YAGNI evaluation with decision tree pattern, falsifiable evidence standard, and citation requirement.
- Adopted: decision tree structure, concrete consumer criteria, citation format, proportional cost examples
- Risks flagged: "roadmap-planned" becoming rubber stamp without evidence standard

**lucy**: Confirmed governance alignment, validated that her AGENT.md needs no changes, identified intent-drift risk in proportional complexity filter.
- Adopted: no lucy changes, intent-drift concern noted at gate
- Risks flagged: proportional filter narrower than user's "do NOT apply YAGNI" statement

**margo**: Self-reviewed the calibration scope, proposed three-tier cost scale (trivial/moderate/high).
- Adopted: overall approach validation, YAGNI enforcement section as target
- Risks flagged: over-fitting to duration_ms example

**software-docs-minion**: Confirmed Decision 33 scope, validated that high-level docs should not reference evaluation algorithm detail.
- Adopted: single-source-of-truth discipline for evaluation logic
- Risks flagged: none

### Architecture Review

**security-minion**: ADVISE. SCOPE: margo/AGENT.md YAGNI verdict output. CHANGE: Add citation requirement for ROADMAP-PLANNED labels. WHY: Without traceability, claim is unfalsifiable.

**test-minion**: APPROVE. No concerns — prompt changes with no executable output.

**ux-strategy-minion**: APPROVE. No concerns — calibration improves developer experience with governance system.

**lucy**: ADVISE.
- SCOPE: docs/decisions.md Decision 32. CHANGE: Fix orphaned heading. WHY: Copy-paste error from Decision 31.
- SCOPE: Task 4 file path. CHANGE: Use absolute path for CLAUDE.local.md. WHY: Worktree compatibility.

**margo**: ADVISE.
- SCOPE: margo/AGENT.md Edit 3. CHANGE: Simplify to cross-reference. WHY: Avoids third maintenance point.
- SCOPE: margo/AGENT.md examples. CHANGE: Replace "interface addition" with concrete example. WHY: Prompt reliability.
- SCOPE: Decision 33. CHANGE: Trim verbosity ~40%. WHY: Reference material, not essay.

### Code Review

**code-review-minion**: ADVISE. SCOPE: margo/AGENT.md:172-184. CHANGE: Label placement — structurally complex roadmap items don't receive explicit ROADMAP-PLANNED label. WHY: Verdict format requirement at lines 181-184 partially unenforceable for deferral path. Non-blocking refinement.

**lucy**: ADVISE. SCOPE: Decision 33 consequences field. CHANGE: CLAUDE.local.md override claim vs. gitignored reality. WHY: Decision says "removed" but file is gitignored so PR doesn't prove it. Non-blocking wording issue.

**margo**: ADVISE. SCOPE: margo/AGENT.md:160-188. CHANGE: Two-tier block could be compressed ~10 lines. WHY: Verbosity in prompt. Confirmed change is proportional and NOT over-engineered.

</details>

## Execution

### Tasks

| # | Task | Agent | Status |
|---|------|-------|--------|
| 1 | Update margo/AGENT.md — YAGNI Enforcement + Working Patterns + Scope Creep | ai-modeling-minion | completed |
| 2 | Update the-plan.md margo spec — remit line + spec-version bump | ai-modeling-minion | completed |
| 3 | Add Decision 33 to docs/decisions.md | software-docs-minion | completed |
| 4 | Remove CLAUDE.local.md YAGNI override section | ai-modeling-minion | completed |

### Files Changed

| File | Action | Description |
|------|--------|-------------|
| [margo/AGENT.md](../../../margo/AGENT.md) | modified | Two-tier YAGNI evaluation, Working Patterns step 4, Scope Creep cross-reference, x-plan-version 1.2 |
| [the-plan.md](../../../the-plan.md) | modified | Margo spec remit line updated, spec-version 1.2 |
| [docs/decisions.md](../../decisions.md) | modified | Decision 33 added, Decision 32 heading fixed |

### Approval Gates

| Gate | Type | Outcome | Notes |
|------|------|---------|-------|
| P1 Team | Team | approved | 4 specialists selected |
| P3.5 Reviewers | Reviewer | approved | 5 mandatory, 0 discretionary |
| P3.5 Plan | Plan | approved | 4 tasks, 2 gates, 6 advisories |
| Task 1: margo/AGENT.md | Mid-execution | approved | Two-tier YAGNI evaluation |
| Task 2: the-plan.md | Mid-execution | approved | Spec remit + version bump |

## Decisions

#### Task 1: margo/AGENT.md — YAGNI Enforcement

**Decision**: Two-tier YAGNI evaluation with falsifiable evidence standard and citation requirement.
**Rationale**: Direct surgical edits to three named sections. Citation requirement makes ROADMAP-PLANNED claims falsifiable. Cross-reference in Scope Creep avoids third maintenance point. Concrete example (additive YAML frontmatter field) replaces generic "interface addition".
**Rejected**: Rewriting full YAGNI section (unnecessary — opening paragraph and detection patterns correct). Separate "Roadmap Items" section (dual maintenance point). Velocity-specific language (AGENT.md must be velocity-neutral).
**Confidence**: HIGH
**Outcome**: approved

#### Task 2: the-plan.md spec update

**Decision**: Minimal remit line update + spec-version bump to 1.2.
**Rationale**: Spec should be concise; implementation detail belongs in AGENT.md. Two edits align spec with AGENT.md.
**Rejected**: Full spec rewrite (over-detailed for spec). Leaving spec unchanged (version drift).
**Confidence**: HIGH
**Outcome**: approved

## Verification

| Phase | Result |
|-------|--------|
| Code Review | 3 ADVISE, 0 BLOCK — all findings accepted as non-blocking refinements |
| Test Execution | Skipped (no test infrastructure — prompt and documentation changes only) |
| Deployment | Skipped (not requested) |
| Documentation | Phase 8a: 0 items. Phase 8b: skipped (empty checklist) |

<details>
<summary>Session resources (1 skill)</summary>

### External Skills

| Skill | Classification | Recommendation | Tasks Used |
|-------|---------------|----------------|------------|
| despicable-lab | ORCHESTRATION | Post-execution verification (--check) | none (verification only) |

### Skills Invoked

- `/nefario` -- orchestration workflow

Context compaction: 2 events

</details>

## Working Files

<details>
<summary>Working files (10 files)</summary>

Companion directory: [2026-03-21-220622-margo-yagni-calibration/](./2026-03-21-220622-margo-yagni-calibration/)

**Prompts**
- [Phase 4: ai-modeling-minion task2 prompt](./2026-03-21-220622-margo-yagni-calibration/phase4-ai-modeling-minion-task2-prompt.md)
- [Phase 4: ai-modeling-minion task4 prompt](./2026-03-21-220622-margo-yagni-calibration/phase4-ai-modeling-minion-task4-prompt.md)
- [Phase 4: software-docs-minion task3 prompt](./2026-03-21-220622-margo-yagni-calibration/phase4-software-docs-minion-task3-prompt.md)
- [Phase 5: code-review-minion prompt](./2026-03-21-220622-margo-yagni-calibration/phase5-code-review-minion-prompt.md)
- [Phase 5: lucy prompt](./2026-03-21-220622-margo-yagni-calibration/phase5-lucy-prompt.md)
- [Phase 5: margo prompt](./2026-03-21-220622-margo-yagni-calibration/phase5-margo-prompt.md)

**Outputs**
- [Phase 5: code-review-minion](./2026-03-21-220622-margo-yagni-calibration/phase5-code-review-minion.md)
- [Phase 5: lucy](./2026-03-21-220622-margo-yagni-calibration/phase5-lucy.md)
- [Phase 5: margo](./2026-03-21-220622-margo-yagni-calibration/phase5-margo.md)
- [Phase 8: checklist](./2026-03-21-220622-margo-yagni-calibration/phase8-checklist.md)

Note: Phase 1-3.5 working files from the prior session were not preserved across context continuation.

</details>
