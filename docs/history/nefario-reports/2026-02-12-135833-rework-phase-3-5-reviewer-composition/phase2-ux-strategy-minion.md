# Phase 2: Domain Plan Contribution -- ux-strategy-minion

## Recommendations

### 1. The Approval Fatigue Problem is Real and Specific

The user already encounters one team-composition gate at Phase 2 (the Team Approval Gate from PR #51). Adding a second team-composition gate at Phase 3.5 creates a pattern I call **gate echo**: the user sees the same decision shape twice in close succession, which trains them to rubber-stamp. This is the most dangerous outcome -- worse than having no gate at all, because it creates a false sense of oversight.

The key insight: these two gates have *different cognitive jobs* even though their surface structure looks similar.

- **Phase 2 gate**: "Who should help me think about this?" (advisory scope). Low stakes -- a wrong specialist costs compute but does not produce incorrect code.
- **Phase 3.5 gate**: "Who should review the plan before I commit resources to execution?" (quality assurance scope). Higher stakes -- a missing reviewer means a blind spot in the plan that flows directly into code.

The interaction model must make this difference *felt*, not just *stated*. Reusing the exact same pattern for both gates makes them feel interchangeable, which undermines the higher-stakes nature of 3.5.

### 2. Recommendation: Differentiate Through Presentation Weight, Not Interaction Mechanics

Reuse the same structural pattern (compact presentation, freeform adjust, 3 options via AskUserQuestion) but differentiate on these dimensions:

**A. Presentation density**: The Phase 2 gate shows SELECTED + ALSO AVAILABLE (the full 27-agent roster). The Phase 3.5 gate should show only the discretionary picks with rationale -- not the mandatory reviewers. The mandatory 5 are not a decision point; showing them dilutes the signal. The user's decision is about the discretionary pool only.

Recommended format for Phase 3.5 (target 6-10 lines):

```
REVIEW TEAM: <1-sentence plan summary>
Mandatory: security, test, software-docs, lucy, margo (always review)

  DISCRETIONARY (nefario recommends):
    ux-design-minion       Plan includes 2 UI component tasks
    accessibility-minion   Web-facing output in Tasks 3, 5

  NOT SELECTED from pool:
    ux-strategy-minion, sitespeed-minion, observability-minion, user-docs-minion

Full plan: $SCRATCH_DIR/{slug}/phase3-synthesis.md
```

Format rules:
- Mandatory line: flat comma-separated, one line, presented as fact not choice. Use short names (security, test, software-docs, lucy, margo) -- the user does not need to parse full agent names for a line they cannot change.
- DISCRETIONARY block: agent name + one-line rationale grounded in the specific plan (reference task numbers or deliverables). One line per agent, left-aligned. This is the decision surface.
- NOT SELECTED: flat comma-separated list of the remaining discretionary pool members. Users scan for surprises.
- No "ALSO AVAILABLE" block listing the full 27-agent roster. The discretionary pool is fixed at 6 agents; the user adjusts within that pool, not across the full roster. This constrains the decision space and prevents Phase 3.5 from feeling like a Phase 2 repeat.

**B. Header differentiation**: Use a different AskUserQuestion header. Phase 2 uses "Team". Phase 3.5 should use "Review" -- a single-word shift that signals different context without requiring the user to read explanatory text.

**C. Rationale grounding**: Phase 2 rationales explain *why this specialist was chosen* (domain relevance). Phase 3.5 rationales must explain *what triggers this reviewer* (specific plan content). This is a subtle but important difference: Phase 2 rationales are about capability fit; Phase 3.5 rationales are about coverage need. The format rule "reference task numbers or deliverables" enforces this.

### 3. AskUserQuestion Design for Phase 3.5

```
AskUserQuestion:
  header: "Review"
  question: "<1-sentence plan summary>"
  options (3, multiSelect: false):
    1. label: "Approve reviewers"
       description: "5 mandatory + N discretionary reviewers proceed to review."
       (recommended)
    2. label: "Adjust reviewers"
       description: "Add or remove discretionary reviewers before review begins."
    3. label: "Skip review"
       description: "Proceed to plan approval without architecture review."
```

Key differences from Phase 2:
- Option 1 description includes the count split (mandatory + discretionary) so the user knows what they are approving.
- Option 3 is "Skip review" rather than "Reject." Rejecting at Phase 2 kills the entire orchestration. Skipping at Phase 3.5 skips the review phase, not the orchestration. This is a meaningful semantic difference. The plan already exists at this point; the question is whether to review it, not whether to proceed.

**"Adjust reviewers" response handling**: Same freeform pattern as Phase 2, but constrained to the 6-member discretionary pool. If the user requests an agent outside the pool (e.g., "add backend-minion"), nefario should note that agent is not in the discretionary pool and offer the closest match or explain why it is not a reviewer. Cap at 2 adjustment rounds, same as Phase 2.

**"Skip review" response handling**: Proceed directly to the Execution Plan Approval Gate. No reviewers are spawned. The plan is presented as-is. This is a meaningful escape hatch for sessions where the user knows the plan is low-risk and wants to save time. The execution plan gate still occurs -- so the user still has a checkpoint before code runs.

### 4. Why "Skip Review" is Better Than "Reject" for Option 3

In Phase 2, "Reject" means "abandon orchestration" -- a nuclear option that makes sense because Phase 2 is the first gate and the user may realize the task is wrong.

In Phase 3.5, the plan already exists. If the user rejects the *reviewer composition*, they probably do not want to kill the entire orchestration -- they want to skip the review step. "Reject" at this point creates a misleading affordance: the user clicks it thinking "I do not want these reviewers" and gets "orchestration abandoned." This is a constraint violation (Norman: prevent errors through design).

"Skip review" correctly maps the control to the effect: clicking it skips the review phase only, preserving all planning work. This follows the mapping principle and reduces the risk of an expensive mistake.

If the user truly wants to abandon orchestration, they can do so at the subsequent Execution Plan Approval Gate (which has "Reject" as option 3). Two chances to kill the orchestration are sufficient; one of them does not need to be disguised as reviewer selection.

### 5. Avoiding Approval Fatigue: The Temporal Compression Problem

In a typical session, the user encounters these gates in rapid succession:

1. Phase 2 Team Approval Gate (team composition)
2. [planning happens -- user waits]
3. Phase 3.5 Reviewer Approval Gate (reviewer composition) -- NEW
4. [review happens -- user waits]
5. Execution Plan Approval Gate (full plan)

Gates 1 and 3 are both team-composition decisions. Gates 3 and 5 are separated by review processing time but may feel like a single "pre-execution" approval cluster. The risk: the user rubber-stamps gate 3 because they just made a team decision at gate 1, and rubber-stamps gate 5 because they just approved reviewers at gate 3.

Mitigations:
- **Visual weight hierarchy**: Phase 2 gate = 8-12 lines. Phase 3.5 gate = 6-10 lines (lighter). Execution Plan gate = 25-40 lines (heaviest). The progression should feel like: quick check, quick check, serious review. The Phase 3.5 gate should be the *lightest* gate in the sequence because it is the most routine decision.
- **Compaction checkpoint between 3 and 3.5**: The existing compaction checkpoint after Phase 3 creates a natural break. The user runs `/compact`, types "continue", and then sees the reviewer gate. This temporal separation is valuable -- do not remove the compaction checkpoint or merge it with the reviewer gate.
- **Default is low-friction**: If nefario's discretionary picks are reasonable (which they should be, given the trigger rules), the user clicks "Approve reviewers" in under 2 seconds. The gate's purpose is not to force a decision -- it is to create a moment of visibility. The user should feel "I see what is about to happen" rather than "I need to decide something."

### 6. Information Density for Discretionary Pick Rationale

The issue asks for "one-line rationale each" for discretionary picks. This is correct. The rationale must satisfy one constraint: **it must reference the specific plan content that triggered the reviewer, not the reviewer's general capability.**

Bad rationale: "Checks accessibility compliance" -- this describes what the agent does, which the user already knows from the agent name.

Good rationale: "Web-facing output in Tasks 3, 5" -- this explains *why this plan specifically* needs this reviewer. It is grounded in concrete plan content.

Rationale format: `<trigger description> [optional: task reference]`

Examples:
- `ux-design-minion       2 UI component tasks (Tasks 2, 4)`
- `accessibility-minion   Web-facing UI in Task 3`
- `sitespeed-minion       Runtime web components in Tasks 1, 3, 5`
- `observability-minion   3 service/API tasks need coordinated observability`

Each rationale: max 60 characters. This keeps the presentation scannable and maintains the visual weight target of 6-10 total lines.

### 7. software-docs-minion Role Narrowing: UX Implications

The issue specifies narrowing software-docs-minion's Phase 3.5 role to a "documentation impact checklist" rather than a full review. This is a positive change from a cognitive load perspective -- it changes software-docs-minion from a reviewer (who might BLOCK) to a scout (who generates a work order for Phase 8).

The UX implication: the software-docs-minion's output at Phase 3.5 should NOT be presented as a verdict (APPROVE/ADVISE/BLOCK). It should be a silent artifact written to `$SCRATCH_DIR/{slug}/phase3.5-software-docs-checklist.md` that Phase 8 consumes as input. This removes one potential BLOCK source from Phase 3.5, making the review phase faster and reducing the chance of a revision loop triggered by documentation concerns.

If software-docs-minion identifies a *plan-level* documentation gap (e.g., the plan changes an API but no documentation task exists), it should flag this as ADVISE, not BLOCK. The fix is to add a Phase 8 checklist item, not to revise the plan. This keeps the revision loop reserved for genuine architectural concerns (security, testing, governance).


## Proposed Tasks

### Task 1: Design Phase 3.5 Reviewer Approval Gate Presentation

**What to do**: Define the Phase 3.5 reviewer gate presentation format in SKILL.md. Includes: mandatory line (flat, non-interactive), discretionary block (one agent per line with plan-grounded rationale), not-selected line, and full plan reference. Target 6-10 lines.

**Deliverables**: New "Reviewer Approval Gate" subsection within the Phase 3.5 section of SKILL.md, containing the presentation format specification, format rules, and line budget.

**Dependencies**: Requires the ALWAYS/discretionary roster split to be defined (from the issue specification).

### Task 2: Design Phase 3.5 AskUserQuestion and Response Handling

**What to do**: Define the AskUserQuestion specification (header: "Review", 3 options: Approve reviewers / Adjust reviewers / Skip review) and response handling for each option. Include: freeform adjust constrained to the 6-member discretionary pool, 2-round adjustment cap, skip-review behavior (proceed to Execution Plan gate without spawning reviewers).

**Deliverables**: AskUserQuestion specification block and response handling subsections within the Phase 3.5 section of SKILL.md.

**Dependencies**: Task 1 (the AskUserQuestion follows the presentation).

### Task 3: Narrow software-docs-minion Phase 3.5 Output to Checklist

**What to do**: Redefine software-docs-minion's Phase 3.5 role from "full review with APPROVE/ADVISE/BLOCK verdict" to "documentation impact checklist generation." The checklist output goes to `phase3.5-software-docs-checklist.md` and feeds Phase 8 as a work order. software-docs-minion still participates in Phase 3.5 but its output is a checklist, not a verdict. Exception: plan-level documentation gaps surface as ADVISE (not BLOCK).

**Deliverables**: Updated software-docs-minion prompt template in the Phase 3.5 reviewer spawning section of SKILL.md. Updated Phase 8 section to reference the checklist as input.

**Dependencies**: Task 1 (roster definition must be finalized).

### Task 4: Update Orchestration Documentation

**What to do**: Update docs/orchestration.md to reflect the new Phase 3.5 reviewer gate: ALWAYS/discretionary roster split, reviewer approval gate interaction model, software-docs-minion role change, Phase 8 checklist handoff. Update the trigger rules table.

**Deliverables**: Updated Phase 3.5 section, trigger rules table, and Phase 8 section in docs/orchestration.md.

**Dependencies**: Tasks 1-3 (SKILL.md changes must be finalized first).


## Risks and Concerns

### Risk 1: Gate Echo Leading to Rubber-Stamping (MEDIUM)

Two team-composition gates in the same session (Phase 2 and Phase 3.5) may train users to rubber-stamp team decisions. The mitigations (visual weight hierarchy, header differentiation, compaction break) reduce but do not eliminate this risk. Monitor whether users ever use "Adjust reviewers" or always click "Approve." If adjustment rate is near zero after 10+ sessions, consider whether the gate adds value or should be converted to a non-blocking notification.

**Mitigation**: All five mitigations described in section 5 above. Additionally, the "Skip review" option gives the user an explicit escape hatch if they find the gate annoying, which is better than having them learn to rubber-stamp it.

### Risk 2: Discretionary Pool Too Small for Future Growth (LOW)

The 6-member discretionary pool is fixed. If new reviewer agents are added to the roster, the pool definition in SKILL.md must be manually updated. This is a maintenance burden, not a UX risk.

**Mitigation**: Document the pool membership explicitly and add a comment in SKILL.md noting that new reviewer agents should be evaluated for pool inclusion.

### Risk 3: "Skip Review" Misuse (LOW)

Users who always skip review lose the benefit of Phase 3.5 entirely. This is an acceptable outcome -- the user is making a conscious choice, and the Execution Plan gate still provides a checkpoint.

**Mitigation**: None needed. Respect user agency. Do not add friction or warnings to the skip path.

### Risk 4: software-docs-minion Checklist Scope Creep (LOW)

If the documentation impact checklist becomes too detailed at Phase 3.5, it duplicates work that Phase 8 agents should do. The checklist should be a *list of items to investigate*, not a detailed documentation plan.

**Mitigation**: Define the checklist as: one line per item, format: `[outcome] [action] [owner]` (reusing the Phase 8 checklist table structure). Max 10 items. If the checklist exceeds 10 items, the plan likely has documentation-heavy changes and the full analysis belongs in Phase 8.


## Additional Agents Needed

None. The current planning team is sufficient for this task. The changes are to nefario's orchestration behavior (SKILL.md, AGENT.md, orchestration.md), which are within the existing team's scope. The reviewer agents themselves (security-minion, test-minion, etc.) do not need AGENT.md changes per the issue scope.
