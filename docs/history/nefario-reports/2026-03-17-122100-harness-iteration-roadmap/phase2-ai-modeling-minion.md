# AI Modeling Minion -- Planning Contribution

## Scope

Routing configuration design, model specification translation, quality-tier
abstraction, and Codex-first implementation roadmap decomposition.

---

## 1. Routing Configuration Design

### The Core DX Question

The orchestrator (nefario) must remain harness-unaware. Routing decisions belong
in user-owned configuration, not in planning logic or agent prompts. The
configuration must answer: "For this agent running this task, which harness
should execute it, and with what model?"

### Recommended Configuration Pattern: Layered Defaults with Overrides

Three configuration layers, evaluated bottom-to-top (last match wins):

```yaml
# .despicable/harness-routing.yaml (project-level, checked into repo)

defaults:
  harness: claude-code           # fallback for everything
  model_tier: standard           # see quality-tier abstraction below

# Override by agent model tier (from AGENT.md frontmatter)
tiers:
  opus:
    harness: claude-code
    model_tier: high
  sonnet:
    harness: claude-code
    model_tier: standard

# Override by specific agent name
agents:
  frontend-minion:
    harness: codex
    model_tier: standard
  test-minion:
    harness: aider
    model_tier: standard

# Override by task characteristic (optional, advanced)
task_routing:
  - match: { requires_tools: [Bash, WebSearch] }
    harness: claude-code          # only Claude Code has these tools
  - match: { requires_tools: [Edit] }
    harness: any                  # all harnesses can edit files
```

### Why This Pattern

1. **Zero-cost for non-users**: If `harness-routing.yaml` does not exist,
   everything routes to Claude Code (current behavior). No config file needed
   until you want external harnesses.

2. **Layered specificity**: Global defaults -> tier-based routing -> per-agent
   routing -> task-characteristic routing. Users configure only the layers they
   care about.

3. **Declarative, not imperative**: The user declares intent ("frontend-minion
   should use Codex"), not mechanism ("spawn codex exec with these flags").
   The adapter layer translates intent to invocation.

4. **Auditable**: A single file shows the full routing policy. No hunting
   through multiple config files.

### Configuration DX Patterns from the Field

Existing multi-agent systems use three routing patterns. Here is how each maps
to this problem:

| Pattern | How It Works | Fit for This Problem |
|---------|-------------|---------------------|
| **Static dispatch table** | Agent name -> harness mapping in config | Good for deterministic routing. The `agents:` section above. |
| **Tier-based routing** | Quality requirement -> provider mapping | Good for model selection. The `tiers:` section above. Matches the existing `model: opus/sonnet` frontmatter. |
| **Capability-based routing** | Task requirements -> eligible harnesses | Good for tool-parity filtering. The `task_routing:` section above. Prevents routing a Bash-dependent task to Aider (which has no Bash). |

**Recommendation**: Start with static dispatch table only (Milestone 1). Add
tier-based routing in Milestone 2. Capability-based routing is Milestone 3 or
later -- it requires a tool-capability registry per harness.

### Configuration Discovery

The adapter should look for configuration in this order:

1. `.despicable/harness-routing.yaml` in the project root (version-controlled)
2. `~/.config/despicable/harness-routing.yaml` (user-level defaults)
3. Built-in defaults (everything -> Claude Code)

Project-level config overrides user-level. This matches the precedence pattern
used by Codex CLI (`~/.codex/config.toml` vs `.codex/config.toml`) and Claude
Code (`~/.claude/` vs project-level `CLAUDE.md`).

---

## 2. Model Specification Translation

### Current State: The `model:` Frontmatter Field

Every AGENT.md has `model: opus` or `model: sonnet`. This is a Claude-specific
quality signal:

| Value | Current Meaning | Agents Using It |
|-------|----------------|-----------------|
| `opus` | Strategic/deep reasoning, complex planning | 8 (gru, nefario, lucy, margo, ai-modeling, api-spec, debugger, security, product-marketing) |
| `sonnet` | Execution/cost-efficiency, domain specialist work | 19 (all other minions) |

These values map directly to Claude model IDs (`claude-opus-4-6`,
`claude-sonnet-4-5`). When the harness is Claude Code, no translation is
needed -- Claude Code already reads this field.

### The Translation Problem

When routing to an external harness, `model: opus` has no meaning to Codex CLI
or Aider. The adapter must translate this intent into a provider-specific model
identifier.

**Option A: Direct model name mapping (per-harness)**

```yaml
# In harness-routing.yaml
harness_config:
  codex:
    models:
      opus: gpt-5-pro          # highest reasoning capability
      sonnet: gpt-5-codex      # standard coding model
  aider:
    models:
      opus: claude-opus-4-6    # Aider can use Claude models via API key
      sonnet: claude-sonnet-4-5
  gemini:
    models:
      opus: gemini-3-pro       # highest Gemini tier
      sonnet: gemini-3-flash   # fast Gemini tier
```

**Option B: Quality-tier abstraction**

```yaml
# In harness-routing.yaml
model_tiers:
  high:                        # maps to model: opus
    claude-code: claude-opus-4-6
    codex: gpt-5-pro
    aider: claude-opus-4-6     # Aider is model-agnostic
    gemini: gemini-3-pro
  standard:                    # maps to model: sonnet
    claude-code: claude-sonnet-4-5
    codex: gpt-5-codex
    aider: claude-sonnet-4-5
    gemini: gemini-3-flash
```

### Recommendation: Quality-Tier Abstraction (Option B)

**Why Option B is better**:

1. **Semantic clarity**: `high` and `standard` express intent, not
   implementation. Users think in quality tiers, not model IDs (which change
   every few months).

2. **Single change point**: When OpenAI ships gpt-6, you update one line in
   `model_tiers.high.codex`, not every agent override.

3. **Composable with routing**: The `tiers:` section in the routing config
   maps frontmatter values to quality tiers. The `model_tiers` section maps
   quality tiers to concrete model IDs per harness. Clean separation.

4. **Matches existing semantics**: `model: opus` already means "high quality
   reasoning" in the-plan.md, not "specifically claude-opus-4-6". The
   abstraction preserves this intent.

5. **Extensible**: Adding a `budget` tier for batch/background tasks requires
   no frontmatter changes -- just a new tier mapping.

**Two tiers are enough for now**. The current system has exactly two values
(`opus`, `sonnet`). Introducing `high`, `standard`, and `budget` as the tier
vocabulary provides room for a third tier without over-engineering.

### Translation Mechanics

The adapter performs this lookup chain:

```
AGENT.md model: field
  -> quality tier (opus->high, sonnet->standard)
    -> harness-specific model ID (from model_tiers config)
      -> CLI flag (--model <id> for Codex/Aider/Gemini)
```

If a tier-to-model mapping is missing for a harness, the adapter should fail
loudly (not silently fall back to a default model). Silent fallback masks
quality problems.

### Per-Harness Model Flag Translation

| Harness | Model Flag | Example | Notes |
|---------|-----------|---------|-------|
| Claude Code | `model:` frontmatter (native) | `model: opus` | No translation needed |
| Codex CLI | `--model <id>` or config.toml `model =` | `codex exec --model gpt-5-pro -p "..."` | Also supports `--profile` for preconfigured model+settings bundles |
| Aider | `--model <id>` | `aider --model claude-opus-4-6 -m "..."` | Provider prefix optional: `openrouter/anthropic/claude-opus-4-6` |
| Gemini CLI | `--model <id>` or `GEMINI_MODEL` env var | `gemini -p "..." --model gemini-3-pro` | Also supports `auto` for automatic routing |

### Reasoning Effort Translation

Some harnesses expose reasoning effort controls beyond model selection:

| Harness | Reasoning Control | Maps From |
|---------|------------------|-----------|
| Codex CLI | `model_reasoning_effort` (minimal/low/medium/high/xhigh) | Could map from opus->high, sonnet->medium |
| Claude Code | `thinking.budget_tokens` | Already handled natively |
| Aider | None (model-dependent) | N/A |
| Gemini CLI | Model-dependent (Pro vs Flash) | Handled by model selection |

The adapter should set reasoning effort flags when available, mapping from the
quality tier. This is a Milestone 2+ concern.

---

## 3. Worktree Isolation for External Harnesses

The orchestrator already uses git worktrees for parallel delegation. External
harnesses must operate in the same worktree model.

### Key Constraint

External tools load project-level configuration from the working directory. When
running in a worktree:

- `.despicable/harness-routing.yaml` is shared (same repo content)
- `.codex/config.toml` at project level is shared
- `AGENTS.md` written by the adapter is worktree-local (written to worktree root)
- `CONVENTIONS.md` for Aider is worktree-local

The adapter must write instruction files to the worktree root, not the main
repo root. The `cwd` parameter of the subprocess spawn must point to the
worktree.

### Instruction Isolation Risk

External tools may read their own project-level configs in addition to
adapter-injected instructions. For example, if the project already has a
`.codex/config.toml` or `AGENTS.md`, the external tool will load it alongside
(or instead of) the adapter's injected instructions.

**Mitigation**: The adapter should check for conflicting instruction files in
the worktree before invocation and either:
- Merge them (risky -- semantic conflicts)
- Temporarily rename them (fragile -- crash leaves stale renames)
- Document the conflict and let the user resolve it (safest for Milestone 1)

---

## 4. Quality Parity Assessment

### Task-Type Suitability Matrix

Not all tasks are equal candidates for external harness delegation. The
orchestrator should consider task characteristics when routing:

| Task Type | Claude Code | Codex CLI | Aider | Notes |
|-----------|------------|-----------|-------|-------|
| Code generation (new files) | Strong | Strong | Strong | All harnesses handle this well |
| Code modification (edit existing) | Strong | Strong | Strong (architect mode) | Aider's diff-based editing is mature |
| Code review / analysis | Strong | Strong | Weak | Aider is edit-focused, not analysis-focused |
| Test writing | Strong | Strong | Moderate | Aider lacks Bash to run tests |
| Documentation writing | Strong | Moderate | Moderate | Claude excels at prose |
| Multi-file refactoring | Strong | Strong | Strong | Aider handles repo-wide edits well |
| Tasks requiring web research | Strong | Moderate | None | Aider has no web access |
| Tasks requiring shell commands | Strong | Strong | None | Aider cannot run Bash |
| Security review | Strong | Moderate | None | Requires reasoning + tool access |
| Architecture planning | Strong | Moderate | None | High-reasoning, low-edit task |

**Implication for routing config**: The `task_routing` section should include
tool-parity guards. A task that requires `Bash` or `WebSearch` tools must not
route to Aider. The adapter should validate tool requirements against harness
capabilities before invocation.

### Quality Tracking

The orchestrator should log per-harness outcomes (task type, harness used,
success/failure, human override needed) to a local file. Over time, this builds
an empirical basis for routing optimization. This is a Milestone 3+ concern.

---

## 5. Aider Result Collection

### The Problem

Aider produces no structured JSON output. Its primary output mechanism is git
commits (with `--auto-commits`). The adapter needs to produce a result summary
compatible with what the orchestrator expects from Claude Code subagents (file
paths, change scope, summary).

### Collection Strategy

```
Aider invocation
  -> capture exit code (0 = success)
  -> git diff HEAD~1..HEAD (if commit was made)
  -> parse diff for: files changed, lines added/removed
  -> construct result object:
     {
       "status": "success" | "failure",
       "files_changed": ["path/to/file1.ts", "path/to/file2.ts"],
       "lines_added": 47,
       "lines_removed": 12,
       "commit_sha": "abc123",
       "summary": null  // no semantic summary available
     }
```

**The missing piece is the semantic summary.** Options:

1. **Skip it**: Return file list and diff stats. The orchestrator can infer
   scope from file paths. Cheapest, simplest. Recommended for Milestone 2.

2. **LLM-based summarization**: Pipe the diff through a cheap model (Haiku 4.5,
   ~$0.001 per summary) to generate a one-sentence description. Adds latency
   (~1-2s) and cost (negligible). Consider for Milestone 3.

3. **Aider commit message**: Aider generates commit messages for its auto-commits.
   Parse `git log -1 --format=%B` after completion. This is free and immediate
   but quality varies. Use as the summary field with a `source: aider-commit-msg`
   qualifier.

**Recommendation**: Use option 3 (commit message) as the summary in Milestone 2.
Add option 2 (LLM summarization) as an optional enhancement in Milestone 3.

---

## 6. Codex-First Implementation Roadmap

### Milestone 0: Configuration Schema (Pre-adapter)

**Goal**: Define and validate the routing configuration format before writing
any adapter code.

**Deliverables**:
1. JSON Schema for `harness-routing.yaml` (validatable, documentable)
2. Configuration loader that resolves the three-layer hierarchy
   (project -> user -> built-in defaults)
3. Dry-run mode: given an agent name and task, print which harness and model
   would be selected (no invocation)

**Why first**: The config schema is the contract between the orchestrator and
all future adapters. Getting it wrong means rewriting every adapter. Getting it
right means adapters are mechanical translations.

**Estimated effort**: Small. Schema definition + loader + CLI dry-run command.

### Milestone 1: Codex CLI Adapter (Core)

**Goal**: Route a single agent task to Codex CLI and collect structured results.

**Deliverables** (sequenced):

1. **Instruction translator**: Convert AGENT.md system prompt to AGENTS.md
   format. Strip Claude Code-specific instructions (TaskUpdate, SendMessage,
   scratch directory conventions). Inject Codex-specific preamble if needed.
   - Input: AGENT.md content + task prompt
   - Output: AGENTS.md file written to worktree + cleaned prompt string

2. **Model resolver**: Look up quality tier from AGENT.md `model:` field,
   resolve to Codex-specific model ID from config.
   - Input: `model: sonnet` + harness name `codex`
   - Output: `--model gpt-5-codex` flag

3. **Invocation wrapper**: Spawn `codex exec` subprocess with:
   - `--model <resolved-model>`
   - `--full-auto` (approval bypass)
   - `--json` (JSONL event stream to stderr for monitoring)
   - `-o <result-file>` (final message to file)
   - `--output-schema <schema.json>` (structured result format)
   - `cwd` set to worktree path
   - Configurable timeout (default: 30 minutes, matching Codex's
     `job_max_runtime_seconds`)

4. **Result collector**: Parse Codex output into normalized result format.
   - JSONL stream: extract file changes, errors, token usage
   - Output schema: validate against expected result schema
   - Exit code: map to success/failure/timeout

5. **Error handler**: Classify exit codes and stderr patterns.
   - 0: success
   - Non-zero: parse stderr for retryable vs. fatal
   - Timeout: configurable retry (0 by default)

**Validation criteria**: Run 5 representative tasks (code generation, edit,
test writing, docs, refactoring) through both Claude Code and Codex CLI.
Compare: files changed match, no regressions, result format is consumable
by orchestrator.

**Estimated effort**: Medium. The Codex CLI has good automation ergonomics;
the main complexity is JSONL parsing and instruction translation.

### Milestone 2: Aider Adapter + Quality Tier System

**Goal**: Second adapter validates that the abstraction generalizes beyond
Codex. Quality tier system is fully operational.

**Deliverables** (sequenced):

1. **Aider instruction translator**: Convert AGENT.md to CONVENTIONS.md
   format for `.aider.conf.yml`. Handle `--read` flags for context files.

2. **Aider invocation wrapper**: Spawn `aider --message <prompt> --yes
   --model <model> --auto-commits` with worktree cwd.

3. **Aider result collector**: Git-diff-based collection (see Section 5).
   Parse commit message as summary. Construct normalized result.

4. **Quality tier configuration**: Full `model_tiers` config section with
   high/standard mappings for Claude Code, Codex, and Aider.

5. **Tool-parity guard**: Check task tool requirements against harness
   capabilities. Reject routing to Aider for tasks requiring Bash or
   WebSearch. Return error with suggested alternative harness.

**Validation criteria**: Run the same 5 representative tasks through Aider.
Compare results with Claude Code baseline. Document quality delta per task type.

**Estimated effort**: Medium. Aider's simpler output model (git commits)
makes result collection easier but less rich.

### Milestone 3: Orchestrator Integration

**Goal**: The orchestrator (nefario) delegates through the adapter layer
transparently.

**Deliverables**:

1. **Adapter dispatch in execution phase**: During Phase 4, the main session
   consults `harness-routing.yaml` before spawning each task. If the route
   points to an external harness, invoke the adapter instead of Task tool.

2. **Result normalization**: All adapters produce the same result schema.
   The orchestrator processes results identically regardless of source harness.

3. **Progress monitoring**: For Codex (JSONL streaming), pipe progress events
   to the orchestrator's status mechanism. For Aider (opaque), report only
   start/complete.

4. **Quality outcome logging**: Record harness, model, task type, success/failure,
   and whether human override was needed. Write to
   `.despicable/harness-outcomes.jsonl`.

**Validation criteria**: Full nefario orchestration with mixed harness routing.
At least one task routed to Codex, one to Aider, remainder to Claude Code.
End-to-end success with no orchestrator changes beyond routing config.

### Milestone 4: Hardening and Extensions (Future)

- Capability-based routing (task_routing section)
- Gemini CLI adapter
- LLM-based diff summarization for Aider results
- Reasoning effort translation
- Per-harness cost tracking and reporting
- Retry policies per harness
- Circuit breaker for harness failures

---

## 7. Risks and Dependencies

### Risks

| Risk | Severity | Mitigation |
|------|----------|------------|
| **Codex CLI interface changes** | Medium | Pin to Codex CLI version in adapter. Monitor OpenAI changelog. Codex CLI is GA and interface is stabilizing. |
| **Quality parity gap** | High | Validation suite (5 representative tasks) run per milestone. Document quality delta. Do not route quality-sensitive tasks (security, architecture) away from Claude Code without explicit user opt-in. |
| **Instruction isolation conflicts** | Medium | Milestone 1: document and warn. Milestone 3: add conflict detection to adapter. |
| **Model ID churn** | Low | Quality-tier abstraction decouples agent specs from model IDs. Only config file changes needed when providers update model names. |
| **Aider no-JSON output** | Low | Git-diff collection is reliable. Commit message as summary is adequate. LLM summarization optional enhancement. |
| **Worktree instruction leakage** | Medium | Adapter writes instruction files to worktree root. Must clean up AGENTS.md/CONVENTIONS.md after invocation to prevent git pollution. |

### Dependencies

| Dependency | Milestone | Notes |
|-----------|-----------|-------|
| Codex CLI installed and authenticated | M1 | `CODEX_API_KEY` or saved auth required |
| Aider installed and configured | M2 | API key for chosen provider required |
| Git worktree support in orchestrator | M1 | Already implemented |
| Schema validation library (JSON Schema) | M0 | For config validation and output schema |
| nefario Phase 4 delegation hook | M3 | Orchestrator must support adapter dispatch |

### Requirements for the Config Schema (for devx-minion)

The configuration schema must:
- Be valid YAML (not TOML -- YAML is the project standard for config)
- Have a JSON Schema definition for validation and editor support
- Support comments (YAML native)
- Be optional (zero-config = current behavior)
- Be discoverable (`.despicable/` directory, matching project conventions)
- Support environment variable interpolation for API keys
  (e.g., `$CODEX_API_KEY` in config values)

---

## 8. Recommendation Summary

1. **Use quality-tier abstraction** (`high`/`standard`) that maps to
   provider-specific models. Do not require users to know model IDs.

2. **Start with static dispatch table routing** (agent name -> harness).
   Add tier-based and capability-based routing in later milestones.

3. **Config is a single YAML file**, optional, with project/user/default
   layering. Zero-cost for users who do not use external harnesses.

4. **Codex CLI first** -- best automation interface, structured output,
   JSON Schema validation. Lowest adapter complexity.

5. **Four-milestone roadmap**: Schema -> Codex adapter -> Aider adapter +
   quality tiers -> Orchestrator integration. Each milestone is independently
   testable and deliverable.

6. **Fail loudly on missing model mappings**. Silent fallback masks quality
   degradation. If a harness has no model mapping for a tier, error with a
   clear message.

7. **Aider result collection via git diff + commit message**. No need for
   LLM summarization in initial milestones.
