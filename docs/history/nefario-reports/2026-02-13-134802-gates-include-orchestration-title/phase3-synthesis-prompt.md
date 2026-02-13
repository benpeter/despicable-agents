MODE: SYNTHESIS

You are synthesizing specialist planning contributions into a
final execution plan.

## Original Task
Every AskUserQuestion gate in the nefario orchestration SKILL.md must include the orchestration run title so the user always knows which run they're deciding on -- even when the status line is hidden by AskUserQuestion prompts. This is critical for parallel nefario sessions in different terminals. The post-exec gate is the worst offender (no context at all). 11 gates total need updating.

## Specialist Contributions

Read the following scratch files for full specialist contributions:
- `/var/folders/3k/bfjvvz9s6dvdn_hvlhvr8lc00000gn/T//nefario-scratch-1zOJ65/gates-include-orchestration-title/phase2-devx-minion.md`
- `/var/folders/3k/bfjvvz9s6dvdn_hvlhvr8lc00000gn/T//nefario-scratch-1zOJ65/gates-include-orchestration-title/phase2-ux-strategy-minion.md`
- `/var/folders/3k/bfjvvz9s6dvdn_hvlhvr8lc00000gn/T//nefario-scratch-1zOJ65/gates-include-orchestration-title/phase2-ai-modeling-minion.md`

## Key consensus across specialists:

### Areas of agreement:
- Use `$summary` (not slug) as the run identifier -- matches status line, natural language
- Leave `header` field alone (12-char cap is for phase identity)
- Post-exec gate needs both run-level AND task-level context
- Single file change (SKILL.md only)

### Key conflict: placement convention
- devx-minion: SUFFIX -- append `\n\nRun: $summary` as trailing line
- ux-strategy-minion: PREFIX -- `$summary -- <gate-specific content>`
- ai-modeling-minion: BRACKET PREFIX -- `[$summary] <question>`

### Specialist-specific insights:
- ai-modeling-minion: Centralized convention note (5 lines) near existing header constraint (line 503-504) is DRYer than 12 individual updates. Only 3 gates with literal strings need explicit spec updates. Add $summary to compaction focus strings.
- devx-minion: Verify multiline question support (evidence suggests yes from P4 reject-confirm gate)
- ux-strategy-minion: 80-char soft limit, truncate gate content (not $summary) when combined length exceeds

## External Skills Context
No external skills detected

## Instructions
1. Review all specialist contributions
2. Resolve the prefix vs suffix placement conflict
3. Incorporate risks and concerns into the plan
4. Create the final execution plan in structured format
5. Ensure every task has a complete, self-contained prompt
6. Write your complete delegation plan to `/var/folders/3k/bfjvvz9s6dvdn_hvlhvr8lc00000gn/T//nefario-scratch-1zOJ65/gates-include-orchestration-title/phase3-synthesis.md`
