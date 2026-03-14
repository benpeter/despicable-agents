Fix post-exec gate UX: replace inverted skip-only multiSelect with explicit 'Run all' single-select

**Outcome**: After approving a task gate, the user sees an explicit "Run all phases" option as the default choice, eliminating the current anti-pattern where the happy path (run everything) requires selecting nothing and triggering a Claude Code "you haven't answered all questions" warning. This makes the most common action visible and warning-free.

**Success criteria**:
- "Run all phases" is the first, explicitly listed option marked as recommended
- Confirming without changing selection runs all phases (no empty-selection semantics)
- No Claude Code "unanswered question" warning on the default path
- Freeform flag overrides (--skip-docs, --skip-tests, --skip-review, --skip-post) still work
- Existing skip combinations remain available as named options

**Scope**:
- In: SKILL.md post-exec AskUserQuestion block (lines ~1627-1636), option definitions, question text
- Out: Approval gate structure (Phase 4 gates themselves), other AskUserQuestion instances, nefario AGENT.md

**Constraints**:
- Must use AskUserQuestion with multiSelect: false (single-select) to avoid empty-selection UX issues
- Preserve freeform text override behavior for flag-style skips
