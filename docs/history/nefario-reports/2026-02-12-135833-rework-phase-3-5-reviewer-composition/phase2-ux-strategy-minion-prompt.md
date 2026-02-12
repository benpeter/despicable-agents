You are contributing to the PLANNING phase of a multi-agent project.
You are NOT executing yet — you are providing your domain expertise
to help build a comprehensive plan.

## Project Task

<github-issue>
**Outcome**: Phase 3.5 Architecture Review uses a smaller mandatory roster (5 ALWAYS) and a discretionary pool (6 conditional reviewers) selected by nefario and approved by the user before spawning. This reduces wasted compute on irrelevant reviews, gives the user control over reviewer composition, and aligns 3.5 with the same approval gate pattern introduced in Phase 2 (#48).

**Success criteria**:
- ALWAYS roster is exactly: security-minion, test-minion, software-docs-minion, lucy, margo
- Discretionary pool is exactly: ux-strategy-minion, ux-design-minion, accessibility-minion, sitespeed-minion, observability-minion, user-docs-minion
- Nefario presents discretionary picks with one-line rationale each; user approves before spawning
- software-docs-minion 3.5 role narrowed to documentation impact checklist (not full review)
- Phase 8 documentation phase consumes the 3.5 checklist as its work order
- test-minion remains ALWAYS with unchanged behavior
- All changes reflected in nefario AGENT.md, SKILL.md, and docs/orchestration.md

**Scope**:
- In: Phase 3.5 reviewer triggering rules, ALWAYS/conditional roster, software-docs-minion 3.5 role, Phase 8 checklist handoff, nefario AGENT.md, SKILL.md, orchestration docs
- Out: Phase 2 approval gate (handled by #48), reviewer agent AGENT.md files, the-plan.md, Phase 5/6 post-execution phases

**Constraints**:
- Depends on #48 (Phase 2 approval gate) — both introduce the same user-approval-before-spawning pattern
- Analysis at nefario/scratch/phase3.5-team-composition-analysis.md
</github-issue>

---
Additional context: use opus for all agents and tasks

## Your Planning Question

Phase 3.5 currently spawns 6 mandatory reviewers unconditionally. We are splitting this into 5 ALWAYS reviewers and 6 discretionary reviewers that nefario picks and the user approves before spawning. The Phase 2 Team Approval Gate (PR #51, merged) established a pattern: compact presentation (8-12 lines), freeform adjust, 3 options (Approve/Adjust/Reject). Should the Phase 3.5 reviewer gate reuse that exact pattern, or does the reviewer selection context warrant a different interaction model? Consider: the user has already approved one team (Phase 2); this is a second "who participates" gate in the same session. How do we avoid approval fatigue from two team-composition gates while still giving meaningful control? What is the right information density for presenting discretionary picks with one-line rationale?

## Context

Read these files for context:
- `skills/nefario/SKILL.md` — Team Approval Gate section and Phase 3.5 section
- `docs/orchestration.md` — Phase 3.5 section and Team Approval Gate section

## Instructions
1. Read relevant files to understand the current state
2. Apply your domain expertise to the planning question
3. Identify risks, dependencies, and requirements from your perspective
4. If you believe additional specialists should be involved that
   aren't already part of the planning, say so and explain why
5. Return your contribution in this format:

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
6. Write your complete contribution to `/var/folders/3k/bfjvvz9s6dvdn_hvlhvr8lc00000gn/T//nefario-scratch-1CcD5T/rework-phase-3-5-reviewer-composition/phase2-ux-strategy-minion.md`
