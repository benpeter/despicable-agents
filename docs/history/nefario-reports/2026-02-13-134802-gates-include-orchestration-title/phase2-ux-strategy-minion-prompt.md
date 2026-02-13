You are contributing to the PLANNING phase of a multi-agent project.
You are NOT executing yet — you are providing your domain expertise
to help build a comprehensive plan.

## Project Task
Every AskUserQuestion gate in the nefario orchestration SKILL.md must include the orchestration run title so the user always knows which run they're deciding on -- even when the status line is hidden by AskUserQuestion prompts. This is critical for parallel nefario sessions in different terminals.

## Your Planning Question
When parallel orchestrations run, gates lose all context about which run the user is deciding on. Is `$summary` (40 chars, natural language) or `slug` (shorter, kebab-case) the right identifier? The post-exec gate needs both run-level AND task-level context -- what information hierarchy works? For finding-focused gates (P5 Security, P5 Issue), should the run title compete with the finding in `question` or layer differently?

## Context

### Current gate specifications

| Gate | header | Current `question` | Has run title? |
|------|--------|-------------------|----------------|
| P1 Team | "P1 Team" | `<1-sentence task summary>` | Partial (task summary, not run title) |
| P3.5 Review | "P3.5 Review" | `<1-sentence plan summary>` | Partial |
| P3 Impasse | "P3 Impasse" | disagreement description | No |
| P3.5 Plan | "P3.5 Plan" | `<orientation line goal summary>` | Partial |
| P4 Gate | "P4 Gate" | `Task N: <task title> -- DECISION` | No (task-level, not run-level) |
| Post-exec | "Post-exec" | "Post-execution phases for this task?" | No context at all |
| P4 Calibrate | "P4 Calibrate" | "5 consecutive approvals without changes. Gates well-calibrated?" | No |
| P5 Security | "P5 Security" | the one-sentence finding description | No |
| P5 Issue | "P5 Issue" | the one-sentence finding description from the brief | No |
| PR | "PR" | "Create PR for nefario/<slug>?" | Partial (slug) |
| Existing PR | "Existing PR" | "PR #N exists on this branch. Update its description with this run's changes?" | No |

### Key constraints
- AskUserQuestion `header` max: 12 characters
- `$summary` variable: up to 40 characters, natural language, established in Phase 1
- `slug` variable: kebab-case, max 40 chars, derived from task description
- Status line format: `⚗︎ P1 Meta-Plan | $summary`
- AskUserQuestion hides the status line when presented
- The user may have 2-3 parallel nefario sessions in different terminals

### Cognitive load considerations
- P1/P3.5 gates already partially include a task summary in `question`
- P4 Gate `question` already includes task-level title + decision text
- P5 gates focus on security findings -- the finding IS the decision context
- Post-exec gate has zero context (worst offender)
- Some gates show a structured card above the AskUserQuestion (e.g., the execution plan card)

## Instructions
1. Read the SKILL.md file at /Users/ben/github/benpeter/2despicable/3/skills/nefario/SKILL.md to see the full gate specifications and the visual hierarchy (card framing) that appears alongside the AskUserQuestion
2. Assess the cognitive load implications of different approaches
3. Consider: $summary vs slug, prefix vs suffix, information layering, which gates need the most vs least additional context
4. Address the post-exec gate specifically (needs both run-level AND task-level context)
5. For P5 gates: how to layer run context with finding-specific context
6. Return your contribution in this format:

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

7. Write your complete contribution to `/var/folders/3k/bfjvvz9s6dvdn_hvlhvr8lc00000gn/T//nefario-scratch-1zOJ65/gates-include-orchestration-title/phase2-ux-strategy-minion.md`
