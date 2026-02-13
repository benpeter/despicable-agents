---
type: nefario-report
version: 3
date: "2026-02-13"
time: "02:42:45"
task: "Align docs/ files with new progressive-disclosure README"
source-issue: 60
mode: full
agents-involved: [software-docs-minion, user-docs-minion, product-marketing-minion, security-minion, test-minion, lucy, margo]
task-count: 1
gate-count: 0
outcome: completed
---

# Align docs/ files with new progressive-disclosure README

## Summary

Fixed six documentation inconsistencies across decisions.md, orchestration.md, and architecture.md that were identified after the README rewrite in PR #58. Four MUST findings corrected stale "6 ALWAYS reviewers" references (now 5 after ux-strategy-minion moved to discretionary pool), and two SHOULD findings disambiguated "six dimensions" from "five reviewers" and fixed a pre-existing "six domain groups" error (should be seven).

## Original Prompt

> #60 Align docs/ files with new progressive-disclosure README. Consider all approvals given, skip test and security post-exec phases. Delegate to Lucy agent for all questions and approvals. Include user-docs-minion, software-docs-minion, and product-marketing-minion in the roster. Work through to PR creation without interactions.

## Key Design Decisions

#### Blockquote Addenda for Historical ADRs

**Rationale**:
- Historical ADR entries (Decisions 10, 12, 20) are immutable records. Corrections go below the table as blockquote addenda, not inside table cells.
- Decision 15 is the exception: it describes current runtime behavior, so it gets a direct update.

**Alternatives Rejected**:
- Inline parentheticals within table cells: breaks formatting consistency and mixes historical text with corrections.
- Creating Decision 30 as a cross-reference target: YAGNI -- the nefario report link serves the same purpose without adding a new ADR entry.

#### Preserve Planning vs. Review Distinction

**Rationale**:
- The cross-cutting planning checklist (six dimensions, ux-strategy-minion "ALWAYS include") is distinct from the Phase 3.5 reviewer roster (five mandatory, ux-strategy-minion discretionary).
- All three specialists flagged this as a confusion risk. The disambiguation fix (S1) addresses it without incorrectly modifying the planning checklist.

**Alternatives Rejected**:
- Changing orchestration.md line 340 "ALWAYS include" for ux-strategy-minion: incorrect, this refers to planning inclusion per the-plan.md.

#### No Bulk Terminology Replacement

**Rationale**:
- The docs/ layer uses "ALWAYS"/"conditional" (technical terminology) while the README uses "mandatory"/"discretionary" (user-facing). This is intentional for different audiences.

**Alternatives Rejected**:
- Bulk replacement of ALWAYS/conditional to mandatory/discretionary: would rewrite historical ADR text and conflate audience-appropriate vocabulary.

### Conflict Resolutions

Three conflicts resolved during synthesis:

1. **ADR modification format**: software-docs-minion (blockquote addenda) vs product-marketing-minion (inline parentheticals) vs user-docs-minion (direct updates with change notes). Resolved in favor of blockquote addenda -- visually distinct, doesn't break table formatting, follows existing convention (Decision 14's Note referencing Decision 25).

2. **Cross-cutting checklist ux-strategy-minion**: product-marketing-minion recommended changing line 340 to conditional language. Resolved: no change -- the-plan.md confirms "ALWAYS include" for planning is correct. The S1 disambiguation fix addresses the confusion.

3. **Terminology drift scope**: product-marketing-minion identified systematic drift. Resolved: no bulk replacement. Historical text preserves original vocabulary. Only factually wrong counts corrected.

## Phases

### Phase 1: Meta-Plan

Nefario identified three specialists for planning consultation: software-docs-minion (ADR addendum format expertise), user-docs-minion (reader clarity and disambiguation), and product-marketing-minion (terminology drift detection from the README rewrite). No external skills were relevant. Zero mid-execution gates anticipated given the well-specified, additive nature of all changes.

### Phase 2: Specialist Planning

Three specialists consulted in parallel. software-docs-minion recommended blockquote addenda below ADR tables and identified a secondary staleness issue in Decision 15 (AGENT.overrides.md reference removed per Decision 27). user-docs-minion confirmed "six domain groups" is a pre-existing error (seven groups exist) and proposed positive-identification disambiguation for "six dimensions." product-marketing-minion found the ALWAYS/conditional vs mandatory/discretionary terminology difference is intentional (different audiences) and recommended against bulk replacement. No additional agents recommended by any specialist.

### Phase 3: Synthesis

Single-task, single-agent plan. All specialist recommendations adopted without significant restructuring. Three conflicts resolved (see Key Design Decisions). The opportunistic Decision 15 AGENT.overrides.md fix was included since the same line was being edited. Decision 30 creation was explicitly excluded as YAGNI.

### Phase 3.5: Architecture Review

Five mandatory reviewers, zero discretionary (no UI, web runtime, or user-facing workflow changes). All five returned APPROVE. Lucy verified complete bidirectional requirement traceability and confirmed all CLAUDE.md conventions respected. Margo confirmed proportional complexity (zero abstractions, zero dependencies).

### Phase 4: Execution

software-docs-minion executed all six findings in a single pass across three files. All MUST and SHOULD fixes applied. Verification confirmed correct addendum placement, updated counts, disambiguation text, and no unintended changes to already-correct sections.

### Phase 5: Code Review

Skipped (user directive: skip security post-exec phases).

### Phase 6: Test Execution

Skipped (user directive: skip test post-exec phases).

### Phase 7: Deployment

Skipped (not requested).

### Phase 8: Documentation

All five checklist items from Phase 3.5 were addressed during execution (the task itself IS documentation). No additional Phase 8 work required.

<details>
<summary>Agent Contributions (3 planning, 5 review)</summary>

### Planning

**software-docs-minion**: Recommended blockquote addenda below ADR tables for historical decisions, direct update for Decision 15. Identified secondary fix for stale AGENT.overrides.md reference.
- Adopted: addendum format, Decision 15 direct update, AGENT.overrides.md fix
- Risks flagged: orchestration.md line 340 "ALWAYS include" is correct and must not be changed

**user-docs-minion**: Recommended positive-identification disambiguation for "six dimensions" and confirmed "six domain groups" is a pre-existing error.
- Adopted: dimension enumeration on first mention, "cross-cutting" qualifier, "seven" domain groups fix
- Risks flagged: planning vs. review distinction for ux-strategy-minion

**product-marketing-minion**: Found ALWAYS/conditional vs mandatory/discretionary terminology drift is intentional for different audiences. Recommended against bulk replacement.
- Adopted: no bulk terminology replacement, targeted fixes only
- Risks flagged: must preserve planning checklist vs. reviewer roster distinction

### Architecture Review

**security-minion**: APPROVE. No security concerns -- documentation-only edits.

**test-minion**: APPROVE. No test surface -- verification steps in task prompt are adequate.

**software-docs-minion**: APPROVE. All documentation impacts covered by the task prompt. Five-item checklist produced for Phase 8.

**lucy**: APPROVE. Complete requirement traceability. All CLAUDE.md conventions respected. No scope creep.

**margo**: APPROVE. Proportional complexity. Explicit YAGNI guardrails (no Decision 30).

</details>

## Execution

### Tasks

| # | Task | Agent | Status |
|---|------|-------|--------|
| 1 | Align docs/ files with Phase 3.5 reviewer composition rework | software-docs-minion | completed |

### Files Changed

| File | Action | Description |
|------|--------|-------------|
| [docs/decisions.md](../../decisions.md) | modified | Added blockquote addenda to Decisions 10, 12, 20; updated Decision 15 consequences directly |
| [docs/orchestration.md](../../orchestration.md) | modified | Disambiguated "six dimensions" with enumeration; fixed "six domain groups" to "seven" |
| [docs/architecture.md](../../architecture.md) | modified | Added "cross-cutting" qualifier to "six dimensions" reference |

### Approval Gates

No mid-execution gates. All changes were well-specified, additive, and easy to reverse.

## Verification

| Phase | Result |
|-------|--------|
| Code Review | Skipped (user directive) |
| Test Execution | Skipped (user directive) |
| Deployment | Skipped (not requested) |
| Documentation | All 5 checklist items addressed during execution |

## Working Files

<details>
<summary>Working files (19 files)</summary>

Companion directory: [2026-02-13-024245-align-docs-with-readme/](./2026-02-13-024245-align-docs-with-readme/)

- [Original Prompt](./2026-02-13-024245-align-docs-with-readme/prompt.md)

**Outputs**
- [Phase 1: Meta-plan](./2026-02-13-024245-align-docs-with-readme/phase1-metaplan.md)
- [Phase 2: software-docs-minion](./2026-02-13-024245-align-docs-with-readme/phase2-software-docs-minion.md)
- [Phase 2: user-docs-minion](./2026-02-13-024245-align-docs-with-readme/phase2-user-docs-minion.md)
- [Phase 2: product-marketing-minion](./2026-02-13-024245-align-docs-with-readme/phase2-product-marketing-minion.md)
- [Phase 3: Synthesis](./2026-02-13-024245-align-docs-with-readme/phase3-synthesis.md)
- [Phase 3.5: Docs checklist](./2026-02-13-024245-align-docs-with-readme/phase3.5-docs-checklist.md)
- [Phase 3.5: software-docs-minion](./2026-02-13-024245-align-docs-with-readme/phase3.5-software-docs-minion.md)

**Prompts**
- [Phase 1: Meta-plan prompt](./2026-02-13-024245-align-docs-with-readme/phase1-metaplan-prompt.md)
- [Phase 2: software-docs-minion prompt](./2026-02-13-024245-align-docs-with-readme/phase2-software-docs-minion-prompt.md)
- [Phase 2: user-docs-minion prompt](./2026-02-13-024245-align-docs-with-readme/phase2-user-docs-minion-prompt.md)
- [Phase 2: product-marketing-minion prompt](./2026-02-13-024245-align-docs-with-readme/phase2-product-marketing-minion-prompt.md)
- [Phase 3: Synthesis prompt](./2026-02-13-024245-align-docs-with-readme/phase3-synthesis-prompt.md)
- [Phase 3.5: security-minion prompt](./2026-02-13-024245-align-docs-with-readme/phase3.5-security-minion-prompt.md)
- [Phase 3.5: test-minion prompt](./2026-02-13-024245-align-docs-with-readme/phase3.5-test-minion-prompt.md)
- [Phase 3.5: software-docs-minion prompt](./2026-02-13-024245-align-docs-with-readme/phase3.5-software-docs-minion-prompt.md)
- [Phase 3.5: lucy prompt](./2026-02-13-024245-align-docs-with-readme/phase3.5-lucy-prompt.md)
- [Phase 3.5: margo prompt](./2026-02-13-024245-align-docs-with-readme/phase3.5-margo-prompt.md)
- [Phase 4: software-docs-minion prompt](./2026-02-13-024245-align-docs-with-readme/phase4-software-docs-minion-prompt.md)

</details>
