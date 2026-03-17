MODE: META-PLAN

You are creating a meta-plan — a plan for who should help plan.

## Task

Two deliverables building on the external harness integration feasibility study (docs/external-harness-integration.md):

**Deliverable 1: Iterate on the research report** with user feedback:
1. CONFIGURATION GAP: How does the user specify which tasks to delegate to Codex vs others? Routing configuration DX needs more depth.
2. MODEL SPECIFICATION: Users must be able to specify which models external harnesses use, mapping to current model: frontmatter pattern.
3. WORKTREE ISOLATION: Per-delegation worktree isolation is likely the only viable approach. Note concurrent Claude Code agents have the same issue. Alternative: concurrency awareness through prompts. Address definitively.
4. QUALITY PARITY: User's responsibility, but framework should let users specify models (ties to point 2).
5. AIDER RESULT COLLECTION: LLM-based diff summarization is the answer if it's the only option. Accept cost/latency. State as answer, not open question.

Update docs/external-harness-integration.md in place.

**Deliverable 2: Codex-first roadmap**
- Sequenced issues/milestones for Codex CLI delegation path
- Extensible for future tools (Aider, Gemini CLI)
- Cover: adapter, config format, instruction translation, result collection, testing, nefario Phase 4 integration
- Formatted for easy GitHub issue creation (title + description per issue)
- Location: sensible place under docs/

Scope:
- In: Report iteration, roadmap document
- Out: Changing nefario, building adapters

## Working Directory
/Users/ben/github/benpeter/despicable-agents/.claude/worktrees/use-outside-harnesses

## External Skill Discovery
Scan .claude/skills/ for SKILL.md files. Previous run found 4 skills, none relevant.

## Instructions
1. Read docs/external-harness-integration.md to understand the current report
2. Analyze the task against your delegation table
3. Reuse the same team from the previous run: ai-modeling-minion, gru, devx-minion, mcp-minion, software-docs-minion, lucy
4. Generate planning questions for all 6 agents focused on the new deliverables
5. Write your complete meta-plan to /var/folders/3k/bfjvvz9s6dvdn_hvlhvr8lc00000gn/T//nefario-scratch-EeXHH5/harness-iteration-roadmap/phase1-metaplan.md
