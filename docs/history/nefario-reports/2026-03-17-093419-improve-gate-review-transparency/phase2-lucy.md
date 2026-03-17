## Domain Plan Contribution: lucy

### Recommendations

#### 1. This is NOT intent drift -- it is an inconsistency that the current spec already knows about

The planning question frames this as a tension between "anomaly detection" gates and "full decision briefings." Having read the full spec, I find this is a false dichotomy. The spec already commits to decision briefings at mid-execution gates -- the AGENT.md Decision Brief Format (lines 338-382) mandates RATIONALE bullets, rejected alternatives, and IMPACT for every mid-execution gate. The Anti-Fatigue Rules (lines 398-411) call rejected alternatives "the primary anti-rubber-stamping measure." The spec is clear: gates are not passive anomaly detectors. They are structured decision briefs with mandatory reasoning disclosure.

The inconsistency is that the Team Approval Gate and Execution Plan Approval Gate do not follow the same pattern. Mid-execution gates show RATIONALE + Rejected alternatives. The Team gate shows agent names + one-line rationale. The Execution Plan gate shows task lists + advisories + risks + conflict resolutions. The reasoning from specialist discussions -- the actual debate -- is absent from both pre-execution gates.

This is a consistency gap, not a philosophical tension. The spec's own stated principle is "Intuitive, Simple & Consistent" with consistency as the third priority. The proposed change fulfills the consistency mandate.

#### 2. The user's role is already "decision maker" at gates, not "anomaly detector"

The SKILL.md (line 1380) says gates are "optimized for anomaly detection." But the AGENT.md contradicts this in practice:

- Gates offer "Request changes" and "Reject" options (not just "Approve" / "Flag anomaly")
- Rejected alternatives are mandatory precisely to make the user evaluate whether they'd have chosen differently (AGENT.md line 407)
- The Confidence indicator (HIGH/MEDIUM/LOW) explicitly guides user attention allocation, implying they should read carefully at LOW confidence
- The calibration check after 5 approvals questions whether gates are serving their purpose

These are decision-maker affordances, not anomaly-detector affordances. The "anomaly detection" framing in SKILL.md line 1380 describes the *common case* (most gates are quick approvals), not the *design intent* (gates exist to catch bad decisions). The proposed change aligns with the actual design intent.

#### 3. Converge all three gate types toward the same disclosure pattern, but at different density

The fix is not to make every gate equally heavy. It is to ensure all gates have the same *structural elements* at density proportional to their scope:

| Gate Type | Current State | Proposed Convergence |
|-----------|---------------|----------------------|
| Team gate (SKILL.md line 482) | Agent list + 1-line rationale per agent | Add: 2-3 bullets on key team composition rationale. "Why these agents and not others" already lives in the meta-plan scratch file. Surface the top 2-3 reasoning points. |
| Execution Plan gate (SKILL.md line 1377) | Task list + advisories + risks + conflict resolutions | Add: RATIONALE section with 3-5 synthesis reasoning bullets including at least one rejected alternative. The CONFLICTS RESOLVED block already exists but is optional -- make it structurally parallel to mid-execution RATIONALE. |
| Mid-execution gate (AGENT.md line 338) | Full decision brief with RATIONALE + Rejected + IMPACT + Confidence | No change needed. This is already the target pattern. |

The key structural elements every gate should have:
1. **DECISION** (one-line summary) -- Team gate has this as the header line
2. **RATIONALE** (2-5 bullets with at least one rejected alternative) -- Missing from Team and Execution Plan gates
3. **Confidence** (HIGH/MEDIUM/LOW) -- Missing from Team and Execution Plan gates
4. **Details link** (to scratch file for deep-dive) -- Already present in all gates

#### 4. The rubber-stamping risk is real but the current state is worse

The planning question raises the risk that heavier gates lead to rubber-stamping from info overload. This is valid. But the current state creates a different and worse failure mode: rubber-stamping from *insufficient context*. When the user sees "5 tasks, 2 gates, 3 advisories" without understanding the reasoning, they approve by default because they lack the information to disagree. The spec's own Anti-Fatigue Rules already identified this: "Rejected alternatives mandatory... this is the primary anti-rubber-stamping measure -- it forces the user to consider whether they would have chosen differently."

Adding 3-5 RATIONALE bullets to the Team and Execution Plan gates adds approximately 5-8 lines to each. The Team gate goes from 8-12 lines to 13-20 lines. The Execution Plan gate goes from 25-40 lines to 30-48 lines. These are within the "soft ceiling, clarity wins over brevity" guidance.

#### 5. Scope containment: what this task should NOT include

The proposed change is about surfacing existing reasoning, not generating new reasoning. The specialist discussions already happen in Phase 2. The synthesis already resolves conflicts in Phase 3. The review already produces verdicts in Phase 3.5. All of this reasoning exists in scratch files. The task is to select the most decision-relevant reasoning and present it at the gate.

What this task should NOT do:
- Add new reasoning phases or analysis steps
- Change the gate interaction model (approve/adjust/reject options)
- Add new gate types
- Modify the mid-execution gate format (it already has the target pattern)
- Change the calibration check or anti-fatigue rules
- Add user-configurable verbosity levels for gates (YAGNI)

### Proposed Tasks

**Task 1: Add RATIONALE section to Team Approval Gate format in SKILL.md**

- What: Add a RATIONALE block (2-3 bullets) to the Team Approval Gate presentation format (SKILL.md lines 491-508). Include at least one "Not selected: [agent] because [reason]" entry. Source the rationale from the meta-plan output (phase1-metaplan.md already contains exclusion reasoning). Add Confidence indicator.
- Deliverables: Updated SKILL.md Team Approval Gate section
- Dependencies: None
- Constraint: Keep within 13-20 line budget for the gate. The rationale displaces no existing content; it inserts between the SELECTED/ALSO AVAILABLE blocks and the Details link.

**Task 2: Add RATIONALE section to Execution Plan Approval Gate format in SKILL.md**

- What: Add a RATIONALE block (3-5 bullets with at least one rejected alternative) to the Execution Plan Approval Gate format (SKILL.md lines 1383-1467). Rename the existing CONFLICTS RESOLVED block to integrate with RATIONALE or keep as a sub-section. Source the rationale from synthesis output (phase3-synthesis.md). Add Confidence indicator.
- Deliverables: Updated SKILL.md Execution Plan Approval Gate section
- Dependencies: None
- Constraint: Keep within 30-48 line budget. Rationale bullets should summarize the synthesis reasoning, not duplicate it. The Details link to phase3-synthesis.md already provides the full deep-dive.

**Task 3: Update AGENT.md gate documentation for consistency**

- What: Update the AGENT.md Approval Gates section to state that all gate types use the progressive-disclosure decision brief pattern, at density proportional to scope. Currently AGENT.md lines 338-382 define the decision brief only for mid-execution gates. The gate classification section (lines 308-336) does not reference the Team or Execution Plan gates. Add a brief note establishing that the decision brief pattern (DECISION, RATIONALE with rejected alternatives, Confidence) applies to all gates, with the SKILL.md defining the per-gate format.
- Deliverables: Updated AGENT.md Approval Gates section
- Dependencies: Tasks 1 and 2 (to ensure SKILL.md formats are final before AGENT.md references them)

**Task 4: Update Communication Protocol SHOW list**

- What: The SHOW list in SKILL.md (lines 169-172) already mentions "Team approval gate (specialist list with rationale)" and "Execution plan approval gate (task list, advisories, risks, review summary)". Update these descriptions to reflect the added RATIONALE sections. Minor edit: add "decision rationale, rejected alternatives" to both entries.
- Deliverables: Updated SKILL.md Communication Protocol section
- Dependencies: Tasks 1 and 2

### Risks and Concerns

**RISK: Line budget inflation makes gates unreadable.** The Team gate currently targets 8-12 lines. Adding RATIONALE could push past 20 if not disciplined. Mitigation: hard cap the RATIONALE block at 3 bullets for Team gate, 5 bullets for Execution Plan gate. The Details link already provides unlimited depth.

**RISK: Synthesis reasoning is too verbose to excerpt cleanly.** The phase3-synthesis.md output may not produce reasoning in a format that excerpts well into 3-5 bullets. Mitigation: the synthesis prompt (AGENT.md MODE: SYNTHESIS) should already produce structured reasoning. If it does not, this is a separate task (updating the synthesis output format) that should be tracked but not included in this scope.

**RISK: "Rejected alternative" at the Execution Plan level is ambiguous.** At mid-execution gates, the rejected alternative is concrete (e.g., "Rejected: PostgreSQL enum over string column because migrations are harder"). At the plan level, rejected alternatives are architectural (e.g., "Rejected: single-agent approach because the task spans 3 domains"). These require different phrasing guidance. Mitigation: add a brief note in SKILL.md that plan-level rejected alternatives describe rejected *approaches*, not rejected *implementations*.

**CONCERN: SKILL.md line 1380 "optimized for anomaly detection" is now misleading.** If RATIONALE sections are added, gates are optimized for informed decision-making, with anomaly detection as the fast path. The phrasing should be updated. This is a small edit but matters for future agent behavior -- the phrasing guides how nefario constructs gates.

### Additional Agents Needed

None. The current team is sufficient. This is a prompt/format change to SKILL.md and AGENT.md -- it does not involve code, UI, security, or infrastructure decisions. The task is squarely within nefario's orchestration domain with lucy providing alignment review.

One note: if the synthesis output format needs updating to produce excerptable reasoning (see Risk 2 above), that would be a separate follow-up task, not part of this scope. If the planning team discovers during execution that the synthesis output does not support clean excerpting, they should flag it as a deferred task rather than expanding this scope.
