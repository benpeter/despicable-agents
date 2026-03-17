# Domain Plan Contribution: ux-strategy-minion

## Recommendations

### 1. The Gate Decision Job Is Anomaly Detection, Not Comprehension

The JTBD at the Execution Plan Approval Gate is unchanged from the prior iteration (2026-02-10-170603): "When the orchestrator presents an execution plan, I want to verify it will accomplish my goal without unnecessary risk or wasted effort, so I can greenlight execution with confidence."

What has changed is the user's complaint: the current gate succeeds at the task-scanning job but fails at the _rationale_ job. The user cannot distinguish a plan that reflects careful deliberation from one that reflects lazy consensus. The task list and advisories answer "what will happen" but not "what was debated and why." The user's real need is a confidence signal: did the specialist team actually wrestle with the hard questions, or did they all agree too easily?

This is still anomaly detection -- but the anomalies being detected are different:
- **Task-level anomalies**: "Why is there a task I didn't expect?" (current gate handles this)
- **Decision-level anomalies**: "Why was approach X chosen over approach Y?" (current gate does NOT handle this)
- **Conflict-level anomalies**: "Did specialists disagree, and was the resolution sensible?" (current gate barely handles this -- one-line CONFLICTS RESOLVED entries)

### 2. The WRL decisions.md Format Is the Target Quality -- But Not the Target Container

The WRL `decisions.md` format (e.g., `0025-rfc3161-timestamps/decisions.md`) is excellent reference documentation. Each decision is self-contained: Decision, Alternatives considered, Rationale, and optionally Conflict/Resolution. Reading any single entry gives complete understanding without needing to read any other file.

However, this format is designed for _archival reference_ (someone revisiting a decision weeks later), not for _real-time approval_ (someone deciding whether to proceed in 60-90 seconds). The key differences:

| Dimension | WRL decisions.md | Gate context |
|-----------|-----------------|--------------|
| Reading time budget | Unbounded | 60-90 seconds |
| Reader familiarity | Low (revisiting) | High (just asked for this) |
| Primary action | Understand | Approve/reject |
| Density tolerance | High (reference) | Low (decision fatigue) |
| Completeness need | Every decision | Only contested/surprising ones |

The right approach is to bring WRL-quality self-containment INTO the gate, but at gate-appropriate density. Not every decision gets the full treatment -- only the ones that would change the user's approve/reject judgment.

### 3. Decision Triage: Which Decisions Belong in the Gate

Not all decisions from synthesis deserve gate-level visibility. Apply a signal-to-noise filter:

**MUST show in gate** (high decision relevance):
- Decisions where specialists disagreed (conflicts). These are the highest-signal items -- disagreement means the answer was not obvious, and the user should validate the resolution.
- Decisions where a significant alternative was rejected. If a reasonable person could have chosen differently, the user should see why this path was taken.
- Decisions driven by constraints the user may not be aware of (runtime limits, platform constraints, security requirements). These "invisible walls" shape the plan without being obvious from the task list.

**MAY show in gate** (medium decision relevance):
- Decisions where the user's original request was reinterpreted or scoped differently than asked. The user asked for X, the plan delivers X-prime -- they need to know why.
- Risk-driven decisions where a safer-but-slower approach was chosen over a faster-but-riskier one.

**MUST NOT show in gate** (implementation detail):
- Agent assignment decisions (who does what -- this is routing, not substance)
- Model selection decisions (opus vs sonnet)
- Sequencing decisions that follow directly from dependencies (obvious ordering)
- Decisions where all specialists agreed and no alternative was seriously considered (consensus without contest)

### 4. Proposed Gate Information Architecture: The "Decisions Brief"

Extend the current Execution Plan Approval Gate format with a new DECISIONS section that sits between ADVISORIES and RISKS. This is the layer that bridges the gap between "what the plan does" (task list + advisories) and "why the plan does it this way" (full synthesis file).

**Current structure** (lines 1377-1467 of SKILL.md):
```
Instant orientation
Task list
Advisories (CHANGE/WHY per advisory)
Risks and conflict resolutions (one-liners)
Review summary
Full plan reference
```

**Proposed structure**:
```
Instant orientation
Task list
Advisories (CHANGE/WHY -- unchanged)
Decisions brief (NEW -- 2-4 key decisions, self-contained)
Review summary
Full plan reference
```

The RISKS and CONFLICTS RESOLVED sections are absorbed into the Decisions Brief. Currently, risks are one-liners (`<risk> -- Mitigation: <approach>`) and conflicts are one-liners (`<contested thing>: Resolved in favor of <approach> because <rationale>`). These are too terse to be useful -- the user can see that something was resolved but not why they should care, and cannot evaluate whether they would have resolved it differently.

### 5. Decisions Brief Format

Each decision in the brief follows a compressed version of the WRL decisions.md format, optimized for gate-time reading:

```
DECISIONS:
  1. <Decision title>                                     [conflict | trade-off | constraint]
     Chosen: <what the plan does>
     Over: <primary rejected alternative>
     Why: <one sentence rationale, self-contained>

  2. <Decision title>                                     [conflict | trade-off | constraint]
     Chosen: <what the plan does>
     Over: <primary rejected alternative>
     Why: <one sentence rationale, self-contained>
```

Format rules:
- Maximum 4 decisions in the brief. If synthesis produced more than 4 decision-worthy items, nefario must triage to the 4 highest-signal ones (conflicts first, then constraint-driven trade-offs, then scope reinterpretations). Remaining decisions go in the linked synthesis file only.
- Each decision is 4 lines: title + tag, Chosen, Over, Why. The tag in brackets classifies the decision type so the user can calibrate attention: `[conflict]` means specialists disagreed; `[trade-off]` means alternatives had merit; `[constraint]` means an external factor forced the choice.
- The "Over" line is mandatory. This is the rejected alternative that makes the decision meaningful. Without it, the decision is just an assertion, not a real choice. The "Over" field directly inherits the WRL self-containment principle: a reader seeing only this decision can understand what was chosen AND what was not chosen.
- The "Why" line must be self-contained (no references to "as discussed", "per the review", "in Phase 2"). It uses domain language, not orchestration language.
- If a decision is a conflict resolution, prepend the "Why" line with the resolution framing: "Why: <domain-A> argued <X>, <domain-B> argued <Y>. Resolved: <rationale>." This is more expensive (longer line) but conflicts deserve the extra context.

**Self-containment test**: A reader seeing only the Decisions Brief (without the task list, advisories, or synthesis file) should be able to answer: (a) what was the hard question, (b) what was chosen, (c) what was rejected, (d) why. If any of those four are missing, the decision entry fails the test.

### 6. Impact on Line Budget

The current gate targets 25-40 lines. Adding the Decisions Brief adds 4-16 lines (1-4 decisions at 4 lines each). This pushes the budget to 29-56 lines in the worst case. However:

- The RISKS and CONFLICTS RESOLVED sections (currently 2-6 lines) are absorbed into the Decisions Brief, recovering some space.
- The 4-decision cap limits the worst case.
- Many plans will have 0-2 decisions worthy of the brief (consensus plans where specialists agreed), keeping the actual output near the current range.

Proposed updated budget: **25-50 lines** (soft guidance). The increase is justified because the additional lines carry the highest-information-density content in the entire gate -- these are the lines most likely to change an approve/reject decision.

### 7. The "Scanning for Anomalies" vs "Understanding Rationale" Distinction

These are two different cognitive modes, and the gate must support both without forcing either:

**Scanning mode** (most approvals): The user glances at the orientation line, scans the task list for surprises, notes the advisory count, and approves. Total time: 10-20 seconds. For this user, the Decisions Brief is skippable -- its presence signals "the team debated things" but the user trusts the resolution without reading the details.

**Rationale mode** (contested/complex plans): The user reads the task list, reads the advisories, then reads the Decisions Brief to understand the trade-offs. They may disagree with a resolution and request changes. Total time: 60-120 seconds.

The progressive disclosure design supports both modes because the Decisions Brief is a _section_ that can be skimmed over, not a _prerequisite_ for the task list and advisories. The user who scans sees the section exists and can skip it. The user who reads sees self-contained decisions and can evaluate them. Neither mode requires reading the synthesis file.

### 8. Mid-Execution Gates Already Have the Right Structure

The Phase 4 mid-execution gate format (lines 1603-1632 of SKILL.md) already includes RATIONALE with rejected alternatives and DECISION with a summary. These are decision briefs for single-task deliverables. The proposal here extends the same principle to the _plan-level_ gate, where the decisions are about the plan's design choices rather than a single agent's output.

No changes are needed to the mid-execution gate format. The Decisions Brief is specific to the Execution Plan Approval Gate.

### 9. Process Narrative Belongs in the Report, Not the Gate

The WRL `process.md` format (e.g., `0025-rfc3161-timestamps/process.md`) provides rich narrative: which specialists argued what, how the discussion evolved, where humans intervened. This is valuable for institutional memory but is the wrong information for a gate decision.

At the gate, the user needs _conclusions_ (what was decided and why), not _process_ (who said what when). Process narrative belongs in:
- The execution report (generated at wrap-up, already has an Agent Contributions section)
- The synthesis scratch file (already exists, already linked from the gate)

Do not add process narrative to the gate. It would triple the gate size, shift the reading mode from "decide" to "follow a story", and violate the 60-90 second attention budget.

### 10. Decisions Section Should Be Omittable

When synthesis produces no conflicts, no rejected alternatives worth noting, and no constraint-driven trade-offs -- i.e., when all specialists agreed on an obvious approach -- the Decisions Brief section should be omitted entirely (like the current CONFLICTS RESOLVED section). Its absence is itself a signal: "this plan was straightforward, no hard choices were made." Do not print an empty section or "No decisions to highlight."

## Proposed Tasks

### Task 1: Define the Decisions Brief format in SKILL.md

**What to do**: Add a DECISIONS section to the Execution Plan Approval Gate specification in SKILL.md. Define the 4-line-per-decision format (title + tag, Chosen, Over, Why), the 4-decision cap, the triage rules (conflicts first, then trade-offs, then constraints), and the self-containment test. Absorb the current RISKS and CONFLICTS RESOLVED sections into the Decisions Brief (risks become decisions tagged `[constraint]` or `[trade-off]`; conflicts become decisions tagged `[conflict]`). Update the line budget guidance from 25-40 to 25-50.

**Deliverables**: Updated SKILL.md Execution Plan Approval Gate section.

**Dependencies**: None -- this is a format specification that can be written first.

### Task 2: Update nefario AGENT.md synthesis output to produce decision metadata

**What to do**: Extend the SYNTHESIS mode delegation plan template in AGENT.md. The current "Conflict Resolutions" and "Risks and Mitigations" sections must be restructured to emit structured decision metadata that the calling session can project into the Decisions Brief format. Each decision needs: title, type tag (conflict/trade-off/constraint), chosen approach, primary rejected alternative, rationale, and (for conflicts) the arguing positions. Nefario performs the triage during synthesis: it selects the top 4 decisions for gate visibility and marks the rest as synthesis-only.

**Deliverables**: Updated AGENT.md synthesis output format with structured decisions section.

**Dependencies**: Depends on Task 1 (the gate format defines what synthesis must produce). However, the current "Conflict Resolutions" format in AGENT.md is loosely specified enough that Task 2 can proceed in parallel with a draft of the target format.

### Task 3: Update orchestration.md to document the Decisions Brief

**What to do**: Update the approval gates section of docs/orchestration.md to distinguish the Execution Plan Approval Gate's Decisions Brief from mid-execution gate rationale bullets. Document the triage criteria for which decisions appear in the brief.

**Deliverables**: Updated docs/orchestration.md.

**Dependencies**: Depends on Tasks 1 and 2.

## Risks and Concerns

### Risk 1: Nefario synthesis quality determines decision brief quality

The Decisions Brief is only as good as the synthesis agent's ability to identify, triage, and articulate the key decisions. If nefario summarizes conflicts poorly or misidentifies which decisions are gate-worthy, the brief will be misleading. This is a prompt engineering challenge, not a format challenge. Mitigation: the Phase 3.5 architecture reviewers (especially lucy and margo) review the synthesis output and can flag poor triage before the gate is presented.

### Risk 2: The "Over" field requires synthesis to track rejected alternatives

Currently, synthesis resolves conflicts and moves on -- it does not always record what was rejected. The Decisions Brief requires this information. If synthesis doesn't capture it during the resolution, it cannot be reconstructed at gate-presentation time. This is the same data-flow concern identified in the prior iteration (Risk 2 from 2026-02-10-170603) but now applies to decisions, not just advisories. Mitigation: make "rejected alternative" a required field in the synthesis conflict resolution format.

### Risk 3: Decision cap of 4 may frustrate power users

Some users may want to see ALL decisions at the gate, not just the top 4. The 4-cap is grounded in cognitive load research (7 plus or minus 2 items, minus the other gate sections consuming working memory slots), but it is a design choice that trades completeness for usability. Mitigation: the linked synthesis file contains all decisions. The cap is presented as a triage, not a filter -- the gate says "4 key decisions" not "4 decisions", signaling that more exist.

### Risk 4: Tension with "soft ceiling" culture

The project uses soft line budgets everywhere (25-40 lines "soft guidance", 12-18 lines "soft ceiling"). Adding a new section that can add up to 16 lines risks gradual gate bloat as nefario consistently includes 4 decisions even when 1-2 would suffice. Mitigation: the triage rules should emphasize that 0-2 decisions is the common case. The 4-decision cap is a maximum, not a target. Include explicit guidance: "Most plans will have 0-2 key decisions. Reaching the 4-decision cap suggests an unusually contested plan."

### Risk 5: Self-containment test is hard for an LLM to self-evaluate

The format specifies a self-containment test ("a reader seeing only this decision can answer: what was the hard question, what was chosen, what was rejected, why"). LLMs are not reliable at self-evaluating whether their output meets abstract quality criteria. Mitigation: The self-containment test is more useful as a design principle guiding the format than as a runtime check. The structured fields (Chosen, Over, Why) mechanically enforce self-containment by requiring each piece of information to be present.

## Additional Agents Needed

None. The current team composition (assuming devx-minion for CLI formatting constraints and software-docs-minion for documentation updates) covers the design space. Lucy and margo will review in Phase 3.5 as mandatory reviewers. The task is a format specification change to existing files, not a new system or interface.
