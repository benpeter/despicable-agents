MODE: SYNTHESIS

You are synthesizing specialist planning contributions into a
final execution plan.

## Original Task
<github-issue>
**Outcome**: Any roster adjustment at the Team Approval Gate triggers a full Phase 1 re-run, so that all agents' planning questions reflect the updated team composition. Currently, minor adjustments (1-2 changes) use a lightweight path that only generates questions for added agents, leaving existing agents' questions stale relative to the new roster. Since planning questions directly shape Phase 2 specialist focus, coherent questions across the full team produce better planning contributions.

**Success criteria**:
- Minor/substantial adjustment classification is removed from SKILL.md
- Any roster change at the Team Approval Gate triggers a full Phase 1 re-run
- Re-run prompt includes the original task, prior meta-plan, and structured delta (same as current substantial path)
- 1 re-run cap per gate is preserved
- 2 adjustment round cap is preserved
- AGENT.md references to minor/substantial paths are removed or updated

**Scope**:
- In: SKILL.md Team Approval Gate adjustment handling, AGENT.md if it references the minor/substantial distinction
- Out: Phase 1 meta-plan logic itself, other approval gates, Phase 3.5 reviewer adjustment gate
</github-issue>

---
Additional context: use opus for all agents

## Specialist Contributions

Read the following scratch files for full specialist contributions:
- /var/folders/3k/bfjvvz9s6dvdn_hvlhvr8lc00000gn/T//nefario-scratch-mxHO9Q/always-rerun-phase1-on-team-gate-change/phase2-devx-minion.md
- /var/folders/3k/bfjvvz9s6dvdn_hvlhvr8lc00000gn/T//nefario-scratch-mxHO9Q/always-rerun-phase1-on-team-gate-change/phase2-ux-strategy-minion.md
- /var/folders/3k/bfjvvz9s6dvdn_hvlhvr8lc00000gn/T//nefario-scratch-mxHO9Q/always-rerun-phase1-on-team-gate-change/phase2-lucy.md
- /var/folders/3k/bfjvvz9s6dvdn_hvlhvr8lc00000gn/T//nefario-scratch-mxHO9Q/always-rerun-phase1-on-team-gate-change/phase2-ai-modeling-minion.md

## Key consensus across specialists:

## Summary: devx-minion
Phase: planning
Recommendation: Remove shared adjustment classification definition, inline simplified version into Team gate (any non-zero change = re-run), inline the existing classification into Reviewer gate to prevent broken back-reference. Remove separate re-run cap (2-round adjustment cap already bounds worst-case).
Tasks: 3 -- Restructure Team gate adjustment to single always-re-run path; Inline Reviewer gate classification; Update CONDENSE line and docs/orchestration.md
Risks: Reviewer gate may reference deleted shared classification definition
Conflicts: none

## Summary: ux-strategy-minion
Phase: planning
Recommendation: Always-re-run is correct simplification. For re-run cap fallback, use mechanical inline adjustment (add/remove questions directly) -- this is a budget-exhaustion fallback, not the old minor path rebranded. Delta summary messages are sufficient for expectation management.
Tasks: 2 -- Replace adjustment classification with single always-re-run path; Define re-run cap fallback as mechanical inline adjustment
Risks: Phase 3.5 Reviewer gate retains minor/substantial -- track as follow-up
Conflicts: Disagrees with devx-minion on re-run cap: ux-strategy wants a mechanical fallback, devx wants to remove cap entirely

## Summary: lucy
Phase: planning
Recommendation: Cross-gate inconsistency is acceptable (different cost profiles). No AGENT.md/the-plan.md changes needed. Three files need changes: SKILL.md Team gate, SKILL.md Reviewer gate back-references, docs/orchestration.md. Re-run cap should be 1 per adjustment round (2 total), eliminating need for fallback path.
Tasks: 3 -- Rewrite Team gate adjustment handling; Fix Reviewer gate back-references; Update docs/orchestration.md
Risks: CONDENSE line for lightweight path cap must be updated
Conflicts: Agrees with devx-minion on removing fallback (contradicts ux-strategy's mechanical fallback)

## Summary: ai-modeling-minion
Phase: planning
Recommendation: Re-run prompt should instruct nefario to regenerate all questions from scratch, using prior meta-plan as context (not template). Add "coherent set" instruction (~30 tokens) and include resolved team list in prompt. Do NOT add change-significance signal.
Tasks: 2 -- Update re-run prompt wording in SKILL.md; Add coherence instruction to re-run constraint directives
Risks: Shared adjustment classification is referenced by Reviewer gate -- dangling reference if removed
Conflicts: none

## Key conflict to resolve:
devx-minion + lucy want to remove the re-run cap entirely (2-round adjustment cap is sufficient bound).
ux-strategy-minion wants to keep re-run cap with a mechanical inline fallback for cap-exceeded case.

## External Skills Context
No external skills detected.

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
7. Write your complete delegation plan to `/var/folders/3k/bfjvvz9s6dvdn_hvlhvr8lc00000gn/T//nefario-scratch-mxHO9Q/always-rerun-phase1-on-team-gate-change/phase3-synthesis.md`
