[< Back to Architecture Overview](architecture.md)

# External Harness Integration

*Last assessed: 2026-03-17*

## Problem Statement

The despicable-agents orchestrator currently delegates all execution tasks to Claude Code subagents via the Task tool. This creates single-harness lock-in: every specialist agent runs inside Claude Code, using Claude models, through Anthropic's API. This is efficient when Claude is the right model for every task, but it prevents leveraging other LLM coding tools that may offer cost advantages, model diversity, or specialized capabilities for certain task types.

Multi-harness delegation would allow the orchestrator to route tasks to the best-fit tool -- Aider for pure code edits, Codex CLI for OpenAI-model tasks, Gemini CLI for Google-model tasks -- while maintaining the same planning, gating, and verification process. The orchestrator's value is in decomposition and coordination, not in which tool executes the work.

---

## Executive Summary

Six CLI coding tools can serve as delegation targets today; one more is close. The core feasibility question is not invocation (all viable tools share a `-p` flag pattern) but result collection and instruction format translation, which vary significantly across tools.

| Category | Tools | Verdict |
|----------|-------|---------|
| Feasible now | Claude Code, Codex CLI, Aider | Build adapters with current capabilities. Structured output (Codex) or git-diff-based collection (Aider) covers result needs. |
| Feasible with constraints | Gemini CLI, Cline CLI, Copilot CLI | Usable but with gaps: auth complexity (Gemini), CLI maturity (Cline, Feb 2026), unclear JSON output (Copilot). |
| Not yet feasible | Continue CLI, Goose, Kilo CLI, Amp, Cursor CLI | Missing headless capabilities, insufficient production signals, or too-new CLI pivots. |
| Not feasible | Windsurf | No headless CLI. IDE-only. |

The instruction format translation from AGENT.md to tool-native formats (AGENTS.md, CONVENTIONS.md, .cursorrules) is lossy but workable for the feasible-now tier. Runtime parameters (model selection, tool restrictions) have no cross-tool standard and require per-adapter configuration.

A delegation abstraction is feasible to build. The recommended sequencing is: Codex CLI first (best automation interface), Aider second (most battle-tested scripting), then Gemini CLI. The abstraction should be invisible to the orchestrator -- nefario continues to think in terms of agents and prompts, not tools.

**Key reason not to build it yet**: no public production signals exist for cross-harness orchestration. Individual tools are mature; the multi-tool pattern is frontier territory. Building adapters is engineering effort with maintenance cost and no proven demand beyond experimentation.

---

## Current Delegation Model

Today, nefario delegates tasks during Phase 4 (Execution) by constructing self-contained prompts and spawning specialist agents as Claude Code subagents via the Task tool. The main session manages lifecycle through TaskList polling and SendMessage.

The delegation contract has five interface points:

| Interface Point | Mechanism | Harness-Specific? |
|----------------|-----------|-------------------|
| **Prompt delivery** | Single text string passed to Task tool. Persisted to scratch file before invocation. | No -- any tool that accepts a text prompt can receive this. |
| **Context injection** | Two channels: (1) inline in prompt (scope, constraints, deliverables), (2) by reference (file paths to scratch files and source). Subagent reads referenced files via its own tools. | Partially -- filesystem references work for any local tool. Claude Code tool references (Read, Glob) are harness-specific. |
| **File access** | Shared filesystem (same git worktree). File ownership enforced by prompt convention, not access controls. | No -- any local CLI tool shares the filesystem. |
| **Result collection** | Two channels: (1) TaskUpdate status, (2) structured completion message via SendMessage (file paths, line counts, summary). Freeform text, not schema-enforced. | Yes -- TaskUpdate and SendMessage are Claude Code primitives. |
| **Error handling** | Thin contract. Detection via TaskList polling and idle detection. No timeout, no structured error format, no retry protocol. | Yes -- polling mechanism is Claude Code-specific. |

**What is harness-agnostic**: Prompt delivery, context injection (filesystem-based), and file access all translate directly to CLI invocation patterns. Any tool that runs in the same working directory inherits these.

**What requires abstraction**: Result collection and error handling are tightly coupled to Claude Code's Task/SendMessage/TaskList primitives. An external harness wrapper must provide equivalent signals through different mechanisms (exit codes, stdout parsing, git diff).

---

## Tool Inventory

### Feasible-Now Tier

| Dimension | Claude Code | Codex CLI | Aider |
|-----------|-------------|-----------|-------|
| **CLI headless** | `-p` flag, `--output-format json`, `--agent` for custom agents | `codex exec`, `--json` JSONL stream, `--full-auto` | `--message` / `-m`, `--yes` auto-confirm |
| **Instruction injection** | CLAUDE.md hierarchy, `--agent`, `--system-prompt` | AGENTS.md, `.codex/` config, MCP servers | CONVENTIONS.md via `.aider.conf.yml`, `--read` for context files, AGENTS.md |
| **Result collection** | JSON with full tool traces, exit codes | JSONL event stream, `--output-schema` for JSON Schema validation, `-o` for file output | Git commits as output (`--auto-commits`), exit codes; no structured JSON output |
| **Auto-approve flag** | `--allowedTools` with patterns | `--full-auto` | `--yes` |
| **Maturity** | Production at scale since 2025. Richest headless API. | GA. Strong automation design. TypeScript SDK for programmatic control. | Mature open-source (Apache 2.0). 49.2% SWE-bench. Very active. |
| **Ring (delegation)** | Adopt | Trial | Trial |

### Feasible-with-Constraints Tier

| Dimension | Gemini CLI | Cline CLI | Copilot CLI |
|-----------|-----------|-----------|-------------|
| **CLI headless** | `-p` flag, `--output-format json`, `--yolo` auto-approve | `cline "task"` headless, `-y` autonomy, `--json` output | `-p` / `--prompt`, `--allow-all-tools` |
| **Instruction injection** | GEMINI.md hierarchy, AGENTS.md | `.clinerules`, MCP servers, Hooks | AGENTS.md, `.github/copilot-instructions.md`, `.agent.md` |
| **Result collection** | JSON with token usage and file change stats | NDJSON streaming, `--json` flag | Text to stdout; JSON output unconfirmed |
| **Auto-approve flag** | `--yolo` / `--approval-mode auto_edit` | `-y` | `--allow-all-tools` |
| **Maturity** | GA (Google). Good automation ergonomics. | CLI 2.0 (Feb 2026). 80.8% SWE-bench. | GA (Feb 2026). Rapidly iterating. |
| **Constraint** | Google auth model may complicate CI/headless | Very new CLI; ACP still stabilizing | JSON output undocumented; GitHub subscription required |
| **Ring (delegation)** | Trial | Trial | Assess |

### Not-Yet-Feasible Tier (brief coverage)

| Tool | Ring | Blocker |
|------|------|---------|
| Continue CLI | Assess | No documented JSON output. Cloud agents are a different paradigm. |
| Goose | Assess | Recipe system (YAML) is a different abstraction from prompt delegation. |
| Kilo CLI | Assess | Too new (Feb 2026). Insufficient production signals despite JSON support. |
| Amp | Assess | CLI pivot happened Mar 2026. Wait for stabilization. |
| Cursor CLI | Assess | Headless has documented blockers: approval flow issues, no user-wide config in headless mode. |
| Windsurf | Hold | No headless CLI. IDE-only. Community Docker/Xvfb hack is not a delegation target. |

*Ring classifications represent delegation readiness (can this tool serve as a delegation target for an orchestrator?), not general tool quality or capability.*

---

## Instruction and Protocol Landscape

### Instruction Format Translation

AGENT.md uses a five-section template (Identity, Core Knowledge, Working Patterns, Output Standards, Boundaries) with YAML frontmatter. External tools consume instructions through different file formats. The table below maps each AGENT.md component to its target-format equivalent.

| AGENT.md Component | AGENTS.md | CONVENTIONS.md (Aider) | .cursor/rules/*.mdc | GEMINI.md |
|-------------------|-----------|----------------------|---------------------|-----------|
| Identity | Top-level heading + description | Preamble section | `description` field | Top-level heading |
| Core Knowledge | Markdown sections | Appended content | MDC body content | Markdown sections |
| Working Patterns | Markdown sections | Appended content | MDC body content | Markdown sections |
| Output Standards | Markdown sections | Appended content | MDC body content | Markdown sections |
| Boundaries | Markdown sections | Appended content | MDC body content | Markdown sections |
| `name` (frontmatter) | No equivalent | N/A | N/A | No equivalent |
| `model` (frontmatter) | No equivalent | `--model` flag | Settings UI (not scriptable) | N/A (uses Gemini models) |
| `tools` (frontmatter) | No equivalent | N/A (Aider has fixed tool set) | N/A | No equivalent |
| `memory` (frontmatter) | No equivalent | N/A | N/A | No equivalent |
| Task prompt | Separate prompt input | `--message` flag | Chat input | `-p` flag |

**Key findings**:

- The five prompt sections translate cleanly to any Markdown-based instruction format. Content fidelity is high.
- Frontmatter fields (`model`, `tools`, `memory`) have no cross-tool equivalent. These are runtime parameters that belong in the wrapper configuration, not the instruction file.
- The task prompt must be stripped of Claude Code-specific instructions (TaskUpdate, SendMessage, scratch directory conventions) before passing to an external tool.
- AGENTS.md (Linux Foundation / AAIF) is the emerging cross-tool format, supported by 60,000+ repos and 10+ tools. It is structurally similar to CLAUDE.md (both are Markdown project instructions) but differs in discovery paths, override semantics, and scoping rules.

### Instruction Format Coverage

| Format | Owner | Tools That Read It |
|--------|-------|--------------------|
| AGENTS.md | Linux Foundation (AAIF) | Codex CLI, Copilot CLI, Gemini CLI, Cline, Goose, Kilo, Amp, Cursor, Windsurf |
| CLAUDE.md | Anthropic | Claude Code (native), Copilot CLI (also reads) |
| GEMINI.md | Google | Gemini CLI |
| CONVENTIONS.md | Aider | Aider |
| .cursorrules / .cursor/rules/ | Cursor | Cursor |
| .clinerules | Cline | Cline |
| copilot-instructions.md | GitHub | Copilot CLI/IDE |

### Protocol Landscape

The delegation problem spans three distinct layers. The current subagent model collapses all three into Claude Code's internal Task/SendMessage/TaskList mechanism. Externalizing harnesses requires making each layer explicit.

| Layer | Concern | Current Mechanism | External Options |
|-------|---------|-------------------|-----------------|
| **L3: Orchestration** | Task assignment, lifecycle, results | Task tool + TaskList polling + SendMessage | Custom wrapper (pragmatic); A2A protocol (architectural fit but zero coding-tool adoption) |
| **L2: Context Sharing** | Repo state, constraints, prompts | Inline prompt text + filesystem paths | File-based injection (write AGENTS.md / CONVENTIONS.md before invocation); MCP resources (subset of tools support MCP as client) |
| **L1: Process Invocation** | Starting/stopping harness processes | Claude Code internal subprocess | Shell subprocess (`spawn(tool, args)`); all feasible tools support this |

**Protocol comparison**:

| Dimension | Claude Code Task | CLI Subprocess | MCP Tool Call | A2A Task |
|-----------|-----------------|---------------|---------------|----------|
| Task lifecycle | Implicit (TaskList polling) | Exit code (0 = success) | Return = done | Explicit states (working, completed, failed, input_required) |
| Progress monitoring | SendMessage + TaskList | stdout streaming (if supported) | SSE for tool progress | SSE streaming + polling + webhooks |
| Result format | Freeform SendMessage text | stdout + git diff + exit code | Tool call return value | Typed artifacts attached to task |
| Multi-turn | SendMessage bidirectional | Not supported (single-shot) | Not native | Send follow-up messages to same taskId |
| Adoption in coding tools | Claude Code only | Universal | Codex CLI (server mode) | Zero |
| Complexity | Low (built-in) | Low (shell) | Medium (JSON-RPC, transport) | High (full protocol stack) |

**MCP is not the right delegation layer.** MCP is designed for short-lived tool calls, not multi-minute coding tasks. The experimental Tasks primitive (SEP-1686) addresses duration but not delegation semantics. MCP's value is on the context-sharing side (L2), not orchestration (L3).

**A2A is architecturally the best fit** for L3 but has zero adoption in coding tools as of 2026-03-17. Monitor for 6 months.

**CLI subprocess is the pragmatic choice** for L3. Tools have converged on `-p` flag invocation. Process exit is an unambiguous completion signal -- simpler and more reliable than the current TaskList polling.

---

## Gap Analysis

Structured comparison of what the current Claude Code Task tool provides versus what external tool wrappers can replicate.

| Dimension | Claude Code Task Tool | CLI Subprocess Wrapper | Gap Severity |
|-----------|----------------------|----------------------|--------------|
| **Prompt delivery** | Single text string via Task `prompt` parameter | `-p` / `--message` flag or `--message-file` for long prompts | None -- direct mapping |
| **Context injection** | Inline text + filesystem path references; subagent reads files with Read/Glob/Grep tools | Write instruction file (AGENTS.md, CONVENTIONS.md) + `--read` flags; tool reads files natively | Low -- filesystem paths work; tool-specific read mechanisms vary |
| **File access** | Shared filesystem; Read/Write/Edit/Bash tools | Shared filesystem; tool-native file operations | None -- same working directory |
| **Result collection** | TaskUpdate status + structured SendMessage (file paths, line counts, summary) | Exit code + git diff of changed files + stdout (JSON where supported) | Medium -- git diff provides file changes but not semantic summaries. Codex `--output-schema` can enforce structured output. Aider has no JSON output. |
| **Error handling** | TaskList polling for idle/failure detection; no timeout; no structured errors | Exit code (0/non-zero) + stderr; configurable timeout via wrapper; no structured error categories | Low-Medium -- exit codes are more reliable than polling. Lack of structured error categories (retryable vs. fatal) requires heuristic classification. |
| **Progress monitoring** | SendMessage for intermediate updates; TaskList for status | stdout streaming (Codex JSONL, Cline NDJSON); no equivalent for non-streaming tools (Aider) | Medium -- streaming tools provide progress; batch tools are opaque until completion |
| **Model routing** | `model` frontmatter field (opus/sonnet); runtime override | Tool-specific model flags (`--model`); model names differ across providers | Medium -- model intent (quality tier) must be translated to provider-specific identifiers. No standard alias system. |
| **Cost tracking** | `usage` response fields (tokens, cache hits) | Tool-specific: Aider tracks tokens; Codex via API billing; others vary | Medium -- no unified cost interface. Per-tool parsing required. |
| **Tool parity** | Read, Write, Edit, Bash, Glob, Grep, WebSearch, WebFetch | Varies: Aider has file edit only (no Bash, no WebSearch). Codex has broader tool set. Gemini CLI has web access. | High for some tools -- Aider cannot do web research or run tests. Tasks requiring Bash or WebSearch must stay on tools that support them. |
| **Instruction isolation** | Subagent gets blank context + system prompt | External tool loads its own config (CLAUDE.md, .cursorrules, etc.) in addition to injected instructions. Context cannot be fully controlled. | Medium -- the orchestrator cannot prevent an external tool from reading conflicting project-level instructions |

---

## Feasibility Assessment

### Feasible Now

**Codex CLI** -- Best automation interface. `codex exec --json` provides JSONL output; `--output-schema` enables JSON Schema validation on final output. `--full-auto` handles approval bypass. TypeScript SDK adds programmatic control. Constraint: uses OpenAI models (o3, o4-mini), so quality parity with Claude Opus is not guaranteed for all task types.

**Aider** -- Most battle-tested scripting mode. `--message` + `--yes` for reliable single-shot execution. Git-native output (commits as deliverables) aligns with the orchestrator's commit workflow. Limitation: no structured JSON output -- result collection requires parsing git diff, which is lossy (file changes but not semantic summaries). Narrower tool set (no Bash, no web search).

### Feasible with Constraints

**Gemini CLI** -- Clean JSON output with token usage and file change stats. Constraint: Google auth adds friction in headless environments.

**Cline CLI** -- Well-designed NDJSON streaming. Constraint: CLI 2.0 launched Feb 2026 -- limited production track record.

**Copilot CLI** -- Reads multiple instruction formats. Constraint: JSON output undocumented; GitHub subscription required.

### Not Yet Feasible

Each has specific blockers: missing JSON output (Continue), different abstraction model (Goose recipes), insufficient maturity (Kilo, Amp), or headless limitations (Cursor). As of 2026-03-17, these tools do not meet the minimum bar for headless delegation.

### Reasons Not to Support External Harnesses

The gap analysis identifies real costs:

- **Maintenance burden**: Each adapter requires ongoing maintenance as tool CLI interfaces evolve. Version drift breaks adapters silently.
- **Instruction isolation**: External tools load their own project config, which the orchestrator cannot control.
- **Tool parity variance**: Tasks designed for Claude Code's full tool set may fail on tools with narrower capabilities.
- **No production precedent**: No public system performs cross-harness orchestration in production as of 2026-03-17.
- **Complexity for non-users**: The abstraction must be zero-cost for users who do not use external harnesses.

---

## Recommendations

### Sequencing

If external harness support is pursued, the recommended order is:

1. **Codex CLI** -- Best-designed automation interface, structured output, JSON Schema validation. Lowest adapter complexity.
2. **Aider** -- Most mature scripting mode. Git-diff result collection is less rich but reliable. Validates that the abstraction works without structured output.
3. **Gemini CLI** -- Third priority. Clean interface but Google auth adds friction.

### What Would Need to Change in the Delegation Model

A resolution layer between the orchestrator and invocation would need to: translate prompts (strip Claude Code-specific instructions, inject tool preamble), write instruction files (AGENTS.md, CONVENTIONS.md), normalize results (JSON/JSONL/git-diff to common format), and clean up temporary files.

The orchestrator (nefario) should remain unaware of which tool executes each task. Routing decisions belong in configuration, not planning logic.

### Technology Radar (Delegation Readiness)

These ring classifications assess each tool's readiness as a delegation target, not its general quality or capability as a standalone coding tool.

| Ring | Tools | Guidance |
|------|-------|---------|
| **Adopt** | Claude Code | Current native target. Continue using. |
| **Trial** | Codex CLI, Aider, Gemini CLI, Cline CLI | Build experimental adapters. Validate with representative tasks before production use. |
| **Assess** | Copilot CLI, Continue CLI, Goose, Kilo CLI, Amp, Cursor CLI | Monitor CLI maturity, structured output support, and headless reliability. Re-evaluate quarterly. |
| **Hold** | Windsurf | No headless CLI. Do not invest adapter effort. |

### Convergence Patterns Worth Watching

Three convergence trends reduce future adapter complexity:

1. **Invocation**: Nearly every tool uses `-p "prompt"` with `--output-format json`. This is converging toward a de facto standard.
2. **Instruction format**: AGENTS.md is gaining cross-tool adoption under Linux Foundation governance. Not universal yet, but trajectory is clear.
3. **Auto-approve**: Every headless-capable tool has an "approve everything" flag. The specific flag name varies but the pattern is uniform.

### ACP Protocol

The Agent Client Protocol (created by Zed, adopted by Cline, Copilot, JetBrains, Zed) standardizes agent-editor communication. If ACP gains an "orchestrator mode" or "headless server mode," it could eventually replace shell-based invocation with protocol-level delegation. As of 2026-03-17, ACP is editor-focused, not orchestrator-focused. Assess ring -- monitor but do not build on it yet.

---

## Out of Scope

- **Security threat model** for external tool execution (filesystem trust, credential exposure, prompt injection via tool output, supply chain risk)
- **UX design** for multi-harness workflows (configuration UI, routing visualization, dry-run modes)
- **Cost comparison** across providers (model pricing, token efficiency, API billing)
- **Implementation** of any wrapper, adapter, configuration schema, or abstraction layer

---

## Open Questions

1. **Instruction isolation**: When an external tool loads both injected instructions (AGENTS.md from the wrapper) and existing project config (.cursorrules, CLAUDE.md), how should conflicts be handled? Can tools be configured to ignore project-level instructions in favor of injected ones?

2. **Parallel delegation race conditions**: If multiple tasks delegate to different tools in the same working directory, concurrent file writes could conflict. Worktree isolation (already supported by the orchestrator) mitigates this, but adds overhead. Is per-delegation worktree creation practical at scale?

3. **Model quality parity**: Routing a task designed for Claude Opus to Codex (o3/o4-mini) or Aider (provider-dependent) may produce different quality results. Should the orchestrator track per-tool quality outcomes to inform future routing, or is this the user's responsibility?

4. **AGENTS.md spec stability**: AGENTS.md recently moved to the Linux Foundation. The spec could evolve in ways that affect translation logic. What is the expected spec cadence and backward-compatibility policy?

5. **Result collection without structured output**: For tools that produce only git diffs (Aider), how should the wrapper generate the semantic summary (file paths, change scope, purpose) that the orchestrator expects? LLM-based summarization of diffs is one option but adds cost and latency.
