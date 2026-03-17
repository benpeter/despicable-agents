MODE: SYNTHESIS

You are synthesizing specialist planning contributions into a
final execution plan.

## Original Task
Research whether and how the despicable-agents orchestrating session can delegate tasks to external LLM coding tools (Cursor, Aider, Codex CLI, etc.) the same way it currently delegates to Claude Code subagents — so that the framework is not locked to a single harness and can route specialist work to the best available tool. The deliverable is a research report under docs/.

Success criteria:
1. Inventory of LLM coding tools and their context-injection mechanisms
2. Analysis of how AGENT.md knowledge maps to each tool's instruction format
3. Feasibility assessment: can a delegation wrapper start an external tool, inject agent knowledge, and collect results
4. Gap analysis: what the current Agent tool provides vs. what a wrapper can replicate
5. Clear recommendation: feasible now / feasible with constraints / not yet feasible
6. Research written to a new doc under docs/

## Specialist Contributions

Read the following scratch files for full specialist contributions:
- /var/folders/3k/bfjvvz9s6dvdn_hvlhvr8lc00000gn/T//nefario-scratch-kifrP8/use-outside-harnesses/phase2-ai-modeling-minion.md
- /var/folders/3k/bfjvvz9s6dvdn_hvlhvr8lc00000gn/T//nefario-scratch-kifrP8/use-outside-harnesses/phase2-gru.md
- /var/folders/3k/bfjvvz9s6dvdn_hvlhvr8lc00000gn/T//nefario-scratch-kifrP8/use-outside-harnesses/phase2-devx-minion.md
- /var/folders/3k/bfjvvz9s6dvdn_hvlhvr8lc00000gn/T//nefario-scratch-kifrP8/use-outside-harnesses/phase2-mcp-minion.md
- /var/folders/3k/bfjvvz9s6dvdn_hvlhvr8lc00000gn/T//nefario-scratch-kifrP8/use-outside-harnesses/phase2-software-docs-minion.md
- /var/folders/3k/bfjvvz9s6dvdn_hvlhvr8lc00000gn/T//nefario-scratch-kifrP8/use-outside-harnesses/phase2-lucy.md

## Key consensus across specialists:

ai-modeling-minion: Current subagent contract has 5 interface points mapping to 3 coordination patterns. Critical area is instruction format translation (AGENT.md → foreign formats). Biggest gap is result collection fidelity.

gru: Landscape surprisingly ready -- 6+ tools feasible today with convergence on headless invocation, instruction formats (AGENTS.md), and auto-approve. Hard problem is result collection, not invocation. Rings: Adopt (Claude Code), Trial (Codex CLI, Aider, Gemini CLI, Copilot CLI, Cline CLI), Assess (Continue, Goose, Kilo, Amp, Cursor CLI), Hold (Windsurf).

devx-minion: Wrapper should be transparent facade with harnesses.toml config. Two instruction channels per tool (persistent + per-task). Three-component error messages. Zero-config defaults to Claude Code.

mcp-minion: MCP wrong layer for delegation (short tool calls, not coding tasks). A2A closer but zero adoption. MCP valuable at context sharing layer. Report should model 3-layer stack: Process Invocation, Context Sharing, Orchestration Protocol.

software-docs-minion: File at docs/external-harness-integration.md. Feasibility study format with sections: Problem Statement, Current Delegation Model, Tool Inventory, Integration Surface, Comparison Matrix, Feasibility Assessment, Recommendations, Out of Scope, Open Questions. Lead with problem not tools.

lucy: Two traceability gaps (recommendation needs explicit owner; gap analysis needs structured table). Four drift risks (questions lean design not research; MCP advocacy bias; security/UX without specialist depth). Synthesis must correct framing from "how to build" to "is it feasible."

## External Skills Context
No external skills detected relevant to this task.

## Instructions
1. Review all specialist contributions
2. Resolve any conflicts between recommendations
3. Incorporate risks and concerns into the plan
4. Create the final execution plan in structured format
5. Ensure every task has a complete, self-contained prompt
6. CRITICAL: Heed lucy's scope drift warnings. The execution plan must produce a RESEARCH REPORT (feasibility study), not a design document. Frame all task prompts around "what exists, what's possible, what are the gaps" rather than "how to build it." Each task prompt must include an explicit scope guard: "This is a research task. Document what exists and assess feasibility. Do not produce implementation designs, architecture proposals, or code."
7. The report deliverable is a single file at docs/external-harness-integration.md
8. Success criterion 5 (the feasibility recommendation) must have an explicit owner task
9. Success criterion 4 (gap analysis) must produce a structured comparison table
10. Write your complete delegation plan to `/var/folders/3k/bfjvvz9s6dvdn_hvlhvr8lc00000gn/T//nefario-scratch-kifrP8/use-outside-harnesses/phase3-synthesis.md`
