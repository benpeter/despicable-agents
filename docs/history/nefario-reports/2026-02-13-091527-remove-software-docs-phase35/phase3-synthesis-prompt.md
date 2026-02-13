MODE: SYNTHESIS

You are synthesizing specialist planning contributions into a
final execution plan.

## Original Task
Remove software-docs-minion from mandatory Phase 3.5 Architecture Reviewers and replace with ux-strategy-minion. Phase 8 (Documentation) will self-derive its work order from the synthesis plan and execution outcomes instead of merging two sources.

Success criteria:
- ALWAYS reviewers list is: security-minion, test-minion, ux-strategy-minion, lucy, margo
- software-docs-minion no longer runs during Phase 3.5
- Phase 3.5 no longer produces phase3.5-docs-checklist.md
- Phase 8 derives its checklist solely from synthesis plan + execution outcomes
- Phase 8 assigns owner tags and priority itself (single-source, no divergence flagging)
- software-docs-minion custom Phase 3.5 prompt removed from SKILL.md
- user-docs-minion remains in the discretionary Phase 3.5 reviewer pool (unchanged)
- Cross-cutting checklist "Documentation (ALWAYS)" item in Phase 1 remains (unchanged)
- All artifacts updated: the-plan.md, nefario AGENT.md, nefario SKILL.md, docs/orchestration.md
- the-plan.md changes pass the gate

Constraints:
- Use opus for all agents
- Human owner approves modification of the-plan.md (CLAUDE.md override)
- the-plan.md gate: before committing, present diff summary for explicit approval. Only Phase 3.5 reviewer list and Phase 8 checklist derivation sections may be touched

## Specialist Contributions

Read the following scratch files for full specialist contributions:
- /var/folders/3k/bfjvvz9s6dvdn_hvlhvr8lc00000gn/T/nefario-scratch-FHCBRb/remove-software-docs-phase35/phase2-software-docs-minion.md
- /var/folders/3k/bfjvvz9s6dvdn_hvlhvr8lc00000gn/T/nefario-scratch-FHCBRb/remove-software-docs-phase35/phase2-lucy.md

## Key consensus across specialists:

### software-docs-minion
Phase: planning
Recommendation: Removal is safe. ~95% of Phase 3.5 checklist is mechanically derivable from outcome-action table. Add one row for "derivative documentation consistency" to close the gap.
Tasks: 5 -- add derivative-docs row; remove from Phase 3.5; rewrite Phase 8 self-derivation; update docs; regenerate AGENT.md
Risks: Slightly less precise checklists (mitigated by Phase 8 agent judgment); loss of divergence signal (mitigated by nefario comparison)
Conflicts: none

### lucy
Phase: planning
Recommendation: Outcome-action table should remain primary driver for Phase 8. Owner tags and priority assigned by orchestrator, not doc agents. Flagged 14 specific locations across 4 files needing updates. Caught count error in issue ("6 to 5" should be "5, composition changes").
Tasks: explicit location checklist to prevent inconsistency
Risks: Consistency risk if locations not tracked; ux-strategy-minion promotion adds scope
Conflicts: none

## External Skills Context
No external skills detected.

## Instructions
1. Review all specialist contributions
2. Resolve any conflicts between recommendations
3. Incorporate risks and concerns into the plan
4. Create the final execution plan in structured format
5. Ensure every task has a complete, self-contained prompt

IMPORTANT: This task modifies multiple configuration/documentation files that are tightly coupled. The key artifacts to update are:
- the-plan.md (Phase 3.5 mandatory reviewer table, Phase 8 checklist derivation, scratch dir structure)
- skills/nefario/SKILL.md (Phase 3.5 mandatory reviewers, software-docs-minion custom prompt, Phase 8 merge logic, scratch dir structure)
- nefario/AGENT.md (Phase 3.5 mandatory reviewers, Phase 8 checklist logic)
- docs/orchestration.md (Phase 3.5 reviewer documentation)

Task constraints from the issue:
- the-plan.md requires an APPROVAL GATE before committing
- Only Phase 3.5 reviewer list and Phase 8 checklist derivation sections may be touched in the-plan.md

The execution plan should use opus for ALL agents as specified in the constraints.

6. Write your complete delegation plan to `/var/folders/3k/bfjvvz9s6dvdn_hvlhvr8lc00000gn/T/nefario-scratch-FHCBRb/remove-software-docs-phase35/phase3-synthesis.md`
