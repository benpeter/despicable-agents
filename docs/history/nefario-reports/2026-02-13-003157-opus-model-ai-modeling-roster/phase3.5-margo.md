# Margo Review: serverless-bias-fix

## Verdict: ADVISE

The plan is well-scoped relative to the issue. The four coordinated spec changes plus delegation table rows plus template plus rebuild is the minimum viable set to close all three gaps identified in #91. The conflict resolutions are sound -- particularly choosing task-type naming over solution-category naming (Conflict 1), and choosing the simpler two-column budget over ai-modeling-minion's scoring machinery (Conflict 3). The plan correctly avoids creating a 28th agent, avoids hardcoding "serverless-first," and keeps changes at the spec layer rather than editing generated artifacts.

That said, four items warrant attention:

---

- [complexity]: Infrastructure proportionality heuristic (five signals) risks becoming a checklist margo applies mechanically rather than a judgment tool
  SCOPE: Task 2 prompt, item (c) -- infrastructure proportionality heuristic
  CHANGE: Reduce the five enumerated signals to 2-3 examples with a framing note that these are illustrative, not exhaustive. The current five feel like a specification for a detection algorithm rather than a heuristic. margo's existing pattern is to identify disproportion through reasoning, not through checklist matching.
  WHY: Over-specified heuristics calcify into false-positive generators. The more signals you enumerate, the more margo will pattern-match against them instead of reasoning about proportionality. Three examples suffice to communicate the concept; five starts to feel like a decision tree.
  TASK: 2

- [scope]: Task 2 prompt encodes significant AGENT.md design decisions (items a-e) inside what is labeled a spec-only change
  SCOPE: Task 2 prompt, "Design intent for the AGENT.md build" section
  CHANGE: Acknowledge that items (a)-(e) are guidance for the /despicable-lab build pipeline, not spec text to insert verbatim into the-plan.md. The prompt already says "Design intent for the AGENT.md build (guidance for /despicable-lab, encoded via spec)" but the executing agent may blur the boundary. Consider adding an explicit constraint: "Do NOT insert the two-column table, the five proportionality signals, or the framing rules as literal spec text. Add only the remit expansion, research focus expansion, and version bump. The rest is guidance for what the build pipeline should produce from the expanded research."
  WHY: If the executing agent interprets items (a)-(e) as spec text and inserts all of it into the-plan.md, the spec grows significantly beyond what is needed. The spec should be compact; the AGENT.md is where operational detail lives.
  TASK: 2

- [yagni]: The CLAUDE.md template (Task 5) prompt specifies "three filled examples showing different specificity levels" plus a "no preference" case -- four scenarios total
  SCOPE: Task 5 prompt, examples section
  CHANGE: Three examples is fine; four (including the "no preference" non-example) is borderline but acceptable since the no-preference case is just a one-liner explaining absence. No change needed, but watch for the executing agent inflating examples beyond the four specified.
  WHY: Templates with many examples teach users to copy-paste rather than think. Three is the right number. This is a minor observation, not a change request.
  TASK: 5

- [complexity-budget]: 7 tasks across 4 batches is proportional to the problem -- the issue identifies 3 gaps requiring 3 spec changes, 1 delegation table update, 1 template, 1 doc sweep, and 1 rebuild. Each task maps to a discrete deliverable. No task could be eliminated without leaving a gap unclosed.
  SCOPE: Overall plan structure
  CHANGE: None. This is a confirmation that the task count is justified.
  WHY: The review prompt asked whether 7 tasks could be simplified. They cannot without skipping a gap. Task 6 (docs staleness) could arguably be folded into Task 7 (rebuild), but keeping it separate is correct since it touches different files with a different agent skill set.
  TASK: all

---

Summary: The plan is proportional. The two items worth acting on are (1) trimming the proportionality heuristic from five signals to fewer, and (2) adding an explicit guardrail in Task 2's prompt to prevent spec bloat from the AGENT.md design guidance. Neither is blocking.
