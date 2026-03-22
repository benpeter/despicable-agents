# Code Review: margo YAGNI Two-Tier Evaluation

Reviewed files:
- `margo/AGENT.md` (logic-bearing)
- `the-plan.md` (canonical spec)
- `docs/decisions.md` (decision record)

---

VERDICT: ADVISE

FINDINGS:

- [ADVISE] margo/AGENT.md:172-177 -- The label placement is structurally ambiguous. The `ROADMAP-PLANNED` label is applied at step 2 when the item is TRIVIALLY NON-BREAKING, but the label name suggests a category (roadmap-planned), not an outcome (accept/flag). An item that is roadmap-planned but STRUCTURALLY COMPLEX falls into step 2's second branch and gets flagged for deferral -- correctly -- but it is never explicitly labeled. The evaluation logic is "label ROADMAP-PLANNED, then evaluate complexity only" per the decision record (decisions.md:464), but the prompt says to label it when *accepting*, not when classifying. A margo instance evaluating a structurally complex roadmap-planned item may apply no label at all, making the verdict format requirement (lines 181-184) unenforceable for that case.
  AGENT: synthesis-agent (implementing Decision 33)
  FIX: Split label assignment from outcome. Label the classification in step 1 (once concrete consumer confirmed: "classify as ROADMAP-PLANNED") and label the outcome in step 2 ("ACCEPT" or "FLAG FOR DEFERRAL"). Then in the verdict format block, require both labels: `ROADMAP-PLANNED [ACCEPT]` or `ROADMAP-PLANNED [DEFERRED: reason]`. This matches how SPECULATIVE is used (it is both a classification and an outcome in one, since speculative always means exclude).

- [ADVISE] margo/AGENT.md:181-184 -- The citation requirement ("cite: issue number, milestone name, or task reference") appears only in the verdict format label block, not in step 1 where the concrete consumer is evaluated. The three-part consumer definition at lines 163-167 requires a specific milestone, task, or issue -- but the citation is not required until verdict output. An agent applying the test could confirm concreteness mentally and then fail to surface the citation in the output. Since the citation is the auditable proof of concreteness, it should be required at the evaluation step, not deferred to the label.
  AGENT: synthesis-agent
  FIX: Add to step 1 YES branch: "YES concrete consumer -> identify and record the citation (issue number, milestone name, or task reference) -> proceed to step 2." This makes the citation a gate at evaluation, not an afterthought at output.

- [NIT] margo/AGENT.md:226 -- The scope creep detection update ("see YAGNI Enforcement for roadmap-planned item evaluation") is a correct cross-reference but uses informal navigation language. The YAGNI Enforcement section is titled exactly that (line 147), so the reference is resolvable -- this is minor.
  AGENT: synthesis-agent
  FIX: No change required; noting only.

- [NIT] docs/decisions.md:450 -- Decision 32 section header (`## Agent Attribution (Decision 32)`) was added as part of this diff. The previous section headers for similar grouped decisions (e.g., "## Nefario v2.0 (Decisions 20-31)") use a different heading style. Decision 32 now has its own `##` header while being the only decision in that group. Decision 33 also gets its own `##` header. These stand in contrast to the grouped `##` headers for earlier decisions. The inconsistency is cosmetic and doesn't affect function, but it degrades the document's navigability pattern.
  AGENT: synthesis-agent
  FIX: Either group 32+33 under a shared `##` header (e.g., "## Recent Decisions (32-33)") or add a note that standalone `##` headers are the new pattern going forward. Given the project's pace, the latter is simpler.

---

## Summary

The two-tier decision tree is logically sound and the SPECULATIVE/ROADMAP-PLANNED labels are consistent across all three edit points (AGENT.md YAGNI Enforcement section, AGENT.md Working Patterns step 4, the-plan.md Remit, decisions.md Decision 33). The core logic -- speculative items always flagged, roadmap-planned items filtered by proportional cost -- is clearly expressed and unambiguous for the common cases.

The two ADVISE findings address edge-case ambiguity: (1) a roadmap-planned item that is structurally complex is handled correctly by the logic but escapes the labeling requirement, and (2) the citation requirement is deferred to output rather than enforced at evaluation. Neither is a correctness bug in the happy path, but both create auditing gaps when margo is producing verdicts under orchestration.

The spec version bump from 1.1 to 1.2 in both `the-plan.md` and `margo/AGENT.md` frontmatter is correct and consistent. `x-build-date` in `margo/AGENT.md` remains "2026-02-14" and was not updated -- this is expected if the convention is to update it only on full regeneration, but worth confirming intent.
