## Domain Plan Contribution: software-docs-minion

### Recommendations

#### 1. The documentation artifacts form a layered system with distinct update needs

There are four documentation artifacts involved, each serving a different role in the information lifecycle:

| Artifact | Role | Audience | When read |
|----------|------|----------|-----------|
| SKILL.md gate format specs | Defines what the orchestrator renders at gates | Nefario (the agent) | During orchestration execution |
| AGENT.md synthesis output format | Defines what information synthesis produces (the data available to gates) | Nefario (the agent) | During synthesis |
| TEMPLATE.md report template | Defines how decisions are recorded post-hoc | Report readers, PR reviewers | After orchestration completes |
| docs/orchestration.md | Explains the gate mechanism to contributors and architects | Project contributors | During onboarding, architecture review |

The key insight: enriching gate presentations is primarily a SKILL.md change (rendering) backed by an AGENT.md change (data availability). The report template and orchestration docs are downstream consumers that need alignment but not fundamental redesign.

#### 2. The report template already has the right structure -- but "Key Design Decisions" and "Decisions" sections overlap

The current TEMPLATE.md has both:
- **Key Design Decisions** (lines 35-56): Non-gate design decisions with rationale and rejected alternatives, plus a Conflict Resolutions subsection
- **Decisions** (lines 190-200): Gate briefs with full rationale, rejected alternatives, confidence, and outcome

The template formatting rules (line 347) already clarify: "Key Design Decisions: Each decision as H4. Non-gate design decisions. For gate decisions, use the Decisions section instead."

This separation is correct in principle but creates a structural problem when gates are enriched: if gates now show the full reasoning (trade-offs, rejected alternatives, conflict resolutions) that was previously only reconstructable from scratch files, the report's "Decisions" section becomes a near-verbatim copy of what the user already saw and approved at the gate. The report should not parrot gate content back.

**Recommendation**: Keep both sections but redefine "Decisions" as a compilation section. The "Decisions" section should reference gate presentations rather than restate them. Specifically:
- Gate decisions in the report should be the gate brief as-presented (already retained in session context per SKILL.md line 2240-2242), not a rewritten version
- The "Key Design Decisions" section should cover decisions that emerged _outside_ of gates (e.g., synthesis conflict resolutions, cross-cutting trade-offs that were baked into the plan before gate presentation)
- Add a brief note in TEMPLATE.md clarifying this distinction: "Key Design Decisions covers non-gate decisions. Decisions covers gate outcomes. If a design decision was surfaced through a gate, record it in Decisions, not Key Design Decisions."

#### 3. The AGENT.md synthesis output format needs a "Decision Rationale" field per task

Currently, the synthesis output (AGENT.md lines 524-578) defines per-task fields including `Gate reason` (a one-liner: "why this deliverable needs user review before proceeding"). But the synthesis output does not include the actual decision rationale, rejected alternatives, or trade-offs that the gate should present. This information exists in the Conflict Resolutions and Risks and Mitigations sections of the synthesis output, but it is not structured per-task.

For enriched gates to work, the synthesis output needs per-task decision context. The mid-execution gate format (SKILL.md lines 1606-1626) already specifies a RATIONALE block with rejected alternatives -- but the data to populate it comes from unstructured narrative in the synthesis output.

**Recommendation**: Add a structured `Gate rationale` field to the synthesis task format that provides the data the gate will render. This keeps the information flow clean: synthesis produces structured data, SKILL.md renders it. The field should include:
- Key reasoning points (2-3 bullets)
- At least one rejected alternative with reason
- Confidence level (HIGH/MEDIUM/LOW)

This is an AGENT.md change, not a SKILL.md change. The SKILL.md gate format already supports this layout -- it just needs the data.

#### 4. The Execution Plan Approval Gate needs a "Decisions Preview" section

The Execution Plan Approval Gate (SKILL.md lines 1377-1500) currently shows: orientation, task list, advisories, risks/conflicts, review summary, and plan reference. It does NOT preview the decision rationale for upcoming mid-execution gates.

If the goal is transparency at gates, the plan approval gate should preview the key decisions the user will be asked to make during execution. This is analogous to a meeting agenda: you know what decisions are coming, not just what tasks will run.

**Recommendation**: Add an optional `UPCOMING DECISIONS:` block to the plan approval gate format, appearing between the task list and advisories. For each gated task, show the one-line decision and confidence level. This gives the user early visibility into what they will be deciding during execution, without bloating the gate (one line per gated task, so 3-5 lines max given the gate budget).

#### 5. docs/orchestration.md needs targeted updates, not a rewrite

The orchestration.md Section 3 (Approval Gates) is well-structured and comprehensive. Enriching gate presentations requires updates to:
- Section 3's "Decision Brief Format" (lines 436-468): Add mention of where rationale data comes from (synthesis output) and that it includes decision context beyond just the deliverable
- The anti-fatigue rules section should note that enriched rationale is what makes "rejected alternatives mandatory" actionable -- the rule already exists, but the mechanism to populate it needs documentation

These are incremental edits, not structural changes. The orchestration.md already describes the progressive disclosure model correctly.

#### 6. The information flow needs explicit documentation

Currently, the flow of decision information is implicit: synthesis produces a plan -> the plan gets reviewed -> gates present deliverables -> the report records outcomes. With enriched gates, the flow becomes more deliberate: synthesis produces structured decision rationale per task -> architecture review may modify it -> gates render it -> the report compiles it.

**Recommendation**: Add a brief "Decision Information Flow" subsection to orchestration.md Section 3, or to the SKILL.md data accumulation section (lines 2215-2273), that explicitly traces how decision rationale flows from synthesis through gates to reports. This prevents future drift where someone changes the synthesis format without updating the gate format, or vice versa.

### Proposed Tasks

#### Task 1: Update AGENT.md synthesis output format
- **What**: Add a `Gate rationale` structured field to each gated task in the synthesis output template (AGENT.md MODE: SYNTHESIS section)
- **Deliverables**: Updated AGENT.md with the new field definition and an example
- **Dependencies**: None (this is the data source; downstream tasks consume it)

#### Task 2: Update SKILL.md gate presentation formats
- **What**: Modify the mid-execution gate format to render the structured rationale from synthesis. Optionally add "UPCOMING DECISIONS" block to the Execution Plan Approval Gate format
- **Deliverables**: Updated SKILL.md gate format specifications
- **Dependencies**: Task 1 (needs the new synthesis field definition to know what data is available)

#### Task 3: Update TEMPLATE.md to clarify Key Design Decisions vs. Decisions distinction
- **What**: Add clarifying text to TEMPLATE.md formatting rules distinguishing gate decisions (Decisions section) from non-gate decisions (Key Design Decisions section). Adjust the Decisions section skeleton to indicate it compiles gate briefs as-presented
- **Deliverables**: Updated TEMPLATE.md
- **Dependencies**: Task 2 (needs to know the enriched gate format to define what the report compiles)

#### Task 4: Update docs/orchestration.md Section 3
- **What**: Update the Decision Brief Format description and add a brief "Decision Information Flow" paragraph tracing rationale from synthesis to gates to reports
- **Deliverables**: Updated orchestration.md
- **Dependencies**: Tasks 1-3 (should reflect the final format decisions)

### Risks and Concerns

1. **Gate bloat vs. transparency tension**: Enriching gates with decision rationale directly conflicts with the existing line budgets (12-18 lines for mid-execution gates, 25-40 for plan approval). The current format is already tight. Adding rationale, rejected alternatives, and conflict context could push gates past the comfort threshold and trigger approval fatigue -- the exact problem the anti-fatigue rules are designed to prevent. The implementation must respect line budgets by keeping enrichment within the existing RATIONALE block structure, not by adding new sections.

2. **Report redundancy**: If gates now contain full decision rationale, and the report's Decisions section records those same gate briefs, the report will contain the information twice (once in Phases narrative, once in Decisions). The TEMPLATE.md already has some structural tension between Key Design Decisions and Decisions; enriched gates could make this worse. The mitigation is clear delineation: Decisions = gate outcomes (verbatim brief), Key Design Decisions = non-gate reasoning.

3. **Data availability at gate time**: Mid-execution gates fire when a gated task completes. At that point, the rationale was written during synthesis (before execution). If the agent deviated from the plan during execution, the pre-written rationale may not match the actual deliverable. The gate presentation should be based on the actual deliverable, not just the pre-planned rationale. This means the producing agent may need to output a decision summary alongside its deliverable, or nefario needs to reconcile the two.

4. **Backward compatibility of synthesis format**: Adding a `Gate rationale` field to the synthesis output changes the contract between SKILL.md (which constructs the synthesis prompt) and AGENT.md (which defines the synthesis output format). Existing orchestrations that use the current format will not produce the new field. This is low risk since both are deployed together, but worth noting for the transition.

5. **Context window pressure**: Retaining enriched gate briefs in session context (as SKILL.md line 2240-2242 already requires) becomes more expensive per gate when briefs are richer. With a 3-5 gate budget, this is manageable, but should be monitored.

### Additional Agents Needed

- **devx-minion**: The gate presentation format is a developer experience problem. devx-minion should weigh in on whether the enriched format genuinely improves the developer's decision-making at gates, or whether it adds cognitive load that hurts the approval flow. The line budget tensions (Concern 1 above) are squarely in devx-minion's domain.

- **ux-strategy-minion**: The gate is an interaction design problem. The question of how to layer information (what to show immediately vs. what to put behind a "Details" link to scratch files) is a progressive disclosure design question. ux-strategy-minion should validate that the proposed enrichment serves the user's actual decision-making needs at the gate, not just the transparency goal in the abstract.

If these agents are already part of the planning team, no additions needed. If not, they should be consulted.
