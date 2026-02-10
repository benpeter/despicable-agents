# Domain Plan Contribution: devx-minion

## Recommendations

### 1. Approach Recommendation: Option (B) with Freeform Fallback -- Not (A), Not (C)

The planning question presents three design paths. Here is the evaluation through the lens of CLI design principles, developer ergonomics, and the specific constraints of AskUserQuestion.

**Reject (A): Multi-select with pre-checked phases (opt-out model).**

This is the textbook "right" answer for a traditional checkbox UI, but it fails here for three reasons:

1. **AskUserQuestion has no "pre-checked" semantics.** Every use of AskUserQuestion in the codebase uses `multiSelect: false` with distinct labeled options. There is no evidence the tool supports default-selected checkboxes that the user unchecks. Even if the tool technically supports `multiSelect: true`, the interaction model in Claude Code is a selection list, not a checkbox form. "Uncheck to skip" requires the user to understand what is checked by default and make a deselection -- a fundamentally different cognitive operation from "select to skip."

2. **Opt-out models are hostile at high frequency.** The follow-up prompt fires at every approval gate (3-5 times per session). An opt-out model forces the user to mentally process "these three things are selected, do I want to un-select any?" every single time. For the 80% case where the answer is "no, run all," the user still has to confirm the pre-checked state. This adds cognitive load to the happy path.

3. **Inverted mental model.** The goal is to make skipping a conscious act. An opt-out model inverts this -- the conscious act becomes "choosing to keep" rather than "choosing to skip." This is the opposite of the design intent.

**Reject (C): Freeform text flags only, removing the AskUserQuestion follow-up.**

This throws away the structured prompt infrastructure that was deliberately added to the skill in a previous nefario orchestration. The AskUserQuestion follow-up exists because freeform text parsing was identified as a friction point -- users had to recall exact flag syntax. Reverting to pure freeform would be a step backward.

However, freeform text input MUST remain as a parallel channel. Users who type `approve --skip-docs` before the follow-up prompt appears (or in response to it) should have their intent honored. The LLM naturally handles this because it reads all user input, whether from structured selection or freeform text.

**Recommend (B): Multi-select skip options with "Run all" default.**

This is the right fit for three reasons:

1. **Happy path is one click.** "Run all" is the first option and recommended. Users who want the default select it and move on. Zero additional cognitive load compared to today's binary follow-up.

2. **Skipping is an explicit additive action.** The user must positively select "Skip code review" -- there is nothing to deselect or uncheck. This aligns with the design intent: skipping is a conscious decision.

3. **`multiSelect: true` enables combinations naturally.** A user who wants to skip docs and tests selects both "Skip docs" and "Skip tests." The multi-select model handles this without enumerating all seven combinations.

**One critical refinement to (B):** Do NOT include "Run all" and individual skip options simultaneously in a `multiSelect: true` prompt. If multiSelect is true, the user could select both "Run all" and "Skip docs" -- a logical contradiction. Instead:

- Use `multiSelect: true` with ONLY skip options (no "Run all")
- Add a description to the prompt making clear that selecting nothing = run all
- OR use `multiSelect: false` with "Run all" as the first option, followed by the three individual skips, followed by "Skip all post-execution"

The second approach (`multiSelect: false` with five single-select options) is simpler and avoids the contradiction problem entirely. But it loses the ability to combine skips in one selection. Given that combining two skips (e.g., skip docs + tests but keep review) is a minority use case, and that the LLM will still accept freeform text for combinations, `multiSelect: false` with five options is the pragmatic choice.

### 2. Recommended AskUserQuestion Follow-Up Structure

Replace the current 2-option follow-up (lines 493-501) with:

```
- **"Approve"**: Present a FOLLOW-UP AskUserQuestion for post-execution options:
  - `header`: "Post-exec"
  - `question`: "Post-execution phases for this task?"
  - `options` (5, `multiSelect: false`):
    1. label: "Run all", description: "Code review + tests + docs after execution completes." (recommended)
    2. label: "Skip docs", description: "Skip documentation updates (Phase 8)."
    3. label: "Skip tests", description: "Skip test execution (Phase 6)."
    4. label: "Skip review", description: "Skip code review (Phase 5)."
    5. label: "Skip all post-execution", description: "Skip Phases 5, 6, 8. Commit and continue."
  The user may also type a freeform response with flags (e.g., "skip docs and tests"
  or "--skip-docs --skip-review"). Interpret natural language skip intent as equivalent
  to the corresponding structured options.
  If "Run all": run post-execution phases (5-8) after execution completes.
  If any skip option: skip the named phase(s). Phase 7 (deployment) is opt-in and unaffected.
```

Key design decisions in this structure:

- **Risk-gradient ordering.** Options are ordered from safest to most dangerous: docs (lowest risk to skip) -> tests -> review -> all. This follows the prior ux-strategy-minion recommendation. Users scanning top-to-bottom hit the safe options first. The serial position effect means "Skip docs" gets the most attention among skip options, creating a natural "just skip docs" path.

- **Five options is the limit.** Five options in a single-select AskUserQuestion is manageable (Hick's Law: decision time increases logarithmically with options). Six or more would push past the threshold where users switch to satisficing (grabbing the first option without reading). Five works because the options form a clear gradient: one positive default, three granular skips, one nuclear option.

- **`multiSelect: false` with freeform fallback for combinations.** The structured prompt handles the four most common paths (run all, skip one specific phase, skip everything). The rare two-phase-skip combination is handled by freeform text input, which the LLM already supports. This avoids the `multiSelect: true` contradiction problem while covering 95%+ of use cases through the structured UI.

- **Phase numbers in descriptions.** Including "(Phase 8)", "(Phase 6)", "(Phase 5)" in descriptions creates a connection between the human-readable label and the technical phase system. Users who have read the SKILL.md or nefario reports will recognize these numbers. Users who have not will ignore them harmlessly. This is progressive disclosure at the description level.

- **"Skip all post-execution" rather than "Skip post"** as the label. The full phrase makes the blast radius obvious. In the structured prompt context, terseness is less important than clarity because the user is reading labels, not typing commands.

### 3. Flag Naming: Reuse Prior Decision

The prior devx-minion contribution established the flag naming convention. Reuse it without changes:

| Flag | Skips | Phase |
|------|-------|-------|
| `--skip-review` | Code review | Phase 5 |
| `--skip-tests` | Test execution | Phase 6 |
| `--skip-docs` | Documentation updates | Phase 8 |
| `--skip-post` | All post-execution | Phases 5, 6, 8 |

These names map to the AskUserQuestion option labels: "Skip review" -> `--skip-review`, "Skip tests" -> `--skip-tests`, "Skip docs" -> `--skip-docs`, "Skip all post-execution" -> `--skip-post`.

### 4. Retain `--skip-post` as a First-Class Shorthand

Yes, retain `--skip-post`. The prior contribution's reasoning still holds:

- **Backward compatibility.** The LLM and users have trained on `--skip-post`. Removing it forces re-learning with no benefit.
- **Legitimate use case.** Sometimes you want to skip everything. Requiring three flags for this is an ergonomic regression.
- **Represented in the structured UI.** Unlike the prior attempt where `--skip-post` was a hidden freeform escape hatch, it is now an explicit option ("Skip all post-execution") in the AskUserQuestion follow-up. This makes it discoverable AND conscious -- the user sees it as the last, most extreme option.
- **Not deprecated.** Do NOT frame it as deprecated. It is a first-class option that happens to be equivalent to all three granular flags combined. Document it as shorthand, not legacy.

The prior ux-strategy-minion contribution recommended NOT showing `--skip-post` in the prompt to force granular decisions. That recommendation was correct for the old freeform text model where `--skip-post` was the path of least resistance. In the new structured prompt model, the path of least resistance is "Run all" (the first, recommended option). "Skip all post-execution" is the LAST option -- users must scroll past three granular alternatives to reach it. The risk-gradient ordering handles the nudge; hiding `--skip-post` is no longer necessary.

### 5. Post-Execution Phase Gating Logic

Replace the single boolean check at line 556 with per-phase conditionals. The logic is identical to the prior contribution but now references both structured selection and freeform input:

```
Run post-execution phases based on the user's follow-up response:
- Phase 5 (Code Review): Skip if user selected "Skip review" or "Skip all
  post-execution", or typed --skip-review or --skip-post. Also skip if Phase 4
  produced no code files (existing conditional).
- Phase 6 (Test Execution): Skip if user selected "Skip tests" or "Skip all
  post-execution", or typed --skip-tests or --skip-post. Also skip if no tests
  exist (existing conditional).
- Phase 8 (Documentation): Skip if user selected "Skip docs" or "Skip all
  post-execution", or typed --skip-docs or --skip-post. Also skip if checklist
  has no items (existing conditional).

If all three phases are skipped (by any combination of user selection and existing
conditionals), skip directly to Wrap-up.
Otherwise, run non-skipped phases in order (5, 6, 8).
```

The dual-source gating (structured selection OR freeform text) is important to document explicitly. The LLM interpreting the SKILL.md needs to understand that skip intent can come from either channel and should be treated identically.

### 6. Verification Summary: Granular Reporting

Replace the three-state verification summary with a format that names what ran and what was skipped:

```
- All ran, all passed: "Verification: all checks passed."
- All ran, with fixes: "Verification: N code review findings auto-fixed, all tests pass, docs updated (M files)."
- Partial skip: "Verification: code review passed (0 findings), tests passed. Skipped: docs."
- Another partial: "Verification: docs updated (2 files). Skipped: code review, tests."
- All skipped: "Verification: skipped (--skip-post)."
```

Pattern: report what ran first (with outcomes), then append "Skipped: <phases>" for anything that was skipped by user choice. Do NOT include phases that were skipped by existing conditionals (e.g., "no code files produced") in the "Skipped:" suffix -- those are already noted by the phase itself. The "Skipped:" suffix is specifically for user-requested skips, creating the accountability trail the ux-strategy-minion recommended.

### 7. "Verifying:" Status Line

The dark kitchen entry line should reflect what will actually run:

```
- No skips: "Verifying: code review, tests, documentation..."
- Skip docs: "Verifying: code review, tests..."
- Skip review + tests: "Verifying: documentation..."
- All skipped: (no line printed -- skip directly to Wrap-up)
```

This was already recommended in the prior contribution and remains correct.

### 8. Satellite File Updates

The following files reference `--skip-post` and need updating:

**`nefario/AGENT.overrides.md` (line 53):**
```
Users can control post-execution phases at approval gates: "Run all" (default),
"Skip docs", "Skip tests", "Skip review", or "Skip all post-execution".
Freeform flags --skip-review, --skip-tests, --skip-docs, --skip-post also accepted.
```

**`docs/orchestration.md` (line 104):**
```
At each approval gate, after selecting "Approve", a follow-up prompt offers
granular control over post-execution phases: "Run all" (default), "Skip docs",
"Skip tests", "Skip review", or "Skip all post-execution" (Phases 5, 6, 8).
Phase 7 (deployment) is opt-in.
```

**`docs/orchestration.md` (line 374):**
```
- **Approve** -- Gate clears. A follow-up prompt offers post-execution options:
  "Run all" (default), "Skip docs", "Skip tests", "Skip review", or
  "Skip all post-execution". Downstream tasks are unblocked.
```

**`nefario/AGENT.md`:** Update the equivalent line (derived from AGENT.overrides.md). If the build process regenerates AGENT.md from overrides, updating overrides is sufficient. If AGENT.md is edited directly, mirror the overrides text.


## Proposed Tasks

### Task 1: Replace AskUserQuestion Follow-Up in SKILL.md

**What to do**: Replace lines 493-501 (the current 2-option "Post-exec" AskUserQuestion follow-up) with the 5-option structure described in Recommendation 2. Include the freeform text interpretation instruction and the response handling logic for each option.

**Deliverables**: Updated `skills/nefario/SKILL.md` lines 493-501.
**Dependencies**: None (this is the primary design artifact).

### Task 2: Update Post-Execution Phase Gating in SKILL.md

**What to do**: Replace line 556 (`If the user said approve --skip-post, skip to Wrap-up.`) with per-phase conditional gating logic as described in Recommendation 5. Update the "Verifying:" status line at line 554 to reflect only active phases (Recommendation 7).

**Deliverables**: Updated `skills/nefario/SKILL.md` lines 554-556.
**Dependencies**: Task 1 (gating logic must match the option labels/flags defined in the follow-up).

### Task 3: Update Verification Summary in SKILL.md

**What to do**: Replace the verification summary format at line 887 (`"Verification: skipped (--skip-post)."`) with the granular format described in Recommendation 6, supporting partial-skip and all-skipped states.

**Deliverables**: Updated `skills/nefario/SKILL.md` line 887.
**Dependencies**: Task 1 (flag names and semantics must be finalized).

### Task 4: Update Satellite Files

**What to do**: Update `--skip-post` references in three satellite files with the text described in Recommendation 8:
- `nefario/AGENT.overrides.md` line 53
- `docs/orchestration.md` lines 104 and 374
- `nefario/AGENT.md` (corresponding line, or rebuild via /despicable-lab)

**Deliverables**: Updated satellite files, all consistent with SKILL.md.
**Dependencies**: Tasks 1-3 (SKILL.md must be finalized before satellite files are updated).


## Risks and Concerns

### Risk 1: Five Options May Trigger Satisficing (LOW)

Five options in a single-select AskUserQuestion prompt is at the practical limit. Users under time pressure may stop reading at option 2 or 3 and just pick "Run all" without considering whether a partial skip would be appropriate. This is actually an acceptable outcome -- "Run all" is the safe default. The risk would only materialize if users who SHOULD be skipping something (e.g., docs on a docs-only change) fail to discover the option.

**Mitigation**: The risk-gradient ordering places "Skip docs" (the most commonly useful skip) as option 2, immediately after the default. Users who scan even briefly will see it. The phase-specific existing conditionals (e.g., "skip code review if no code produced") already handle the most important auto-skip cases.

### Risk 2: AskUserQuestion multiSelect Behavior Unknown (MEDIUM)

The recommendation uses `multiSelect: false` precisely because the exact behavior of `multiSelect: true` in Claude Code's AskUserQuestion is not fully documented in this codebase. All existing uses are `multiSelect: false`. If the synthesis opts for `multiSelect: true` instead (to allow combination selection in the structured UI), the implementation should first verify that the tool supports it correctly.

**Mitigation**: The `multiSelect: false` design works well without multi-select support. Combinations are handled by freeform text input. If `multiSelect: true` is later confirmed to work reliably, the follow-up could be upgraded to a multi-select with only skip options (no "Run all") where "select nothing and confirm = run all." This would be a future improvement, not a blocker.

### Risk 3: Dual-Channel Input (Structured + Freeform) Creates Ambiguity (LOW)

If a user selects "Run all" from the structured prompt but also types "--skip-docs" in freeform, the LLM must resolve the contradiction. This is an edge case but technically possible.

**Mitigation**: Document a precedence rule in SKILL.md: "If the user provides both structured selection and freeform text, interpret freeform text as overriding the structured selection." This matches the general principle that explicit text input (which requires more effort) signals stronger intent than a quick button click.

### Risk 4: Inconsistency Between Four Files (MEDIUM)

Four files must be updated consistently. This is the same risk identified in the prior contribution.

**Mitigation**: The task dependency chain (SKILL.md first, satellite files last) ensures consistency flows from the source of truth. Phase 3.5 architecture review (lucy) will catch any mismatches.


## Additional Agents Needed

None. The devx-minion + ux-strategy-minion combination covers the design space. The ux-strategy-minion's prior contribution on risk-gradient ordering, no confirmation dialogs, and accountability-without-friction principles are fully compatible with the structured prompt recommendation above. Phase 3.5 reviewers (lucy, margo, security-minion, software-docs-minion) will provide the necessary governance review during execution.
