You are contributing to the PLANNING phase of a multi-agent project.
You are NOT executing yet — you are providing your domain expertise
to help build a comprehensive plan.

## Project Task

Document the /despicable-statusline skill in the project's docs so that users understand what it does, when to use it, and what it modifies before invoking it.

Success criteria:
- Skill is listed in relevant project documentation (README or docs/)
- Documentation explains what the skill does, what it modifies (~/.claude/settings.json), and the four config states it handles
- Documentation mentions idempotency and safety (backup/rollback)

Scope:
- In: Project-level documentation for the skill (README, docs/)
- Out: Changes to the SKILL.md itself, changes to nefario's SKILL.md, statusline styling

## Your Planning Question

How should we present the four config states (no statusLine, inline without nefario, already configured, non-standard/script file), safety properties (backup, rollback, idempotency), and the relationship between manual setup and the automated skill? What level of detail is right -- before/after examples of settings.json, or higher-level descriptions?

## Context

The skill (.claude/skills/despicable-statusline/SKILL.md) handles four states:
- State A: No statusLine configured -- sets full default command
- State B: Inline statusLine without nefario snippet -- appends snippet before final echo
- State C: Already has nefario snippet -- idempotent no-op
- State D: Non-standard/script-file statusLine -- cannot auto-modify, prints manual instructions

Safety measures:
- Validates JSON before and after modification
- Creates backup at ~/.claude/settings.json.backup-statusline
- Restores from backup if post-write validation fails
- Requires jq

The existing manual setup section in docs/using-nefario.md (lines 166-198) provides a JSON snippet users can paste manually. The skill automates this. We need to reconcile both approaches in the docs.

Target audience: Developers who have installed despicable-agents and want nefario status in their Claude Code status line.

## Instructions
1. Read relevant files to understand the current state
2. Apply your domain expertise to the planning question
3. Identify risks, dependencies, and requirements from your perspective
4. If you believe additional specialists should be involved that
   aren't already part of the planning, say so and explain why
5. Return your contribution in this format:

## Domain Plan Contribution: user-docs-minion

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
6. Write your complete contribution to `/var/folders/3k/bfjvvz9s6dvdn_hvlhvr8lc00000gn/T//nefario-scratch-6Op9Al/add-despicable-statusline-docs/phase2-user-docs-minion.md`
