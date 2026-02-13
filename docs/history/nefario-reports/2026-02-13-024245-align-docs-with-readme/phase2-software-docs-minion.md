## Domain Plan Contribution: software-docs-minion

### Recommendations

#### 1. ADR Addendum Format: Blockquote Below the Table

Historical ADR entries (Decisions 10, 12, 20) must not be rewritten -- they were correct at the time of writing. The addendum should appear as a blockquote immediately after the decision's table, before the next decision heading. This placement is unambiguous: the addendum is clearly attached to the decision it modifies, and it does not break the table's Markdown rendering.

Recommended format:

```markdown
> **Update (2026-02-12)**: ALWAYS reviewer count reduced from 6 to 5.
> ux-strategy-minion moved to discretionary pool (Phase 3.5 reviewer
> composition rework, [report](history/nefario-reports/2026-02-12-135833-rework-phase-3-5-reviewer-composition.md)).
```

Rationale for this format:
- **Blockquote (`>`)**: Visually distinct from the original decision text. Signals "this was added later" without ambiguity.
- **Bold `Update` with date**: The date establishes when the correction was made. Use the date of the rework (2026-02-12), not today's date, since that is when the change actually happened.
- **Below the table, not inside it**: Putting addenda inside table cells would break the single-row-per-decision format and make cells unwieldy. Below the table is the standard ADR addendum position (analogous to footnotes in academic papers).
- **Link to nefario report, not a Decision N**: There is no formal Decision 30 for the Phase 3.5 rework in decisions.md. The rework was executed via nefario orchestration and documented in the execution report. The addendum should link to that report. If a Decision 30 is created as part of this task, then the addenda should cross-reference Decision 30 instead.

**Do NOT add addenda inside the table cell.** Markdown table cells with blockquotes or multi-paragraph content are fragile across renderers and break the uniform cell structure used throughout decisions.md.

#### 2. Decision 15: Direct Update, Not Addendum

Decision 15 is different from the other three. Its Consequences field describes current runtime behavior ("Every `/nefario` run incurs review cost..."), not a historical snapshot. When a consequence describes how the system works *now* and that description is factually wrong, it must be corrected directly. Leaving it as-is with an addendum would force readers to mentally reconcile two contradictory statements.

Update the Consequences field from:

```
Every `/nefario` run incurs review cost (6 ALWAYS + 0-4 conditional reviewers).
```

to:

```
Every `/nefario` run incurs review cost (5 ALWAYS + 0-6 discretionary reviewers).
```

Also update the stale reference to `AGENT.overrides.md` in the same cell. Decision 27 removed the overlay mechanism -- the constraint is now maintained directly in `nefario/AGENT.md`. Change:

```
Constraint encoded in AGENT.overrides.md and AGENT.md.
```

to:

```
Constraint encoded in AGENT.md (previously also in AGENT.overrides.md, removed per Decision 27).
```

This secondary fix was not flagged in the audit but is a pre-existing inconsistency in Decision 15 that will be noticed during this edit.

#### 3. Whether to Create Decision 30

The Phase 3.5 reviewer composition rework was a significant architectural change -- it restructured the review model from 6-ALWAYS + 4-conditional to 5-mandatory + 6-discretionary with a new approval gate. This clearly warrants an ADR entry. However, creating new ADR entries may be out of scope for this task (which is scoped to "align docs/ files").

**Recommendation**: Create a minimal Decision 30 entry. The nefario report already contains all the rationale, alternatives, and consequences. Decision 30 can be a compact entry that references the report for detail. This gives the addenda in Decisions 10, 12, 20 a proper cross-reference target ("See Decision 30") instead of linking directly to a nefario report.

If creating Decision 30 is deemed out of scope, the addenda should link to the nefario report directly. Both approaches work; the Decision 30 approach is more consistent with how the ADR log references other changes (e.g., Decision 14's Note referencing Decision 25).

#### 4. SHOULD Finding: "Six Cross-Cutting Dimensions"

The references to "six cross-cutting dimensions" in orchestration.md (lines 20, 44, 334) and architecture.md (line 113) are **factually correct**. The cross-cutting checklist has six dimensions (Testing, Security, Usability-Strategy, Usability-Design, Documentation, Observability). This is distinct from the five mandatory Phase 3.5 reviewers.

The rework itself added a "cross-cutting clarification" to AGENT.md (per the nefario report) to distinguish between planning inclusion (the checklist) and Phase 3.5 review (the reviewer roster). No changes are needed to these references.

However, I recommend adding one parenthetical to the most prominent occurrence in orchestration.md (line 334) to preempt the confusion:

```
Every plan is evaluated against a six-dimension checklist (distinct from the Phase 3.5 reviewer roster).
```

This is a low-effort, high-clarity addition. The other occurrences (lines 20 and 44) are deep enough in context that they are unambiguous.

#### 5. SHOULD Finding: "Six Domain Groups"

orchestration.md line 318 states "all six domain groups" but the agent roster in architecture.md shows seven groups (Protocol & Integration, Infrastructure & Data, Intelligence, Development & Quality, Security & Observability, Design & Documentation, Web Quality). This is a pre-existing error unrelated to the rework -- it predates the eight-agent expansion (Decision 20) which added the Web Quality group.

**Fix**: Change "six" to "seven" on line 318. This is a factual correction, not an opinion.

### Proposed Tasks

#### Task A: Add Decision 30 to decisions.md (if in scope)

- **File**: `/Users/ben/github/benpeter/2despicable/2/docs/decisions.md`
- **Action**: Add a new section "## Phase 3.5 Reviewer Composition (Decision 30)" after Decision 29, before the Deferred section
- **Content**: Compact ADR entry: Status Implemented, Date 2026-02-12, Choice (5 mandatory + 6 discretionary with approval gate), Alternatives rejected (keep 6-ALWAYS), Rationale (one paragraph), Consequences (one paragraph). Link to nefario report for full detail.
- **Dependencies**: None. But if created, Tasks B-D should reference "Decision 30" instead of the nefario report.

#### Task B: Add addenda to Decisions 10, 12, 20

- **File**: `/Users/ben/github/benpeter/2despicable/2/docs/decisions.md`
- **Action**: Add blockquote addenda below each decision's table
- **Lines affected**: After line 131 (Decision 10), after line 153 (Decision 12), after line 262 (Decision 20)
- **Dependencies**: Task A (determines whether addenda reference Decision 30 or the nefario report)

#### Task C: Update Decision 15 consequences directly

- **File**: `/Users/ben/github/benpeter/2despicable/2/docs/decisions.md`
- **Action**: Change "6 ALWAYS + 0-4 conditional" to "5 ALWAYS + 0-6 discretionary" on line 191. Also fix the stale AGENT.overrides.md reference.
- **Dependencies**: None

#### Task D: Fix orchestration.md cross-cutting table and domain group count

- **File**: `/Users/ben/github/benpeter/2despicable/2/docs/orchestration.md`
- **Action**: (1) Add parenthetical clarification to line 334. (2) Change "six domain groups" to "seven" on line 318.
- **Dependencies**: None

### Risks and Concerns

1. **No formal Decision for the rework**: The Phase 3.5 rework is one of the most significant architectural changes in the project's history, but it has no ADR entry. The nefario report serves as the decision record, but it is buried in the history directory. If Decision 30 is not created now, it should be flagged for future creation. Without it, the addenda must link to the nefario report, which is less discoverable than a decisions.md entry.

2. **AGENT.overrides.md reference in Decision 15**: This secondary staleness issue was not in the original audit. If fixing it is considered scope creep, it can be split out -- but editing the same line twice is wasteful.

3. **Cross-cutting table "ALWAYS include" for ux-strategy-minion**: orchestration.md line 340 says ux-strategy-minion's planning inclusion rule is "ALWAYS include". This is correct -- it refers to the planning checklist (Phases 1-3), not Phase 3.5 review. It should NOT be changed. But whoever executes Task D should be aware of this distinction to avoid an over-correction.

4. **Addendum date**: Use 2026-02-12 (the date of the rework), not the date this fix is applied. The addendum documents when the change happened, not when the addendum was written.

### Additional Agents Needed

- **lucy**: Should review the final edits to confirm ADR immutability is respected and the addendum format is consistent with project conventions.
- **margo**: Should verify that creating Decision 30 (if in scope) does not violate YAGNI -- the nefario report already documents the decision thoroughly. If Decision 30 would be purely a pointer to the report, margo may recommend skipping it.
