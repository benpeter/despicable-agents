---
type: nefario-report
version: 3
date: "2026-02-12"
time: "18:08:36"
task: "Add re-run option when roster changes significantly at approval gates"
source-issue: 53
mode: full
agents-involved: [devx-minion, ux-strategy-minion, ai-modeling-minion, lucy, margo, security-minion, test-minion, software-docs-minion, code-review-minion, user-docs-minion, nefario]
task-count: 4
gate-count: 1
outcome: completed
---

# Add re-run option when roster changes significantly at approval gates

## Summary

Added adjustment classification to the nefario orchestration skill, enabling both the Team Approval Gate and Reviewer Approval Gate to automatically scale processing depth based on change magnitude. Minor adjustments (1-2 agents) use the existing lightweight path, while substantial changes (3+ agents) trigger a META-PLAN re-run (team gate) or in-session re-evaluation (reviewer gate), ensuring planning artifacts match the updated roster composition.

## Original Prompt

> #53 use opus for everything and make sure the ai-modeling-minion is part of the planning and architecture review teams

Issue #53: When a user adjusts team composition at either the Team Approval Gate or the Reviewer Approval Gate (Phase 3.5), substantial roster changes trigger a re-run of the relevant planning phase so that questions and review coverage reflect the updated composition.

## Key Design Decisions

#### Invisible Classification (System Behavior, Not User Decision)

**Rationale**:
- The user controls WHAT changes (team composition); the system controls HOW thoroughly it processes the change
- Adding a user-facing decision ("lightweight or re-run?") creates a secondary decision point the issue explicitly excluded
- The threshold (3+ agents) is an implementation detail that increases cognitive load without improving user control

**Alternatives Rejected**:
- User-facing override keywords ("lightweight", "re-run"): Creates secondary decision point violating "no new gates" constraint
- Percentage-based thresholds: Over-engineering for a fixed roster size

#### Context-Aware Re-run (Not Fresh Start)

**Rationale**:
- The re-spawned nefario receives the original meta-plan as context to anchor scope
- A constraint directive prevents scope drift while allowing planning depth
- Output goes to `phase1-metaplan-rerun.md` (preserving original as audit artifact)

**Alternatives Rejected**:
- Fresh re-run without context: Risks scope drift and loses cross-cutting checklist continuity
- Overwriting original meta-plan: Creates stale in-context references

#### Re-run Counts as Same Adjustment Round

**Rationale**:
- The user's mental model is "I adjusted once" regardless of internal processing depth
- Resetting the counter creates unpredictable behavior the user cannot observe
- Infinite loop risk addressed separately via 1 re-run cap per gate

**Alternatives Rejected**:
- Resetting the 2-round counter after re-run: Creates silent behavior difference, confusing for users

### Conflict Resolutions

Three conflicts resolved during synthesis:
1. **Adjustment cap interaction**: devx-minion and ux-strategy-minion (re-run = same round) vs. lucy (re-run resets counter). Resolved in favor of same-round counting with separate re-run cap.
2. **Override mechanism**: devx-minion (explicit override keywords) vs. ux-strategy-minion (invisible). Resolved in favor of invisible classification.
3. **Output file naming**: ai-modeling-minion (separate file) vs. devx-minion (overwrite). Resolved in favor of separate file to avoid stale references.

## Phases

### Phase 1: Meta-Plan

Nefario identified 4 specialists for planning: devx-minion (gate flow structure), ux-strategy-minion (journey coherence), ai-modeling-minion (re-run prompt design, user-requested), and lucy (governance alignment). Two project-local skills discovered (despicable-lab, despicable-statusline) but neither relevant to the task.

### Phase 2: Specialist Planning

Four specialists consulted in parallel. Key consensus: absolute 3+ threshold for both gates, re-run as invisible system behavior, same gate structure preserved. One conflict surfaced: whether re-runs reset or consume the adjustment cap (resolved in synthesis). No additional agents recommended.

### Phase 3: Synthesis

Nefario consolidated into a 4-task plan with 1 approval gate. Three conflicts resolved (adjustment cap interaction, override mechanism visibility, output file naming). All task prompts included explicit "What NOT to Do" boundaries to prevent scope drift.

### Phase 3.5: Architecture Review

Six reviewers (5 mandatory + ai-modeling-minion discretionary). All returned ADVISE or APPROVE with no BLOCKs. Key advisories incorporated: test-minion flagged 0-change edge case and replacement counting ambiguity; lucy flagged missing CONDENSE line template for reviewer gate; margo noted re-run cap redundancy (kept as defense-in-depth).

### Phase 4: Execution

Three batches executed. Batch 1: adjustment classification definition added to SKILL.md. Batch 2: both gate sections restructured in parallel. Batch 3: docs/orchestration.md updated. One approval gate presented after Task 2 (team gate restructuring) -- approved without changes.

### Phase 5: Code Review

Three reviewers: code-review-minion (ADVISE, 3 findings), lucy (APPROVE), margo (APPROVE). Three findings auto-fixed: (1) leaked "substantial" classification label in reviewer gate delta summary, (2) missing "Before spawning" prompt-write instruction for Phase 1 re-run, (3) no-op round counting ambiguity.

### Phase 6: Test Execution

Skipped (no executable code produced -- all changes are specification documents).

### Phase 7: Deployment

Skipped (not requested).

### Phase 8: Documentation

Six-item checklist from Phase 3.5. Items 1-4 (software-docs, orchestration.md) handled by Task 4. Items 5-6 (user-docs, using-nefario.md) handled in Phase 8 by user-docs-minion: added brief clauses about planning refresh on large team changes and reviewer re-evaluation on significant adjustments.

## Agent Contributions

<details>
<summary>Agent Contributions (4 planning, 6 review)</summary>

### Planning

**devx-minion**: Gate adjustment flow restructuring with classification-based branching.
- Adopted: Deterministic threshold (1-2 minor, 3+ substantial), shared classification definition, branching flow structure
- Risks flagged: Re-run latency (30-60s), stale context after re-run

**ux-strategy-minion**: Invisible classification as system behavior, "refresh" not "restart" framing.
- Adopted: No user-facing threshold, no override mechanism, same gate structure preserved
- Risks flagged: Latency mismatch between lightweight and re-run paths

**ai-modeling-minion**: Context-aware re-run prompt design, cost analysis.
- Adopted: Original meta-plan + delta + constraint directive pattern, separate output file, reviewer gate in-session re-evaluation
- Risks flagged: Anchoring bias from carrying original meta-plan

**lucy**: Governance alignment verification, absolute threshold recommendation.
- Adopted: Absolute 3+ threshold, re-run cap (1 per gate)
- Risks flagged: Intent drift if re-run feels like new gate, SKILL.md/docs sync

### Architecture Review

**security-minion**: ADVISE. Reinforce sanitization instruction in re-run prompt (user declined -- intentionally permissive).

**test-minion**: ADVISE. 5 findings: state explosion testability, replacement counting ambiguity, re-run cap state tracking, prompt completeness review, 0-change edge case.

**software-docs-minion**: ADVISE. 6-item documentation impact checklist produced for Phase 8.

**lucy**: ADVISE. 3 NITs: Task 3 missing scratch file statement, CONDENSE line template symmetry, constraint directive maintainability.

**margo**: ADVISE. Re-run cap redundant with adjustment cap (kept as defense-in-depth, negligible complexity).

**ai-modeling-minion**: ADVISE. 5 observations: anchoring bias risk, cost budget acceptable, constraint directive well-calibrated, in-session reviewer re-evaluation correct, compliance risk low due to gate safety net.

### Code Review

**code-review-minion**: ADVISE. 3 findings auto-fixed: leaked classification label, missing prompt-write, no-op ambiguity.

**lucy**: APPROVE. All 6 success criteria met, no drift.

**margo**: APPROVE. Minimum needed, no speculative features.

</details>

## Execution

### Tasks

| # | Task | Agent | Status |
|---|------|-------|--------|
| 1 | Add adjustment classification definition to SKILL.md | devx-minion | completed |
| 2 | Restructure "Adjust team" response handling in SKILL.md | devx-minion | completed |
| 3 | Restructure "Adjust reviewers" response handling in SKILL.md | devx-minion | completed |
| 4 | Update docs/orchestration.md | software-docs-minion | completed |

### Files Changed

| File Path | Action | Description |
|-----------|--------|-------------|
| [skills/nefario/SKILL.md](../../../skills/nefario/SKILL.md) | modified | Added adjustment classification definition, restructured both gate adjustment flows with minor/substantial branching |
| [docs/orchestration.md](../../orchestration.md) | modified | Added brief architectural notes about re-run behavior at both gates |
| [docs/using-nefario.md](../../using-nefario.md) | modified | Added user-facing clauses about planning refresh and reviewer re-evaluation |

### Approval Gates

| Gate Title | Agent | Confidence | Outcome | Rounds |
|------------|-------|------------|---------|--------|
| Team gate adjustment flow design | devx-minion | HIGH | approved | 1 |

#### Team gate adjustment flow design

**Decision**: Team gate adjustment flow now branches on change magnitude -- minor adjustments use lightweight path, substantial changes trigger META-PLAN re-run.
**Rationale**: Context-aware re-run provides same-depth output as original meta-plan. Invisible classification keeps cognitive load zero.
**Rejected**: User-facing override keywords (adds secondary decision point), fresh re-run without context (loses scope anchoring).

## Decisions

#### Team gate adjustment flow design

**Decision**: The "Adjust team" flow branches on adjustment magnitude using the shared classification definition.
**Rationale**: Context-aware META-PLAN re-run provides planning questions at the same depth as the original. Invisible classification avoids a secondary user decision. The re-presented gate uses the same AskUserQuestion structure.
**Rejected**: Explicit override keywords (violates "no new gates" constraint); percentage-based thresholds (over-engineering for fixed roster).
**Confidence**: HIGH
**Outcome**: approved

## Verification

| Phase | Result |
|-------|--------|
| Code Review | 3 findings auto-fixed (leaked label, missing prompt-write, no-op ambiguity) |
| Test Execution | Skipped (no executable code) |
| Deployment | Skipped (not requested) |
| Documentation | 3 files updated (orchestration.md, using-nefario.md via Phase 8) |

## Working Files

<details>
<summary>Working files (34 files)</summary>

Companion directory: [2026-02-12-180836-rerun-on-roster-changes/](./2026-02-12-180836-rerun-on-roster-changes/)

- [Original Prompt](./2026-02-12-180836-rerun-on-roster-changes/prompt.md)

**Outputs**
- [Phase 1: Meta-plan](./2026-02-12-180836-rerun-on-roster-changes/phase1-metaplan.md)
- [Phase 2: devx-minion](./2026-02-12-180836-rerun-on-roster-changes/phase2-devx-minion.md)
- [Phase 2: ux-strategy-minion](./2026-02-12-180836-rerun-on-roster-changes/phase2-ux-strategy-minion.md)
- [Phase 2: ai-modeling-minion](./2026-02-12-180836-rerun-on-roster-changes/phase2-ai-modeling-minion.md)
- [Phase 2: lucy](./2026-02-12-180836-rerun-on-roster-changes/phase2-lucy.md)
- [Phase 3: Synthesis](./2026-02-12-180836-rerun-on-roster-changes/phase3-synthesis.md)
- [Phase 3.5: security-minion](./2026-02-12-180836-rerun-on-roster-changes/phase3.5-security-minion.md)
- [Phase 3.5: test-minion](./2026-02-12-180836-rerun-on-roster-changes/phase3.5-test-minion.md)
- [Phase 3.5: software-docs-minion](./2026-02-12-180836-rerun-on-roster-changes/phase3.5-software-docs-minion.md)
- [Phase 3.5: docs-checklist](./2026-02-12-180836-rerun-on-roster-changes/phase3.5-docs-checklist.md)
- [Phase 3.5: lucy](./2026-02-12-180836-rerun-on-roster-changes/phase3.5-lucy.md)
- [Phase 3.5: margo](./2026-02-12-180836-rerun-on-roster-changes/phase3.5-margo.md)
- [Phase 3.5: ai-modeling-minion](./2026-02-12-180836-rerun-on-roster-changes/phase3.5-ai-modeling-minion.md)
- [Phase 5: code-review-minion](./2026-02-12-180836-rerun-on-roster-changes/phase5-code-review-minion.md)
- [Phase 5: lucy](./2026-02-12-180836-rerun-on-roster-changes/phase5-lucy.md)
- [Phase 5: margo](./2026-02-12-180836-rerun-on-roster-changes/phase5-margo.md)

**Prompts**
- [Phase 1: Meta-plan prompt](./2026-02-12-180836-rerun-on-roster-changes/phase1-metaplan-prompt.md)
- [Phase 2: devx-minion prompt](./2026-02-12-180836-rerun-on-roster-changes/phase2-devx-minion-prompt.md)
- [Phase 2: ux-strategy-minion prompt](./2026-02-12-180836-rerun-on-roster-changes/phase2-ux-strategy-minion-prompt.md)
- [Phase 2: ai-modeling-minion prompt](./2026-02-12-180836-rerun-on-roster-changes/phase2-ai-modeling-minion-prompt.md)
- [Phase 2: lucy prompt](./2026-02-12-180836-rerun-on-roster-changes/phase2-lucy-prompt.md)
- [Phase 3: Synthesis prompt](./2026-02-12-180836-rerun-on-roster-changes/phase3-synthesis-prompt.md)
- [Phase 3.5: security-minion prompt](./2026-02-12-180836-rerun-on-roster-changes/phase3.5-security-minion-prompt.md)
- [Phase 3.5: test-minion prompt](./2026-02-12-180836-rerun-on-roster-changes/phase3.5-test-minion-prompt.md)
- [Phase 3.5: software-docs-minion prompt](./2026-02-12-180836-rerun-on-roster-changes/phase3.5-software-docs-minion-prompt.md)
- [Phase 3.5: lucy prompt](./2026-02-12-180836-rerun-on-roster-changes/phase3.5-lucy-prompt.md)
- [Phase 3.5: margo prompt](./2026-02-12-180836-rerun-on-roster-changes/phase3.5-margo-prompt.md)
- [Phase 3.5: ai-modeling-minion prompt](./2026-02-12-180836-rerun-on-roster-changes/phase3.5-ai-modeling-minion-prompt.md)
- [Phase 4: devx-minion task1 prompt](./2026-02-12-180836-rerun-on-roster-changes/phase4-devx-minion-task1-prompt.md)
- [Phase 4: devx-minion task2 prompt](./2026-02-12-180836-rerun-on-roster-changes/phase4-devx-minion-task2-prompt.md)
- [Phase 4: devx-minion task3 prompt](./2026-02-12-180836-rerun-on-roster-changes/phase4-devx-minion-task3-prompt.md)
- [Phase 4: software-docs-minion prompt](./2026-02-12-180836-rerun-on-roster-changes/phase4-software-docs-minion-prompt.md)
- [Phase 8: user-docs-minion prompt](./2026-02-12-180836-rerun-on-roster-changes/phase8-user-docs-minion-prompt.md)

</details>
