You are contributing to the PLANNING phase of a multi-agent project.
You are NOT executing yet — you are providing your domain expertise
to help build a comprehensive plan.

## Project Task

<github-issue>
**Outcome**: Nefario prepends the alembic symbol (⚗️) to its status line display and all user-facing messages during orchestration sessions, giving it a distinctive visual identity that users instantly associate with "nefario is orchestrating."

**Success criteria**:
- Status line entry includes ⚗️ prefix (using text variant ⚗︎ where monospace alignment matters)
- All nefario phase announcements and user-facing messages are prefixed with ⚗️
- Symbol renders correctly in macOS Terminal, VS Code integrated terminal, and iTerm2
- No alignment or double-width issues in the Claude Code status line

**Scope**:
- In: Nefario skill (SKILL.md), nefario agent (AGENT.md), status line config (despicable-statusline skill)
- Out: Other agents' messaging, emoji/symbols for lucy/margo/minions, terminal compatibility testing beyond macOS

**Constraints**:
- Symbol is ⚗️ (U+2697, Alembic) — decided via team brainstorm with lucy, ux-strategy-minion, ux-design-minion
- Use text variant selector (⚗︎ / U+2697 U+FE0E) in monospace/status-line contexts to avoid 2-cell width
</github-issue>

## Your Planning Question

The alembic symbol will prefix nefario's status line, phase announcements, and user-facing messages. Review the full set of user-facing nefario outputs (phase markers, CONDENSE lines, AskUserQuestion headers, gate briefs) and advise: should ALL of these get the prefix, or only a subset? What is the right balance between "distinctive identity" and "visual noise" in a fast-scrolling terminal during multi-phase orchestrations?

## Context

Key files to review:
- `skills/nefario/SKILL.md` — contains all user-facing output patterns:
  - Phase markers: `**--- Phase N: Name ---**`
  - CONDENSE lines: `Planning: consulting ...`, `Review: N APPROVE, N BLOCK`, `Verifying: ...`
  - AskUserQuestion headers: "P1 Team", "P3.5 Review", "P3.5 Plan", "P4 Gate", etc.
  - Gate briefs: TEAM, EXECUTION PLAN, APPROVAL GATE, REVIEWERS, etc.
  - Status file writes: `echo "P1 Meta-Plan | $summary" > /tmp/nefario-status-$SID`
- The Communication Protocol section defines what is SHOW, NEVER SHOW, and CONDENSE
- The Visual Hierarchy section defines weight levels: Decision, Orientation, Advisory, Inline

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
6. Write your complete contribution to `/var/folders/3k/bfjvvz9s6dvdn_hvlhvr8lc00000gn/T//nefario-scratch-h34Soi/alembic-nefario-status-prefix/phase2-ux-strategy-minion.md`
