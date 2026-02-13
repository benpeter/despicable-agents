# Domain Plan Contribution: ux-strategy-minion

## Recommendations

### Question 1: Should correctly-classified docs-only skips be silent?

**Yes, silent is correct for genuine docs-only changes -- but the current behavior has an accountability gap.**

The orchestration already uses a well-designed two-tier visibility system for post-execution phases:

1. **Entry CONDENSE line** (line 1657): `Verifying: code review, tests, documentation...` -- lists only phases that will actually run. If code review is skipped, it simply does not appear in this list.
2. **Wrap-up verification summary** (lines 1903-1908): Reports what ran and what the user explicitly skipped. Phases skipped by "existing conditionals" (like "no code files") are deliberately excluded from the `Skipped:` suffix.

This design follows the dark kitchen pattern -- the user should not need to monitor internal process decisions. That is sound for phases that are genuinely inapplicable (there is no code to review, so review adds zero value). The user's job is to know what DID happen, not to audit every internal routing decision.

**However**, the gap is: there is nowhere in the entire user journey where the user can see *why* a phase did not run, if they later wonder. If someone modifies AGENT.md files, sees no code review happened, and asks "wait, why not?" -- the answer is buried in an internal classification they never saw and cannot inspect. This becomes more important after the fix, because the classification boundary becomes a substantive decision (was this logic-bearing or documentation?) rather than a trivial one (was the file extension .md or .py?).

**Recommendation**: Do NOT add a skip notification to the dark kitchen flow. That would break the existing pattern and add noise for the majority case. Instead, surface the classification outcome in the wrap-up verification summary when phases were auto-skipped, using a parenthetical:

- Current: `"Verification: all checks passed."` (when everything ran)
- Current: Omits any mention of auto-skipped phases
- Proposed: `"Verification: tests passed. (Code review: not applicable -- docs-only changes)"` when code review was auto-skipped

This preserves the dark kitchen silence during execution while giving the user a retrospective explanation. It respects the satisficing pattern -- users who glance and move on are not burdened, but users who want to understand the decision have a breadcrumb.

### Question 2: Should the classification boundary be surfaced?

**Partially, and only at one point: the execution plan approval gate.**

The execution plan gate (lines 1277-1398) is the user's primary inspection point -- it is designed for "anomaly detection" (line 1280). The user already sees the task list, advisories, and risks here. This is the natural place to surface classification-relevant information, because the user is already in an evaluative mindset.

**Do NOT** surface the raw classification labels ("logic-bearing markdown" vs "documentation-only markdown"). These are internal vocabulary. The user's mental model is simpler: "will my changes get the appropriate quality checks?" Exposing the classification taxonomy violates recognition-over-recall (Nielsen heuristic 6) -- the user would need to learn and remember what "logic-bearing markdown" means.

**Instead**, surface the *consequence* of the classification: which post-execution phases will be eligible to run. The execution plan gate already shows task deliverables; adding a one-line indication of which post-execution phases apply to each task naturally communicates the classification outcome without exposing the classification machinery.

For example, in the task list at the execution plan gate:
```
  1. Update phase-skip conditionals in SKILL.md    [devx-minion, opus]
     Produces: Modified phase 5 conditional logic
     Depends on: none
     Post-exec: code review, tests, docs
```

The `Post-exec:` line is optional supplementary information -- only worth adding if the set differs from the default ("code review, tests, docs"). If all tasks get full post-execution, omit it (progressive disclosure). If a task's output is genuinely docs-only, showing `Post-exec: docs only` signals the classification outcome without any jargon.

**However**: this is a net-new feature addition to the execution plan gate format. The planning question asks whether the classification *should* be surfaced, and the answer is "the consequence should be, the machinery should not." But given the project's YAGNI principles, I would rank this as a **future enhancement, not part of the current fix**. The immediate fix should focus on getting the classification right, not on redesigning the execution plan gate format. The wrap-up verification summary change (Question 1) is lower-cost and directly addresses the accountability gap.

### Question 3: Cognitive load risk of nuanced classification

**The risk is real but manageable, provided the nuance stays internal.**

The user's mental model should remain binary and outcome-focused:

- "My changes will be reviewed" (the orchestrator treats them as substantive)
- "My changes are housekeeping" (the orchestrator skips review)

The internal distinction between "logic-bearing markdown" and "documentation-only markdown" is an implementation detail of the orchestrator. It should NEVER appear in user-facing text. Users do not think in terms of file classification taxonomies -- they think in terms of "did my changes get the quality checks I expected?"

The cognitive load risk materializes if:

1. **The classification leaks into user-facing language.** Error messages, CONDENSE lines, or gate descriptions that say "logic-bearing markdown" or "documentation-only" would force users to learn a new concept that does not map to their mental model. Avoid this.
2. **The classification produces surprising results.** If the user modifies a RESEARCH.md file (which feels like "documentation" to them) and it triggers code review, they may be confused. Or vice versa: they modify something they consider important and review is skipped. Surprise is the real cognitive load cost, not classification nuance.
3. **The classification boundary is inconsistent across sessions.** If the same file type sometimes triggers review and sometimes does not, the user cannot build a reliable mental model.

**Recommendation**: The classification should be deterministic and based on clear, stable criteria (file naming conventions and directory location, not content heuristics). Content-based classification would produce unpredictable results from the user's perspective. A user who sees AGENT.md reviewed in one session but not another (because the content heuristic fired differently) would lose trust in the orchestrator's judgment.

The user should never need to know the word "logic-bearing." They should simply observe that "when I change agent files, they get reviewed; when I change the README, they don't." This maps to their intuitive expectations and requires zero new concepts.

## Proposed Tasks

### Task 1: Add auto-skip explanation to wrap-up verification summary

**What to do**: Modify the verification summary format in `skills/nefario/SKILL.md` to include a brief parenthetical explanation when phases are auto-skipped by conditionals (not by user request). This provides retrospective accountability without breaking the dark kitchen silence during execution.

**Deliverables**: Updated verification summary format examples in SKILL.md (lines ~1903-1908 and ~2103-2109) showing the new parenthetical format.

**Dependencies**: Depends on the classification definition being finalized (the parenthetical text needs to reference the classification outcome in user-friendly language, e.g., "docs-only changes" not "documentation-only markdown classification").

**Scope note**: This is a small, low-risk change to an existing format. It does not require new gates, new CONDENSE lines, or new user-facing concepts.

### Task 2: Ensure classification labels never appear in user-facing output

**What to do**: When the classification boundary is documented in SKILL.md (per software-docs-minion's contribution), include an explicit rule: classification labels (e.g., "logic-bearing markdown," "documentation-only") are internal vocabulary and MUST NOT appear in user-facing output (CONDENSE lines, gate presentations, verification summaries, error messages). User-facing references should use outcome language ("docs-only changes," "code changes," "changes requiring review").

**Deliverables**: A sentence or two in the classification boundary documentation section, co-located with the classification definition.

**Dependencies**: Co-dependent with the classification definition task and the documentation placement task.

### Task 3 (Future enhancement, NOT part of current fix): Post-exec eligibility in execution plan gate

**What to do**: Add an optional `Post-exec:` line to the task list format in the execution plan gate, shown only when post-execution eligibility differs from the default full set.

**Why deferred**: This adds a new field to the execution plan gate format, which is already carefully budgeted at 25-40 lines. It requires design work beyond the scope of the current bug fix. The wrap-up verification summary change (Task 1) provides sufficient accountability for the immediate problem. File as a follow-up issue if the wrap-up change proves insufficient in practice.

## Risks and Concerns

### Risk 1: Classification surprise (medium severity)

If the classification boundary does not match user intuition, users will see unexpected phase-skipping behavior. Example: user edits RESEARCH.md expecting it to be treated as substantive content, but the classifier treats it as documentation. Or: user edits a README expecting a lightweight pass-through, but the classifier treats it as logic-bearing because it is in an agent directory.

**Mitigation**: The classification criteria should be validated against user expectations for each file type in the project. Err on the side of "more review" (classify as logic-bearing when ambiguous) -- false positives (unnecessary review) are far less damaging than false negatives (skipped review for substantive changes).

### Risk 2: User-facing jargon leak (low severity, high impact if it happens)

If "logic-bearing markdown" or similar internal terminology appears in any user-facing output, it creates immediate cognitive load and confusion.

**Mitigation**: Task 2 explicitly guards against this. During code review (Phase 5), reviewers should check for jargon leaks in any text that reaches the user.

### Risk 3: Wrap-up format change breaks existing patterns (low severity)

The verification summary format is referenced in two places in SKILL.md (lines 1903-1908 and 2103-2109). Inconsistent updates would create divergence.

**Mitigation**: Both instances must be updated together. The change is additive (new parenthetical in existing format), not structural.

### Risk 4: Over-engineering the visibility (medium severity)

The YAGNI principle applies strongly here. The temptation will be to add classification visibility everywhere -- in the team gate, the execution plan gate, CONDENSE lines, and the wrap-up. Each addition is individually reasonable but collectively they turn a simple classification fix into a user journey redesign.

**Mitigation**: Strictly limit user-facing changes to the wrap-up verification summary parenthetical (Task 1) and the internal jargon guard rail (Task 2). Defer everything else. The primary fix is getting the classification RIGHT, not making the classification VISIBLE.

## Additional Agents Needed

None. The current team (ai-modeling-minion for classification criteria, lucy for intent alignment, software-docs-minion for documentation placement, ux-strategy-minion for journey coherence) covers the necessary perspectives. The changes to user-facing text are small enough that they do not require ux-design-minion involvement -- there are no new UI patterns, just a parenthetical addition to an existing text format.
