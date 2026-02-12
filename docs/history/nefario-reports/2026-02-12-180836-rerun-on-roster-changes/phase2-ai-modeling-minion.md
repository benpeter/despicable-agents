## Domain Plan Contribution: ai-modeling-minion

### Recommendations

#### (1) Team Gate Re-Run: Context-Aware META-PLAN Re-Spawn

The re-spawned nefario should receive the original meta-plan as context, NOT start fresh. Starting fresh wastes tokens rediscovering what the first run already established (codebase structure, external skills, scope definition, cross-cutting checklist). More importantly, a fresh run could diverge from the original scope, producing a meta-plan the user did not ask for.

**Re-run prompt design (META-PLAN RE-RUN mode)**:

The re-spawn prompt should contain four context blocks:

1. **Original task description** -- same as the initial spawn (already retained as `original-prompt`).

2. **Original meta-plan** -- the full output from `$SCRATCH_DIR/{slug}/phase1-metaplan.md`. This anchors scope, cross-cutting checklist, external skill integration, and rationale. The re-run should preserve these unless the team change invalidates them.

3. **User adjustment request** -- the verbatim text from the user's "Adjust team" response PLUS a structured delta summary (e.g., "Added: security-minion, observability-minion. Removed: frontend-minion, ux-design-minion, seo-minion."). Both the raw text and the structured delta matter: the raw text captures the user's intent/reasoning, the structured delta prevents misinterpretation of natural language.

4. **Constraint directive** -- explicit instruction telling nefario what to do differently:
   ```
   The user made substantial changes to the team (3+ agents changed).
   Re-evaluate your meta-plan with the updated team composition as a constraint.

   You MUST:
   - Keep the same scope and task description
   - Preserve external skill integration decisions unless the team change invalidates them
   - Generate planning questions for all newly added agents
   - Remove planning questions for removed agents
   - Re-evaluate the cross-cutting checklist against the new team
   - If the team change implies a scope shift the original plan missed, note it
     in a "Scope Adjustment" section

   You MUST NOT:
   - Change the fundamental scope of the task
   - Add agents the user did not request (beyond cross-cutting checklist requirements)
   - Re-discover external skills (reuse the original discovery)
   ```

**Depth parity**: The constraint directive should include: "Produce output at the same depth and format as the original meta-plan. Match the consultation detail level: each consultation entry must include agent, planning question, context to provide, and rationale." This ensures the re-run does not produce a thin sketch just because it has more context to work from. Models with rich context tend to produce shorter outputs unless explicitly told to match a reference depth.

**Output location**: Write to `$SCRATCH_DIR/{slug}/phase1-metaplan-rerun.md` (not overwrite the original). The original meta-plan is a useful audit artifact. The calling session should use the re-run output going forward.

#### (2) Reviewer Gate Re-Run: In-Session Reviewer Re-Evaluation

This is correct -- no nefario subagent spawn needed. The calling session already has the synthesis plan in context (or in `$SCRATCH_DIR/{slug}/phase3-synthesis.md`). Reviewer identification is a bounded evaluation against a 6-member discretionary pool using domain signal matching from the delegation plan.

**Context required for re-evaluation**:

1. **The delegation plan** -- already in session context or readable from the scratch file. This is the primary input: the domain signal table maps plan artifacts to reviewer domains.

2. **The user's adjustment and the structured delta** -- which reviewers were added/removed and why.

3. **Re-evaluation instruction** -- the calling session should re-run the discretionary reviewer logic (the domain signal table from SKILL.md lines 623-633) against the delegation plan, producing plan-grounded rationales for each reviewer in the adjusted set. For user-added reviewers that do not match any domain signal, the rationale should note: "User-requested; no direct domain signal in plan."

The key insight: reviewer rationales must be plan-grounded even for user-requested additions. If a user adds `ux-design-minion` but the plan has no UI artifacts, the rationale should say exactly that -- transparently, not argumentatively. This preserves the integrity of the rationale system while respecting user authority.

**No model upgrade needed**: This is a structured evaluation against a known rubric. The calling session (which already runs on the orchestrating model) can handle it without spawning a subagent.

#### (3) Cost Justification Analysis

**Meta-plan re-run cost estimate**:

A nefario META-PLAN spawn on Opus costs:
- Input: ~4,000-6,000 tokens (system prompt + task + working directory context + file reads)
- For re-run: add ~2,000-4,000 tokens for the original meta-plan context + adjustment delta
- Total input: ~6,000-10,000 tokens
- Output: ~1,500-3,000 tokens (meta-plan structure)
- Estimated cost per re-run: ~$0.04-$0.10 (at Opus $5/$25 per MTok)

With prompt caching on nefario's system prompt (~4,096+ tokens, meets Opus cache minimum), the system prompt portion hits cache on re-run (it was cached during the initial META-PLAN spawn within the same session). The 5-minute TTL is easily within the time between initial spawn and user adjustment. This brings effective input cost down by ~40-50%.

**Cached re-run cost**: ~$0.025-$0.065 per re-run.

**Is this justified?** Yes, for three reasons:

1. **The alternative is worse, not cheaper.** The current lightweight path (calling session generates questions) runs in the main Opus session, which has a much larger context window loaded (full conversation history, all prior CONDENSE state). A nefario subagent spawn is actually MORE token-efficient because it gets a clean, focused context window with only the relevant inputs. The "lightweight" path may use more tokens than the re-spawn because it reasons over a bloated context.

2. **Quality difference is material.** Nefario's META-PLAN mode applies the delegation table, cross-cutting checklist, and external skill integration -- three structured evaluation passes that lightweight inference skips. When 3+ agents change, the cross-cutting checklist alone can surface missed dependencies (e.g., removing frontend-minion should trigger re-evaluation of accessibility-minion and sitespeed-minion needs).

3. **Frequency is low.** Substantial team changes (3+ agents) are rare. Most users approve the team or make 1-2 swaps. The re-run path will execute in <5% of orchestrations. The cost of the mechanism is dominated by implementation complexity, not runtime cost.

**Recommendation**: The re-run is justified. The cost is negligible ($0.03-$0.07 per occurrence) and the quality improvement is significant for the cases that trigger it. Do NOT try to optimize by using Sonnet for the re-run -- nefario's delegation table reasoning and cross-cutting evaluation benefit from Opus, and the savings (~$0.02) are not worth the quality risk on an already-rare path.

### Proposed Tasks

**Task 1: Design META-PLAN RE-RUN prompt template**
- What: Create the prompt template for the re-run mode, including the four context blocks (original task, original meta-plan, user adjustment, constraint directive). Define the output format and file naming convention (`phase1-metaplan-rerun.md`).
- Deliverables: Prompt template in SKILL.md with all template variables documented.
- Dependencies: None (can be designed independently).

**Task 2: Define the threshold logic and structured delta format**
- What: Specify how the calling session counts changes (added + removed agents), computes the threshold (3+), and produces the structured delta summary passed to the re-run prompt. Define edge cases: what counts as a "change" when a user says "replace X with Y" vs "add X" + "remove Y" separately.
- Deliverables: Threshold logic specification and delta format definition.
- Dependencies: None.

**Task 3: Update Team Approval Gate "Adjust team" handling in SKILL.md**
- What: Modify the "Adjust team" response handling (currently SKILL.md lines 428-445) to branch on change magnitude. Lightweight path (1-2 changes): existing behavior. Substantial path (3+ changes): spawn META-PLAN RE-RUN. Both paths converge at the re-presentation of the Team Approval Gate.
- Deliverables: Updated SKILL.md section with branching logic.
- Dependencies: Task 1, Task 2.

**Task 4: Update Reviewer Gate "Adjust reviewers" handling in SKILL.md**
- What: Add re-evaluation logic for substantial reviewer changes. Define that the calling session re-runs the domain signal evaluation in-place, producing fresh plan-grounded rationales. No subagent spawn needed.
- Deliverables: Updated SKILL.md section for the reviewer gate.
- Dependencies: Task 2 (threshold logic).

**Task 5: Add nefario AGENT.md MODE: META-PLAN-RERUN documentation**
- What: Document the re-run mode in nefario's AGENT.md. This is not a new mode flag -- the calling session adds context to the META-PLAN prompt. But the AGENT.md should document the expected behavior when the original meta-plan is provided as context (preserve scope, re-evaluate team, match depth).
- Deliverables: Updated nefario AGENT.md with re-run behavior guidance.
- Dependencies: Task 1.

### Risks and Concerns

1. **Context window bloat on re-run**. Including the full original meta-plan in the re-run prompt adds 1,500-3,000 tokens. For large meta-plans (many specialists, extensive external skill discovery), this could push the re-run input past 10K tokens. Mitigation: cap the original meta-plan at a summary if it exceeds a threshold, or reference the scratch file path for full content and let nefario read it via the Read tool (which it already does for codebase exploration).

2. **Scope drift on re-run**. Even with explicit constraints, the re-run could subtly shift scope if the team change implies a different interpretation of the task. Example: user removes all frontend agents and adds backend agents -- nefario might reframe a "build a dashboard" task as "build an API." Mitigation: the constraint directive explicitly prohibits scope changes, and the re-run output goes through the Team Approval Gate again, giving the user a second look.

3. **Adjustment round cap interaction**. The current cap is 2 adjustment rounds. A substantial change that triggers a re-run consumes one round. If the re-run output needs a minor tweak, the user is on their last round. This is probably fine -- the re-run should produce a high-quality team selection that rarely needs further adjustment. But the cap logic should count re-run rounds and lightweight rounds equivalently.

4. **Cache invalidation timing**. The 5-minute TTL on nefario's system prompt cache should hold between initial spawn and re-run in normal usage. But if the user takes a long time deliberating (>5 minutes on the approval gate), the cache expires and the re-run pays full write cost. This is acceptable -- the cost difference is ~$0.01 and the scenario is uncommon.

5. **No new approval gates** (per task spec). Verify that the re-run does not introduce any new gate. It should re-present the SAME Team Approval Gate with updated content, not add a "Re-Run Approval Gate." This is a specification constraint, not a technical risk, but it is easy to accidentally violate.

### Additional Agents Needed

None. The current planning team should be sufficient. The task is primarily about orchestration workflow design (nefario skill modifications) and prompt engineering (re-run prompt template), both of which are covered by the agents likely already involved in this planning session. If devx-minion is not already on the team, they could add value for the UX of the approval gate interaction (how the re-run is presented to the user), but this is a minor concern that can be addressed during synthesis.
