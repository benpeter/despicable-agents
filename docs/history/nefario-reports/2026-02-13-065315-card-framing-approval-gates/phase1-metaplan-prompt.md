MODE: META-PLAN

You are creating a meta-plan — a plan for who should help plan.

## Task

<github-issue>
**Outcome**: Approval gates are visually distinct from surrounding tool output by using inline code spans (backticks) on structural lines, leveraging Claude Code's built-in code highlight color to create card-like separation without any special markdown extensions or rendering features.

**Success criteria**:
- Gate header line uses backtick-wrapped text with box-drawing dash (─) border
- All CAPS-LABEL field names (DECISION:, DELIVERABLE:, RATIONALE:, IMPACT:, Confidence:) are backtick-wrapped
- Closing border line uses backtick-wrapped box-drawing dashes
- Visual Hierarchy table in SKILL.md updated to reflect the new Decision weight pattern
- Gate renders as a visually coherent card in Claude Code terminal output

**Scope**:
- In: SKILL.md approval gate template, Visual Hierarchy table description for Decision weight
- Out: Phase announcement formatting, compaction checkpoint formatting, AskUserQuestion prompts, non-SKILL.md documentation

**Constraints**:
- Only inline code spans (backticks) and box-drawing characters -- no markdown extensions, no special rendering
</github-issue>

---
Additional context: consider all approvals given, skip test and security post-exec phases. Include user-docs-minion, software-docs-minion, and product-marketing-minion in the roster. Work all through to PR creation without interactions.

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
7. Write your complete meta-plan to `/var/folders/3k/bfjvvz9s6dvdn_hvlhvr8lc00000gn/T//nefario-scratch-mq2F9b/card-framing-approval-gates/phase1-metaplan.md`
