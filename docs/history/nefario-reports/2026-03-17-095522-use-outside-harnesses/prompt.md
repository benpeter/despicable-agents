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
