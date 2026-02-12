---
type: nefario-report
version: 3
date: "2026-02-12"
time: "11:14:17"
task: "Add user approval gate after Phase 2 specialist team selection"
source-issue: 48
mode: full
agents-involved: [nefario, ux-strategy-minion, devx-minion, lucy, margo, security-minion, test-minion, software-docs-minion, user-docs-minion, code-review-minion]
task-count: 3
gate-count: 1
outcome: completed
---

# Add user approval gate after Phase 2 specialist team selection

## Summary

Added a Team Approval Gate between Phase 1 (Meta-Plan) and Phase 2 (Specialist Planning) in the nefario orchestration workflow. Users now see which specialists were selected with rationale and can approve, adjust (freeform, 2-round cap), or reject before specialist dispatch begins. This prevents wasted compute on irrelevant specialists and gives early visibility into orchestration decisions.

## Original Prompt

> **Outcome**: Before nefario dispatches specialists for planning, the user sees which agents were selected and can approve, adjust, or veto the team composition. This prevents wasted compute on specialists the user considers irrelevant and gives the user visibility into orchestration decisions early.
>
> **Success criteria**:
> - After Phase 2 team selection, nefario presents the chosen specialists with rationale before proceeding
> - User can approve the team as-is, remove specialists, or add specialists not initially selected
> - Phase 2 does not proceed to specialist dispatch until the user confirms
> - Existing Phase 3.5 architecture review gate continues to work unchanged
>
> **Scope**:
> - In: Nefario SKILL.md orchestration flow, Phase 2 team selection logic, approval gate UX
> - Out: Phase 3.5 review gate changes, agent AGENT.md files, the-plan.md, adding new agents

## Key Design Decisions

#### Gate Weight: Categorically Lighter Than Execution Plan Gate

**Rationale**:
- Two pre-execution gates risk approval fatigue; the team gate must be visibly different from the heavier execution plan gate
- Target 8-12 lines (vs 25-40 for execution plan gate) with under 10 seconds for common approve path
- Three options (Approve/Adjust/Reject) vs four options per Hick's Law

**Alternatives Rejected**:
- Same weight as execution plan gate: would cause rubber-stamping
- No gate at all (status quo): user has no visibility into team selection decisions

#### Freeform Natural Language for Team Adjustment

**Rationale**:
- Users refer to agents by name or domain in natural language
- Nefario validates against the 27-agent roster before interpretation
- Domain hint list provided as memory aid

**Alternatives Rejected**:
- 27-item multi-select UI: overwhelming, terrible UX at scale
- Structured form with dropdowns: over-engineered for a rarely-used path

#### Three Response Options (Not Four)

**Rationale**:
- "Skip planning" (jump to MODE: PLAN) is a mode switch, not a team response
- Users who want MODE: PLAN should invoke it explicitly
- Fewer options = faster decisions at a glance-and-confirm checkpoint

**Alternatives Rejected**:
- 4th "Skip planning" option: redundant with MODE: PLAN, adds cognitive load

### Conflict Resolutions

Three conflicts were resolved during synthesis:

1. **CONDENSE line timing** (ux-strategy vs devx): Kept BEFORE gate with `(pending approval)` marker. Moving it after would break the pattern for all other CONDENSE lines.
2. **Response option count** (ux-strategy: 3 vs devx: 4): Used 3 options. "Skip planning" is redundant with MODE: PLAN.
3. **MODE: PLAN behavior** (ux-strategy vs lucy): Gate skipped in MODE: PLAN (lucy's position). Showing specialists then not consulting them is confusing.

## Phases

### Phase 1: Meta-Plan

Nefario identified three specialists for planning: ux-strategy-minion (gate interaction design), devx-minion (SKILL.md integration), and lucy (governance alignment). Two project-local skills were discovered (despicable-lab, despicable-statusline) but neither was relevant. Zero mid-execution gates anticipated.

### Phase 2: Specialist Planning

Three specialists contributed in parallel. ux-strategy-minion recommended the gate be categorically lighter than the execution plan gate (5-12 lines), with freeform "Adjust team" instead of multi-select. devx-minion identified the exact insertion point in SKILL.md and recommended natural language modification with roster validation. lucy confirmed the gate aligns with project governance, noting it should be mandatory by default and exempt in MODE: PLAN.

### Phase 3: Synthesis

Nefario synthesized three specialist contributions into a 3-task, 1-gate plan. Three conflicts were resolved (CONDENSE timing, option count, MODE: PLAN behavior). The calibration counter exemption was dropped per margo's later advice -- pre-execution gates structurally cannot trigger the mid-execution calibration check.

### Phase 3.5: Architecture Review

Six mandatory reviewers participated. All approved or advised; no blocks. Security-minion advised adding roster validation for the freeform input (incorporated). ux-strategy-minion advised adding a domain hint in the adjustment prompt and explicit cap-reached behavior (incorporated). software-docs-minion noted architecture.md and decisions.md as additional documentation targets (deferred as non-blocking). margo advised dropping the calibration counter exemption language (incorporated). lucy verified all requirements traced to plan elements with no scope violations.

### Phase 4: Execution

Three tasks executed in two batches. Batch 1: devx-minion added the Team Approval Gate section to SKILL.md (+67 lines). After gate approval, Batch 2: software-docs-minion updated docs/orchestration.md (+33/-3 lines) and user-docs-minion updated docs/using-nefario.md (+2/-2 lines), running in parallel.

### Phase 5: Code Review

Three reviewers (code-review-minion, lucy, margo) reviewed all changed files. code-review-minion and lucy approved with no findings. margo advised monitoring adjust-team path usage and noted the roster validation instruction could potentially live in AGENT.md instead of SKILL.md (NIT, non-blocking).

### Phase 6: Test Execution

Skipped (no executable code produced; changes are to markdown workflow instructions and documentation).

### Phase 7: Deployment

Skipped (not user-requested).

### Phase 8: Documentation

Skipped (deliverables are themselves documentation; no additional docs needed).

## Agent Contributions

<details>
<summary>Agent Contributions (3 planning, 6 review)</summary>

### Planning

**ux-strategy-minion**: Designed the gate as a lightweight glance-and-confirm checkpoint (5-12 lines) with freeform team adjustment.
- Adopted: 3-option structure, freeform adjust flow, domain hint list, cap-reached behavior
- Risks flagged: approval fatigue from two pre-execution gates

**devx-minion**: Identified SKILL.md insertion point, CONDENSE line timing, and Communication Protocol SHOW list requirement.
- Adopted: gate insertion at line 374, CONDENSE before gate with `(pending approval)`, SHOW list addition
- Risks flagged: approval fatigue, AGENT.md scope boundary

**lucy**: Confirmed governance alignment, no conflicts with existing rules or MODE: PLAN behavior.
- Adopted: mandatory-by-default/user-skippable pattern, MODE: PLAN exemption, second-round specialists exemption
- Risks flagged: AGENT.md scope boundary if meta-plan format changes needed

### Architecture Review

**security-minion**: ADVISE. Freeform input creates narrow prompt injection surface; recommended roster validation before interpretation.

**test-minion**: APPROVE. No executable test surface; purely prose changes.

**ux-strategy-minion**: ADVISE. Recommended domain hint in adjustment prompt and explicit cap-reached behavior.

**software-docs-minion**: ADVISE. Noted architecture.md and decisions.md as potential additional documentation targets.

**lucy**: ADVISE. Verified all requirements trace to plan elements; CONDENSE `(pending approval)` is a minor pattern extension.

**margo**: ADVISE. Recommended dropping calibration counter exemption language; noted ALSO AVAILABLE list is borderline YAGNI but low cost.

### Code Review

**code-review-minion**: APPROVE. Cross-file consistency verified across all three modified files.

**lucy**: APPROVE. Scope boundaries respected; existing patterns followed; NEVER-skip model correctly extended.

**margo**: ADVISE. Monitor adjust-team usage; roster validation instruction is a NIT.

</details>

## Execution

### Tasks

| # | Task | Agent | Status |
|---|------|-------|--------|
| 1 | Add team approval gate to SKILL.md | devx-minion | completed |
| 2 | Update docs/orchestration.md | software-docs-minion | completed |
| 3 | Update docs/using-nefario.md | user-docs-minion | completed |

### Files Changed

| File Path | Action | Description |
|-----------|--------|-------------|
| [skills/nefario/SKILL.md](../../skills/nefario/SKILL.md) | modified | New Team Approval Gate section (+67 lines), CONDENSE line update, SHOW list addition |
| [docs/orchestration.md](../orchestration.md) | modified | Three-gate taxonomy, new Team Approval Gate subsection, Mermaid diagram update (+33/-3 lines) |
| [docs/using-nefario.md](../using-nefario.md) | modified | Phase 1/2 descriptions updated to reflect user confirmation step (+2/-2 lines) |

### Approval Gates

| Gate Title | Agent | Confidence | Outcome | Rounds |
|------------|-------|------------|---------|--------|
| Add team approval gate to SKILL.md | devx-minion | HIGH | approved | 1 |

## Decisions

#### Add team approval gate to SKILL.md

**Decision**: Accept the Team Approval Gate implementation in SKILL.md as the core deliverable defining the user experience for all future orchestrations.
**Rationale**: Gate follows existing patterns (AskUserQuestion, 3 options, structured format). 8-12 line output is categorically lighter than the 25-40 line execution plan gate. Freeform adjust flow avoids 27-item multi-select. All specialist recommendations incorporated.
**Rejected**: 4-option gate with "Skip planning" (redundant with MODE: PLAN); structured multi-select for team adjustment (poor UX at scale).
**Confidence**: HIGH
**Outcome**: approved

## Verification

| Phase | Result |
|-------|--------|
| Code Review | 2 APPROVE, 1 ADVISE (non-blocking) |
| Test Execution | Skipped (no executable code) |
| Deployment | Skipped (not requested) |
| Documentation | Skipped (deliverables are documentation) |

## Working Files

<details>
<summary>Working files (26 files)</summary>

Companion directory: [2026-02-12-111417-add-user-approval-gate-phase2-team-selection/](./2026-02-12-111417-add-user-approval-gate-phase2-team-selection/)

- [Original Prompt](./2026-02-12-111417-add-user-approval-gate-phase2-team-selection/prompt.md)

**Outputs**
- [Phase 1: Meta-plan](./2026-02-12-111417-add-user-approval-gate-phase2-team-selection/phase1-metaplan.md)
- [Phase 2: ux-strategy-minion](./2026-02-12-111417-add-user-approval-gate-phase2-team-selection/phase2-ux-strategy-minion.md)
- [Phase 2: devx-minion](./2026-02-12-111417-add-user-approval-gate-phase2-team-selection/phase2-devx-minion.md)
- [Phase 2: lucy](./2026-02-12-111417-add-user-approval-gate-phase2-team-selection/phase2-lucy.md)
- [Phase 3: Synthesis](./2026-02-12-111417-add-user-approval-gate-phase2-team-selection/phase3-synthesis.md)
- [Phase 5: code-review-minion](./2026-02-12-111417-add-user-approval-gate-phase2-team-selection/phase5-code-review-minion.md)
- [Phase 5: lucy](./2026-02-12-111417-add-user-approval-gate-phase2-team-selection/phase5-lucy.md)
- [Phase 5: margo](./2026-02-12-111417-add-user-approval-gate-phase2-team-selection/phase5-margo.md)

**Prompts**
- [Phase 1: Meta-plan prompt](./2026-02-12-111417-add-user-approval-gate-phase2-team-selection/phase1-metaplan-prompt.md)
- [Phase 2: ux-strategy-minion prompt](./2026-02-12-111417-add-user-approval-gate-phase2-team-selection/phase2-ux-strategy-minion-prompt.md)
- [Phase 2: devx-minion prompt](./2026-02-12-111417-add-user-approval-gate-phase2-team-selection/phase2-devx-minion-prompt.md)
- [Phase 2: lucy prompt](./2026-02-12-111417-add-user-approval-gate-phase2-team-selection/phase2-lucy-prompt.md)
- [Phase 3: Synthesis prompt](./2026-02-12-111417-add-user-approval-gate-phase2-team-selection/phase3-synthesis-prompt.md)
- [Phase 3.5: security-minion prompt](./2026-02-12-111417-add-user-approval-gate-phase2-team-selection/phase3.5-security-minion-prompt.md)
- [Phase 3.5: test-minion prompt](./2026-02-12-111417-add-user-approval-gate-phase2-team-selection/phase3.5-test-minion-prompt.md)
- [Phase 3.5: ux-strategy-minion prompt](./2026-02-12-111417-add-user-approval-gate-phase2-team-selection/phase3.5-ux-strategy-minion-prompt.md)
- [Phase 3.5: software-docs-minion prompt](./2026-02-12-111417-add-user-approval-gate-phase2-team-selection/phase3.5-software-docs-minion-prompt.md)
- [Phase 3.5: lucy prompt](./2026-02-12-111417-add-user-approval-gate-phase2-team-selection/phase3.5-lucy-prompt.md)
- [Phase 3.5: margo prompt](./2026-02-12-111417-add-user-approval-gate-phase2-team-selection/phase3.5-margo-prompt.md)
- [Phase 4: devx-minion prompt](./2026-02-12-111417-add-user-approval-gate-phase2-team-selection/phase4-devx-minion-prompt.md)
- [Phase 4: software-docs-minion prompt](./2026-02-12-111417-add-user-approval-gate-phase2-team-selection/phase4-software-docs-minion-prompt.md)
- [Phase 4: user-docs-minion prompt](./2026-02-12-111417-add-user-approval-gate-phase2-team-selection/phase4-user-docs-minion-prompt.md)
- [Phase 5: code-review-minion prompt](./2026-02-12-111417-add-user-approval-gate-phase2-team-selection/phase5-code-review-minion-prompt.md)
- [Phase 5: lucy prompt](./2026-02-12-111417-add-user-approval-gate-phase2-team-selection/phase5-lucy-prompt.md)
- [Phase 5: margo prompt](./2026-02-12-111417-add-user-approval-gate-phase2-team-selection/phase5-margo-prompt.md)

</details>
