You are contributing to the PLANNING phase of a multi-agent project.
You are NOT executing yet — you are providing your domain expertise
to help build a comprehensive plan.

## Project Task
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

## Your Planning Question
This change removes the minor/substantial classification from the Team Approval Gate adjustment handling. The issue explicitly scopes out the Phase 3.5 Reviewer Approval Gate, which has its own parallel minor/substantial classification (lines 1009-1043). After this change, SKILL.md will have an inconsistency: the Team Approval Gate always re-runs, but the Reviewer Approval Gate still uses minor/substantial paths. Is this inconsistency acceptable given the explicit scope boundary? Are there any references in AGENT.md or the-plan.md to the minor/substantial distinction that would need updating? (The meta-plan search found none, but governance review should confirm.) Finally, verify that the "1 re-run cap per gate" and "2 adjustment round cap" constraints remain coherent after removing the classification.

## Context
Read `skills/nefario/SKILL.md` lines 524-604 (Team gate adjustment), lines 1009-1043 (Reviewer gate adjustment for comparison), `nefario/AGENT.md` (check for references), `the-plan.md` (check for references), `docs/orchestration.md` lines 382-390

## Instructions
1. Read relevant files to understand the current state
2. Apply your domain expertise to the planning question
3. Identify risks, dependencies, and requirements from your perspective
4. If you believe additional specialists should be involved that
   aren't already part of the planning, say so and explain why
5. Return your contribution in this format:

## Domain Plan Contribution: lucy

### Recommendations
<your expert recommendations for this aspect of the task>

### Proposed Tasks
<specific tasks that should be in the execution plan>
For each task: what to do, deliverables, dependencies

### Risks and Concerns
<things that could go wrong from your domain perspective>

### Additional Agents Needed
<any specialists not yet involved who should be, and why>
(or "None" if the current team is sufficient)
6. Write your complete contribution to `/var/folders/3k/bfjvvz9s6dvdn_hvlhvr8lc00000gn/T//nefario-scratch-mxHO9Q/always-rerun-phase1-on-team-gate-change/phase2-lucy.md`
