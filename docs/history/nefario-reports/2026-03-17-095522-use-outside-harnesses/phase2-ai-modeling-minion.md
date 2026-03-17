## Domain Plan Contribution: ai-modeling-minion

### Recommendations

#### 1. The Current Subagent Contract Has Five Interface Points

After analyzing SKILL.md Phase 4, nefario AGENT.md, and the orchestration docs, the current Claude Code Task tool delegation contract consists of these discrete interface points that any abstraction must replicate:

**a. Prompt Delivery** -- The orchestrator constructs a self-contained prompt string containing the task description, constraints, file paths, context references (scratch directory paths), deliverable specification, and a completion-reporting instruction ("mark it completed with TaskUpdate and send a message to the team lead"). This prompt is the single input channel. The prompt is also persisted to `$SCRATCH_DIR/{slug}/phase4-{agent-name}-prompt.md` before invocation -- this is both a debugging artifact and an audit trail.

**b. Context Injection** -- Subagents receive context through two mechanisms: (1) inline in the prompt (task description, scope boundaries, "do NOT do" sections, available skills), and (2) by reference (file paths to scratch files like `phase3-synthesis.md`, paths to relevant source files). The subagent reads referenced files using its own tools (Read, Glob, Grep). There is no structured "context bundle" -- it is text instructions plus filesystem access.

**c. File Access** -- Subagents share the same filesystem as the main session (same git worktree). They read source files, write new files, and edit existing files using Claude Code's built-in tools (Read, Write, Edit, Bash). File ownership is enforced by prompt convention ("you own these files; do not modify others"), not by access controls.

**d. Result Collection** -- Results flow back through two channels: (1) TaskUpdate status (completed/failed), and (2) a structured completion message to the team lead containing file paths with change scope, line counts, and a 1-2 sentence summary. The orchestrator uses TaskList polling to detect completion. There is no structured result schema -- it is freeform text matching an expected format.

**e. Error Handling** -- The contract is thin on error handling. Subagents can fail silently (idle without completing), fail explicitly (error in Bash), or produce work that does not meet spec. Detection relies on the orchestrator's active monitoring loop (TaskList polling, idle detection, status messages). There is no timeout mechanism, no retry protocol at the Task level, and no structured error reporting format.

#### 2. Mapping to External Tool Interfaces

The research shows three viable coordination patterns for external LLM coding tools. Each maps differently to the five interface points above:

**Pattern A: CLI Wrapper (Aider, Codex CLI)**

Both Aider and Codex CLI support non-interactive single-shot invocation:
- **Aider**: `aider --message "<prompt>" --file <files> --no-stream` exits after applying edits
- **Codex CLI**: `codex exec "<prompt>" --json` streams JSONL events and exits

Mapping to interface points:
- Prompt delivery: `--message` / positional arg (direct text or `--message-file` for long prompts)
- Context injection: `--file` / `--read` flags for Aider; AGENTS.md hierarchy for Codex; both have working directory filesystem access
- File access: Both tools operate on the same filesystem -- Aider applies git-tracked edits, Codex writes files directly
- Result collection: Aider exit code (0/non-zero) + git diff of applied changes; Codex `--json` JSONL stream with structured events + `--output-schema` for structured final output
- Error handling: Exit codes; Codex `--json` includes `exit_code` fields per command execution

This pattern is the most pragmatic starting point. Both tools already work as CLI programs. The wrapper translates the nefario prompt format into CLI arguments, invokes the tool, and collects results from exit code + filesystem diff + stdout.

**Pattern B: MCP Tool Use**

Codex CLI can operate as an MCP server, meaning the orchestrating session could invoke it as a tool rather than spawning a subprocess. This is the most architecturally clean pattern but the least mature.

Mapping:
- Prompt delivery: MCP tool call parameters
- Context injection: MCP resource URIs or inline content
- File access: Shared filesystem (same as subagents)
- Result collection: MCP tool result response
- Error handling: MCP error responses with structured codes

Advantage: stays within Claude Code's tool-use paradigm. Disadvantage: requires the external tool to expose an MCP interface, which only Codex CLI currently does.

**Pattern C: A2A Protocol**

Google's Agent2Agent protocol (v0.3, Linux Foundation governance) provides a formal inter-agent communication standard with Agent Cards (capability discovery), task lifecycle management, and structured message exchange.

Mapping:
- Prompt delivery: A2A task creation with instructions
- Context injection: A2A context sharing, file references
- File access: Defined by the remote agent's capabilities (may not share filesystem)
- Result collection: A2A task completion with structured artifacts
- Error handling: A2A task lifecycle states (failed, cancelled, etc.)

This is the most future-proof pattern but the heaviest to implement. No coding tool currently exposes an A2A server interface. This is a research-only recommendation for the report, not a near-term implementation target.

#### 3. Instruction Format Translation Is the Core Research Area

The report must cover how nefario's AGENT.md system prompts and task prompts translate to instruction formats consumed by external tools. This is where the real complexity lives:

**AGENT.md -> AGENTS.md**: AGENTS.md (Linux Foundation / AAIF standard) is now supported by 60,000+ projects and tools including Cursor, Codex, Copilot, Gemini CLI, and others. Claude Code uses CLAUDE.md. The two formats are structurally similar (Markdown-based project instructions) but differ in:
- Discovery paths: CLAUDE.md uses `.claude/` hierarchy; AGENTS.md uses git root + directory walk
- Override semantics: CLAUDE.md has `CLAUDE.local.md` (gitignored); AGENTS.md has `AGENTS.override.md`
- Scope: CLAUDE.md has user-global + project + directory scoping; AGENTS.md has home + project + directory scoping
- Size: AGENTS.md default 32KiB limit; CLAUDE.md no documented limit

The report should document a bidirectional translation between AGENT.md five-section template (Identity, Core Knowledge, Working Patterns, Output Standards, Boundaries) and the equivalent AGENTS.md or .cursorrules/.mdc representation. Key finding: the AGENT.md frontmatter (model, tools, memory) has no equivalent in AGENTS.md -- these are runtime-specific parameters that belong in the wrapper, not the instruction file.

**AGENT.md -> .cursor/rules/*.mdc**: Cursor's MDC format uses `description`, `globs`, and `alwaysApply` fields. An AGENT.md system prompt could be converted to an `alwaysApply: true` MDC file with the system prompt as body content. The `globs` field maps loosely to file ownership constraints in the nefario plan.

**AGENT.md -> .aider.conf.yml**: Aider's YAML config covers model selection, file scoping, and behavior flags but does not have a "system prompt" field. Aider uses `--system-prompt-file` or inline `--message` for instructions. The translation is: AGENT.md body -> system prompt file; AGENT.md frontmatter -> aider config flags.

**Task prompts -> tool-native prompts**: The nefario task prompt includes nefario-specific conventions (scratch directory paths, TaskUpdate/SendMessage instructions, deliverable format). These must be stripped or translated. The wrapper must:
1. Strip Claude Code-specific instructions (TaskUpdate, SendMessage, team tools)
2. Replace scratch directory references with actual file paths or inline content
3. Translate deliverable format instructions to tool-native equivalents (Codex `--output-schema`, Aider git diff)
4. Add tool-specific preamble (Aider edit format instructions, Codex approval mode flags)

#### 4. Fundamental Constraints the Wrapper Must Replicate or Work Around

**Shared filesystem assumption**: All current subagents share the orchestrator's filesystem. CLI wrappers preserve this naturally (same working directory). Remote tools (A2A, cloud-hosted) would require a different model (git push/pull synchronization or mounted volumes).

**No context window sharing**: Subagents already start with empty context (stateless single-turn). This is actually favorable for external tools -- there is no conversation state to transfer.

**Claude Code tool subset**: Subagents have access to Claude Code built-in tools (Read, Write, Edit, Bash, Glob, Grep, WebSearch, WebFetch). External tools have their own tool sets. The wrapper cannot guarantee tool parity. For example, Aider cannot do WebSearch. The report should map tool capabilities across harnesses.

**Model routing**: AGENT.md frontmatter specifies `model: opus | sonnet`. External tools have their own model selection (Aider supports multiple providers via `--model`; Codex uses its own model family; Cursor uses configured models). The wrapper must translate model intent (quality tier) to the external tool's model configuration.

**Subagent nesting prohibition**: Claude Code subagents cannot spawn sub-subagents. This constraint does not apply to external tools -- Aider and Codex operate independently and could theoretically nest, though the wrapper should not rely on this.

**Active monitoring**: The orchestrator currently uses TaskList polling and SendMessage for monitoring. CLI wrappers would use process exit monitoring (wait for process to complete, check exit code). This is actually simpler and more reliable than the current polling model.

**Cost tracking**: Claude Code tracks token usage in `usage` response fields. External tools have their own cost tracking (Aider tracks token usage; Codex tracks via API billing). The wrapper should expose a unified cost interface.

#### 5. Recommended Abstraction Layer Architecture

The report should propose a thin abstraction with these components:

1. **Harness Interface** -- A contract defining: `invoke(prompt, context_files, working_dir, model_tier) -> Result(exit_code, changed_files, summary, cost)`. Each harness (Claude Code Task, Aider CLI, Codex CLI, Cursor background) implements this interface.

2. **Prompt Translator** -- Converts nefario task prompts to harness-native format. Strips Claude Code-specific instructions, injects tool-specific preamble, resolves file references.

3. **Result Normalizer** -- Converts harness-native output to a unified result format. Extracts changed files from git diff, parses structured output, normalizes error codes.

4. **Harness Registry** -- Configuration mapping agent types or task types to preferred harnesses. Allows routing decisions (e.g., "use Aider for pure code edits, Claude Code for tasks needing web research").

This is a *conceptual* architecture for the report, not a code implementation proposal. The deliverable is a research document, not a framework.

### Proposed Tasks

**Task 1: Research Report -- External Harness Delegation**
- What: Write a comprehensive research report covering: (a) the five interface points of the current subagent contract, (b) external tool capability mapping (Aider, Codex CLI, Cursor, Goose), (c) instruction format translation (AGENT.md/CLAUDE.md -> AGENTS.md/MDC/.aider), (d) coordination protocol comparison (CLI wrapper vs MCP tool-use vs A2A), (e) abstraction layer design, (f) constraints and limitations
- Deliverable: `docs/external-harness-delegation.md`
- Dependencies: None (this is the primary deliverable)
- Agent: ai-modeling-minion (primary), with devx-minion input on CLI ergonomics and mcp-minion input on MCP/A2A protocol details
- Note: The report should reference the AAIF (Agentic AI Foundation) convergence of MCP + AGENTS.md + Goose under Linux Foundation governance, as this directly affects the standardization trajectory

**Task 2: Tool Capability Matrix**
- What: Build a structured comparison matrix of external tools' capabilities against the five interface points. Include: prompt delivery method, context injection mechanism, file access model, result collection format, error handling, model routing, cost tracking, and MCP support
- Deliverable: A table/section within the main research report (not a separate file)
- Dependencies: Part of Task 1

**Task 3: Instruction Format Translation Reference**
- What: Document the concrete mapping between AGENT.md five-section template and each external format (AGENTS.md, .cursor/rules/*.mdc, .aider system prompt file). Include worked examples showing how a representative AGENT.md translates
- Deliverable: A section within the main research report
- Dependencies: Part of Task 1

### Risks and Concerns

1. **AGENTS.md convergence is still in flux.** The Linux Foundation AAIF was announced but a production-ready version of AGENTS.md is not yet finalized. The report should frame AGENTS.md as the likely convergence point while noting that CLAUDE.md remains the authoritative format for Claude Code. Do not recommend migrating away from CLAUDE.md.

2. **External tools have weaker result contracts.** Aider and Codex CLI return exit codes and file diffs, but they do not provide structured completion summaries in the format nefario expects. The wrapper must infer deliverable summaries from git diff output, which is lossy. This is a fundamental fidelity gap.

3. **Model quality parity is not guaranteed.** Routing a task designed for Claude Opus 4.6 to Codex (which uses o3/o4-mini) or Aider (which supports multiple providers) may produce different quality results. The report should be explicit that harness-agnosticism does not mean model-agnosticism -- quality still depends on which model executes the task.

4. **Security surface expansion.** Delegating to external CLI tools means the orchestrator trusts those tools with filesystem access, API keys, and potentially secrets in the working directory. The security-minion should review the threat model for external harness delegation (prompt injection via tool output, credential exposure, supply chain risk from external tool dependencies).

5. **Scope creep risk.** This is a *research report*, not a framework implementation. The report should propose a conceptual architecture but explicitly defer implementation. Building a working multi-harness orchestration layer is a separate, much larger initiative. The report should make this boundary crystal clear.

6. **Active monitoring translation.** The current TaskList/SendMessage polling loop in Phase 4 has known reliability issues (see agent memory: "Main session may not auto-react to teammate completion messages"). Ironically, CLI wrapper invocation (synchronous process wait) would be more reliable than the current pattern. The report should note this.

### Additional Agents Needed

- **security-minion**: Should review the threat model for delegating to external tools. Key concerns: (a) external tools executing in the same filesystem with potential access to secrets, (b) prompt injection risk if external tool output is fed back into the orchestrator's context, (c) supply chain risk from external tool dependencies (npm/pip packages). This is not covered by the default cross-cutting checklist because the task is a research report, but the report's recommendations will influence future architecture decisions that have security implications.

- **gru**: Should provide a technology radar assessment of the external tools (Aider, Codex CLI, Cursor, Goose) and the AAIF standardization trajectory. Gru's adopt/hold/wait framework would help the report make actionable recommendations about which tools to target first. (Note: gru may already be in the planning team -- if so, this is a confirmation of relevance rather than an addition.)

All other needed perspectives (devx-minion for CLI ergonomics, mcp-minion for protocol details, software-docs-minion for report structure) appear to already be covered by the planning team.
