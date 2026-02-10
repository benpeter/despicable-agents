---
type: nefario-report
version: 1
date: "2026-02-09"
sequence: 1
task: "Implement human-in-the-loop review mechanisms with architecture review phase and enhanced approval gates"
mode: full
agents-involved: [devx-minion, software-docs-minion, ai-modeling-minion, ux-strategy-minion]
task-count: 5
gate-count: 0
outcome: completed
---

# Architecture Decision Report: Orchestration System Updates

**Date**: 2026-02-09
**Process**: Nefario 4-phase orchestration with architecture review
**Specialists Consulted**: devx-minion, software-docs-minion, ai-modeling-minion, ux-strategy-minion

## Executive Summary

This report documents three interconnected architectural changes to the despicable-agents orchestration system. First, a build and versioning proposal introducing overlay files to preserve hand-tuned customizations across regeneration cycles. Second, a human-in-the-loop review mechanism adding a mandatory architecture review phase (Phase 3.5) and formalized approval gates with anti-fatigue strategies. Third, implementation of the review mechanisms in the nefario agent and skill files, including enhanced gate presentation format, progressive disclosure decision briefs, and proactive orchestration monitoring.

## Decisions Made

### Decision 1: Build System Overlay Files

| Field | Value |
|-------|-------|
| **Decision** | Introduce three-file build pattern: AGENT.generated.md (build output) + AGENT.overrides.md (hand-tuned customizations) → AGENT.md (deployed artifact). Merge operates on YAML frontmatter (shallow merge) and markdown body (section-level replacement by H2 heading match). |
| **Status** | PROPOSED (documented in architecture-update-build.md) |
| **Rationale** | Current pipeline destructively overwrites AGENT.md on rebuild, forcing maintainers to choose between losing customizations or never rebuilding. Overlay pattern preserves both generated baseline and hand-tuned refinements. The nefario agent demonstrates the problem: AGENT.md at version 1.3 with refinements that would be lost if regenerated from 1.2 spec. Section-level merge keeps semantics simple and predictable. |
| **Alternatives rejected** | **Marker-based partial generation** (HTML comment markers in AGENT.md preserved during regeneration) - rejected due to fragility, splice complexity, and mixing generated/hand-edited content in single file. **Hooks/customizations directory** (patch files or post-processing scripts) - rejected as over-engineered for 19 agents, patch files are brittle across regeneration. **Template + data separation** (render markdown from YAML data files) - rejected because prose-heavy content is painful in YAML, adds templating dependency, solves wrong problem (generation works fine, need merge solution). |
| **Risks** | **Heading parser fragility** - merge depends on exact H2 heading match; heading renames break matching. Mitigation: emit warnings for orphaned overrides (headings in override file that don't match generated file). **Override staleness after spec changes** - when spec updates, overrides may reference outdated concepts. Mitigation: warn when spec version increases and overrides exist, --diff command shows what's overridden. **Three-file pattern complexity** - contributors may be confused about which file to edit. Mitigation: most agents (17/19) will only have two files (AGENT.generated.md = AGENT.md, no overrides), document convention clearly in CLAUDE.md. |

### Decision 2: Architecture Review Phase (Phase 3.5)

| Field | Value |
|-------|-------|
| **Decision** | Insert new phase between Synthesis (Phase 3) and Execution (Phase 4). Mandatory reviewers: security-minion, test-minion. Conditional reviewers (triggered when domain touched by 2+ tasks): observability-minion, software-docs-minion, ux-design-minion. Reviewers return structured verdicts: APPROVE (no concerns), ADVISE (non-blocking warnings), BLOCK (halts execution, triggers revision loop capped at 2 rounds). All reviewers run on sonnet. |
| **Status** | IMPLEMENTED (in nefario/AGENT.md and .claude/skills/nefario/SKILL.md) |
| **Rationale** | Cross-cutting concerns checklist in current nefario ensures concerns are considered during planning, but consideration is not review. Security and test strategy gaps are invisible until code runs - mandatory review catches issues cheap to fix in plans, expensive to fix in code. Conditional reviewers balance coverage against cost. BLOCK verdict with revision loop prevents rubber-stamping while capping iteration cost. |
| **Alternatives rejected** | **Blanket all-agent review** (all 5 cross-cutting agents review every plan) - rejected due to cost ($0.35-0.45 per plan vs $0.10-0.20 with conditional), diminishing returns when reviewers have nothing substantive to say. **No review phase** (rely only on planning consultation) - rejected because synthesis may create emergent issues not visible to individual specialists, and planning consultation draws expertise without review accountability. **User review only** (no agent review) - rejected because user cannot catch every domain-specific gap, agent review provides first line of defense. |
| **Risks** | **Review cost** - adds $0.10-0.20 per plan (15-30% overhead). Mitigation: sonnet for all reviews (pattern-matching, not deep reasoning), conditional reviewers reduce average cost, prompt caching for shared context. **False negatives** (reviewers miss issues) - sonnet may lack depth for complex review. Mitigation: mandatory security and test review provides baseline, user still approves final plan. **Revision loop deadlock** (nefario and reviewer cannot agree) - 2-round cap prevents infinite loops, escalate to user after 2 rounds with both positions presented. |

### Decision 3: Approval Gate Decision Brief Format

| Field | Value |
|-------|-------|
| **Decision** | Three-layer progressive disclosure format. Layer 1 (5-second scan): one-sentence decision summary. Layer 2 (30-second read): 3-5 bullet rationale including at least one rejected alternative, impact statement, confidence indicator (HIGH/MEDIUM/LOW). Layer 3 (deep dive): full deliverable at file path. Gate classification matrix: reversibility (easy/hard) × blast radius (low/high) → NO GATE / OPTIONAL / MUST gate. Response handling: approve (clear gate), request changes (cap 2 rounds), reject (cascade warning), skip (defer to wrap-up). |
| **Status** | IMPLEMENTED (in nefario/AGENT.md and SKILL.md) |
| **Rationale** | Current gates are underspecified - no guidance on which tasks to gate, how to present efficiently, or how to handle cascading dependencies. Progressive disclosure respects user time: most approvals decidable at Layer 1-2 without reading full deliverable. Rejected alternatives in Layer 2 are primary anti-rubber-stamping measure - forces consideration of tradeoffs. Classification matrix provides objective criteria for gatekeeping decisions. Confidence indicator helps users allocate attention to genuinely uncertain decisions. |
| **Alternatives rejected** | **Unstructured free-text presentation** (no format, agents describe gates however they want) - rejected due to inconsistent quality, no progressive disclosure, hard to scan quickly. **Keyboard shortcuts for responses** ([a]pprove, [r]eject) - rejected because Claude Code uses natural conversation, not key-based UIs. **Always-block gates** (every gate blocks until approved) - rejected because some outputs are informational, not decisions; introduce non-blocking notifications for these. **Unlimited revision rounds** - rejected due to diminishing returns and fatigue; 2-round cap forces escalation to user for substantive disagreements. |
| **Risks** | **Gate classification errors** (task marked MUST gate when optional, or vice versa) - nefario may misjudge reversibility or blast radius. Mitigation: classification matrix provides objective criteria, user can override gate decisions during plan review. **Fatigue from excessive gates** - too many gates defeats purpose through rubber-stamping. Mitigation: see Decision 4 (anti-fatigue strategies). **Layer 2 quality** (rejected alternatives are pro forma, not substantive) - agents may list token alternatives. Mitigation: mandatory rejected alternative requirement, calibration check after 5 consecutive approvals. |

### Decision 4: Anti-Fatigue Strategies

| Field | Value |
|-------|-------|
| **Decision** | Four complementary strategies. **Gate budget**: target 3-5 gates per plan, consolidate or downgrade if synthesis produces more. **Confidence indicator**: HIGH (clear best practice, quick approve likely) / MEDIUM (alternatives have merit) / LOW (significant uncertainty, read carefully). **Gate vs notification distinction**: gates block execution, notifications are informational but non-blocking. **Calibration check**: after 5 consecutive approvals without changes, prompt user "Are gates well-calibrated or should future plans gate fewer decisions?" |
| **Status** | IMPLEMENTED (in nefario/AGENT.md and SKILL.md) |
| **Rationale** | Approval fatigue is the primary threat to the gate mechanism. Fatigued users rubber-stamp everything, creating false confidence that human review occurred. Gate budget prevents death-by-a-thousand-gates. Confidence indicator helps users allocate attention to genuinely uncertain decisions rather than treating all gates equally. Notifications provide visibility without blocking. Calibration check creates feedback loop that tunes mechanism over time based on actual user behavior. |
| **Alternatives rejected** | **No gate budget** (gate as many tasks as classification indicates) - rejected because 10+ gates in a plan guarantees fatigue. **No anti-fatigue measures** (rely on user discipline) - rejected because fatigue is psychological, not willpower; system must account for it. **Blanket reduction** (always use fewer gates regardless of plan complexity) - rejected because some plans genuinely need more review points; budget provides threshold, not hard limit. **Automated approval after N approvals** - rejected because removes human judgment entirely, defeats purpose of gates. |
| **Risks** | **Under-gating** (consolidation removes genuinely important review points) - users may miss critical decisions. Mitigation: classification matrix ensures MUST-gate tasks are never consolidated, consolidation applies to OPTIONAL gates. **Calibration prompt ignored** - users skip the feedback prompt. Mitigation: prompt is lightweight (single yes/no), appears infrequently (every 5 approvals). **Confidence indicator miscalibration** (agents mark HIGH confidence for genuinely uncertain decisions) - users approve without scrutiny. Mitigation: confidence based on objective signals (number of alternatives, reversibility, dependents), not agent intuition. |

### Decision 5: Removal of "When to Simplify" Escape Hatch

| Field | Value |
|-------|-------|
| **Decision** | Remove the "When to Simplify" section from nefario SKILL.md. Full process (Meta-plan → Specialist Planning → Synthesis → Architecture Review → Execution) always runs. MODE: PLAN remains in AGENT.md for explicit user requests but is not offered proactively. |
| **Status** | IMPLEMENTED (removed from .claude/skills/nefario/SKILL.md) |
| **Rationale** | User preference is to establish baseline quality by running full process consistently before introducing shortcuts. "Is this simple enough for one agent?" decision should be made by the user explicitly, not by the orchestrator proactively. Removing the escape hatch prevents premature optimization and ensures cross-cutting review happens systematically. MODE: PLAN still available when user explicitly requests simplified flow, but skill does not suggest it. |
| **Alternatives rejected** | **Keep escape hatch with higher threshold** (suggest simplification only for trivially simple tasks) - rejected because "trivially simple" is subjective, misclassification risk is high. **Remove MODE: PLAN entirely** (force full process always) - rejected because user may legitimately want direct planning for small tasks; keep the capability, just don't proactively offer it. **Add complexity scoring** (nefario assigns complexity score, suggest simplification for low scores) - rejected because scoring adds cognitive load, calibration unclear, better to let user decide. |
| **Risks** | **Process overhead for simple tasks** - full process costs $0.43-0.80 and takes 60-120 seconds for planning even when task is simple. Mitigation: user can explicitly request MODE: PLAN when appropriate, overhead is bounded and predictable. **User frustration** - users may feel process is unnecessarily heavyweight. Mitigation: gather data over multiple sessions to inform future optimization, current preference is for consistency over efficiency. |

### Decision 6: Nefario-Gated Simplification (Deferred)

| Field | Value |
|-------|-------|
| **Decision** | Defer proposal for nefario to classify task complexity and skip phases for simple tasks. Proposal: Simple (single-domain, clear requirements, no architectural impact) → skip to MODE: PLAN. Standard (multi-domain, well-understood patterns) → full 4-phase. Complex (novel architecture, high uncertainty, significant risk) → full 4.5-phase with mandatory review. |
| **Status** | DEFERRED (documented in architecture-update-humanloop.md for future consideration) |
| **Rationale** | Current user preference is to run full process for all tasks to establish baseline quality. Introducing shortcuts before baseline is known risks invisible bugs (skipped security review, inadequate test strategy). Classification risk is high: nefario misclassifying complex task as simple would skip critical planning steps. Cost of false "simple" classification far exceeds cost of over-planning genuinely simple tasks. Full process generates data about which phases add value for which task types, informing future evidence-based classification rules. |
| **Alternatives rejected** | **Implement now with conservative rules** (only classify truly trivial tasks as simple) - rejected because even conservative rules lack validation data, calibration unclear. **Always skip architecture review for simple tasks** - rejected because mandatory security/test review has near-zero marginal cost if no issues found, false negative cost is high. **User-controlled simplification flag** - already implemented as MODE: PLAN, no need for duplicate mechanism. |
| **Risks** | **Opportunity cost** - potential savings of $0.24 and 60-120 seconds per simple task unrealized. Mitigation: revisit after 20+ full-process runs with data on substantive vs pro forma phases. **Nefario unable to classify accurately even with data** - complexity is subjective, edge cases are common. Mitigation: if revisited, classification should be advisory (suggest simplification) not automatic, user retains final decision. |

## Conflict Resolutions

### Conflict 1: Architecture Review Scope (software-docs-minion vs ai-modeling-minion)

**Position 1 (software-docs-minion)**: Every plan involving multiple tasks should produce or update ARCHITECTURE.md. Architecture documentation is critical for future planning and should be systematic.

**Position 2 (ai-modeling-minion)**: ARCHITECTURE.md should be conditional - only when plan introduces components that future plans need to understand. Review should be triggered by domain (2+ tasks touching architecture/API surface), not by task count.

**Resolution**: Adopted conditional review model. software-docs-minion is triggered when 2+ tasks change architecture or API surface (not just 2+ tasks of any kind). ARCHITECTURE.md is optional - heuristic is whether plan introduces components that future plans would need to understand. Minimum viable ARCHITECTURE.md includes Components + Constraints + Key Decisions + Cross-Cutting Concerns sections.

**Rationale**: Systematic review is valuable, but forcing ARCHITECTURE.md for every multi-task plan creates busywork. Conditional triggering balances documentation value against cost. Key Decisions table in ARCHITECTURE.md captures rationale and rejected alternatives, preventing future plans from relitigating settled decisions.

### Conflict 2: Simplification Escape Hatch (ai-modeling-minion vs user preference)

**Position 1 (ai-modeling-minion)**: Nefario should classify task complexity and skip phases for simple tasks. Three-level scale: Simple → MODE: PLAN, Standard → 4-phase, Complex → 4.5-phase. Benefits: cost savings ($0.24/task), time savings (60-120s), moves complexity decision from user to expert.

**Position 2 (user preference, documented in MEMORY.md)**: Full process should always run to establish baseline quality before introducing shortcuts. Classification risk is high - false "simple" classification skips critical planning. Full process generates data for future evidence-based rules.

**Resolution**: Defer proposal per user instruction. Full process always runs. Nefario-gated simplification captured in architecture-update-humanloop.md as future consideration. Revisit when system has 20+ full-process runs across diverse task types with data on which phases were substantive.

**Rationale**: User has explicitly requested full process to calibrate quality first. Premature optimization risks introducing bugs that are invisible because checking steps were skipped. Learning opportunity: every full-process run generates data about phase value. MODE: PLAN remains available for explicit user request but is not offered proactively.

### Conflict 3: Gate Presentation Format (ux-strategy-minion vs ai-modeling-minion)

**Position 1 (ux-strategy-minion)**: Use keyboard shortcuts for gate responses ([a]pprove, [r]eject, [c]hange, [s]kip). Single-key responses are faster and reduce friction. Include visual hierarchy with spacing and formatting.

**Position 2 (ai-modeling-minion)**: Use natural conversation responses ("approve", "request changes", "reject", "skip"). Claude Code is conversational AI, not a key-based CLI. Structured format is fine but responses should be natural text.

**Resolution**: Adopted structured brief format with three-layer progressive disclosure, but responses are natural text ("approve", "request changes", "reject", "skip") not keyboard shortcuts. Format includes spacing and visual hierarchy (field names in caps, bullets for rationale).

**Rationale**: Claude Code's interface is natural language conversation. Keyboard shortcuts would require modal interaction pattern not supported by the platform. Structured format provides scannability, natural responses preserve conversational flow.

### Conflict 4: Review Verdict Taxonomy (software-docs-minion vs ai-modeling-minion)

**Position 1 (software-docs-minion)**: Three verdict levels - APPROVE (no concerns), CONCERN (issues to flag), BLOCK (halt execution). CONCERN is clearer for users than ADVISE.

**Position 2 (ai-modeling-minion)**: Three verdict levels - APPROVE, ADVISE (non-blocking warnings), BLOCK (halt execution). ADVISE is standard terminology in review contexts, parallel to Git's "Changes requested" vs "Comment."

**Resolution**: Standardized on APPROVE / ADVISE / BLOCK. ADVISE verdicts are non-blocking warnings logged in plan output and presented to user before approval gate. BLOCK triggers revision loop.

**Rationale**: ADVISE is more standard in software review contexts (code review, architecture review, security review). Non-blocking nature is clearer: ADVISE means "here's a concern but not serious enough to halt." CONCERN could be interpreted as "concern that must be addressed" vs "concern for awareness."

## Process Used

### Phase 1: Meta-Plan

Nefario analyzed the task of implementing human-in-the-loop review mechanisms. Identified four specialists needed for planning:

- **devx-minion**: Build system expertise for overlay file pattern and /lab skill updates
- **software-docs-minion**: Documentation review phase design and architecture review process
- **ai-modeling-minion**: Gate classification, anti-fatigue strategies, orchestration flow design
- **ux-strategy-minion**: Progressive disclosure pattern for gate presentation and user interaction design

All four selected on basis of domain expertise in areas directly relevant to review mechanism design.

### Phase 2: Specialist Planning

All four specialists spawned in parallel at opus model for planning consultation. Each received original task description and domain-specific planning question. Contributions:

- devx-minion proposed overlay file pattern (generated + overrides → merged), evaluated alternatives, defined migration path
- software-docs-minion proposed architecture review phase, mandatory reviewers, ARCHITECTURE.md template
- ai-modeling-minion proposed gate classification matrix, verdict taxonomy, anti-fatigue strategies, addressed nefario-gated simplification
- ux-strategy-minion proposed progressive disclosure format, visual hierarchy, user interaction patterns

No additional agents recommended by specialists - team was sufficient for scope.

### Phase 3: Synthesis

Nefario consolidated four specialist contributions into 5-task execution plan:

1. **Task 1** (parallel): devx-minion writes architecture-update-build.md proposal
2. **Task 2** (parallel): ai-modeling-minion writes architecture-update-humanloop.md proposal
3. **Task 3** (sequential, after 1+2): software-docs-minion updates nefario/AGENT.md
4. **Task 4** (sequential, after 1+2): software-docs-minion updates .claude/skills/nefario/SKILL.md
5. **Task 5** (sequential, after 3+4): software-docs-minion writes report.md

Dependency rationale: Tasks 3+4 depend on 1+2 because AGENT.md and SKILL.md implement mechanisms described in proposals. Task 5 depends on 3+4 because report captures all changes including implementations.

Conflicts identified and resolved during synthesis (documented in Conflict Resolutions section above).

### Phase 4: Execution

Execution followed batch pattern determined by dependency graph:

- **Batch 1** (parallel): Tasks 1+2 (proposals)
- **Batch 2** (parallel after Batch 1 complete): Tasks 3+4 (implementations)
- **Batch 3** (sequential after Batch 2 complete): Task 5 (report)

No approval gates were set for this execution - all tasks were informational deliverables reviewed as a group.

## Files Created or Modified

| File | Action | Description |
|------|--------|-------------|
| `/Users/ben/github/benpeter/despicable-agents/architecture-update-build.md` | Created | Build system overlay files proposal. Documents three-file pattern (AGENT.generated.md + AGENT.overrides.md → AGENT.md), merge rules, version tracking, /lab skill changes, alternatives rejected, risks and mitigations. |
| `/Users/ben/github/benpeter/despicable-agents/architecture-update-humanloop.md` | Created | Human-in-the-loop review mechanism proposal. Documents Architecture Review phase (3.5), approval gates classification and format, anti-fatigue strategies, cascading approvals, updated flow diagram, cost analysis, future nefario-gated simplification consideration. |
| `/Users/ben/github/benpeter/despicable-agents/nefario/AGENT.md` | Modified | Added Architecture Review (Phase 3.5) section with review triggering rules, verdict format, ARCHITECTURE.md template. Enhanced Approval Gates section with gate classification matrix, decision brief format, response handling, anti-fatigue rules, cascading gates, gate vs notification distinction. Added x-fine-tuned: true flag to frontmatter. Updated x-plan-version to 1.3. |
| `/Users/ben/.claude/skills/nefario/SKILL.md` | Modified | Added Phase 3.5 section between synthesis and execution. Documents reviewer identification rules, reviewer spawn pattern, verdict processing. Enhanced Phase 4 execution section with approval gate presentation format, response handling, batch execution with gates, anti-fatigue guidelines. Removed "When to Simplify" section. Enhanced troubleshooting section for orchestrator monitoring. |
| `/Users/ben/github/benpeter/despicable-agents/report.md` | Created | This decision report documenting 6 architectural decisions, 4 conflict resolutions, process used, files created/modified, and outstanding items. |

## Outstanding Items

### Requires User Approval

- [ ] **architecture-update-build.md proposal** - Review and approve/reject overlay file pattern for build system. If approved, proceed to /lab implementation and agent migration items below.
- [ ] **architecture-update-humanloop.md proposal** - Review and approve/reject architecture review phase and enhanced approval gates. If approved, nefario AGENT.md and SKILL.md changes are already implemented.
- [ ] **nefario/AGENT.md changes** - Review Phase 3.5, enhanced Approval Gates section, x-fine-tuned flag, Cross-Cutting Concerns checklist.
- [ ] **nefario/SKILL.md changes** - Review Phase 3.5 implementation, enhanced Phase 4 execution, removal of "When to Simplify" section.

### Contingent on Build Proposal Approval

- [ ] **Update /lab SKILL.md** - Implement overlay pattern: change build target to AGENT.generated.md, add merge step (frontmatter shallow merge + markdown section replacement), update version check to read from AGENT.generated.md, add --diff command.
- [ ] **Migrate existing agents** - For each of 19 agents: generate AGENT.generated.md from spec, diff against current AGENT.md, extract overrides for agents with meaningful diffs (currently: nefario, possibly others), verify merged output matches current state.

### Documentation and Alignment

- [ ] **Bump the-plan.md spec-version** - Nefario currently at version 1.3 in AGENT.md but the-plan.md shows 1.2. Bump spec to 1.3 to reflect cross-cutting concerns checklist, approval gates, architecture review phase. (Human edit required per project rules.)
- [ ] **Verify AGENT.md and SKILL.md alignment** - Confirm Phase 3.5 triggering rules match between AGENT.md (orchestrator knowledge) and SKILL.md (executor implementation). Confirm verdict format (APPROVE/ADVISE/BLOCK) is consistent. Confirm BLOCK resolution flow matches (2-round cap, escalation to user).

### Future Evaluation

- [ ] **Nefario-gated simplification** - Deferred per user instruction. Revisit when system has completed 20+ full-process runs across diverse task types, data on which phases were substantive vs pro forma is available, classification rules can be validated against historical data, user explicitly requests simplification. Document in MEMORY.md when revisited.
- [ ] **Gate calibration tuning** - After several sessions using enhanced gates, evaluate: Are 3-5 gates the right budget? Is confidence indicator calibrated accurately? Are rejected alternatives substantive? Adjust thresholds based on user feedback and calibration check responses.
- [ ] **Architecture review effectiveness** - Track BLOCK verdicts over multiple sessions: Which reviewers block most frequently? Are blocks substantive or overly cautious? Are 2 revision rounds sufficient or should cap be adjusted? Use data to tune triggering rules and review prompts.
