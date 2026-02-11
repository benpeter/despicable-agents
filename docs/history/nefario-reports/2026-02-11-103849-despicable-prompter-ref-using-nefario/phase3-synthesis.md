# Synthesis: Add /despicable-prompter reference to using-nefario documentation

## Delegation Plan

**Team name**: despicable-prompter-ref-using-nefario
**Description**: Add a /despicable-prompter reference to docs/using-nefario.md so users with vague prompts discover the briefing coach tool.

### Task 1: Insert /despicable-prompter reference paragraph in docs/using-nefario.md

- **Agent**: user-docs-minion
- **Model**: sonnet
- **Mode**: default
- **Blocked by**: none
- **Approval gate**: no
- **Gate reason**: n/a -- single paragraph insertion, easily reversed, zero downstream dependents
- **Prompt**: |
    You are editing `docs/using-nefario.md` in the despicable-agents project at
    `/Users/ben/github/benpeter/2despicable/2/`.

    **What to do:**

    Insert a two-sentence paragraph immediately after the "Less helpful examples"
    code block (after line 56, the closing code fence) and before the
    "## What Happens: The Nine Phases" heading (currently line 58). Place a blank
    line before and after the new paragraph to maintain markdown spacing.

    Use this exact text:

    ```
    If you have a rough idea but are not sure how to structure it, run `/despicable-prompter` with your idea first. It transforms vague descriptions into structured `/nefario` briefings with outcomes, success criteria, and scope -- ready to paste and run.
    ```

    **Why:** Users reading the "less helpful examples" are at peak awareness that
    their prompt is vague. This is the optimal moment to point them to a tool that
    solves that problem. The reference turns a dead end into a learning opportunity.

    **Style constraints:**
    - Match the existing document tone: direct, imperative mood, no callout boxes.
    - Do NOT add a heading, tip box, or admonition wrapper.
    - Do NOT add more than these two sentences. No before/after examples, no
      extended explanation.
    - The phrase "ready to paste and run" mirrors the prompter's own output closing
      line. Keep it.
    - Use normalizing language ("if you have a rough idea") not critical language
      ("if your prompt is too vague").

    **What NOT to do:**
    - Do not edit any other section of the document.
    - Do not add a secondary reference in "Tips for Success" or anywhere else.
    - Do not modify the less-helpful examples themselves.
    - Do not create new files.

    **Deliverable:** Updated `docs/using-nefario.md` with the new paragraph at the
    specified location. No other files changed.

    **Verification:** After editing, read the file and confirm:
    1. The new paragraph appears between the code fence and the "## What Happens" heading.
    2. There is a blank line before and after the paragraph.
    3. No other lines in the file were changed.
- **Deliverables**: Updated `docs/using-nefario.md`
- **Success criteria**: The two-sentence paragraph appears after the "less helpful examples" code block, reads naturally in context, and no other content is modified.

### Cross-Cutting Coverage

This is a two-sentence documentation edit to a single markdown file. Cross-cutting evaluation:

- **Testing**: Not applicable. No executable output produced -- pure documentation text edit.
- **Security**: Not applicable. No attack surface, authentication, user input handling, or dependencies involved.
- **Usability -- Strategy**: Addressed by design. The specialist contribution already applied UX principles: symptom-adjacent help placement, normalizing tone, progressive disclosure. The two-sentence format was chosen specifically to minimize cognitive load.
- **Usability -- Design**: Not applicable. No user-facing interface produced.
- **Documentation**: This IS the documentation task. The edit is self-contained.
- **Observability**: Not applicable. No runtime components.

### Architecture Review Agents

- **Always**: security-minion, test-minion, ux-strategy-minion, software-docs-minion, lucy, margo
- **Assessment**: This is a two-sentence markdown insertion into a documentation file. There is no code, no architecture change, no API surface change, no security surface, no test surface, and no runtime component. The full architecture review battery (6 mandatory reviewers) would be disproportionate to the scope. Recommend the calling session apply proportional review per the nefario skill's scope-based review rules.

### Conflict Resolutions

None. Single specialist contributed. No conflicting recommendations.

### Risks and Mitigations

1. **Over-explaining the tool** (from specialist). Mitigated by capping the insertion at exactly two sentences with explicit instructions not to expand.
2. **Tool rename or removal** (from specialist). If `/despicable-prompter` is later renamed or removed, this two-sentence reference is trivial to update or delete. No mitigation needed beyond awareness.
3. **Tone mismatch** (from specialist). Mitigated by using "if you have a rough idea" (normalizing) rather than "if your prompt is too vague" (critical).

### Execution Order

```
Batch 1: Task 1 (single task, no dependencies)
```

No gates. No parallel work. No sequencing concerns.

### Verification Steps

1. Read `docs/using-nefario.md` after the edit and confirm the paragraph is correctly placed and formatted.
2. Confirm no other content in the file was modified (diff should show only the insertion).
