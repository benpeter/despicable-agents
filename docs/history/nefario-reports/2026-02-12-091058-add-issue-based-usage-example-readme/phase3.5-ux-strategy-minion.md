## ADVISE

**Non-blocking UX concerns:**

1. **Arrow symbol inconsistency risk** (line 40-42): The plan instructs the agent to "verify the existing examples use → or -> and match whichever is used," but also specifies to use `->` (ASCII arrow) in the template. This creates potential confusion. The agent should be given one clear instruction: either check first and match, OR use ASCII arrow unconditionally. The current wording could lead to hesitation.

2. **"Issue in, PR out" sets incorrect mental model** (Risk #2, lines 113-116): While the plan acknowledges this as "acceptable," the phrase obscures the collaborative human-AI workflow that is core to nefario's value proposition. Users who internalize "issue in, PR out" may expect zero human involvement, leading to frustration when governance gates appear. The annotation mentions "governance review," but users scan the punchy top line first. Consider: "Got a GitHub issue? nefario can drive it to PR" — shifts from automatic output to assisted workflow.

3. **Missing JTBD clarity**: The example shows *what* happens but not *when* or *why* a user would choose `/nefario #42` over `/nefario <free-text>`. The comment doesn't convey the job-to-be-done. A clearer trigger: "Already scoped the work in an issue? Point nefario at it" — now the user knows when this pattern applies.

**Recommendation**: These are refinements, not blockers. The example will function and teach the mechanic. The above suggestions would reduce friction and set more accurate expectations, but their absence doesn't break the experience.
