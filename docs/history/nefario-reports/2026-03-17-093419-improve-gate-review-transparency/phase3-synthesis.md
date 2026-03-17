## Advisory Report

**Question**: How should the nefario orchestration system be changed so that approval gates surface decision rationale, trade-offs, and rejected alternatives -- instead of requiring users to read scratch files?
**Confidence**: HIGH
**Recommendation**: Add a structured DECISIONS section (Chosen/Over/Why format, max 4 entries) to the Execution Plan Approval Gate, fed by a new Key Design Decisions table in the synthesis output and a Decisions field in inline summaries. Absorb the current RISKS and CONFLICTS RESOLVED blocks into this section. Do not change the mid-execution gate format (it already has the target pattern). Converge compaction focus strings to preserve decision data.

### Executive Summary

The team unanimously agrees that the current gap is real and fixable: the Execution Plan Approval Gate presents what the plan does but not why the plan chose this approach over alternatives. The user cannot evaluate whether they would have decided differently without reading scratch files. All four specialists confirm that the information already exists (specialist contributions, synthesis conflict resolutions) -- the problem is rendering, not generation.

The recommended approach threads a needle between two failure modes: (1) gates too sparse to support informed decisions (the current state), and (2) gates so heavy they trigger approval fatigue. The solution is a compact DECISIONS section using a 3-field format (Chosen / Over / Why) with a 4-entry cap, placed between ADVISORIES and the review summary. This adds 4-16 lines in the worst case, with most plans producing 0-2 entries. The RISKS and CONFLICTS RESOLVED blocks are absorbed into the DECISIONS section (risks become [constraint] or [trade-off] tagged decisions; conflicts become [conflict] tagged decisions), recovering some of the line budget.

The change touches four files: SKILL.md (gate rendering format + compaction focus strings + inline summary template), AGENT.md (synthesis output format), TEMPLATE.md (Key Design Decisions vs. Decisions distinction), and docs/orchestration.md (gate documentation). The data flow is: specialist Decisions field in inline summaries -> synthesis Key Design Decisions table -> nefario triage to top 4 -> DECISIONS block at gate -> report compilation.

### Team Consensus

1. **The gap is real and specific**: All four specialists agree that the Execution Plan Approval Gate lacks decision rationale. The information exists in scratch files but is not surfaced at the gate. This is not a new feature request -- it is a consistency gap (lucy) / rendering problem (ai-modeling-minion) / information architecture gap (ux-strategy-minion) / data flow gap (software-docs-minion).

2. **The mid-execution gate format is already correct**: No specialist proposed changing the mid-execution gate format (AGENT.md Decision Brief Format, lines 338-382). It already has RATIONALE with rejected alternatives, Confidence, and IMPACT. The target is to bring the *plan-level* gate closer to this pattern, not to redesign mid-execution gates.

3. **Max 4-5 decisions at the gate**: All specialists converge on a hard cap (ux-strategy: 4, ai-modeling: 5). The difference is minor. Recommend 4, matching the ux-strategy rationale that the gate shares working memory with other sections (task list, advisories). The cap is a maximum, not a target -- most plans will show 0-2.

4. **Rejected alternatives are mandatory per entry**: All specialists agree that each gate decision must show what was *not* chosen, not just what was chosen. This directly fulfills the spec's own Anti-Fatigue Rule: "Rejected alternatives mandatory... the primary anti-rubber-stamping measure."

5. **Self-containment is the quality bar**: Each decision entry must be readable without access to the task list, advisories, synthesis file, or other context. The structured fields (Chosen, Over, Why) mechanically enforce this by requiring each piece to be stated explicitly. No "as discussed" or "per the review" language.

6. **Process narrative stays in scratch/report, not in gate**: All specialists agree that *who said what* is archival information, not gate information. The gate shows conclusions (what was decided and why), not process (how the discussion evolved). Process goes to the execution report's Agent Contributions section.

7. **Compaction must preserve decisions**: ai-modeling-minion identified that current compaction focus strings do not mention decisions. Adding "key design decisions table" to Phase 3 and Phase 3.5 focus strings is a low-cost, high-value change that prevents decision data from being lost during context compaction.

8. **TEMPLATE.md needs Key Design Decisions vs. Decisions clarification**: software-docs-minion identified that the report template's two decision sections overlap. The distinction should be: Key Design Decisions = non-gate reasoning that emerged during synthesis; Decisions = gate outcomes as presented and approved.

### Dissenting Views

- **DECISIONS as new section vs. expanding existing RATIONALE block**: software-docs-minion recommends working within the existing RATIONALE block rather than adding a new DECISIONS section, arguing that "changes should work within existing RATIONALE block, not add new sections." ux-strategy-minion and ai-modeling-minion both recommend a new DECISIONS section. Resolution: the RATIONALE block in AGENT.md is defined for mid-execution gates (single-task deliverables). The Execution Plan gate in SKILL.md has no RATIONALE block -- it has RISKS and CONFLICTS RESOLVED blocks, which are structurally different. Adding a DECISIONS section to the plan gate is not adding a section to something that already has one; it is filling a structural gap that the mid-execution gate already fills differently. **Resolved in favor of new DECISIONS section** because the plan gate and mid-execution gate serve different purposes and the existing RISKS/CONFLICTS blocks are being absorbed, not duplicated.

- **Per-task Gate rationale field vs. plan-level decisions table**: software-docs-minion recommends a per-task `Gate rationale` field in the synthesis output so each gated task carries its own rationale data. ai-modeling-minion recommends a single Key Design Decisions table in the synthesis output that covers plan-level decisions. Resolution: these are complementary, not conflicting. The per-task field serves mid-execution gates (already working). The plan-level table serves the Execution Plan gate (the gap being fixed). **Recommend the plan-level Key Design Decisions table** as the primary change, since the mid-execution gate format already works. Per-task gate rationale can be a follow-up if mid-execution gates are found to lack data in practice.

- **Team Approval Gate changes**: lucy recommends adding RATIONALE (2-3 bullets) and Confidence to the Team Approval Gate as well. Other specialists focus exclusively on the Execution Plan gate. Resolution: the Team gate is lower-stakes (agent composition is easy to reverse, low blast radius). The user's complaint centers on the Execution Plan gate where plan-level decisions are invisible. **Recommend deferring Team gate changes** -- address the primary complaint first, evaluate whether the same pattern is needed at the Team gate based on real usage. This avoids scope creep per margo's governance principles.

- **UPCOMING DECISIONS preview block**: software-docs-minion proposes an UPCOMING DECISIONS block in the plan gate that previews what mid-execution gate decisions the user will face. No other specialist raised this. Resolution: **recommend against this addition.** It adds lines to an already-expanding gate section for information that is already visible in the task list (GATE markers on gated tasks). The user can see which tasks are gated from the task list -- previewing the decision content before the deliverable exists risks being speculative. This is YAGNI.

- **Optional DECISION cross-reference field in ADVISE verdicts**: ai-modeling-minion proposes adding an optional `DECISION:` field to ADVISE verdicts that links advisories to decisions table rows. No other specialist raised this. Resolution: **recommend against for now.** The relationship between advisories and decisions is often implicit and forcing explicit linkage adds prompt complexity for reviewers. If the DECISIONS section and ADVISORIES section are adjacent at the gate, the user can mentally connect related items. Revisit if real usage shows confusion.

- **Anomaly detection framing**: lucy argues that SKILL.md line 1380 ("optimized for anomaly detection") is misleading and should be updated. ux-strategy-minion explicitly reaffirms that the gate IS anomaly detection, just for a broader set of anomalies (task-level + decision-level + conflict-level). Resolution: both positions are valid depending on definition scope. **Recommend updating the phrasing** from "optimized for anomaly detection" to "optimized for informed approval -- the user scans for surprises in the task list and evaluates key design decisions." This preserves the scanning-first reading model while acknowledging the decision-evaluation role. This is a single-line edit with no structural impact.

### Supporting Evidence

#### UX Strategy (ux-strategy-minion)

The contribution provides the strongest framework for the change. Key findings:

- **Triage criteria**: Decisions belong in the gate only when they carry decision relevance (conflicts, rejected alternatives worth noting, constraint-driven choices). Routine consensus decisions (agent assignments, model selection, obvious sequencing) are noise at the gate.
- **Two reading modes**: The gate must support both scanning mode (10-20 seconds, most approvals) and rationale mode (60-120 seconds, contested plans). The DECISIONS section is skippable for scanners and self-contained for rationale readers. Progressive disclosure already supports this -- no new interaction model needed.
- **Absorb RISKS and CONFLICTS RESOLVED**: Rather than adding a section while keeping existing ones, absorb risks (as [constraint] or [trade-off] tagged decisions) and conflicts (as [conflict] tagged decisions) into the DECISIONS section. This is budget-neutral and reduces section count.
- **Line budget**: Proposed 25-50 lines (up from 25-40). Justified because RISKS and CONFLICTS (2-6 lines) are absorbed, and the DECISIONS section (4-16 lines worst case) carries the highest information density at the gate.
- **Omittability**: When no decisions are gate-worthy (all specialists agreed, no hard choices), the section is omitted entirely. Its absence signals "straightforward plan."

#### Prompt Engineering (ai-modeling-minion)

The contribution traces the full data pipeline from specialist output to gate rendering. Key findings:

- **Inline summary gap**: The current inline summary template has no Decisions field. After compaction, inline summaries are all that remain -- if decisions are not captured there, synthesis cannot surface them. Adding a Decisions field costs +20-40 tokens per summary, +120-240 total for a 6-agent team.
- **Synthesis output gap**: The synthesis format has Conflict Resolutions and Risks and Mitigations but no Key Design Decisions section. Most design decisions are *uncontested* choices (one specialist recommended, nobody disagreed) -- these are invisible in the current format.
- **Compaction gap**: Neither Phase 3 nor Phase 3.5 focus strings mention decisions. The compactor has no signal to retain decision data. Adding "key design decisions table" to both focus strings costs 4 tokens but preserves 100-200 tokens of decision data.
- **Token budget**: Total impact is ~270-590 tokens of new persistent content across the pipeline. Under 1% of context window. Manageable.

#### Governance / Intent Alignment (lucy)

The contribution reframes the problem and identifies a spec inconsistency. Key findings:

- **Not intent drift, but consistency gap**: Mid-execution gates already have RATIONALE + rejected alternatives + Confidence. The Execution Plan gate does not. The spec's own "Intuitive, Simple & Consistent" principle demands convergence.
- **"Anomaly detection" framing is contradicted by spec features**: The spec provides Request Changes, Reject, Confidence indicators, calibration checks, and mandatory rejected alternatives. These are decision-maker affordances, not anomaly-detector affordances. The common case is quick approval (anomaly detection), but the design intent is informed decision-making.
- **Scope containment is critical**: The change is about surfacing existing reasoning, not generating new reasoning. No new phases, no new gate types, no user-configurable verbosity (YAGNI).

#### Documentation (software-docs-minion)

The contribution maps the information flow across artifacts. Key findings:

- **Four artifacts affected**: SKILL.md (rendering), AGENT.md (data availability), TEMPLATE.md (report compilation), docs/orchestration.md (contributor documentation). Changes propagate in that dependency order.
- **Root cause**: Synthesis output lacks structured per-task gate rationale. The SKILL.md gate format already supports rationale rendering (it uses it for mid-execution gates) -- it just lacks the data from synthesis.
- **Report redundancy risk**: If gates now show full rationale, the report's Decisions section becomes a near-verbatim copy of what the user saw at gates. Mitigation: clearly delineate Key Design Decisions (non-gate reasoning) from Decisions (gate outcomes as-presented).
- **Data availability at gate time**: For mid-execution gates, rationale is written during synthesis but the deliverable may have diverged during execution. This is a pre-existing concern, not introduced by this change -- flagged for awareness.

### Risks and Caveats

1. **Synthesis quality determines gate quality**: The DECISIONS section is only as good as nefario's ability to identify, triage, and articulate key decisions during synthesis. Poor triage produces misleading gates. Mitigation: Phase 3.5 reviewers (lucy, margo) review synthesis output. The structured format (Chosen/Over/Why) constrains output and reduces quality variance.

2. **Gate line budget inflation**: The gate grows from 25-40 to 25-50 lines. While RISKS and CONFLICTS are absorbed, the net effect is still growth. Risk: gradual creep toward the cap as nefario consistently includes 3-4 decisions even for straightforward plans. Mitigation: explicit guidance that 0-2 decisions is the common case and reaching the 4-decision cap signals an unusually contested plan. The section is omitted entirely when no decisions are gate-worthy.

3. **Compaction is not guaranteed**: Adding "key design decisions table" to focus strings signals the compactor but does not guarantee preservation under heavy context pressure. Mitigation: the decisions table uses structured format (table or Chosen/Over/Why blocks) that compacts better than prose. The inline summary Decisions field provides a fallback extraction point.

4. **Specialist adoption of Decisions field in inline summaries**: Specialists need to populate the new Decisions field. If they do not (because their prompts do not emphasize it), synthesis falls back to scratch file reading -- no worse than today, but the optimization is lost. Mitigation: update the Phase 2 prompt template to include the field with an example.

5. **Self-containment is hard for LLMs to self-evaluate**: The quality bar ("a reader seeing only this decision can answer: what was the hard question, what was chosen, what was rejected, why") is an abstract criterion. Mitigation: the structured fields mechanically enforce self-containment. The test is a design principle for humans reviewing the format, not a runtime check for the LLM.

6. **This recommendation could itself be scope-creeped**: Four files are touched, each with multiple sections. Discipline is needed to make surgical edits, not restructure entire sections. The implementation should be a single agent task per file, not a multi-phase project.

### Next Steps

If this recommendation is adopted, the implementation path is:

1. **AGENT.md**: Add Key Design Decisions table to MODE: SYNTHESIS output format (between Risks and Mitigations and Execution Order). Add triage instructions: nefario selects top 4 decisions by gate-relevance (conflicts first, then constraint-driven trade-offs, then scope reinterpretations). Restructure Conflict Resolutions and Risks and Mitigations to feed into the decisions table.

2. **SKILL.md (inline summary template)**: Add `Decisions:` field to the inline summary template. Update token budget estimate from ~80-120 to ~100-160 per summary.

3. **SKILL.md (gate format)**: Replace RISKS and CONFLICTS RESOLVED blocks with a DECISIONS section using the Chosen/Over/Why format. Cap at 4 entries. Update line budget from 25-40 to 25-50. Update the "optimized for anomaly detection" phrasing.

4. **SKILL.md (compaction)**: Add "key design decisions table" to Phase 3 and Phase 3.5 compaction focus strings.

5. **TEMPLATE.md**: Clarify Key Design Decisions vs. Decisions distinction. Add guidance: "Key Design Decisions covers non-gate decisions. Decisions covers gate outcomes."

6. **docs/orchestration.md**: Update Section 3 gate documentation to reflect the enriched format. Add brief note on decision information flow.

Steps 1-4 are the core change. Steps 5-6 are downstream alignment. A follow-up `/nefario` execution could implement all six steps as a single plan with one gate (on the DECISIONS format in SKILL.md, since it is the rendering contract that downstream steps depend on).

### Conflict Resolutions

Three conflicts were resolved during synthesis:

1. **New section vs. existing block**: software-docs-minion favored working within existing structures; ux-strategy and ai-modeling favored a new DECISIONS section. Resolved in favor of new section because the Execution Plan gate has no equivalent RATIONALE block -- RISKS and CONFLICTS RESOLVED are being absorbed, not duplicated.

2. **Team gate scope**: lucy recommended extending changes to the Team Approval Gate. Resolved: deferred. The primary user complaint is about the Execution Plan gate. Team gate changes can follow if needed.

3. **UPCOMING DECISIONS block**: software-docs-minion proposed previewing mid-execution gate decisions at the plan gate. Resolved: rejected (YAGNI -- the task list already shows which tasks are gated).
