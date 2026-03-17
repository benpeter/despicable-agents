## Domain Plan Contribution: gru

### TL;DR

The CLI coding agent landscape has converged dramatically: by March 2026, **10+ tools** support a near-identical headless invocation pattern (`-p` flag, JSON output, auto-approve). Six tools are feasible delegation targets today (Claude Code, Codex CLI, Aider, Gemini CLI, Copilot CLI, Cline CLI). Three more are close (Continue CLI, Goose, Kilo CLI). Instruction format convergence around AGENTS.md is underway but incomplete -- CLAUDE.md and GEMINI.md still coexist. The biggest risk is not "can we invoke them" but "can we reliably collect structured results and detect failure." Build the abstraction layer now; the tools are ready.

---

### Recommendations

#### 1. Landscape Assessment: CLI Coding Tools as Delegation Targets

The table below assesses each tool across the five requested dimensions. Ring classifications follow the adopt/trial/assess/hold framework applied specifically to the question "can this tool serve as a headless delegation target for an orchestrator?"

| Tool | Ring | CLI Headless | Instruction Injection | Result Collection | Maturity | Instruction Openness |
|------|------|-------------|----------------------|-------------------|----------|---------------------|
| **Claude Code** | **Adopt** | `-p` flag, `--agent`, `--session-id` for multi-turn, `--output-format json\|stream-json\|text` | CLAUDE.md (project/user/enterprise), AGENTS.md (read), `--agent` for custom agents, `--system-prompt` | JSON structured output, exit codes, `--output-format json` with full tool traces | Production at scale; GA since 2025 | CLAUDE.md is Anthropic-proprietary format; AGENTS.md read support added |
| **Codex CLI** | **Trial** | `codex exec` subcommand, `--json` JSONL stream, `--full-auto`, `--output-last-message`, `--output-schema` for JSON Schema validation | AGENTS.md (primary), `.codex/` config, MCP servers, Agents SDK integration | JSONL event stream, `--output-schema` for structured output, `-o` writes final message to file, session resume | GA; strong automation design; TypeScript SDK for programmatic control | AGENTS.md -- open standard under Linux Foundation |
| **Aider** | **Trial** | `--message` / `-m` for single prompt, `--yes` auto-confirm, `--message-file`, Python API (unofficial) | CONVENTIONS.md via `.aider.conf.yml`, `--read` flag for context files, AGENTS.md support | Git commits as output (diff-based), `--auto-commits`, exit after message processing; **no structured JSON output**, no explicit exit codes documented | Mature open-source (Apache 2.0); 49.2% SWE-bench; very active release cadence | CONVENTIONS.md is Aider-specific; also reads AGENTS.md |
| **Gemini CLI** | **Trial** | `-p` flag, `--output-format json\|text`, `--yolo` auto-approve, `--approval-mode auto_edit` | GEMINI.md (project hierarchy), AGENTS.md support, `--include-directories`, `--all-files` | JSON output with response + stats (token usage, tool stats, file changes), pipe-friendly | GA (Google); strong JSON output; good automation ergonomics | GEMINI.md is Google-proprietary; AGENTS.md also supported |
| **Copilot CLI** | **Trial** | `-p` / `--prompt` flag, `--allow-all-tools` for headless, GitHub Actions integration | AGENTS.md, `.github/copilot-instructions.md`, `.agent.md` custom agents, CLAUDE.md/GEMINI.md also read | Text output to stdout; **JSON output format not confirmed**; exit codes unclear | GA (Feb 2026); ACP support; rapidly iterating | Multiple formats read: AGENTS.md, copilot-instructions.md, .agent.md, CLAUDE.md |
| **Cline CLI** | **Trial** | `cline "task"` headless, `-y` full autonomy, `--json` structured output, stdin/stdout piping | `.clinerules`, MCP servers, Skills, Hooks; ACP for cross-editor | NDJSON streaming, `--json` flag, full stdin/stdout, Unix pipe-friendly | CLI 2.0 (Feb 2026); 80.8% SWE-bench with Claude API; active open-source | `.clinerules` is Cline-specific; ACP is open protocol |
| **Continue CLI** | **Assess** | `cn -p` headless mode, `--config` for config switching, `--rule` for Mission Control rules | `config.yaml`, AGENTS.md, `--rule` flag, `@` file mentions, MCP tools | Final response only in headless; **no documented JSON output**; permission management via YAML | Early CLI; good design philosophy; cloud agents capability | config.yaml is Continue-specific; rules system |
| **Goose** | **Assess** | `goose run --no-session -t "task"`, recipes (YAML), `GOOSE_MODE=auto`, `GOOSE_MAX_TURNS` | AGENTS.md, recipe YAML files, environment variables, MCP extensions | Recipe-driven output (markdown/json/html); no native structured JSON stream; session-based | Apache 2.0; Block-backed; MCP-native; good extensibility | AGENTS.md + recipe YAML (open) |
| **Cursor CLI** | **Assess** | `-p` print mode, `--force` for file writes, `--output-format json\|stream-json\|text` | `.cursor/rules/` (.mdc files), `.cursorrules` (legacy), project-level only in headless | JSON and stream-JSON output; file modification gated behind `--force` | CLI exists but **headless has documented limitations** (approval flow blockers, no user-wide config) | .cursor/rules (.mdc) is Cursor-proprietary |
| **Windsurf** | **Hold** | No official headless CLI; community Docker wrapper with Xvfb hack | `.windsurfrules`, project-level; no headless instruction mechanism | No structured output; UI-dependent | IDE-first; no CLI-first strategy; headless is a community hack | .windsurfrules is Windsurf-proprietary |
| **Kilo CLI** | **Assess** | `--auto` autonomous mode, `--json` structured output, auto-exit on completion/timeout | AGENTS.md, model-agnostic config | `--json` with `--auto` for structured output; timeout-based exit | New (Feb 2026 CLI release); Cline fork; 25T+ tokens processed; active | AGENTS.md supported |
| **Amp** | **Assess** | CLI-only (editor extensions deprecated Mar 2026); headless mode; sub-agents | AGENTS.md, project/folder/global context | Sub-agent results; **structured output details unclear** | Sourcegraph-backed; CLI pivot is very recent (Mar 2026) | AGENTS.md supported |

#### 2. Feasibility Tiers

**Feasible today (build adapters now):**
- **Claude Code** -- Already the native delegation target. Richest headless API. JSON output, session management, custom agents.
- **Codex CLI** -- Best-designed automation interface (`codex exec`). JSONL streaming, JSON Schema output validation, session resume. The TypeScript SDK adds programmatic control beyond shell invocation.
- **Aider** -- Battle-tested scripting mode. Git-native output (commits as deliverables). Limitation: no structured JSON output means result parsing requires convention-based approaches (read the git diff).

**Feasible with caveats (trial adapters):**
- **Gemini CLI** -- Strong JSON output with stats. `-p` + `--output-format json` is clean. Caveat: Google auth model may complicate CI/headless environments.
- **Copilot CLI** -- `-p` mode works. Caveat: JSON output format not well-documented; GitHub subscription required; custom agent format (.agent.md) differs from others.
- **Cline CLI** -- NDJSON streaming is good. Caveat: very new CLI (Feb 2026); ACP protocol still stabilizing; depends on API keys to providers.

**Watch (not ready for delegation adapters):**
- **Continue CLI** -- Good design but no structured JSON output documented. Cloud agents are interesting but different paradigm.
- **Goose** -- Recipe system is powerful but different abstraction (YAML recipes vs. prompt delegation). Needs adapter translation.
- **Kilo CLI** -- Too new (Feb 2026). JSON output exists but production signals are insufficient.
- **Amp** -- CLI pivot just happened (Mar 2026). Wait for stabilization.
- **Cursor CLI** -- Headless has documented blockers around approval flows and config scoping. Not suitable for headless delegation yet despite having output format support.

**Not feasible (hold):**
- **Windsurf** -- No headless CLI. IDE-only. Community Docker hack is not a delegation target.

#### 3. Convergence Patterns to Exploit

Three convergence patterns make this the right time to build a delegation abstraction:

**a) Invocation convergence.** Nearly every tool has adopted the same pattern: `<tool> -p "prompt"` with `--output-format json`. This maps directly to a shell invocation adapter: `spawn(tool, ["-p", prompt, "--output-format", "json"])`.

**b) Instruction format convergence.** AGENTS.md is emerging as the cross-tool instruction file, now under the Linux Foundation. Tools that don't read AGENTS.md natively (Claude Code prefers CLAUDE.md) still have their own file-based instruction mechanisms that can be populated by the orchestrator. The adapter pattern: write a tool-specific instruction file before invocation, clean up after.

**c) Auto-approve convergence.** Every headless-capable tool has an "approve everything" flag (`--yes`, `--yolo`, `--allow-all-tools`, `--force`, `-y`, `--full-auto`). This is required for non-interactive delegation.

#### 4. What the Abstraction Layer Needs

Based on the landscape analysis, the delegation adapter for each tool needs to handle:

1. **Invocation** -- Tool binary detection, flag assembly, working directory, environment variables
2. **Instruction injection** -- Write the appropriate instruction file for the tool (CLAUDE.md, AGENTS.md, CONVENTIONS.md, .cursor/rules/, etc.) or pass instructions via flags
3. **Context provision** -- Specify which files the tool should read/edit (varies: `--read`, `@file`, `--include-directories`, positional args)
4. **Approval bypass** -- Set the tool-specific "auto-approve" flag
5. **Result collection** -- Parse stdout (JSON/JSONL/text), check exit codes, read git diffs, detect file changes
6. **Timeout and failure** -- Max execution time, graceful termination, error classification
7. **Cleanup** -- Remove temporary instruction files, reset tool-specific state

#### 5. Hype Filter Assessment

Applying the six-point hype detection methodology to the "multi-tool orchestration" concept:

1. **Production usage**: Claude Code headless is in production (CI/CD pipelines). Codex CLI exec is in production. Aider scripting is in production. Multi-tool orchestration across different harnesses -- **no public production signals yet**. This is a frontier use case.
2. **Community velocity**: The convergence on `-p` flag patterns and AGENTS.md shows organic community alignment, not top-down mandates. ACP protocol is gaining real adoption (Cline, Copilot, JetBrains, Zed). This is positive.
3. **Second-order signals**: Job postings mentioning "multi-agent orchestration" are increasing. Conference talks about tool-agnostic agent frameworks are appearing. But these are mostly about MCP-based orchestration, not cross-harness delegation.
4. **Failure stories**: Absent. Nobody is publicly failing at this because nobody is publicly doing it yet. This is an indicator of frontier territory.
5. **Benchmark independence**: SWE-bench is the cross-tool benchmark. It confirms that multiple tools achieve comparable results (Claude Code 80.9%, Cline 80.8%, Codex 77.3%). This validates that tool selection can be capability-matched.
6. **Revenue signal**: All major tools are VC-funded or big-tech subsidized. Pricing is not yet rationalized. This means the cost advantage of routing to cheaper tools is real but may shift.

**Verdict**: The individual tools are mature enough. The orchestration pattern is assess-ring -- interesting, no production precedent, worth building experimentally.

#### 6. Instruction Format Landscape

| Format | Owner | Tools That Read It | Status |
|--------|-------|--------------------|--------|
| **AGENTS.md** | Linux Foundation (Agentic AI Foundation) | Codex CLI, Copilot CLI, Gemini CLI, Cline, Goose, Kilo, Amp, Cursor, Windsurf, + growing | Emerging standard; 60k+ repos |
| **CLAUDE.md** | Anthropic | Claude Code (native), Copilot CLI (also reads) | Proprietary but widely adopted |
| **GEMINI.md** | Google | Gemini CLI (native), possibly others | Proprietary |
| **.cursorrules / .cursor/rules/** | Cursor | Cursor only | Proprietary; legacy format deprecated |
| **.clinerules** | Cline | Cline only | Proprietary |
| **.windsurfrules** | Windsurf | Windsurf only | Proprietary |
| **CONVENTIONS.md** | Aider | Aider (native) | Open convention but Aider-specific |
| **copilot-instructions.md** | GitHub | Copilot CLI/IDE | Proprietary |
| **.agent.md** | GitHub | Copilot CLI | Custom agent format |

**Recommendation**: Target AGENTS.md as the cross-tool instruction format. For Claude Code delegation (the current native path), continue using CLAUDE.md. The adapter layer should translate the orchestrator's internal instruction format into the tool-specific file before invocation.

#### 7. Emerging Protocol: ACP (Agent Client Protocol)

**Ring: Assess**

ACP is the most significant emerging protocol for this use case. Created by Zed, now implemented by Cline CLI, Copilot CLI, JetBrains, and others. ACP standardizes agent-editor communication the way LSP standardized language server integration.

Relevance to delegation: ACP could eventually provide a protocol-level abstraction for invoking any ACP-compatible agent, rather than shelling out with tool-specific flags. However, ACP is editor-focused (agent-to-editor), not orchestrator-focused (orchestrator-to-agent). It solves a related but different problem.

**Timeframe**: Monitor ACP for 6 months. If it gains an "orchestrator mode" or "headless server mode," it becomes a strong candidate for the delegation protocol layer. Today, shell invocation is the pragmatic choice.

---

### Proposed Tasks

#### Task 1: Tool Capability Matrix (Research Deliverable)

**What**: Produce a detailed capability matrix for the research report documenting each tool's headless invocation interface, instruction injection mechanism, result collection format, and auto-approve flags. Include version-pinned CLI examples.

**Deliverables**: Section in `docs/external-harness-delegation.md` (or similar) with per-tool reference cards.

**Dependencies**: None. This is the foundational reference.

#### Task 2: Invocation Pattern Analysis

**What**: Document the common invocation pattern that all headless-capable tools share (`-p` + JSON output + auto-approve) and the tool-specific deviations. Define the minimal adapter interface: `invoke(tool, prompt, context_files, instruction_text) -> {stdout, stderr, exit_code, changed_files}`.

**Deliverables**: Interface specification in the research report. Pseudocode or TypeScript type definition for the adapter contract.

**Dependencies**: Task 1.

#### Task 3: Instruction Format Translation Map

**What**: Document how the orchestrator's internal instruction format (currently CLAUDE.md-centric) maps to each target tool's instruction mechanism. Define the translation rules: which files to write, where to write them, what format to use, and how to clean up.

**Deliverables**: Translation table in the research report. Decision on whether AGENTS.md should become the canonical internal format.

**Dependencies**: Task 1.

#### Task 4: Result Collection Strategy

**What**: Analyze how each tool reports results (JSON, JSONL, git diffs, text, exit codes) and define a normalization strategy. This is the hardest part -- tools vary significantly in what they report and how.

**Deliverables**: Result normalization specification. Per-tool parsing rules. Failure detection heuristics.

**Dependencies**: Task 1, Task 2.

#### Task 5: Feasibility Tier Recommendations

**What**: Produce the final adopt/trial/assess/hold classification for each tool as a delegation target, with timeframe recommendations for when to build adapters and conditions for re-evaluation.

**Deliverables**: Summary table with ring, timeframe, and re-evaluation triggers.

**Dependencies**: Tasks 1-4.

---

### Risks and Concerns

#### Risk 1: Result Collection Fragility (HIGH)

The biggest risk is not invocation (that's converged) but result collection. Tools vary dramatically in what they return:
- Claude Code and Codex CLI: rich JSON with tool traces
- Aider: git commits (no JSON output at all)
- Copilot CLI: text output with unclear JSON support
- Goose: recipe-dependent output format

An adapter that works for one tool may silently fail for another. **Mitigation**: Define a minimal result contract (exit code + changed files list) that every adapter must satisfy, with richer output as optional enhancement.

#### Risk 2: Instruction Injection Race Conditions (MEDIUM)

Writing a temporary AGENTS.md or CONVENTIONS.md before tool invocation creates a race condition if multiple delegations run in parallel in the same working directory. Each tool may read different instruction files at different times.

**Mitigation**: Use git worktree isolation (already supported by the orchestrator) to give each delegation its own working directory. Alternatively, use flag-based instruction injection where available (`--message`, `--system-prompt`) rather than file-based.

#### Risk 3: Auto-Approve Safety (MEDIUM)

Every delegation requires auto-approve (`--yes`, `--yolo`, `--full-auto`). This means the delegated tool has full write access to the working directory. A misbehaving tool could corrupt the repository. (Note: credential/trust boundary analysis is out of scope per the planning question, but this is an adjacent concern.)

**Mitigation**: Worktree isolation limits blast radius. Pre-delegation git commit creates a rollback point. Post-delegation git diff validates changes are within expected scope.

#### Risk 4: Tool Availability and Version Drift (MEDIUM)

The adapter layer depends on specific CLI flags that can change between versions. A tool update could break an adapter silently.

**Mitigation**: Pin tool versions in the adapter configuration. Include version detection at invocation time. Design adapters to fail loudly on unrecognized output.

#### Risk 5: ACP Protocol Disruption (LOW, long-term)

If ACP becomes the standard orchestration protocol, the shell-invocation adapter layer may become obsolete. Building it now is not wasted work (shell invocation will always work), but the long-term architecture may shift.

**Mitigation**: Design the adapter interface to be protocol-agnostic. A future ACP adapter would implement the same interface as the shell adapter.

#### Risk 6: AGENTS.md Spec Instability (LOW)

AGENTS.md just moved to the Linux Foundation. The spec could evolve in ways that break assumptions. However, the format is "just Markdown" with no schema requirements, which limits the blast radius of spec changes.

**Mitigation**: Treat AGENTS.md as a content delivery mechanism, not a contract. The orchestrator owns the content; AGENTS.md is just the file name.

---

### Additional Agents Needed

- **mcp-minion**: ACP (Agent Client Protocol) is structurally similar to MCP -- both are JSON-RPC protocols for agent communication. The mcp-minion should evaluate whether the delegation abstraction should be built on ACP rather than shell invocation, or whether an MCP-to-ACP bridge makes sense. MCP expertise is needed to assess protocol-level delegation vs. shell-level delegation.

- **test-minion**: The adapter layer will need a testing strategy that covers multiple external tools (most of which require API keys and have rate limits). The test-minion should contribute to how we design testable adapters without requiring every tool to be installed and authenticated in CI.

Otherwise, the current planning team is sufficient. The research report itself does not require security-minion (credential/trust boundaries are explicitly out of scope) or frontend specialists.
