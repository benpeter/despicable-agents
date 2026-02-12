You are contributing to the PLANNING phase of a multi-agent project.
You are NOT executing yet — you are providing your domain expertise
to help build a comprehensive plan.

## Project Task

**Outcome**: Before nefario dispatches specialists for planning, the user sees which agents were selected and can approve, adjust, or veto the team composition. This prevents wasted compute on specialists the user considers irrelevant and gives the user visibility into orchestration decisions early.

**Success criteria**:
- After Phase 2 team selection, nefario presents the chosen specialists with rationale before proceeding
- User can approve the team as-is, remove specialists, or add specialists not initially selected
- Phase 2 does not proceed to specialist dispatch until the user confirms
- Existing Phase 3.5 architecture review gate continues to work unchanged

**Scope**:
- In: Nefario SKILL.md orchestration flow, Phase 2 team selection logic, approval gate UX
- Out: Phase 3.5 review gate changes, agent AGENT.md files, the-plan.md, adding new agents

## Your Planning Question

Where exactly in SKILL.md does the gate insert, what data is extracted from the meta-plan output, how are response options handled (especially "add agent" from 27 possible agents), what happens to the CONDENSE line, and how does docs/orchestration.md need to update?

## Context

The nefario orchestration is defined in `skills/nefario/SKILL.md` (symlinked to `~/.claude/skills/nefario/SKILL.md`). The current flow is: Phase 1 (meta-plan) identifies specialists, then Phase 2 immediately spawns those specialists in parallel for planning contributions. The CONDENSE line for Phase 1 currently reads: "Planning: consulting devx-minion, security-minion, ... | Skills: N discovered | Scratch: <path>". Documentation is at `docs/orchestration.md`.

## Instructions
1. Read relevant files to understand the current state
2. Apply your domain expertise to the planning question
3. Identify risks, dependencies, and requirements from your perspective
4. If you believe additional specialists should be involved that
   aren't already part of the planning, say so and explain why
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

6. Write your complete contribution to `/var/folders/3k/bfjvvz9s6dvdn_hvlhvr8lc00000gn/T//nefario-scratch-ymv695/add-user-approval-gate-phase2-team-selection/phase2-devx-minion.md`
