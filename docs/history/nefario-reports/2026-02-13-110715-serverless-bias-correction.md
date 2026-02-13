---
type: nefario-report
version: 3
date: "2026-02-13"
time: "11:07:15"
task: "Advisory: correct serverless bias in agent system"
mode: plan
agents-involved: [nefario, iac-minion, margo, gru, lucy, devx-minion, security-minion, test-minion, ux-strategy-minion]
task-count: 0
gate-count: 0
outcome: completed
---

# Advisory: Correct Serverless Bias in Agent System

## Summary

Five specialists independently confirmed a structural anti-serverless bias in the despicable-agents system, distributed across three compounding gaps: iac-minion has zero serverless knowledge, margo's complexity heuristics penalize novelty instead of operational burden, and the delegation table has no serverless routing. All specialists unanimously recommend against a new agent -- the fix is expanding iac-minion's remit, recalibrating margo's heuristics, updating the delegation table, and providing a CLAUDE.md template for target projects to declare serverless-first preferences.

## Original Prompt

> Advisory-only request. Create a meaningful report with the team to consult on the following question, don't act. No execution or post-processing.
>
> Question: When starting greenfield, the system thinks serverless is complicated and flags it as overengineering / YAGNI / anti-KISS, but that's a wrong bias. Serverless is super simple. Maybe we need a serverless agent in the roster? At a minimum, we must correct the bias in a meaningful way and find the right entry point for that (CLAUDE.md? lucy?).

## Key Design Decisions

#### No New Agent -- Expand Existing Knowledge

**Rationale**:
- All 5 specialists independently reached the same conclusion: the gap is knowledge, not roster
- 27 agents is already at the upper bound of manageable complexity
- A serverless-minion would have boundary conflicts with iac-minion, edge-minion, frontend-minion, and api-design-minion
- Filling iac-minion's knowledge gap is cheaper and less disruptive than adding a 28th agent

**Alternatives Rejected**:
- Dedicated serverless-minion: boundary conflicts with 4 existing agents, adds complexity without proportional value

#### CLAUDE.md for Preferences, Agents for Capability

**Rationale**:
- Agents are generic specialists under Apache 2.0 -- hardcoding "serverless-first" makes them opinionated
- CLAUDE.md is the most enforceable location (lucy can produce APPROVE/BLOCK verdicts against it)
- Follows the existing pattern (CLAUDE.local.md carries vendor preferences, agents stay generic)
- Per-project customizable: different projects can have different infrastructure preferences

**Alternatives Rejected**:
- Baking preference into iac-minion AGENT.md: violates publishability constraint, forces opinion on all users
- Adding to despicable-agents' own CLAUDE.md: wrong scope (governs agent development, not target projects)
- Making margo block self-hosted proposals: margo enforces simplicity, not infrastructure topology

#### Operational Burden Over Novelty in Complexity Scoring

**Rationale**:
- Current "New service: 5 points" treats `vercel deploy` the same as Docker + Terraform + Caddy
- Self-managed services carry ongoing operational burden (patching, scaling, incident response) that was underweighted
- Splitting to self-managed (8pts) vs managed/serverless (3pts) corrects the structural bias

**Alternatives Rejected**:
- Keeping flat scoring: perpetuates the bias
- devx-minion's 25-point Kubernetes scale: different measurement (DX benchmark, not complexity budget)

### Conflict Resolutions

**Serverless routing ownership**: devx-minion proposed edge-minion as primary for serverless deployment config. iac-minion and gru proposed iac-minion. Resolved: iac-minion owns deployment decisions and platform config; edge-minion owns edge-specific implementation. Preserves existing boundary.

**Margo's scope with infrastructure opinions**: lucy cautioned that making margo opinionated about infrastructure topology is scope creep. Resolved: margo detects when infrastructure complexity is disproportionate (a simplicity question, in scope), without prescribing alternatives (an infrastructure preference, out of scope).

**Complexity budget vs DX scoring**: margo's two-tier budget and devx-minion's deployment complexity score are incompatible scales. Resolved: margo's split (8/3) goes into the Complexity Budget; devx-minion's scoring stays as a separate DX benchmark in devx-minion's knowledge.

## Phases

### Phase 1: Meta-Plan

Nefario analyzed the question and identified five specialists: iac-minion (self-assessment of knowledge gap), margo (complexity heuristic recalibration), gru (technology maturity assessment), lucy (convention entry point design), and devx-minion (developer experience perspective). The meta-plan identified that the bias is structural and emergent -- not from a single rule but from three compounding gaps across agent knowledge, heuristic framing, and task routing. No external skills were relevant.

### Phase 2: Specialist Planning

Five specialists were consulted in parallel, all at opus. Key findings by agent:

**iac-minion** performed a candid self-assessment: "The bias is real and I am its primary vector." The word "serverless" appears zero times in its AGENT.md. Its Infrastructure Design Approach never asks "does this project need infrastructure at all?" Estimated 10:1 operational complexity ratio between its default stack and serverless. Proposed a Step 0 deployment strategy triage and bounded serverless knowledge additions.

**margo** identified three compounding factors in its own heuristics: complexity budget measures novelty not burden, boring tech examples implicitly equate "boring" with "self-hosted," and no detection pattern exists for infrastructure over-engineering. Proposed splitting service costs (self-managed 8pts, managed 3pts), adding serverless to boring tech, and adding an Infrastructure Over-Engineering detection pattern.

**gru** classified AWS Lambda and Cloudflare Workers as ADOPT, Vercel as TRIAL, Netlify as TRIAL with reservations, and Deno Deploy as ASSESS. Confirmed serverless is legitimately boring technology for qualifying patterns. Recommended against a 28th agent. Flagged vendor lock-in as highest-severity risk.

**lucy** concluded that CLAUDE.md is the most enforceable entry point, citing three properties: enforceability (APPROVE/BLOCK verdicts), publishability (agents stay generic), and the three-gap nature of the bias (no single fix suffices). Recommended a layered combination: CLAUDE.md for preference, agents for capability, delegation table for routing.

**devx-minion** quantified a 50:1 time-to-first-deploy penalty (47 seconds for `vercel deploy` vs 1-4 hours for Docker + Terraform + Caddy). Proposed a 5-level escalation path from static hosting (Level 0) to self-managed infrastructure (Level 4). Core principle: "Complexity should be opt-in, not opt-out."

No specialists recommended additional agents beyond the initial five.

### Phase 3: Synthesis

Nefario consolidated the five contributions into a unified advisory. All specialists converged on the same corrective architecture with no fundamental disagreements. Three minor conflicts were resolved (routing ownership, margo scope, budget scoring). The synthesis produced four prioritized recommendations: (1) expand iac-minion, (2) recalibrate margo, (3) update delegation table, (4) provide CLAUDE.md template. An implementation roadmap was included for if/when the user decides to act.

### Phase 3.5: Architecture Review

Five mandatory reviewers (security-minion, test-minion, ux-strategy-minion, lucy, margo) reviewed the synthesis. No discretionary reviewers applied (advisory-only, no code output).

Results: 2 APPROVE (lucy, ux-strategy-minion), 3 ADVISE (security-minion, test-minion, margo), 0 BLOCK.

Security-minion advised adding serverless security patterns to iac-minion's knowledge, framing vendor lock-in as a security risk (not just cost/portability), and adding security-based escalation triggers (compliance forensics, mTLS, BYOK). Test-minion advised adding calibration examples to the triage decision tree and defining pass/fail criteria for Phase E verification. Margo advised that the 5-level escalation ladder is over-specified for an advisory, the four delegation table rows could be two, and Phase E verification is premature for changes that don't yet exist.

### Phase 4: Execution

Skipped (advisory-only).

### Phase 5: Code Review

Skipped (advisory-only).

### Phase 6: Test Execution

Skipped (advisory-only).

### Phase 7: Deployment

Skipped (advisory-only).

### Phase 8: Documentation

Skipped (advisory-only).

<details>
<summary>Agent Contributions (5 planning, 5 review)</summary>

### Planning

**iac-minion**: Self-assessed a complete serverless knowledge gap. Proposed deployment strategy triage as Step 0, bounded serverless knowledge (Vercel deep, CF Pages/Lambda moderate), decision-first knowledge restructuring, and a 4-level escalation path.
- Adopted: All recommendations adopted into synthesis
- Risks flagged: Margo coordination required or complexity budget will overrule serverless recommendations

**margo**: Identified three heuristic flaws (novelty-based scoring, self-hosted boring tech bias, missing infra over-engineering detection). Proposed split service costs, boring tech additions, and new detection patterns.
- Adopted: All recommendations adopted
- Risks flagged: Over-correction risk; counter-signals must be equally prominent

**gru**: Classified serverless platforms on adopt/trial/assess/hold. Lambda and CF Workers at ADOPT. Confirmed serverless is boring technology. Recommended against 28th agent.
- Adopted: All recommendations adopted; technology maturity assessment referenced in synthesis
- Risks flagged: Vendor lock-in accumulation (highest severity)

**lucy**: Analyzed convention enforceability across entry points. Concluded CLAUDE.md is most enforceable; agents stay generic; bias is three gaps not one convention.
- Adopted: Layered approach (CLAUDE.md preference + agent capability + routing) adopted
- Risks flagged: Publishability constraint if preferences baked into agents

**devx-minion**: Quantified 50:1 TTFD penalty. Designed 5-level escalation path. Proposed complexity-as-opt-in principle.
- Adopted: Escalation path and TTFD analysis adopted; deployment complexity score kept as separate DX metric
- Risks flagged: Over-correction to always-serverless

### Architecture Review

**lucy**: APPROVE. Synthesis faithfully represents the user's original question. Publishability preserved. One non-blocking observation: proposed margo Boring Technology addition names specific platforms where current section names none (stylistic shift).

**ux-strategy-minion**: APPROVE. Journey coherence is strong. Escalation ladder transforms an invisible default into an explicit decision framework. Cognitive load reduced (triage offloaded to agent). Two observations: delegation table rows may be too granular; margo's 8/3 budget split will need calibration over time.

**security-minion**: ADVISE. Three warnings: (1) iac-minion's serverless expansion omits security patterns (shared responsibility, IAM, event injection); (2) vendor lock-in framed as cost/portability only, missing security dimension (single trust point, opaque runtime); (3) escalation ladder missing security triggers (compliance forensics, mTLS, BYOK).

**test-minion**: ADVISE. Two warnings: (1) Phase E verification is underspecified (narrative prose, no pass/fail criteria); (2) triage decision tree lacks calibration examples (3-5 worked scenarios would serve as implicit test cases).

**margo**: ADVISE. Four concerns: (1) 5-level escalation ladder over-specified for an advisory; (2) four delegation table rows where two suffice; (3) technology maturity table reproduced out of gru's scope; (4) Phase E verification premature for non-existent changes. Core recommendations are sound and proportional.

</details>

## Execution

### Tasks

No execution tasks (advisory-only).

### Files Changed

No files changed (advisory-only).

## Verification

| Phase | Result |
|-------|--------|
| Code Review | Skipped (advisory-only) |
| Test Execution | Skipped (advisory-only) |
| Deployment | Skipped (advisory-only) |
| Documentation | Skipped (advisory-only) |

## Working Files

<details>
<summary>Working files (25 files)</summary>

Companion directory: [2026-02-13-110715-serverless-bias-correction/](./2026-02-13-110715-serverless-bias-correction/)

- [Original Prompt](./2026-02-13-110715-serverless-bias-correction/prompt.md)

**Outputs**
- [Phase 1: Meta-plan](./2026-02-13-110715-serverless-bias-correction/phase1-metaplan.md)
- [Phase 2: iac-minion](./2026-02-13-110715-serverless-bias-correction/phase2-iac-minion.md)
- [Phase 2: margo](./2026-02-13-110715-serverless-bias-correction/phase2-margo.md)
- [Phase 2: gru](./2026-02-13-110715-serverless-bias-correction/phase2-gru.md)
- [Phase 2: lucy](./2026-02-13-110715-serverless-bias-correction/phase2-lucy.md)
- [Phase 2: devx-minion](./2026-02-13-110715-serverless-bias-correction/phase2-devx-minion.md)
- [Phase 3: Synthesis](./2026-02-13-110715-serverless-bias-correction/phase3-synthesis.md)
- [Phase 3.5: security-minion](./2026-02-13-110715-serverless-bias-correction/phase3.5-security-minion.md)
- [Phase 3.5: test-minion](./2026-02-13-110715-serverless-bias-correction/phase3.5-test-minion.md)
- [Phase 3.5: ux-strategy-minion](./2026-02-13-110715-serverless-bias-correction/phase3.5-ux-strategy-minion.md)
- [Phase 3.5: lucy](./2026-02-13-110715-serverless-bias-correction/phase3.5-lucy.md)
- [Phase 3.5: margo](./2026-02-13-110715-serverless-bias-correction/phase3.5-margo.md)

**Prompts**
- [Phase 1: Meta-plan prompt](./2026-02-13-110715-serverless-bias-correction/phase1-metaplan-prompt.md)
- [Phase 2: iac-minion prompt](./2026-02-13-110715-serverless-bias-correction/phase2-iac-minion-prompt.md)
- [Phase 2: margo prompt](./2026-02-13-110715-serverless-bias-correction/phase2-margo-prompt.md)
- [Phase 2: gru prompt](./2026-02-13-110715-serverless-bias-correction/phase2-gru-prompt.md)
- [Phase 2: lucy prompt](./2026-02-13-110715-serverless-bias-correction/phase2-lucy-prompt.md)
- [Phase 2: devx-minion prompt](./2026-02-13-110715-serverless-bias-correction/phase2-devx-minion-prompt.md)
- [Phase 3: Synthesis prompt](./2026-02-13-110715-serverless-bias-correction/phase3-synthesis-prompt.md)
- [Phase 3.5: security-minion prompt](./2026-02-13-110715-serverless-bias-correction/phase3.5-security-minion-prompt.md)
- [Phase 3.5: test-minion prompt](./2026-02-13-110715-serverless-bias-correction/phase3.5-test-minion-prompt.md)
- [Phase 3.5: ux-strategy-minion prompt](./2026-02-13-110715-serverless-bias-correction/phase3.5-ux-strategy-minion-prompt.md)
- [Phase 3.5: lucy prompt](./2026-02-13-110715-serverless-bias-correction/phase3.5-lucy-prompt.md)
- [Phase 3.5: margo prompt](./2026-02-13-110715-serverless-bias-correction/phase3.5-margo-prompt.md)

</details>
