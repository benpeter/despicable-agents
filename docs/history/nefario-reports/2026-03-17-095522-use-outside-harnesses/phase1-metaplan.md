# Phase 1: Meta-Plan

## Task Summary

Research whether and how the despicable-agents orchestrating session can delegate tasks to external LLM coding tools (Cursor, Aider, Codex CLI, etc.) the same way it currently delegates to Claude Code subagents. The deliverable is a thorough research report under `docs/`, not implementation.

## Meta-Plan

### Planning Consultations

#### Consultation 1: Multi-Agent Architecture and Delegation Abstractions
- **Agent**: ai-modeling-minion
- **Planning question**: The current delegation mechanism is tightly coupled to Claude Code's `Task` tool (subagent spawning with `subagent_type`, prompt injection, result playback). What abstraction layer would be needed to generalize delegation to external LLM coding tools? Specifically: (1) What are the key interface points in the current subagent contract (prompt delivery, context injection, file access, result collection, error handling)? (2) How do these map to known multi-agent coordination patterns (A2A, MCP tool-use, CLI wrappers)? (3) What research areas should the report cover regarding prompt/instruction format translation (AGENT.md -> .cursorrules, .aider.conf, etc.)?
- **Context to provide**: `skills/nefario/SKILL.md` (Phase 4 execution loop, subagent spawning pattern), `nefario/AGENT.md` (delegation model), `docs/orchestration.md` (nine-phase architecture), `docs/agent-anatomy.md` (AGENT.md structure)
- **Why this agent**: ai-modeling-minion is the expert on multi-agent architectures, prompt engineering, and system prompt design. The core question -- whether AGENT.md knowledge can be faithfully translated to foreign instruction formats -- is fundamentally a prompt engineering and agent architecture question.

#### Consultation 2: Technology Landscape and Tool Maturity Assessment
- **Agent**: gru
- **Planning question**: What is the current landscape of LLM coding tools that could serve as delegation targets? For each major tool (Cursor, Aider, Codex CLI, Windsurf, Cline, Continue, Copilot CLI, and any emerging tools), assess: (1) CLI/API availability for programmatic invocation (can it be started headless?), (2) context/instruction injection mechanisms (system prompts, project rules, file context), (3) result collection capabilities (structured output, exit codes, file diffs), (4) maturity level (adopt/trial/assess/hold), (5) openness of the instruction format. What tools are feasible delegation targets today vs. which require waiting?
- **Context to provide**: `gru/AGENT.md` (technology radar framework), the task description with scope boundaries
- **Why this agent**: gru is the technology landscape analyst. The inventory of LLM coding tools and their maturity assessment is squarely in gru's domain. The adopt/trial/assess/hold framework provides the right lens for evaluating each tool's readiness as a delegation target.

#### Consultation 3: Developer Experience of the Delegation Wrapper
- **Agent**: devx-minion
- **Planning question**: If a delegation wrapper is built to start external tools, inject agent knowledge, and collect results, what should the developer experience look like? Consider: (1) How should the wrapper be invoked (CLI subcommand, config-driven, transparent to the orchestrator)? (2) What configuration format maps AGENT.md fields to foreign tool instruction formats? (3) What does the error experience look like when an external tool fails or produces unexpected output? (4) What should the report cover regarding DX of the wrapper interface?
- **Context to provide**: `docs/agent-anatomy.md` (AGENT.md structure, frontmatter schema), `install.sh` (current deployment model), `docs/external-skills.md` (how external skills are discovered and integrated)
- **Why this agent**: devx-minion specializes in CLI design, configuration systems, and developer-facing tooling. The delegation wrapper is fundamentally a developer tool -- its interface, configuration format, and error handling determine whether the abstraction is usable.

#### Consultation 4: Inter-Agent Protocol and Result Collection
- **Agent**: mcp-minion
- **Planning question**: MCP provides a standardized protocol for tool invocation across hosts. Could MCP serve as the inter-agent communication layer between the orchestrating session and external coding tools? Assess: (1) Can external coding tools expose or consume MCP interfaces? (2) Is MCP appropriate for long-running coding tasks (vs. short tool calls)? (3) What about A2A (Agent-to-Agent protocol) as an alternative? (4) What protocol-level research should the report cover for result collection back to the orchestrating session?
- **Context to provide**: `minions/mcp-minion/AGENT.md` (MCP architecture, transport mechanisms), `docs/orchestration.md` (current result flow from subagents to main session)
- **Why this agent**: mcp-minion is the protocol specialist. The question of how results flow back from external tools to the orchestrating session is a protocol design question. MCP and A2A are the two most relevant standardization efforts for inter-agent communication.

### Cross-Cutting Checklist

- **Testing**: Exclude from planning. This is a research report, not executable code. No test strategy is needed for the deliverable itself. Testing considerations for a future wrapper implementation should be noted in the research but are out of scope for execution.
- **Security**: Include in planning -- security-minion should review the research plan. Delegating to external tools introduces significant trust, credential, and sandboxing questions. The research report must cover: credential passing to external tools, file access scope, prompt injection via foreign instruction formats, and trust boundaries when agent knowledge leaves the Claude Code sandbox.
- **Usability -- Strategy**: ALWAYS include. ux-strategy-minion should advise on what the research report should cover regarding the user journey of delegating to external tools. When a user invokes `/nefario` and work is routed to Cursor or Aider instead of a Claude Code subagent, what does the user need to see, know, or control? The research should address this even though implementation is out of scope.
- **Usability -- Design**: Exclude from planning. No user-facing interfaces are being produced. This is a research document.
- **Documentation**: ALWAYS include. software-docs-minion should advise on the structure and placement of the research report. Where does it fit in the existing docs/ hierarchy? What sections does a thorough feasibility study need? How should it reference and link to existing architecture docs?
- **Observability**: Exclude from planning. No runtime components are being produced.

### Planning Consultations (Cross-Cutting)

#### Consultation 5: Security Implications of External Delegation
- **Agent**: security-minion
- **Planning question**: What security dimensions must the research report cover when evaluating delegation to external LLM coding tools? Consider: (1) Trust boundary analysis -- AGENT.md contains sensitive project knowledge; what are the risks of injecting it into tools with different trust models? (2) Credential management -- if external tools need API keys, file access, or git credentials, how should the wrapper handle this? (3) Prompt injection surface -- could a foreign instruction format (.cursorrules) be manipulated to override agent boundaries? (4) Sandboxing -- Claude Code subagents inherit the session's permission model; what happens when an external tool operates outside that sandbox?
- **Context to provide**: `docs/external-skills.md` (trust model for external skills), `minions/security-minion/AGENT.md` (threat modeling expertise), `docs/agent-anatomy.md` (what's in AGENT.md that would be exposed)
- **Why this agent**: Security is a cross-cutting concern that must be evaluated even for research. The core question -- sending agent knowledge to external tools -- inherently crosses trust boundaries. The research report needs a rigorous security section.

#### Consultation 6: Research Report Structure
- **Agent**: software-docs-minion
- **Planning question**: What structure should the research report follow to be thorough and useful? Consider: (1) Where should it live in `docs/` and how should it link to existing architecture docs? (2) What sections does a feasibility study need (tool inventory, format mapping, gap analysis, recommendation matrix)? (3) How should it handle the comparison across tools (matrix format, per-tool sections, or both)? (4) Should it follow any existing report patterns in the project?
- **Context to provide**: `docs/architecture.md` (doc hierarchy), existing docs structure, task success criteria
- **Why this agent**: software-docs-minion specializes in architecture documentation structure. The deliverable is a research document -- its structure, placement, and integration with existing docs is the primary documentation concern.

#### Consultation 7: User Journey Coherence
- **Agent**: ux-strategy-minion
- **Planning question**: From a user journey perspective, what should the research report evaluate regarding the experience of multi-tool delegation? Consider: (1) The current user journey when `/nefario` delegates -- user sees status, gets approval gates, sees results. What breaks if the subagent is Cursor instead of Claude Code? (2) Cognitive load -- does adding external tool options increase complexity for the user, or does it remain transparent? (3) What simplification principles should guide the wrapper's design (even though implementation is out of scope)?
- **Context to provide**: `docs/using-nefario.md` (current user experience), `docs/orchestration.md` (approval gates, status updates), task description
- **Why this agent**: ux-strategy-minion evaluates journey coherence and cognitive load. The research must consider whether external delegation preserves or degrades the user experience, even at the research/recommendation level.

### Anticipated Approval Gates

This is a research task producing a single document. The deliverable is additive (a new doc file), easy to reverse (delete or revise), and has no downstream dependents in this plan. Based on the gate classification matrix:

- **Research report deliverable**: Easy to reverse + low blast radius = NO GATE. The report can be reviewed and iterated post-creation without gating execution.

No mid-execution approval gates are anticipated. The standard plan approval gate (after synthesis/review) applies as usual.

### Rationale

Seven specialists are consulted for planning -- four domain experts and three cross-cutting reviewers:

1. **ai-modeling-minion** (primary): The central question is about multi-agent architecture abstractions and prompt/instruction format translation. This is ai-modeling-minion's core domain.
2. **gru**: The tool landscape inventory and maturity assessment requires technology radar expertise. Gru's adopt/trial/assess/hold framework structures the evaluation.
3. **devx-minion**: The delegation wrapper's interface and configuration are developer experience concerns. Even though the wrapper isn't being built, the research needs devx input to evaluate feasibility of the DX layer.
4. **mcp-minion**: Protocol-level questions about inter-agent communication (MCP, A2A) and result collection are mcp-minion's specialty.
5. **security-minion**: Trust boundary analysis when sending agent knowledge to external tools is a critical security concern that the research must address.
6. **software-docs-minion**: The deliverable is a research document. Its structure and placement in the docs hierarchy needs documentation expertise.
7. **ux-strategy-minion**: The user journey impact of multi-tool delegation must be evaluated, even at the research level.

Agents NOT consulted: The remaining 19 agents (lucy, margo, frontend-minion, test-minion, etc.) do not have domain expertise that would materially improve the research plan. lucy and margo will review during Phase 3.5 as mandatory reviewers. test-minion is excluded because no executable code is produced.

### Scope

**In scope**:
- Inventory of LLM coding tools with CLI/API availability and context-injection mechanisms
- Analysis of how AGENT.md knowledge maps to each tool's instruction format
- Feasibility assessment of a delegation wrapper (start tool, inject knowledge, collect results)
- Gap analysis: current `Task` tool capabilities vs. what a wrapper can replicate
- Security analysis of cross-tool trust boundaries
- User journey impact assessment
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
