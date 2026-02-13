MODE: SYNTHESIS

You are synthesizing specialist planning contributions into a final execution plan.

## Original Task

Two GitHub issues to implement together, both targeting `skills/nefario/SKILL.md`:

### Issue #112: embed context usage in compaction AskUserQuestion gates
Parse `<system_warning>` Token usage and embed context percentage in the AskUserQuestion question text at both compaction checkpoints.

### Issue #110: add pbcopy clipboard support to compaction checkpoints
Add `pbcopy` clipboard copy to both compaction checkpoint gates. Mac-only acceptable.

## Specialist Contributions

Read the following scratch files for full specialist contributions:
- /var/folders/3k/bfjvvz9s6dvdn_hvlhvr8lc00000gn/T//nefario-scratch-2d9adF/compaction-gate-context-clipboard/phase2-devx-minion.md
- /var/folders/3k/bfjvvz9s6dvdn_hvlhvr8lc00000gn/T//nefario-scratch-2d9adF/compaction-gate-context-clipboard/phase2-observability-minion.md

## Key consensus across specialists:

### devx-minion
- Context line FIRST in question text: `[Context: N% used -- Nk remaining]`
- pbcopy in "Compact" response handling only (not before gate) to avoid clipboard overwrite on "Skip"
- Fix `$summary` to `$summary_full` in Run: line (pre-existing bug)
- Silent — no success/failure surfacing for pbcopy

### observability-minion
- Backward scan for most recent `<system_warning>` — no proactive tool call (saves tokens)
- Silent degradation: if warning absent or format changed, omit context line entirely
- Handle comma-formatted numbers in token counts
- Document format as empirical (HTML comment)
- Also found the $summary → $summary_full bug

## External Skills Context
No external skills detected relevant to this task.

## Instructions
1. Review all specialist contributions
2. Resolve any conflicts between recommendations
3. Incorporate risks and concerns into the plan
4. Create the final execution plan in structured format
5. Ensure every task has a complete, self-contained prompt
6. Write your complete delegation plan to /var/folders/3k/bfjvvz9s6dvdn_hvlhvr8lc00000gn/T//nefario-scratch-2d9adF/compaction-gate-context-clipboard/phase3-synthesis.md

IMPORTANT: This is a single-file change (skills/nefario/SKILL.md). One execution task with one agent is sufficient. Use model opus. Mode bypassPermissions. No approval gates needed (additive, reversible changes).
