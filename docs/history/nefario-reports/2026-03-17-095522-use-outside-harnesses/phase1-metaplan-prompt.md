MODE: META-PLAN

You are creating a meta-plan — a plan for who should help plan.

## Task
<github-issue>
**Outcome**: The team has a thorough research report on whether and how the despicable-agents orchestrating session can delegate tasks to external LLM coding tools (Cursor, Aider, Codex CLI, etc.) the same way it currently delegates to Claude Code subagents — so that the framework is not locked to a single harness and can route specialist work to the best available tool.

**Success criteria**:
- Inventory of LLM coding tools and their context-injection mechanisms (how each consumes system prompts, project instructions, file context)
- Analysis of how AGENT.md knowledge maps to each tool's instruction format (CLAUDE.md, .cursorrules, .aider.conf, etc.)
- Feasibility assessment: can a delegation wrapper start an external tool, inject agent knowledge, and collect results back to the orchestrating session
- Gap analysis: what the current Agent tool provides (background execution, result playback) vs. what a wrapper can replicate
- Clear recommendation: feasible now / feasible with constraints / not yet feasible — with rationale
- Research written to a new doc under `docs/`

**Scope**:
- In: LLM coding tools (CLI and otherwise), context/instruction injection mechanisms, delegation patterns, AGENT.md-to-foreign-format mapping, result collection, inter-agent protocols
- Out: Changing the nefario orchestrator itself, building the actual delegation wrapper
</github-issue>

## Working Directory
/Users/ben/github/benpeter/despicable-agents/.claude/worktrees/use-outside-harnesses

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
7. Write your complete meta-plan to `/var/folders/3k/bfjvvz9s6dvdn_hvlhvr8lc00000gn/T//nefario-scratch-kifrP8/use-outside-harnesses/phase1-metaplan.md`
