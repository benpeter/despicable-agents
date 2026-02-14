ADVISE

---

[ux-strategy]: CLAUDE.md template progressive disclosure needs one simplification
SCOPE: Task 5 (docs/claudemd-template.md)
CHANGE: Remove the four HTML comment examples (existing infrastructure, constraints, team context, preferences). Replace with one HTML comment: "<!-- Add context that helps agents understand your deployment situation: existing infrastructure, constraints, team capacity, or preferences -->". The current design forces users to evaluate four pre-defined categories, creating cognitive load even for users who would otherwise write a simple one-sentence declaration.
WHY: Progressive disclosure aims to reduce cognitive load, not shift it. The template currently shows four decision points in comments (do I have existing infrastructure? constraints? team context? preferences?) that users must evaluate even if they choose not to fill them in. This violates "don't make me think." Users with simple needs ("We use Vercel") should write one sentence without evaluating a checklist. Users with complex needs will provide context naturally without prompt categories.
TASK: Task 5

---

[ux-strategy]: Default behavior explanation creates false dichotomy
SCOPE: Task 5 requirement 6 (default behavior when no deployment section exists)
CHANGE: Clarify that "simplest viable" applies to the agent's recommendation, not to what the user must understand. The current framing in requirement 6 says agents will "state what they chose and why, briefly" -- this is good. But the surrounding language implies users need to understand the difference between "simplest-viable" (a principle) vs "serverless" (an implementation). Users don't need this mental model. Recommend revising the template doc to say: "When no Deployment section exists, agents recommend an approach and explain their reasoning. You can accept or redirect."
WHY: Users hire agents to make deployment decisions, not to learn deployment taxonomy. The distinction between "simplest viable" and "serverless" is internal agent framing that shouldn't leak into user-facing documentation. Focus on the user's job: understanding what the agent recommends and having the power to redirect. The current framing adds a conceptual layer ("here's why we don't say serverless even though we might choose serverless") that serves agent design philosophy, not user needs.
TASK: Task 5

---

[ux-strategy]: Example balance is correct but needs one addition
SCOPE: Task 5 requirement 4 (three filled examples)
CHANGE: Add a fourth example showing the minimal case: "We deploy on Vercel." (one sentence, no elaboration). This is distinct from "no preference" (section omitted) -- it signals a platform choice without justifying it. Currently the three examples range from moderate specificity to high specificity, missing the lower bound.
WHY: The job of examples is to show the range of valid input. The current three examples all include justification or context (budget constraint, existing setup, team size). A user who simply wants to say "use platform X" has no pattern to follow and may over-elaborate unnecessarily. The minimal example teaches that one sentence is sufficient when that's all the user wants to communicate. This supports satisficing behavior -- users take the first reasonable option that matches their need.
TASK: Task 5

---

[ux-strategy]: Journey coherence across spec changes is sound
SCOPE: Tasks 1-4 (spec updates and delegation table)
CHANGE: None required.
WHY: The spec changes create a coherent journey for the user facing a deployment decision: (1) nefario routes to deployment strategy selection, (2) iac-minion evaluates criteria and proposes approach, (3) margo catches disproportionate complexity, (4) user receives a recommendation with stated reasoning. The journey supports progressive disclosure (user doesn't need to know about serverless vs containers upfront) and reduces cognitive load (agent makes the decision, user validates or redirects). The delegation table additions are task-type framed, not solution-category framed, which prevents premature classification.
TASK: Tasks 1-4

---

[ux-strategy]: Two-column complexity budget maintains simplicity
SCOPE: Task 2 (margo spec update, two-column complexity budget design)
CHANGE: None required.
WHY: The two-column model (self-managed vs managed) adds one dimension to the existing four-row budget. This is the minimal change needed to recalibrate scoring for operational burden. The synthesis correctly rejected ai-modeling-minion's proposal for build-time vs operational dimensions with lifetime multipliers -- that would have over-engineered the heuristic. The approved model follows KISS: same conceptual structure, one additional column, no formulas. Users facing margo's governance reviews will see scoring that reflects operational reality without learning new complexity assessment machinery.
TASK: Task 2
