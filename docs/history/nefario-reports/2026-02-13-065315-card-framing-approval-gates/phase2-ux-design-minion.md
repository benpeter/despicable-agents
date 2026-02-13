# Domain Plan Contribution: ux-design-minion

## Recommendations

### (a) Border lines: single continuous box-drawing span vs. segments

Use a **single backtick span containing a continuous run of box-drawing dashes (U+2500)** for both top and bottom borders. Do not break into segments.

**Rationale**: A single highlighted span reads as one visual edge, creating clear card framing. Segmented spans would introduce gaps in the highlight color, breaking the "card border" illusion and introducing visual noise. The highlight background color is the entire point -- it needs to be continuous to read as a line/edge.

**Recommended width**: 52 characters of box-drawing dash. This is wide enough to span most gate content but narrow enough to avoid wrapping in typical 80-column or 100-column terminal widths. The top border should be identical to the bottom border for visual symmetry. Do NOT attempt to exactly match content width -- fixed-width borders are simpler and more predictable.

Example:
```
`────────────────────────────────────────────────────`
```

**Why 52?** The longest typical gate header is something like `APPROVAL GATE: Implement user authentication flow` which runs ~50 characters with the emoji prefix. Matching approximate content width makes the card feel intentional rather than arbitrary.

### (b) Field labels: label only vs. label plus value

Wrap **only the label** (e.g., `DECISION:`, `DELIVERABLE:`, `RATIONALE:`, `IMPACT:`, `Confidence:`), not the label plus its value.

**Rationale -- three reasons:**

1. **Scanability**: Highlighted labels create a left-column visual anchor. The user's eye can scan down the left edge to find the field they want, then read rightward into unhighlighted content. If the entire line is highlighted, there's no contrast between structure and content -- everything is equally emphasized, which means nothing is emphasized.

2. **Information hierarchy**: Labels are metadata (structure); values are content (substance). Different visual treatment maps to different cognitive roles. This is the same principle behind bold labels in forms -- the label tells you what to read, the value is what you read.

3. **Line wrapping**: Values can be long (especially DECISION and IMPACT lines). If the entire line is backtick-wrapped and it wraps in the terminal, the code span highlight behavior becomes unpredictable -- some terminals extend the highlight background to the next line, others don't. Wrapping only the short label avoids this entirely.

**One exception**: The header line. `APPROVAL GATE: <Task title>` should have the full line wrapped because it functions as a title, not a label-value pair. The emoji prefix should be OUTSIDE the backtick span (see section c).

### (c) Emoji inside backtick code spans in terminals

**Do NOT wrap the emoji inside the backtick span.** Place the emoji outside, before the span.

**Rationale**: Terminal emoji rendering inside monospace/code contexts is a known source of visual glitches:

- **Width calculation mismatch**: Emojis are typically rendered as double-width characters, but monospace fonts and terminal emulators disagree on whether this means 1 or 2 character cells. Inside a code span (which signals "monospace"), this disagreement is more pronounced and can cause misalignment.
- **Font fallback**: Code spans may trigger a monospace font stack. If the monospace font lacks the emoji glyph, fallback behavior varies -- some terminals render it fine, others show a replacement character or a broken-width glyph.
- **Claude Code specifically**: Claude Code renders in a terminal context where inline code gets a distinct background highlight. The emoji glyph plus its potential extra width can cause the highlight background to clip oddly or leave a gap.

**Recommended pattern**: `emoji` + space + `` `LABEL: content` ``

Example: `` APPROVAL GATE: Implement authentication `` renders the emoji in the normal text flow and the label+title in the code span.

### Concrete Template: APPROVAL GATE (recommended)

```
`────────────────────────────────────────────────────`
⚗️ `APPROVAL GATE: <Task title>`
`Agent:` <who produced this> | `Blocked tasks:` <what's waiting>

`DECISION:` <one-sentence summary of the deliverable/decision>

`DELIVERABLE:`
  <file path 1> (<change scope>, +N/-M lines)
  <file path 2> (<change scope>, +N/-M lines)
  `Summary:` <1-2 sentences describing what was produced>

`RATIONALE:`
- <key point 1>
- <key point 2>
- Rejected: <alternative and why>

`IMPACT:` <what approving/rejecting means for the project>
`Confidence:` HIGH | MEDIUM | LOW
`────────────────────────────────────────────────────`
```

Design notes on this template:
- Top and bottom borders are identical highlighted spans -- creates visual "card" framing.
- Header line: emoji outside span, full `APPROVAL GATE: <title>` inside span -- reads as a card title bar.
- `Agent:` and `Blocked tasks:` get label-only wrapping -- these are secondary metadata, highlight helps the eye parse the pipe-separated structure.
- `Summary:` inside DELIVERABLE gets its own highlight -- it's a sub-label within the file list.
- `Confidence:` label is highlighted; the value (HIGH/MEDIUM/LOW) is not, allowing the user to read the value without the visual noise of highlight.
- List content under RATIONALE: and DELIVERABLE: remains unhighlighted -- these are the substance the user needs to read carefully.

### Scope: All Decision-weight elements, not just APPROVAL GATE

**Apply the backtick card framing pattern to ALL Decision-weight elements.** The Visual Hierarchy table defines "Decision" as a weight class, not a single template. If only the APPROVAL GATE gets the new treatment but TEAM, REVIEWERS, EXECUTION PLAN, PLAN IMPASSE, SECURITY FINDING, and VERIFICATION ISSUE keep the old `---` style, the visual hierarchy breaks: some Decision-weight elements will look heavier than others despite having the same attention demand.

However, the scope of the current issue says "In: SKILL.md approval gate template." I recommend a **two-step approach**:

1. **This issue**: Apply the backtick card framing to the APPROVAL GATE template (Phase 4, step 5) and update the Visual Hierarchy table to describe the new Decision weight pattern. This establishes the pattern.
2. **Follow-up issue**: Apply the same pattern to the remaining 6 Decision-weight elements (TEAM, REVIEWERS, EXECUTION PLAN, PLAN IMPASSE, SECURITY FINDING, VERIFICATION ISSUE). This is mechanical work once the pattern is established but it touches many sections of SKILL.md and should be separately reviewable.

The Visual Hierarchy table update in this issue should describe the NEW pattern even though not all Decision-weight elements will use it yet. Add a note that the remaining elements will be updated in a follow-up. This way the table serves as the specification, and the follow-up issue just brings the remaining templates into compliance.

### Visual Hierarchy Table Update

Current:
```
| **Decision** | `---` card frame + `ALL-CAPS LABEL:` header + structured content | Approval gates, escalations -- requires user action |
```

Proposed:
```
| **Decision** | `` `─── ···` `` border + `` `LABEL:` `` highlighted fields + structured content | Approval gates, escalations -- requires user action |
```

This description captures all three visual cues: box-drawing border in code span, highlighted field labels, and the structured content within. The `` `─── ···` `` notation shows it's a code-span-wrapped box-drawing border without trying to reproduce the full 52-character line inside a table cell.

## Proposed Tasks

### Task 1: Update APPROVAL GATE template with backtick card framing
- **Agent**: devx-minion or direct implementation
- **Scope**: Replace the `---` borders in the APPROVAL GATE template (lines ~1286-1305 of SKILL.md) with the backtick-wrapped box-drawing pattern shown in the concrete template above
- **Details**:
  - Replace `---` top/bottom borders with `` `────────────────────────────────────────────────────` ``
  - Wrap header line: ⚗️ `` `APPROVAL GATE: <Task title>` ``
  - Wrap field labels: `` `DECISION:` ``, `` `DELIVERABLE:` ``, `` `RATIONALE:` ``, `` `IMPACT:` ``, `` `Confidence:` ``
  - Add `` `Agent:` `` and `` `Blocked tasks:` `` and `` `Summary:` `` label wrapping
  - Emoji stays OUTSIDE the code span

### Task 2: Update Visual Hierarchy table
- **Agent**: devx-minion or direct implementation
- **Scope**: Update the Decision row in the Visual Hierarchy table (line ~209 of SKILL.md) to reflect the new pattern
- **Details**: Replace the pattern description as shown above. Optionally add a brief note below the table that the remaining Decision-weight elements will be updated to match in a follow-up issue.

### Task 3 (optional, follow-up): Apply pattern to remaining Decision-weight elements
- **Agent**: devx-minion or direct implementation
- **Scope**: Apply the same backtick card framing to TEAM, REVIEWERS, EXECUTION PLAN, PLAN IMPASSE, SECURITY FINDING, VERIFICATION ISSUE templates
- **Details**: Mechanical application of the established pattern. Each template needs: box-drawing borders, label-only backtick wrapping, emoji outside spans.
- **Recommendation**: Separate issue/PR for clean review

## Risks and Concerns

### Risk 1: Terminal width and border wrapping
**Severity**: Low
**Description**: If the user's terminal is narrower than ~55 columns, the 52-character box-drawing border line will wrap, breaking the card illusion. However, this is an edge case -- most developer terminals are 80+ columns, and Claude Code's default panel width accommodates this.
**Mitigation**: 52 characters is conservative. If wrapping is observed in practice, reduce to 40. The exact width is a tuning parameter, not a structural decision.

### Risk 2: Box-drawing characters (U+2500) rendering
**Severity**: Very low
**Description**: Box-drawing characters (U+2500, `─`) are part of the basic Unicode box-drawing block and render correctly in virtually all modern terminal emulators. Unlike emojis, they don't have width ambiguity. They're the safest non-ASCII choice for terminal borders.
**Mitigation**: No action needed. If a terminal can't render U+2500, it likely can't render the existing ⚗️ emoji either, so this isn't a new risk.

### Risk 3: Backtick character within values
**Severity**: Very low
**Description**: If a task title or field value contains a literal backtick, it would prematurely close the code span. Example: `APPROVAL GATE: Fix the \`config\` parser` would break.
**Mitigation**: This is a markdown escaping issue, not a design issue. The template already uses backticks in other contexts (code blocks). File paths and task descriptions rarely contain backticks. If they do, the implementer can note that backticks in values should be escaped or that double-backtick spans (``` `` ``) can be used for the header.

### Risk 4: Consistency during transition period
**Severity**: Low
**Description**: If only the APPROVAL GATE gets the new treatment in this issue, there will be a visual inconsistency between Decision-weight elements until the follow-up issue is completed. The TEAM gate will use `---` while the APPROVAL GATE uses box-drawing borders.
**Mitigation**: This is acceptable if the follow-up is prioritized. The Visual Hierarchy table update in this issue serves as the spec -- the inconsistency is "in progress" not "by design." Document it explicitly.

### Risk 5: Cognitive load of highlighted labels
**Severity**: Very low but worth noting
**Description**: Too many highlighted elements in one gate could increase visual noise rather than reduce it. The proposed template has ~8 highlighted labels plus 2 border lines = 10 highlighted elements.
**Mitigation**: This is actually fine. The highlights serve as structural anchors, not emphasis. The user's eye learns to skip over them after one or two gates, using them as navigation landmarks. This is the same pattern as bold labels in a form -- frequent but functional, not noisy.

## Additional Agents Needed

No additional agents are needed beyond what's typical for a SKILL.md-focused change.

- **lucy** (governance): Should review the updated Visual Hierarchy table to ensure the new Decision weight pattern description is consistent with how the table is referenced elsewhere in the system.
- **margo** (simplicity): Should verify that the backtick treatment doesn't over-engineer the visual framing. The pattern should be simple enough that an agent can reproduce it from the template without counting characters or memorizing complex rules.

No frontend-minion, accessibility-minion, or other specialists are needed -- this is a terminal-rendered markdown pattern, not a web UI component.
