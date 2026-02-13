# Domain Plan Contribution: ux-strategy-minion

## Recommendations

### 1. Collapsing to always-re-run is the correct simplification

The minor/substantial distinction is a classic case of internal system complexity leaking into interaction design. From a UX perspective, the distinction violates several principles:

- **Consistency** (Nielsen H4): Two different processing paths for the same user action ("adjust team") creates unpredictable system behavior. The user cannot predict which path they will get until they have already committed to a specific number of changes.
- **Invisible thresholds are hostile**: The spec explicitly says "classification is internal. Never surface the threshold number or classification label to the user" (line 540-541). If a distinction is invisible to the user and produces different output quality, the user has no mental model for why sometimes their adjustments produce coherent planning questions and sometimes they don't. This is the worst of both worlds: hidden complexity with visible consequences.
- **Satisficing behavior**: Users making a "minor" adjustment (adding 1 agent) still expect coherent output. They don't think "I only changed one thing, so I accept lower-quality planning questions for existing agents." They think "I changed the team, so the plan should reflect my team." The lightweight path violates this expectation silently.

Removing the minor/substantial classification eliminates extraneous cognitive load from the spec itself (fewer concepts for the orchestrator to internalize) and produces more predictable, higher-quality output for all users.

### 2. User expectation management for re-run latency

The planning question asks whether users will feel friction waiting for a full re-run after a small change. The answer: **minimal risk, but acknowledge the tradeoff.**

- The user has already demonstrated willingness to wait by entering the orchestration workflow. They chose "Adjust team" rather than "Approve team" -- they want it right, not fast.
- The re-run is a Phase 1 meta-plan regeneration, not the entire orchestration. This is a single nefario subagent call. The latency is bounded and predictable (tens of seconds, not minutes).
- **The delta summary message is the right mechanism for expectation-setting.** The existing message "Refreshed for team change (+N, -M). Planning questions regenerated." is clear and sufficient. It tells the user: (a) what changed, (b) what was regenerated, (c) implicitly that this took processing time because it was a real regeneration.
- No additional "please wait" or progress indicator is needed beyond the existing heartbeat mechanism (line 199: "for phases lasting more than 60 seconds with no output, print a heartbeat").

**Recommendation**: Keep the delta summary message as-is. It is concise, informative, and sets correct expectations. Do not add apologies, warnings about processing time, or explanations for why a re-run is happening. The user asked for a change; the system made it. That is the expected contract.

### 3. Re-run cap fallback behavior (the critical design question)

The current spec (lines 544-546) says: "Cap at 1 re-run per gate. If a second substantial adjustment occurs at the same gate, use the lightweight path." With always-re-run, there is no lightweight path to fall back to. Three options exist:

**Option A: Accept the adjustment without re-running (apply changes mechanically)**
The system applies the delta to the existing re-run output: add planning questions for new agents (generated inline by nefario, not via a full Phase 1 re-run), remove questions for dropped agents. This is analogous to the old lightweight path but reframed: it is not a "lesser" processing depth, it is the cap-reached fallback. The delta summary would read: "Team updated (+N, -M). Re-run cap reached; planning questions adjusted inline."

**Option B: Allow a second re-run (raise the cap)**
This contradicts the stated constraint "1 re-run cap per gate is preserved" from the issue's success criteria. Reject this option.

**Option C: Lock the gate after one re-run (no second adjustment)**
After the re-run, the next gate presentation offers only Approve/Reject. This is overly restrictive and violates user control (Nielsen H3). A user who made a typo in their first adjustment would be forced to either approve a wrong team or reject and restart.

**Recommendation: Option A.** The cap-reached fallback is a mechanical adjustment (add/remove planning questions for changed agents only), with a clear message that sets expectations: "Team updated (+N, -M). Planning questions adjusted inline (re-run cap reached)." This preserves user control while bounding processing costs. It is honest about what happened without introducing the minor/substantial taxonomy.

Key nuance: This is NOT the same as the old minor path. The old minor path was triggered by change count regardless of whether a re-run had already occurred. The new fallback is triggered ONLY when the re-run budget is exhausted -- a fundamentally different (and simpler) mental model. First adjustment always gets a full re-run. Second adjustment gets a mechanical adjustment. No thresholds, no classification, no ambiguity.

### 4. Interaction with the 2-adjustment-round cap

The 2-adjustment-round cap (line 599-604) works cleanly with always-re-run:

- **Round 1**: User adjusts. Full re-run. Re-present gate.
- **Round 2**: User adjusts again. Re-run cap reached. Mechanical adjustment. Re-present gate.
- **Round 3 attempt**: Cap reached. Approve/Reject only. Message: "Adjustment cap reached (2 rounds)."

This is a clean, predictable escalation: full processing -> bounded processing -> no processing. Each step narrows the user's options in a way that is transparent and justified. No hidden thresholds. No classification logic.

### 5. CONDENSE line update

The current CONDENSE line for substantial adjustments (line 191) reads: "Planning: refreshed for team change (+N, -M) | consulting <agents> (pending approval)". This language is appropriate for the always-re-run case. For the cap-reached fallback, use: "Planning: team updated (+N, -M), inline adjustment (re-run cap) | consulting <agents> (pending approval)".

### 6. Phase 3.5 Reviewer Approval Gate (out of scope but flagging)

The issue explicitly scopes out "Phase 3.5 reviewer adjustment gate." However, note that Phase 3.5 (lines 1009-1043) uses the same minor/substantial classification. If the classification is removed from the Team Approval Gate, the Phase 3.5 gate becomes the only place it survives. This creates an inconsistency: the same conceptual mechanism (adjust an agent roster at a gate) works differently at two gates. This is a consistency violation (Nielsen H4) and increases the spec's cognitive load.

This is not a blocker for the current issue but should be tracked as a follow-up. Unifying the adjustment behavior across gates would reduce spec complexity and make the orchestrator's behavior more predictable.

## Proposed Tasks

### Task 1: Update SKILL.md Team Approval Gate adjustment handling
- **What**: Remove the adjustment classification section (lines 524-549). Replace the minor/substantial paths (lines 564-598) with a single always-re-run path. Define the cap-reached fallback as a mechanical inline adjustment with a distinct delta summary message.
- **Deliverables**: Updated SKILL.md with simplified adjustment flow.
- **Dependencies**: None (this is the primary deliverable).

### Task 2: Update SKILL.md CONDENSE line for cap-reached fallback
- **What**: Add a CONDENSE line template for the cap-reached fallback case (inline adjustment). Keep the existing re-run CONDENSE line for the standard case.
- **Deliverables**: Updated CONDENSE section in SKILL.md (line 191 area).
- **Dependencies**: Task 1 (the fallback behavior must be defined before its CONDENSE line can be specified).

### Task 3: Verify AGENT.md references
- **What**: Search nefario AGENT.md for any references to minor/substantial/lightweight paths. Based on the grep search, AGENT.md contains no such references -- so this task should confirm "no changes needed" rather than produce edits.
- **Deliverables**: Confirmation that AGENT.md requires no updates (or updates if references are found).
- **Dependencies**: None.

### Task 4: Verify delta summary message wording
- **What**: Ensure the delta summary messages for both cases (re-run and cap-reached fallback) are clear, concise, and set correct user expectations. The re-run message "Refreshed for team change (+N, -M). Planning questions regenerated." is good as-is. The cap-reached message should follow the same structure: "Team updated (+N, -M). Planning questions adjusted inline (re-run cap reached)."
- **Deliverables**: Final wording for both delta summary messages, embedded in the SKILL.md updates from Task 1.
- **Dependencies**: Task 1.

## Risks and Concerns

### Risk 1: Spec inconsistency with Phase 3.5 (medium severity)
The Phase 3.5 Reviewer Approval Gate retains the minor/substantial classification. After this change, two gates in the same spec use different adjustment models. This is a consistency violation that increases cognitive load for anyone reading or implementing the spec. **Mitigation**: Track as a follow-up issue. Do not expand scope of this issue.

### Risk 2: Cap-reached fallback quality perception (low severity)
If a user hits the re-run cap and gets a mechanical inline adjustment, the resulting planning questions for newly-added agents may be less coherent than those from a full re-run. The user may perceive this as lower quality. **Mitigation**: The delta summary message explicitly states "re-run cap reached," setting the expectation that this is a bounded fallback. Users who need higher quality can reject and restart. In practice, reaching the re-run cap (round 2 of adjustments) is rare -- most users approve on the first or second presentation.

### Risk 3: No risk from removing the minor/substantial distinction itself
The minor path was an optimization that saved processing time at the cost of output quality. Removing it trades a small amount of latency for consistently better output. Since the user has already opted into a multi-phase orchestration workflow, the marginal latency of a Phase 1 re-run is negligible relative to the total orchestration time. There is no user-facing risk from this simplification.

## Additional Agents Needed

None. The current team is sufficient. This is a spec simplification task (removing complexity, not adding it), and the primary work is editing SKILL.md and potentially AGENT.md. A devx-minion could review the spec's readability after edits, but that is handled adequately by the existing cross-cutting review (lucy for intent alignment, margo for simplicity).
