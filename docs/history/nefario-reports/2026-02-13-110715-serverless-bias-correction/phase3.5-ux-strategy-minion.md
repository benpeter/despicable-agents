# Phase 3.5 Review: UX Strategy

## Verdict: APPROVE

The synthesis plan is well-structured from a developer experience perspective. The core insight -- that three independent gaps compound to produce a systematic bias -- is a textbook example of a broken user journey where each step is locally reasonable but the end-to-end outcome fails the user's job-to-be-done.

## Positive Assessment

**Journey coherence is strong.** The 5-level escalation ladder (Section 4) is the plan's best UX contribution. It transforms an implicit, invisible decision ("you get servers because that is all we know") into an explicit, scannable decision framework with clear escalation triggers. This is progressive disclosure applied to infrastructure: start simple, add complexity only when a named constraint demands it. The developer's mental model shifts from "how do I configure infrastructure?" to "do I need infrastructure?" -- a far better framing.

**Cognitive load is reduced, not increased.** Counter-intuitively, adding serverless knowledge to iac-minion reduces the developer's cognitive burden. Today, if a developer suspects serverless is appropriate, they must override the system's recommendation and bring their own knowledge. After this change, the system does the triage. The decision tree (persistent connections? long-running processes? compliance? cost at scale?) offloads the evaluation from the developer's working memory to the agent's knowledge.

**The CLAUDE.md layering is correct.** Placing "serverless-first" preference in each target project's CLAUDE.md rather than in published agents is the right separation. It follows the same progressive disclosure pattern the codebase already uses for technology preferences. Developers who want server-first defaults simply omit the directive. No new concept to learn.

**The "What NOT to Do" table (Section 8) is unusually valuable.** Explicitly documenting rejected alternatives prevents future re-litigation and reduces the cognitive cost of understanding why the system works the way it does.

## Minor Observations (Non-blocking)

1. **Delegation table expansion**: Four new rows is reasonable. The distinction between "serverless platform deployment" and "serverless compute provisioning" may be too granular for nefario's routing -- a developer asking "deploy my API" will not think in those categories. Monitor whether nefario routes correctly in practice, or whether collapsing to two rows (deployment strategy selection + serverless deployment) would reduce routing ambiguity.

2. **Margo's complexity budget numbers**: The shift from a flat 5 to an 8/3 split is directionally correct. The exact numbers are less important than the principle (operational burden matters more than novelty). Expect these to need calibration over time. The risk is developers trying to game the score -- keep the budget as a heuristic guide, not a calculator.

No blocking issues. The plan serves the developer's core job ("deploy my project with appropriate infrastructure") with less cognitive effort than the current system requires.
