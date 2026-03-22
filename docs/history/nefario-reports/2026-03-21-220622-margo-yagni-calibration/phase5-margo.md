# Phase 5 Review: margo (YAGNI/Simplicity)

## Review Scope

Three changed files: `margo/AGENT.md`, `the-plan.md`, `docs/decisions.md`.
Core change: replace binary YAGNI test ("when will we need this?") with a two-tier evaluation (speculative vs. roadmap-planned).

## Assessment

The change addresses a real calibration problem: binary YAGNI was producing false-positive deferrals on trivially non-breaking additions with known consumers. The two-tier structure is a reasonable fix. However, the implementation has some verbosity and redundancy issues.

---

VERDICT: ADVISE

FINDINGS:

- [ADVISE] margo/AGENT.md:160-188 -- Two-tier evaluation is wordy for what it does. The 28-line block could be ~18 lines without losing precision. Specifically: lines 162-168 (the "evaluate in order" preamble and the three-part "concrete consumer" definition) repeat what the labels SPECULATIVE/ROADMAP-PLANNED already convey when defined inline. The parenthetical "(a) names a specific milestone, task, or issue, (b) is on the active roadmap (not backlog or wishlist), and (c) the planned work will read or use the proposed addition" is thorough but could be a single sentence: "A consumer is concrete when a named milestone, task, or issue on the active roadmap will read or use the addition."
  AGENT: margo-minion (producing agent for this section)
  FIX: Compress lines 162-168 into a tighter definition. Suggested rewrite of the core block:

  ```
  **Two-tier justification test**:

  1. **Does a concrete, named consumer exist on the active roadmap?**
     (Concrete = names a specific milestone/task/issue that will use the addition.)
     - NO -> **SPECULATIVE**. Recommend exclusion.
     - YES -> proceed to step 2.

  2. **Is the addition proportional to its cost?**
     - TRIVIALLY NON-BREAKING (additive field, optional parameter, new enum value) -> **ROADMAP-PLANNED**. Accept. Do not flag.
     - STRUCTURALLY COMPLEX (new abstraction, service, framework, or forced changes to existing consumers) -> Flag for deferral. Build when the consumer is built.
  ```

  This preserves all decision logic in fewer lines.

- [NIT] margo/AGENT.md:320-325 -- Working Patterns step 4 restates the two-tier logic that is already fully defined in the YAGNI Enforcement section (lines 160-188). The current text at lines 320-325 is a 6-line paraphrase. A cross-reference would be tighter: "Apply YAGNI test: for each component, apply the two-tier evaluation from YAGNI Enforcement (speculative vs. roadmap-planned)." This avoids two maintenance points that could drift apart.
  AGENT: margo-minion
  FIX: Replace lines 320-325 with a single-sentence cross-reference to YAGNI Enforcement section.

- [NIT] margo/AGENT.md:229-230 -- The parenthetical "(see YAGNI Enforcement for roadmap-planned item evaluation)" in the Scope Creep Detection section is a good cross-reference. No issue here -- noting it as correctly done.
  AGENT: margo-minion
  FIX: None needed.

- [ADVISE] docs/decisions.md:453-464 -- Decision 33 section heading uses a redundant pattern: "## YAGNI Calibration (Decision 33)" followed by "### Decision 33: Two-Tier YAGNI Calibration for Margo". The section heading duplicates information from the subsection heading. All other decisions in this file use a group heading ("## Core Architecture", "## Orchestration Refinements") with numbered entries below. Decision 33 gets its own group heading for a single entry.
  AGENT: margo-minion
  FIX: Use a group heading consistent with the file's existing pattern. Either add Decision 33 under an existing group (e.g., "## Governance Refinements") or use a generic group name. The group heading should not repeat the decision number.

- [NIT] the-plan.md:546-548 -- The three-line description of two-tier evaluation in the remit bullet is appropriately concise for a spec file. No issue.
  AGENT: margo-minion
  FIX: None needed.

---

## Summary

The two-tier YAGNI evaluation is the right level of complexity for the calibration problem. It is not over-engineered -- the distinction between speculative and roadmap-planned items is a genuine decision boundary. The ADVISE items are about prose efficiency, not structural over-engineering. The main AGENT.md evaluation block could be ~35% shorter without losing any decision logic, and the Working Patterns step 4 creates a second maintenance point that a cross-reference would eliminate.

No BLOCK issues. The change is proportional to the problem.
