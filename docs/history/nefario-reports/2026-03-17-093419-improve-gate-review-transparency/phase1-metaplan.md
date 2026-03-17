# Meta-Plan: Improve Gate Review Transparency

## Problem Statement

Nefario's approval gates (Team, Reviewer, Execution Plan, mid-execution) present
task lists, agent names, and counts -- but NOT the reasoning, trade-offs,
rejected alternatives, or conflict resolutions that led to the plan. The user
must navigate to scratch directory files to understand what the team actually
discussed and decided. The gates are oriented toward "here's what we'll do"
rather than "here's what we debated and why."

The WRL project's evolution log format (particularly `decisions.md` and
`process.md`) demonstrates a pattern where every decision is self-contained:
what was chosen, what was rejected, and why -- including which specialists
argued which positions and how conflicts were resolved. This transparency is
currently achieved only retroactively (in reports), not at the moment the user
needs to make a decision.

## Scope

**In scope**:
- Team Approval Gate (Phase 1): how specialist selection rationale is surfaced
- Reviewer Approval Gate (Phase 3.5): how discretionary reviewer selection is justified
- Execution Plan Approval Gate (Phase 3.5 -> Phase 4): how synthesis decisions,
  conflict resolutions, and rejected alternatives are presented
- Mid-execution Approval Gates (Phase 4): how deliverable decisions and rationale
  are presented to the user
- The gate format specifications in SKILL.md and AGENT.md
- The data flow: what information specialists/synthesis/reviewers produce and how
  it reaches the gate presentation

**Out of scope**:
- The WRL evolution log format itself (that is a project-specific convention)
- Post-execution phases (5-8)
- Nefario execution report format (that is retroactive documentation)
- Changes to specialist agent prompts (AGENT.md files for minions)
- Changes to the Phase 2 specialist consultation process
- Changes to the Phase 3 synthesis output format (unless needed to feed gates)

## Analysis

### Current Information Flow

```
Phase 2 specialists --> produce recommendations, risks, conflicts
                            |
Phase 3 synthesis --> resolves conflicts, produces delegation plan
                            |
                        [CONFLICT RESOLUTIONS, RATIONALE written to
                         scratch/phase3-synthesis.md -- NOT surfaced]
                            |
Phase 3.5 reviewers --> APPROVE/ADVISE/BLOCK verdicts
                            |
                        [ADVISER reasoning written to
                         scratch/phase3.5-*.md -- partially surfaced
                         via CHANGE/WHY fields in advisories]
                            |
Execution Plan Gate --> shows: task list, advisory summaries, review
                       counts. Missing: WHY this plan shape, what was
                       rejected, where specialists disagreed
                            |
Phase 4 gates --> shows: DELIVERABLE, RATIONALE, rejected alternative
                  Missing: specialist arguments, synthesis reasoning,
                  connection to planning phase debates
```

### The WRL Pattern (What Works)

WRL's `decisions.md` succeeds because each decision entry has:
1. **Decision**: what was chosen
2. **Alternatives considered**: what was rejected (with who proposed it)
3. **Rationale**: why this choice wins
4. **Rejected**: explicit statement of why alternatives lost

WRL's `process.md` adds the narrative: which specialists argued what, where
they disagreed, how conflicts were resolved, and what the human changed.

### The Gap

The gap is NOT that nefario lacks this information -- it produces it during
synthesis (conflict resolutions, rationale, rejected alternatives). The gap is
that this information does not flow through to the gate presentation. It stays
in scratch files that the user would need to navigate to find.

Specific gaps by gate type:
1. **Team Gate**: Shows agent names + 1-line rationale. Missing: why other agents
   were NOT selected, what trade-offs were made in team composition.
2. **Reviewer Gate**: Shows discretionary picks + rationale. This gate is
   actually reasonably transparent already (plan-grounded rationales required).
3. **Execution Plan Gate**: Shows tasks + advisories. Missing: synthesis
   conflict resolutions, key design decisions, rejected plan structures,
   specialist disagreements that shaped the plan.
4. **Mid-execution Gates**: Have the best format (RATIONALE + Rejected
   alternative). But these are post-hoc (agent already did the work). The
   decisions that SHAPED the plan are invisible.

## Planning Consultations

### Consultation 1: Gate Interaction Design

- **Agent**: ux-strategy-minion
- **Planning question**: The Execution Plan Approval Gate currently presents
  25-40 lines of task list, advisories, and review summary. The user needs to
  also see: (a) key design decisions from synthesis (conflict resolutions,
  rejected alternatives), (b) specialist disagreements that shaped the plan,
  and (c) enough context to make a meaningful approve/reject decision. How
  should this additional information be layered into the gate without
  overwhelming the user? Consider: progressive disclosure depth, what belongs
  in the gate vs. linked detail, cognitive load at the decision point, and
  the difference between "scanning for anomalies" and "understanding rationale."
  Reference the WRL decisions.md format as a target for decision self-containment.
- **Context to provide**: Current gate formats from SKILL.md (Team Gate at
  lines 482-600, Reviewer Gate at lines 999-1108, Execution Plan Gate at
  lines 1377-1500, mid-execution gates at lines 1600-1725). WRL decisions.md
  examples (0025-rfc3161-timestamps, 0027-dual-screenshot-consent). The
  12-18 line budget for mid-execution gates and 25-40 line budget for the
  execution plan gate.
- **Why this agent**: ux-strategy-minion designs information architecture for
  decision points. The core challenge is presenting complex multi-agent
  reasoning within the cognitive constraints of an approval gate. This is a
  user journey design problem: what does the user need to see, in what order,
  to make a confident decision?

### Consultation 2: Prompt Engineering for Decision Surfacing

- **Agent**: ai-modeling-minion
- **Planning question**: The nefario synthesis phase (MODE: SYNTHESIS in
  AGENT.md) produces conflict resolutions, rationale, and rejected alternatives
  -- but this information is structured for the delegation plan, not for
  user-facing gate presentation. What changes are needed to the synthesis
  output format and the SKILL.md gate presentation logic to ensure that
  decision rationale flows from synthesis through to the gate? Consider:
  (a) should synthesis produce a separate "decisions summary" block that
  gates can directly include? (b) should the CONDENSE lines preserve
  decision rationale? (c) how should the reviewer verdict format feed
  into the execution plan gate's decision context? The goal is that the
  calling session has the information it needs to populate a richer gate
  without re-reading scratch files.
- **Context to provide**: AGENT.md synthesis output format (lines ~495-575),
  SKILL.md Phase 3 synthesis handling, SKILL.md Execution Plan Approval Gate
  format, CONDENSE line patterns. The current flow where synthesis writes to
  scratch and the gate reads task list + advisory summaries but not conflict
  resolutions or design decisions.
- **Why this agent**: ai-modeling-minion understands prompt engineering and
  multi-agent data flow. The challenge is structural: how to modify the
  nefario AGENT.md synthesis output and the SKILL.md gate presentation so that
  decision rationale is preserved through context compaction and available at
  gate time. This is an agent architecture problem, not just a formatting one.

### Consultation 3: Governance Alignment

- **Agent**: lucy
- **Planning question**: The proposed change adds decision rationale (conflict
  resolutions, rejected alternatives, specialist disagreements) to approval
  gates. Does this align with the project's intent that gates are "anomaly
  detection" checkpoints (user scans for surprises), or does it shift gates
  toward "full decision briefings" (user evaluates reasoning)? The AGENT.md
  describes gates as "progressive-disclosure decision briefs" where "most
  approvals should be decidable from the first two layers." Adding synthesis
  reasoning may change what "the first two layers" contain. Is this intent
  drift, or is it fulfilling the original intent that was under-specified?
  Also: the mid-execution gate format already has RATIONALE and
  "Rejected: alternative and why" -- should the execution plan gate converge
  toward this same pattern?
- **Context to provide**: AGENT.md gate classification and decision brief
  format (lines ~308-425). The stated gate purpose: "progressive-disclosure
  decision brief" and "most approvals should be decidable from the first two
  layers." Current SKILL.md gate formats. The WRL process.md pattern for
  comparison.
- **Why this agent**: lucy ensures changes align with the project's stated
  intent and conventions. The core question is whether enriching gates with
  decision rationale is fulfilling the AGENT.md's promise of "decision briefs"
  or drifting toward a different gate philosophy. Lucy's judgment on intent
  alignment determines whether this is an enhancement or a scope change.

### Consultation 4: Software Documentation Impact

- **Agent**: software-docs-minion
- **Planning question**: If gate presentations are enriched with decision
  rationale, how does this affect: (a) the nefario execution report template
  (TEMPLATE.md), which currently has "Key Design Decisions" and "Decisions"
  sections that may overlap with gate content, (b) the orchestration
  documentation (docs/orchestration.md), which describes the gate workflow,
  and (c) the AGENT.md gate specification sections? Identify which
  documentation artifacts need updates and whether the enriched gate format
  creates redundancy with the report format. Also assess whether the
  WRL-style evolution log pattern (decisions.md + process.md) should be
  referenced as an architectural influence in the docs.
- **Context to provide**: Report template (TEMPLATE.md), docs/orchestration.md,
  AGENT.md gate sections, current gate format in SKILL.md. The relationship
  between gate decision briefs and report "Decisions" section.
- **Why this agent**: software-docs-minion maintains documentation coherence.
  Enriching gates creates potential redundancy with existing documentation
  formats (reports, ARCHITECTURE.md, docs/orchestration.md). This agent
  ensures the change is documented and that the various documentation layers
  remain coherent rather than duplicative.

## Cross-Cutting Checklist

- **Testing**: Exclude test-minion from planning. The deliverables are prompt
  engineering artifacts (AGENT.md, SKILL.md) with no executable test
  infrastructure. Test-minion will participate in Phase 3.5 review as a
  mandatory reviewer.
- **Security**: Exclude security-minion from planning. Gate transparency changes
  do not introduce attack surface, handle auth, or process user input beyond
  what gates already do. security-minion participates in Phase 3.5 as mandatory
  reviewer.
- **Usability -- Strategy**: INCLUDED as Consultation 1 (ux-strategy-minion).
  Planning question: How to layer decision rationale into gate presentations
  without overwhelming the user.
- **Usability -- Design**: Exclude ux-design-minion and accessibility-minion
  from planning. Gates are CLI text output, not visual UI components. The
  design challenge is information architecture (ux-strategy), not visual
  hierarchy or WCAG compliance.
- **Documentation**: INCLUDED as Consultation 4 (software-docs-minion).
  Planning question: Documentation impact assessment across TEMPLATE.md,
  orchestration.md, AGENT.md.
- **Observability**: Exclude observability-minion and sitespeed-minion. No
  runtime components, no production services, no web-facing output.

## Anticipated Approval Gates

1. **Gate format specification** (likely MUST gate): The revised gate format
   in SKILL.md defines what all gates look like going forward. Hard to reverse
   (downstream execution depends on it), high blast radius (affects every
   future orchestration). User should review the format before it is committed.

2. **AGENT.md synthesis output changes** (likely MUST gate if synthesis format
   changes): If the synthesis output format in AGENT.md is modified to produce
   a "decisions summary" block, this changes nefario's core behavior. Hard to
   reverse, high blast radius.

Single-gate consolidation is possible: if the format specification and synthesis
changes are tightly coupled, present as one gate. Target: 1-2 gates total.

## Rationale

**Why ux-strategy-minion**: This is fundamentally an information design problem.
The user is making a decision at the gate -- what information do they need, in
what order, at what depth? ux-strategy-minion designs decision points and
cognitive load management.

**Why ai-modeling-minion**: The information exists in the system but does not
flow to where the user sees it. This is a prompt engineering and agent
architecture problem: modifying synthesis output format, CONDENSE preservation,
and gate rendering logic in SKILL.md and AGENT.md.

**Why lucy**: Intent alignment is critical. The AGENT.md explicitly describes
gates as "anomaly detection" with progressive disclosure. Adding decision
rationale could either fulfill or contradict this intent depending on how it
is done. Lucy's judgment prevents well-intentioned changes from drifting the
gate philosophy.

**Why software-docs-minion**: Documentation coherence. The change touches
AGENT.md, SKILL.md, TEMPLATE.md, and docs/orchestration.md. Without
documentation planning, these artifacts will drift apart.

**Why NOT devx-minion**: devx-minion was involved in the previous gate
improvement (2026-02-10-170603-improve-exec-plan-approval-gate) for SKILL.md
formatting. This time the challenge is information architecture and data flow,
not CLI formatting. ux-strategy-minion and ai-modeling-minion cover the
relevant expertise.

**Why NOT margo**: margo's YAGNI/KISS judgment is valuable but better applied
at review time (Phase 3.5) than at planning time. The risk of over-engineering
the gate format is real, but ux-strategy-minion's cognitive load analysis and
lucy's intent alignment check serve as planning-phase guardrails.

## External Skill Integration

### Discovered Skills

| Skill | Location | Classification | Domain | Recommendation |
|-------|----------|---------------|--------|----------------|
| despicable-lab | .claude/skills/despicable-lab/ | ORCHESTRATION | Agent rebuild pipeline | Not relevant -- no agent rebuilds needed |
| despicable-statusline | .claude/skills/despicable-statusline/ | LEAF | Status line config | Not relevant -- no status line changes |
| despicable-prompter | skills/despicable-prompter/ | LEAF | Task briefing generation | Not relevant -- no briefing generation |
| nefario | skills/nefario/ | ORCHESTRATION | Orchestration workflow | The target of changes -- referenced as context, not invoked |

### Precedence Decisions

No precedence conflicts. The discovered skills operate in different domains
than the task at hand. The nefario skill is the target artifact being modified,
not a tool being invoked during planning.
