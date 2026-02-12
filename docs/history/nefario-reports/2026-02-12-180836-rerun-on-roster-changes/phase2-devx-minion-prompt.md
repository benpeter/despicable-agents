You are contributing to the PLANNING phase of a multi-agent project.
You are NOT executing yet — you are providing your domain expertise
to help build a comprehensive plan.

## Project Task

Add re-run option when roster changes significantly at team and reviewer approval gates.

When a user adjusts team composition at either the Team Approval Gate or the Reviewer Approval Gate (Phase 3.5), substantial roster changes should trigger a re-run of the relevant planning phase so that questions and review coverage reflect the updated composition. At the Team Approval Gate, substantial specialist changes re-run the meta-plan to produce planning questions matching the revised team's domain coverage. At the Reviewer Approval Gate, substantial reviewer changes re-run reviewer identification so that discretionary rationales and domain signals align with the actual reviewer set. Minor adjustments (1-2 agents changed) keep the fast lightweight path. Substantial adjustments (3+ agents changed) default to or recommend re-run.

Success criteria:
- Team Approval Gate "Adjust team" flow offers a meta-plan re-run path (not just lightweight question generation)
- Reviewer Approval Gate "Adjust reviewers" flow offers a reviewer re-identification path when changes are substantial
- Minor adjustments (1-2 agents changed) still use the fast lightweight path by default at both gates
- Substantial adjustments (3+ agents changed) default to or recommend re-run at both gates
- Re-runs produce output with the same depth as the original phase
- No additional approval gates introduced (re-runs feed back into the existing gate)

Scope:
- In: Team Approval Gate "Adjust team" handling in SKILL.md, Reviewer Approval Gate "Adjust reviewers" handling in SKILL.md, nefario AGENT.md if meta-plan mode needs changes
- Out: Phase 2/3 specialist logic, Phase 5 code review, other approval gates, nefario core orchestration flow

## Your Planning Question

The "Adjust team" flow in SKILL.md (lines 428-445) currently generates planning questions for added agents via "lightweight inference from task context, not a full re-plan." The "Adjust reviewers" flow (lines 693-697) similarly constrains adjustments to the 6-member discretionary pool. The issue asks that substantial changes (3+ agents) trigger a re-run of the original phase (meta-plan re-run for Team gate, reviewer re-identification for Reviewer gate), while minor changes (1-2 agents) keep the fast lightweight path. How should the SKILL.md "Adjust team" and "Adjust reviewers" response handling sections be restructured to: (a) classify adjustments as minor vs. substantial, (b) default to the appropriate path for each, (c) let the user override the default (e.g., force lightweight for a large change or force re-run for a small one), and (d) ensure the re-run output feeds back into the same gate without introducing new approval gates? Consider the 2-round adjustment cap interaction -- does a re-run count as an adjustment round?

## Context

Read the following files for context:
- `skills/nefario/SKILL.md` lines 379-457 (Team Approval Gate) and lines 608-703 (Reviewer Approval Gate)
- `nefario/AGENT.md` lines 1-50 (META-PLAN invocation)

The existing flow structure: user selects "Adjust team" -> freeform input -> nefario interprets -> generates questions -> re-presents gate.

## Instructions
1. Read relevant files to understand the current state
2. Apply your domain expertise to the planning question
3. Identify risks, dependencies, and requirements from your perspective
4. If you believe additional specialists should be involved that aren't already part of the planning, say so and explain why
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

6. Write your complete contribution to /var/folders/3k/bfjvvz9s6dvdn_hvlhvr8lc00000gn/T//nefario-scratch-mhoPIa/rerun-on-roster-changes/phase2-devx-minion.md
