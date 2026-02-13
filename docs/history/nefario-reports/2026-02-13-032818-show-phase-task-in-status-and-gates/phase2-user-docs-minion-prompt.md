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
- In: Nefario SKILL.md phase transition logic, gate message templates, despicable-statusline skill docs
- Out: Changing Claude Code's AskUserQuestion UI behavior

## Your Planning Question

The `docs/using-nefario.md` Status Line section currently describes the status bar as showing "the task summary." The "What Happens" section describes phase announcements but does not mention phase awareness in the status line or gates. What documentation changes are needed to reflect: (a) status line now shows phase + task, (b) approval gates now include phase context in their headers? Should the "How It Works" subsection be updated to describe the phase-updating behavior? Assess whether the manual configuration example needs to change or if the status line command remains the same (it reads whatever is in the file).

## Context
- Read `docs/using-nefario.md` at `/Users/ben/github/benpeter/2despicable/2/docs/using-nefario.md` for the current documentation
- Read the despicable-statusline SKILL.md at `/Users/ben/github/benpeter/2despicable/2/.claude/skills/despicable-statusline/SKILL.md` for the status line mechanism
- The status line shell command reads the file and appends it -- no command changes needed, just the content written to the file changes

## Instructions
1. Read relevant files to understand the current state
2. Apply your domain expertise to the planning question
3. Identify risks, dependencies, and requirements from your perspective
4. If you believe additional specialists should be involved that aren't already part of the planning, say so and explain why
5. Return your contribution in this format:

## Domain Plan Contribution: user-docs-minion

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
6. Write your complete contribution to `/var/folders/3k/bfjvvz9s6dvdn_hvlhvr8lc00000gn/T//nefario-scratch-3zAK10/show-phase-task-in-status-and-gates/phase2-user-docs-minion.md`
