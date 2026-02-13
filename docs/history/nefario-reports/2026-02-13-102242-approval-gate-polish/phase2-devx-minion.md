## Domain Plan Contribution: devx-minion

### Recommendations

#### (a) Expressing MD links inside code block templates with variable paths

The SKILL.md gate templates live inside fenced code blocks (` ``` `). Markdown links are **not rendered** inside code blocks -- they display as literal text. This is actually the correct behavior here: the templates are instructional examples that the calling session reads and interprets at runtime. The "links" are not clickable in the SKILL.md source; they are patterns the calling session emits as real markdown in its chat output.

**Recommendation**: Keep the link syntax as plain `[display](path)` inside the code block templates. The calling session resolves `$SCRATCH_DIR/{slug}/` to the actual path at runtime and emits the link as rendered markdown (outside a code block) in the chat output. No special escaping is needed. The template author reads the pattern; the end user sees a rendered link.

This matches how the existing `Details:` lines already work -- they show a path inside a code block template, and the calling session emits the resolved path in plain text. Converting from `Details: $SCRATCH_DIR/{slug}/file.md` to `Details: [$SCRATCH_DIR/{slug}/file.md]($SCRATCH_DIR/{slug}/file.md)` or (better) `[file.md]($SCRATCH_DIR/{slug}/file.md)` is a straightforward pattern for the calling session to follow.

For the slug-only display text requirement: use the filename as display text, with the full resolved path as the link target.

Pattern:
```
Details: [phase1-metaplan.md]($SCRATCH_DIR/{slug}/phase1-metaplan.md)
```

At runtime the calling session resolves this to:
```
Details: [phase1-metaplan.md](/tmp/nefario-scratch-a3F9xK/my-slug/phase1-metaplan.md)
```

This is clean, predictable, and follows the slug-only display convention: the display text is the filename (which implicitly carries the slug context), and the full path is in the link target where tools and copy-paste workflows can use it.

#### (b) Backtick card framing interaction with MD links

There is a rendering ambiguity risk. The card framing pattern uses backticks to highlight field labels: `` `DECISION:` ``, `` `RATIONALE:` ``, etc. If link display text is also backtick-wrapped (`` [`prompt`](path) ``), the nested backticks create visual noise and potential rendering issues depending on the markdown renderer.

**Recommendation**: Do NOT backtick-wrap link display text inside card-framed gates. Instead, use a different visual distinction mechanism for links:

1. **Field label in backticks** (existing pattern): `` `Details:` ``
2. **Link text in plain text**: `[phase1-metaplan.md](path)`
3. **Visual distinction via the label prefix**: The backtick-wrapped label (`` `Details:` ``, `` `Prompt:` ``, `` `Verdict:` ``) already creates the visual contrast. The link that follows is the value, not the label.

This produces:
```
`Details:` [phase1-metaplan.md]($SCRATCH_DIR/{slug}/phase1-metaplan.md)
```

The backtick wrapping applies to the **label** (structural element), not the **value** (content). This is consistent with how the existing mid-execution gate treats field labels vs. field values. The label-value separation IS the visual distinction.

If additional distinction is needed for inline links within running text (e.g., advisory sections where there is no label prefix), use parenthetical link pairs:
```
([prompt]($SCRATCH_DIR/{slug}/phase3.5-{reviewer}-prompt.md) | [verdict]($SCRATCH_DIR/{slug}/phase3.5-{reviewer}.md))
```

The parentheses + pipe delimiter create a compact, visually distinct link cluster without backtick nesting.

#### (c) Consistency rules across all five gates

**Rule 1 -- Link placement**: Every gate gets a footer line with a `Details:` link to its primary scratch file. This is the "deep dive" reference. Place it as the last content line before the bottom border.

| Gate | Primary scratch file |
|------|---------------------|
| Team Approval | `phase1-metaplan.md` |
| Reviewer Approval | `phase3-synthesis.md` |
| Execution Plan | `phase3-synthesis.md` |
| Mid-Execution | (already has inline file paths in DELIVERABLE) |
| PR | (report file, or synthesis for context) |

**Rule 2 -- Display text convention**: Filename only (e.g., `phase1-metaplan.md`), not the full path. The full path goes in the link target. This keeps the display compact while maintaining copy-paste utility in the link target.

Exception: the "Working dir:" line in the Execution Plan gate should show the slug directory as display text (e.g., `my-slug/`) with the full path as link target, since it references a directory, not a file.

**Rule 3 -- Label backtick wrapping**: All field labels inside card-framed gates get backtick wrapping. This is the existing pattern from the mid-execution gate. Apply to: `TEAM:`, `Specialists:`, `SELECTED:`, `ALSO AVAILABLE:`, `REVIEWERS:`, `Mandatory:`, `DISCRETIONARY:`, `NOT SELECTED:`, `EXECUTION PLAN:`, `REQUEST:`, `Tasks:`, `TASKS:`, `ADVISORIES:`, `RISKS:`, `REVIEW:`, `PR:`, `Branch:`, `Commits:`. Field labels that are section headers (like `TASKS:`, `ADVISORIES:`) get backtick wrapping on the label only.

**Rule 4 -- Border consistency**: All five gates use identical top/bottom borders:
```
`────────────────────────────────────────────────────`
```
This is 48 em-dash characters inside backticks. Same as the existing mid-execution gate.

**Rule 5 -- Header line format**: All gates use the pattern:
```
⚗️ `GATE_TYPE: <context>`
```
Where `GATE_TYPE` is backtick-wrapped (e.g., `` `TEAM:` ``, `` `REVIEWERS:` ``, `` `EXECUTION PLAN:` ``, `` `APPROVAL GATE:` ``, `` `PR:` ``).

**Rule 6 -- Advisory links**: In the ADVISORIES section of the Execution Plan gate, complex advisories (those with a `Details:` line) get prompt+verdict link pairs:
```
  `Details:` [phase3.5-{reviewer}.md]($SCRATCH_DIR/{slug}/phase3.5-{reviewer}.md)
  `Prompt:` [phase3.5-{reviewer}-prompt.md]($SCRATCH_DIR/{slug}/phase3.5-{reviewer}-prompt.md)
```
Simple advisories (CHANGE + WHY only) still omit links per existing rules.

**Rule 7 -- No links inside AskUserQuestion**: Links go in the printed gate brief only, never in the `question` or `description` fields of AskUserQuestion. Those fields are constrained UI elements.

### Proposed Tasks

**Task 1: Apply card framing + links to all 5 gates**
- What: Edit the 5 gate template code blocks in SKILL.md, applying the backtick card framing pattern (borders, backtick-wrapped labels) and adding MD links to scratch files
- Deliverables: Updated SKILL.md with all 5 gates in consistent card-framed format with links
- Dependencies: None (single-file edit)
- Specific sub-edits:
  1. Team Approval Gate (line ~441-454): Add borders, backtick-wrap labels (`TEAM:`, `Specialists:`, `SELECTED:`, `ALSO AVAILABLE:`, `Details:`), convert Details path to MD link with filename display text
  2. Reviewer Approval Gate (line ~782-794): Same treatment, labels (`REVIEWERS:`, `Mandatory:`, `DISCRETIONARY:`, `NOT SELECTED:`, `Details:`), convert Details path to link
  3. Execution Plan gate (lines ~1038-1114): Add borders around full presentation, backtick-wrap all section labels (`EXECUTION PLAN:`, `REQUEST:`, `Tasks:`, `Working dir:`, `TASKS:`, `ADVISORIES:`, `RISKS:`, `CONFLICTS RESOLVED:`, `REVIEW:`, `Details:`), convert advisory Details/Prompt to links, convert footer Details to link, convert Working dir path to slug-display link
  4. Mid-execution gate (line ~1250-1268): Already has card framing. Add/update any links not yet present.
  5. PR Gate (line ~1676-1683): Add borders, backtick-wrap labels (`PR:`, `Branch:`, `Commits:`), add Details link if appropriate
  6. Advisory section (line ~1083-1090): Convert the existing `Details:` and `Prompt:` paths to MD links with filename display text

**Task 2: Update Visual Hierarchy table**
- What: If the card framing description in the Visual Hierarchy table (line ~209) needs refinement to mention links, update it. Verify the Decision weight description still accurately describes the updated pattern.
- Deliverables: Accurate Visual Hierarchy table reflecting the final pattern
- Dependencies: Task 1 (need to see final pattern)
- Note: This may be a no-op if the current description ("`` `─── ···` `` border + `` `LABEL:` `` highlighted fields + structured content") already covers it. Links are "structured content."

### Risks and Concerns

1. **Rendering variance across terminals**: The backtick-wrapped borders and labels render differently depending on the markdown renderer. Claude Code's chat output renders markdown, but terminal width and font support for em-dash characters vary. The existing mid-execution gate already has this treatment, so this is an accepted risk.

2. **Template readability for maintainers**: Adding MD link syntax inside code block templates increases the visual complexity of the SKILL.md source. A line like `` `Details:` [phase1-metaplan.md]($SCRATCH_DIR/{slug}/phase1-metaplan.md) `` is harder to read than `Details: $SCRATCH_DIR/{slug}/phase1-metaplan.md`. Mitigation: the link syntax is a well-known pattern, and the consistency rules make it predictable.

3. **Code block boundary ambiguity**: The Execution Plan gate currently uses multiple separate code blocks for different sections (orientation, task list, advisories, risks, review summary, details). If we add borders, should the borders wrap all sections together (one card) or wrap each section? Recommendation: one card with borders around the entire gate output. The separate code blocks in SKILL.md are an authoring convenience; the calling session emits one continuous block. The borders should wrap the outermost level. However, the Execution Plan gate is notably longer than the others (25-40 lines vs 6-12 lines), so the single-card approach may need a different treatment -- potentially borders only around the orientation block, with sections flowing below. Defer to the executing agent's judgment during implementation, guided by the 25-40 line budget.

4. **Over-linking the Execution Plan gate**: The Execution Plan gate already has the most content (task list, advisories, risks, review, details). Adding links to every advisory's prompt and verdict files could push it past the 40-line budget. Mitigation: links only appear on complex advisories (those that already have a Details line). Simple advisories (the common case) remain link-free.

### Additional Agents Needed

None. The current team of devx-minion and ux-strategy-minion is sufficient. This is a single-file template formatting task with no code, infrastructure, security, or documentation surface beyond SKILL.md itself. Lucy and margo will review in Phase 3.5 as mandatory reviewers.
