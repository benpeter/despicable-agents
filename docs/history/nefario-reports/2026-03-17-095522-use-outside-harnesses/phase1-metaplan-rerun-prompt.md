MODE: META-PLAN

You are creating a revised meta-plan after a team adjustment.

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

## Original Meta-Plan
The following meta-plan was produced for the original team. Use it as context for the revised plan, not as a template to minimally edit.

Read the original meta-plan from: /var/folders/3k/bfjvvz9s6dvdn_hvlhvr8lc00000gn/T//nefario-scratch-kifrP8/use-outside-harnesses/phase1-metaplan.md

## Team Adjustment
Added: lucy. Removed: security-minion, ux-strategy-minion.

Revised team: ai-modeling-minion, gru, devx-minion, mcp-minion, software-docs-minion, lucy

## Constraints
- Keep the same scope and task description
- Preserve external skill integration decisions unless the team change removes all agents relevant to a skill's domain
- Generate planning consultations for ALL agents in the revised team
- Re-evaluate the cross-cutting checklist against the new team
- Produce output at the same depth and format as the original
- Do NOT change the fundamental scope of the task
- Do NOT add agents the user did not request (beyond cross-cutting requirements)
- Design planning questions as a coherent set — each question should address aspects that no other agent on the team covers, and questions should reference cross-cutting boundaries where relevant

## Instructions
1. Read the original meta-plan for context
2. Read relevant files to understand the codebase context
3. Generate planning consultations for ALL agents in the revised team
4. Re-evaluate the cross-cutting checklist against the new team
5. Return the revised meta-plan in the structured format
6. Write your complete revised meta-plan to `/var/folders/3k/bfjvvz9s6dvdn_hvlhvr8lc00000gn/T//nefario-scratch-kifrP8/use-outside-harnesses/phase1-metaplan-rerun.md`
