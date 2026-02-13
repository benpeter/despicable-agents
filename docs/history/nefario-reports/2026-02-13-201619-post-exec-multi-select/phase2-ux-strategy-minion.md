# Phase 2: Domain Plan Contribution -- ux-strategy-minion

## Recommendations

### 1. Framing: Phases to SKIP (opt-in to skip), not phases to RUN (opt-out to skip)

This is the most consequential design decision. The two framings are cognitively different:

**Option A: "Run these" (pre-checked, uncheck to skip)**
- Mental model: "I'm removing protections." Unchecking feels like disarming safety.
- Default state: all checked = run everything. Safe.
- Action semantics: each uncheck is a removal, which conflicts with the typical check-means-affirm mental model. Users expect "check = do something," not "uncheck = do something."
- Risk: the action (uncheck) contradicts the affordance (checkboxes conventionally mean "select this to include it"). Unchecking to skip is a double negative: "I am NOT selecting this TO NOT run it."

**Option B: "Skip these" (unchecked, check to skip)**
- Mental model: "I'm choosing what to exclude." Each check is an active, affirmative decision to skip.
- Default state: nothing checked = run everything. Safe. Identical safe default to Option A.
- Action semantics: check = skip. One cognitive mapping, no double negatives. "Check the things you want to skip."
- Alignment with current design: the existing single-select options are all "Skip X" labels. Users who have developed muscle memory with the current UI will find "Skip docs" as a checkbox label immediately familiar.

**Recommendation: Option B (skip framing).** Both options share the same safe default (nothing selected = run all). But Option B has a cleaner cognitive model because each check is a single affirmative action ("I choose to skip this"), while Option A requires interpreting unchecking as the meaningful action. Option B also maintains label continuity with the current 4-option single-select design, which already uses "Skip docs," "Skip tests," "Skip review" as labels.

### 2. Default States: All Unchecked (run everything)

All options should be unchecked by default. This means:

- **Zero-action path = run all.** The user confirms the multi-select without checking anything, and all phases run. This preserves the one-click-to-run-all invariant established in the prior analysis.
- **Each skip is a conscious opt-in.** No phase is skipped unless the user explicitly checks its checkbox. This aligns with the project goal of "conscious, individual decisions about which verification phases to skip."
- **Satisficing works in the user's favor.** Users who take the first reasonable option (Krug) will submit with no changes, which is the safest outcome.

### 3. "Run all" as a Separate Option: Remove It

With multi-select, "Run all" becomes semantically redundant. Submitting the multi-select with nothing checked IS "run all." Adding a "Run all" checkbox alongside individual skip checkboxes creates three problems:

1. **Logical contradiction.** A user could check "Run all" AND "Skip docs." What happens? This was flagged in the 2026-02-10 devx-minion analysis and remains a real risk. You'd need disambiguation logic that adds complexity for a non-existent benefit.
2. **Cognitive overhead.** An extra option that duplicates the default-no-action path forces every user to parse one more item. "Don't make me think" -- if doing nothing already means run all, a "Run all" checkbox makes users think about what would happen if they checked it alongside a skip option.
3. **Inconsistent interaction paradigm.** "Run all" is an action about the whole set; skip options are actions about individual items. Mixing set-level and item-level controls in a flat list is a category error in interaction design.

**Recommendation: No "Run all" option.** The multi-select contains exactly 3 options, one per skippable phase. Submitting with none checked = run all. The question text should make this explicit (see section 5).

### 4. Risk-Gradient Ordering: Preserved from Current Design

The three options should be ordered by ascending risk, matching the current single-select design and the principle established in the 2026-02-10 analysis:

1. **Skip docs** -- lowest risk (no code safety impact)
2. **Skip tests** -- medium risk (reduces confidence in correctness)
3. **Skip review** -- highest risk (removes agent review of changes)

This ordering leverages the serial position effect: users scanning from top to bottom encounter the safest skip first. A user who only wants to skip documentation checks the first box and submits without needing to scan further.

Do NOT add risk labels, warning icons, or color coding. The ordering IS the nudge. Explicit risk markers would patronize the user. This principle is unchanged from the prior analysis.

### 5. Proposed Multi-Select Design

```
AskUserQuestion:
  header: "Post-exec"
  question: "Skip any post-execution phases for Task N: <task title>?
    (confirm with none selected to run all)\n\nRun: $summary_full"
  options (3, multiSelect: true):
    1. label: "Skip docs", description: "Skip documentation updates (Phase 8)."
    2. label: "Skip tests", description: "Skip test execution (Phase 6)."
    3. label: "Skip review", description: "Skip code review (Phase 5)."
```

Key design points:

- **Question text explicitly states the default.** "Confirm with none selected to run all" removes ambiguity about what happens when nothing is checked. This is critical for first-time users who haven't seen this prompt before. Without this hint, users might wonder: "If I don't select anything, does it skip everything or run everything?"
- **Header unchanged at "Post-exec"** (9 chars, within 12-char limit).
- **Question ends with `\n\nRun: $summary_full`** per the existing constraint.
- **Labels match the current single-select labels exactly** ("Skip docs", "Skip tests", "Skip review"). Zero re-learning for existing users.
- **Descriptions match the current single-select descriptions exactly.** No gratuitous changes.
- **No "(recommended)" marker on any option.** In the current single-select, "Run all" is marked recommended. With multi-select, the recommended action is "select nothing," which cannot be marked on a specific option. Instead, the question text conveys the recommendation implicitly via "confirm with none selected to run all."

### 6. Progressive Disclosure: No Longer Needed

The prior analysis (2026-02-10) recommended a two-tier progressive disclosure pattern: first prompt offers "Run all" or "Customize," second prompt shows the multi-select. This was the right call when `multiSelect: true` didn't work, because a single-select tier 2 was no better than a flat single-select tier 1 -- adding a click without adding capability.

Now that `multiSelect: true` works, the progressive disclosure tier is unnecessary overhead:

- **The common path is already one interaction.** With multi-select, the user sees the 3 skip options, checks nothing, and confirms. One interaction. Adding a "Run all or Customize?" gate before it would make the common path TWO interactions for zero benefit.
- **The uncommon path (selective skipping) is also one interaction.** The user checks the phases to skip and confirms. No need for a navigation step.
- **Progressive disclosure solves a problem that multi-select eliminates.** The original problem was: single-select can only express one choice. Progressive disclosure worked around that by sequencing two single-selects. Multi-select expresses multiple choices in one step, making the workaround unnecessary.

The one-click-to-run-all invariant is preserved: "confirm with nothing checked" is one action, equivalent to "click Run all" in the current design.

### 7. Interaction with Freeform Flags

The freeform escape hatch (`--skip-docs`, `--skip-tests`, `--skip-review`, `--skip-post`) is handled by devx-minion and is orthogonal to this multi-select design. The two channels coexist:

- **Structured path:** multi-select checkboxes (this analysis).
- **Power-user path:** typed flags in freeform input.

Both produce the same skip configuration downstream. The gating logic must accept input from either channel. This is unchanged from the current design -- the current single-select already coexists with freeform flags.

One note: the current decision brief template includes a flag reference line for power users. This should be preserved. devx-minion owns the flag names; this analysis does not modify them.

### 8. Cognitive Load Analysis

**Current design (4-option single-select):**
- User reads 4 options, selects 1. Hick's Law: log2(4) = 2 bits of decision complexity.
- But: single-select cannot express "skip docs AND tests." The user must fall back to freeform text for combinations. This is a hidden complexity cost -- the structured UI fails silently for a legitimate use case, forcing a modality switch.

**Proposed design (3-option multi-select):**
- User reads 3 options, checks 0-3. Each option is an independent binary decision: skip or don't skip. That's 3 bits of decision complexity, but each bit is trivial (yes/no on a familiar phase).
- No modality switch needed for any combination. All 8 possible configurations (2^3) are expressible through the structured UI.
- Working memory load: 3 items, well within the 7+-2 constraint. Each item is a simple, labeled checkbox with a one-line description. Scanning cost is minimal.

**Net assessment:** The multi-select slightly increases decision points (3 independent binary choices vs. 1 choice from 4 options) but eliminates the hidden complexity of the freeform fallback. For the majority case (run all), cognitive load is equivalent: scan the options, change nothing, confirm. For the skip case, cognitive load is lower: check boxes directly instead of parsing a list of pre-built combinations or typing flags.

### 9. Edge Case: What if `multiSelect: true` Still Has Issues?

The planning question assumes `multiSelect: true` now works. If it doesn't -- if the UI renders it as single-select despite the flag, or if checkbox interaction is broken -- the fallback is the current 4-option single-select design, which is already shipped and functional.

The implementation task should include a verification step: before committing the SKILL.md change, test the `multiSelect: true` rendering in Claude Code's actual UI. If it doesn't work as expected, do not merge. The current design is a reasonable fallback, not a regression.


## Proposed Tasks

### Task 1: Replace Post-Exec Follow-Up AskUserQuestion

**What to do**: Replace the 4-option `multiSelect: false` follow-up (SKILL.md lines 1550-1570) with the 3-option `multiSelect: true` design specified in section 5 above. Update the question text to include the "confirm with none selected to run all" guidance. Remove the "Run all" option. Preserve the freeform flag documentation (lines 1562-1570) unchanged.

**Deliverables**: Updated AskUserQuestion block in SKILL.md (lines 1550-1570).

**Dependencies**: None. This is the core change.

### Task 2: Update Phase-Gating Logic

**What to do**: Update the gating logic (SKILL.md lines 1645-1662) to handle multi-select response format. The current logic checks for specific option labels ("Skip review", "Skip tests", "Skip docs"). With multi-select, the response is a list of selected labels. The gating logic should treat each selected label as a skip directive. If the response list is empty (nothing selected), run all phases.

**Deliverables**: Updated gating section in SKILL.md.

**Dependencies**: Task 1 (must know the exact label strings used in the multi-select).

### Task 3: Update CONDENSE Line and Verification Summary

**What to do**: No structural change needed -- the CONDENSE line format (lines 1657-1662) and verification summary format (lines 1901-1908) already support per-phase skip granularity. Verify that the label-to-phase mapping remains consistent after the option list change. If labels changed, update the mapping references.

**Deliverables**: Verification pass; update only if labels changed.

**Dependencies**: Task 1.

### Task 4: Update Satellite Files

**What to do**: Update `nefario/AGENT.overrides.md`, `nefario/AGENT.md`, and `docs/orchestration.md` to reflect the multi-select interaction pattern. Replace references to 4-option single-select with 3-option multi-select.

**Deliverables**: Updated text in satellite files.

**Dependencies**: Tasks 1-3.

### Task 5: Validate multiSelect: true in Claude Code UI

**What to do**: Before merging any SKILL.md changes, test the `multiSelect: true` AskUserQuestion in Claude Code's actual terminal UI. Verify: (a) checkboxes render correctly, (b) multiple selections are possible, (c) submitting with nothing selected works, (d) the response format is parseable.

**Deliverables**: Validation result. If validation fails, abort the multi-select change and keep the current 4-option single-select.

**Dependencies**: Must happen before Tasks 1-4 are committed. Can happen in parallel with planning.


## Risks and Concerns

### Risk 1: multiSelect: true Still Non-Functional (MEDIUM)

The entire design depends on `multiSelect: true` working in Claude Code's UI. On 2026-02-10, it was confirmed non-functional. The planning question assumes it now works, but this has not been independently verified.

**Impact**: If multi-select doesn't work, all Tasks 1-4 are wasted effort.

**Mitigation**: Task 5 (validation) must gate the implementation. Do not commit SKILL.md changes until multi-select behavior is confirmed in the actual UI. The current 4-option single-select is the safe fallback.

### Risk 2: Multi-Select Response Parsing Ambiguity (LOW)

The LLM interprets AskUserQuestion responses. With single-select, the response is a single string. With multi-select, the response may be a list, a comma-separated string, or some other format. If the response format is unexpected, the gating logic could misinterpret the user's choices.

**Mitigation**: The gating logic is expressed as natural language instructions to the LLM (not code), which makes it format-flexible. As long as the instructions clearly state "each selected label = skip that phase; empty selection = run all," the LLM can interpret any reasonable response format. Still, Task 5 should document the actual response format.

### Risk 3: "Confirm with None Selected" is Unfamiliar (LOW)

Most multi-select interfaces expect at least one selection. A multi-select where the recommended action is "select nothing and confirm" is slightly unusual. Some users might hesitate, wondering if they need to select something.

**Mitigation**: The question text explicitly states "confirm with none selected to run all." This is the primary defense. Additionally, the skip-framing (options are things to skip, not things to run) makes it intuitive that not checking anything means not skipping anything. The mental model is consistent: "I didn't ask to skip anything, so everything runs."

### Risk 4: Loss of "(recommended)" Marker (LOW)

The current "Run all" option carries a "(recommended)" marker that nudges users toward the safe default. With multi-select, there's no option to mark as recommended because the recommended action is inaction (nothing checked). The question text compensates, but the visual nudge is weaker.

**Mitigation**: The question text guidance ("confirm with none selected to run all") replaces the function of the recommended marker. Users who satisfice will read the question, see no reason to check anything, and confirm. The nudge is textual rather than visual, but it's present. If the team wants a stronger nudge, the question could be reworded to "All phases will run. Skip any?" -- which frames running as the established plan and skipping as the deviation. But this is a minor refinement, not a blocker.


## Additional Agents Needed

None. The devx-minion handles freeform flag semantics and CLI ergonomics. This contribution covers the structured multi-select interaction design. Between the two, the AskUserQuestion change is fully specified. lucy and margo review at Phase 3.5 as usual. software-docs-minion handles satellite file updates during execution.

One coordination note for the synthesizer: if devx-minion recommends changes to the option labels (e.g., different wording for "Skip docs"), the labels in this analysis should be updated to match. The UX principles (skip framing, risk-gradient ordering, no "Run all" option, explicit default guidance in question text) are invariants; the exact label strings are negotiable.
