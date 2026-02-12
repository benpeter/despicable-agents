MODE: SYNTHESIS

You are synthesizing specialist planning contributions into a
final execution plan.

## Original Task

Add re-run option when roster changes significantly at team and reviewer approval gates (#53).

When a user adjusts team composition at either the Team Approval Gate or the Reviewer Approval Gate (Phase 3.5), substantial roster changes trigger a re-run of the relevant planning phase so that questions and review coverage reflect the updated composition. Minor adjustments (1-2 agents changed) keep the fast lightweight path. Substantial adjustments (3+ agents changed) default to or recommend re-run. No additional approval gates introduced (re-runs feed back into the existing gate).

Scope:
- In: Team Approval Gate "Adjust team" handling in SKILL.md, Reviewer Approval Gate "Adjust reviewers" handling in SKILL.md, nefario AGENT.md if meta-plan mode needs changes
- Out: Phase 2/3 specialist logic, Phase 5 code review, other approval gates, nefario core orchestration flow

Additional context from user: use opus for everything and make sure the ai-modeling-minion is part of the planning and architecture review teams.

## Specialist Contributions

Read the following scratch files for full specialist contributions:
- /var/folders/3k/bfjvvz9s6dvdn_hvlhvr8lc00000gn/T/nefario-scratch-mhoPIa/rerun-on-roster-changes/phase2-devx-minion.md
- /var/folders/3k/bfjvvz9s6dvdn_hvlhvr8lc00000gn/T/nefario-scratch-mhoPIa/rerun-on-roster-changes/phase2-ux-strategy-minion.md
- /var/folders/3k/bfjvvz9s6dvdn_hvlhvr8lc00000gn/T/nefario-scratch-mhoPIa/rerun-on-roster-changes/phase2-ai-modeling-minion.md
- /var/folders/3k/bfjvvz9s6dvdn_hvlhvr8lc00000gn/T/nefario-scratch-mhoPIa/rerun-on-roster-changes/phase2-lucy.md

## Key consensus across specialists:

## Summary: devx-minion
Phase: planning
Recommendation: Simple deterministic threshold (1-2=minor, 3+=substantial). Re-run as system behavior with override; re-run counts toward same adjustment round. Team gate re-spawns nefario in META-PLAN; reviewer gate re-evaluates discretionary pool internally.
Tasks: 3 -- Restructure "Adjust team" handling with branching flow; Restructure "Adjust reviewers" handling with parallel flow; Add shared adjustment classification definition
Risks: Re-run latency (30-60s opus), stale context after re-run, edge case of removing all specialists
Conflicts: none
Full output: phase2-devx-minion.md

## Summary: ux-strategy-minion
Phase: planning
Recommendation: Re-run should be invisible system behavior, not user decision. Frame as "refresh" not "restart." Same gate structure preserved. No new AskUserQuestion for re-run choice.
Tasks: 2 -- Implement invisible classification with delta summary; Align heartbeat mechanism for re-run latency
Risks: Latency mismatch (30-60s re-run vs instant lightweight)
Conflicts: none
Full output: phase2-ux-strategy-minion.md

## Summary: ai-modeling-minion
Phase: planning
Recommendation: Context-aware re-run (not fresh). Original meta-plan + user delta + constraint directive. Reviewer gate re-run is in-place, no subagent. Cost justified at ~$0.03-0.07 per re-run, less than 5% occurrence.
Tasks: 3 -- Design META-PLAN re-run prompt template; Define reviewer gate re-run logic; Cost analysis documentation
Risks: Prompt bloat from context accumulation, nefario producing shallower output if constrained too much
Conflicts: none
Full output: phase2-ai-modeling-minion.md

## Summary: lucy
Phase: planning
Recommendation: Aligns with gate purpose if re-run is recommendation not forced gate. Absolute 3+ threshold for both gates. Cap at 1 re-run per gate to prevent infinite loops.
Tasks: 2 -- Implement re-run as branch in existing Adjust handling; Update docs/orchestration.md to document re-run paths
Risks: Intent drift if re-run feels like new gate, re-run cap and adjustment cap interaction unclear, SKILL.md/docs sync
Conflicts: Disagrees with devx/ux-strategy on adjustment cap: lucy says re-run resets the 2-round counter; devx/ux-strategy say re-run counts toward the same adjustment round.

## External Skills Context
No external skills detected relevant to this task.

## Instructions
1. Review all specialist contributions
2. Resolve any conflicts between recommendations. Key conflict: re-run cap/adjustment cap interaction (devx/ux-strategy: re-run counts toward round; lucy: re-run resets counter)
3. Incorporate risks and concerns into the plan
4. Create the final execution plan in structured format
5. Ensure every task has a complete, self-contained prompt
6. No external skills to include
7. Write your complete delegation plan to /var/folders/3k/bfjvvz9s6dvdn_hvlhvr8lc00000gn/T/nefario-scratch-mhoPIa/rerun-on-roster-changes/phase3-synthesis.md
