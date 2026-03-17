## Meta-Plan

### Planning Consultations

#### Consultation 1: Gate data pipeline and upstream format changes (AGENT.md)

- **Agent**: ai-modeling-minion
- **Planning question**: The advisory identified specific upstream data format changes needed in AGENT.md: structured Chosen/Over/Why/Source for conflict resolutions in synthesis output, a "Gate rationale" field for gated tasks, excerptable exclusion rationale in meta-plan output for the Team gate, and per-reviewer "Review focus" + exclusion rationale in the Architecture Review Agents section. Given that AGENT.md is the canonical spec that governs nefario's behavior across all sessions, what is the precise set of format changes needed to ensure each gate type receives the structured data it needs to render transparency? Specifically: (a) what changes to the meta-plan output template ensure the Team gate can excerpt NOT SELECTED (notable) entries without re-analyzing the full checklist, (b) what changes to the synthesis output template produce Chosen/Over/Why entries that the Execution Plan gate can render directly, and (c) how should the "Gate rationale" fallback field be structured so it is useful when agents do not report execution-time rationale? Also assess whether the compaction focus strings need to name "key design decisions" explicitly to preserve decision data through context compression.
- **Context to provide**: Current AGENT.md meta-plan output template (lines 460-500), synthesis output template (lines 524-578, especially Conflict Resolutions at line 563), Architecture Review Agents section (lines 556-561), the advisory's data flow analysis and before/after examples for all four gates
- **Why this agent**: ai-modeling-minion owns prompt engineering and multi-agent architecture. AGENT.md changes are prompt engineering artifacts that define the data pipeline feeding all four gates. This agent traced the data flow in the advisory and identified exactly where rationale is lost per gate type.

#### Consultation 2: Gate rendering format changes (SKILL.md)

- **Agent**: ux-strategy-minion
- **Planning question**: The advisory recommends specific changes to all four gate presentation formats in SKILL.md. For the Team gate: add a NOT SELECTED (notable) block with max 3 entries and exclusion rationale, adjusting the line budget from 8-12 to 10-16. For the Reviewer gate: replace the flat NOT SELECTED comma list with per-member exclusion rationales, add "Review focus" per discretionary pick, adjusting from 6-10 to 7-13 lines. For the Execution Plan gate: rename CONFLICTS RESOLVED to DECISIONS with Chosen/Over/Why format, adjusting from 25-40 to 35-55 lines. For the mid-execution gate: add good/bad RATIONALE examples and agent prompt instructions for rationale reporting (format unchanged). Given the self-containment test ("decidable without clicking Details"), what is the precise rendering format for each gate that maximizes decision quality within the line budget? Specifically: (a) should the NOT SELECTED (notable) block in the Team gate use the same one-liner format as SELECTED or a different density, (b) how should the DECISIONS block in the Execution Plan gate handle the max-5 cap and overflow, (c) what good/bad RATIONALE examples best teach the pattern without being so specific that agents copy them verbatim, and (d) should the agent completion message instruction (for mid-execution gates) live in SKILL.md's Phase 4 section or in the synthesis task prompt template?
- **Context to provide**: Current SKILL.md Team gate format (lines 482-518), Reviewer gate format (lines 999-1032), Execution Plan gate format (lines 1377-1471), the advisory's before/after examples for all four gates, AGENT.md Decision Brief Format section
- **Why this agent**: ux-strategy-minion owns user journey design and cognitive load reduction. Gate rendering is fundamentally a UX problem -- the user must be able to make informed decisions from inline content alone. This agent proposed the self-containment test and line budgets in the advisory.

### Cross-Cutting Checklist

- **Testing**: Exclude test-minion from planning. No executable output -- all changes are prompt/doc artifacts. test-minion will review in Phase 3.5 (mandatory reviewer) to verify the prompt changes do not create contradictions or untestable commitments.
- **Security**: Exclude security-minion from planning. No new attack surface -- gate changes are prompt-only, no auth, no user input handling, no new dependencies. security-minion reviews in Phase 3.5 (mandatory).
- **Usability -- Strategy**: Included as Consultation 2 (ux-strategy-minion). Planning question covers all four gate rendering formats, line budgets, and the self-containment test.
- **Usability -- Design**: Exclude ux-design-minion and accessibility-minion from planning. No UI components produced -- all changes are CLI text output formats (monospace terminal). No web-facing HTML.
- **Documentation**: Exclude software-docs-minion from planning. The advisory already mapped the 4-artifact impact comprehensively. The two secondary artifacts (TEMPLATE.md, docs/orchestration.md) are documentation updates that flow mechanically from the AGENT.md and SKILL.md changes. software-docs-minion's contribution in the advisory (exception rules for advisories and mandatory reviewers, TEMPLATE.md broadening strategy) is already incorporated into the task description. An execution task for docs/orchestration.md can reference the advisory directly.
- **Observability**: Exclude observability-minion and sitespeed-minion from planning. No runtime components, no browser-facing code, no services to monitor.

### Anticipated Approval Gates

No mid-execution gates anticipated. This is a prompt-engineering task with 4 artifacts that have clear sequential dependencies (AGENT.md upstream before SKILL.md rendering). The changes are additive (new fields and format enrichments, no breaking changes) and easy to reverse (revert commits). The Execution Plan Approval Gate is the primary decision point.

### Rationale

Two specialists are sufficient because:

1. **The advisory already did the deep analysis.** Four specialists (ux-strategy-minion, ai-modeling-minion, lucy, software-docs-minion) spent a full advisory session analyzing all four gate types with real production data. The recommendations are specific and consensus-backed. Planning does not need to re-derive the analysis -- it needs to translate it into precise implementation specs.

2. **The work splits cleanly into two domains.** ai-modeling-minion owns the upstream data formats (AGENT.md -- what data is produced). ux-strategy-minion owns the downstream rendering (SKILL.md -- how data is presented). These are the two agents whose domain expertise directly improves the implementation specs. lucy and software-docs-minion's advisory contributions (convergence framing, exception rules, artifact impact) are already captured in the task description and advisory report.

3. **Governance reviews happen in Phase 3.5.** lucy (intent alignment) and margo (simplicity enforcement) review the plan as mandatory reviewers. Their planning contributions would duplicate their review contributions for a task this well-scoped.

### Scope

**In scope:**
- AGENT.md: Meta-plan output template (excerptable exclusion rationale), synthesis output template (structured Chosen/Over/Why conflict resolutions, "Gate rationale" field for gated tasks, per-reviewer "Review focus" + exclusion rationale), compaction focus strings (naming "key design decisions")
- SKILL.md: Team gate format (NOT SELECTED notable block), Reviewer gate format (per-member rationale, Review focus), Execution Plan gate format (DECISIONS replacing CONFLICTS RESOLVED), Mid-execution gate (good/bad RATIONALE examples, agent prompt instructions for rationale reporting)
- TEMPLATE.md: Gate type awareness, Chosen/Over/Why in Decisions section
- docs/orchestration.md: Gate philosophy preamble, decision transparency expectations per gate type, Reviewer gate elevation to Section 3 as first-class gate type

**Out of scope:**
- Gate interaction mechanics (AskUserQuestion structure, response handling, adjustment flows)
- Post-execution phases (5-8)
- Report generation logic
- Advisory mode gates
- Code, infrastructure, or runtime changes

### External Skill Integration

No external skills detected in project. Two project-local skills exist (despicable-lab, despicable-statusline) but neither is relevant to this prompt-engineering task.
