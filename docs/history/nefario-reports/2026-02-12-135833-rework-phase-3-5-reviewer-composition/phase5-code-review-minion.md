VERDICT: APPROVE

FINDINGS:

## Roster Consistency (5 mandatory + 6 discretionary)

All three files are internally consistent on the 5/6 split:

**Mandatory reviewers (5)** -- security-minion, test-minion, software-docs-minion, lucy, margo:
- AGENT.md lines 513, 563-570: Table with 5 rows, all marked ALWAYS. Matches.
- SKILL.md lines 611-616 (Identify Reviewers), 647 (auto-approve text "5 mandatory"), 654 (presentation format "security, test, software-docs, lucy, margo"), 681 (AskUserQuestion "5 mandatory + N discretionary"): All consistent.
- orchestration.md lines 59-65: Table with 5 rows matching the same agents and rationale. Matches.

**Discretionary reviewers (6)** -- ux-strategy-minion, ux-design-minion, accessibility-minion, sitespeed-minion, observability-minion, user-docs-minion:
- AGENT.md lines 575-581: Table with 6 rows, domain signals present. Matches.
- SKILL.md lines 623-631: Identical 6-row table. Matches.
- orchestration.md lines 69-76: Condensed domain signal table with 6 rows. Matches.
- orchestration.md line 78: "constrained to the 6-member pool". Matches.
- SKILL.md line 674: "the 6-member discretionary pool only". Matches.

No stale references to the old 6-mandatory or 4-mandatory reviewer counts found in any of the three changed files.

**Cross-cutting checklist distinction**: AGENT.md lines 273-274 explicitly states "an agent can be ALWAYS in the checklist but discretionary in Phase 3.5 review." This resolves the apparent tension with ux-strategy-minion being ALWAYS in the cross-cutting checklist (AGENT.md line 263, orchestration.md line 340) but discretionary in Phase 3.5.

- [NIT] docs/orchestration.md:332-345 -- The cross-cutting concerns table shows ux-strategy-minion as "ALWAYS include" without noting the Phase 3.5 distinction. AGENT.md has the clarifying note at lines 273-274 but orchestration.md does not replicate it. A reader of orchestration.md alone could be confused about why ux-strategy-minion is "ALWAYS" in section 2 but discretionary in section 1 (Phase 3.5).
  FIX: Add a footnote or parenthetical after the cross-cutting table in orchestration.md, e.g.: "Note: This checklist governs agent inclusion in planning and execution phases. Phase 3.5 architecture review has its own triggering rules (see Phase 3.5 section above) -- an agent can be ALWAYS in the cross-cutting checklist but discretionary in Phase 3.5 review."

## Gate Specification Completeness

The Reviewer Approval Gate is fully specified:

- **AskUserQuestion** (SKILL.md lines 676-686): header, question, 3 options. Complete.
- **Response handling** (SKILL.md lines 688-702): All three options handled -- "Approve reviewers" spawns both mandatory + discretionary, "Adjust reviewers" constrained to 6-member pool with 2-round cap, "Skip review" proceeds to Execution Plan Approval Gate with no friction.
- **Auto-skip** (SKILL.md lines 645-648): When no discretionary reviewers selected, auto-approve with CONDENSE note. Complete.
- **Adjustment constraint** (SKILL.md line 694-695): Rejects out-of-pool agents, offers closest match. Complete.

No gaps found in the gate specification.

## software-docs-minion Prompt (Self-Contained and Actionable)

The prompt at SKILL.md lines 738-803 is self-contained:

- **Clear role scoping**: "produce a documentation impact checklist for Phase 8" (line 747)
- **Explicit output path**: `$SCRATCH_DIR/{slug}/phase3.5-docs-checklist.md` (line 758)
- **Structured format**: Checklist template with owner tags ([software-docs] / [user-docs]), Scope, Files, Priority fields (lines 762-787)
- **Priority definitions**: MUST/SHOULD/COULD with clear criteria (lines 785-787)
- **Item cap**: Max 10 items with overflow guidance (lines 788-789)
- **Verdict constraints**: Explicitly says "Do NOT use BLOCK for documentation concerns" (line 795). Allows only APPROVE and ADVISE. The extremely-rare BLOCK exception is documented (line 796-798).
- **Output file path for verdict**: `$SCRATCH_DIR/{slug}/phase3.5-software-docs-minion.md` (line 800) -- separate from checklist file. Correct.

The AGENT.md mirrors this at lines 633-638 ("software-docs-minion exception" paragraph). Consistent.

## Phase 8 Merge Logic

The merge logic at SKILL.md lines 1403-1431 is correct and complete:

- **Step a** (lines 1405-1408): Read Phase 3.5 checklist if exists. Correct path reference (`phase3.5-docs-checklist.md`).
- **Step b** (lines 1410-1425): Supplement with execution outcomes using the outcome-action table. 10 outcome types mapped. Check-before-add logic ("check whether the Phase 3.5 checklist already covers it"). Correct.
- **Step c** (lines 1427-1429): Flag divergence for planned-but-not-implemented items. The text "Planned but not implemented -- verify if still needed" is clear and actionable.
- **Output**: Written to `$SCRATCH_DIR/{slug}/phase8-checklist.md` (line 1431). This is a DIFFERENT file from the Phase 3.5 input (`phase3.5-docs-checklist.md`), preserving the original. Correct design.
- **Downstream consumption** (lines 1436-1443): Sub-step 8a agents receive `phase8-checklist.md` with items tagged by owner. Items from Phase 3.5 have pre-analyzed scope; execution-derived items may need inspection. Clear.

The AGENT.md line 708 summarizes this correctly: "Phase 8: Documentation -- Conditional: runs when documentation checklist has items."

The orchestration.md lines 162 describes the merge: "merging the Phase 3.5 documentation impact checklist...with execution-outcome items." Consistent.

## Formatting and Markdown

- [NIT] AGENT.md line 510 -- Template placeholder reads "for each of the 6 mandatory dimensions" which refers to the 6 cross-cutting concern dimensions, not the 5 mandatory Phase 3.5 reviewers. This is correct but could momentarily confuse someone scanning for "6" expecting it to relate to Phase 3.5. No fix needed since context is unambiguous.

- All markdown tables in the three files render correctly (pipe-aligned, header separators present).
- No orphaned references found. The old "ux-strategy-minion" mandatory reviewer references in historical nefario-reports are immutable history and correctly left unchanged.

## Summary

The three files are well-coordinated. The 5-mandatory/6-discretionary split is consistent across all definitions, tables, gate presentation formats, and AskUserQuestion parameters. The software-docs-minion Phase 3.5 prompt is self-contained with clear format, constraints, and output paths. The Phase 8 merge logic correctly reads, supplements, flags divergence, and writes to a separate merged checklist. The single finding is a minor documentation gap in orchestration.md regarding the cross-cutting vs. Phase 3.5 distinction for ux-strategy-minion.
