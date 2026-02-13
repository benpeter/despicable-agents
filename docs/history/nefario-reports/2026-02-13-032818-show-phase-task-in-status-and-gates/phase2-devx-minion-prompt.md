You are contributing to the PLANNING phase of a multi-agent project.
You are NOT executing yet — you are providing your domain expertise to help build a comprehensive plan.

## Project Task

**Outcome**: Users always know which phase of nefario orchestration they are in and what task is being worked on, whether they are looking at the status line or responding to an approval gate. This closes the orientation gap where the status line is hidden during AskUserQuestion prompts, ensuring phase and task awareness is never lost regardless of UI state.

**Success criteria**:
- Nefario updates `/tmp/nefario-status-$sid` with the current phase followed by the task title at each phase boundary
- Status line displays both phase and task title during orchestration when visible
- All AskUserQuestion gates include a contextual indicator of the current phase/step within their messaging
- Phase and task context is visible in both the status line AND gate UI, so neither pathway loses orientation
- Existing phase announcement markers (`**--- Phase N: Name ---**`) from #57 continue to work alongside the new mechanisms

**Scope**:
- In: Nefario SKILL.md phase transition logic, gate message templates, despicable-statusline skill
- Out: Changing Claude Code's AskUserQuestion UI behavior, modifying status line during interviews, post-execution dark kitchen phases

## Your Planning Question

The nefario SKILL.md defines 11 distinct AskUserQuestion instances with headers like "Team", "Review", "Plan", "Gate", "Post-exec", "Confirm", "Calibrate", "Security", "Issue", "PR", and "Existing PR". The status line disappears during AskUserQuestion prompts, creating an orientation gap. How should we embed phase/step context into AskUserQuestion headers or question text so that users always know where they are in the orchestration? Consider: (a) should the `header` field carry phase context (e.g., "Phase 1 > Team") or should it go in the `question` text? (b) what format balances brevity with orientation? (c) should all 11 gate types get phase context or only certain ones?

## Context
- Read the nefario SKILL.md at `/Users/ben/github/benpeter/2despicable/2/skills/nefario/SKILL.md` for the 11 AskUserQuestion patterns
- Read `docs/history/nefario-reports/2026-02-13-024849-restore-phase-announcements-improve-visibility.md` for the #57 visual hierarchy system
- The `header` field in AskUserQuestion is max 12 chars
- The existing Visual Hierarchy from #57: Decision (ALL-CAPS + structured), Orientation (bold single line), Advisory (blockquote), Inline (plain text)

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
6. Write your complete contribution to `/var/folders/3k/bfjvvz9s6dvdn_hvlhvr8lc00000gn/T//nefario-scratch-3zAK10/show-phase-task-in-status-and-gates/phase2-devx-minion.md`
