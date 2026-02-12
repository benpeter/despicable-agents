## Domain Plan Contribution: ux-strategy-minion

### Recommendations

#### 1. Make the threshold invisible; surface only the recommendation

The user's mental model at the adjustment step is: "I want to change who's on this team." They are not thinking in terms of "how many agents constitutes a substantial change." Exposing the 3-agent threshold would force them to count, predict system behavior, and second-guess their input -- textbook extraneous cognitive load.

Instead, after the user provides their freeform adjustment, nefario should classify the change silently and present the outcome as a recommendation within the existing gate structure. Two paths:

- **Lightweight path (1-2 agents changed):** Behave exactly as today. Generate planning questions for added agents, re-present the gate. The user never sees anything about thresholds. No new decision point.

- **Re-run path (3+ agents changed):** Re-present the gate with a single additional line explaining what will happen and why. The key design principle: **recommend the re-run as a default action, not as a question.** The user should see a recommendation they can override, not a fork they must resolve.

This follows the "don't make me think" principle. The system absorbs the classification complexity; the user sees only the result.

#### 2. Frame re-run as "refresh" not "restart" -- preserve the adjustment mental model

This is the critical mental model risk. If the re-run feels like "starting over," two bad things happen: (a) the user feels their time was wasted, and (b) the new gate presentation feels like a different gate rather than the same gate with updated content. Both break the user's sense of continuity and control.

Design the re-run path so that:

- **The gate is the same gate.** Same header, same AskUserQuestion structure, same options. The user is still "adjusting their team." The re-run happens behind the scenes as an implementation detail of how nefario fulfills the adjustment.
- **Show what changed, not what was rebuilt.** When re-presenting after a re-run, add a delta line: "Re-planned with updated team. Changes from original: +agent-a, +agent-b, -agent-c, -agent-d, planning questions regenerated." This anchors the user to their original context and makes the new result feel like an evolution, not a replacement.
- **Never say "re-running Phase 1" or "re-planning."** These are system-internal concepts. The user asked to adjust the team; the system is adjusting the team. How thoroughly it does so is the system's business.

Suggested CONDENSE line after re-run completes (replaces the original):
```
Planning: refreshed for team change (+3, -1) | consulting devx-minion, security-minion, ... (pending approval)
```

#### 3. The re-run result fits naturally into the existing gate -- no reshaping needed

The "no additional approval gates" constraint is satisfied if we treat the re-run as part of the adjustment flow. The sequence is:

1. User selects "Adjust team"
2. User provides freeform input
3. Nefario classifies change magnitude (invisible to user)
4. **If lightweight:** generate questions for new agents, re-present gate (existing behavior)
5. **If substantial:** re-run planning phase, then re-present gate with updated team and delta summary

In both cases, the user ends up at step 4 of the existing "Adjust team" flow: "Re-present the gate with the updated team for confirmation." The gate shape is identical. No new gate is introduced. The only difference is how much work nefario does between step 2 and the re-presentation.

#### 4. Adjustment round cap interaction

The 2-round adjustment cap must count re-runs as adjustment rounds. A re-run IS an adjustment round -- a thorough one. If the user adjusts once (lightweight), then adjusts again triggering a re-run, that's round 2. After that, they get Approve/Reject only. This prevents infinite re-planning loops and keeps the gate budget intact.

Do NOT reset the adjustment counter after a re-run. From the user's perspective, they've adjusted twice. The fact that the second adjustment was more thorough is an implementation detail.

#### 5. Reviewer Approval Gate: same pattern, smaller scope

The Reviewer Approval Gate has a tighter decision space (6-member discretionary pool vs. 27-agent roster). The "substantial change" threshold should be proportional. For a pool of 6, changing 3+ is genuinely a different review strategy. The same invisible-threshold-with-recommendation pattern applies:

- 1-2 reviewers changed: lightweight (swap them, no re-run)
- 3+ reviewers changed: recommend re-running reviewer selection logic

However, for the Reviewer Gate, there's less to "re-run" -- the synthesis plan doesn't change based on who reviews it. The re-run here is really "re-evaluate which discretionary reviewers are appropriate given the changed pool." This is a lighter operation and should feel lighter to the user too. No "refreshed" language needed; just re-present the gate with updated selections.

#### 6. Structured choice over freeform for the re-run decision

When nefario determines a re-run is warranted, do NOT ask a freeform question. Do NOT add a new AskUserQuestion with "re-run or lightweight?" options. Instead, present it as an informational note within the existing re-presentation:

```
TEAM: <1-sentence task summary>
Note: Team changed substantially (+3, -1). Planning questions regenerated for updated composition.
Specialists: N selected | N considered, not selected

  SELECTED:
    ...
```

The user sees the result of the re-run, not the decision about whether to re-run. This eliminates the secondary decision point entirely. If the user doesn't like the result, they still have "Adjust team" (if within cap) or "Reject."

This is the most important recommendation: **the re-run is not a user decision, it is a system behavior triggered by the magnitude of the user's adjustment.** The user decides WHAT to change. The system decides HOW THOROUGHLY to process that change. Separating these concerns eliminates the cognitive load of the secondary decision point.

### Proposed Tasks

#### Task 1: Define change classification logic in SKILL.md
- **What:** Add a section to both gate specifications defining how nefario classifies adjustment magnitude. Threshold: 3+ agents changed at Team Gate, 3+ reviewers changed at Reviewer Gate. Classification is internal -- never surfaced to the user.
- **Deliverables:** Updated "Adjust team" and "Adjust reviewers" response handling sections in SKILL.md.
- **Dependencies:** None.

#### Task 2: Define re-run behavior for Team Approval Gate
- **What:** Specify what "re-run" means for the Team Gate: re-execute Phase 1 meta-planning with the adjusted roster as a constraint, regenerate planning questions for all selected agents (not just added ones, since the team composition shift may change what's relevant). Define the CONDENSE line format for refreshed plans. Define the delta summary format shown in the re-presented gate.
- **Deliverables:** Updated Phase 1 / Team Gate sections in SKILL.md with re-run flow.
- **Dependencies:** Task 1 (classification logic).

#### Task 3: Define re-run behavior for Reviewer Approval Gate
- **What:** Specify what "re-run" means for the Reviewer Gate: re-evaluate discretionary reviewer selection given the changed pool. Lighter than Team Gate re-run since the synthesis plan itself doesn't change. Define the re-presented gate format.
- **Deliverables:** Updated Reviewer Gate section in SKILL.md with re-run flow.
- **Dependencies:** Task 1 (classification logic).

#### Task 4: Validate adjustment cap interaction with re-runs
- **What:** Explicitly document that re-runs count as adjustment rounds toward the 2-round cap. Add a worked example to the spec showing: round 1 lightweight adjust, round 2 triggers re-run, round 3 attempt gets Approve/Reject only.
- **Deliverables:** Updated cap documentation in both gate sections.
- **Dependencies:** Tasks 2, 3.

### Risks and Concerns

1. **Re-run latency breaks the "adjustment" mental model.** A lightweight adjustment is fast (seconds). A re-run of Phase 1 meta-planning could take 30-60+ seconds. If the user expects adjustment-speed response and gets planning-speed response, the mismatch creates confusion ("did something break?"). Mitigation: use the existing heartbeat mechanism ("Refreshing plan for updated team...") during re-run. The heartbeat should use "refreshing" language, not "re-running Phase 1" language.

2. **Re-run produces a substantially different plan that confuses the user.** If the user changed 3 agents expecting minor adjustments but the re-run produces a fundamentally different meta-plan (different planning questions, different agent rationales), the delta between what they expected and what they got creates cognitive dissonance. Mitigation: the delta summary ("Changes from original: ...") anchors the user. But if the delta is large, the user may feel they've lost control. This is an inherent tension -- a large roster change SHOULD produce a different plan. The delta summary is the right tool but may not fully resolve the feeling.

3. **Threshold feels arbitrary at the boundary.** Changing exactly 3 agents triggers a re-run; changing 2 does not. The user doesn't see the threshold, but they'll notice the behavioral difference between adjustment rounds if they experiment. Mitigation: since the threshold is invisible and the outcome is always "here's your updated team," the behavioral difference is primarily latency (re-run takes longer). This is acceptable -- users intuit that bigger changes take longer. Do NOT try to smooth this with artificial delays on the lightweight path.

4. **Gate budget pressure.** The anti-fatigue guidelines budget 3-5 approval gates per plan. A re-run doesn't add a new gate (same gate, re-presented), but it does add an adjustment round that costs user attention. Combined with the existing 2-round cap, the worst case at Team Gate is: present gate -> adjust (lightweight) -> re-present -> adjust (re-run) -> re-present -> cap reached. That's 3 presentations of the same gate before it resolves. This is already bounded by the cap, but it's worth monitoring whether re-runs push users toward the cap more frequently.

5. **Reviewer Gate re-run scope ambiguity.** Unlike the Team Gate where re-running Phase 1 is well-defined, what "re-run" means at the Reviewer Gate is less clear. The discretionary pool is derived from the synthesis plan, which doesn't change when reviewers change. The re-run here is really "let nefario re-select from the pool" -- but the user just told nefario what they want. This risks a circular dynamic: user says "add X, remove Y," nefario "re-evaluates" and recommends something different. Resolution: at the Reviewer Gate, substantial changes should ALWAYS use the user's stated preferences as hard constraints, with nefario only re-evaluating the remaining pool slots. Never override the user's explicit choices.

### Additional Agents Needed

**devx-minion** should review the final spec changes to ensure the re-run mechanism integrates cleanly with the SKILL.md structure and that the adjustment flow remains implementable within nefario's existing subagent spawning patterns. If devx-minion is already on the team, no additional agents are needed.

Beyond that: None. This is primarily a UX strategy + spec-writing task. The changes are to SKILL.md documentation, not to code. The governance agents (lucy, margo) should review the final result as part of normal Phase 3.5, but they don't need to be consulted during planning.
