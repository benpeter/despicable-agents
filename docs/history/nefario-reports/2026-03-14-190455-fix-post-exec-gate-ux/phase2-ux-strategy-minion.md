# Domain Plan Contribution: ux-strategy-minion

## Recommendations

### 1. Option List Design (the core question)

There are 7 possible skip combinations from 3 flags. With a 2-4 option budget on single-select, we need to identify which combinations actually matter and collapse the rest into freeform.

**Recommended options (3, single-select):**

1. **"Run all"** (recommended) -- "Run code review, tests, and documentation."
2. **"Skip docs only"** -- "Run code review and tests. Skip documentation updates."
3. **"Skip all post-exec"** -- "Skip code review, tests, and documentation."

**Rationale for these three:**

- **"Run all"** is the happy path. It must be option 1, explicitly marked `(recommended)`. This is the entire point of the fix -- make the most common action the most visible and easiest to take. Satisficing behavior (Krug) means users will pick the first reasonable option; making "Run all" first means the default behavior requires zero thought.

- **"Skip docs only"** is the most common skip. Documentation updates are the lowest-risk phase to skip and the one users reach for when they want to move faster without sacrificing safety. This covers the "I trust the code but don't want to wait for docs" job.

- **"Skip all post-exec"** covers the power-user "just ship it" case. It maps directly to `--skip-post`. Users who want to skip tests or review but keep docs are rare enough to route through freeform.

**Why not include "Skip tests" or "Skip review" as standalone options:**

- Adding them would push to 4-5 options, exceeding the cognitive budget.
- "Skip review but keep tests" and "Skip tests but keep review" are uncommon -- users who skip one safety check usually skip both or neither.
- These combinations remain accessible via freeform flags (`--skip-tests`, `--skip-review`), which power users already know.
- Hick's Law: 3 options is the sweet spot for instant scanning in a CLI gate. 4 is acceptable (see P4 Gate). 5+ causes hesitation.

### 2. Question Text

The question text must make the default action obvious without requiring the user to read option descriptions.

**Proposed question:**
```
Post-execution phases for Task N: <task title>\n\nRun: $summary_full
```

Key changes from current:
- **Remove the instruction "confirm with none selected to run all"** -- that instruction is the anti-pattern we're eliminating.
- **Neutral framing** -- the question is now a simple label, not a leading question about skipping. The options speak for themselves.
- **No question mark** -- this is a choice point, not a question. The options define the action space. This matches the P4 Gate pattern ("Task N: <task title> -- DECISION") where the question field is informational and the options carry the decision.

### 3. Downstream Consumption Logic Update

The current logic (lines 1723-1736) checks for multi-select label matches ("Skip review", "Skip tests", "Skip docs") and an empty-selection default. With single-select, this needs a clean rewrite:

**New logic:**
```
Determine which post-execution phases to run based on the user's
single-select response and/or freeform text flags:

- "Run all": Run Phases 5, 6, and 8 (subject to existing conditional
  skips: docs-only files skip Phase 5, no tests skip Phase 6, empty
  checklist skips Phase 8).
- "Skip docs only": Skip Phase 8. Run Phases 5 and 6 (subject to
  existing conditional skips).
- "Skip all post-exec": Skip Phases 5, 6, and 8.
- Freeform text: If the user types freeform flags instead of selecting
  an option, interpret them as before:
  - --skip-docs = skip Phase 8
  - --skip-tests = skip Phase 6
  - --skip-review = skip Phase 5
  - --skip-post = skip Phases 5, 6, 8
  Flags can be combined. Freeform overrides structured selection on conflict.
```

This is simpler than the current logic because single-select produces exactly one label match instead of a set. The conditional skips (docs-only files, no tests, empty checklist) remain unchanged -- they're orthogonal to the user's selection.

### 4. Consistency with Existing Patterns

Every other AskUserQuestion in SKILL.md uses `multiSelect: false`. This change brings the post-exec gate into alignment. The recommended-first pattern matches P1 Team ("Approve team"), P3.5 Plan ("Approve"), P4 Gate ("Approve"), and PR gate ("Create PR"). Users who have internalized "first option = proceed" will instantly grok this.

### 5. Header

Keep `"Post-exec"` -- it's under 12 characters and already establishes the pattern.

## Proposed Tasks

### Task 1: Rewrite post-exec AskUserQuestion block
- **What**: Replace lines 1627-1648 in SKILL.md with the new single-select pattern (3 options, multiSelect: false, "Run all" as recommended default)
- **Deliverables**: Updated SKILL.md AskUserQuestion block
- **Dependencies**: None

### Task 2: Rewrite downstream consumption logic
- **What**: Replace lines 1723-1736 in SKILL.md with logic that matches on single-select labels ("Run all", "Skip docs only", "Skip all post-exec") instead of multi-select set membership
- **Deliverables**: Updated SKILL.md consumption logic block
- **Dependencies**: Task 1 (must know the exact option labels)

### Task 3: Verify freeform flag documentation
- **What**: Ensure the freeform flag reference (--skip-docs, --skip-tests, --skip-review, --skip-post) remains documented in the post-exec block so power users know the escape hatch exists
- **Deliverables**: Freeform flag reference preserved in SKILL.md
- **Dependencies**: Task 1

## Risks and Concerns

1. **Mid-frequency skip combinations become less discoverable.** "Skip tests only" and "Skip review only" move from explicit options to freeform-only. This is acceptable because (a) these are uncommon, (b) power users who want them already know the flags, and (c) the freeform override is documented in the same block. But monitor whether users start asking "how do I skip just tests?" -- if they do, consider adding a 4th option.

2. **Freeform override interaction.** The current spec says "freeform text overrides on conflict." With single-select, conflicts are less likely (user either picks an option OR types freeform), but the override rule should be preserved for the edge case where a user selects an option AND types text.

3. **`multiSelect: true` may have been non-functional anyway.** My prior analysis (2026-02-10) noted that `multiSelect: true` in Claude Code AskUserQuestion was non-functional. If that's still the case, the current gate may already be behaving as single-select in practice, meaning users may have been working around this bug by using freeform flags. The fix should still proceed -- it makes the designed behavior match the actual behavior and eliminates the warning.

4. **Label precision matters for downstream parsing.** The consumption logic will match on exact label strings. The labels must be stable and unambiguous. I recommend the labels use title case with no trailing punctuation: "Run all", "Skip docs only", "Skip all post-exec".

## Additional Agents Needed

None. This is a SKILL.md-only change with no UI components, no code, and no architecture impact. The ux-strategy analysis above covers the interaction design. The implementation is straightforward text editing.
