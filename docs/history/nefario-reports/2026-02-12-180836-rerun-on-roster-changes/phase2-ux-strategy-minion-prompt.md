You are contributing to the PLANNING phase of a multi-agent project.
You are NOT executing yet — you are providing your domain expertise
to help build a comprehensive plan.

## Project Task

Add re-run option when roster changes significantly at team and reviewer approval gates.

When a user adjusts team composition at either the Team Approval Gate or the Reviewer Approval Gate (Phase 3.5), substantial roster changes should trigger a re-run of the relevant planning phase so that questions and review coverage reflect the updated composition. Minor adjustments (1-2 agents changed) keep the fast lightweight path. Substantial adjustments (3+ agents changed) default to or recommend re-run. No additional approval gates introduced.

## Your Planning Question

The current approval gates (Team and Reviewer) have a clean 3-option flow: Approve / Adjust / Reject (or Skip). Adding a re-run path to the "Adjust" flow introduces a secondary decision point: after the user says what to change, they may be offered "lightweight adjustment" vs. "re-run the planning phase." How should this be presented to minimize cognitive load while preserving the user's ability to control the process? Specifically: (1) Should the minor/substantial threshold be communicated to the user, or should it be invisible with just a recommendation? (2) When the re-run produces a new meta-plan, the gate re-presents with potentially different specialists -- is the user's mental model of "I'm adjusting my team" preserved, or does it feel like starting over? (3) The issue says "no additional approval gates introduced" -- does the re-run result naturally fit into the existing gate, or does the gate need to be reshaped? Consider the anti-fatigue rules and gate budget.

## Context

Read the following files for context:
- `skills/nefario/SKILL.md` lines 379-457 (Team Approval Gate)
- `skills/nefario/SKILL.md` lines 643-703 (Reviewer Approval Gate)
- `skills/nefario/SKILL.md` lines 134-172 (Communication Protocol for CONDENSE/SHOW rules)

The user interaction pattern: gate -> adjust -> freeform input -> (new: classify change size) -> (new: recommend lightweight or re-run) -> re-present gate.

## Instructions
1. Read relevant files to understand the current state
2. Apply your domain expertise to the planning question
3. Identify risks, dependencies, and requirements from your perspective
4. If you believe additional specialists should be involved that aren't already part of the planning, say so and explain why
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

6. Write your complete contribution to /var/folders/3k/bfjvvz9s6dvdn_hvlhvr8lc00000gn/T//nefario-scratch-mhoPIa/rerun-on-roster-changes/phase2-ux-strategy-minion.md
