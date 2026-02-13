MODE: SYNTHESIS

You are synthesizing specialist planning contributions into a
final execution plan.

## Original Task

Document the /despicable-statusline skill in the project's docs so that users understand what it does, when to use it, and what it modifies before invoking it.

Success criteria:
- Skill is listed in relevant project documentation (README or docs/)
- Documentation explains what the skill does, what it modifies (~/.claude/settings.json), and the four config states it handles
- Documentation mentions idempotency and safety (backup/rollback)

Scope:
- In: Project-level documentation for the skill (README, docs/)
- Out: Changes to the SKILL.md itself, changes to nefario's SKILL.md, statusline styling

## Specialist Contributions

Read the following scratch files for full specialist contributions:
- /var/folders/3k/bfjvvz9s6dvdn_hvlhvr8lc00000gn/T//nefario-scratch-6Op9Al/add-despicable-statusline-docs/phase2-software-docs-minion.md
- /var/folders/3k/bfjvvz9s6dvdn_hvlhvr8lc00000gn/T//nefario-scratch-6Op9Al/add-despicable-statusline-docs/phase2-user-docs-minion.md

## Key consensus across specialists:

### software-docs-minion
Phase: planning
Recommendation: Augment two existing pages (using-nefario.md and deployment.md), no new standalone page. Lead with automated skill, keep manual JSON as fallback.
Tasks: 2 -- Rewrite Status Line section in using-nefario.md; Add skill to deployment.md Skills section
Risks: Manual JSON drift from skill's actual command
Conflicts: none

### user-docs-minion
Phase: planning
Recommendation: Present config states as user-perspective outcomes, not state machine. One before/after example. Safety as brief callout. Lead with automated skill.
Tasks: 3 -- Restructure using-nefario.md Status Line; Add project-local note to README; Add paragraph to deployment.md Skills
Risks: Duplication between manual/automated docs; project-local discoverability; State D UX; install.sh scope confusion
Conflicts: user-docs-minion suggests README change, software-docs-minion says leave README unchanged

## External Skills Context
2 project-local skills discovered (despicable-lab, despicable-statusline). Neither is used as an execution tool for this task. despicable-statusline is the documentation subject.

## Instructions
1. Review all specialist contributions
2. Resolve any conflicts between recommendations (notably: README change vs no README change)
3. Incorporate risks and concerns into the plan
4. Create the final execution plan in structured format
5. Ensure every task has a complete, self-contained prompt
6. Write your complete delegation plan to `/var/folders/3k/bfjvvz9s6dvdn_hvlhvr8lc00000gn/T//nefario-scratch-6Op9Al/add-despicable-statusline-docs/phase3-synthesis.md`
