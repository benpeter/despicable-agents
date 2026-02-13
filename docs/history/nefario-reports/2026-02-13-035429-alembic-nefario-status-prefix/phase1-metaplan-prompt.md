MODE: META-PLAN

You are creating a meta-plan — a plan for who should help plan.

## Task

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

## Working Directory
/Users/ben/github/benpeter/2despicable/2

## External Skill Discovery
Before analyzing the task, scan for project-local skills. If skills are
discovered, include an "External Skill Integration" section in your meta-plan
(see your Core Knowledge for the output format).

## Instructions
1. Read relevant files to understand the codebase context
2. Discover external skills:
   a. Scan .claude/skills/ and .skills/ in the working directory for SKILL.md files
   b. Read frontmatter (name, description) for each discovered skill
   c. For skills whose description matches the task domain, classify as
      ORCHESTRATION or LEAF (see External Skill Integration in your Core Knowledge)
   d. Check the project's CLAUDE.md for explicit skill preferences
   e. Include discovered skills in your meta-plan output
3. Analyze the task against your delegation table
4. Identify which specialists should be CONSULTED FOR PLANNING
   (not execution — planning). These are agents whose domain
   expertise is needed to create a good plan.
5. For each specialist, write a specific planning question that
   draws on their unique expertise.
6. Return the meta-plan in the structured format.
7. Write your complete meta-plan to `/var/folders/3k/bfjvvz9s6dvdn_hvlhvr8lc00000gn/T//nefario-scratch-h34Soi/alembic-nefario-status-prefix/phase1-metaplan.md`
