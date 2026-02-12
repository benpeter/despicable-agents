MODE: SYNTHESIS

You are synthesizing specialist planning contributions into a
final execution plan.

## Original Task

**Outcome**: Before nefario dispatches specialists for planning, the user sees which agents were selected and can approve, adjust, or veto the team composition. This prevents wasted compute on specialists the user considers irrelevant and gives the user visibility into orchestration decisions early.

**Success criteria**:
- After Phase 2 team selection, nefario presents the chosen specialists with rationale before proceeding
- User can approve the team as-is, remove specialists, or add specialists not initially selected
- Phase 2 does not proceed to specialist dispatch until the user confirms
- Existing Phase 3.5 architecture review gate continues to work unchanged

**Scope**:
- In: Nefario SKILL.md orchestration flow, Phase 2 team selection logic, approval gate UX
- Out: Phase 3.5 review gate changes, agent AGENT.md files, the-plan.md, adding new agents

## Specialist Contributions

Read the following scratch files for full specialist contributions:
- /var/folders/3k/bfjvvz9s6dvdn_hvlhvr8lc00000gn/T//nefario-scratch-ymv695/add-user-approval-gate-phase2-team-selection/phase2-ux-strategy-minion.md
- /var/folders/3k/bfjvvz9s6dvdn_hvlhvr8lc00000gn/T//nefario-scratch-ymv695/add-user-approval-gate-phase2-team-selection/phase2-devx-minion.md
- /var/folders/3k/bfjvvz9s6dvdn_hvlhvr8lc00000gn/T//nefario-scratch-ymv695/add-user-approval-gate-phase2-team-selection/phase2-lucy.md

## Key consensus across specialists:

## Summary: ux-strategy-minion
Phase: planning
Recommendation: Gate should be categorically lighter than execution plan gate (5-12 lines vs 25-40); three options (Approve/Adjust/Reject); "Adjust" uses freeform follow-up not 27-agent multi-select; CONDENSE line moves to after gate approval.
Tasks: 2 -- Add team selection gate to SKILL.md; Update docs/orchestration.md
Risks: Approval fatigue from two pre-execution gates; adjustment latency if spawning nefario for planning questions
Conflicts: none

## Summary: devx-minion
Phase: planning
Recommendation: Gate replaces "No need for formal user approval" text at SKILL.md ~line 374; natural language modification instead of 27-item multi-select; CONDENSE line fires before gate unchanged; four options (Approve/Modify/Skip planning/Abandon).
Tasks: 2 -- Update SKILL.md with gate section; Update docs/orchestration.md (Phase 2, new subsection, Mermaid diagram)
Risks: Approval fatigue from third gate; keep under 20 lines
Conflicts: none

## Summary: lucy
Phase: planning
Recommendation: APPROVE — gate aligns with project intent; no governance conflict; mandatory by default, user-skippable; MODE: PLAN bypasses naturally; Phase 3.5 unaffected; keep under 10 lines to avoid fatigue.
Tasks: 1 -- Implement gate with explicit MODE: PLAN exemption
Risks: AGENT.md scope boundary if meta-plan format changes needed; anti-fatigue concern
Conflicts: none

## External Skills Context
No external skills relevant to this task.

## Instructions
1. Review all specialist contributions
2. Resolve any conflicts between recommendations
3. Incorporate risks and concerns into the plan
4. Create the final execution plan in structured format
5. Ensure every task has a complete, self-contained prompt
6. Write your complete delegation plan to `/var/folders/3k/bfjvvz9s6dvdn_hvlhvr8lc00000gn/T//nefario-scratch-ymv695/add-user-approval-gate-phase2-team-selection/phase3-synthesis.md`
