MODE: META-PLAN

You are creating a meta-plan — a plan for who should help plan.

## Task

<github-issue>
**Outcome**: The compaction flow no longer asks for permission before generating the compaction prompt. Instead, it always generates the prompt, copies it to the clipboard, and tells the user to paste it back to compact or type "continue" to skip. This eliminates a redundant confirmation step and makes the flow self-service. Additionally, the post-compaction continuation instruction is clarified: the user queues "continue" immediately (it executes once compaction finishes), rather than the misleading "type continue once you are ready."

**Success criteria**:
- Compaction prompt is always generated and copied to clipboard without asking first
- User message clearly says: paste to compact, or type "continue" to skip
- Post-compaction instruction tells user to queue "continue" (not "type once ready")
- No behavioral regression in the orchestration phases that follow compaction

**Scope**:
- In: Compaction flow logic and user-facing messages in the nefario skill
- Out: Compaction prompt content/quality, other nefario phases, Claude Code clipboard internals
</github-issue>

## Working Directory
/Users/ben/github/benpeter/despicable-agents

## External Skill Discovery
Before analyzing the task, scan for project-local skills. If skills are
discovered, include an "External Skill Integration" section in your meta-plan
(see your Core Knowledge for the output format).

Project-local skills found in .claude/skills/:
- despicable-lab
- despicable-prompter
- despicable-statusline

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
7. Write your complete meta-plan to /var/folders/3k/bfjvvz9s6dvdn_hvlhvr8lc00000gn/T//nefario-scratch-8uolGq/streamline-compaction-ux-clipboard-first/phase1-metaplan.md
