MODE: SYNTHESIS

You are synthesizing specialist planning contributions into a
final execution plan.

## Original Task

**Outcome**: Nefario prepends the alembic symbol (⚗️) to its status line display and all user-facing messages during orchestration sessions, giving it a distinctive visual identity that users instantly associate with "nefario is orchestrating."

**Success criteria**:
- Status line entry includes ⚗️ prefix (using text variant ⚗︎ where monospace alignment matters)
- All nefario phase announcements and user-facing messages are prefixed with ⚗️
- Symbol renders correctly in macOS Terminal, VS Code integrated terminal, and iTerm2
- No alignment or double-width issues in the Claude Code status line

**Scope**:
- In: Nefario skill (SKILL.md), nefario agent (AGENT.md), status line config (despicable-statusline skill)
- Out: Other agents' messaging, emoji/symbols for lucy/margo/minions, terminal compatibility testing beyond macOS

**Constraints**:
- Symbol is ⚗️ (U+2697, Alembic) — decided via team brainstorm with lucy, ux-strategy-minion, ux-design-minion
- Use text variant selector (⚗︎ / U+2697 U+FE0E) in monospace/status-line contexts to avoid 2-cell width

## Specialist Contributions

Read the following scratch files for full specialist contributions:
- /var/folders/3k/bfjvvz9s6dvdn_hvlhvr8lc00000gn/T//nefario-scratch-h34Soi/alembic-nefario-status-prefix/phase2-devx-minion.md
- /var/folders/3k/bfjvvz9s6dvdn_hvlhvr8lc00000gn/T//nefario-scratch-h34Soi/alembic-nefario-status-prefix/phase2-ux-strategy-minion.md
- /var/folders/3k/bfjvvz9s6dvdn_hvlhvr8lc00000gn/T//nefario-scratch-h34Soi/alembic-nefario-status-prefix/phase2-software-docs-minion.md

## Key consensus across specialists:

## Summary: devx-minion
Phase: planning
Recommendation: Use text variant (U+2697 U+FE0E) for monospace/status-line contexts, emoji variant (U+2697 U+FE0F) for markdown. Literal UTF-8 in bash echo strings.
Tasks: 1 -- Update all echo patterns in SKILL.md to prefix with text variant; update phase announcement templates to prefix with emoji variant
Risks: Terminal emulators may vary in handling variant selectors; U+FE0E invisible char could be stripped during editing
Conflicts: none
Full output: /var/folders/3k/bfjvvz9s6dvdn_hvlhvr8lc00000gn/T//nefario-scratch-h34Soi/alembic-nefario-status-prefix/phase2-devx-minion.md

## Summary: ux-strategy-minion
Phase: planning
Recommendation: Only prefix Orientation and Decision weight outputs (phase markers, gate briefs, AskUserQuestion headers, status line). Leave Advisory and Inline outputs unprefixed to avoid visual noise. Yields 8-12 occurrences per orchestration vs 20-30 with universal prefixing.
Tasks: 1 -- Apply selective prefixing based on visual hierarchy weight
Risks: AskUserQuestion header 12-char limit may be exceeded by prefix; banner blindness if over-applied
Conflicts: none
Full output: /var/folders/3k/bfjvvz9s6dvdn_hvlhvr8lc00000gn/T//nefario-scratch-h34Soi/alembic-nefario-status-prefix/phase2-ux-strategy-minion.md

## Summary: software-docs-minion
Phase: planning
Recommendation: One additional doc file needs updating: docs/using-nefario.md (line 191 status line example). All other docs are safe. Historical reports must not be modified.
Tasks: 1 -- Update docs/using-nefario.md status line example
Risks: U+FE0E could be stripped during editing; header length constraint
Conflicts: none
Full output: /var/folders/3k/bfjvvz9s6dvdn_hvlhvr8lc00000gn/T//nefario-scratch-h34Soi/alembic-nefario-status-prefix/phase2-software-docs-minion.md

## External Skills Context
4 external skills detected:
- despicable-lab (LEAF, not relevant)
- despicable-statusline (LEAF, reference resource -- no changes needed per devx-minion analysis)
- despicable-prompter (LEAF, not relevant)
- nefario (ORCHESTRATION, edit target, not invoked as skill)

## Instructions
1. Review all specialist contributions
2. Resolve any conflicts between recommendations
3. Incorporate risks and concerns into the plan
4. Create the final execution plan in structured format
5. Ensure every task has a complete, self-contained prompt
6. If external skills were discovered, include them in the execution plan:
   - ORCHESTRATION skills: create DEFERRED macro-tasks (see Core Knowledge)
   - LEAF skills: list in the Available Skills section of relevant task prompts
   - Apply precedence rules when skills overlap with internal specialists
7. Write your complete delegation plan to `/var/folders/3k/bfjvvz9s6dvdn_hvlhvr8lc00000gn/T//nefario-scratch-h34Soi/alembic-nefario-status-prefix/phase3-synthesis.md`
