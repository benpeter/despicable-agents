You are contributing to the PLANNING phase of a multi-agent project.
You are NOT executing yet — you are providing your domain expertise to help build a comprehensive plan.

## Project Task

**Outcome**: Users always know which phase of nefario orchestration they are in and what task is being worked on, whether they are looking at the status line or responding to an approval gate. This closes the orientation gap where the status line is hidden during AskUserQuestion prompts, ensuring phase and task awareness is never lost regardless of UI state.

**Success criteria**:
- Nefario updates `/tmp/nefario-status-$sid` with the current phase followed by the task title at each phase boundary
- Status line displays both phase and task title during orchestration when visible
- All AskUserQuestion gates include a contextual indicator of the current phase/step within their messaging
- Phase and task context is visible in both the status line AND gate UI, so neither pathway loses orientation

**Scope**:
- In: Nefario SKILL.md phase transition logic, gate message templates, despicable-statusline skill
- Out: Changing Claude Code's AskUserQuestion UI behavior, modifying status line during interviews

## Your Planning Question

The status file at `/tmp/nefario-status-$sid` currently contains only a task summary (max 48 chars, e.g., "Build MCP server with OAuth..."). The issue asks to include both phase and task title (e.g., "Phase 3: Synthesis | Restore phase announcements"). How should the status file content be structured given: (a) the status line has limited horizontal space (it already shows directory, model, and context percentage), (b) users need "where am I?" orientation at a glance, (c) the file is written once per phase boundary and read continuously by the status line command, (d) during AskUserQuestion the status line is hidden so the gate itself must carry orientation. What is the right information density for the status line vs. the gate?

## Context
- Read the despicable-statusline SKILL.md at `/Users/ben/github/benpeter/2despicable/2/.claude/skills/despicable-statusline/SKILL.md` for the current status line format
- Read the nefario SKILL.md at `/Users/ben/github/benpeter/2despicable/2/skills/nefario/SKILL.md` - see lines 362-368 for current status file write, lines 176-201 for phase announcements
- The status line shell command currently outputs: `$dir | $model | Context: N% | $ns` where $ns is from the status file

## Instructions
1. Read relevant files to understand the current state
2. Apply your domain expertise to the planning question
3. Identify risks, dependencies, and requirements from your perspective
4. If you believe additional specialists should be involved that aren't already part of the planning, say so and explain why
5. Return your contribution in this format:

## Domain Plan Contribution: ux-strategy-minion

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
6. Write your complete contribution to `/var/folders/3k/bfjvvz9s6dvdn_hvlhvr8lc00000gn/T//nefario-scratch-3zAK10/show-phase-task-in-status-and-gates/phase2-ux-strategy-minion.md`
