Two deliverables building on the external harness integration feasibility study (docs/external-harness-integration.md):

**Deliverable 1: Iterate on the research report** with the following user feedback:

1. CONFIGURATION GAP: The report doesn't adequately cover how the user would specify which tasks to delegate to Codex (and in the future others). The DX of routing configuration needs more depth -- how does a user say "send this agent to Codex, that one to Aider"?

2. MODEL SPECIFICATION: Users should be able to specify which models external harnesses use, just as they currently specify model: opus/sonnet in AGENT.md frontmatter. The report should address how model specification maps across tools.

3. WORKTREE ISOLATION: Per-delegation worktree isolation (Open Question 2) may be the only viable approach for concurrent external tool execution. Note that concurrent Claude Code agents already have the same filesystem concurrency issue -- this isn't unique to external harnesses. The alternative is creating concurrency awareness through delegation prompts (telling each tool which files it owns). Address this more definitively.

4. QUALITY PARITY: Open Question 3 (model quality parity) -- this is the user's responsibility, not the orchestrator's. But the framework should let users specify models, which ties back to point 2.

5. AIDER RESULT COLLECTION: Open Question 5 asks about result collection without structured output. If LLM-based diff summarization is the only option for tools like Aider, then accept the cost and latency tradeoff. State this as the answer, not as an open question.

Update the report in place at docs/external-harness-integration.md. Resolve or downgrade the open questions that the user answered. Add the missing configuration/routing DX content.

**Deliverable 2: Codex-first roadmap**

Create a sequenced roadmap document for executing on the Codex CLI delegation path. This should:
- Be a series of issues/milestones in logical execution order
- Keep the design extensible for adding other tools later (Aider, Gemini CLI)
- Cover: adapter implementation, configuration format, instruction translation, result collection, testing strategy, integration with nefario Phase 4
- Live in a sensible location under docs/
- Be formatted so GitHub issues can be easily created from it later (title + description per issue)

Scope:
- In: Report iteration with user feedback, Codex-first roadmap document
- Out: Changing nefario orchestrator code, building any adapters
