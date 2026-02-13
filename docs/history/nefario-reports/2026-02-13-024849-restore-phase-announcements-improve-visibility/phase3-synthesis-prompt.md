MODE: SYNTHESIS

You are synthesizing specialist planning contributions into a final execution plan.

## Original Task

Restore phase announcements and improve orchestration message visibility in nefario's SKILL.md.

**Outcome**: Nefario's orchestration messages (phase transitions, approval gates, status updates) are visually distinct from tool output and easy to follow. Approval gates present clear, meaningful links to relevant artifacts instead of raw scratch directory paths.

**Success criteria**:
- Phase transition announcements are restored and visible to the user
- Nefario orchestration messages are visually distinguishable from tool output at a glance
- Approval gate messages use meaningful labels instead of raw scratch directory paths
- Highlighting approach works within Claude Code's actual text rendering capabilities (monospace terminal, CommonMark markdown)
- No regression in useful output suppression rules

**Scope**: In: SKILL.md communication protocol / output discipline sections, approval gate message formatting, scratch directory reference presentation, phase transition announcements. Out: Subagent output formatting, tool output suppression rules unrelated to nefario messages, AGENT.md changes, scratch directory structure itself.

## Specialist Contributions

Read the following scratch files for full specialist contributions:
- /var/folders/3k/bfjvvz9s6dvdn_hvlhvr8lc00000gn/T//nefario-scratch-nizNjj/restore-phase-announcements-improve-visibility/phase2-ux-design-minion.md
- /var/folders/3k/bfjvvz9s6dvdn_hvlhvr8lc00000gn/T//nefario-scratch-nizNjj/restore-phase-announcements-improve-visibility/phase2-ux-strategy-minion.md
- /var/folders/3k/bfjvvz9s6dvdn_hvlhvr8lc00000gn/T//nefario-scratch-nizNjj/restore-phase-announcements-improve-visibility/phase2-devx-minion.md
- /var/folders/3k/bfjvvz9s6dvdn_hvlhvr8lc00000gn/T//nefario-scratch-nizNjj/restore-phase-announcements-improve-visibility/phase2-software-docs-minion.md
- /var/folders/3k/bfjvvz9s6dvdn_hvlhvr8lc00000gn/T//nefario-scratch-nizNjj/restore-phase-announcements-improve-visibility/phase2-user-docs-minion.md
- /var/folders/3k/bfjvvz9s6dvdn_hvlhvr8lc00000gn/T//nefario-scratch-nizNjj/restore-phase-announcements-improve-visibility/phase2-product-marketing-minion.md

## Key consensus across specialists:

## Summary: ux-design-minion
Phase: planning
Recommendation: Three-tier visual weight system (framed/quoted/inline) using CommonMark. Restore phase banners with NEFARIO prefix between horizontal rules. Consistent prefix on all gates. Semantic file references with content hints.
Tasks: 4 -- restore phase banners; apply consistent framing to all gates; convert compaction to blockquotes; implement semantic file labels
Risks: `---` renders as `<hr>` in some markdown renderers
Conflicts: none
Full output: phase2-ux-design-minion.md

## Summary: ux-strategy-minion
Phase: planning
Recommendation: Replace 3-tier system with 4 tiers (ORIENTATION/DECISION/SUPPRESS/CONDENSE). One-line phase markers between dashes. Label-first artifact references. Dark kitchen stays dark but gets entry marker.
Tasks: 4 -- restructure tiers; add phase markers; redesign artifact references; update dark kitchen entry
Risks: Over-restoration could make phase announcements compete with gates; `---` may render as hr
Conflicts: none
Full output: phase2-ux-strategy-minion.md

## Summary: devx-minion
Phase: planning
Recommendation: Labels describe content not filenames. Always show full resolved paths. Add parenthetical content hints. Standardize to Details/Prompt/Working dir vocabulary.
Tasks: 3 -- standardize reference vocabulary; add content hints; update all gate formats
Risks: macOS TMPDIR paths can be 100+ chars, visually dominating gate output
Conflicts: none
Full output: phase2-devx-minion.md

## Summary: software-docs-minion
Phase: planning
Recommendation: Three docs need updating: using-nefario.md (MUST), orchestration.md (MUST), compaction-strategy.md (SHOULD). Dark kitchen terminology needs reconciling with restored phase markers.
Tasks: 3 -- update using-nefario.md; update orchestration.md; verify compaction-strategy.md
Risks: dark kitchen terminology inconsistency across docs
Conflicts: none
Full output: phase2-software-docs-minion.md

## Summary: user-docs-minion
Phase: planning
Recommendation: Update phase descriptions in using-nefario.md, add compact "What to Expect" example (15-25 lines), reflect gate label improvements in docs. Maintenance coupling risk.
Tasks: 3 -- update phase descriptions; add What to Expect example; optionally add gate snippets
Risks: maintenance coupling between SKILL.md output format and user guide examples
Conflicts: none
Full output: phase2-user-docs-minion.md

## Summary: product-marketing-minion
Phase: planning
Recommendation: Tier 3 (Document Only). No README or positioning changes needed. SKILL.md changes are self-documenting.
Tasks: 0 -- no positioning tasks
Risks: If scope expands to changing gate interaction model, re-evaluate as Tier 2
Conflicts: none
Full output: phase2-product-marketing-minion.md

## External Skills Context
No external skills detected as relevant. despicable-lab, despicable-statusline, and despicable-prompter are all outside the task domain.

## Instructions
1. Review all specialist contributions
2. Resolve any conflicts between recommendations
3. Incorporate risks and concerns into the plan
4. Create the final execution plan in structured format
5. Ensure every task has a complete, self-contained prompt
6. No external skills to integrate
7. Write your complete delegation plan to `/var/folders/3k/bfjvvz9s6dvdn_hvlhvr8lc00000gn/T//nefario-scratch-nizNjj/restore-phase-announcements-improve-visibility/phase3-synthesis.md`

IMPORTANT NOTES:
- All changes are to SKILL.md and documentation markdown files. No code execution.
- The main execution agent should be a general-purpose agent with bypassPermissions mode since all work is markdown editing.
- Keep the plan lean: merge overlapping tasks, avoid unnecessary gates.
- Documentation updates (using-nefario.md, orchestration.md, compaction-strategy.md) can be a separate parallel task from SKILL.md changes.
- Product marketing confirmed Tier 3 — no README changes needed.
