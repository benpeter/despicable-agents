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
The Team Approval Gate currently provides different processing depth based on change magnitude (minor vs. substantial). Collapsing to always-re-run changes the user's mental model: every adjustment now has the same processing cost (a full Phase 1 re-run). Does this create any cognitive load or expectation mismatch for users who make a small change (e.g., adding 1 agent) and then wait for a full re-run? Should the gate's delta summary message ("Refreshed for team change (+N, -M). Planning questions regenerated.") be adjusted to set expectations? Also: the re-run cap (line 544-546) currently says "if a second substantial adjustment occurs, use lightweight path" -- with always-re-run, the cap still applies (1 re-run per gate) but the fallback behavior needs a new definition since there is no lightweight path. What should happen on a second adjustment after the re-run cap is hit?

## Context
Read `skills/nefario/SKILL.md` lines 460-608 (Team Approval Gate), the user-facing presentation format (lines 472-498), the adjustment flow

## Instructions
1. Read relevant files to understand the current state
2. Apply your domain expertise to the planning question
3. Identify risks, dependencies, and requirements from your perspective
4. If you believe additional specialists should be involved that
   aren't already part of the planning, say so and explain why
5. Return your contribution in this format:

## Domain Plan Contribution: ux-strategy-minion

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
6. Write your complete contribution to `/var/folders/3k/bfjvvz9s6dvdn_hvlhvr8lc00000gn/T//nefario-scratch-mxHO9Q/always-rerun-phase1-on-team-gate-change/phase2-ux-strategy-minion.md`
