---
type: nefario-report
version: 3
date: "2026-02-13"
time: "15:03:10"
task: "Always re-run Phase 1 meta-plan on any Team Approval Gate roster change"
source-issue: 78
mode: full
agents-involved: [devx-minion, ux-strategy-minion, lucy, ai-modeling-minion, security-minion, test-minion, margo, code-review-minion, software-docs-minion]
task-count: 3
gate-count: 1
outcome: completed
---

# Always re-run Phase 1 meta-plan on any Team Approval Gate roster change

## Summary

Simplified the Team Approval Gate adjustment handling by removing the minor/substantial classification and making any non-zero roster change trigger a full Phase 1 re-run. This ensures all agents' planning questions reflect the updated team composition, eliminating the stale-question problem caused by the lightweight path. The Reviewer Approval Gate retains its own minor/substantial classification (different cost profile, explicitly out of scope).

## Original Prompt

> Always re-run Phase 1 meta-plan on any Team Approval Gate roster change (#78). Use opus for all agents.

## Key Design Decisions

#### Always re-run on any roster change

**Rationale**:
- The lightweight path (minor adjustments) only generated questions for added agents, leaving existing agents' questions stale relative to the new roster
- Planning questions directly shape Phase 2 specialist focus, so coherent questions across the full team produce better planning contributions
- Token cost is negligible ($0.10-$0.20 per re-run per ai-modeling-minion's analysis)

**Alternatives Rejected**:
- Keep lightweight path for small changes: rejected because it reintroduces the stale-question problem under a different name

#### Remove separate re-run cap, rely on 2-round adjustment cap

**Rationale**:
- The 2-round adjustment cap already bounds worst-case to at most 2 re-runs
- A single cap with a single behavior (always re-run) is simpler than two caps with different fallback behaviors
- A mechanical inline fallback on cap exhaustion would reintroduce the quality problem this change solves

**Alternatives Rejected**:
- Keep 1-re-run cap with mechanical inline fallback (ux-strategy-minion): rejected because it reintroduces stale questions on the second adjustment

**Note**: Issue #78's success criteria says "1 re-run cap per gate is preserved." This was replaced with "bounded by 2-round adjustment cap" -- same protection, simpler mechanism. Approved at Task 1 gate.

#### Re-run prompt enhancements

**Rationale**:
- Including the full revised team list helps nefario generate targeted questions
- "Context not template" framing prevents minimal-edit behavior on the original meta-plan
- Coherence instruction ensures cross-agent question boundaries are explicit

**Alternatives Rejected**:
- Add change-significance signal to prompt: rejected because it would reintroduce magnitude-based calibration complexity

### Conflict Resolutions

**Re-run cap behavior**: devx-minion and lucy recommended removing the separate re-run cap entirely (2-round adjustment cap is sufficient). ux-strategy-minion recommended keeping the 1-re-run cap with a mechanical inline fallback. Resolved in favor of removing the separate cap -- the mechanical fallback would reintroduce the stale-question problem, and the 2-round cap already provides a hard bound.

## Phases

### Phase 1: Meta-Plan

Nefario identified 3 specialists for planning consultation: devx-minion (workflow integration, SKILL.md structure), ux-strategy-minion (approval gate interaction design), and lucy (governance alignment). The user adjusted the team to add ai-modeling-minion (re-run prompt engineering), bringing the total to 4 specialists.

### Phase 2: Specialist Planning

Four specialists contributed in parallel. devx-minion recommended removing the shared classification definition and inlining into each gate. ux-strategy-minion confirmed always-re-run is the correct simplification but advocated for a mechanical fallback on cap exhaustion. lucy confirmed cross-gate inconsistency is acceptable and that no AGENT.md changes are needed. ai-modeling-minion recommended regenerating all questions from scratch with "context not template" framing and a coherence instruction.

### Phase 3: Synthesis

Specialist input was merged into a 3-task plan. The key conflict (re-run cap behavior) was resolved in favor of devx-minion and lucy's position. The deviation from issue #78's literal success criteria was flagged for user awareness at the Task 1 approval gate.

### Phase 3.5: Architecture Review

Five mandatory reviewers (security-minion, test-minion, ux-strategy-minion, lucy, margo) reviewed the plan. No discretionary reviewers were needed (no UI, no web-facing code, no runtime components). Results: 3 APPROVE (security-minion, ux-strategy-minion, margo), 2 ADVISE (test-minion, lucy). test-minion advised scoping grep verification to line ranges and adding cross-file consistency checks. lucy confirmed the re-run cap deviation rationale is sound and flagged it for the gate. No BLOCKs.

### Phase 4: Execution

Task 1 (devx-minion): Rewrote the Team gate adjustment handling -- removed shared classification block, collapsed minor/substantial paths into single always-re-run flow, enhanced re-run prompt, simplified caps. Approved at gate. Tasks 2 and 3 ran in parallel after Task 1 approval. Task 2 (devx-minion): Inlined the classification definition into the Reviewer gate section, fixing dangling references. Task 3 (software-docs-minion): Updated docs/orchestration.md Team gate description and Reviewer gate cross-reference, verified no AGENT.md changes needed.

### Phase 5: Code Review

Three reviewers (code-review-minion, lucy, margo) all returned APPROVE. Verified: no stale terminology in Team gate section, coherent flow, self-contained Reviewer gate classification, consistent cross-references between SKILL.md and docs/orchestration.md.

### Phase 6: Test Execution

Skipped (no executable code produced -- all deliverables are spec/documentation edits).

### Phase 7: Deployment

Skipped (not requested).

### Phase 8: Documentation

Skipped (documentation was updated as part of execution in Task 3).

## Agent Contributions

<details>
<summary>Agent Contributions (4 planning, 5 review)</summary>

### Planning

**devx-minion**: Recommended removing the shared classification definition, inlining into each gate section, and removing the separate re-run cap.
- Adopted: All recommendations adopted (Tasks 1 and 2)
- Risks flagged: Reviewer gate dangling references if shared block removed

**ux-strategy-minion**: Confirmed always-re-run is correct simplification. Advocated for mechanical inline fallback on cap exhaustion.
- Adopted: Always-re-run recommendation adopted; mechanical fallback rejected
- Risks flagged: Cross-gate inconsistency (accepted as intentional)

**lucy**: Confirmed cross-gate inconsistency is acceptable, verified no AGENT.md changes needed, confirmed caps remain coherent.
- Adopted: All governance findings adopted
- Risks flagged: CONDENSE line update needed

**ai-modeling-minion**: Recommended regenerating all questions from scratch, "context not template" framing, coherence instruction, including resolved team list. Advised against change-significance signal.
- Adopted: All prompt engineering recommendations (3 enhancements in Task 1)
- Risks flagged: Reviewer gate dangling reference

### Architecture Review

**security-minion**: APPROVE. No security concerns -- changes are spec text edits with no new attack surface.

**test-minion**: ADVISE. Verification grep should be scoped to line ranges; add cross-file consistency check between SKILL.md and docs/orchestration.md.

**ux-strategy-minion**: APPROVE. Net cognitive load reduction. Single-path flow creates clear mental model.

**lucy**: ADVISE. Re-run cap deviation flagged for user awareness at gate (plan already handles this). Task 2's Reviewer gate touch is structural cleanup, correctly scoped.

**margo**: APPROVE. Net simplification -- no over-engineering, no YAGNI violations.

### Code Review

**code-review-minion**: APPROVE. All success criteria met, unified flow is coherent, no stale terminology.

**lucy**: APPROVE. All changes trace to issue #78 requirements, no intent drift.

**margo**: APPROVE. Net complexity reduction, proportional changes.

</details>

## Execution

### Tasks

| # | Task | Agent | Status |
|---|------|-------|--------|
| 1 | Rewrite Team gate adjustment handling in SKILL.md | devx-minion | completed |
| 2 | Inline Reviewer gate classification in SKILL.md | devx-minion | completed |
| 3 | Update docs/orchestration.md | software-docs-minion | completed |

### Files Changed

| File | Action | Description |
|------|--------|-------------|
| [skills/nefario/SKILL.md](../../skills/nefario/SKILL.md) | modified | Removed shared classification block, collapsed Team gate to always-re-run, inlined Reviewer gate classification |
| [docs/orchestration.md](../orchestration.md) | modified | Updated Team gate description and Reviewer gate cross-reference |

### Approval Gates

| Gate Title | Agent | Confidence | Outcome | Rounds |
|------------|-------|------------|---------|--------|
| Rewrite Team gate adjustment handling | devx-minion | HIGH | approved | 1 |

## Decisions

#### Rewrite Team gate adjustment handling

**Decision**: Collapsed minor/substantial paths into single always-re-run flow; removed shared classification block; simplified to 2-round cap as sole bound.
**Rationale**: Single path eliminates stale-question problem. 2-round adjustment cap bounds re-runs to max 2 (same protection, simpler mechanism). Issue #78's "1 re-run cap per gate" replaced with "bounded by 2-round adjustment cap" -- same goal, simpler.
**Rejected**: Mechanical inline fallback (reintroduces quality problem); keeping separate re-run cap (adds confusing cap interaction).
**Confidence**: HIGH
**Outcome**: approved

## Verification

| Phase | Result |
|-------|--------|
| Code Review | 3 APPROVE (code-review-minion, lucy, margo) |
| Test Execution | Skipped (no executable code) |
| Deployment | Skipped (not requested) |
| Documentation | Skipped (updated in execution) |

## Working Files

<details>
<summary>Working files (31 files)</summary>

Companion directory: [2026-02-13-150310-always-rerun-phase1-on-team-gate-change/](./2026-02-13-150310-always-rerun-phase1-on-team-gate-change/)

- [Original Prompt](./2026-02-13-150310-always-rerun-phase1-on-team-gate-change/prompt.md)

**Outputs**
- [Phase 1: Meta-plan](./2026-02-13-150310-always-rerun-phase1-on-team-gate-change/phase1-metaplan.md)
- [Phase 2: devx-minion](./2026-02-13-150310-always-rerun-phase1-on-team-gate-change/phase2-devx-minion.md)
- [Phase 2: ux-strategy-minion](./2026-02-13-150310-always-rerun-phase1-on-team-gate-change/phase2-ux-strategy-minion.md)
- [Phase 2: lucy](./2026-02-13-150310-always-rerun-phase1-on-team-gate-change/phase2-lucy.md)
- [Phase 2: ai-modeling-minion](./2026-02-13-150310-always-rerun-phase1-on-team-gate-change/phase2-ai-modeling-minion.md)
- [Phase 3: Synthesis](./2026-02-13-150310-always-rerun-phase1-on-team-gate-change/phase3-synthesis.md)
- [Phase 3.5: security-minion](./2026-02-13-150310-always-rerun-phase1-on-team-gate-change/phase3.5-security-minion.md)
- [Phase 3.5: test-minion](./2026-02-13-150310-always-rerun-phase1-on-team-gate-change/phase3.5-test-minion.md)
- [Phase 3.5: ux-strategy-minion](./2026-02-13-150310-always-rerun-phase1-on-team-gate-change/phase3.5-ux-strategy-minion.md)
- [Phase 3.5: lucy](./2026-02-13-150310-always-rerun-phase1-on-team-gate-change/phase3.5-lucy.md)
- [Phase 3.5: margo](./2026-02-13-150310-always-rerun-phase1-on-team-gate-change/phase3.5-margo.md)
- [Phase 5: code-review-minion](./2026-02-13-150310-always-rerun-phase1-on-team-gate-change/phase5-code-review-minion.md)
- [Phase 5: lucy](./2026-02-13-150310-always-rerun-phase1-on-team-gate-change/phase5-lucy.md)
- [Phase 5: margo](./2026-02-13-150310-always-rerun-phase1-on-team-gate-change/phase5-margo.md)

**Prompts**
- [Phase 1: Meta-plan prompt](./2026-02-13-150310-always-rerun-phase1-on-team-gate-change/phase1-metaplan-prompt.md)
- [Phase 2: devx-minion prompt](./2026-02-13-150310-always-rerun-phase1-on-team-gate-change/phase2-devx-minion-prompt.md)
- [Phase 2: ux-strategy-minion prompt](./2026-02-13-150310-always-rerun-phase1-on-team-gate-change/phase2-ux-strategy-minion-prompt.md)
- [Phase 2: lucy prompt](./2026-02-13-150310-always-rerun-phase1-on-team-gate-change/phase2-lucy-prompt.md)
- [Phase 2: ai-modeling-minion prompt](./2026-02-13-150310-always-rerun-phase1-on-team-gate-change/phase2-ai-modeling-minion-prompt.md)
- [Phase 3: Synthesis prompt](./2026-02-13-150310-always-rerun-phase1-on-team-gate-change/phase3-synthesis-prompt.md)
- [Phase 3.5: security-minion prompt](./2026-02-13-150310-always-rerun-phase1-on-team-gate-change/phase3.5-security-minion-prompt.md)
- [Phase 3.5: test-minion prompt](./2026-02-13-150310-always-rerun-phase1-on-team-gate-change/phase3.5-test-minion-prompt.md)
- [Phase 3.5: ux-strategy-minion prompt](./2026-02-13-150310-always-rerun-phase1-on-team-gate-change/phase3.5-ux-strategy-minion-prompt.md)
- [Phase 3.5: lucy prompt](./2026-02-13-150310-always-rerun-phase1-on-team-gate-change/phase3.5-lucy-prompt.md)
- [Phase 3.5: margo prompt](./2026-02-13-150310-always-rerun-phase1-on-team-gate-change/phase3.5-margo-prompt.md)
- [Phase 4: devx-minion Task 1 prompt](./2026-02-13-150310-always-rerun-phase1-on-team-gate-change/phase4-devx-minion-task1-prompt.md)
- [Phase 4: devx-minion Task 2 prompt](./2026-02-13-150310-always-rerun-phase1-on-team-gate-change/phase4-devx-minion-task2-prompt.md)
- [Phase 4: software-docs-minion Task 3 prompt](./2026-02-13-150310-always-rerun-phase1-on-team-gate-change/phase4-software-docs-minion-task3-prompt.md)
- [Phase 5: code-review-minion prompt](./2026-02-13-150310-always-rerun-phase1-on-team-gate-change/phase5-code-review-minion-prompt.md)
- [Phase 5: lucy prompt](./2026-02-13-150310-always-rerun-phase1-on-team-gate-change/phase5-lucy-prompt.md)
- [Phase 5: margo prompt](./2026-02-13-150310-always-rerun-phase1-on-team-gate-change/phase5-margo-prompt.md)

</details>
