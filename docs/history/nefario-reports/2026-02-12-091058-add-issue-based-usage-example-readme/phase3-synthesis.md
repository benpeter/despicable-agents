## Delegation Plan

**Team name**: readme-issue-example
**Description**: Add a `/nefario #42` usage example to the README Examples section

### Scope

**In**: README.md Examples section (lines 17-30) -- add one example block inside
the existing code fence.

**Out**: Other README sections, docs/ files, skill definitions, using-nefario.md.

### Task 1: Add issue-driven example to README Examples section

- **Agent**: product-marketing-minion
- **Delegation type**: standard
- **Model**: sonnet
- **Mode**: default
- **Blocked by**: none
- **Approval gate**: no
- **Prompt**: |
    Edit `/Users/ben/github/benpeter/2despicable/3/README.md` to add one example
    block inside the existing code fence in the Examples section.

    **What to do:**

    Insert a new example block after line 29 (the last annotation of the existing
    `/nefario` example) and before line 30 (the closing ```). Add a blank line
    separator before the new block, matching the spacing pattern between existing
    examples.

    The new block to insert:

    ```
    # Got a GitHub issue? Point nefario at it -- issue in, PR out.
    /nefario #42
    # -> orchestrated plan, governance review, parallel execution, PR with "Resolves #42"
    ```

    Note: use `->` (ASCII arrow) not `→` (Unicode arrow) to match the existing
    annotation style in the file. Verify the existing examples use `→` or `->` and
    match whichever is used.

    **Pattern to follow:**

    The existing three examples each have:
    1. A comment line (question format, 7-13 words)
    2. A command line
    3. An annotation line starting with `# →` or `# ->`

    The new example follows this same three-line pattern.

    **Placement rationale:**

    After the existing `/nefario` example, before the closing code fence. This
    groups orchestrator invocations together and shows two ways to invoke nefario:
    free-text prompt vs. issue number.

    **What NOT to do:**
    - Do not change any existing examples
    - Do not add content outside the code fence
    - Do not modify any other section of the README
    - Do not touch any other files

    **Consistency check:**

    After making the edit, read lines 60-76 of
    `/Users/ben/github/benpeter/2despicable/3/docs/using-nefario.md` and confirm
    the new README example does not contradict the "GitHub Issue Integration"
    section there. The README example is a teaser; the docs have the full
    explanation. They should be consistent but the README should not duplicate
    the docs' detail.

- **Deliverables**: Updated README.md with the new example block
- **Success criteria**:
    - README Examples code fence contains 4 examples (was 3)
    - New example follows the comment + command + annotation pattern
    - New example is positioned after the existing `/nefario` example
    - Existing examples are unchanged
    - Content is consistent with docs/using-nefario.md

### Cross-Cutting Coverage

- **Testing**: Not applicable. This is a documentation-only change with no executable output.
- **Security**: Not applicable. No attack surface, auth, user input, or infrastructure changes.
- **Usability -- Strategy**: Addressed within the task. product-marketing-minion's contribution already applied JTBD framing (trigger + outcome), matched the conversational register of existing examples, and evaluated cognitive load. A separate ux-strategy review would not add value for a 3-line addition that follows an established pattern.
- **Usability -- Design**: Not applicable. No user-facing interface produced.
- **Documentation**: This IS the documentation task. The edit is self-contained within README.md. No architectural or API surface changes require software-docs-minion. The consistency check with using-nefario.md is embedded in the task prompt.
- **Observability**: Not applicable. No runtime components.

### Architecture Review Agents

- **Always**: security-minion, test-minion, ux-strategy-minion, software-docs-minion, lucy, margo
- **Conditional**: none triggered

Note: While Phase 3.5 review is mandatory per protocol, the scope of this change
is a 3-line addition to a code fence in README.md following an established pattern.
All six mandatory reviewers apply, but the review scope is narrow: does this
3-line example align with intent, maintain simplicity, and stay consistent with
existing documentation?

### Conflict Resolutions

None. Single specialist contributed; no conflicting recommendations.

### Risks and Mitigations

1. **Issue #42 specificity** (low): If repo has an actual issue #42 with unrelated
   content, a reader who tries the example literally could be confused. Mitigation:
   #42 is a standard placeholder; the docs section explains the `#<n>` syntax
   generically. No action needed.

2. **"Issue in, PR out" overpromise** (low): Implies full autonomy when the actual
   workflow includes human approval gates. Mitigation: The annotation line includes
   "governance review" which signals human-in-the-loop. Acceptable as-is.

3. **Comment length** (negligible): At 13 words, the new comment is at the upper
   bound of existing comment lengths (7-12 words). Falls within acceptable range
   and reads naturally.

### Execution Order

Single task, no dependencies, no batching needed.

```
Batch 1: Task 1 (product-marketing-minion)
```

No approval gates in the execution path.

### Verification Steps

1. Confirm README.md Examples code fence has exactly 4 example blocks
2. Confirm the new block follows the 3-line pattern (comment + command + annotation)
3. Confirm existing 3 examples are byte-identical to their pre-edit state
4. Confirm no changes to any file other than README.md
