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
The Team Approval Gate in `skills/nefario/SKILL.md` (lines 524-604) currently has two adjustment paths: minor (1-2 changes, lightweight inline question generation) and substantial (3+ changes, full Phase 1 re-run). We want to collapse these into a single path: any roster change always triggers a full Phase 1 re-run. What is the cleanest way to restructure the "Adjust team" response handling (steps 3-4b) into a single flow? Specifically: (a) how should the adjustment classification definition (lines 524-532) be rewritten to remove the threshold while preserving the 0-change no-op, (b) what happens to the re-run cap rule on line 544-546 now that every change triggers a re-run, and (c) how should the CONDENSE line on line 191 be updated given there is no longer a "substantial" qualifier?

## Context
Read `skills/nefario/SKILL.md` lines 460-608 (full Team Approval Gate section), lines 185-192 (CONDENSE line references), `docs/orchestration.md` lines 382-390 (adjustment description in orchestration docs)

## Instructions
1. Read relevant files to understand the current state
2. Apply your domain expertise to the planning question
3. Identify risks, dependencies, and requirements from your perspective
4. If you believe additional specialists should be involved that
   aren't already part of the planning, say so and explain why
5. Return your contribution in this format:

## Domain Plan Contribution: devx-minion

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
6. Write your complete contribution to `/var/folders/3k/bfjvvz9s6dvdn_hvlhvr8lc00000gn/T//nefario-scratch-mxHO9Q/always-rerun-phase1-on-team-gate-change/phase2-devx-minion.md`
