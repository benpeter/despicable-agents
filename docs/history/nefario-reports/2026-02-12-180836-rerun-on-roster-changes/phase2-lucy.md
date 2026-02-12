## Domain Plan Contribution: lucy

### Recommendations

#### (1) Alignment with documented gate purpose

The gates exist to "give the user visibility into team selection and prevent wasted compute on irrelevant specialists" (Team Approval Gate, `docs/orchestration.md` line 371) and to let the user "approve the reviewer set, adjust discretionary picks [...], or skip architecture review entirely" (Reviewer Approval Gate, `docs/orchestration.md` line 78). The core intent is **user control over composition before work proceeds**.

Adding a "substantial change triggers re-run" path **aligns with this intent**, provided the re-run is framed as protecting the user from stale planning artifacts rather than second-guessing the user's adjustment. A team that changes by 3+ members means the planning questions, cross-cutting checklist, and specialist coverage may no longer match the task -- proceeding without re-planning risks executing a plan built on the wrong assumptions. The re-run preserves the gate's purpose: ensuring work proceeds only with a composition the user has vetted and that the system can meaningfully support.

However, **alignment requires that the re-run path remains a recommendation, not a forced gate**. The existing gates offer "Approve / Adjust / Reject" -- if the user makes a large adjustment and explicitly approves it, forcing a re-run would undermine the very control the gates are designed to provide. The user must be able to override the re-run recommendation.

#### (2) "No additional approval gates" constraint

The issue explicitly states "no additional approval gates introduced." The proposed flow satisfies this constraint **if and only if** the re-run path is integrated into the existing "Adjust team" / "Adjust reviewers" response handling, not implemented as a separate gate step. Specifically:

- After the user provides their adjustment in the freeform prompt (step 2 of "Adjust team" handling, SKILL.md line 436-438), the system evaluates the magnitude of change.
- If substantial (3+ agents changed): the system **recommends** re-running the relevant phase and re-presents the gate with a note like "Substantial change (N agents). Recommend re-running Phase 1 to update planning questions." The user still sees the same Approve/Adjust/Reject options -- no new gate type is introduced.
- If minor (1-2 agents): proceed as today (lightweight inference for added agents, re-present gate).

This keeps the interaction within the existing gate flow. The re-run is a **behavioral branch inside the Adjust path**, not a new approval point.

#### (3) CLAUDE.md and repo convention constraints

Relevant constraints from CLAUDE.md and the engineering philosophy:

- **YAGNI**: The implementation should not pre-build infrastructure for future re-run scenarios. The change is to the adjustment flow in SKILL.md and the corresponding docs -- no new files, no new abstractions.
- **KISS**: The threshold logic must be simple and explainable. "3 or more agents changed" is a simple rule. Relative thresholds (percentage-based) add complexity.
- **"Intuitive, Simple & Consistent"**: Both gates (Team and Reviewer) should handle substantial changes the same way. If the Team Approval Gate gets a re-run recommendation on 3+ changes, the Reviewer Approval Gate should use the same logic for its discretionary pool.
- **Adjustment cap**: SKILL.md caps adjustments at 2 rounds (lines 443-445, line 696). A re-run that feeds back into the same gate flow must count toward this cap, or the cap must be explicitly reset. I recommend the re-run resets the adjustment counter since it is effectively a fresh pass through the phase, but this must be stated explicitly.
- **Session Output Discipline**: Any re-run output must respect the compact format rules (8-12 lines for Team gate, 6-10 for Reviewer gate). The re-run note should be a single additional line, not a verbose explanation.

#### (4) Absolute vs. relative threshold

The issue proposes 3+ agents as "substantial." This is an absolute threshold. The question is whether it should be relative to team size.

Current data points:
- The cross-cutting checklist has 6 mandatory dimensions (`docs/orchestration.md` lines 336-344), suggesting minimum viable teams are typically 3-6 agents.
- The discretionary reviewer pool is exactly 6 agents (SKILL.md lines 623-631).
- Mandatory reviewers (5) are not user-adjustable (SKILL.md line 611).

Analysis:
- **Team Approval Gate**: Teams can range from 2-15+ agents. Changing 3 agents on a 4-agent team is a 75% change; on a 12-agent team it is 25%. Both are arguably "substantial" for planning purposes because planning questions are per-agent -- adding or removing 3 agents means 3 planning questions are either missing or stale regardless of team size. **Absolute threshold is defensible here.**
- **Reviewer Approval Gate**: The discretionary pool is fixed at 6. Changing 3 of 6 discretionary reviewers is always a 50% change. The mandatory 5 are untouched. This is always substantial in relative terms. **Absolute threshold works here too, and happens to be a 50% relative threshold on a fixed pool.**

Recommendation: **Use the absolute threshold of 3+ for both gates.** It is simple (KISS), consistent across gates, and avoids the complexity of percentage math. The fixed pool size at the Reviewer gate makes relative vs. absolute moot anyway. For the Team gate, the argument that 3+ stale/missing planning questions invalidates the plan holds regardless of total team size.

One edge case to document: if the user's adjustment is purely subtractive (only removing agents, not adding), the existing planning contributions from removed agents still exist in scratch files. A re-run of Phase 1 is less critical for pure removals since the synthesis (Phase 3) can simply exclude those contributions. The re-run recommendation could be softer for pure removals vs. mixed or additive changes. However, per YAGNI, I would NOT implement this distinction in v1 -- flag it as a future consideration and use the same 3+ threshold uniformly.

### Proposed Tasks

**Task 1: Modify Team Approval Gate adjustment flow in SKILL.md**

- **What**: In the "Adjust team" response handling (SKILL.md lines 429-445), add a magnitude check after step 2 (interpreting the user's request). If 3+ agents are added, removed, or swapped: recommend re-running Phase 1 (META-PLAN) with the updated roster context, then re-enter the Team Approval Gate with the fresh meta-plan. If fewer than 3: proceed as today (lightweight inference for added agents).
- **Deliverable**: Updated SKILL.md section with the branching logic.
- **Key constraint**: The re-run recommendation must be overridable. The re-presented gate should include a note about the recommendation but still offer the standard Approve/Adjust/Reject options. Explicitly state that the re-run resets the 2-round adjustment cap (since it is a fresh phase pass).
- **Dependencies**: None.

**Task 2: Modify Reviewer Approval Gate adjustment flow in SKILL.md**

- **What**: In the "Adjust reviewers" response handling (SKILL.md lines 693-697), add the same magnitude check. If 3+ discretionary reviewers are changed: recommend re-running the reviewer selection step (nefario re-evaluates the delegation plan against the discretionary pool). If fewer than 3: proceed as today.
- **Deliverable**: Updated SKILL.md section with the branching logic.
- **Key constraint**: Same overridability and cap-reset semantics as Task 1. Consistent language and structure with the Team gate change.
- **Dependencies**: Task 1 (for consistent language/structure; can be done in parallel if conventions are agreed first).

**Task 3: Update docs/orchestration.md**

- **What**: Update the Team Approval Gate and Reviewer Approval Gate sections in `docs/orchestration.md` to document the re-run recommendation behavior. Add a brief note about the threshold and the override mechanism.
- **Deliverable**: Updated orchestration.md sections.
- **Dependencies**: Tasks 1 and 2 (document what was implemented).

**Task 4: Update the mermaid sequence diagram in docs/orchestration.md**

- **What**: The mermaid diagram (lines 173-304) shows the Team Approval Gate and Reviewer Approval Gate flows. If the re-run path introduces a visible loop-back (Adjust -> re-run Phase 1 -> re-enter gate), the diagram should reflect it. Evaluate whether the diagram needs updating -- if the re-run is purely internal to the "Adjust" response handling, the existing diagram's `User->>Main: Approve / Adjust / Reject` arc may already cover it adequately.
- **Deliverable**: Updated or unchanged diagram with explicit rationale.
- **Dependencies**: Tasks 1 and 2.

### Risks and Concerns

1. **Re-run cost and latency**: Re-running Phase 1 (META-PLAN) spawns nefario on opus. This is not free in time or compute. The user should understand that choosing a large adjustment implies re-planning latency. The recommendation note should mention this briefly ("Re-running Phase 1 to update planning questions. This may take a moment."). Risk: users may find the re-run slow and frustrating. Mitigation: make it overridable and clearly explain why it is recommended.

2. **Adjustment cap interaction**: If a re-run resets the 2-round adjustment cap, a user could theoretically loop indefinitely (large adjust -> re-run -> large adjust -> re-run). The existing cap logic must be extended to cover re-runs. Recommendation: cap total re-runs at 1 per gate. After one re-run, subsequent large adjustments proceed with the lightweight path and a note that further re-runs are not available. This prevents infinite loops while keeping the user in control.

3. **Reviewer gate scope creep**: The Reviewer Approval Gate adjustments are constrained to the 6-member discretionary pool. Changing 3+ of 6 is always a 50% change. The re-run for this gate is lighter (re-evaluate reviewer selection, not re-run full synthesis). Ensure the implementation does not conflate the two re-run scopes -- Phase 1 re-run for Team gate vs. reviewer selection re-evaluation for Reviewer gate.

4. **Consistency between SKILL.md and docs/orchestration.md**: These two files describe the same gates. Any change to SKILL.md adjustment flows must be mirrored in orchestration.md. This is a known consistency risk in this repo. Task 3 addresses it, but the dependency must be enforced (Task 3 should not be marked complete until it matches the final SKILL.md text).

5. **"No additional approval gates" constraint violation risk**: If the re-run path introduces any new AskUserQuestion call that was not previously part of the flow, it could be argued as a new gate. The re-presented gate after re-run must use the **same** AskUserQuestion structure (same header, same options) as the original gate. The only difference is the content (updated team/reviewers) and possibly a one-line note about the re-run.

### Additional Agents Needed

**margo** -- The threshold logic (absolute 3+ vs. relative) and the re-run cap (1 re-run per gate) are complexity decisions that benefit from YAGNI/KISS validation. Margo should review whether the re-run mechanism is the simplest solution or whether a simpler alternative exists (e.g., always re-run on any adjustment, or never re-run and trust synthesis to handle stale contributions).

No other additional agents needed. The task is primarily a SKILL.md and docs update -- devx-minion and ux-strategy-minion (if already on the team) cover the interaction design and developer experience angles.
