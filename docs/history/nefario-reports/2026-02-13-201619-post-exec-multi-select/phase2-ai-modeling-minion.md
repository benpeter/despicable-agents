# Domain Plan Contribution: ai-modeling-minion

## Planning Question Answered

### (1) Expected behavior of `multiSelect: true`

When `multiSelect: true` is set on an AskUserQuestion question, the Claude Code TUI
renders checkboxes instead of radio buttons, allowing the user to toggle multiple
options before submitting. The response format differs from single-select:

- **Single-select** (`multiSelect: false`): The answer value is a single option label string.
  Example: `"How should I format?": "Summary"`
- **Multi-select** (`multiSelect: true`): The answer value is a **comma-space-separated string**
  of selected labels. Example: `"Which sections?": "Introduction, Conclusion"`

This is confirmed by Anthropic's official Agent SDK documentation at
https://platform.claude.com/docs/en/agent-sdk/user-input which states:

> "For multi-select questions, join multiple labels with `", "`."

The response is always a `Record<string, string>` (answers object), never an array.
Both single-select and multi-select use the same string value type -- multi-select
simply comma-joins the labels.

### (2) Response format for zero, one, and multiple selections

Based on the documented response format (`Record<string, string>` with comma-join):

| User selection | Response value |
|----------------|---------------|
| Zero options selected | Unclear from docs. Likely empty string `""` or the "Other" freeform text. There is no documented minimum selection requirement. |
| One option | `"Skip docs"` (single label, no comma) |
| Multiple options | `"Skip docs, Skip tests"` (comma-space-separated labels) |
| Freeform "Other" | The user's typed text verbatim |

**Critical parsing implication**: The response is a flat string, not a structured array.
Parsing requires splitting on `", "`. This means option labels must NOT contain
literal commas, or parsing becomes ambiguous. The current proposed labels ("Run all",
"Skip docs", "Skip tests", "Skip review") are all comma-free and safe.

### (3) Known constraints on `multiSelect: true`

**Bug status (critical)**:

The original bug report ([#12030](https://github.com/anthropics/claude-code/issues/12030))
from November 2025 reported that the Enter key acts like Tab instead of toggling
selections. A user-discovered **workaround exists: use the Space bar** to select
items (confirmed by commenter NathanSmeltzer).

The issue was closed "not planned" on January 21, 2026 due to 60 days of inactivity
(autoclose). This is ambiguous -- it could mean:

1. The bug was silently fixed in a subsequent release (the autoclose bot does not
   distinguish "fixed" from "stale")
2. The team considers Space bar the intended interaction model (checkboxes
   conventionally use Space, not Enter)
3. The bug persists and was deprioritized

Changelog entries from January-February 2026 show ongoing AskUserQuestion improvements
(auto-submit for single-select in v2.1.21, external editor support in v2.1.9,
IME checkbox support in v2.1.31) but no explicit mention of a multiSelect fix.

**Practical assessment**: Multi-select likely works via the Space bar. The original
report characterized Enter-not-working as "broken," but Space bar for checkbox
toggling is standard TUI convention (similar to `inquirer.js`, `blessed`, and most
terminal checkbox UIs). The February 2026 finding that "multiSelect doesn't work"
may have been based on the same Enter-key expectation.

**Other constraints**:
- 2-4 options per question (same as single-select)
- 1-4 questions per AskUserQuestion call
- `header` max 12 characters
- "Other" freeform option is always present (cannot be suppressed)
- No documented maximum selection count (implicitly all options can be selected)
- AskUserQuestion is NOT available in subagents (only main agent / orchestrator)

### (4) Default-checked options and "(Recommended)" labels

There is **no documented way to set default-checked options** in `multiSelect: true`.
All checkboxes start unchecked. The user must explicitly select each desired phase.

The "(Recommended)" label convention (appending to the first option's label) is a
prompt-level convention documented in the tool description: "Recommended options
should be listed first with '(Recommended)' appended." In multi-select context,
this could apply to multiple options (e.g., mark all three phases as recommended),
but the user still has to manually check each one.

This has a UX implication: if the common case is "run all phases," multi-select
requires 3 clicks (check, check, check, submit) versus single-select's 1 click
("Run all"). The design must account for this.

---

## Recommendations

### 1. Verify multiSelect works before committing to the approach

The single highest-risk item is whether `multiSelect: true` actually functions
in the current Claude Code version. The Space bar workaround is standard TUI
convention and likely works, but this was never verified in the nefario context.

**Recommendation**: Before any SKILL.md changes, run a 30-second manual verification:
create a minimal skill that presents a `multiSelect: true` AskUserQuestion and
confirm (a) checkboxes render, (b) Space toggles selection, (c) response contains
comma-separated labels, (d) zero-selection behavior is defined.

### 2. Invert the selection model: select what to SKIP, not what to RUN

If multiSelect is used, the question should ask "Which phases to **skip**?" with
all checkboxes unchecked by default. This means:

- **Zero selections** = run all (the common/safe case, one click to submit)
- **Check items** = skip those phases (explicit opt-out)

This preserves the "run all is one click" invariant from the previous design.
The alternative (select what to run, all checked by default) is impossible because
there are no default-checked options.

### 3. Response parsing specification

The devx-minion needs to parse responses in this format:

```
"<question text>"="<comma-space-separated labels>"
```

Parsing logic:
- Empty string or missing answer -> run all phases
- Split value on `", "` -> set of labels to skip
- Map labels to phases: "Code review" -> Phase 5, "Tests" -> Phase 6, "Docs" -> Phase 8
- Freeform "Other" text -> apply existing flag parsing (`--skip-docs`, etc.)

### 4. Option design for multi-select

Proposed options (3 options, `multiSelect: true`):

| # | label | description |
|---|-------|-------------|
| 1 | Code review | "Phase 5: automated code review" |
| 2 | Tests | "Phase 6: test execution" |
| 3 | Docs | "Phase 8: documentation updates" |

Labels are what-to-skip, ordered by ascending risk (docs = safest to skip first).
No "Run all" option needed -- that is the zero-selection default.
No "Skip all" option needed -- the user can check all three, or type `--skip-post`.

### 5. Fall back gracefully if multiSelect is broken

If multiSelect proves non-functional, the fallback is the current design (single-select
with 4 options + freeform flags). The SKILL.md change should be a clean swap of the
options block and response handling, with no structural changes to surrounding logic.

---

## Proposed Tasks

### Task 1: Manual verification of multiSelect behavior
- **What**: Create a throwaway skill with `multiSelect: true` AskUserQuestion. Test
  in current Claude Code version. Document: does Space toggle? Does Enter submit?
  What does the response look like for 0, 1, 2, 3 selections? What about "Other"?
- **Deliverables**: Written verification result (pass/fail + observed response format)
- **Dependencies**: None (blocker for all other tasks)
- **Agent**: devx-minion or manual by user

### Task 2: Update post-exec AskUserQuestion in SKILL.md
- **What**: Change the post-execution follow-up from `multiSelect: false` (4 options)
  to `multiSelect: true` (3 options, skip-what-you-select model). Update question
  text, option labels, option descriptions, and response handling logic.
- **Deliverables**: Modified SKILL.md (lines ~1550-1570)
- **Dependencies**: Task 1 (must pass)
- **Agent**: devx-minion

### Task 3: Update response parsing logic in SKILL.md
- **What**: Replace the single-select response handling (`If "Run all"` / `If "Skip docs"`)
  with multi-select parsing: split on `", "`, map labels to phases, merge with
  freeform flag parsing. Handle zero-selection as "run all."
- **Deliverables**: Modified SKILL.md response handling section
- **Dependencies**: Task 1 (confirmed response format), Task 2
- **Agent**: devx-minion

### Task 4: Update orchestration.md if affected
- **What**: Check `docs/orchestration.md` for references to the post-exec gate
  options and update if the option set or response format changed.
- **Deliverables**: Modified orchestration.md (if needed)
- **Dependencies**: Task 2

---

## Risks and Concerns

### Risk 1: multiSelect still broken (HIGH)
- **Likelihood**: Low-medium. The Space bar workaround is standard TUI convention
  and the original bug may have been a misunderstanding of keyboard interaction.
  But it was never verified in this codebase.
- **Impact**: Entire task scope changes. Falls back to current single-select design.
- **Mitigation**: Task 1 is a hard gate. Do not proceed without verification.

### Risk 2: Zero-selection ambiguity (MEDIUM)
- **Likelihood**: Medium. If the user submits with no checkboxes selected, the
  response format is undocumented. It could be an empty string, a missing key,
  or an error.
- **Impact**: Parsing logic must handle this case. If zero-selection fails or
  produces unexpected output, the "run all is one click" invariant breaks.
- **Mitigation**: Task 1 explicitly tests this case.

### Risk 3: Comma in labels breaks parsing (LOW)
- **Likelihood**: Very low with current label design (no commas).
- **Impact**: Would produce incorrect phase skip/run decisions.
- **Mitigation**: Enforce a no-comma constraint on option labels in the spec.

### Risk 4: UX regression -- more clicks for common case (MEDIUM)
- **Likelihood**: Certain if the design uses "select what to RUN."
- **Impact**: "Run all" goes from 1 click to 3+ clicks, violating the one-click
  default invariant established in the previous design.
- **Mitigation**: Use "select what to SKIP" model. Zero selections = run all = one click (submit).

### Risk 5: "Other" freeform always present (LOW)
- **Likelihood**: Certain. Cannot be suppressed.
- **Impact**: Minimal. The freeform channel is already supported and used for
  `--skip-*` flags. It remains a valid input path alongside structured multi-select.
- **Mitigation**: None needed. This is actually a feature, not a bug.

---

## Additional Agents Needed

None. The current team (ux-strategy-minion for UX design, devx-minion for
implementation/parsing) is sufficient. The ai-modeling-minion contribution here
is the definitive answer on tool behavior that unblocks both consultants.

The key finding that changes the previous understanding: **multiSelect likely works
via Space bar** (standard TUI convention). The February 10 finding that it "doesn't
work" was probably based on the Enter-key expectation from bug #12030, which
reported Enter acting like Tab. The workaround (Space bar) is the conventional
checkbox interaction model and may have been the intended behavior all along.

---

## Sources

- [Anthropic Agent SDK - Handle approvals and user input](https://platform.claude.com/docs/en/agent-sdk/user-input) -- official documentation confirming multi-select response format (comma-space-separated labels)
- [GitHub Issue #12030 - AskUserQuestion multiSelect: Enter key acts like Tab](https://github.com/anthropics/claude-code/issues/12030) -- the original bug report, closed "not planned" with Space bar workaround
- [Claude Code system prompts - AskUserQuestion tool description](https://github.com/Piebald-AI/claude-code-system-prompts/blob/main/system-prompts/tool-description-askuserquestion.md) -- extracted tool spec
- [Internal Claude Code tools implementation (gist)](https://gist.github.com/bgauryy/0cdb9aa337d01ae5bd0c803943aa36bd) -- tool schema details
- [Claude Code changelog / release notes](https://releasebot.io/updates/anthropic/claude-code) -- February 2026 release notes (no explicit multiSelect fix entry)
