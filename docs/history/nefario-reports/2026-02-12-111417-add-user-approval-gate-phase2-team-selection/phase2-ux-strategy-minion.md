## Domain Plan Contribution: ux-strategy-minion

### Recommendations

#### 1. The Gate Should Be Lightweight -- Not a Second "Execution Plan Gate"

The existing Execution Plan Approval Gate (after Phase 3.5) is the heavyweight checkpoint in the user's journey. It presents tasks, advisories, risks, review summaries -- 25-40 lines of structured output. This new team selection gate must be categorically lighter. If it feels like "two big gates before anything happens," the user will experience approval fatigue and start rubber-stamping both.

The right mental model: the team selection gate is a **glance-and-confirm** checkpoint, not a **study-and-decide** checkpoint. Think of it as the "Are these the right people to invite to the meeting?" question, not the "Here is the full meeting agenda for your approval" question.

**Recommended cognitive weight**: 5-10 lines of output. One structured prompt. No secondary follow-ups. The user should spend under 10 seconds on this gate in the common case.

#### 2. Information Hierarchy: What the User Needs to Decide

The user needs exactly three things to make a team selection decision:

1. **Who** is being consulted (agent names)
2. **Why** each agent was selected (one-line rationale -- not the planning question)
3. **Who was considered but excluded** (so the user can add them back)

The user does NOT need at this point:
- The specific planning questions (those are implementation details of Phase 2)
- The cross-cutting checklist evaluation (internal bookkeeping)
- External skill discovery results (already condensed in the CONDENSE line)
- The full meta-plan rationale for each exclusion

This follows progressive disclosure: show the decision surface (who/why/who-else), defer the implementation details (questions, checklist reasoning) to the scratch file.

#### 3. Presentation Format: Compact Table + Exclusion Note

```
TEAM: <1-sentence task summary>
Specialists: N selected | N considered, excluded

  SELECTED:
    devx-minion       Workflow integration, SKILL.md structure
    ux-strategy-minion  Approval gate interaction design
    lucy              Governance alignment for new gate

  ALSO AVAILABLE (not selected):
    ai-modeling-minion, margo, software-docs-minion, security-minion, ...

Full meta-plan: $SCRATCH_DIR/{slug}/phase1-metaplan.md
```

Design rationale:
- **SELECTED** block uses agent name + one-line rationale (not the planning question). This is enough for the user to evaluate "does this person belong in the room?"
- **ALSO AVAILABLE** is a flat comma-separated list, not a table. The user scans it for surprises ("wait, why isn't security-minion consulting?") rather than reading each entry. This is the progressive disclosure layer -- details are in the meta-plan scratch file.
- **Full meta-plan** link lets the user deep-dive if they want to see the planning questions, exclusion rationale, or cross-cutting checklist. Most users will not click this.
- Total: 8-12 lines. Under the 25-40 line budget of the execution plan gate.

#### 4. Decision Options: Three Options, Default Is Approve

```
AskUserQuestion:
  header: "Team"
  question: "<1-sentence task summary>"
  options (3, multiSelect: false):
    1. label: "Approve team"
       description: "Consult these N specialists and proceed to planning."
       (recommended)
    2. label: "Adjust team"
       description: "Add or remove specialists before planning begins."
    3. label: "Reject"
       description: "Abandon this orchestration."
```

Design rationale:
- Three options, not four or five. Hick's Law: fewer choices = faster decisions.
- "Approve team" is the default/recommended path. The satisficing user clicks this in under 3 seconds.
- "Adjust team" replaces separate "Add" and "Remove" options. Combining them into one option reduces choice complexity at the gate. The add/remove interaction happens in the follow-up, not at the gate itself.
- "Reject" mirrors the execution plan gate's "Reject" option for consistency. Users build a transferable mental model: every gate has an escape hatch.
- No "Request changes" option (unlike the execution plan gate). The team selection is simple enough that "Adjust team" covers it. There is nothing to "change" in the meta-plan itself -- the user either wants different agents or doesn't.

#### 5. "Adjust Team" Follow-Up: Freeform, Not Structured

When the user selects "Adjust team," do NOT present a multi-select list of 27 agents. That would be overwhelming (Hick's Law violation with 27 options) and would require the user to know what each agent does.

Instead, use a brief conversational follow-up:

```
Which specialists should be added or removed?
Refer to agents by name or domain (e.g., "add security-minion" or "drop lucy").
Agent roster: $SCRATCH_DIR/{slug}/phase1-metaplan.md (or see nefario/AGENT.md for full list)
```

This works because:
- The user already knows what they want to change (they selected "Adjust team" for a reason).
- Agent names are descriptive enough to identify by domain ("the security one", "margo").
- A 27-item structured list would be a worse experience than freeform input for this case.
- Nefario can interpret natural language requests: "also ask the security person" is unambiguous.

After the adjustment, nefario generates planning questions for any newly added agents (the user should not have to provide these -- that is nefario's job). Then re-present the gate with the updated team for final confirmation. Cap at 2 adjustment rounds to prevent infinite loops.

#### 6. CONDENSE Line: Split Into Before/After

The current CONDENSE line fires after the meta-plan returns:
```
Planning: consulting devx-minion, security-minion, ... | Skills: N discovered | Scratch: <path>
```

With the new gate, this line should fire AFTER the gate is approved (not before). The user should not see the agent list condensed into a single line and THEN be asked to approve it -- that creates a jarring sequence where information is compressed then immediately expanded.

Recommended flow:
1. Meta-plan returns (silent -- existing behavior)
2. Present the TEAM gate (new)
3. User approves/adjusts
4. CONDENSE line fires: `Planning: consulting devx-minion, security-minion, ... (approved) | Skills: N discovered | Scratch: <path>`

The `(approved)` marker is a micro-signal that confirms the gate was passed. It aids context recovery after compaction.

#### 7. Relationship to Execution Plan Gate: Mental Model Coherence

The user's journey now has two named gates:
- **Team gate** (after Phase 1): "Who should plan this?"
- **Plan gate** (after Phase 3.5): "Is this plan good?"

These are naturally sequential decisions with increasing commitment:
1. Team gate = low stakes (choosing who to consult costs compute but is easily reversible)
2. Plan gate = high stakes (approving execution commits to code changes)

This escalating-commitment model is intuitive. The risk is if the team gate feels redundant when the plan gate already exists. To counter this, the team gate must be visibly lighter (fewer lines, fewer options, faster to process). If users start saying "I always just approve the team," that is a signal the gate is working correctly for common cases -- it exists for the uncommon case where nefario selects a surprising team.

#### 8. MODE: PLAN Behavior

When the user invokes `MODE: PLAN` (simplified process), this gate should still appear. MODE: PLAN skips specialist consultation (Phase 2) entirely, but the user should still see nefario's proposed team before it is bypassed. This gives the user the option to say "actually, let's do the full process with these specialists" -- upgrading from PLAN to full mode.

However, if the team has zero specialists (MODE: PLAN may not generate a team), skip the gate. Do not present an empty approval checkpoint.

#### 9. Anti-Fatigue: Gate Budget Accounting

The existing anti-fatigue guidelines budget 3-5 approval gates per plan. The team gate is a new mandatory gate. It should count toward the budget but be weighted as "half a gate" in the anti-fatigue calculus because:
- It is a glance-and-confirm interaction, not a study-and-decide interaction
- It has 3 options (not 4), no secondary follow-ups in the approve path
- It takes under 10 seconds in the common case

Recommendation: do NOT increment the calibration counter (the "5 consecutive approvals" check). The team gate approval is a different class of decision from execution gates. Mixing them in the fatigue counter would trigger false positives.

### Proposed Tasks

#### Task 1: Add Team Selection Gate to SKILL.md
- **What**: Insert a new section between Phase 1 and Phase 2 in `skills/nefario/SKILL.md`. Define the gate presentation format, AskUserQuestion options, response handling (approve/adjust/reject), CONDENSE line repositioning, and adjustment follow-up workflow.
- **Deliverables**: Updated `skills/nefario/SKILL.md` with the team selection gate section
- **Dependencies**: None (but must be informed by all planning contributions)
- **Key constraints**:
  - Gate output must be 5-12 lines (under the execution plan gate's 25-40 line budget)
  - "Approve team" must be the recommended default
  - "Adjust team" uses freeform follow-up, not structured multi-select
  - CONDENSE line moves to after gate approval
  - Gate is skipped only if MODE: PLAN produces no specialist team
  - Cap adjustment rounds at 2

#### Task 2: Update docs/orchestration.md
- **What**: Update the orchestration documentation to reflect the new Phase 1.5 team selection gate. Add it to the Approval Gates section. Update the Phase 1 and Phase 2 descriptions.
- **Deliverables**: Updated `docs/orchestration.md`
- **Dependencies**: Task 1 (the SKILL.md changes define the gate; docs describe it)

### Risks and Concerns

1. **Approval fatigue from two pre-execution gates**: The primary risk. If the team gate feels like "just another thing to click through," users will rubber-stamp it, defeating the purpose. Mitigation: keep it visibly lighter than the execution plan gate (fewer lines, fewer options, no secondary prompts). Monitor via the calibration mechanism -- if users approve 100% of teams without adjustment, the gate may be unnecessary overhead.

2. **"Adjust team" generating planning questions for new agents**: When the user adds a specialist, nefario must generate a planning question for them. This requires a mini meta-plan operation. If this takes noticeable time (spawning nefario again), the adjustment flow feels sluggish. Mitigation: nefario should generate questions locally (no subagent spawn for a single question) or batch all adjustments into one additional meta-plan call.

3. **CONDENSE line timing creates a gap in the Communication Protocol**: Moving the CONDENSE line to after the gate means there is a brief period (during gate presentation) where the meta-plan result is not condensed. If context compaction happens during this window, the meta-plan details could be lost. Mitigation: the gate presentation itself contains the agent list, so the information is present in context even without the CONDENSE line.

4. **Gate placement in the "NEVER SHOW" / "SHOW" taxonomy**: The Communication Protocol has explicit SHOW and NEVER SHOW lists. The team gate must be added to the SHOW list. If it is accidentally omitted, the orchestrator might suppress it following the "never show phase transition announcements" rule.

### Additional Agents Needed

None. The current planning team (ux-strategy-minion, devx-minion, lucy) covers the three relevant domains: interaction design, workflow integration, and governance alignment. The task scope is bounded to two files (SKILL.md, orchestration.md) with no code, security, or testing implications beyond what Phase 3.5 mandatory reviewers will catch.
