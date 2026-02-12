You are contributing to the PLANNING phase of a multi-agent project.
You are NOT executing yet — you are providing your domain expertise
to help build a comprehensive plan.

## Project Task

Add re-run option when roster changes significantly at team and reviewer approval gates.

When a user adjusts team composition at either the Team Approval Gate or the Reviewer Approval Gate (Phase 3.5), substantial roster changes should trigger a re-run of the relevant planning phase so that questions and review coverage reflect the updated composition. Minor adjustments (1-2 agents changed) keep the fast lightweight path. Substantial adjustments (3+ agents changed) default to or recommend re-run. No additional approval gates introduced.

## Your Planning Question

When a substantial team change triggers a meta-plan re-run, nefario is spawned again in META-PLAN mode. This re-run needs to be context-aware: it should know what the original meta-plan contained, what the user changed, and why. Similarly, at the Reviewer Approval Gate, substantial reviewer changes require re-running the reviewer identification logic within nefario's synthesis context. Design the re-run prompts: (1) For the Team gate re-run: should the re-spawned nefario receive the original meta-plan as context, or start fresh? What information from the user's adjustment request should be included? How do we ensure the re-run produces output at the same depth as the original? (2) For the Reviewer gate re-run: this is not a nefario subagent spawn -- it is the calling session re-evaluating discretionary reviewers. What context does it need to produce plan-grounded rationales for the new reviewer set? (3) Cost implications: a meta-plan re-run spawns nefario on opus. Is this justified for the value it provides over lightweight question generation?

## Context

Read the following files for context:
- `skills/nefario/SKILL.md` lines 291-375 (Phase 1 -- nefario spawn with META-PLAN prompt)
- `skills/nefario/SKILL.md` lines 379-457 (Team Approval Gate)
- `skills/nefario/SKILL.md` lines 608-703 (Reviewer Approval Gate)
- `nefario/AGENT.md` lines 1-50 (META-PLAN mode behavior)

The distinction between "lightweight inference" (current approach: calling session generates questions from task context) vs. "full re-plan" (spawning nefario in META-PLAN mode with the updated team composition as a constraint).

## Instructions
1. Read relevant files to understand the current state
2. Apply your domain expertise to the planning question
3. Identify risks, dependencies, and requirements from your perspective
4. If you believe additional specialists should be involved that aren't already part of the planning, say so and explain why
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

6. Write your complete contribution to /var/folders/3k/bfjvvz9s6dvdn_hvlhvr8lc00000gn/T//nefario-scratch-mhoPIa/rerun-on-roster-changes/phase2-ai-modeling-minion.md
