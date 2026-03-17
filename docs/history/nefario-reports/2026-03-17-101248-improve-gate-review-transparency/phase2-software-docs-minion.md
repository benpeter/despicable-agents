# Domain Plan Contribution: software-docs-minion

## Full Documentation Impact Analysis: Gate Review Transparency Across All Four Gate Types

### 1. SKILL.md: Gate Format Spec Interactions and Shared Patterns

#### Current State

The four gate types in SKILL.md have different levels of specification depth:

| Gate | SKILL.md Lines | Decision Rationale | Alternatives Shown |
|------|---------------|-------------------|-------------------|
| Team (P1) | ~100 lines | One-line rationale per specialist (why chosen) | ALSO AVAILABLE list (names only, no exclusion reasoning) |
| Reviewer (P3.5) | ~100 lines | One-line rationale per discretionary pick (task reference) | NOT SELECTED list (names only) |
| Execution Plan (P3.5 Plan) | ~90 lines | ADVISORIES with CHANGE/WHY; CONFLICTS RESOLVED as one-liners | Rejected alternatives in CONFLICTS RESOLVED only |
| Mid-Execution (P4) | ~30 lines | RATIONALE bullets + "Rejected: alternative and why" | Rejected alternatives inline |

The mid-execution gate is the only gate that already has a structured Chosen/Over/Why pattern (via the RATIONALE + Rejected format in the decision brief). The other three gates lack this explicit decision structure.

#### Recommendation: Common Decision Entry Format with Gate-Specific Wrappers

Each gate type serves a different purpose, but decision rationale follows a universal cognitive pattern: **what was decided, what was considered, why this choice**. The gates differ in *what* is being decided, not *how* decisions should be communicated.

Proposed approach -- define a reusable "decision entry" micro-format in a new preamble section of SKILL.md, then reference it from each gate:

```
DECISION ENTRY FORMAT (reusable across all gate types):
  <chosen option>
    Over: <rejected alternative(s)>
    Why: <rationale grounding the choice>
```

**Gate-specific wrappers**:

- **Team gate**: Each SELECTED specialist gets a decision entry. The "Over" field names agents from the roster that cover adjacent domains but were not chosen. The "Why" field explains task-specific relevance. This replaces the current one-line rationale.
- **Reviewer gate**: Each DISCRETIONARY pick gets a decision entry. The "Over" field names the pool members not selected. The "Why" field references specific plan tasks (already partially present). Mandatory reviewers do not get decision entries (they are unconditional).
- **Execution Plan gate**: CONFLICTS RESOLVED entries already approximate this format -- formalize them. ADVISORIES keep their CHANGE/WHY format (these are modifications, not choices between alternatives, so the decision entry format does not apply to them).
- **Mid-Execution gate**: Already has this structure. No change needed.

**Dependencies between gate formats**: Team gate decisions flow into the Execution Plan gate (specialists chosen affect task prompts). Reviewer gate decisions affect ADVISORIES in the Execution Plan gate. These are data dependencies, not format dependencies -- each gate's presentation is self-contained. No cross-gate format coupling is needed.

**Trade-off**: Adding decision entries to Team and Reviewer gates increases their line count (estimated +2-3 lines per specialist). Team gate currently targets 8-12 lines; with decision entries for 5 specialists, this grows to approximately 13-18 lines. The Reviewer gate is similar. This is within the "clarity wins over brevity" principle already stated in the Execution Plan gate section.

**What NOT to do**: Do not make every gate look identical. The Team gate is about team composition (roster decisions). The Reviewer gate is about review scope (discretionary pool decisions). The Execution Plan gate is about the work itself (plan decisions). The Mid-Execution gate is about a specific deliverable (approval decisions). Each has domain-specific fields that should remain distinct. The decision entry format is a shared micro-pattern, not a shared macro-layout.

### 2. AGENT.md: Meta-Plan and Synthesis Output Format Interactions

#### Current State

The nefario AGENT.md defines two output formats that feed gate presentations:

- **Meta-plan output** (lines 459-500): Produces `Planning Consultations` with per-specialist entries containing "Why this agent" and the planning question. This feeds the Team gate.
- **Synthesis output** (lines 525-578): Produces `Delegation Plan` with tasks, gates, conflict resolutions, risks. Also produces `Architecture Review Agents` with discretionary picks and rationales. This feeds both the Reviewer gate and the Execution Plan gate.

#### Impact Assessment

**Meta-plan output needs enrichment** to support Team gate decision entries. Currently, the meta-plan produces a "Why this agent" field per consultation, but does NOT produce "What alternatives were considered" or "Why this agent over alternatives." The Team gate cannot show decision entries unless the meta-plan provides the raw data.

Recommended changes to meta-plan output format:
- Add an "Over" or "Alternatives considered" field per consultation entry, naming agents whose domains overlap but who were not selected. Example: `Over: api-spec-minion (narrower scope than api-design-minion for contract-level decisions)`
- Keep the existing "Why this agent" field unchanged
- Add a "Cross-Cutting Exclusion Rationale" to the cross-cutting checklist entries that states why non-included agents were excluded. Currently the checklist says "include test-minion for planning? why / why not" -- the "why not" answer is already there but needs to be surfaced at the gate

**Synthesis output needs minor enrichment** to support Reviewer gate decision entries. The `Architecture Review Agents` section already includes discretionary picks with one-line rationales and a NOT SELECTED list. To support decision entries, add an "Over" or "Why not selected" annotation per NOT SELECTED pool member (one line each). This is a small addition -- the discretionary pool has only 5 members, so at most 3-4 "not selected" entries need rationale.

**Interaction between the two formats**: The meta-plan's specialist selection directly determines what planning data is available for synthesis. If a specialist is excluded at the Team gate, their domain perspective is absent from synthesis. The enriched exclusion rationale in the meta-plan serves double duty: it supports the Team gate presentation AND it documents what perspectives the plan deliberately lacks. No format coupling between meta-plan and synthesis is needed -- each is self-contained.

**No changes needed for mid-execution gate data**: Mid-execution gate decision briefs are composed by the SKILL.md orchestration from execution agent outputs, not from a nefario output format. The current RATIONALE + Rejected structure in the SKILL.md mid-execution gate spec is sufficient.

### 3. TEMPLATE.md: Report Structure Changes for Multi-Gate Decision Capture

#### Current State

The report template (TEMPLATE.md v3) has two sections that capture gate decisions:

- **Approval Gates** table (lines 178-189): Summary table with Gate Title, Agent, Confidence, Outcome, Rounds, plus per-gate H4 briefs with Decision/Rationale/Rejected fields
- **Decisions** section (lines 191-201): Separate H2 with full gate briefs (Decision/Rationale/Rejected/Confidence/Outcome)

Both sections currently focus on mid-execution gates (Phase 4 gates). The table headers ("Agent", "Confidence") and the H4 brief structure assume a deliverable-approval pattern.

#### Impact Assessment

**Team gate and Reviewer gate decisions are currently NOT captured in the report's gate sections.** They appear only in the Phases narrative (Phase 1 and Phase 3.5 descriptions). This is the documentation gap.

Recommended changes:

1. **Rename "Approval Gates" to "Gate Decisions"** (or keep "Approval Gates" but broaden the definition). The table should include ALL gate types, not just mid-execution gates.

2. **Extend the summary table** to accommodate non-deliverable gates:

   | Gate Title | Type | Outcome | Rounds |
   |------------|------|---------|--------|
   | Team composition (8 specialists) | Team | approved (adjusted +3) | 2 |
   | Discretionary reviewers | Reviewer | approved (adjusted +1) | 2 |
   | Execution plan (6 tasks, 1 gate) | Plan | approved | 1 |
   | Auth module rewrite | Mid-execution | approved | 1 |

   The "Type" column replaces "Agent" (which is specific to mid-execution gates) and "Confidence" (which does not apply to Team/Reviewer gates). Confidence can be included in the per-gate H4 brief for gate types that have it.

3. **Per-gate H4 briefs need type-aware structure**:
   - **Team gate brief**: Specialists chosen (count), key roster decisions (Chosen/Over/Why), adjustments made
   - **Reviewer gate brief**: Discretionary picks (with rationale), adjustments made
   - **Plan gate brief**: Key plan parameters (task count, gate count, advisory count), notable conflicts resolved
   - **Mid-execution brief**: Decision/Rationale/Rejected/Confidence (unchanged)

4. **Decisions section**: Keep as-is but include Team and Reviewer gate decisions when they involved user adjustments or non-trivial choices. Routine approvals (approve team as-is, approve reviewers as-is) should appear in the Approval Gates table but do NOT need a full Decisions entry -- they add noise without insight.

**Conditional inclusion rule update**: The existing rule is `Decisions: gate-count > 0`. This is fine -- the `gate-count` frontmatter field already counts all gates. The change is that `gate-count` should count Team and Reviewer gates (currently unclear whether it does). Recommend explicitly stating: "gate-count includes all user-facing gates: Team, Reviewer, Plan, and Mid-execution."

### 4. docs/orchestration.md: Gate Documentation Overhaul

#### Current State

The orchestration.md Section 3 (Approval Gates, lines 357-503) is well-structured and comprehensive, but it has a key philosophical gap: **it describes gate mechanics (what the gate shows, what buttons the user clicks) without articulating why the user should care about each gate's decision surface.**

The current structure:
- Three gate types listed (Team, Execution Plan, Mid-execution)
- Reviewer gate described inline within Phase 3.5 narrative (not in Section 3)
- Gate classification matrix for mid-execution gates
- Decision brief format for mid-execution gates
- Anti-fatigue rules

#### Recommended Changes

1. **Elevate to four gate types in Section 3**: Move the Reviewer gate from the Phase 3.5 narrative into Section 3 as a first-class gate type alongside Team, Plan, and Mid-execution. This makes the gate taxonomy complete and discoverable.

2. **Add a gate philosophy preamble** before the individual gate descriptions:

   > Approval gates exist to give the user informed agency over high-impact decisions. "Informed" means the gate shows not just what was decided, but what was considered and why the chosen path beats the alternatives. A gate that shows only the outcome without the reasoning produces rubber-stamping, not informed consent.
   >
   > All gates follow a common transparency principle: every non-trivial decision presented at a gate includes what was chosen, what was not chosen, and why. The depth of this rationale scales with the decision's reversibility and blast radius.

3. **Add decision transparency expectations per gate type**:

   | Gate | Decision Surface | Expected Rationale Depth |
   |------|-----------------|------------------------|
   | Team | Which specialists to consult | One line per specialist: why chosen over adjacent-domain alternatives |
   | Reviewer | Which discretionary reviewers to include | One line per pick/exclusion: task-grounded reasoning |
   | Execution Plan | Whether the synthesized plan is sound | ADVISORIES (CHANGE/WHY), CONFLICTS RESOLVED (Chosen/Over/Why), RISKS (with mitigations) |
   | Mid-Execution | Whether a specific deliverable is correct | Full decision brief: rationale, rejected alternatives, confidence, impact |

4. **Document the information flow between gates**: The Team gate affects what perspectives are available for planning. The Reviewer gate affects what advisory input shapes the Execution Plan gate. The Execution Plan gate determines what Mid-execution gates exist. This is a causal chain, and orchestration.md should document it as such. Add a brief subsection or diagram showing the decision flow.

5. **Update the anti-fatigue section**: The current anti-fatigue rules apply primarily to mid-execution gates. With enriched Team and Reviewer gates, add guidance: "Team and Reviewer gates should remain lightweight (under 15 lines each). The decision entries are compressed (one line per specialist, not a paragraph). If the team has more than 8 specialists, group related specialists by domain and explain domain-level decisions rather than per-agent decisions."

### 5. Consistency Pattern: Chosen/Over/Why -- Simplification vs. Uniformity

#### Analysis

A shared Chosen/Over/Why format across all four gate types is a **simplification**, not a uniformity problem. Here is why:

**What the user needs to know at each gate is the same cognitive pattern**: "What did you decide, what else was possible, and why this choice?" The content differs (specialists vs. reviewers vs. plan elements vs. deliverables), but the structure is constant.

**The risk of uniformity** is that gates start to feel like the same form repeated four times, creating fatigue. This risk is mitigated by three factors:
1. The wrapper around the decision entries is gate-specific (SELECTED block vs. DISCRETIONARY block vs. ADVISORIES block vs. DELIVERABLE block)
2. The line budgets are different (8-12 for Team, 6-10 for Reviewer, 25-40 for Plan, 12-18 for Mid-execution)
3. Only the Plan and Mid-execution gates have confidence levels, rejected alternatives, and impact statements

**Recommendation**: Adopt the shared Chosen/Over/Why micro-format for decision entries, but do NOT create a shared macro-layout. Each gate keeps its distinct visual structure and line budget. The shared element is the rationale pattern inside each decision entry, not the gate presentation as a whole.

**Where the pattern breaks**: Two cases where Chosen/Over/Why does not apply:
- **ADVISORIES in the Execution Plan gate**: These are plan modifications, not choices between alternatives. They keep the CHANGE/WHY format (no "Over" because nothing was rejected -- the advisory is additive).
- **Mandatory reviewers**: These are unconditional (security, test, ux-strategy, lucy, margo). No decision was made, so no decision entry is needed. Only discretionary picks get decision entries.

### Recommendations

**Priority-ordered tasks for documentation changes:**

1. **SKILL.md gate format updates** (highest priority -- this is the spec that nefario follows):
   - Add a "Decision Transparency" preamble defining the Chosen/Over/Why micro-format
   - Update Team gate presentation spec: add decision entry per SELECTED specialist (Over: adjacent-domain agent not selected, Why: task-specific relevance)
   - Update Reviewer gate presentation spec: add decision entry per discretionary pick and per NOT SELECTED pool member (Why selected / Why not)
   - No changes to Execution Plan gate ADVISORIES format (CHANGE/WHY is correct as-is)
   - Formalize CONFLICTS RESOLVED entries into Chosen/Over/Why structure
   - No changes to Mid-execution gate format (already has Rejected: alternative in RATIONALE)

2. **AGENT.md meta-plan output format** (required -- gates cannot show what nefario does not produce):
   - Add "Over" field to each Planning Consultation entry
   - Add explicit exclusion rationale to Cross-Cutting Checklist entries

3. **AGENT.md synthesis output format** (minor -- mostly already present):
   - Add "Why not selected" annotations per NOT SELECTED discretionary pool member in the Architecture Review Agents section

4. **TEMPLATE.md report structure** (important for decision traceability):
   - Rename or broaden Approval Gates section to cover all four gate types
   - Add Type column to the gate summary table
   - Define type-aware H4 brief structures for Team and Reviewer gates
   - Update gate-count definition to explicitly include all gate types
   - Add conditional rule: routine approvals (no adjustments) get table row only; adjusted or contested gates get full Decisions entry

5. **docs/orchestration.md** (important for developer understanding):
   - Elevate Reviewer gate to Section 3 as a first-class gate type
   - Add gate philosophy preamble on transparency principle
   - Add decision transparency expectations table per gate type
   - Document information flow between gates
   - Update anti-fatigue guidance for enriched Team/Reviewer gates

### Risks and Concerns

1. **Line budget inflation**: Adding decision entries to Team and Reviewer gates increases their size. Team gate could grow from 8-12 lines to 15-20 with 8 specialists. Mitigation: group specialists by domain for large teams (4+ specialists from same group get a single domain-level decision entry).

2. **Context window pressure**: Enriched gates consume more of the LLM's context window. Each additional Chosen/Over/Why entry is approximately 15-20 tokens. For a team of 8 specialists, this adds approximately 120-160 tokens to the gate presentation. This is small relative to the overall orchestration context, but cumulative across all gates. Mitigation: keep decision entries to single lines; deep reasoning stays in scratch files.

3. **Meta-plan output change ripple**: Changing the meta-plan output format requires updating nefario's AGENT.md, which means a spec-version bump and rebuild. This touches one of the most critical files in the system. Mitigation: the change is additive (new optional fields), not breaking (existing fields unchanged).

4. **TEMPLATE.md version bump**: Changing the report template structure from v3 to v4 means existing reports and any tooling that parses them (build-index.sh) may need updates. Mitigation: the changes are additive (new columns in existing tables, new brief types under existing sections), so v3 reports remain valid when read by v4 tooling.

5. **Spec-vs-implementation drift**: The enriched gate formats are more complex, increasing the chance that nefario's runtime behavior drifts from the spec. Mitigation: the decision entry format is simple (three fields: Chosen, Over, Why) and the examples in SKILL.md serve as alignment anchors.

### Additional Agents Needed

None. The documentation changes are within the scope of software-docs-minion (SKILL.md, AGENT.md, TEMPLATE.md, orchestration.md are all architectural documentation). The actual implementation of enriched gate behavior at runtime is a nefario/SKILL.md change, not a separate agent's work.
