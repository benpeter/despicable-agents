# Domain Plan Contribution: devx-minion

## Recommendations

### 1. The Foundational Prerequisite: Does multiSelect: true Work Now?

The entire task hinges on whether `multiSelect: true` has become functional in
Claude Code since the 2026-02-10 discovery that it did not work. The meta-plan
correctly identifies this as the critical dependency and assigns ai-modeling-minion
to investigate.

**My recommendations below assume multiSelect: true works.** If it does not,
the current 4-option single-select design (implemented 2026-02-10) is already
the correct solution and the task should be closed as "won't fix" or deferred
until the platform supports it. I include a fallback section at the end for
the non-functional case.

### 2. Response Format: What multiSelect: true Returns

The planning question asks about the expected response format. Based on the
AskUserQuestion tool specification and Claude Code's tool response patterns:

**Single-select (`multiSelect: false`)** returns a single string:
```
"<question text>"="<selected label>"
```

**Multi-select (`multiSelect: true`)** should return either:
- (a) A comma-separated string of selected labels:
  `"<question text>"="Label A, Label B"`
- (b) Multiple key-value pairs:
  `"<question text>"="Label A"` and `"<question text>"="Label B"`
- (c) An array-like format:
  `"<question text>"=["Label A", "Label B"]`

**Recommendation**: The skip determination logic should not hard-code any single
format. Instead, it should check whether each phase label **appears** in the
response string, regardless of delimiter format. This is resilient to format
variations because:

1. The label strings ("Code review", "Tests", "Documentation") are distinct
   enough that substring matching produces no false positives among the option set.
2. The LLM interprets the response naturally -- it reads the user's selection
   and determines intent. Whether the response is `"Code review, Tests"` or
   `["Code review", "Tests"]`, the LLM will correctly identify which phases
   were selected.
3. This approach is the same pattern already used for freeform text interpretation,
   where the LLM reads natural language and maps it to skip intent.

The SKILL.md should describe the logic in terms of **semantic matching**
("if the user selected X"), not in terms of parsing a specific string format.
This is already how the current single-select logic works -- it says
"If user selected 'Skip docs'" rather than "If response equals 'Skip docs'".
The same pattern extends naturally to multi-select.

### 3. Freeform Flag Semantics: Preserve Unchanged

The planning question asks whether freeform flag semantics should change now
that multi-select handles combinations natively. **No, they should not change.**

Rationale:

1. **Freeform is a parallel channel, not a workaround.** The previous design
   used freeform as an escape hatch for multi-phase skips because single-select
   could not express combinations. With multi-select, freeform is no longer the
   only way to combine skips. But that does not make it redundant. Users who
   type `--skip-docs --skip-tests` at an approval gate before the follow-up
   prompt appears should still have their intent honored. Removing freeform
   support would break that workflow.

2. **`--skip-post` has no multi-select equivalent.** If the multi-select uses
   positive framing ("select phases to run" -- which ux-strategy-minion will
   likely recommend), then "skip all" means "select nothing." If it uses negative
   framing ("select phases to skip"), then "skip all" means "select everything."
   Either way, `--skip-post` remains the clearest way to express "skip all
   post-execution" in freeform text. It should stay.

3. **Flag names map cleanly regardless of framing.** Whether the options say
   "Code review" (run-these framing) or "Skip review" (skip-these framing),
   the flag `--skip-review` always means "do not run Phase 5." The mapping
   table in SKILL.md lines 1565-1569 stays as-is.

4. **Backward compatibility.** Users and the LLM have trained on these flags
   over three days of orchestration. No reason to change.

**One simplification**: The freeform text documentation can drop the
explanatory note that freeform is "instead of selecting an option" (line 1562).
With multi-select, freeform is a true parallel input method, not an alternative.
The documentation should say: "The user may also type freeform flags at the
same prompt." This is a wording refinement, not a semantic change.

### 4. Multi-Select and Freeform Conflict Resolution

The planning question asks about edge cases where multi-select and freeform
conflict. There are two scenarios:

**Scenario A: User selects phases to run via multi-select AND types skip flags.**
Example: Selects "Code review" and "Tests" (run framing), but also types
`--skip-tests`. This is contradictory.

**Scenario B: User selects nothing via multi-select AND types `--skip-post`.**
This is redundant, not contradictory. Both mean "skip everything."

**Resolution rule (same as current design)**: Freeform text overrides structured
selection when they conflict. This rule was established in the previous
orchestration (phase3-synthesis.md, Risk 4) and should be carried forward.
Document it in SKILL.md:

```
If the user provides both structured selection and freeform text, freeform
text overrides. Example: selecting "Code review" and "Tests" but typing
"--skip-tests" results in running only code review.
```

This rule is simple, predictable, and matches the general CLI principle that
explicit text input (higher effort) signals stronger intent than a GUI click
(lower effort).

### 5. Skip Determination Logic Update (Lines 1645-1662)

The current logic checks for single-select labels ("Skip review", "Skip tests",
"Skip docs") and freeform flags. With multi-select, the logic must handle a
set of selected labels rather than a single one. Here is the updated logic,
written to be framing-agnostic (works whether ux-strategy-minion recommends
run-these or skip-these framing):

**If options use RUN-THESE framing** (user selects phases to run):

```
Determine which post-execution phases to run based on the user's response:
- Phase 5 (Code Review): Run if user selected "Code review" in the
  multi-select. Skip if not selected, or if user typed --skip-review or
  --skip-post. Also skip if Phase 4 produced no code files (existing
  conditional, unchanged).
- Phase 6 (Test Execution): Run if user selected "Tests" in the
  multi-select. Skip if not selected, or if user typed --skip-tests or
  --skip-post. Also skip if no tests exist (existing conditional, unchanged).
- Phase 8 (Documentation): Run if user selected "Documentation" in the
  multi-select. Skip if not selected, or if user typed --skip-docs or
  --skip-post. Also skip if checklist has no items (existing conditional,
  unchanged).
```

**If options use SKIP-THESE framing** (user selects phases to skip):

```
Determine which post-execution phases to run based on the user's response:
- Phase 5 (Code Review): Skip if user selected "Skip review" in the
  multi-select, or typed --skip-review or --skip-post. Also skip if Phase 4
  produced no code files (existing conditional, unchanged).
- Phase 6 (Test Execution): Skip if user selected "Skip tests" in the
  multi-select, or typed --skip-tests or --skip-post. Also skip if no tests
  exist (existing conditional, unchanged).
- Phase 8 (Documentation): Skip if user selected "Skip docs" in the
  multi-select, or typed --skip-docs or --skip-post. Also skip if checklist
  has no items (existing conditional, unchanged).
```

**Key structural change**: The current logic has an implicit "Run all" path
(if no skip option was selected, all phases run). With multi-select using
run-these framing, the default path is now "if nothing is selected, nothing
runs" (skip all). This is a significant behavioral inversion.

**Recommendation to ux-strategy-minion**: If using run-these framing, the
question text must make clear that selecting nothing means running nothing.
Something like: "Select phases to run (none selected = skip all)." The
skip-these framing avoids this problem (nothing selected = run all), which
is why it may be safer despite the double-negative.

### 6. CONDENSE Status Line Logic (Lines 1657-1662)

The planning question asks whether the CONDENSE status line generation needs
to change. **The logic does not change.** The CONDENSE line is downstream of
the skip determination -- it consumes the result of the skip logic, not the
raw user response. Whether the skip decision came from single-select,
multi-select, or freeform text, the CONDENSE line operates on the same
three boolean flags (run_review, run_tests, run_docs).

The existing format examples remain correct:
```
- No skips: `Verifying: code review, tests, documentation...`
- Skip docs: `Verifying: code review, tests...`
- Skip review + tests: `Verifying: documentation...`
- All skipped: skip the status line entirely, proceed to Wrap-up.
```

No changes needed to lines 1657-1662.

### 7. The "No Run All" Problem

Multi-select eliminates the "Run all" button. In the current single-select
design, "Run all" is option 1 (recommended) -- the one-click fast path.
With multi-select, the equivalent is "select all three phases." This is
three clicks instead of one.

This is a **real regression** in the happy-path interaction cost. The current
design optimizes the 80% case (run all) to one click. Multi-select makes
the 80% case three clicks.

**Possible mitigations**:
1. Default all options to checked (if the tool supports default states).
   The user simply confirms without unchecking anything. But this requires
   the tool to support default-checked options -- unknown until ai-modeling-minion
   reports.
2. Add a "Run all" meta-option alongside individual toggles. But this creates
   the contradiction problem identified in the previous devx-minion analysis:
   user could select "Run all" and uncheck "Tests," which is ambiguous.
3. Accept the three-click cost for run-all, since the majority of time is
   spent reading the gate, not clicking buttons.

ai-modeling-minion's answer on default-checked options determines which
mitigation is viable.

### 8. Fallback: If multiSelect: true Still Does Not Work

If ai-modeling-minion confirms that multiSelect: true is still non-functional
or unreliable:

- The current 4-option single-select design is already the correct solution.
- The task should be closed with a note that the blocked dependency is platform
  support for multiSelect.
- No changes needed to SKILL.md.
- The freeform flag escape hatch already covers multi-phase skip combinations.

This is not a failure -- it is the design working as intended. The previous
orchestration explicitly chose the current design as the best solution given
the platform constraint.

## Proposed Tasks

### Task 1: Update AskUserQuestion Definition (SKILL.md lines 1550-1570)

**What to do**: Replace the post-exec follow-up AskUserQuestion from
`multiSelect: false` with 4 single-choice options to `multiSelect: true` with
3 per-phase options (matching the framing chosen by ux-strategy-minion). Remove
the "Run all" meta-option. Update the response interpretation text to describe
multi-select behavior. Preserve freeform flag documentation.

**Deliverables**: Updated `skills/nefario/SKILL.md` lines 1550-1570.

**Dependencies**: ux-strategy-minion's framing decision (run-these vs.
skip-these) and ai-modeling-minion's confirmation that multiSelect: true works.

### Task 2: Update Skip Determination Logic (SKILL.md lines 1645-1662)

**What to do**: Replace the single-select label matching with multi-select
label matching. If run-these framing: phase runs if its label appears in
selection. If skip-these framing: phase skips if its label appears in selection.
Preserve existing conditional skips (no code files, no tests, empty checklist).
Preserve freeform flag interpretation. Document freeform-overrides-structured
precedence rule.

**Deliverables**: Updated `skills/nefario/SKILL.md` lines 1645-1662.

**Dependencies**: Task 1 (option labels must be finalized first).

### Task 3: Update AGENT.md Skip Description

**What to do**: Update the brief mention of skip options in `nefario/AGENT.md`
to reflect the multi-select interaction. The description should say "multi-select
of phases to run/skip" rather than listing individual single-select options.

**Deliverables**: Updated `nefario/AGENT.md` (line ~775).

**Dependencies**: Tasks 1-2 (SKILL.md must be finalized first).

### Task 4 (Conditional): Verify multiSelect: true in Live Session

**What to do**: After Tasks 1-3, the first nefario orchestration that reaches a
post-exec gate will be the live verification. If the multi-select renders
incorrectly or produces unparseable responses, revert to the single-select
design immediately. This is a runtime verification, not a code task.

**Deliverables**: Confirmation that multi-select works in practice.

**Dependencies**: Tasks 1-3 deployed.

## Risks and Concerns

### Risk 1: multiSelect: true Still Non-Functional (HIGH)

The entire task depends on this platform capability working. It was confirmed
non-functional three days ago. The meta-plan acknowledges this but proceeds
with planning. If ai-modeling-minion cannot definitively confirm it works,
execution should be blocked until a live test is performed.

**Mitigation**: ai-modeling-minion's consultation. If uncertain, add a Task 0
that tests multiSelect: true with a minimal AskUserQuestion before any SKILL.md
changes.

### Risk 2: Happy-Path Regression -- Three Clicks Instead of One (MEDIUM)

The current "Run all" is one click. Multi-select requires selecting all three
phases (or confirming pre-checked defaults, if supported). This is a measurable
UX regression for the 80% case.

**Mitigation**: Default-checked options (if platform supports them). Or accept
the trade-off: the 20% case (multi-skip combinations) improves significantly,
and the 80% case regresses slightly.

### Risk 3: Response Format Uncertainty (MEDIUM)

The exact format of a multiSelect: true response is not documented in this
codebase. If the format is unexpected (e.g., the LLM receives selected labels
in a format it does not anticipate), the skip determination could silently
miscategorize responses.

**Mitigation**: Write the skip determination logic in semantic terms ("if
the user selected X"), not parsing terms ("if response contains string X").
The LLM naturally handles both single-select and multi-select responses when
the logic is described semantically.

### Risk 4: Framing Inversion Confusion (LOW)

If the option framing changes from skip-these (current) to run-these (likely
with multi-select), users familiar with the current "Skip docs" labels will
see a different mental model. This is a one-time adjustment.

**Mitigation**: Clear question text explaining what selection means. The
ux-strategy-minion should handle this in option label design.

## Additional Agents Needed

None beyond those already assigned. The three-agent team (ux-strategy-minion
for framing, devx-minion for parsing/flags, ai-modeling-minion for platform
verification) covers the design space. margo and lucy will review in Phase 3.5
as usual.

**One note for synthesis**: The ai-modeling-minion response is a hard dependency
for all execution tasks. If ai-modeling-minion cannot confirm multiSelect: true
works, the synthesis should produce a conditional plan: "if works, do X; if not,
close the issue." Do not proceed to execution under uncertainty.
