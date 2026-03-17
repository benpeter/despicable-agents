## Margo Review: adapter-interface-definition

**Verdict: ADVISE**

The plan is well-disciplined. Two tasks for a single Markdown document plus cross-references -- scope is proportional to the problem. The YAGNI analysis on excluded fields is solid. The conflict resolutions are well-reasoned. Three specific concerns:

---

1. [complexity]: Behavioral Contract section specifies implementation-level detail beyond a type-and-contract spec
   SCOPE: Task 1 prompt, "Adapter Behavioral Contract" subsection
   CHANGE: Trim the behavioral contract to boundary rules only (the "must NOT do" list and error handling conventions). Remove the 8-step lifecycle sequence -- that is implementation guidance for Issue 2.1/3.2, not a type contract. Adapter authors will discover the lifecycle when they implement the wrapper; prescribing it here couples the spec to a specific execution model before any adapter exists.
   WHY: The original request says "types and contracts only." A behavioral contract that specifies "capture pre-invocation git ref," "place the translated instruction file," and "wait for completion or timeout" is implementation choreography, not interface definition. This is accidental complexity -- it pre-decides implementation details that Issue 2.1 and 3.2 should own. Risk: adapter authors treat the lifecycle as normative and resist simpler approaches that satisfy the same contract.
   TASK: 1

2. [YAGNI]: `duration_ms` included without a current consumer
   SCOPE: DelegationResult field table, `duration_ms` field
   CHANGE: Move `duration_ms` to the "Fields Considered and Excluded" table. Rationale: "No consumer in M1-M4. Adding an integer field later is trivially non-breaking."
   WHY: The plan's own justification is "avoids breaking change when M4 progress monitoring needs it." But adding an optional integer field is never a breaking change. The YAGNI test: "When will we need this?" Answer: "M4 at earliest, maybe." The plan correctly excluded `context_files` and `rationale` with the same reasoning ("can be added non-breakingly when a concrete use case validates the need"). Apply the same standard to `duration_ms`. Two specialists agreeing on a field does not make it needed -- consensus on a YAGNI violation is still a YAGNI violation.
   TASK: 1

3. [over-documentation]: "Fields Considered and Excluded" section is proportionate but risks becoming a change-control artifact
   SCOPE: Task 1 prompt, "Fields Considered and Excluded" subsection
   CHANGE: Keep the section but cap it at fields that were seriously proposed during this planning round (the current 8 entries). Add a single sentence: "This list captures decisions from the initial design. Future field proposals should be evaluated against current needs, not against this list." This prevents the table from becoming a bureaucratic gate where every future field addition requires updating a historical exclusion table.
   WHY: The section's value (preventing re-proposals of already-rejected fields) is real. The risk is that it calcifies into a change-control artifact that makes the spec harder to evolve. A sentence clarifying its purpose prevents this without removing the value.
   TASK: 1

---

All three are non-blocking. The plan's core shape -- one spec document, one linking task, Markdown field tables, YAGNI-filtered field set -- is sound and proportional. The `duration_ms` concern is the most actionable; the other two are refinements.
