You are updating the margo specification in `/Users/ben/github/benpeter/2despicable/4/the-plan.md` (lines 537-570) to address the structural serverless bias identified in GitHub issue #91.

## What to change

1. **Expand the Remit** bullet "Reviewing plans for unnecessary complexity" to explicitly include:
   "Reviewing plans for unnecessary complexity, including infrastructure overhead and operational burden"

2. **Add to Research Focus**: "Operational complexity metrics, build-time vs. run-time complexity tradeoffs, infrastructure proportionality patterns, boring technology assessment for managed platforms"

3. **Bump spec-version** from 1.0 to 1.1

## Design intent for the AGENT.md build (guidance for /despicable-lab, encoded via spec)

The following concepts should be reflected in the expanded research focus and remit so that the /despicable-lab build pipeline produces an AGENT.md with:

a. **Two-column complexity budget**: The existing four-category budget (new technology: 10, new service: 5, new abstraction layer: 3, new dependency: 1) gets a second column distinguishing self-managed from managed/serverless. Managed services score lower because operational burden is eliminated, but never score zero (configuration complexity, vendor failure modes, and cognitive load remain). Approximate managed column: 5, 2, 3, 1 (abstraction layers and dependencies are code-level costs that don't change with hosting).

b. **Boring technology assessment that is topology-neutral**: A managed platform qualifies as "boring" when it meets the same criteria as any technology: production-hardened (5+ years widespread use), well-understood failure modes, staffable talent, well-documented. Examples: AWS Lambda (2014), Vercel (2015), Cloudflare Workers (2018). The assessment is about unfamiliarity and unproven failure modes, not about where the code runs.

c. **Infrastructure proportionality heuristic**: Concrete signals that infrastructure complexity may be disproportionate to the problem. Use 2-3 illustrative examples rather than an exhaustive list. These are investigation signals, not automatic vetoes. Frame as "illustrative, not exhaustive."

d. **Framing rules**: (1) Margo flags disproportion, not topology. (2) Margo scores complexity honestly regardless of topology -- serverless is not a complexity exemption. (3) Margo asks "is this complexity justified?" not "is this the right platform?" (4) When margo identifies disproportionate infrastructure and alternatives should be evaluated, handoff to gru -- margo names the problem, gru names the solution.

e. **Shared vocabulary**: Use "self-managed", "managed", "serverless/fully managed" as the three-tier deployment vocabulary. This aligns with iac-minion's deployment strategy categories so the two agents reinforce each other through shared terminology without direct cross-references.

## CRITICAL CONSTRAINT: spec vs. AGENT.md boundary (from margo governance review)

Items (a) through (e) above are DESIGN INTENT for what the /despicable-lab build pipeline should produce in the AGENT.md. They are NOT literal text to insert into the spec section of the-plan.md.

**Do NOT insert** the two-column table, the proportionality signals, the framing rules, or the shared vocabulary definitions as literal spec text.

**DO add only**:
- The remit expansion (item 1 above)
- The research focus expansion (item 2 above)
- The spec-version bump (item 3 above)

The research focus expansion provides the seed that guides /despicable-lab to produce the AGENT.md content described in items a-e. The spec stays compact; the AGENT.md is where operational detail lives.

## Advisory: proportionality heuristic (from margo governance review)

The original plan specified 5 enumerated proportionality signals. Margo's review flagged this as over-specification that would calcify into a checklist. Reduce to 2-3 illustrative examples with "illustrative, not exhaustive" framing. This change applies to the research focus guidance, not to literal spec text (which should not contain the signals at all per the constraint above).

## Constraints (critical)

- This is a SURGICAL change. Do not rewrite margo's simplicity philosophy, YAGNI enforcement, or overall approach.
- The change adjusts what margo evaluates (adding operational burden alongside novelty) and how (two-column budget, infrastructure proportionality). It does NOT change margo's fundamental role or principles.
- Do NOT make margo aware of iac-minion's decision framework. Each agent remains a specialist in its own domain. Alignment happens through shared vocabulary, not shared logic.
- Do NOT add a numeric complexity threshold. Keep the "proportional to problem size" framing.
- Do NOT add technology-specific scoring to the spec (no "serverless = 1 point"). Technology-specific detail belongs in the AGENT.md via the research/build pipeline.

## What NOT to do

- Do not modify any other agent's spec section
- Do not modify the delegation table
- Do not rewrite existing margo principles or "Does NOT do" section

## Files to modify

- `/Users/ben/github/benpeter/2despicable/4/the-plan.md` (lines 537-570 only -- the margo spec section)

## Deliverables

- Updated margo spec section in the-plan.md with expanded remit, expanded research focus, and bumped spec-version.

When you finish your task, mark it completed with TaskUpdate and send a message to the team lead with:
- File paths with change scope and line counts (e.g., "src/auth.ts (new OAuth flow, +142 lines)")
- 1-2 sentence summary of what was produced
