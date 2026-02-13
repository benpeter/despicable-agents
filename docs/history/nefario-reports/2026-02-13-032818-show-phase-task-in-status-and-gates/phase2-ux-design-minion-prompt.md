You are contributing to the PLANNING phase of a multi-agent project.
You are NOT executing yet — you are providing your domain expertise to help build a comprehensive plan.

## Project Task

**Outcome**: Users always know which phase of nefario orchestration they are in and what task is being worked on, whether they are looking at the status line or responding to an approval gate. This closes the orientation gap where the status line is hidden during AskUserQuestion prompts, ensuring phase and task awareness is never lost regardless of UI state.

**Success criteria**:
- Nefario updates `/tmp/nefario-status-$sid` with the current phase followed by the task title at each phase boundary
- Status line displays both phase and task title during orchestration when visible
- All AskUserQuestion gates include a contextual indicator of the current phase/step within their messaging

**Scope**:
- In: Nefario SKILL.md phase transition logic, gate message templates, despicable-statusline skill
- Out: Changing Claude Code's AskUserQuestion UI behavior, modifying status line during interviews, post-execution dark kitchen phases

## Your Planning Question

Currently the status file is written once at Phase 1 start with a static task summary. The issue requires updating it at each phase boundary. The SKILL.md defines phase transitions at Phase 1, 2, 3, 3.5, and 4 (phases 5-8 use a combined CONDENSE line). Where exactly in the SKILL.md flow should the status file update calls be placed? Should the update happen before or after the phase announcement marker? Should mid-execution gate names also appear in the status (e.g., "Phase 4: Execution > Gate: DB Schema")? Consider the interaction between the status file update and the phase announcement -- they serve the same orientation purpose in different UI channels.

## Context
- Read the nefario SKILL.md at `/Users/ben/github/benpeter/2despicable/2/skills/nefario/SKILL.md` for:
  - Lines 362-368: current status file write (Phase 1 only)
  - Lines 176-201: phase announcement rules
  - Lines 1209+: execution batch loop and gate handling
- Read `docs/history/nefario-reports/2026-02-13-024849-restore-phase-announcements-improve-visibility.md` for the #57 context

## Instructions
1. Read relevant files to understand the current state
2. Apply your domain expertise to the planning question
3. Identify risks, dependencies, and requirements from your perspective
4. If you believe additional specialists should be involved that aren't already part of the planning, say so and explain why
5. Return your contribution in this format:

## Domain Plan Contribution: ux-design-minion

### Recommendations
<your expert recommendations>

### Proposed Tasks
<specific tasks that should be in the execution plan>
For each task: what to do, deliverables, dependencies

### Risks and Concerns
<things that could go wrong from your domain perspective>

### Additional Agents Needed
<any specialists not yet involved who should be, and why>
(or "None" if the current team is sufficient)
6. Write your complete contribution to `/var/folders/3k/bfjvvz9s6dvdn_hvlhvr8lc00000gn/T//nefario-scratch-3zAK10/show-phase-task-in-status-and-gates/phase2-ux-design-minion.md`
