MODE: SYNTHESIS

You are synthesizing specialist planning contributions into a
final execution plan.

## Original Task

Issue #87: Fix compaction checkpoints: add AskUserQuestion pause + clipboard copy

Compaction checkpoints (after Phase 3 and Phase 3.5) print a blockquote advisory suggesting the user run `/compact`, but the orchestration proceeds immediately without pausing. Replace with AskUserQuestion gates that actually pause execution.

Additional context: use opus for all agents

## Specialist Contributions

Read the following scratch files for full specialist contributions:
- `/var/folders/3k/bfjvvz9s6dvdn_hvlhvr8lc00000gn/T//nefario-scratch-PKILQw/fix-compaction-checkpoints/phase2-ux-strategy-minion.md`
- `/var/folders/3k/bfjvvz9s6dvdn_hvlhvr8lc00000gn/T//nefario-scratch-PKILQw/fix-compaction-checkpoints/phase2-devx-minion.md`
- `/var/folders/3k/bfjvvz9s6dvdn_hvlhvr8lc00000gn/T//nefario-scratch-PKILQw/fix-compaction-checkpoints/phase2-ai-modeling-minion.md`

## Key consensus across specialists:

## Summary: ux-strategy-minion
Phase: planning
Recommendation: "Skip" as recommended default is correct; simplify "continue" instruction to remove queuing explanation; use P<N> convention for headers (P3 Compact, P3.5 Compact); suppress P3.5 gate if user skipped at P3
Tasks: 3 -- replace checkpoints with AskUserQuestion gates; update visual hierarchy table; add skip-cascade logic
Risks: Gate fatigue if both checkpoints fire in sequence
Conflicts: none

## Summary: devx-minion
Phase: planning
Recommendation: Do NOT use clipboard; print the /compact command in a code block instead -- zero dependencies, zero failure modes, works on all platforms. Focus strings are static, no escaping issues. Simpler approach means less throwaway work when #88 lands.
Tasks: 3 -- replace checkpoints with AskUserQuestion + printed code block; update visual hierarchy table; add authoring guard comments near focus strings
Risks: Clipboard introduces invisible state and platform-specific failures
Conflicts: Opposes clipboard approach proposed in issue; recommends printed code block instead

## Summary: ai-modeling-minion
Phase: planning
Recommendation: Static focus strings are correct; template variables ($summary, $SCRATCH_DIR) must be interpolated to actual values before display. Auto-compaction risk during Phase 4 is pre-existing, not introduced by this change. Existing two-tier state approach is already the right architecture.
Tasks: 2 -- replace checkpoints with AskUserQuestion gates ensuring variable interpolation; update visual hierarchy table
Risks: Template variables in focus strings might not be interpolated if treated as literal text
Conflicts: none

## External Skills Context
No external skills detected relevant to this task.

## Instructions
1. Review all specialist contributions
2. Resolve any conflicts between recommendations
3. Incorporate risks and concerns into the plan
4. Create the final execution plan in structured format
5. Ensure every task has a complete, self-contained prompt

Key conflict to resolve: The issue proposes clipboard copy via pbcopy. devx-minion recommends printing the command in a code block instead (no clipboard). Evaluate and decide.

All three specialists agree on: use P<N> header convention, update visual hierarchy table, "Skip" as recommended default.

Note: The user specified "use opus for all agents" -- apply this to model selection for all execution agents.

6. Write your complete delegation plan to `/var/folders/3k/bfjvvz9s6dvdn_hvlhvr8lc00000gn/T//nefario-scratch-PKILQw/fix-compaction-checkpoints/phase3-synthesis.md`
