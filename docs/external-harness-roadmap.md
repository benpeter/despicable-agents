[< Back to Architecture Overview](architecture.md) | [Feasibility Study](external-harness-integration.md)

# External Harness Integration Roadmap

*Last assessed: 2026-03-17*

## How to Use This Document

Each milestone maps to a GitHub milestone; each issue maps to a GitHub issue (linked by `#number`). This document is the historical record of the original scope and rationale. Do not update issue content here after filing -- track changes in the issue tracker.

## Scope and Boundaries

**In scope** (Milestones 1-4):
- Adapter layer: `DelegationRequest`/`DelegationResult` interface
- Routing configuration surface (`.nefario/routing.yml`)
- Codex CLI adapter (first concrete implementation)
- Aider adapter (validates abstraction works without structured output)
- LLM-based diff summarization service (shared by Aider and future adapters)
- Phase 4 routing dispatch in the orchestrator

**Out of scope** (do not add to these milestones):
- Nefario planning Phases 1-3.5 (unchanged)
- AGENT.md format changes
- Quality outcome tracking by the framework
- A2A or ACP protocol integrations
- Gemini CLI and beyond (Future Milestones)

**Nefario change boundary**: Only Phase 4 execution routing is modified. The orchestrator continues to think in terms of agents and prompts. Routing decisions live in configuration, not planning logic.

**YAGNI constraint**: Build only the Codex adapter concretely in Milestone 2. Extract the shared adapter interface after Aider (Milestone 3) validates the abstraction. Do not design the interface in isolation before two implementations exist.

---

## Milestone 1: Adapter Foundation

Shared types, configuration schema, and instruction translation. No tool invocation yet. All subsequent milestones depend on this one.

### #138: Adapter Interface Definition

**Goal**: Define the `DelegationRequest` and `DelegationResult` types that all adapters implement.

**Scope**:
- `DelegationRequest`: agent name, task prompt (already stripped of Claude Code-specific instructions), instruction file path, working directory, model tier (`opus` | `sonnet`), required tools list
- `DelegationResult`: exit code, changed files (from git diff), stdout summary, stderr, raw diff reference
- No implementation -- types and contracts only
- Language/format matches the surrounding codebase (document the decision; do not assume)

**Depends on**: nothing

**Acceptance criteria**:
- Types are defined and documented
- Interface is minimal -- covers Codex and Aider use cases, nothing more
- No harness-specific fields in the shared types

### #139: Routing Configuration Schema

**Goal**: Define the YAML schema for `.nefario/routing.yml` and implement config loading with validation.

**Scope**:
- Schema: `default` harness, optional `groups` (per-agent-group), optional `agents` (per-agent), optional `model-mapping` (tier → provider ID per harness)
- Resolution order: agent > group > default > implicit `claude-code`
- Capability gating: validate agent `tools:` requirements against harness capability list at load time; hard error with actionable message on mismatch
- Zero-config path: no file present means everything routes to `claude-code`
- Config loading reads from project-level `.nefario/routing.yml` and optional user-level override

**Depends on**: #138

**Acceptance criteria**:
- Config loads and validates without error for the minimal (`default: claude-code`) and power-user examples from the feasibility study
- Capability gating rejects a config that routes a web-research agent to Aider with a clear error message
- Zero-config path routes all tasks to `claude-code`

**Notes**: No "did you mean?" suggestions, no JSON Schema output, no CI/CD env var overrides -- these are premature for a first implementation.

### #140: AGENT.md Instruction Translator

**Goal**: Translate an AGENT.md file to a tool-native instruction file (AGENTS.md or CONVENTIONS.md), stripping frontmatter and Claude Code-specific content.

**Scope**:
- Strip YAML frontmatter entirely; pass frontmatter fields as adapter runtime config (not written to instruction file)
- Strip Claude Code-specific task instructions (TaskUpdate, SendMessage, scratch directory conventions) from the Markdown body
- Write tool-native file: AGENTS.md format for Codex CLI; CONVENTIONS.md format for Aider
- Translator is invoked per delegation call; output is a temporary file cleaned up after the harness exits

**Depends on**: #138

**Acceptance criteria**:
- Output file contains no YAML frontmatter
- Output file contains no TaskUpdate, SendMessage, or scratch file references
- Output is valid Markdown readable by the target tool

---

## Milestone 2: Codex CLI Adapter

First concrete adapter. Uses the foundation from Milestone 1. Codex is prioritized because it has the best-designed automation interface and structured output.

### #141: Codex CLI Invocation Wrapper

**Goal**: Implement a subprocess wrapper that invokes Codex CLI headlessly from a `DelegationRequest`.

**Scope**:
- Invoke via `codex exec` with `--full-auto`, `--json` JSONL stream, and prompt via `-p` or `--message-file` for long prompts
- Write translated AGENTS.md before invocation; clean up after
- Pass model tier via routing config's `model-mapping` (e.g., `opus → o3`)
- Configurable timeout; fail with non-zero exit on timeout
- Version-pin: record the Codex CLI version used during validation; document minimum version requirement

**Depends on**: #138, #139, #140

**Acceptance criteria**:
- Wrapper invokes Codex and returns a `DelegationResult`
- Timeout is enforced
- Temporary instruction files are cleaned up on both success and failure
- Uses CLI invocation, not the TypeScript SDK

**Notes**: Use the CLI (`codex exec`), not the TypeScript SDK. The CLI is the stable, version-pinned interface. SDK adds a dependency with its own versioning concerns.

### #144: Codex Result Collector

**Goal**: Parse Codex JSONL output and git diff into a structured `DelegationResult`.

**Scope**:
- Parse JSONL event stream for final output event and exit code
- Collect git diff of changed files in the working directory after invocation
- Use `--output-schema` when a schema is available to enforce structured final output
- Populate `DelegationResult` fields from parsed output

**Depends on**: #141

**Acceptance criteria**:
- Changed files list is accurate (matches `git diff --name-only`)
- Exit code is correctly propagated
- Non-zero exit code results in a `DelegationResult` that the orchestrator can distinguish from success

### #146: Codex Adapter Validation

**Goal**: Validate the Codex adapter with representative tasks before declaring it production-ready.

**Scope**:
- Run five representative task types: pure code edit, code edit with test, documentation update, refactor, research-then-write
- Record results: did the task complete, were changed files accurate, was the summary useful?
- Note quality observations (not for automated tracking -- for the validation report)
- Identify any interface gaps between `DelegationRequest`/`DelegationResult` and Codex behavior

**Depends on**: #144

**Acceptance criteria**:
- All five task types complete without adapter errors
- Validation report documents outcomes and any interface adjustments needed before Milestone 3

---

## Milestone 3: Aider Adapter + Result Summarization

Second concrete adapter. Validates that the abstraction holds for a tool without structured JSON output. Introduces shared LLM-based diff summarization.

### #142: Result Summarization Service

**Goal**: Implement a reusable service that generates a structured summary from a git diff and the original task prompt.

**Scope**:
- Input: unified diff (from `git diff`) + original task prompt
- Output: structured summary matching `DelegationResult.stdout_summary` (changed files, scope description, purpose)
- Use a small fast model; target <$0.01 per call, <5 second latency
- Reusable by any adapter that lacks native structured output (Aider today; others potentially later)

**Depends on**: #138

**Acceptance criteria**:
- Service returns a structured summary for a representative set of diffs
- Cost per call is under $0.01 on a 500-line diff
- Latency is under 5 seconds on a 500-line diff

### #143: Aider Invocation Wrapper

**Goal**: Implement a subprocess wrapper that invokes Aider headlessly from a `DelegationRequest`.

**Scope**:
- Invoke via `aider --message` + `--yes` for single-shot execution
- Write CONVENTIONS.md before invocation; clean up after
- Pass model via routing config `model-mapping`
- Enable `--auto-commits` so git commits serve as the output signal
- Capability gating: reject tasks requiring Bash or WebSearch (Aider does not support these)

**Depends on**: #138, #139, #140

**Acceptance criteria**:
- Wrapper invokes Aider and returns a `DelegationResult`
- Capability gating rejects incompatible tasks before invocation
- Temporary instruction files are cleaned up on both success and failure

### #145: Aider Result Collector

**Goal**: Collect results from an Aider invocation using git diff and LLM summarization.

**Scope**:
- Collect git diff of commits made since invocation start
- Pass diff + original task prompt to the Result Summarization Service (#142)
- Populate `DelegationResult` from exit code, diff, and summary

**Depends on**: #142, #143

**Acceptance criteria**:
- Changed files list matches git commits made during the Aider invocation
- Summary is populated for all successful invocations
- Non-zero exit code is correctly propagated

### #147: Aider Adapter Validation + Abstraction Check

**Goal**: Validate the Aider adapter with the same five representative tasks used for Codex, and assess whether the shared interface held.

**Scope**:
- Run the same five task types as #146
- Record results and quality observations
- Assess interface health: did `DelegationRequest`/`DelegationResult` cover Aider without Codex-specific leakage?
- Document interface adjustments needed (if any) and whether they would require Codex adapter changes

**Depends on**: #145

**Acceptance criteria**:
- All five task types complete without adapter errors (tasks requiring Bash/WebSearch are correctly rejected)
- Interface health check documents whether abstraction held or requires adjustment

---

## Milestone 4: Orchestrator Integration

Wire the adapter layer into nefario's Phase 4 execution. Nefario remains unaware of which tool executes each task.

### #148: Phase 4 Routing Dispatch

**Goal**: Replace the unconditional Task tool invocation in Phase 4 with a routing dispatch that consults `.nefario/routing.yml`.

**Scope**:
- At Phase 4 entry, load routing config (or use default if absent)
- Resolve harness for each task (agent > group > default)
- Route to Codex or Aider adapter if configured; fall through to existing Task tool invocation for `claude-code`
- No change to how nefario plans or constructs task prompts

**Depends on**: #144, #145

**Acceptance criteria**:
- Tasks with no routing config route to `claude-code` via existing Task tool (zero regression)
- Tasks routed to Codex or Aider invoke the respective adapter
- Nefario prompt construction is unchanged

### #149: Progress Monitoring Integration

**Goal**: Surface progress signals from Codex and Aider adapters into nefario's Phase 4 monitoring loop.

**Scope**:
- Codex: stream JSONL progress events to a log or status display during execution
- Aider: no progress stream available; treat as opaque until completion (consistent with current behavior for non-streaming subagents)
- No progress contract defined for future tools -- monitor only what Codex and Aider provide today

**Depends on**: #148

**Acceptance criteria**:
- Codex JSONL events are surfaced during task execution (format TBD at implementation)
- Aider tasks are opaque until completion with no error
- No interface defined for "future tool progress" -- only Codex and Aider

---

## Future Milestones

These are headline-level only. Scope and sequencing depend on Milestone 1-4 outcomes.

**M5: Gemini CLI Adapter** -- Third adapter after Codex and Aider. Clean JSON output and token usage stats. Primary constraint is Google auth friction in headless environments. Defer until M4 is complete and auth story is clearer.

**M6: Capability-Based Routing** -- Automatic harness selection based on agent tool requirements and task type, rather than explicit config. Requires quality and reliability data from M2-M4 validation runs. Do not design routing heuristics before that data exists.

**M7: Quality Outcome Logging** -- Optional user-side tooling to log task outcomes per harness, enabling informed routing config decisions. This is not a framework feature -- the framework does not track quality. If built, it lives outside the adapter layer as a separate opt-in tool.

**M8: Hardening** -- Retry logic, structured error categories (retryable vs. fatal), cost tracking integration, and adapter version management. Scope driven by operational experience from M1-M4.

---

## Dependencies

| Issue | Depends on | Reason |
|-------|-----------|--------|
| #139 | #138 | Config references types from interface definition |
| #140 | #138 | Translator produces instruction files consumed by adapters |
| #141 | #138, #139, #140 | Wrapper needs types, config loading, and instruction translation |
| #144 | #141 | Result collector operates on wrapper output |
| #146 | #144 | Validation requires a working adapter |
| #142 | #138 | Summarization service references result types |
| #143 | #138, #139, #140 | Same as Codex wrapper |
| #145 | #142, #143 | Collector combines diff (from wrapper) and summarization |
| #147 | #145 | Validation requires a working adapter |
| #148 | #144, #145 | Dispatch needs at least Codex and Aider adapters |
| #149 | #148 | Monitoring hooks into the dispatch loop |

---

## Risks

| Risk | Likelihood | Impact | Mitigation |
|------|-----------|--------|-----------|
| Codex CLI interface changes between versions | Medium | Medium | Version-pin at validation (#146); document minimum version |
| Aider result collection is unreliable for large diffs | Low | Medium | Test with large diffs in #147; fall back to diff-only result if summarization fails |
| AGENTS.md spec evolves post-Linux Foundation transfer | Medium | Low-Medium | Translator (#140) is isolated; updates require only one file change |
| Instruction isolation: external tools read conflicting project config | Medium | Medium | Document as known limitation (open question in feasibility study); investigate per-tool config override in #147 |
| Interface abstraction does not hold after two implementations | Low | High | #147 explicitly checks interface health; adjust before M4 if needed |

---

## What NOT to Build

YAGNI constraints for Milestones 1-4:

- **No TypeScript orchestrator** -- adapter layer integrates into the existing shell/scripting approach; do not introduce a new runtime
- **No containerization** -- adapters run in the same working directory as the orchestrator; no Docker or isolation layer
- **No automatic routing heuristics** -- routing is always explicit config; no ML-based task-to-harness matching
- **No A2A or ACP integration** -- CLI subprocess is the chosen invocation mechanism; protocol layers add complexity with zero ecosystem benefit today
- **No configuration UI** -- `.nefario/routing.yml` is edited directly; no GUI, no wizard
- **No quality tracking in the framework** -- quality parity is the user's responsibility; the adapter layer does not record or compare outcomes across harnesses
- **No "did you mean?" config suggestions** -- validation raises a clear error; no fuzzy matching on harness names or agent names
