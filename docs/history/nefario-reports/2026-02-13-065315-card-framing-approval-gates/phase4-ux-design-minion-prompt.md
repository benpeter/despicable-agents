You are updating the nefario orchestration skill file to add card-style visual
framing to the APPROVAL GATE decision brief template. This leverages Claude
Code's built-in inline code highlight color to create card-like separation.

## File to edit

`/Users/ben/github/benpeter/2despicable/2/skills/nefario/SKILL.md`

## Change 1: APPROVAL GATE template (around lines 1286-1306)

Replace the current template block:

```
---
⚗️ APPROVAL GATE: <Task title>
Agent: <who produced this> | Blocked tasks: <what's waiting>

DECISION: <one-sentence summary of the deliverable/decision>

DELIVERABLE:
  <file path 1> (<change scope>, +N/-M lines)
  <file path 2> (<change scope>, +N/-M lines)
  Summary: <1-2 sentences describing what was produced>

RATIONALE:
- <key point 1>
- <key point 2>
- Rejected: <alternative and why>

IMPACT: <what approving/rejecting means for the project>
Confidence: HIGH | MEDIUM | LOW
---
```

With this new template that uses backtick-wrapped box-drawing borders and
backtick-wrapped field labels:

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

Design rules to follow precisely:
- The border lines are exactly 52 box-drawing dash characters (U+2500, ─) wrapped in backticks
- Top and bottom borders are identical
- The header line has the emoji OUTSIDE the backtick span: ⚗️ `APPROVAL GATE: <Task title>`
- Only field LABELS are backtick-wrapped, not their values (e.g., `DECISION:` not `DECISION: <value>`)
- `Summary:` inside DELIVERABLE also gets backtick-wrapped as a sub-label
- `Agent:` and `Blocked tasks:` get label-only backtick wrapping
- List content under RATIONALE: and DELIVERABLE: remains unhighlighted
- The backtick border lines replace the `---` borders entirely

## Change 2: Visual Hierarchy table (around line 209)

In the Visual Hierarchy table, replace the current Decision row:

```
| **Decision** | `---` card frame + `ALL-CAPS LABEL:` header + structured content | Approval gates, escalations -- requires user action |
```

With:

```
| **Decision** | `` `─── ···` `` border + `` `LABEL:` `` highlighted fields + structured content | Approval gates, escalations -- requires user action |
```

This shows the new pattern: code-span-wrapped box-drawing border, highlighted
field labels, and structured content within.

## What NOT to do

- Do NOT modify any other templates (TEAM gate, REVIEWERS gate, EXECUTION PLAN gate, etc.) -- those are out of scope for this issue
- Do NOT change the AskUserQuestion parameters or status file update sections that follow the template
- Do NOT modify the "Maximum 5 files" or "Target 12-18 lines" guidance paragraphs that follow the template
- Do NOT change any phase announcement formatting
- Do NOT add any new sections or commentary -- just the two targeted edits

## Verification

After editing, read back lines 1284-1310 and lines 207-212 to confirm the
changes rendered correctly. Ensure the box-drawing characters (─) are present
and that backtick wrapping is correct on all field labels.

## Task completion

When you finish your task, mark it completed with TaskUpdate (task ID "1") and
send a message to the team lead with:
- File paths with change scope and line counts
- 1-2 sentence summary of what was produced
