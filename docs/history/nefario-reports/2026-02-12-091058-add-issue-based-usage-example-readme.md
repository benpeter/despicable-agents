---
type: nefario-report
version: 3
date: "2026-02-12"
time: "09:10:58"
task: "Add issue-based usage example to README"
mode: full
agents-involved: [product-marketing-minion, security-minion, test-minion, ux-strategy-minion, software-docs-minion, lucy, margo]
task-count: 1
gate-count: 0
outcome: completed
---

# Add issue-based usage example to README

## Summary

Added a GitHub issue integration example to the README Examples section showing how to run `/nefario #42` to orchestrate work from a GitHub issue. The new example follows the established three-line pattern (comment question + command + annotation) and demonstrates the issue-driven workflow that produces a PR with automatic issue linking. This surfaces a key capability that was documented but not exemplified in the README.

## Original Prompt

> Add issue-based usage example to README
>
> **Outcome**: The README Examples section includes a concrete example showing how to run `/nefario #42` to have the agent team tackle a GitHub issue using the full 9-phase orchestration process, so that new users immediately see the issue-driven workflow.
>
> **Success criteria**:
> - README Examples section contains a `/nefario #<issue>` example
> - Example conveys the end-to-end flow (issue in, PR out) in 1-2 sentences
> - Existing examples are unchanged
>
> **Scope**:
> - In: README.md Examples section
> - Out: Other README sections, docs/ files, skill definitions

## Key Design Decisions

#### Arrow Character: Unicode vs ASCII

**Rationale**:
- Existing README examples all use Unicode arrow `→` (U+2192)
- Template initially proposed ASCII `->` which would create visual inconsistency
- Architecture review (lucy) flagged the mismatch between template and existing file

**Alternatives Rejected**:
- ASCII arrow `->`: Rejected for consistency. Would deviate from established pattern.

#### Example Placement

**Rationale**:
- Positioned after the existing multi-domain `/nefario` example, before the closing code fence
- Groups orchestrator invocations together
- Shows two entry points: free-text prompt vs. issue number

**Alternatives Rejected**:
- Insert between specialist examples: Rejected. Would break the progression from simple (specialist) to complex (orchestrator).
- Insert at the end after all examples: Rejected. Would separate the two `/nefario` variants.

#### Messaging Framing

**Rationale**:
- Lead with outcome framing ("issue in, PR out") rather than mechanism ("GitHub integration") or architecture ("9-phase process")
- Developers scanning a README respond to jobs-to-be-done, not implementation details
- The annotation line includes "governance review" to set expectations about human-in-the-loop workflow

**Alternatives Rejected**:
- "Full 9-phase process from a single command": Rejected. Feature language, not value language. New users don't yet know why nine phases matter.
- "Point it at an issue": Rejected. Describes input mechanism, not outcome.

### Conflict Resolutions

None.

## Phases

### Phase 1: Meta-Plan

Nefario identified this as a narrow, additive documentation edit with a single planning decision: how to frame the issue-driven workflow in a comment that maximizes comprehension. One specialist was consulted: product-marketing-minion for messaging and positioning expertise. Four project-local skills were discovered (despicable-lab, despicable-statusline, despicable-prompter, nefario) but none overlapped with the documentation task domain.

### Phase 2: Specialist Planning

product-marketing-minion evaluated three framing options (orchestration scope, GitHub integration, automation outcome) and recommended leading with "issue in, PR out" as the most compelling JTBD framing. The specialist proposed a question-opener comment (`Got a GitHub issue? Point nefario at it -- issue in, PR out.`) following the established pattern of existing examples. Two tasks were identified: insert the example block and verify consistency with `docs/using-nefario.md`. Risks flagged: issue #42 specificity (accepted as standard placeholder), "issue in, PR out" slight overpromise (mitigated by "governance review" in annotation), comment length at 13 words (within acceptable range).

### Phase 3: Synthesis

Nefario consolidated the messaging recommendation into a single-task execution plan. The synthesis incorporated product-marketing-minion's framing, specified exact placement (after existing `/nefario` example, before closing fence), and embedded a consistency check against the using-nefario.md documentation. Cross-cutting coverage was evaluated: testing, security, observability marked as not applicable; usability strategy addressed within the JTBD analysis; documentation handled within the task itself. No conflicts to resolve. No approval gates warranted (trivially reversible additive edit with zero downstream dependents).

### Phase 3.5: Architecture Review

Six mandatory reviewers evaluated the plan. security-minion: APPROVE (no attack surface). test-minion: APPROVE (documentation-only, no executable output). ux-strategy-minion: ADVISE (three non-blocking concerns: arrow symbol ambiguity in template, "issue in, PR out" mental model risk, missing JTBD clarity about when to use issue mode vs free-text mode). software-docs-minion: ADVISE (three clarifications needed: arrow style check ambiguity, missing action spec for consistency check failures, no line number validation). lucy: ADVISE (arrow character mismatch in template - plan uses ASCII `->` but existing file uses Unicode `→`; template should match). margo: APPROVE (proportional scope, no over-engineering). All ADVISE notes were incorporated into the execution task prompt: corrected template to use Unicode arrow, added line number verification instruction, clarified consistency check handling.

### Phase 4: Execution

product-marketing-minion updated README.md, inserting the new example block at line 30 (after the existing `/nefario` example annotation line, before the closing code fence). The agent verified existing examples use Unicode arrow `→` and matched the style. Consistency check against `docs/using-nefario.md` lines 60-76 (GitHub Issue Integration section) confirmed no contradictions. The new example follows the established three-line pattern: question-format comment (13 words), command line (`/nefario #42`), annotation line with Unicode arrow describing the orchestration flow and PR linking behavior. Total change: +4 lines.

### Phase 5: Code Review

Skipped (documentation-only change, no code files produced).

### Phase 6: Test Execution

Skipped (no tests applicable to markdown documentation).

### Phase 7: Deployment

Skipped (not requested).

### Phase 8: Documentation

Skipped (no documentation checklist items generated; this task itself was documentation).

## Agent Contributions

<details>
<summary>Agent Contributions (1 planning, 6 review)</summary>

### Planning

**product-marketing-minion**: Recommended "issue in, PR out" outcome framing over mechanism or architecture framing. Proposed question-opener comment following existing pattern.
- Adopted: JTBD framing, question-opener register, annotation with governance mention
- Risks flagged: Issue #42 specificity (accepted), overpromise mitigation via annotation, comment length at upper bound

### Architecture Review

**security-minion**: APPROVE. No concerns.

**test-minion**: APPROVE. Documentation-only change, no executable output to test.

**ux-strategy-minion**: ADVISE. Arrow symbol ambiguity (template vs instruction mismatch), "issue in, PR out" sets incorrect mental model (obscures human-AI collaboration), missing JTBD clarity (doesn't convey when to choose issue mode). Recommendations: clarify template instruction, consider "nefario can drive it to PR" phrasing, add trigger context.

**software-docs-minion**: ADVISE. Inconsistent arrow style check (template shows ASCII but instruction says verify and match), missing action spec for consistency check failures, no line number validation. Recommendations: specify exact arrow or show alternatives, add blocking condition for inconsistency, verify code fence boundaries.

**lucy**: ADVISE. Arrow character mismatch - plan template uses ASCII `->` but existing README lines 20, 24, 28-29 all use Unicode `→`. Fix: change template to Unicode to eliminate ambiguity. Annotation style density noted but within acceptable range. CLAUDE.md compliant, intent-aligned.

**margo**: APPROVE. Proportional to problem: one task, one agent, one file, three lines. No new dependencies, no abstractions, no scope creep.

</details>

## Execution

### Tasks

| # | Task | Agent | Status |
|---|------|-------|--------|
| 1 | Add issue-driven example to README Examples section | product-marketing-minion | completed |

### Files Changed

| File Path | Action | Description |
|-----------|--------|-------------|
| README.md | modified | Added GitHub issue integration example (+4 lines) |

### Approval Gates

No approval gates in this execution.

## Verification

| Phase | Result |
|-------|--------|
| Code Review | Skipped (documentation-only change) |
| Test Execution | Skipped (no tests applicable) |
| Deployment | Skipped (not requested) |
| Documentation | Skipped (task itself was documentation) |

## Working Files

<details>
<summary>Working files (7 files)</summary>

Companion directory: [2026-02-12-091058-add-issue-based-usage-example-readme/](./2026-02-12-091058-add-issue-based-usage-example-readme/)

- [Phase 1: Meta-plan](./2026-02-12-091058-add-issue-based-usage-example-readme/phase1-metaplan.md)
- [Phase 2: product-marketing-minion](./2026-02-12-091058-add-issue-based-usage-example-readme/phase2-product-marketing-minion.md)
- [Phase 3: Synthesis](./2026-02-12-091058-add-issue-based-usage-example-readme/phase3-synthesis.md)
- [Phase 3.5: ux-strategy-minion](./2026-02-12-091058-add-issue-based-usage-example-readme/phase3.5-ux-strategy-minion.md)
- [Phase 3.5: software-docs-minion](./2026-02-12-091058-add-issue-based-usage-example-readme/phase3.5-software-docs-minion.md)
- [Phase 3.5: lucy](./2026-02-12-091058-add-issue-based-usage-example-readme/phase3.5-lucy.md)
- [Original Prompt](./2026-02-12-091058-add-issue-based-usage-example-readme/prompt.md)

</details>
