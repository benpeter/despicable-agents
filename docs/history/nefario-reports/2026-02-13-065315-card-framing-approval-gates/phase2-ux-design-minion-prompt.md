You are contributing to the PLANNING phase of a multi-agent project.
You are NOT executing yet — you are providing your domain expertise
to help build a comprehensive plan.

## Project Task

Add card-style visual framing to approval gates in SKILL.md by using inline
code spans (backticks) on structural lines, leveraging Claude Code's built-in
code highlight color to create card-like separation.

**Success criteria**:
- Gate header line uses backtick-wrapped text with box-drawing dash (─) border
- All CAPS-LABEL field names (DECISION:, DELIVERABLE:, RATIONALE:, IMPACT:, Confidence:) are backtick-wrapped
- Closing border line uses backtick-wrapped box-drawing dashes
- Visual Hierarchy table in SKILL.md updated to reflect the new Decision weight pattern
- Gate renders as a visually coherent card in Claude Code terminal output

**Constraints**:
- Only inline code spans (backticks) and box-drawing characters -- no markdown extensions, no special rendering

## Your Planning Question

Given that Claude Code renders inline code spans (`backticks`) with a distinct
highlight color against the terminal background, what is the optimal way to
apply backtick wrapping to create a card-like visual effect? Specifically:
(a) Should the `---` border lines be replaced with box-drawing characters (─)
wrapped in a single backtick span, or should they be broken into segments?
(b) For field labels like `DECISION:`, should just the label be wrapped or
the label plus its value?
(c) Does wrapping the header line `⚗️ APPROVAL GATE: <Task title>` in backticks
risk readability issues with the emoji rendering inside a code span in terminal
environments?
Provide a concrete template showing the recommended backtick placement.

## Context

The current SKILL.md approval gate template (Phase 4, step 5) looks like this:

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

The Visual Hierarchy table currently looks like:

| Weight | Pattern | Use |
|--------|---------|-----|
| **Decision** | `---` card frame + `ALL-CAPS LABEL:` header + structured content | Approval gates, escalations -- requires user action |
| **Orientation** | `**--- ⚗️ Phase N: Name ---**` | Phase transitions -- glance and continue |
| **Advisory** | `>` blockquote with bold label | Compaction checkpoints -- optional user action |
| **Inline** | Plain text, no framing | CONDENSE lines, heartbeats, informational notes |

There are also other Decision-weight elements in SKILL.md:
- TEAM gate (Phase 1)
- REVIEWERS gate (Phase 3.5)
- EXECUTION PLAN gate (Phase 3.5/4 boundary)
- PLAN IMPASSE (Phase 3.5)
- SECURITY FINDING (Phase 5)
- VERIFICATION ISSUE (Phase 5)

The issue's scope says "In: SKILL.md approval gate template", but the Visual Hierarchy
table applies the Decision weight to all "Approval gates, escalations". Consider whether
the backtick card framing should apply to all Decision-weight elements or just the
APPROVAL GATE template.

## Instructions
1. Read the SKILL.md file at /Users/ben/github/benpeter/2despicable/2/skills/nefario/SKILL.md
   to understand the current gate templates and Visual Hierarchy
2. Apply your domain expertise to the planning question
3. Identify risks, dependencies, and requirements from your perspective
4. If you believe additional specialists should be involved that
   aren't already part of the planning, say so and explain why
5. Return your contribution in this format:

## Domain Plan Contribution: ux-design-minion

### Recommendations
<your expert recommendations for this aspect of the task>

### Proposed Tasks
<specific tasks that should be in the execution plan>
For each task: what to do, deliverables, dependencies

### Risks and Concerns
<things that could go wrong from your domain perspective>

### Additional Agents Needed
<any specialists not yet involved who should be, and why>
(or "None" if the current team is sufficient)

6. Write your complete contribution to `/var/folders/3k/bfjvvz9s6dvdn_hvlhvr8lc00000gn/T//nefario-scratch-mq2F9b/card-framing-approval-gates/phase2-ux-design-minion.md`
