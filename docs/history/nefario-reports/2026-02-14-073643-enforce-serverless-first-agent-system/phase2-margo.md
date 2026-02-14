# Domain Plan Contribution: margo

## Recommendations

### (a) Encoding: Modify the existing budget, not a new detection pattern

A new "Unnecessary Infrastructure Detection" pattern would be redundant. Margo already
has infrastructure proportionality assessment, YAGNI enforcement, and the two-column
complexity budget. The right approach is to add a **burden-of-proof rule** to the
existing complexity budget section. This keeps the mechanism lean -- one budget system
with a clear default, not two overlapping detection systems.

Specifically: add a paragraph after the budget table that establishes serverless/managed
as the **default baseline** for new services. When a plan proposes self-managed
infrastructure, the complexity budget already scores it higher. The new rule makes this
gap actionable: the plan must document a specific blocking concern from the approved list
to justify the higher-scoring column. "We prefer Docker" or "we already know Terraform"
are not blocking concerns -- they are team familiarity preferences, which are legitimate
inputs to gru's technology radar but not sufficient to justify the operational complexity
penalty.

### (b) Language: strong preference with an explicit escape hatch

The language should be:

> **Default to the managed/serverless column.** When a serverless or fully managed
> alternative exists for a proposed service, plans must use the managed/serverless
> column unless a documented blocking concern prevents it. Blocking concerns are
> specific technical constraints -- not team preference, existing tooling familiarity,
> or speculative future needs. When a blocking concern is cited, it must name the
> constraint and explain why it cannot be worked around within the serverless model.

This is strong ("must use ... unless") but explicitly allows deviation when a real
blocking concern exists. It does not say "never use containers." It says "justify
containers against a specific constraint." A team with a genuine WebSocket requirement
cites it, documents it, and margo approves. No friction for legitimate cases.

### (c) Interaction with "Flag disproportion, not topology"

The framing rule can coexist **with a clarification**. The current rule says the problem
is never "you're self-hosting." Under the new stance, the problem is still not topology
per se -- it is unjustified operational complexity. Self-managed infrastructure carries
measurably higher operational burden (the budget table already quantifies this). The
serverless-first stance simply makes this cost explicit as a default.

Proposed amendment to framing rule #1:

> **Flag disproportion, not topology -- but recognize that self-managed infrastructure
> carries inherent operational overhead.** The problem is never "you chose the wrong
> cloud provider." The problem is "this operational burden is not justified." When a
> serverless alternative exists without blocking concerns, choosing self-managed
> infrastructure IS a disproportion signal because it adds operational complexity
> that could be avoided.

This preserves the original intent (don't be a topology zealot) while acknowledging
that topology choices have real, measurable complexity costs. Margo is not saying
"serverless is always right." Margo is saying "self-managed costs more -- prove you
need to pay that cost."

### (d) Reconciling with gru's domain: complexity lens, not platform recommendation

Framing rule #3 ("Ask 'is this complexity justified?' not 'is this the right
platform?'") needs a targeted refinement, not a reversal. Margo's question is still
about complexity, but with a sharper edge:

> **Ask "is this complexity justified?" -- and when the answer is "a simpler
> managed/serverless alternative exists," flag the self-managed choice as unjustified
> complexity.** Margo does not select platforms (that is gru's domain). Margo
> identifies when a plan pays unnecessary operational complexity. If a plan proposes
> containers and a serverless option exists without blocking concerns, margo flags
> the operational overhead as accidental complexity and asks "why not the simpler
> option?" The plan author must provide a documented blocking concern. If they
> cannot, margo escalates to gru for platform re-evaluation.

The boundary with gru remains clean:
- **margo** says: "This plan has X units of unnecessary operational complexity.
  A managed/serverless alternative would score Y units lower. Justify the gap or
  simplify."
- **gru** says: "Given the constraints, here is the right platform choice."

Margo never says "use Lambda" or "use Cloudflare Workers." Margo says "this container
deployment scores 5 in the budget; a serverless equivalent would score 2; justify the
extra 3 or simplify." Gru then determines which specific serverless platform fits.

### Summary of encoding approach

The changes touch three places in AGENT.md:

1. **Complexity Budget section** (lines 53-84): Add the "default to managed/serverless
   column" paragraph with the burden-of-proof rule and the blocking concerns list.
2. **Framing rule #1** (line 306-308): Amend to acknowledge that self-managed carries
   inherent overhead and choosing it when serverless alternatives exist is itself a
   disproportion signal.
3. **Framing rule #3** (line 312-313): Refine to clarify that flagging unnecessary
   operational complexity from infrastructure choice is within margo's scope, while
   platform selection remains gru's.

No new detection patterns. No new sections. Three surgical modifications to existing
mechanisms.

## Proposed Tasks

1. **Modify margo's complexity budget in the-plan.md** (lines 539-574 area):
   Add the serverless-first default stance, burden-of-proof rule, and the four
   documented blocking concerns to the margo spec. This is the source of truth.
   - Owner: whoever is editing the-plan.md (human-approved change)
   - Dependency: human approval required per CLAUDE.md ("Do NOT modify the-plan.md
     unless the human owner approves")

2. **Rebuild margo/AGENT.md via /despicable-lab**: After the-plan.md is updated,
   regenerate AGENT.md to incorporate:
   - Burden-of-proof paragraph in the Complexity Budget section
   - Amended framing rule #1 (disproportion includes unnecessary self-managed choice)
   - Refined framing rule #3 (complexity flag for self-managed when serverless exists)
   - The four blocking concerns list embedded in the budget section
   - Owner: despicable-lab skill
   - Dependency: task 1 complete

3. **Add "Serverless-first default" to margo's review checklist** (step 6 in
   "When Reviewing a Plan or Architecture"): Between the current step 6 (complexity
   budget tally) and step 7 (infrastructure proportionality), add a step that
   explicitly asks: "For each proposed service, does a serverless/managed alternative
   exist? If yes, is there a documented blocking concern justifying self-managed?"
   - Owner: part of the AGENT.md rebuild in task 2
   - Dependency: task 1 complete

4. **Validate with a dry-run review**: After the rebuild, test the updated margo
   against a hypothetical plan that proposes a Docker container deployment for a
   stateless API (no blocking concerns). Confirm margo flags it. Then test against
   a plan proposing containers for a WebSocket server. Confirm margo approves it.
   - Owner: manual validation
   - Dependency: task 2 complete

## Risks and Concerns

1. **Overreach into gru's domain**: The biggest risk is margo drifting from "this has
   unjustified complexity" into "use this specific platform." The language must stay
   firmly in the complexity/budget lane. Margo quantifies the gap; gru fills it.
   The proposed language is carefully constructed to maintain this boundary, but
   reviewers should watch for drift during implementation.

2. **The blocking concerns list will need maintenance**: The four blocking concerns
   (persistent connections, long-running processes, compliance, cost-at-scale) are
   correct today but will evolve as serverless platforms mature. For example, WebSocket
   support is already available on some serverless platforms. This list should be
   treated as a living reference, not carved in stone. However, updating it is gru's
   domain (technology assessment), not margo's. Margo applies whatever the current
   list says.

3. **Risk of mechanical application**: A rigid "no containers ever" reading would
   block legitimate use cases. The language must make clear that documented blocking
   concerns are a first-class escape hatch, not a grudging exception. The proposed
   wording handles this ("justify the gap or simplify" rather than "never use
   containers"), but it depends on margo's LLM interpretation being nuanced rather
   than dogmatic.

4. **Interaction with existing plans**: Any plans already approved with self-managed
   infrastructure should not be retroactively flagged unless they come up for
   re-review. The stance applies to new plans going forward. This should be stated
   somewhere (possibly in the nefario orchestration context rather than in margo's
   spec).

5. **the-plan.md is human-edited**: Per CLAUDE.md, modifying the-plan.md requires
   human approval. The proposed changes to the margo spec in the-plan.md cannot be
   made by an agent unilaterally. This is a hard dependency on the human owner.

## Additional Agents Needed

- **gru**: Owns the blocking concerns list. Gru should validate that the four
  blocking concerns are the correct and complete set for the current serverless
  landscape. Gru should also confirm that the boundary between margo's complexity
  flagging and gru's platform selection is correctly drawn in the proposed language.

- **lucy**: Already being consulted separately on CLAUDE.md and governance
  enforcement. Lucy should verify that the burden-of-proof rule in margo's spec
  is consistent with whatever governance enforcement mechanism lucy proposes.
  The two should reinforce each other, not contradict.
