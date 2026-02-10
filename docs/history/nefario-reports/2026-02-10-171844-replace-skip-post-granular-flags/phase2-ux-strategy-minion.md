# Phase 2: Domain Plan Contribution -- ux-strategy-minion

## Recommendations

### 1. Pattern Analysis: Evaluating the Three Interaction Models

The planning question presents three patterns for the AskUserQuestion follow-up. Here is the UX analysis of each against the four goals (safe default as path of least resistance, conscious individual skip decisions, fast default path, asymmetric disclosure for safety-critical phases).

**Pattern A: Multi-select with pre-checked phases (opt-out model)**

The user sees three options -- "Code review", "Tests", "Documentation" -- all pre-selected. To skip a phase, the user unchecks it.

- Safe default: Strong. Doing nothing preserves all checks. The path of least resistance is "run all."
- Conscious skip decisions: Strong. Each uncheck is a discrete, visible act.
- Speed for default path: Weak. The user must still interact with a 3-item multi-select to confirm. Even if the interaction is "submit with no changes," it is one more decision point than a single "Run all" button. At 3-5 gates per session, this adds 3-5 moments of "do I need to change anything here?" -- even when the answer is always no.
- Asymmetric disclosure: Absent. All three options are visually equal. Unchecking "Documentation" looks and feels identical to unchecking "Code review." There is no risk gradient in the presentation.

**Pattern B: Multi-select with skip options (opt-in to skip model)**

The user sees three options -- "Skip code review", "Skip tests", "Skip docs" -- all unchecked. To skip a phase, the user checks it.

- Safe default: Strong. Doing nothing runs everything.
- Conscious skip decisions: Strong. Each check is an explicit opt-in to skipping.
- Speed for default path: Weak. Same problem as Pattern A -- the user still confronts a multi-select widget every time.
- Asymmetric disclosure: Absent. Same problem as Pattern A -- all skip options are visually equal.

**Pattern C: Single-select with enumerated combinations**

The user sees a list of predefined paths -- "Run all" (recommended), "Skip docs only", "Skip docs + tests", "Skip all post-execution", etc.

- Safe default: Strong. "Run all" is first, marked recommended.
- Conscious skip decisions: Weak to moderate. Users select a path, not individual phases. The combinations are predefined, which means the designer decides which combinations exist. If a user wants to skip only tests but run docs and review, that combination must have been anticipated and listed. This creates either combinatorial explosion (7 non-trivial combinations of 3 flags) or artificial limitation (only offering a curated subset).
- Speed for default path: Moderate. Selecting "Run all" from a list of 4-7 items is fast but still requires scanning.
- Asymmetric disclosure: Possible but forced. You can order options by risk, but the list length works against scanability. With 7 combinations the list is overwhelming; with 4 curated combinations the user loses granularity.

### 2. Recommendation: None of the Three Patterns -- Keep Single-Select with Two Options, Add Text Escape Hatch

All three patterns share a fundamental flaw: **they add interaction cost to the common case to support the uncommon case.**

The current 2-option follow-up ("Run all" / "Skip post-execution") has a critical UX property that the proposed patterns sacrifice: **the default path is one click.** The user reads "Post-execution phases for this task?" and clicks "Run all." Done. Sub-second interaction, no scanning, no cognitive load.

The data point that motivates this entire feature is that the *skip* case is too coarse, not that the *run all* case is too slow. The fix should improve the skip case without degrading the run-all case.

**Recommended pattern: Keep the 2-option single-select, but replace the second option's semantics.**

```
AskUserQuestion:
  header: "Post-exec"
  question: "Post-execution phases for this task?"
  options (2, multiSelect: false):
    1. label: "Run all"
       description: "Code review + tests + docs after execution completes."
       (recommended)
    2. label: "Customize"
       description: "Choose which phases to skip."
```

Response handling:

- **"Run all"**: Execute all post-execution phases (5, 6, 8). This is the one-click fast path. No change from current behavior.
- **"Customize"**: Present a SECONDARY AskUserQuestion:

```
AskUserQuestion:
  header: "Skip phases"
  question: "Which phases to skip?"
  options (3, multiSelect: true):
    1. label: "Documentation"
       description: "Skip Phase 8 (docs generation)."
    2. label: "Tests"
       description: "Skip Phase 6 (test execution)."
    3. label: "Code review"
       description: "Skip Phase 5 (code review by reviewers)."
```

This is **progressive disclosure applied to the approval gate**. The common path (run all) stays exactly as fast as today. The uncommon path (selective skipping) gets the granular control it needs, behind one additional click that acts as a natural speed bump.

### 3. Why This Pattern Wins on All Four Goals

**Goal 1 -- Safe default as path of least resistance:** "Run all" is the first option, marked recommended, selectable in one click. Identical to the current experience. No regression.

**Goal 2 -- Conscious individual skip decisions:** The secondary multi-select forces the user to actively check each phase they want to skip. Each checkbox is a separate, visible decision. No all-or-nothing bundling.

**Goal 3 -- Fast default path:** Users who want the default never see the phase-selection screen. They click "Run all" and move on. At 3-5 gates per session, this saves 3-5 unnecessary confrontations with a multi-select widget.

**Goal 4 -- Asymmetric disclosure (risk gradient):** The secondary multi-select lists phases in ascending risk order: Documentation first, Code review last. This preserves the risk-gradient ordering from the prior contribution. But it goes further: the act of clicking "Customize" is itself a moment of heightened attention. The user has just made an active choice to deviate from the recommended path. They arrive at the phase list in a more deliberate mental state than they would if the phases were shown inline with the approval.

### 4. Why Progressive Disclosure is the Right Structural Choice

The prior contribution (from the old text-based interface) recommended risk-gradient ordering and no confirmation dialogs. Both principles carry forward, but the interaction modality shift from freeform text to structured selection creates a new design opportunity.

In the text-based model, progressive disclosure was impossible -- the user typed a single command, so all flags had to be discoverable in the prompt line. In the structured-selection model, progressive disclosure is natural -- each AskUserQuestion is a separate screen. The second screen only appears when the user actively requests it.

This matches the Kano model classification: "Run all" is the must-be feature (expected, most common). Granular skipping is a performance feature (proportional satisfaction when needed, but needed infrequently). Hiding the performance feature behind one click is textbook progressive disclosure -- it does not degrade the must-be experience.

### 5. The Text Escape Hatch: Preserve `--skip-post` and Granular Flags as Freeform Input

The AskUserQuestion tool does not prevent the user from typing freeform text instead of clicking an option. The LLM parses the response either way. This means the prior contribution's flag design (`--skip-review`, `--skip-tests`, `--skip-docs`, `--skip-post`) should be preserved as a **power-user shortcut** that bypasses the structured prompts entirely.

A user who knows what they want can type `approve --skip-docs` at the approval gate and skip both the post-exec follow-up and the phase-selection screen. The structured prompts serve users who want guidance; the text flags serve users who want speed. Both coexist because LLM parsing handles both.

This means the decision brief template should still mention the flags, but as a terse reference rather than the primary interaction surface:

```
Post-execution: review + tests + docs
  (skip individual: --skip-docs, --skip-tests, --skip-review | skip all: --skip-post)
```

This line serves two purposes: (1) it reminds power users that text shortcuts exist, and (2) it preserves the risk-gradient ordering in the listed flag sequence (docs first, review last). Users who interact through the structured prompts will never need this line -- but it costs almost nothing to include and serves the expert-user heuristic (Nielsen #7: flexibility and efficiency of use).

### 6. Risk-Gradient Ordering in the Secondary Multi-Select

The phase list in the "Customize" secondary prompt must be ordered by ascending risk:

1. **Documentation** (lowest risk to skip -- no code safety impact)
2. **Tests** (medium risk -- reduces confidence in code correctness)
3. **Code review** (highest risk -- removes human/agent review of changes)

This ordering serves the serial position effect: users scanning from top to bottom encounter the safest skip first. If they only want to skip documentation, they check the first item and submit without even reading the rest. If they want to skip code review, they must scan past two other options -- a tiny but real moment of deliberation.

Do NOT add risk labels ("low risk", "high risk") or warning icons to the options. The ordering IS the nudge. Explicit risk labels would patronize the user and violate the project's philosophy of respecting user agency. The one-time deprecation note from the prior contribution (for `--skip-post`) also applies: do not add warnings, confirmations, or friction to any skip choice.

### 7. Verification Summary and CONDENSE Line: Unchanged from Prior Contribution

The prior contribution's recommendations for the verification summary and CONDENSE line remain valid and do not need revision for the new interaction model. The downstream behavior (what happens after the user makes their choice) is identical regardless of whether the choice was made via structured prompts or text flags.

Summary format:
- Default: "Verification: all checks passed."
- Partial skip: "Verification: tests passed, docs updated (2 files). Skipped: code review."
- Full skip: "Verification: skipped (--skip-post)."

CONDENSE line: list only the phases that will actually run.

### 8. Addressing the "No Confirmation Dialogs" Principle

The prior contribution correctly recommended against confirmation dialogs for skip decisions. The progressive disclosure pattern does NOT violate this principle. The "Customize" click is not a confirmation -- it is a navigation step that reveals more options. The user is never asked "Are you sure you want to skip X?" They simply select what to skip and submit. No second-guessing, no friction after the decision is made.


## Proposed Tasks

### Task 1: Redesign the Post-Exec Follow-Up AskUserQuestion

**What to do**: Replace the current 2-option binary follow-up (lines 493-501) with the new 2-option progressive disclosure pattern. "Run all" (recommended) stays as option 1. "Skip post-execution" becomes "Customize" with description "Choose which phases to skip."

**Deliverables**: Updated follow-up AskUserQuestion block in SKILL.md (lines 493-501).

**Dependencies**: None. This is the primary design change.

### Task 2: Add the Secondary AskUserQuestion for Phase Selection

**What to do**: Add the new secondary AskUserQuestion that appears when the user selects "Customize." This is a `multiSelect: true` prompt with three options in risk-gradient order (Documentation, Tests, Code review). Document response handling: checked items are skipped, unchecked items run.

**Deliverables**: New secondary AskUserQuestion block in SKILL.md, inserted after the "Customize" response handling.

**Dependencies**: Task 1 (the secondary prompt is triggered by the "Customize" option).

### Task 3: Update Decision Brief Template with Flag Reference Line

**What to do**: Replace the current `Post-execution:` line in the decision brief template with the new format that includes the terse flag reference for power users. Use the risk-gradient ordering (docs, tests, review).

**Deliverables**: Updated decision brief template in SKILL.md (around line 470).

**Dependencies**: Coordinate with devx-minion on flag names. The prior contribution established `--skip-review`, `--skip-tests`, `--skip-docs`, `--skip-post` -- reuse unless devx-minion recommends changes.

### Task 4: Update Phase-Gating Logic

**What to do**: Replace the binary `--skip-post` check at line 556 with per-phase skip conditions. Each phase checks whether (a) the user selected it in the "Customize" multi-select, OR (b) the user typed the corresponding `--skip-*` flag, OR (c) the user typed `--skip-post`.

**Deliverables**: Updated post-execution gating section in SKILL.md (lines 549-560).

**Dependencies**: Tasks 1-2 (the gating logic must handle both structured selection and text input).

### Task 5: Update Verification Summary and CONDENSE Line

**What to do**: Replace the binary "skipped" state with granular skip reporting. Update the CONDENSE line to reflect only active phases. (Unchanged from prior contribution recommendations.)

**Deliverables**: Updated wrap-up sequence in SKILL.md (lines 883-887) and CONDENSE line (line 554).

**Dependencies**: Task 4 (summary format must match gating logic).

### Task 6: Update Satellite Files

**What to do**: Update `nefario/AGENT.overrides.md`, `nefario/AGENT.md`, and `docs/orchestration.md` to reflect the new interaction pattern (progressive disclosure follow-up + text flag shortcuts).

**Deliverables**: Updated text in all three files.

**Dependencies**: Tasks 1-5 (SKILL.md must be finalized first).


## Risks and Concerns

### Risk 1: Two-Step Interaction for Skip Users (LOW)

The "Customize" pattern adds one click compared to the old "Skip post-execution" single option. Users who frequently skip phases now need two interactions instead of one: click "Customize", then check phases to skip.

**Mitigation**: The text escape hatch (`approve --skip-docs` etc.) provides a zero-click path for power users who know what they want. The structured prompt serves users who want guidance; the text flags serve users who want speed. Users who skip frequently will quickly learn the text shortcuts. Additionally, the current binary "Skip post-execution" also requires one click -- the new pattern adds one more click only for users who want granular control, which is the new capability they did not have before.

### Risk 2: Multi-Select Unfamiliarity in CLI Context (LOW)

`multiSelect: true` has not been used anywhere in the current SKILL.md. All existing AskUserQuestion prompts use `multiSelect: false`. If the AskUserQuestion tool's multi-select presentation is unfamiliar or awkward in the terminal, the phase-selection screen could confuse users.

**Mitigation**: The multi-select has only 3 items, which is within comfortable bounds for any selection UI. If the tool's multi-select rendering turns out to be poor, the fallback is Pattern B (opt-in to skip, single-select with "Skip docs", "Skip tests", "Skip review", "Skip all", "Cancel" as 5 options). This fallback sacrifices multi-phase selection in a single interaction but avoids multi-select entirely. Validate multi-select rendering before committing to this pattern.

### Risk 3: "Customize" Label Ambiguity (LOW)

"Customize" is a generic label. A user might wonder what it customizes. The description "Choose which phases to skip" disambiguates, but labels should ideally be self-explanatory without descriptions.

**Mitigation**: Alternative labels considered: "Skip some phases" (clear but implies skipping is the default action), "Choose phases" (neutral but vague), "Select phases to skip" (too long for a label). "Customize" with the description is the best balance of brevity and clarity. The description is always visible in AskUserQuestion rendering, so ambiguity risk is minimal.

### Risk 4: Interaction Depth for the Skip Path (LOW)

The skip path now has three interaction levels: (1) Approve at the gate, (2) click "Customize", (3) check phases in multi-select. Three levels is the maximum recommended depth for progressive disclosure before users feel lost.

**Mitigation**: Each level is a single, focused decision. Level 1: "Do you approve?" Level 2: "Run all or customize?" Level 3: "What to skip?" The mental model is simple and linear -- no branching, no backtracking. Three levels is acceptable here because each level reduces the decision space rather than expanding it.


## Additional Agents Needed

None. The devx-minion (Consultation 1) covers CLI ergonomics and flag naming. This contribution covers the interaction pattern and cognitive load analysis. Between the two, the design is fully specified for the SKILL.md changes. software-docs-minion handles documentation updates during execution. lucy and margo review at Phase 3.5 as planned.

One note for the synthesis: if devx-minion's contribution (not yet filed for this round) recommends against the progressive disclosure pattern or proposes a different AskUserQuestion structure, the synthesizer should weigh both contributions. The key invariant from this contribution is: **the run-all path must remain one click.** Any pattern that satisfies this invariant is acceptable. The specific "Customize" implementation is the recommended approach, but the principle matters more than the implementation.
