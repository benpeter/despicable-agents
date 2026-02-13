MODE: SYNTHESIS

You are synthesizing specialist planning contributions into a
final execution plan.

## Original Task

Add card-style visual framing to approval gates in SKILL.md by using inline
code spans (backticks) on structural lines, leveraging Claude Code's built-in
code highlight color to create card-like separation.

Source issue: #75 "Add card-style visual framing to approval gates in SKILL.md"

**Success criteria**:
- Gate header line uses backtick-wrapped text with box-drawing dash (─) border
- All CAPS-LABEL field names (DECISION:, DELIVERABLE:, RATIONALE:, IMPACT:, Confidence:) are backtick-wrapped
- Closing border line uses backtick-wrapped box-drawing dashes
- Visual Hierarchy table in SKILL.md updated to reflect the new Decision weight pattern
- Gate renders as a visually coherent card in Claude Code terminal output

**Scope**:
- In: SKILL.md approval gate template, Visual Hierarchy table description for Decision weight
- Out: Phase announcement formatting, compaction checkpoint formatting, AskUserQuestion prompts, non-SKILL.md documentation

**Constraints**:
- Only inline code spans (backticks) and box-drawing characters -- no markdown extensions, no special rendering

## Specialist Contributions

Read the following scratch file for full specialist contribution:
/var/folders/3k/bfjvvz9s6dvdn_hvlhvr8lc00000gn/T//nefario-scratch-mq2F9b/card-framing-approval-gates/phase2-ux-design-minion.md

## Key consensus across specialists:

**ux-design-minion**: Use single continuous backtick spans for 52 box-drawing dash (─) borders. Wrap only field labels (DECISION:, DELIVERABLE:, etc.) not their values. Keep emoji outside code spans to avoid rendering issues. Apply to APPROVAL GATE template now; follow-up for other Decision-weight elements.
- Tasks: 1 -- Update APPROVAL GATE template with backtick card framing + update Visual Hierarchy table
- Risks: Terminal width variation at narrow widths; emoji rendering outside code spans

## External Skills Context
No external skills relevant to this task.

## User Directives
- All approvals pre-given -- no approval gates needed
- Skip test and security post-exec phases (Phase 5 and 6)
- Include user-docs-minion, software-docs-minion, product-marketing-minion for Phase 8
- No compaction checkpoints
- Work through to PR creation without interactions

## Instructions
1. Review all specialist contributions
2. Resolve any conflicts between recommendations
3. Incorporate risks and concerns into the plan
4. Create the final execution plan in structured format
5. Ensure every task has a complete, self-contained prompt
6. No approval gates are needed (all pre-approved, single-file low-risk change)
7. Write your complete delegation plan to `/var/folders/3k/bfjvvz9s6dvdn_hvlhvr8lc00000gn/T//nefario-scratch-mq2F9b/card-framing-approval-gates/phase3-synthesis.md`
