You are contributing to the PLANNING phase of a multi-agent project.
You are NOT executing yet — you are providing your domain expertise
to help build a comprehensive plan.

## Project Task
Every AskUserQuestion gate in the nefario orchestration SKILL.md must include the orchestration run title so the user always knows which run they're deciding on -- even when the status line is hidden by AskUserQuestion prompts. This is critical for parallel nefario sessions in different terminals.

The issue provides a full audit of 11 gates, showing which currently have run context and which don't.

## Your Planning Question
12 AskUserQuestion gates in SKILL.md need to consistently include the orchestration run title so users in parallel nefario sessions can identify which run they are deciding on. The `header` is capped at 12 chars. The `$summary` is up to 40 chars. Some `question` fields are already long (e.g., P4 Gate includes "Task N: <task title> -- DECISION"). What convention (prefix/suffix, delimiter, truncation) keeps questions scannable across all 12 gate types?

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
- `$summary` variable: up to 40 characters, established in Phase 1, preserved across compaction
- Some `question` fields are already multi-line or include structured content
- Gates must remain visually distinguishable from each other (phase prefix helps)
- The convention must work for ALL 12 gates, not just the worst offenders

### The `$summary` variable
Defined in SKILL.md lines 389-391:
"Extract a status summary from the first line of the user's task description. Truncate to 40 characters; if truncated, append '...'"

The status line uses it as: `⚗︎ P1 Meta-Plan | $summary`

## Instructions
1. Read the SKILL.md file at /Users/ben/github/benpeter/2despicable/3/skills/nefario/SKILL.md to see the full gate specifications in context
2. Apply your CLI interaction design expertise to propose a convention
3. Consider: prefix vs suffix, delimiter choice, truncation strategy when question + summary is too long
4. Show how the convention applies to each of the 12 gates (before/after)
5. Address the post-exec gate specifically (needs both run-level AND task-level context)
6. Return your contribution in this format:

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

7. Write your complete contribution to `/var/folders/3k/bfjvvz9s6dvdn_hvlhvr8lc00000gn/T//nefario-scratch-1zOJ65/gates-include-orchestration-title/phase2-devx-minion.md`
