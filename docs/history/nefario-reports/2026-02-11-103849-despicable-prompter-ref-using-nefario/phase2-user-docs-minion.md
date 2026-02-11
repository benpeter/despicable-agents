# Domain Plan Contribution: user-docs-minion

## Recommendations

### Placement: After the "less helpful examples" code block (between lines 56 and 58)

The reference should go **immediately after the closing code fence of the "less helpful" examples** (line 56) and **before the "What Happens: The Nine Phases" heading** (line 58). This is the optimal position for three reasons:

1. **Symptom-adjacent help.** The user just read three examples of what NOT to do. They are at peak awareness of the problem ("my prompt is vague"). This is the exact moment to offer a tool that solves that problem. Placing the reference here follows the error-prevention-and-recovery pattern: show the problem, then immediately show the recovery path.

2. **Does not interrupt the "How to Invoke" flow.** The good/less-helpful examples are a natural pause point in the section. The next heading ("What Happens") starts a new conceptual block about the orchestration process. Inserting a short reference in this gap feels like a closing thought on "how to write good prompts," not an interruption of the phase walkthrough.

3. **Does not break the "Tips for Success" section.** An alternative placement would be inside "Tips for Success" (lines 86-96), which already has a tip about being specific. However, that section is six screen-lengths away from the vague examples. Users who need this help most (those writing vague prompts) will not scroll that far before invoking `/nefario`. The reference must be at the point of need.

### Format: A single short paragraph, not a callout or tip box

A callout/admonition (like a `> **Tip:**` block) would work visually but risks feeling like a sidebar the user skips. A standalone paragraph integrated into the prose flow is better because:

- It matches the existing document's style, which uses no callouts or admonition blocks anywhere.
- It keeps the tone conversational and direct rather than "system notification."
- It is brief enough (2-3 sentences) that a callout wrapper would add more chrome than content.

### Wording: Bridge from problem to tool in two sentences

The reference should:

1. Acknowledge the user's situation (they have a rough idea but not a structured prompt).
2. Name the tool and what it does in one sentence.
3. Show what the workflow looks like (paste idea in, get structured briefing out).

**Proposed text:**

```markdown
If you have a rough idea but are not sure how to structure it, run `/despicable-prompter` with your idea first. It transforms vague descriptions into structured `/nefario` briefings with outcomes, success criteria, and scope -- ready to paste and run.
```

This wording:
- Uses imperative mood ("run") consistent with the rest of the document.
- Explains the tool's function in one sentence without overselling.
- Makes the workflow concrete: input a rough idea, get a structured briefing back.
- Does not repeat the vague examples or belabor the point.
- Uses "ready to paste and run" which mirrors the prompter's own closing line ("paste into /nefario as-is").

### Secondary placement: A brief echo in "Tips for Success"

To reinforce the reference for users who skip directly to the tips section, add one sentence to the existing "Be specific" tip (line 88). This is not a duplicate -- it is a cross-reference in context. Proposed addition appended to that tip's paragraph:

```markdown
If you are starting from a rough idea, `/despicable-prompter` can help you structure it before invoking nefario.
```

This is optional. The primary placement after the vague examples is the critical one. If the scope is strictly minimal (one insertion only), skip this secondary echo.

## Proposed Tasks

### Task 1: Insert /despicable-prompter reference after "less helpful examples"

**What to do:** Add a two-sentence paragraph between line 56 (closing code fence of less helpful examples) and line 58 ("## What Happens: The Nine Phases") in `docs/using-nefario.md`. Use the wording proposed above. Ensure a blank line before and after the new paragraph to maintain markdown spacing.

**Deliverable:** Updated `docs/using-nefario.md` with the new paragraph at the specified location.

**Dependencies:** None. This is a self-contained text insertion.

### Task 2 (optional): Add cross-reference in "Tips for Success"

**What to do:** Append one sentence to the "Be specific in your task description" tip (line 88) referencing `/despicable-prompter` as a tool for structuring rough ideas.

**Deliverable:** Updated tip paragraph in the same file.

**Dependencies:** Task 1 should be done first so the primary reference exists. This task is additive and optional.

### Task 3: Verify no broken document flow

**What to do:** Read the updated file end-to-end and confirm the new text does not disrupt the reading flow between the "How to Invoke" section and the "What Happens" section. Confirm the reference reads as a natural closing thought on prompt quality, not an advertisement.

**Deliverable:** Confirmation that the document reads naturally with the insertion.

**Dependencies:** Task 1 complete.

## Risks and Concerns

1. **Over-explaining the tool.** The biggest risk is writing too much. The current document is tight and well-paced. More than 2-3 sentences about `/despicable-prompter` would break the rhythm and make the reference feel like a sales pitch. The proposed text is intentionally minimal.

2. **Creating a dependency on prompter documentation.** The reference names `/despicable-prompter` but does not link to separate documentation for it. If users want to learn more, they currently can only invoke the skill directly (which is fine -- it is self-documenting via its examples). However, if `/despicable-prompter` is later removed or renamed, this reference becomes a dead end. **Mitigation:** The reference is small enough to update or remove trivially.

3. **Tone mismatch.** The document currently presents vague examples as "less helpful" without judgment. The new reference must not imply the user is doing something wrong. Phrasing it as "if you have a rough idea" (normalizing the situation) rather than "if your prompt is too vague" (criticizing the user) avoids this.

4. **Scope creep into a tutorial.** There is a temptation to add a before/after example showing a vague prompt transformed by `/despicable-prompter`. This would be valuable but exceeds the stated scope ("one sentence explaining what it does"). If a before/after is desired later, it belongs in a separate how-to guide or in the prompter's own documentation, not inline here.

## Additional Agents Needed

None. This is a small, self-contained documentation edit. The text insertion requires no code changes, no design work, and no architectural review. A single execution agent (user-docs-minion or any agent writing markdown) can handle it. If code review is triggered by the project's standard process, that is sufficient governance for a two-sentence addition.
