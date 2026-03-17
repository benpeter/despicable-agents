## Domain Plan Contribution: lucy

### Recommendations

#### 1. The previous advisory got the diagnosis right but the prescription wrong

The previous advisory (2026-03-17) correctly identified this as a "consistency gap, not intent drift." That framing holds. But the recommended scope -- enrich only the Execution Plan gate, defer the rest -- was itself a form of scope underreach that the user explicitly rejected. The user said "The mid-execution gates aren't great either to base decisions on." The advisory deferred the Team gate on YAGNI grounds ("lower-stakes, easy to reverse"). The user overrode that judgment. YAGNI is a valid principle, but it does not apply when the user is telling you the feature is needed now. The user adding 3 agents via freeform at the Team gate IS the user telling you the gate does not give them enough to decide.

The previous advisory also assumed mid-execution gates are "already the target pattern" and need no changes. The user disagrees. The spec has RATIONALE+Rejected in the mid-execution gate format, but zero production sessions have tested it. We cannot treat untested spec text as a known-good reference implementation. The spec says the right things; we do not know if agents follow through in practice.

#### 2. The philosophy is correct; the implementation is inconsistently absent

The spec's gate philosophy is sound:
- "Progressive-disclosure decision briefs" (AGENT.md line 340-342)
- "Most approvals should be decidable from the first two layers without reading the full deliverable" (line 341-342)
- "Rejected alternatives mandatory... primary anti-rubber-stamping measure" (line 406-408)
- Confidence indicator to guide attention allocation (line 403-405)
- Calibration check to detect gate fatigue (line 409-411)

This philosophy is only actualized at mid-execution gates. It is absent from:
- **Team gate**: Shows agent names and one-liners. No RATIONALE. No Confidence. No rejected alternatives. The user cannot see why agents were excluded. The meta-plan has this reasoning -- it is not surfaced.
- **Execution Plan gate**: Shows tasks, advisories, risks, and conflict resolutions. The CONFLICTS RESOLVED block shows conclusions without reasoning ("Name uniqueness: not enforced for MVP"). No RATIONALE. No Confidence. No rejected alternatives at the plan level.
- **Reviewer gate**: Shows a roster with one-line rationales. No reasoning about why discretionary reviewers were or were not selected relative to the plan content. No Confidence.

The fix is to apply the philosophy that already exists in the spec consistently across all gates. This is convergence, not new complexity.

#### 3. All four gates SHOULD converge to the same structural pattern, at density proportional to decision scope

The planning question asks whether gates should converge or each have a format appropriate to its scope. The answer is: converge on structure, vary on density. This is what "Intuitive, Simple & Consistent" means for gates.

Every gate should have these structural elements:

| Element | Team Gate | Reviewer Gate | Execution Plan Gate | Mid-Execution Gate |
|---------|-----------|---------------|--------------------|--------------------|
| DECISION (1-line summary) | "Consulting these N specialists for planning" | "These N reviewers will evaluate the plan" | "Execute this N-task plan" | "Accept this deliverable" |
| RATIONALE (bullets + rejected alternative) | 2-3 bullets: key inclusion/exclusion reasoning from meta-plan | 2-3 bullets: key discretionary selection reasoning from plan content | 3-5 bullets: key synthesis decisions, Chosen/Over/Why | 3-5 bullets: key implementation decisions, at least one Rejected |
| Confidence | HIGH/MEDIUM/LOW | HIGH/MEDIUM/LOW | HIGH/MEDIUM/LOW | Already present |
| Details link | Already present (meta-plan) | Already present (plan) | Already present (synthesis) | Already present (task-prompt) |

Density scaling:
- Team gate: 2-3 RATIONALE bullets, targeting 13-18 lines total (up from 8-12)
- Reviewer gate: 2-3 RATIONALE bullets for the discretionary selection as a whole (not per-reviewer), targeting 10-14 lines (up from 6-10)
- Execution Plan gate: 3-5 RATIONALE bullets using Chosen/Over/Why, targeting 30-48 lines (up from 25-40)
- Mid-Execution gate: Already specified at 3-5 RATIONALE bullets, targeting 12-18 lines

The key insight: the RATIONALE section is the element that turns a "here's what we're doing" presentation into a "here's what we decided and why" decision support tool. Without it, gates are information displays. With it, they are decision briefs.

#### 4. The mid-execution gate spec should be treated as design intent, not verified implementation

The mid-execution gate format in AGENT.md (lines 338-382) and SKILL.md (lines 1600-1631) is the most complete gate specification. It has DECISION, DELIVERABLE, RATIONALE (with Rejected), IMPACT, and Confidence. This is good.

But the user reports that mid-execution gates have "never been observed" in 17+ production sessions with the RATIONALE+Rejected format actually appearing. This means one of two things:
1. The tasks that get gated don't produce enough decision-relevant content for agents to populate the RATIONALE section meaningfully, or
2. The agents are complying with the spec format but producing shallow RATIONALE bullets that don't expose real reasoning.

Either way, the mid-execution gate does NOT need a format redesign. It needs verification that the format produces useful content in practice. The structural specification is already the target pattern. The question is execution quality, not specification quality.

Recommendation: Do not redesign the mid-execution gate format. Instead:
- Verify the RATIONALE section wording in SKILL.md encourages substantive reasoning (it currently says "key point 1, key point 2" -- these could be more directive)
- Add an example of a good vs. bad RATIONALE in the SKILL.md mid-execution gate section, parallel to the good/bad examples already in the Phase 3.5 reviewer verdicts section (SKILL.md lines 1150-1172)
- Treat the first production sessions after this change as a test of whether agents populate RATIONALE meaningfully, and plan a follow-up if they do not

#### 5. The Team gate should surface meta-plan reasoning, not become a decision-making tool

The planning question asks whether the Team gate should "become a decision-making tool." The answer is: it already IS a decision-making tool (the user approves, adjusts, or rejects the team). It should become a TRANSPARENT decision-making tool.

The meta-plan already contains:
- Why each specialist was selected (planning question = expertise needed)
- Why agents were not selected (exclusion rationale)
- Cross-cutting checklist evaluation
- The user's task analysis

None of this reaches the Team gate presentation. The user sees agent names and one-liners. The user's free-text additions ("add gru, lucy, devx") are a direct signal: the gate did not explain its reasoning well enough for the user to understand why those agents were not included.

The fix is to add a RATIONALE block that surfaces the top 2-3 meta-plan reasoning points. At minimum, include one "Not selected: [agent] because [reason]" entry for the most notable exclusion. This costs 3-5 lines and directly addresses the observed user behavior.

#### 6. The Reviewer gate has a narrower but real gap

The Reviewer gate (SKILL.md lines 999-1108) currently shows discretionary picks with plan-grounded rationales. This is better than the Team gate -- it already requires task references and specific rationale. But it lacks:
- An overall RATIONALE for the reviewer composition as a whole (why these specific reviewers matter for this specific plan)
- Confidence indicator

The Reviewer gate is lower-stakes than the other three (the user can adjust, and mandatory reviewers always run). The fix here is lighter: add 2-3 bullets of overall composition rationale and a Confidence indicator. This is enough to make the gate structurally consistent without inflating it.

#### 7. The CONFLICTS RESOLVED block in the Execution Plan gate illustrates the exact problem

The user's verbatim example is devastating:

```
CONFLICTS RESOLVED:
  - Revoked key visibility: exclude by default, ?include=revoked opt-in (api-design-minion)
  - Name uniqueness: not enforced for MVP (avoids key rotation friction)
```

These are conclusions. They tell the user WHAT was decided but not:
- What alternatives were considered
- Who argued for what
- Why this resolution was chosen over others
- What trade-offs were accepted

The previous advisory recommended absorbing RISKS and CONFLICTS RESOLVED into a DECISIONS section using Chosen/Over/Why format. I concur with that structural recommendation. The Chosen/Over/Why format mechanically forces the reasoning that CONFLICTS RESOLVED currently omits. It is not possible to write a Chosen/Over/Why entry without stating the rejected alternative and the reason for rejection -- the format itself is the enforcement mechanism.

### Proposed Tasks

**Task 1: Add RATIONALE section to Team Approval Gate format in SKILL.md**

- What: Add a RATIONALE block (2-3 bullets) to the Team Approval Gate presentation format. Source from meta-plan: top reasoning points for team composition, at least one notable exclusion with reason. Add Confidence indicator. Update the presentation format template and line budget (target 13-18 lines).
- Deliverables: Updated SKILL.md Team Approval Gate section
- Dependencies: None
- Constraint: RATIONALE bullets must be sourced from existing meta-plan output. If the meta-plan does not produce excerptable reasoning, that is a separate follow-up (update the meta-plan output format).

**Task 2: Add RATIONALE section to Reviewer Approval Gate format in SKILL.md**

- What: Add a RATIONALE block (2-3 bullets) to the Reviewer Approval Gate presentation format. Focus on overall composition reasoning (why this set of reviewers matters for this plan), not per-reviewer rationale (that already exists). Add Confidence indicator. Update line budget (target 10-14 lines).
- Deliverables: Updated SKILL.md Reviewer Approval Gate section
- Dependencies: None
- Constraint: Keep the existing per-reviewer rationale lines. The new RATIONALE block covers the composition as a whole, not individual picks.

**Task 3: Replace RISKS and CONFLICTS RESOLVED with DECISIONS section in Execution Plan Approval Gate**

- What: Replace the separate RISKS and CONFLICTS RESOLVED blocks with a unified DECISIONS section using Chosen/Over/Why format. Cap at 4 entries. Absorb risks as [constraint] or [trade-off] tagged decisions. Absorb conflicts as [conflict] tagged decisions. Update the phrasing from "optimized for anomaly detection" to "optimized for informed approval." Update line budget (target 30-48 lines).
- Deliverables: Updated SKILL.md Execution Plan Approval Gate section
- Dependencies: None
- Constraint: The DECISIONS section format must be compatible with the mid-execution gate RATIONALE format (both use rejected alternatives). The previous advisory's Chosen/Over/Why proposal achieves this.

**Task 4: Add good/bad RATIONALE examples to mid-execution gate in SKILL.md**

- What: Add a brief example block showing a substantive vs. shallow RATIONALE for mid-execution gates. Parallel to the good/bad advisory examples already in the Phase 3.5 reviewer verdicts section (SKILL.md lines 1150-1172). This does not change the format -- it improves execution quality by showing agents what "good" looks like.
- Deliverables: Updated SKILL.md Phase 4 gate section
- Dependencies: None
- Constraint: No format changes to the mid-execution gate. This is quality guidance, not structural change.

**Task 5: Update AGENT.md gate documentation for structural consistency**

- What: Update the AGENT.md Approval Gates section to establish that all gate types use the progressive-disclosure decision brief pattern, at density proportional to scope. Currently AGENT.md lines 338-382 define the decision brief only for mid-execution gates. Add a brief note that Team, Reviewer, and Execution Plan gates follow the same structural pattern (DECISION, RATIONALE with rejected alternatives, Confidence), with SKILL.md defining per-gate format.
- Deliverables: Updated AGENT.md Approval Gates section
- Dependencies: Tasks 1-4 (to ensure SKILL.md formats are final before AGENT.md references them)

**Task 6: Update upstream data flow (inline summaries, synthesis output, compaction)**

- What: Add a Decisions field to the inline summary template. Add a Key Design Decisions table to the synthesis output format. Update compaction focus strings to preserve decision data. This ensures the data pipeline supports the enriched gates. (Directly adopted from ai-modeling-minion's previous advisory contribution.)
- Deliverables: Updated SKILL.md inline summary template, synthesis prompt, and compaction focus strings; updated AGENT.md synthesis output format
- Dependencies: None (can proceed in parallel with Tasks 1-4)

### Risks and Concerns

**RISK: Line budget inflation across multiple gates.** Adding RATIONALE to three gates (Team, Reviewer, Execution Plan) and improving examples for a fourth (mid-execution) is additive. Total line increase across all gates: approximately 15-25 lines combined. Mitigation: RATIONALE sections at Team and Reviewer gates are capped at 2-3 bullets. The Execution Plan gate absorbs RISKS and CONFLICTS, so the net increase is smaller than the gross increase. All budgets are soft ceilings -- clarity wins over brevity.

**RISK: Meta-plan output may not produce excerptable reasoning for Team gate RATIONALE.** The meta-plan currently produces planning questions and agent selection rationale, but the excerpting quality is untested. Mitigation: if excerpting is poor, follow up with a meta-plan output format update. The Team gate RATIONALE is sourced from existing meta-plan content, not new generation.

**RISK: Scope of touching four gate types simultaneously.** The previous advisory specifically deferred non-Execution Plan gates. Doing all four at once is a larger change. Mitigation: this is the user's explicit request after evaluating the previous advisory. The structural pattern is the same across all four gates (RATIONALE + Confidence + Details), reducing the design surface. The per-gate density variation is the only thing that differs.

**RISK: Mid-execution gate quality cannot be tested without a real execution session.** We are adding examples to guide agent behavior, but we cannot verify the output quality until agents actually produce gate content in a production session. Mitigation: treat the first production sessions after this change as validation. Plan a follow-up if RATIONALE quality is poor.

**CONCERN: Report redundancy.** If gates now show fuller reasoning, the report's Key Design Decisions section may become a near-copy of gate content. The previous advisory's recommendation (software-docs-minion) to distinguish Key Design Decisions (non-gate reasoning) from Decisions (gate outcomes) addresses this. Include that distinction in TEMPLATE.md.

### Additional Agents Needed

None. The current team is sufficient. This is a prompt/format change to SKILL.md and AGENT.md. No code, no UI, no infrastructure.

### Alignment Verdict (Advisory Context)

The user's original request: "gates can be improved so that the user has the rationale of the decisions they are supposed to make in front of them."

The user's follow-up after the previous advisory: "The mid-execution gates aren't great either to base decisions on."

Scope check:
- User wants ALL gates evaluated: Tasks 1-4 cover all four gate types. PASS.
- User wants decision rationale visible at gates: RATIONALE sections with rejected alternatives at every gate. PASS.
- User wants to understand team discussions: Chosen/Over/Why format surfaces what was debated. PASS.
- No requested feature is missing from the proposal. PASS.
- No proposed feature exceeds what the user asked for. PASS (Task 6 is upstream plumbing required for the gate changes to have data to render).

The previous advisory's YAGNI-based deferral of Team/Reviewer/mid-execution gates was overridden by the user. This proposal respects that override while maintaining proportional density across gate types (lighter gates get lighter RATIONALE sections).
