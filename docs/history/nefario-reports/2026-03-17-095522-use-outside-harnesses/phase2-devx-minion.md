## Domain Plan Contribution: devx-minion

### Recommendations

#### 1. Invocation: Config-Driven, Transparent to the Orchestrator

The wrapper should be **invisible to nefario**. The orchestrator should continue to think in terms of "spawn agent X with prompt Y" -- the routing decision (Claude Code subagent vs. external tool) happens in a resolution layer between the orchestrator and the execution surface. This is the facade pattern: nefario calls the same conceptual interface; the facade decides which backend handles it.

**Why not a CLI subcommand?** A subcommand (e.g., `despicable delegate --tool aider --agent security-minion`) forces the orchestrator to know about tool routing, which violates separation of concerns. Nefario should not care whether security-minion runs in Claude Code or Aider -- it cares about the prompt, the deliverables, and the result.

**Why not purely transparent?** Some user visibility is essential. The user must be able to see and override which tool handles which agent, because tool capabilities vary (Aider has no Bash tool, Cursor cannot be scripted headlessly). A configuration file declares the routing; the orchestrator reads it but does not reason about it.

**Recommended approach**: A `harnesses.toml` configuration file at the project root (or `~/.claude/harnesses.toml` for global defaults) that maps agents to external tools. The orchestrator's Phase 4 execution loop reads this file to determine how to spawn each agent. If no entry exists for an agent, the default is Claude Code subagent (current behavior, zero-config for 80% of users).

#### 2. Configuration Format: TOML with AGENT.md Field Mapping

TOML is the right format for this configuration. Rationale:
- It supports comments (unlike JSON), which is critical for a file where users explain *why* they routed an agent to a specific tool
- It is stricter than YAML, preventing indentation-error surprises in a file that directly controls execution routing
- It handles flat-to-moderately-nested structures well, which matches the mapping schema
- It is familiar to Rust/Python ecosystems that overlap with CLI tool users

**Proposed schema**:

```toml
# harnesses.toml -- Route agents to external coding tools
# Agents not listed here use the default Claude Code subagent.

[defaults]
harness = "claude-code"  # "claude-code" | "aider" | "codex" | "cursor"
timeout = 600            # seconds, per-agent execution cap

[harness.aider]
command = "aider"
args = ["--message", "{prompt}", "--no-stream", "--yes"]
instruction-injection = "read-file"     # "read-file" | "flag" | "env"
instruction-file = ".aider.conventions.md"
result-collection = "git-diff"          # "git-diff" | "stdout" | "file"
working-directory = "inherit"           # "inherit" | "worktree"

[harness.codex]
command = "codex"
args = ["-p", "{prompt}", "--json"]
instruction-injection = "agents-md"     # uses AGENTS.md convention
instruction-file = "AGENTS.md"
result-collection = "stdout-json"

[harness.cursor]
# Cursor cannot be invoked headlessly -- flag as interactive-only
interactive = true
instruction-injection = "cursor-rules"  # writes .cursor/rules/*.mdc
instruction-file = ".cursor/rules/{agent-name}.mdc"
result-collection = "git-diff"

# Per-agent overrides
[agent.security-minion]
harness = "aider"
model = "claude-sonnet-4-20250514"  # override model for this tool

[agent.frontend-minion]
harness = "cursor"
# Cursor is interactive; orchestrator pauses and prompts user
```

**AGENT.md field mapping**: The five-section system prompt needs translation rules per harness:

| AGENT.md Section | Claude Code | Aider | Codex CLI | Cursor |
|-----------------|-------------|-------|-----------|--------|
| Frontmatter `name` | `subagent_type` | N/A (no agent concept) | N/A | N/A |
| Frontmatter `model` | `model` param | `--model` flag | `--model` flag | Settings UI (not scriptable) |
| Identity + Core Knowledge | System prompt (automatic) | `--read` convention file | AGENTS.md content | `.cursor/rules/*.mdc` |
| Working Patterns | System prompt (automatic) | Appended to `--read` file | AGENTS.md content | `.cursor/rules/*.mdc` |
| Output Standards | System prompt (automatic) | Appended to `--read` file | AGENTS.md content | `.cursor/rules/*.mdc` |
| Boundaries | System prompt (automatic) | Appended to `--read` file | AGENTS.md content | `.cursor/rules/*.mdc` |
| Task prompt | `prompt` field | `--message` flag | `-p` flag | Chat input (manual) |

The key insight: all external tools accept some form of "persistent instruction" (conventions file, AGENTS.md, cursor rules) and a "per-task prompt" (`--message`, `-p`, chat). The wrapper must split the AGENT.md content into these two channels.

#### 3. Error Experience: Three-Component Error Messages with Recovery Paths

External tool failures are fundamentally different from Claude Code subagent failures. A subagent failure stays within the Claude Code process boundary. An external tool failure crosses process boundaries, involves different exit codes, different output formats, and potentially different file system states.

**Error taxonomy** the report should define:

| Error Class | Example | Recovery Path |
|-------------|---------|---------------|
| Tool not found | `aider: command not found` | "Install aider: pip install aider-chat. Then re-run." |
| Tool auth failure | Aider cannot authenticate with API provider | "Set ANTHROPIC_API_KEY or check aider auth: aider --check-update" |
| Tool timeout | Agent exceeds `timeout` in harnesses.toml | "Increase timeout in harnesses.toml [agent.X] or split the task" |
| Tool exit non-zero | Aider exits 1 with stderr | Show last 20 lines of stderr, suggest checking tool logs |
| No output produced | Tool ran but git diff is empty | "Agent completed but produced no changes. Check if the task was too vague or the tool lacks necessary capabilities." |
| Result parse failure | Expected JSON from codex, got plaintext | "Codex output was not valid JSON. Raw output saved to scratch. Check codex version." |
| Interactive tool blocked | Cursor routed but session is non-interactive | "cursor harness requires interactive mode. Use --interactive or route to a headless harness." |

**Error message format** (three components, consistent with devx best practice):

```
ERROR [harness:aider] security-minion failed (exit 1, 45s elapsed)

What happened: aider exited with code 1 after processing security-minion's task.
              Last output: "Model claude-sonnet-4-20250514 not available"

How to fix:   1. Check model availability: aider --list-models
              2. Override model in harnesses.toml: [agent.security-minion] model = "..."
              3. Or route back to Claude Code: remove [agent.security-minion] from harnesses.toml

More info:    Scratch file: /tmp/nefario-scratch-xyz/slug/phase4-security-minion-stderr.log
              Aider docs:   https://aider.chat/docs/troubleshooting.html
```

**Partial success handling**: When an external tool produces some output but also errors (e.g., modified 3 files but crashed on the 4th), the wrapper should:
1. Capture the partial result (git diff of what was produced)
2. Report the error with what succeeded and what failed
3. Let the orchestrator decide: accept partial, retry the failed portion, or fall back to Claude Code

#### 4. Report Coverage on DX

The research report should cover these DX-specific sections:

**A. Invocation ergonomics**: How the wrapper fits into the existing install/deploy workflow. Should `install.sh` validate harness availability? Should there be a `./install.sh --check-harnesses` subcommand?

**B. Configuration discoverability**: Where does `harnesses.toml` live, how is it discovered (project root, then `~/.claude/`, then built-in defaults), and what happens when it is missing (silent default to Claude Code -- zero-config).

**C. First-run experience**: What happens the first time a user adds an external harness? The report should recommend a `--dry-run` flag that shows what would be spawned without executing, so users can verify routing before committing to a long orchestration.

**D. Error message catalog**: A table of all error conditions with their three-component messages. This is documentation that writes itself once and prevents thousands of support questions.

**E. Observability for the user**: During Phase 4 execution, the user should see which harness is handling each agent. The CONDENSE lines should include the harness name: "Executing: security-minion (aider), frontend-minion (cursor)..." This is non-negotiable for trust -- users must know what is running where.

**F. Escape hatches**: How to override routing mid-session (e.g., "security-minion failed in aider, re-run in Claude Code"). The report should define whether this is a harnesses.toml edit + re-run, or a runtime override flag.

**G. Instruction format translation fidelity**: The report should document known lossy translations. For example, AGENT.md `tools:` field has no equivalent in Aider (Aider always has file edit capability, never has Bash). The `model:` field may not map to the same model name across providers. These are not bugs to fix -- they are constraints to document clearly so users set correct expectations.

### Proposed Tasks

**Task 1: Document harness instruction formats**
- What: Research and document how each target tool (Aider, Codex CLI, Cursor, Gemini CLI) accepts instructions, prompts, and configuration. Create a comparison matrix.
- Deliverables: Section in research report covering instruction injection formats per tool, with field-by-field mapping from AGENT.md.
- Dependencies: None (pure research).

**Task 2: Design harnesses.toml schema**
- What: Define the complete TOML schema for harness configuration, including defaults, per-harness settings, per-agent overrides, and validation rules. Include a JSON Schema or TOML schema definition for editor autocompletion.
- Deliverables: Schema definition in the research report. Example `harnesses.toml` for a multi-tool setup. Validation error messages for invalid configuration.
- Dependencies: Task 1 (needs to know what fields each tool requires).

**Task 3: Design error taxonomy and message catalog**
- What: Define all error conditions that can arise from external tool delegation, with three-component error messages (what happened, how to fix, more info) for each.
- Deliverables: Error taxonomy table and message templates in the research report.
- Dependencies: Task 1 (needs to know tool-specific failure modes).

**Task 4: Design observability and dry-run UX**
- What: Define how harness routing is surfaced to the user during orchestration (CONDENSE line format, Phase 4 status updates, dry-run output format).
- Deliverables: Section in research report covering user-facing output during external tool delegation.
- Dependencies: Task 2 (needs the configuration model to show what dry-run output looks like).

**Task 5: Document known translation fidelity gaps**
- What: For each harness, document which AGENT.md fields cannot be faithfully translated and what the user should expect. Frame as constraints documentation, not missing features.
- Deliverables: Fidelity matrix in the research report (AGENT.md field x harness, with "full", "partial", "unsupported" ratings and notes).
- Dependencies: Task 1.

### Risks and Concerns

**Risk 1: Interactive-only tools break the orchestration contract.** Cursor cannot be scripted headlessly as of March 2026. If a user routes an agent to Cursor, the orchestration must pause and hand control to the user. This is a fundamental impedance mismatch with the batch-gated execution model. The report must clearly delineate "headless-capable" harnesses (Aider, Codex CLI, Claude Code) from "interactive-only" harnesses (Cursor) and define different UX for each.

**Risk 2: Configuration complexity creep.** The harnesses.toml schema could grow unbounded as each tool requires different flags, auth mechanisms, and output formats. Mitigation: keep the schema minimal (command, args, instruction-injection method, result-collection method) and push tool-specific complexity into the tool's own configuration files (`.aider.conf.yml`, `AGENTS.md`, `.cursor/rules/`). The harness config should be a thin routing layer, not a superset of every tool's config.

**Risk 3: Model name fragmentation.** The `model` field in AGENT.md says "opus" or "sonnet" -- these are Claude-specific shorthands. External tools use different model identifiers (`claude-sonnet-4-20250514`, `gpt-4o`, `gemini-2.0-flash`). The translation layer needs a model alias map, or the per-agent override in `harnesses.toml` must always specify the full model identifier for non-Claude Code harnesses.

**Risk 4: Result collection reliability.** Different tools return results differently (stdout, git diff, JSON). If the wrapper relies on git diff for result collection but the tool made changes outside the expected file set (or made no changes at all), the orchestrator will have incorrect information about what was produced. The report must define a result validation step.

**Risk 5: Auth proliferation.** Each external tool needs its own API keys. Aider needs `ANTHROPIC_API_KEY` or `OPENAI_API_KEY`; Codex CLI needs `OPENAI_API_KEY`; Cursor uses its own auth. The first-run experience for adding a new harness will involve auth setup that is outside the despicable-agents framework's control. The report should document this as a known friction point and recommend linking to each tool's auth setup docs in the error messages.

**Risk 6: YAGNI tension.** This framework supports 27 agents. The overwhelming majority of users will never route any of them to an external tool. The configuration layer must be strictly zero-cost for users who do not use it -- no new files required, no new flags, no changed behavior. If `harnesses.toml` does not exist, everything works exactly as it does today. This is the most important DX requirement.

### Additional Agents Needed

**test-minion** should be consulted on how external tool outputs would be validated. When a result comes back from Aider as a git diff, how does the orchestrator verify it meets the task requirements? Test-minion can advise on validation patterns for externally-produced code. (Note: test-minion may already be in the cross-cutting review set for Phase 3.5, but should be explicitly asked about external result validation during planning.)

Otherwise, the current team (ai-modeling-minion for abstraction layer design, mcp-minion for protocol research, software-docs-minion for report structure, lucy for consistency, gru for strategic landscape) is sufficient.
