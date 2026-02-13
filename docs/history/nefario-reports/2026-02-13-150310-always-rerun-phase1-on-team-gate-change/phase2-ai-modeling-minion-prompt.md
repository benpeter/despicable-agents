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
The re-run prompt for Phase 1 sends the original task description, the original meta-plan, and a structured delta (added/removed agents) to nefario in META-PLAN mode. With always-re-run, every roster adjustment (even adding a single agent) goes through this re-run path. How should the re-run prompt instruct nefario to handle planning question generation for the revised team? Specifically: (a) should the prompt instruct nefario to regenerate all planning questions from scratch while being aware of what changed, or to explicitly reference and update the original questions? (b) Are there prompt engineering patterns that would help nefario maintain cross-agent question coherence (e.g., where one specialist's question references another's domain) when the team changes are small? (c) Should the re-run prompt include a "change significance" signal so nefario can calibrate depth of re-planning, or would that reintroduce the complexity we're trying to remove?

## Context
Read `skills/nefario/SKILL.md` lines 554-604 (the current substantial re-run path with its prompt structure and constraint directives), and `nefario/AGENT.md` for how nefario handles META-PLAN mode

## Instructions
1. Read relevant files to understand the current state
2. Apply your domain expertise to the planning question
3. Identify risks, dependencies, and requirements from your perspective
4. If you believe additional specialists should be involved that
   aren't already part of the planning, say so and explain why
5. Return your contribution in this format:

## Domain Plan Contribution: ai-modeling-minion

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
6. Write your complete contribution to `/var/folders/3k/bfjvvz9s6dvdn_hvlhvr8lc00000gn/T//nefario-scratch-mxHO9Q/always-rerun-phase1-on-team-gate-change/phase2-ai-modeling-minion.md`
