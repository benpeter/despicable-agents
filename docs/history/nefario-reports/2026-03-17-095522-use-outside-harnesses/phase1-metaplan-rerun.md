# Phase 1: Meta-Plan (Revised)

## Task Summary

Research whether and how the despicable-agents orchestrating session can delegate tasks to external LLM coding tools (Cursor, Aider, Codex CLI, etc.) the same way it currently delegates to Claude Code subagents. The deliverable is a thorough research report under `docs/`, not implementation.

## Team Adjustment

**Added**: lucy (governance -- intent alignment, convention enforcement)
**Removed**: security-minion, ux-strategy-minion

**Revised team**: ai-modeling-minion, gru, devx-minion, mcp-minion, software-docs-minion, lucy

**Rationale for adjustment**: The user removed security-minion and ux-strategy-minion from the planning team. Security and UX considerations remain noted in the cross-cutting checklist (see below) but will not have dedicated planning consultations. Lucy is added to ensure the research stays aligned with the original intent (harness-agnostic delegation) and does not drift toward implementation, tool advocacy, or scope expansion.

## Meta-Plan

### Planning Consultations

#### Consultation 1: Multi-Agent Architecture and Delegation Abstractions
- **Agent**: ai-modeling-minion
- **Planning question**: The current delegation mechanism is tightly coupled to Claude Code's `Task` tool (subagent spawning with `subagent_type`, prompt injection, result playback). What abstraction layer would be needed to generalize delegation to external LLM coding tools? Specifically: (1) What are the key interface points in the current subagent contract (prompt delivery, context injection, file access, result collection, error handling)? (2) How do these map to known multi-agent coordination patterns (A2A, MCP tool-use, CLI wrappers)? (3) What research areas should the report cover regarding prompt/instruction format translation (AGENT.md -> .cursorrules, .aider.conf, etc.)? (4) What are the fundamental constraints of the current Claude Code delegation model that a wrapper must replicate or work around?
- **Context to provide**: `skills/nefario/SKILL.md` (Phase 4 execution loop, subagent spawning pattern), `nefario/AGENT.md` (delegation model), `docs/orchestration.md` (nine-phase architecture), `docs/agent-anatomy.md` (AGENT.md structure including frontmatter schema and five-section template)
- **Why this agent**: ai-modeling-minion is the expert on multi-agent architectures, prompt engineering, and system prompt design. The core question -- whether AGENT.md knowledge can be faithfully translated to foreign instruction formats -- is fundamentally a prompt engineering and agent architecture question. This agent covers the architecture-level analysis that no other team member addresses.

#### Consultation 2: Technology Landscape and Tool Maturity Assessment
- **Agent**: gru
- **Planning question**: What is the current landscape of LLM coding tools that could serve as delegation targets? For each major tool (Cursor, Aider, Codex CLI, Windsurf, Cline, Continue, Copilot CLI, and any emerging tools), assess: (1) CLI/API availability for programmatic invocation (can it be started headless?), (2) context/instruction injection mechanisms (system prompts, project rules, file context), (3) result collection capabilities (structured output, exit codes, file diffs), (4) maturity level (adopt/trial/assess/hold), (5) openness of the instruction format. What tools are feasible delegation targets today vs. which require waiting? Note: security implications of cross-tool trust boundaries and credential sharing are out of scope for this consultation -- focus on capability inventory and maturity.
- **Context to provide**: `gru/AGENT.md` (technology radar framework), the task description with scope boundaries
- **Why this agent**: gru is the technology landscape analyst. The inventory of LLM coding tools and their maturity assessment is squarely in gru's domain. The adopt/trial/assess/hold framework provides the right lens for evaluating each tool's readiness as a delegation target. No other team member covers tool landscape analysis.

#### Consultation 3: Developer Experience of the Delegation Wrapper
- **Agent**: devx-minion
- **Planning question**: If a delegation wrapper is built to start external tools, inject agent knowledge, and collect results, what should the developer experience look like? Consider: (1) How should the wrapper be invoked (CLI subcommand, config-driven, transparent to the orchestrator)? (2) What configuration format maps AGENT.md fields to foreign tool instruction formats? (3) What does the error experience look like when an external tool fails or produces unexpected output? (4) What should the report cover regarding DX of the wrapper interface? Note: protocol-level interoperability (MCP, A2A) is covered by mcp-minion -- focus on the human-facing configuration and invocation layer.
- **Context to provide**: `docs/agent-anatomy.md` (AGENT.md structure, frontmatter schema), `install.sh` (current deployment model), `docs/external-skills.md` (how external skills are discovered and integrated)
- **Why this agent**: devx-minion specializes in CLI design, configuration systems, and developer-facing tooling. The delegation wrapper is fundamentally a developer tool -- its interface, configuration format, and error handling determine whether the abstraction is usable. This is distinct from the protocol questions mcp-minion handles.

#### Consultation 4: Inter-Agent Protocol and Result Collection
- **Agent**: mcp-minion
- **Planning question**: MCP provides a standardized protocol for tool invocation across hosts. Could MCP serve as the inter-agent communication layer between the orchestrating session and external coding tools? Assess: (1) Can external coding tools expose or consume MCP interfaces? (2) Is MCP appropriate for long-running coding tasks (vs. short tool calls)? (3) What about A2A (Agent-to-Agent protocol) as an alternative? (4) What protocol-level research should the report cover for result collection back to the orchestrating session? Note: the DX of configuring and invoking the wrapper is covered by devx-minion -- focus on the protocol layer (message formats, transport, completion signals, error propagation).
- **Context to provide**: `minions/mcp-minion/AGENT.md` (MCP architecture, transport mechanisms), `docs/orchestration.md` (current result flow from subagents to main session)
- **Why this agent**: mcp-minion is the protocol specialist. The question of how results flow back from external tools to the orchestrating session is a protocol design question. MCP and A2A are the two most relevant standardization efforts for inter-agent communication. No other team member covers protocol-level interoperability.

#### Consultation 5: Research Report Structure and Placement
- **Agent**: software-docs-minion
- **Planning question**: What structure should the research report follow to be thorough and useful? Consider: (1) Where should it live in `docs/` and how should it link to existing architecture docs? (2) What sections does a feasibility study need (tool inventory, format mapping, gap analysis, recommendation matrix)? (3) How should it handle the comparison across tools (matrix format, per-tool sections, or both)? (4) Should it follow any existing report patterns in the project? (5) How should the document acknowledge dimensions the research intentionally does not cover in depth (security, UX) without creating gaps that readers would find surprising?
- **Context to provide**: `docs/architecture.md` (doc hierarchy and sub-document table), existing docs structure, task success criteria
- **Why this agent**: software-docs-minion specializes in architecture documentation structure. The deliverable is a research document -- its structure, placement, and integration with existing docs is the primary documentation concern. This is the only team member covering document structure.

#### Consultation 6: Intent Alignment and Scope Governance
- **Agent**: lucy
- **Planning question**: Review the task description and success criteria against the planned research scope. Specifically: (1) Does the research plan fully cover all six success criteria from the issue (tool inventory, AGENT.md mapping, feasibility assessment, gap analysis, recommendation, docs placement)? (2) Are there signs of scope drift -- areas where the planning team might over-invest in implementation detail, tool advocacy, or architectural proposals beyond what the issue asks for (a research report, not a design doc)? (3) The research must stay tool-neutral and vendor-neutral (Apache 2.0 publishable). What conventions from the project's CLAUDE.md and existing docs should the research report respect? (4) Are the boundaries between in-scope (research) and out-of-scope (implementation, orchestrator changes) sufficiently clear in the planning questions to prevent drift during execution?
- **Context to provide**: The GitHub issue (task description with success criteria), `CLAUDE.md` (project rules including publishability constraints), `docs/architecture.md` (design philosophy), the other five planning questions (for cross-checking scope coverage)
- **Why this agent**: lucy is the intent alignment guardian. Adding lucy to planning ensures the research stays true to the user's ask -- a feasibility study, not an implementation plan or technology endorsement. Lucy's drift detection is particularly valuable here because five domain specialists will each optimize for their own perspective, which could collectively push the research toward premature design decisions.

### Cross-Cutting Checklist

- **Testing**: Exclude from planning. This is a research report, not executable code. No test strategy is needed for the deliverable itself. Testing considerations for a future wrapper implementation should be noted in the research but are out of scope for execution.
- **Security**: Excluded from planning team per user adjustment. Security considerations (trust boundaries when sending AGENT.md to external tools, credential management, sandboxing differences) are important dimensions of the research. The execution agent should be instructed to include a security section in the report, but without dedicated security-minion planning input. The security section will draw on general threat awareness rather than specialist threat modeling.
- **Usability -- Strategy**: Excluded from planning team per user adjustment. UX considerations (user journey impact when delegation targets change from Claude Code subagents to external tools, cognitive load of multi-tool orchestration) are relevant to the research. The execution agent should note UX implications in the feasibility assessment, but without dedicated ux-strategy-minion planning input.
- **Usability -- Design**: Exclude from planning. No user-facing interfaces are being produced. This is a research document.
- **Documentation**: Included -- software-docs-minion (Consultation 5) covers report structure, placement, and integration with existing docs.
- **Observability**: Exclude from planning. No runtime components are being produced.

### Anticipated Approval Gates

This is a research task producing a single document. The deliverable is additive (a new doc file), easy to reverse (delete or revise), and has no downstream dependents in this plan. Based on the gate classification matrix:

- **Research report deliverable**: Easy to reverse + low blast radius = NO GATE. The report can be reviewed and iterated post-creation without gating execution.

No mid-execution approval gates are anticipated. The standard plan approval gate (after synthesis/review) applies as usual.

### Rationale

Six specialists are consulted for planning -- four domain experts, one documentation expert, and one governance reviewer:

1. **ai-modeling-minion** (primary): The central question is about multi-agent architecture abstractions and prompt/instruction format translation. This is ai-modeling-minion's core domain.
2. **gru**: The tool landscape inventory and maturity assessment requires technology radar expertise. Gru's adopt/trial/assess/hold framework structures the evaluation.
3. **devx-minion**: The delegation wrapper's interface and configuration are developer experience concerns. Even though the wrapper isn't being built, the research needs devx input to evaluate feasibility of the DX layer.
4. **mcp-minion**: Protocol-level questions about inter-agent communication (MCP, A2A) and result collection are mcp-minion's specialty.
5. **software-docs-minion**: The deliverable is a research document. Its structure and placement in the docs hierarchy needs documentation expertise.
6. **lucy**: Intent alignment review ensures the research stays scoped to the user's ask (feasibility study) and doesn't drift toward implementation design or tool advocacy. Lucy also verifies that the planning questions collectively cover all success criteria from the issue.

**Agents removed from original plan**: security-minion and ux-strategy-minion were removed per user request. Their domains remain relevant and are noted in the cross-cutting checklist. The execution agent will be instructed to cover security and UX dimensions in the research, but without specialist planning input shaping those sections.

### Scope

**In scope**:
- Inventory of LLM coding tools with CLI/API availability and context-injection mechanisms
- Analysis of how AGENT.md knowledge maps to each tool's instruction format
- Feasibility assessment of a delegation wrapper (start tool, inject knowledge, collect results)
- Gap analysis: current `Task` tool capabilities vs. what a wrapper can replicate
- Clear feasibility recommendation with rationale
- Research document written to `docs/`

**Out of scope**:
- Building the actual delegation wrapper
- Changing the nefario orchestrator or SKILL.md
- Changing AGENT.md format or frontmatter schema
- Implementing any tool integrations
- Performance benchmarking of external tools

### External Skill Integration

#### Discovered Skills

| Skill | Location | Classification | Domain | Recommendation |
|-------|----------|---------------|--------|----------------|
| despicable-lab | `.claude/skills/despicable-lab/` | LEAF | Agent build/rebuild pipeline | Not relevant -- this task does not rebuild agents |
| despicable-statusline | `.claude/skills/despicable-statusline/` | LEAF | Claude Code status line config | Not relevant to this research task |
| despicable-prompter | `skills/despicable-prompter/` | LEAF | Task briefing generation | Not relevant -- task is already briefed |
| nefario | `skills/nefario/` | ORCHESTRATION | Multi-phase orchestration | Already being used as the invocation mechanism |

#### Precedence Decisions

No precedence conflicts. None of the discovered skills overlap with the research task's domain. The nefario skill is the invoking mechanism, not a task target.
