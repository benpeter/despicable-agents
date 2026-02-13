MODE: SYNTHESIS

You are synthesizing specialist planning contributions into a final execution plan.

## Original Task

Polish approval gate presentation in skills/nefario/SKILL.md:
1. Apply backtick card framing to 4 remaining gates (Team, Reviewer, Execution Plan, PR) — matching the pattern already applied to the mid-execution gate
2. Add markdown links to scratch files in all 5 gates (team, reviewer, exec plan, mid-execution, PR)
3. Shorten scratch dir display (slug-only display text, full path as link target)
4. Add prompt+verdict links in advisory sections
5. Make links visually distinct

Synthesized from GitHub issues #82 and #85. All requirements from both issues must be addressed.

## Specialist Contributions

Read the following scratch files for full specialist contributions:
- /var/folders/3k/bfjvvz9s6dvdn_hvlhvr8lc00000gn/T//nefario-scratch-ICWV4u/approval-gate-polish/phase2-ux-strategy-minion.md
- /var/folders/3k/bfjvvz9s6dvdn_hvlhvr8lc00000gn/T//nefario-scratch-ICWV4u/approval-gate-polish/phase2-devx-minion.md

## Key consensus across specialists:

### ux-strategy-minion
- Footer links (not inline) for all gates; role-based display labels
- Minimum viable link set: 1 link for Team/Reviewer/ExecPlan/Mid-exec, 0 for PR gate
- Path display rule (SKILL.md ~line 224) must be amended in the same change
- Critical: MD links inside backtick code blocks render as literal text, not clickable

### devx-minion
- Filename-only display text with full path as link target
- Backtick-wrap field labels, NOT link display text (avoids nested-backtick ambiguity)
- 7 consistency rules: footer Details link on every gate, identical borders, consistent header pattern
- Advisory links use label-prefixed format for complex advisories only
- Risk: Execution Plan gate line budget (25-40) could be exceeded

## External Skills Context
No external skills detected relevant to this task.

## Instructions
1. Review all specialist contributions
2. Resolve any conflicts between recommendations (ux-strategy says role-based labels like [meta-plan], devx says filename-only like [phase1-metaplan.md] — pick one)
3. Incorporate risks and concerns into the plan
4. Create the final execution plan in structured format
5. Ensure every task has a complete, self-contained prompt
6. This is a single-file change (SKILL.md) with potential path display rule amendment
7. Write your complete delegation plan to `/var/folders/3k/bfjvvz9s6dvdn_hvlhvr8lc00000gn/T//nefario-scratch-ICWV4u/approval-gate-polish/phase3-synthesis.md`
