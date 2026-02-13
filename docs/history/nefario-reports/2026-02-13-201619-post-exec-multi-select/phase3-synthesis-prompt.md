MODE: SYNTHESIS

You are synthesizing specialist planning contributions into a
final execution plan.

## Original Task
<github-issue>
The post-execution skip interview (after Phase 4) currently uses single-choice AskUserQuestion options like "Skip to Phase 8" or "Run Phase 5". Change this to a multi-select so the user can pick exactly which post-execution phases to run (e.g., run Phase 5 code review and Phase 8 docs but skip Phase 6 tests and Phase 7 deploy).
</github-issue>

## Specialist Contributions

Read the following scratch files for full specialist contributions:
- /var/folders/3k/bfjvvz9s6dvdn_hvlhvr8lc00000gn/T/nefario-scratch-rEm4yP/post-exec-multi-select/phase2-ux-strategy-minion.md
- /var/folders/3k/bfjvvz9s6dvdn_hvlhvr8lc00000gn/T/nefario-scratch-rEm4yP/post-exec-multi-select/phase2-devx-minion.md
- /var/folders/3k/bfjvvz9s6dvdn_hvlhvr8lc00000gn/T/nefario-scratch-rEm4yP/post-exec-multi-select/phase2-ai-modeling-minion.md

## Key consensus across specialists:

### ux-strategy-minion
Recommendation: Use skip-framing (options = phases to skip), all unchecked by default (zero-action = run all), remove "Run all" option, 3 options with multiSelect: true
Tasks: 3 -- Update SKILL.md post-exec gate to multi-select; Update AGENT.md description; Validate multiSelect works in Claude Code UI
Risks: multiSelect: true might still not work; "confirm with none selected" is unusual UX pattern
Conflicts: none

### devx-minion
Recommendation: Use semantic matching for response parsing (not format-specific); freeform flags unchanged; freeform overrides structured selection on conflict; CONDENSE line unchanged
Tasks: 3 -- Rewrite skip determination logic for multi-select; Update freeform flag wording; Validate multiSelect response format
Risks: Loss of one-click "Run all" fast path if no default-checked support; multiSelect might still not work
Conflicts: none

### ai-modeling-minion
Recommendation: multiSelect: true IS functional -- Space bar toggles (not Enter); response format is comma-space-separated string; no default-checked support exists; use skip-framing so zero selections = run all
Tasks: 2 -- Manual verification of multiSelect behavior; Update spec files
Risks: Space vs Enter UX confusion; response format parsing needs testing
Conflicts: none

## External Skills Context
No external skills detected relevant to this task.

## Instructions
1. Review all specialist contributions
2. Resolve any conflicts between recommendations
3. Incorporate risks and concerns into the plan
4. Create the final execution plan in structured format
5. Ensure every task has a complete, self-contained prompt
6. Write your complete delegation plan to /var/folders/3k/bfjvvz9s6dvdn_hvlhvr8lc00000gn/T/nefario-scratch-rEm4yP/post-exec-multi-select/phase3-synthesis.md