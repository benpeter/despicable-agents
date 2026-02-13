# Domain Plan Contribution: ai-modeling-minion

## Recommendations

### (a) Regenerate from scratch, not patch the original

The re-run prompt should instruct nefario to **regenerate all planning questions from scratch** while being provided the original meta-plan and delta as reference context. Do not instruct it to "update" or "edit" the original questions.

**Why**: Planning questions are tightly coupled to team composition. When nefario knows which agents are on the team, it crafts questions that create productive division of labor -- e.g., asking security-minion about threat modeling while asking api-design-minion about contract shape, rather than having both address security broadly. Adding or removing even one agent changes the optimal question boundaries for everyone. An "update the existing questions" instruction forces the model into a constrained edit mode where it anchors too heavily on original phrasing and misses the opportunity to redistribute question scope across the revised team.

The current substantial-path constraint directive (SKILL.md lines 579-587) already has the right structure: "Generate planning consultations for ALL agents in the revised team." This directive should be preserved exactly as-is for the unified always-re-run path.

**Prompt structure recommendation**: The re-run prompt should present context in this order:

1. **MODE: META-PLAN** header (unchanged)
2. **Original task description** (the `original-prompt`, identical to initial run)
3. **Working directory** (unchanged)
4. **External skill discovery** instructions (unchanged)
5. **Prior meta-plan** -- the full original meta-plan, presented as reference: "The following meta-plan was produced for the original team. Use it as context for the revised plan, not as a template to minimally edit."
6. **Structured delta** -- "Team change: Added: X, Y. Removed: Z."
7. **Constraint directives** -- the existing six directives from lines 579-587, unchanged

The key phrase is "Use it as context for the revised plan, not as a template to minimally edit." This is a well-established prompt engineering pattern for getting Claude to treat prior output as informational rather than as a draft to surgically revise. Without this framing, Claude models (especially Opus) tend to make minimal changes to provided text, which is precisely the coherence problem we are trying to avoid.

### (b) Cross-agent question coherence

For maintaining question coherence when team changes are small, two prompt engineering patterns are effective:

**Pattern 1: Team-wide question design instruction.** Add a single line to the constraint directives: "Design planning questions as a coherent set -- each question should address aspects that no other agent on the team covers, and questions should reference cross-cutting boundaries where relevant." This is ~30 tokens and makes the model explicitly reason about question boundaries during generation rather than treating each question independently.

**Pattern 2: Provide the team list prominently.** The structured delta alone is insufficient context for coherent question design. The re-run prompt should include the complete revised team list (not just the delta) so nefario sees the full roster it is planning for. The delta tells nefario what changed; the full list tells it what the final team looks like. Both are needed. The current substantial-path prompt implicitly provides this via the original meta-plan + delta, but it would be clearer to state the resolved team explicitly: "Revised team: agent-a, agent-b, agent-c (added), agent-d."

These two patterns together are lightweight (under 50 additional tokens in the prompt) and produce measurably better cross-agent coherence than relying on the model to infer boundaries from the delta alone.

### (c) Do NOT add a change-significance signal

Adding a "change significance" signal to the re-run prompt would reintroduce the minor/substantial distinction at the prompt level rather than the routing level. This directly undermines the goal of the issue.

More importantly, it is unnecessary. The model already receives the structured delta ("Added: X. Removed: none.") which inherently communicates the magnitude of change. Claude will naturally calibrate its re-planning depth based on the delta size -- a one-agent addition with an otherwise-identical task description will produce a meta-plan that is largely similar to the original, because the task and most of the team are the same. A five-agent overhaul will produce a more divergent meta-plan because the team composition fundamentally changed. This is emergent behavior from the model's reasoning, not something that needs an explicit signal.

Adding an explicit signal would also create a prompt engineering maintenance burden: the SKILL.md would need to define thresholds for "low/medium/high significance" and specify how nefario should respond to each level, which is exactly the classification complexity the issue is removing.

### Additional prompt engineering considerations

**Token cost**: The always-re-run path spawns a nefario META-PLAN subagent for every adjustment, including single-agent additions that the minor path previously handled without a subagent spawn. This adds approximately 15-30K input tokens per adjustment (system prompt + original task + prior meta-plan + constraint directives) plus 2-5K output tokens. At Opus pricing ($5/$25 per MTok), this is roughly $0.10-$0.20 per re-run. Given the 1-re-run cap and 2-adjustment-round cap, maximum additional cost per orchestration is $0.20-$0.40. This is negligible relative to the total orchestration cost (which typically runs $2-10 across all phases).

**Latency**: The re-run adds 15-30 seconds of latency per adjustment (Opus META-PLAN generation). The minor path was near-instant because the calling session generated questions inline. This is a real tradeoff but acceptable because: (1) team adjustments are infrequent (typically 0-1 per orchestration), (2) the user is already at an interactive gate and expects to wait for the system to process their change, and (3) question coherence directly affects Phase 2 quality which affects the entire downstream plan.

**Caching**: The re-run prompt shares the same system prompt (nefario AGENT.md) as the original Phase 1 spawn. If the original Phase 1 cache entry is still warm (5-minute TTL), the re-run benefits from a cache hit on the system prompt, reducing the input cost by roughly 60-70%. The SKILL.md should not need any special caching instructions -- this happens automatically via the API's prompt caching behavior.

## Proposed Tasks

### Task 1: Revise SKILL.md adjustment handling (Team Approval Gate)

**What to do**: Remove the adjustment classification definition (lines 524-549), remove step 4a (minor path, lines 564-567), and promote step 4b (substantial path, lines 569-604) as the single adjustment handling path. Update the re-run prompt with the two coherence patterns described above. Update the 1-re-run-cap rule (lines 544-546) to remove the "lightweight path" fallback -- after the re-run cap is reached, a second adjustment at the same gate should re-present the current team with Approve/Reject only (consistent with the existing 2-round cap behavior at line 599-604).

**Deliverables**: Updated SKILL.md with unified adjustment path.

**Dependencies**: None (this is the primary task).

**Specific edits**:
- Remove "Adjustment classification" block (lines 524-549)
- Replace steps 4a/4b with a single step 4 that always re-runs Phase 1
- Update the re-run prompt (lines 573-587) to add: (i) explicit revised team list, (ii) "context not template" framing for the prior meta-plan, (iii) team-wide question coherence instruction
- Update the 1-re-run-cap fallback (line 545-546) to point at Approve/Reject instead of lightweight path
- Update the CONDENSE line (line 191) to remove "(substantial team adjustment)" qualifier -- all adjustments produce this line now
- Update the scratch directory structure comment (line 310) to remove "(if substantial team adjustment)" qualifier

### Task 2: Verify nefario AGENT.md has no minor/substantial references

**What to do**: Confirm that `nefario/AGENT.md` does not reference the minor/substantial distinction. Based on my grep, it does not -- this task is a verification step, not a code change.

**Deliverables**: Confirmation (no file changes expected).

**Dependencies**: None.

### Task 3: Update Phase 3.5 reviewer gate to match (if in scope)

**What to do**: The reviewer adjustment gate (SKILL.md lines 1015-1043) uses the same minor/substantial classification. The issue scope says "Out: Phase 3.5 reviewer adjustment gate" but the adjustment classification definition (lines 524-549) is shared between both gates. If the classification definition is removed, the reviewer gate needs its own inline threshold or must also switch to always-re-evaluate. This is a scoping decision for the plan owner.

**Deliverables**: Either (a) inline the 3+ threshold into the reviewer gate section, or (b) extend the always-re-run pattern to the reviewer gate as well. Decision needed.

**Dependencies**: Task 1 (the classification removal creates the dependency).

## Risks and Concerns

1. **Shared classification definition**: The adjustment classification (lines 524-549) is referenced by both the Team Approval Gate and the Reviewer Approval Gate (Phase 3.5). Removing it for the Team gate without addressing the Reviewer gate will leave a dangling reference. The SKILL.md currently says "per the adjustment classification definition" at both gates. This must be resolved -- either by inlining the threshold at the reviewer gate or by extending the change to both gates.

2. **Re-run cap fallback behavior change**: The current re-run cap fallback says "use the lightweight path." If the lightweight path no longer exists, the fallback must change. The simplest approach: after the 1-re-run cap is reached, a second adjustment at the same gate re-presents with Approve/Reject only (same as the 2-round cap behavior). This is simpler and consistent. But it means a second adjustment at the same gate is not possible -- the user must approve or reject. This is a minor UX regression for users who want to make iterative small changes. Given the 2-round cap already limits this, the regression is minimal.

3. **No regression in question quality for small changes**: The minor path generated questions "from task context" inline in the calling session (not via nefario subagent). The quality of these inline-generated questions was lower than nefario-generated questions (the calling session lacks nefario's delegation table knowledge and cross-cutting checklist). The always-re-run path produces strictly better questions. There is no quality regression risk.

4. **Prompt length growth**: Including the full prior meta-plan in the re-run prompt adds 1-3K tokens. For very large meta-plans (10+ agents), this could push the re-run prompt to 40K+ tokens. This is well within the 200K context window and has negligible cost impact with caching, but is worth noting.

## Additional Agents Needed

None. The current team is sufficient. This is primarily a SKILL.md editing task with prompt engineering considerations. The ai-modeling-minion contribution covers the prompt design patterns. The actual file editing is straightforward enough that it does not require additional specialist input beyond whoever is assigned to edit SKILL.md.
