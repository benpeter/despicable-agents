## Domain Plan Contribution: product-marketing-minion

### Recommendations

**The comment should emphasize automation -- "issue in, PR out" -- not GitHub integration or the 9-phase process.**

Here is the reasoning by elimination:

1. **"Full 9-phase process from a single command" (orchestration scope)** -- This is feature language, not value language. The nine phases are an implementation detail. A new user scanning the Examples section does not yet know why nine phases matter. Telling them "9-phase process" before they understand the value is like saying "16-layer neural network" instead of "identifies objects in photos." The orchestration depth is already conveyed elsewhere in the README (the "How It Works" section exists for this). Reject.

2. **"Point it at an issue" (GitHub integration)** -- This describes the input mechanism, not the outcome. It is necessary context (the user needs to know the command takes an issue number), but it is not the value. GitHub integration is a means, not an end. Developers do not wake up wanting "GitHub integration." They wake up wanting their issue backlog to shrink. This framing belongs in the command syntax, not the comment. Partially useful, but insufficient alone.

3. **"Issue in, PR out" (automation/outcome)** -- This is the job-to-be-done framing. It describes the progress a developer is trying to make: they have a defined task (issue) and they want a shippable result (PR). The compressed before/after ("issue in, PR out") is the kind of concrete, verifiable claim developers respond to. It passes the "show, don't tell" test because the reader can immediately picture what happens. It also carries an implicit promise of end-to-end completeness without needing to explain the mechanism.

**The winning comment should combine the trigger (issue number) with the outcome (PR), treating the orchestration as the invisible machinery that makes it happen.** This mirrors how the existing examples work: the comment describes the job, the command shows the invocation, the follow-up annotation shows the output.

**Proposed comment and example block:**

```
# Got a GitHub issue? Point nefario at it -- issue in, PR out.
/nefario #42
# → full orchestration: plan, governance review, parallel execution, PR with "Resolves #42"
```

This works because:
- The comment line is 13 words (within the 15-word limit)
- "Got a GitHub issue?" meets the reader at their moment of struggle (JTBD)
- "Point nefario at it" tells them what to do (action)
- "issue in, PR out" delivers the value promise (outcome)
- The follow-up annotation mirrors the pattern of the existing examples (each has a `# →` line showing output)
- "Resolves #42" is a concrete, verifiable detail that signals automatic PR linking -- a gain creator that experienced GitHub users will immediately recognize

**Alternative comment options ranked by effectiveness:**

1. `# Got a GitHub issue? Point nefario at it -- issue in, PR out.` (recommended -- combines trigger with outcome)
2. `# Have a GitHub issue? Nefario turns it into a reviewed PR.` (slightly more formal, loses the punchy parallelism)
3. `# Turn any GitHub issue into a PR -- planning, execution, and review included.` (buries the command pattern, reads more like marketing copy)

I recommend option 1. The casual "Got a GitHub issue?" opener matches the conversational register of the existing comments ("Need to validate your auth flow?", "Leaking memory under load?", "Multi-domain task?"). All three existing comments use question-mark openers. The new example should follow this pattern for consistency.

### Proposed Tasks

**Task 1: Add issue-driven example to README Examples section**

- What to do: Insert a fourth example block after the existing `/nefario` example (line 27-29), following the established pattern of comment + command + annotation.
- Deliverable: Updated `/Users/ben/github/benpeter/2despicable/3/README.md` with the new example block inserted at the right position within the existing ```` ``` ```` code fence (lines 17-30).
- Dependencies: None. The existing examples provide the pattern to follow.

**Placement decision:** The new example should go after the existing `/nefario` example (line 27-29), not before or between the specialist examples. Rationale: the Examples section establishes a progression from simple (single specialist) to complex (multi-domain orchestration). The issue-driven workflow is a variation of the `/nefario` pattern, not a new complexity tier. Placing it immediately after the existing `/nefario` example groups the orchestrator invocations together and shows two ways to invoke the same capability.

**Task 2: Verify consistency with using-nefario.md**

- What to do: Confirm that the README example does not contradict or duplicate what is already in `docs/using-nefario.md` lines 60-83 (the "GitHub Issue Integration" section). The README example should be a teaser that drives readers to the docs for details, not a parallel explanation.
- Deliverable: Confirmation that the example is consistent; no changes needed to docs/.
- Dependencies: Task 1.

### Risks and Concerns

1. **Issue number specificity.** Using `#42` as the example number is fine -- it is clearly illustrative. But if there is an actual issue #42 in this repo that is unrelated or closed, a reader who tries it will get confused. This is a minor risk and standard practice for examples, but worth noting.

2. **Overpromising the automation.** "Issue in, PR out" implies full autonomy. The actual workflow includes a human approval gate at Phase 3/4 (plan review before execution). The follow-up annotation mitigates this by mentioning "governance review," which signals human-in-the-loop. This is important to keep -- removing the annotation would make the promise feel too strong.

3. **Code fence boundaries.** The new example must stay inside the existing fenced code block (lines 17-30). Adding it outside would break the visual grouping. The implementer should insert before the closing ``` on line 30, adding a blank line separator consistent with the spacing between existing examples.

4. **Comment length creep.** The existing comments are terse (7-12 words). The recommended comment at 13 words is at the upper bound. If it feels long in context, the fallback is: `# GitHub issue to reviewed PR in one command.` (8 words, still outcome-focused).

### Additional Agents Needed

None. This is a single-file, single-section edit with clear pattern precedent. The existing README examples establish the format, and the content is a messaging decision within product-marketing-minion's scope. No technical validation, docs changes, or design work is required.
