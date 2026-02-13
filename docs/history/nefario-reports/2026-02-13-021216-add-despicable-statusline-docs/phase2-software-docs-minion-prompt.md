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

Given the existing docs tree (architecture.md with its Sub-Documents table, deployment.md with a "Skills" section, using-nefario.md with a manual "Status Line" section at lines 166-198), where should /despicable-statusline be documented? Own page in docs/, additions to existing pages, or both? How do we reconcile the existing manual setup instructions in using-nefario.md with the new automated skill documentation?

## Context

Key existing docs structure:
- docs/architecture.md -- has Sub-Documents tables (User-Facing + Contributor)
- docs/deployment.md -- has "Skills" section mentioning /nefario and /despicable-prompter
- docs/using-nefario.md -- has "Status Line" section (lines 166-198) with manual setup instructions
- README.md -- mentions "2 skills (/nefario, /despicable-prompter)" in Install section
- .claude/skills/despicable-statusline/SKILL.md -- the skill itself (4 config states: A-D)

The skill is project-local (in .claude/skills/), not globally installed via install.sh.

## Instructions
1. Read relevant files to understand the current state
2. Apply your domain expertise to the planning question
3. Identify risks, dependencies, and requirements from your perspective
4. If you believe additional specialists should be involved that
   aren't already part of the planning, say so and explain why
5. Return your contribution in this format:

## Domain Plan Contribution: software-docs-minion

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
6. Write your complete contribution to `/var/folders/3k/bfjvvz9s6dvdn_hvlhvr8lc00000gn/T//nefario-scratch-6Op9Al/add-despicable-statusline-docs/phase2-software-docs-minion.md`
