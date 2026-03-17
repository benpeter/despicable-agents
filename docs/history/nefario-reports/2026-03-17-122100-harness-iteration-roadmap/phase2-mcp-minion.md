# Phase 2 Contribution: mcp-minion -- Adapter Protocol & Instruction Translation

## Question Addressed

Three questions from the meta-plan:

1. What should the adapter interface look like (exact shape)?
2. Should adapters strip AGENT.md frontmatter entirely or translate it?
3. Where does LLM-based diff summarization land in the roadmap?

---

## 1. Adapter Interface Shape

### Design Principles

The adapter interface is a protocol bridge. It must follow the same design principles as any good protocol contract:

- **Self-contained per call**: Each invocation carries everything needed. No shared state between calls. (Same principle as MCP tool handlers -- create connections per call, not at server start.)
- **Dual output format**: Return both human-readable text and structured data. The orchestrator needs structured data for routing decisions; the report needs human-readable summaries.
- **Idempotent where possible**: Same inputs should produce deterministic invocation (though the LLM output itself is non-deterministic, the adapter's behavior is).

### Proposed Interface

The adapter contract has two halves: **invocation** (orchestrator to adapter) and **result** (adapter to orchestrator).

#### Invocation Input

```typescript
interface DelegationRequest {
  // What to do
  prompt: string;              // The self-contained task prompt (already Claude Code-specific
                               // instructions stripped by the orchestrator)
  instructionFile?: string;    // Path to generated instruction file (AGENTS.md, CONVENTIONS.md, etc.)
                               // Adapter writes this before invocation, cleans up after.

  // Runtime configuration (from routing config, not from AGENT.md frontmatter)
  model?: string;              // Provider-specific model identifier (e.g., "o3", "o4-mini", "gemini-2.5-pro")
                               // If omitted, tool uses its default.
  qualityTier?: "high" | "standard";  // Optional: orchestrator's intent signal. Adapters
                               // that support tier-to-model mapping use this when `model` is not set.
  autoApprove: boolean;        // Whether the tool should auto-approve all actions
  timeout?: number;            // Max execution time in ms. Adapter enforces via process timeout.
  workingDirectory: string;    // Absolute path to the working directory (worktree root)

  // Context
  contextFiles?: string[];     // Additional files to pass via --read or equivalent flags
  environment?: Record<string, string>;  // Environment variables for the subprocess
}
```

#### Result Output

```typescript
interface DelegationResult {
  // Completion status
  exitCode: number;            // 0 = success, non-zero = failure
  status: "completed" | "failed" | "timeout";

  // File changes (the primary deliverable)
  changedFiles: FileChange[];  // Derived from git diff (always available)

  // Semantic summary
  summary: string;             // Human-readable summary of what was done.
                               // Source varies by adapter:
                               // - Codex: extracted from structured JSON output
                               // - Aider: LLM-summarized from git diff (see section 3)
                               // - Others: parsed from stdout

  // Raw output (for debugging, not for orchestrator logic)
  stdout?: string;             // Truncated to last N lines if large
  stderr?: string;             // Always captured

  // Cost tracking (optional, best-effort)
  usage?: {
    inputTokens?: number;
    outputTokens?: number;
    model?: string;            // Actual model used (may differ from requested)
    durationMs: number;        // Wall clock time
  };
}

interface FileChange {
  path: string;                // Relative to workingDirectory
  action: "added" | "modified" | "deleted" | "renamed";
  linesAdded: number;
  linesRemoved: number;
}
```

### Why This Shape

**`prompt` is a string, not structured data.** The orchestrator already constructs self-contained prompts with scope, constraints, and deliverables embedded. The adapter does not need to understand prompt structure -- it passes it through. This preserves the current delegation contract where nefario's synthesis output is the prompt.

**`instructionFile` is a path, not content.** The adapter writes the instruction file to disk before invocation (because tools discover instruction files by filesystem convention, not by parameter passing). The adapter owns the lifecycle: write before, clean up after. This avoids polluting the repo with adapter-generated files.

**`changedFiles` is always derived from git diff.** Every feasible-now tool operates in a git repo. `git diff --stat HEAD` after invocation is the universal, tool-agnostic way to collect file changes. This is more reliable than parsing tool-specific output formats.

**`summary` source varies by adapter.** This is the key design decision. Codex gives structured JSON, so summary extraction is mechanical. Aider gives only git diffs, so summary requires LLM-based extraction. The interface is the same; the implementation cost differs. The orchestrator does not need to know which path was taken.

**`qualityTier` is an intent signal, not a command.** Some tools have fixed model sets (Codex uses OpenAI models only). The tier lets the orchestrator express "this task needs the best model you have" without knowing provider-specific model names. Adapters map tiers to models. If `model` is set explicitly, it overrides tier.

### What the Interface Does NOT Include

- **Multi-turn conversation**: External tools run single-shot. If the orchestrator needs clarification, it spawns a new delegation. This matches the current subagent model where Task invocations are one-shot.
- **Progress streaming**: The interface is request-response, not streaming. Progress monitoring (Codex JSONL, Cline NDJSON) is an adapter-internal concern. The orchestrator waits for completion. This is simpler than the current TaskList polling and more reliable.
- **Tool restriction**: Unlike Claude Code's `--allowedTools`, most external tools have binary auto-approve (all or nothing). The interface does not try to express fine-grained tool restrictions because most targets cannot enforce them. Tasks requiring restricted tool access should stay on Claude Code.
- **Structured output schema**: Codex supports `--output-schema` for JSON Schema validation on output. This is powerful but Codex-specific. The adapter interface uses `summary` (string) as the common denominator. Adapters that support richer output can parse it into the summary field. A future iteration could add an optional `structuredOutput` field when more tools support it.

---

## 2. Frontmatter Handling: Strip and Pass as Runtime Config

### Recommendation: Strip entirely. Pass as runtime config.

The AGENT.md frontmatter fields (`name`, `model`, `tools`, `memory`, `x-plan-version`, `x-build-date`) are Claude Code runtime parameters. They have no cross-tool equivalents and should not appear in translated instruction files.

The adapter should:

1. **Strip all frontmatter** when generating the instruction file (AGENTS.md, CONVENTIONS.md, etc.).
2. **Extract actionable fields** into `DelegationRequest` properties:
   - `model:` -> `DelegationRequest.model` (after translation via routing config)
   - `tools:` -> Not translatable. If the task requires specific tool restrictions, the routing config should keep it on Claude Code.
   - `name:`, `memory:`, `x-plan-version:`, `x-build-date:` -> Discarded. These are Claude Code metadata with no external equivalent.
3. **Pass only the Markdown body** (the five-section system prompt: Identity, Core Knowledge, Working Patterns, Output Standards, Boundaries) to the instruction file.

### Why Not a Translation Step

A translation step (mapping frontmatter fields to tool-native equivalents) would require maintaining a mapping table for every tool. The mapping is inherently lossy:

| Frontmatter Field | Codex Equivalent | Aider Equivalent | Gemini Equivalent |
|---|---|---|---|
| `model: opus` | `--model o3` (not equivalent) | `--model <provider-dependent>` | N/A (Gemini models only) |
| `tools: Read, Write, Bash` | No equivalent (all tools always available) | No equivalent (fixed tool set) | No equivalent |
| `memory: user` | No equivalent | No equivalent | No equivalent |

The mapping produces false equivalences. `model: opus` to `--model o3` is not a translation -- they are different models with different capabilities. Pretending they are equivalent creates a false sense of parity.

Instead, the routing config should explicitly state the model per harness:

```yaml
routing:
  codex:
    model: o3           # User explicitly chooses
  aider:
    model: claude-sonnet-4-20250514  # Aider can use any provider
  default: claude-code  # Unrouted tasks stay on Claude Code
```

This makes the user's choice visible and explicit, rather than hiding it behind a lossy translation layer. This aligns with the user feedback that quality parity is the user's responsibility.

### Instruction File Generation

The adapter writes a tool-specific instruction file before invocation:

| Target Tool | File Written | Content |
|---|---|---|
| Codex CLI | `AGENTS.md` (or `.codex/agents/<name>.md`) | Markdown body from AGENT.md |
| Aider | `CONVENTIONS.md` (or `.aider.conf.yml` reference) | Markdown body, possibly reformatted |
| Gemini CLI | `GEMINI.md` | Markdown body from AGENT.md |

The Markdown body (sections 1-5 of AGENT.md) translates cleanly to all formats because they are all Markdown. The content fidelity finding in the existing report is correct -- the five-section structure maps 1:1.

### Instruction Isolation Risk

The existing report identifies instruction isolation as an open question: external tools load their own project config (CLAUDE.md, .cursorrules) in addition to injected instructions. The adapter cannot prevent this.

Mitigation options (for the roadmap to address):

1. **Preamble injection**: Start the instruction file with "The following instructions take precedence over any project-level configuration" -- relies on the tool's LLM respecting the instruction, which is unreliable.
2. **Config suppression flags**: Some tools support disabling project config loading. Codex has `--no-project-doc` (if it exists -- needs verification). Aider can be configured to ignore `.aider.conf.yml`.
3. **Accept the risk**: For feasible-now tools, instruction conflict is unlikely because the injected instructions are task-specific (scope, constraints, deliverables) while project config is general (coding standards, repo conventions). Conflicts would require the project config to contradict the task prompt, which is a user configuration error.

Recommend option 3 for the initial roadmap, with option 2 explored as an enhancement issue.

---

## 3. LLM-Based Diff Summarization: Roadmap Positioning

### Recommendation: Dedicated roadmap issue, dependency of "Aider Adapter" issue

The user wants "LLM-based diff summarization" stated as the answer for Aider result collection. This resolves Open Question 5 in the report. For the roadmap, this should be:

### Proposed Issue: "Result Summarization Service"

**Position in sequence**: After the core adapter interface is defined (issue 1-2), before the Aider adapter (issue N). It is a dependency of any adapter that lacks structured JSON output.

**Scope**:
- Input: `git diff` output (unified diff format) + original task prompt
- Output: `DelegationResult.summary` string + `DelegationResult.changedFiles` array
- Implementation: Call an LLM (any provider -- the summarization model does not need to be the same as the execution model) with the diff and prompt, asking for a structured summary

**Dependencies**:
- Depends on: Adapter interface definition (issue 1) -- needs to know the `DelegationResult` shape
- Blocks: Aider adapter (cannot produce `summary` without this)
- Does NOT block: Codex adapter (Codex provides structured output natively)

**Why a separate issue (not part of the Aider adapter issue)**:
- Reusability: Any future tool without structured output (Continue CLI, Goose, etc.) will need the same service
- Testability: Can be tested independently with synthetic diffs before the Aider adapter exists
- Cost/latency concerns are isolated: The summarization service can be optimized (model choice, prompt engineering, caching) without touching adapter logic

**Cost and Latency Tradeoffs (for the report)**:

The report should state these as accepted tradeoffs, not open questions:

- **Cost**: One additional LLM call per Aider delegation. Using a small, fast model (sonnet-class) for summarization keeps cost low. A typical diff summary is <500 input tokens (diff excerpt) + <200 output tokens.
- **Latency**: Adds 1-3 seconds per delegation. Negligible compared to the multi-minute execution time of the coding task itself.
- **Accuracy**: LLM-based summarization may miss semantic intent that the executing tool understood but did not express in the diff. This is acceptable because the orchestrator uses summaries for reporting, not for correctness decisions. File changes (`changedFiles`) are derived from git diff mechanically and are always accurate.

### Roadmap Sequencing Recommendation

For the overall roadmap issue sequence, from the adapter protocol perspective:

```
Issue 1: Adapter Interface Definition
  - Define DelegationRequest / DelegationResult types
  - Define adapter registration/discovery mechanism
  - Define instruction file lifecycle (write, invoke, clean up)

Issue 2: Routing Configuration Schema
  - Define config format and location
  - Define default behavior (Claude Code unless overridden)
  - Define model mapping per harness
  (Depends on: Issue 1)

Issue 3: Codex CLI Adapter
  - Implement DelegationRequest -> codex exec invocation
  - Implement JSONL/JSON parsing -> DelegationResult
  - Implement AGENTS.md generation from AGENT.md body
  - Test with representative tasks
  (Depends on: Issue 1, Issue 2)

Issue 4: Result Summarization Service
  - Implement git-diff-to-summary LLM call
  - Define prompt template for diff summarization
  - Benchmark cost/latency with real diffs
  (Depends on: Issue 1)

Issue 5: Aider Adapter
  - Implement DelegationRequest -> aider invocation
  - Implement git-diff-based result collection using Issue 4
  - Implement CONVENTIONS.md generation from AGENT.md body
  - Test with representative tasks
  (Depends on: Issue 1, Issue 2, Issue 4)

Issue 6: Nefario Phase 4 Integration
  - Wire adapter dispatch into Phase 4 execution loop
  - Replace Task tool invocation with adapter dispatch for routed tasks
  - Maintain fallback to Task tool for non-routed tasks
  (Depends on: Issue 3 minimum, Issue 5 for full coverage)
```

---

## 4. Risks and Dependencies

### Risk: Adapter Interface Versioning

The adapter interface will evolve as more tools are added. The initial interface should be minimal (the shape above) with explicit extension points. Adding optional fields to `DelegationResult` (like `structuredOutput`) is backward-compatible. Changing required fields is not.

**Mitigation**: Version the interface. Start at v1. Document which fields are required vs optional. Adapters declare which interface version they implement.

### Risk: Instruction File Pollution

Adapters write instruction files (AGENTS.md, CONVENTIONS.md) to the working directory before invocation. If the adapter crashes or the process is killed, these files remain and pollute the repo.

**Mitigation**: Use a cleanup-on-exit pattern. Write to a temporary location and symlink, or write with a `.nefario-generated` marker that a cleanup step removes. The roadmap should include cleanup as part of the adapter lifecycle specification in Issue 1.

### Risk: Git State Mutation During Diff Collection

If the external tool creates commits (Aider's `--auto-commits`), `git diff HEAD` will show nothing because the changes are already committed. The adapter needs to diff against the pre-invocation commit, not HEAD.

**Mitigation**: Capture `git rev-parse HEAD` before invocation. After invocation, diff against that ref: `git diff <pre-invocation-ref>..HEAD`. This handles both tools that commit (Aider) and tools that leave changes uncommitted (Codex).

### Dependency: Routing Config Must Precede Adapter Implementation

The Codex adapter needs to know which model to use, which comes from routing config. Issue 2 (routing config schema) must be at least design-complete before Issue 3 (Codex adapter) can be implemented. They can overlap in execution but the config schema must be settled first.

### Dependency: Nefario Phase 4 Is Out of Scope for This Roadmap

The meta-plan states "Changing nefario orchestrator code" is out of scope. Issue 6 (Phase 4 integration) describes what needs to happen but is explicitly deferred. The roadmap should flag it as a future issue, not a current deliverable.

---

## 5. Recommendations for Report Iteration

### Open Question 5 Resolution

Replace the current Open Question 5:

> **Result collection without structured output**: For tools that produce only git diffs (Aider), how should the wrapper generate the semantic summary (file paths, change scope, purpose) that the orchestrator expects? LLM-based summarization of diffs is one option but adds cost and latency.

With a definitive statement in the Gap Analysis or Feasibility Assessment section:

> **Result collection for non-JSON tools**: Tools that produce only git diffs (Aider) use LLM-based diff summarization to generate the semantic summary the orchestrator expects. A small, fast model processes the unified diff against the original task prompt to produce a structured summary (changed files, change scope, purpose). The cost (~500 input tokens + ~200 output tokens per delegation) and latency (~1-3 seconds) are negligible relative to multi-minute task execution. File change lists are always derived mechanically from `git diff`, ensuring accuracy regardless of summarization quality.

### Gap Analysis Table Update

The "Result collection" row should be updated to reflect this resolution:

> **Gap Severity**: Low-Medium (was Medium). Git diff provides file changes mechanically. Semantic summaries use LLM-based diff summarization for tools without structured JSON output. Codex `--output-schema` provides native structured output.

### Instruction Format Translation Section

Add a subsection or note under "Key findings" stating:

> Frontmatter fields are stripped during instruction translation and passed as adapter runtime configuration. The Markdown body (five-section system prompt) is the only content written to tool-native instruction files. Model selection, which has no cross-tool equivalent in frontmatter, is handled through the routing configuration (see Routing Configuration section).

---

## Summary of Contributions

| Question | Answer |
|---|---|
| Adapter interface shape | `DelegationRequest` (prompt + config) -> `DelegationResult` (exit code + file changes + summary + optional usage). Self-contained per call, dual output format. |
| Frontmatter handling | Strip entirely. Pass actionable fields (model) as runtime config. Markdown body passes through to instruction files unchanged. |
| LLM-based diff summarization positioning | Dedicated "Result Summarization Service" issue. Dependency of Aider adapter, not dependency of Codex adapter. Separate for reusability and testability. |
| Recommended roadmap sequence | Interface -> Config -> Codex Adapter -> Summarization Service -> Aider Adapter -> Phase 4 Integration |
