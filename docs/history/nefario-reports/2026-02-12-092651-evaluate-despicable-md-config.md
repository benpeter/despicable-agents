---
type: nefario-report
version: 3
date: "2026-02-12"
time: "09:26:51"
task: "Evaluate DESPICABLE.md as project-local configuration for the framework"
mode: plan
agents-involved: [nefario, gru, lucy, margo, devx-minion, software-docs-minion, security-minion, test-minion, ux-strategy-minion]
task-count: 0
gate-count: 0
outcome: completed
---

# Evaluate DESPICABLE.md as Project-Local Configuration

## Summary

The team evaluated whether consuming projects should have dedicated DESPICABLE.md and DESPICABLE.local.md files for framework-specific configuration. Five specialists were consulted (gru, lucy, margo, devx-minion, software-docs-minion) and six mandatory reviewers validated the synthesis. The unanimous recommendation from 4 of 5 specialists is to **reject DESPICABLE.md** and use a `## Despicable Agents` section in the existing CLAUDE.md instead. One specialist (software-docs-minion) dissented, favoring dedicated files for separation-of-concerns reasons.

## Original Prompt

> Evaluate DESPICABLE.md as project-local configuration for the framework
>
> **Outcome**: The team reaches a well-reasoned decision on whether consuming projects should have dedicated DESPICABLE.md and DESPICABLE.local.md files for framework-specific configuration, so that project instructions for despicable-agents stay separated from general CLAUDE.md concerns without requiring users to modify files owned by other tools.
>
> **Success criteria**:
> - Clear recommendation (adopt, defer, or reject) with rationale
> - Precedence rules documented if adopted (DESPICABLE.md vs CLAUDE.md conflicts)
> - At least gru, lucy, margo, and devx-minion consulted
> - YAGNI analysis: real demand vs speculative need
> - Alternative approaches evaluated (e.g., a `## Despicable Agents` section in CLAUDE.md)
>
> **Scope**:
> - In: File naming convention, .md vs .local.md split, interaction with existing CLAUDE.md/CLAUDE.local.md, discoverability for adopters, what configuration options these files would support (agent exclusion, domain spin, orchestration overrides)
> - Out: Implementation of file parsing, changes to agent runtime, changes to nefario orchestration code
>
> **Constraints**:
> - Consultation only -- produce a decision document, not code
> - Must include input from gru, lucy, margo, and devx-minion at minimum

## Key Design Decisions

#### Reject DESPICABLE.md, Recommend CLAUDE.md Section Convention

**Rationale**:
- Zero consuming projects exist outside the toolkit itself -- building per-project config infrastructure now is a YAGNI violation
- CLAUDE.md is auto-loaded by Claude Code; DESPICABLE.md would require explicit Read calls in 27 agents
- The industry is consolidating config surfaces (AGENTS.md standard, ESLint flat config), not proliferating them
- All three proposed config use cases (agent exclusion, domain spin, orchestration overrides) already work via CLAUDE.md sections
- Decisions 26 (.nefario.yml rejected) and 27 (overlay mechanism removed) established direct precedent within the past week

**Alternatives Rejected**:
- DESPICABLE.md + DESPICABLE.local.md: Rejected for zero demonstrated demand, 7 complexity points vs. 0 for CLAUDE.md sections, fragile discovery, precedence complexity (4-file hierarchy), and contradiction with freshly-established project principles
- Status quo (no guidance): Rejected because consuming projects would rediscover configuration patterns inconsistently

### Conflict Resolutions

software-docs-minion recommended adopting DESPICABLE.md on separation-of-concerns grounds. This was the only dissenting view (4-to-1 against). The dissent was acknowledged as valid in principle but assessed as disproportionate: the configuration surface is closer to Prettier (few preferences, fits in a host file section) than ESLint (complex plugin architecture needing its own file). software-docs-minion's own documentation burden estimate (1200-1500 lines for dedicated file vs. 400-600 for CLAUDE.md section) itself demonstrated the overhead differential.

## Phases

### Phase 1: Meta-Plan

Nefario identified 5 specialists to consult: the 4 user-specified agents (gru, lucy, margo, devx-minion) plus software-docs-minion for documentation impact assessment. Key tensions identified upfront: Decision 5 establishes CLAUDE.md as the canonical customization surface, the external skill integration already uses CLAUDE.md precedence (Decision 28), and YAGNI/KISS principles from the Helix Manifesto apply strongly.

### Phase 2: Specialist Planning

Five specialists contributed in parallel. Four reached the same conclusion independently (reject DESPICABLE.md), while one (software-docs-minion) recommended adoption. Key findings per specialist are detailed in the Agent Contributions section below.

### Phase 3: Synthesis

Nefario synthesized the 4-to-1 consensus into a single-task execution plan: write Decision 29 in docs/decisions.md. The conflict resolution weighed the majority's YAGNI/platform-integration/industry-direction arguments against the minority's separation-of-concerns argument and found the majority position more compelling given zero external consumers.

### Phase 3.5: Architecture Review

Six mandatory reviewers evaluated the synthesis. All approved or advised (no blocks). Security-minion and software-docs-minion provided advisory notes that were incorporated into the plan's consequences.

### Phase 4: Execution

Skipped. The user requested a consultation report only, not a decision entry in docs/decisions.md.

### Phase 5: Code Review

Skipped (no code produced).

### Phase 6: Test Execution

Skipped (no tests applicable).

### Phase 7: Deployment

Skipped (not requested).

### Phase 8: Documentation

Skipped (consultation only).

<details>
<summary>Agent Contributions (5 planning, 6 review)</summary>

### Planning

**gru**: HOLD on DESPICABLE.md. The industry is consolidating config surfaces -- AGENTS.md (Linux Foundation / AAIF, 40,000+ repo adoption) is emerging as the cross-platform standard. Frameworks that ship their own config files (LangGraph, CrewAI) do so because they are application frameworks with structured, machine-parsed configuration, not guidance files for coding agents. Despicable-agents config is closer to Prettier (section-in-host-file) than ESLint (dedicated file). Key risk: AGENTS.md collision when Claude Code adopts it (71% probability in 2026).
- Adopted: CLAUDE.md section convention as recommended alternative; AGENTS.md migration note as future consideration
- Risks flagged: Config fragmentation (3+ files), discovery failure (27 agents need explicit Read), AGENTS.md collision

**lucy**: BLOCK on DESPICABLE.md. Dual-file validation creates multiplicative compliance complexity (N x M directive pairs). Convention fragmentation violates Decision 5. All three use cases already work via CLAUDE.md. Critical security finding: any configuration allowing exclusion of ALWAYS reviewers (security-minion, test-minion, lucy, margo) undermines Decision 10's safety guarantee -- this applies regardless of config surface and needs enforcement in nefario.
- Adopted: ALWAYS reviewer protection concern carried into consequences; single-surface recommendation
- Risks flagged: Convention fragmentation, security blind spots, precedence complexity (4 new questions)

**margo**: BLOCK on DESPICABLE.md. Fails every YAGNI test. Zero consuming projects, zero user requests. Decision 27 (overlay removal, 3 days ago) and Decision 26 (.nefario.yml rejection, 2 days ago) set direct precedent. Complexity cost: 7 points for DESPICABLE.md vs. 0 for CLAUDE.md sections.
- Adopted: "Not now" framing with explicit re-introduction trigger; complexity cost analysis methodology
- Risks flagged: Building infrastructure nobody asked for; contradicting freshly-established precedent

**devx-minion**: Reject DESPICABLE.md. CLAUDE.md section is more discoverable (developers already know CLAUDE.md), more maintainable (one file vs. two), lower cognitive overhead (no new concept to learn). None of the proposed config options justify a new file -- agent exclusion has low utility (nefario already selects by relevance), domain spin already works via CLAUDE.md, orchestration overrides are dangerous (would bypass governance). ESLint ecosystem moved toward consolidation, not proliferation.
- Adopted: Realistic utility assessment of each config option; discovery-at-planning-time-only recommendation
- Risks flagged: Scope creep into config infrastructure; precedence complexity; onboarding friction

**software-docs-minion** (DISSENT): Adopt DESPICABLE.md. Separation of concerns wins -- framework config separate from general CLAUDE.md. Better discoverability (new contributors see the file), better reusability (copy across projects), cleaner git history. Documentation burden is modest (1200-1500 lines). Proposed 7 documentation tasks.
- Adopted: Documentation burden estimate used as evidence for overhead differential; acknowledgment that consuming-projects guidance is a future need
- Risks flagged: Configuration sprawl, precedence confusion

### Architecture Review

**security-minion**: ADVISE. ALWAYS reviewer bypass risk is an open gap -- CLAUDE.local.md can exclude mandatory reviewers with no enforcement. Recommend tagging as security debt. Also note that unstructured LLM interpretation of config means no formal validation.

**test-minion**: APPROVE. No testing concerns for a decision document task.

**ux-strategy-minion**: APPROVE. CLAUDE.md section optimizes for simplicity and cognitive load reduction. Zero discovery friction, satisficing-friendly (one canonical place), matches existing mental model. Re-introduction trigger is well-calibrated.

**software-docs-minion**: ADVISE. Decision 29 alone does not teach consuming projects how to use CLAUDE.md sections. Recommend a consuming-projects guide as future documentation when external adoption occurs. Format consistency verified against existing decisions.md conventions.

**lucy**: APPROVE. All success criteria covered. Dissenting view given fair treatment. Scope containment verified -- no creep beyond consultation.

**margo**: APPROVE. Appropriately minimal scope. Zero complexity addition. Decision itself is YAGNI-aligned.

</details>

## Execution

### Tasks

| # | Task | Agent | Status |
|---|------|-------|--------|
| - | No execution tasks | - | User requested report only |

### Files Changed

| File Path | Action | Description |
|-----------|--------|-------------|
| docs/history/nefario-reports/2026-02-12-092651-evaluate-despicable-md-config.md | created | This consultation report |
| docs/history/nefario-reports/2026-02-12-092651-evaluate-despicable-md-config/ | created | Companion directory with working files |

## Verification

| Phase | Result |
|-------|--------|
| Code Review | Skipped (no code produced) |
| Test Execution | Skipped (no tests applicable) |
| Deployment | Skipped (not requested) |
| Documentation | Skipped (consultation only) |

<details>
<summary>Working Files (10 files)</summary>

Companion directory: [2026-02-12-092651-evaluate-despicable-md-config/](./2026-02-12-092651-evaluate-despicable-md-config/)

- [Original Prompt](./2026-02-12-092651-evaluate-despicable-md-config/prompt.md)
- [Phase 1: Meta-plan](./2026-02-12-092651-evaluate-despicable-md-config/phase1-metaplan.md)
- [Phase 2: gru](./2026-02-12-092651-evaluate-despicable-md-config/phase2-gru.md)
- [Phase 2: lucy](./2026-02-12-092651-evaluate-despicable-md-config/phase2-lucy.md)
- [Phase 2: margo](./2026-02-12-092651-evaluate-despicable-md-config/phase2-margo.md)
- [Phase 2: devx-minion](./2026-02-12-092651-evaluate-despicable-md-config/phase2-devx-minion.md)
- [Phase 2: software-docs-minion](./2026-02-12-092651-evaluate-despicable-md-config/phase2-software-docs-minion.md)
- [Phase 3: Synthesis](./2026-02-12-092651-evaluate-despicable-md-config/phase3-synthesis.md)
- [Phase 3.5: security-minion](./2026-02-12-092651-evaluate-despicable-md-config/phase3.5-security-minion.md)
- [Phase 3.5: software-docs-minion](./2026-02-12-092651-evaluate-despicable-md-config/phase3.5-software-docs-minion.md)

</details>

## Consultation Findings

### The Question

Should consuming projects have dedicated DESPICABLE.md and DESPICABLE.local.md files for framework-specific configuration of despicable-agents?

### Recommendation: Reject (with re-introduction trigger)

**Do not introduce DESPICABLE.md or DESPICABLE.local.md.** Consuming projects should configure despicable-agents behavior via a `## Despicable Agents` section in their existing CLAUDE.md (public) and CLAUDE.local.md (private).

**Re-introduction trigger**: Revisit when 2+ consuming projects demonstrate configuration needs that CLAUDE.md sections cannot serve, OR when Claude Code adopts AGENTS.md support (whichever comes first).

### Arguments For Rejection (4 specialists)

| Argument | Source | Strength |
|----------|--------|----------|
| Zero consuming projects -- no demonstrated demand | margo | Decisive |
| Decisions 26 + 27 set direct YAGNI precedent this week | margo | Strong |
| CLAUDE.md auto-loaded; DESPICABLE.md needs explicit discovery | gru, devx-minion | Strong |
| Industry consolidating config (AGENTS.md standard) | gru | Strong |
| All 3 config use cases already work via CLAUDE.md | lucy, devx-minion | Strong |
| Convention fragmentation -- no crisp boundary between files | lucy | Strong |
| 7 complexity points vs. 0 for CLAUDE.md sections | margo | Strong |
| Config options either have low utility or are dangerous | devx-minion | Moderate |

### Arguments For Adoption (1 specialist)

| Argument | Source | Strength |
|----------|--------|----------|
| Separation of concerns -- framework config separate from general | software-docs-minion | Moderate |
| Better discoverability -- file is visible in project root | software-docs-minion | Moderate |
| Better reusability -- copy across projects without extraction | software-docs-minion | Weak |
| Cleaner git history -- framework changes isolated | software-docs-minion | Weak |
| Progressive disclosure -- learn CLAUDE.md first, then DESPICABLE.md | software-docs-minion | Weak |

### Why the Dissent Did Not Prevail

The separation-of-concerns argument is valid in principle but disproportionate for the current configuration surface:

1. **Volume mismatch**: The despicable-agents config is a few preferences (agent exclusions, technology spin, orchestration tweaks) -- not a complex plugin architecture. This is Prettier-scale config (fits in package.json), not ESLint-scale config (needs its own file).

2. **Discovery asymmetry**: DESPICABLE.md is discoverable only if you already know it exists. CLAUDE.md is already the place every developer looks for project-level AI config. A section in a known file beats a new file you must learn about.

3. **Platform advantage**: CLAUDE.md is auto-loaded by Claude Code with zero infrastructure. DESPICABLE.md requires explicit Read calls -- either in all 27 agents (fragile, bloated) or only in nefario (single point of failure). The auto-loading advantage is structural and hard to overcome.

4. **Timing**: The ecosystem is moving toward fewer config files (AGENTS.md consolidation), not more. Introducing a new file now means potential migration twice (DESPICABLE.md -> AGENTS.md) instead of once (CLAUDE.md section -> AGENTS.md section).

### Configuration Options Utility Assessment

| Option | Utility | Recommendation |
|--------|---------|----------------|
| Agent exclusion | Low | Nefario already selects by task relevance. A CLAUDE.md note like "backend-only project, no frontend" achieves the same result |
| Domain spin | Medium | Already works via CLAUDE.md technology preferences. Just document the pattern with examples |
| Orchestration overrides | Low to Dangerous | Phase 3.5 skip and ALWAYS reviewer exclusion undermine governance. Runtime overrides via user commands already cover legitimate cases |
| Skill preferences | Already exists | Decision 28 Tier 1 routes through CLAUDE.md already |

### Recommended Alternative: CLAUDE.md Section Convention

```markdown
## Despicable Agents

### Project Context
- Backend-only Python API; no frontend or web UI
- Uses PostgreSQL and Redis; deployed on Kubernetes

### Agent Preferences
- Prefer security-minion review for all PRs touching auth/
- Skip sitespeed-minion (no web frontend in this project)

### Orchestration
- Default mode: PLAN (always require approval before execution)
- Report directory: docs/reports/
```

This approach:
- Is automatically read by Claude Code (zero infrastructure)
- Is visible to all Claude Code agents (not just despicable-agents)
- Works today without any code changes
- Follows the AGENTS.md philosophy ("just Markdown, use any headings")
- Migrates trivially when AGENTS.md support arrives in Claude Code

### Open Items (Not In Scope of This Consultation)

1. **ALWAYS reviewer protection**: Lucy identified that CLAUDE.md/CLAUDE.local.md can currently instruct exclusion of mandatory Phase 3.5 reviewers with no enforcement. This needs a runtime guardrail in nefario (separate task).

2. **Consuming-projects guide**: When external projects begin adopting the toolkit, a short guide showing how to use CLAUDE.md sections for framework config would be valuable. Not needed until there are actual consumers.

3. **AGENTS.md migration**: When Claude Code adopts AGENTS.md support, the `## Despicable Agents` section convention should be evaluated for migration. The section-based approach migrates trivially.
