MODE: META-PLAN

You are creating a meta-plan — a plan for who should help plan.

## Task

<github-issue>
**Outcome**: Nefario's orchestration messages (phase transitions, approval gates, status updates) are visually distinct from tool output and easy to follow. Approval gates present clear, meaningful links to relevant artifacts instead of raw scratch directory paths, so the user understands what to review and where to find it without needing to know internal directory structures.

**Success criteria**:
- Phase transition announcements are restored and visible to the user
- Nefario orchestration messages are visually distinguishable from tool output at a glance
- Approval gate messages use meaningful labels (e.g., "Review specialist contributions (phase2-*.md)") instead of raw scratch directory paths
- Highlighting approach works within Claude Code's actual text rendering capabilities (monospace terminal, CommonMark markdown)
- No regression in useful output suppression rules (raw tool dumps, verbose git output, etc. stay suppressed)

**Scope**:
- In: SKILL.md communication protocol / output discipline sections, approval gate message formatting, scratch directory reference presentation, phase transition announcements
- Out: Subagent output formatting, tool output suppression rules unrelated to nefario messages, AGENT.md changes, scratch directory structure itself
</github-issue>

---
Additional context: consider all approvals given, skip test and security post-exec phases. Include user docs, software docs and product marketing in the roster. Rely on ux-design-minion and ux-strategy-minion to figure the way to highlight.

## Working Directory
/Users/ben/github/benpeter/2despicable/3

## External Skill Discovery
Before analyzing the task, scan for project-local skills. If skills are discovered, include an "External Skill Integration" section in your meta-plan (see your Core Knowledge for the output format).

Project-local skills found:
- .claude/skills/despicable-lab/SKILL.md
- .claude/skills/despicable-statusline/SKILL.md

## Instructions
1. Read relevant files to understand the codebase context
2. Discover external skills:
   a. Scan .claude/skills/ and .skills/ in the working directory for SKILL.md files
   b. Read frontmatter (name, description) for each discovered skill
   c. For skills whose description matches the task domain, classify as ORCHESTRATION or LEAF
   d. Check the project's CLAUDE.md for explicit skill preferences
   e. Include discovered skills in your meta-plan output
3. Analyze the task against your delegation table
4. Identify which specialists should be CONSULTED FOR PLANNING (not execution — planning). These are agents whose domain expertise is needed to create a good plan.
5. For each specialist, write a specific planning question that draws on their unique expertise.
6. Return the meta-plan in the structured format.
7. Write your complete meta-plan to `/var/folders/3k/bfjvvz9s6dvdn_hvlhvr8lc00000gn/T//nefario-scratch-nizNjj/restore-phase-announcements-improve-visibility/phase1-metaplan.md`

IMPORTANT: The user explicitly requested these specialists be included in the roster: user-docs-minion, software-docs-minion, product-marketing-minion, ux-design-minion, ux-strategy-minion. Make sure they are in the SELECTED list.
