You are contributing to the PLANNING phase of a multi-agent project.
You are NOT executing yet — you are providing your domain expertise
to help build a comprehensive plan.

## Project Task
Every AskUserQuestion gate in the nefario orchestration SKILL.md must include the orchestration run title so the user always knows which run they're deciding on -- even when the status line is hidden by AskUserQuestion prompts. This is critical for parallel nefario sessions in different terminals.

## Your Planning Question
The SKILL.md file is a ~2000-line system prompt that the LLM orchestrator follows to construct AskUserQuestion calls. The `question` field is a template with variables like `$summary`, `<task title>`, etc. that the orchestrator resolves at runtime. How should the run-title injection be specified as a template convention that the LLM can follow consistently across 12 different gate types? Consider: should it be a single "Run Title Convention" section referenced by all gates, or should each gate's spec be updated individually? What variable name and interpolation pattern will be least error-prone for LLM execution?

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

### How the SKILL.md works as a prompt
- SKILL.md is loaded as part of the system prompt for the Claude Code main session
- The orchestrator follows it step by step, constructing AskUserQuestion tool calls
- Variables like `$summary` and `<slug>` are resolved by the LLM, not a template engine
- The `$summary` variable is established in Phase 1 and referenced via "retain in session context" instructions
- The LLM must remember to include the run title in every gate -- there's no enforcement mechanism beyond the spec

### Key constraints
- AskUserQuestion `header` max: 12 characters
- `$summary` variable: up to 40 characters, natural language
- The spec should be DRY -- avoid repeating the convention 12 times if a cross-reference works
- LLM reliability: the convention must be clear enough that the LLM doesn't forget or misformat

## Instructions
1. Read the SKILL.md file at /Users/ben/github/benpeter/2despicable/3/skills/nefario/SKILL.md to understand how it functions as an LLM-executable specification
2. Apply your prompt engineering expertise to propose a template convention
3. Consider: centralized definition vs. per-gate specs, variable naming, interpolation patterns
4. Address LLM reliability -- how to ensure the convention is followed consistently
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

7. Write your complete contribution to `/var/folders/3k/bfjvvz9s6dvdn_hvlhvr8lc00000gn/T//nefario-scratch-1zOJ65/gates-include-orchestration-title/phase2-ai-modeling-minion.md`
