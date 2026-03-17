# Gru Technology Assessment: Codex CLI Stability, Filesystem Isolation, and Roadmap Inputs

*Date: 2026-03-17*

---

## 1. Codex CLI Automation Interface Stability

### Ring: Trial (for delegation target use)

### Current State

Codex CLI is at version **0.115.0** (released 2026-03-16), with **0.116.0-alpha** builds
already appearing. The project follows a pre-1.0 versioning scheme with no published
semver policy or backward-compatibility guarantees. The SDK (`@openai/codex-sdk`) is at
**0.112.0** and is explicitly marked **Beta** on npm with 415 published versions and
88 dependents.

### Release Velocity

Codex ships **multiple releases per day** during active development cycles. Alpha tags
flow continuously (0.115.0-alpha.22 through 0.115.0-alpha.27 all appeared within two
days). Stable bumps (0.114.0 -> 0.115.0) happen roughly weekly. This velocity is
characteristic of a rapidly iterating product with insufficient stabilization pressure --
there are not enough external consumers pinning versions to force backward compatibility.

### Breaking Change History

Recent changelog entries show low-frequency but real breaking changes:

| Version | Change | Impact |
|---------|--------|--------|
| 0.115.0 | `wait_agent` tool renamed (was generic name) | Breaks automation referencing old name |
| 0.115.0 | Stricter subagent inheritance for sandbox/network rules | May change behavior of existing profiles |
| 0.114.0 | Permission profile config language expanded with split sandbox policies | Legacy `workspace-write` preserved but newer profiles degrade |
| 0.113.0 | Global wildcard (`*`) domains rejected in network proxy policies | Breaks permissive network configs |

The deprecation of `--ask-for-approval on-failure` in favor of `on-request`/`never` is
another example -- functional but requires config updates.

### Stability Assessment for Automation

**What is stable (safe to build on):**
- `codex exec` subcommand and its core flags (`--json`, `--full-auto`, `--output-schema`,
  `-o`, `--ephemeral`, `--sandbox`)
- JSONL event stream format (event types: `thread.started`, `turn.started/completed/failed`,
  `item.started/completed`, `error`)
- Exit code semantics (0 = success, non-zero = failure)
- JSON Schema validation via `--output-schema`

**What is experimental or unstable (risky to build on):**
- `codex cloud exec` (marked Experimental)
- `codex mcp` (marked Experimental)
- `codex sandbox` (marked Experimental)
- `codex execpolicy` (marked Experimental)
- Tool naming within agent/subagent system (just renamed)
- Permission profile language (actively evolving, 0.114.0 expanded it)

**Risk assessment**: The core `codex exec` automation surface is the most stable part
of the product. OpenAI has strong incentive to keep CI/CD integrations working (they
ship a GitHub Action built on `codex exec`). The experimental features and subagent
orchestration internals are high-churn. **An adapter built on `codex exec --json` and
`--output-schema` has acceptable stability risk for a Trial-ring integration.**

### Recommendation for Roadmap

- **Pin to specific Codex CLI versions** in any adapter. Do not track `latest`.
- **Wrap CLI invocation behind an abstraction** so that flag changes require updating
  one adapter, not all call sites.
- **Test against alpha channel** in CI to get early warning of breaking changes.
- **Do not depend on Codex subagent/multi-agent internals** -- these are churning fast
  and are not the adapter's concern anyway.

---

## 2. Codex TypeScript SDK vs. CLI Subprocess

### Ring: Assess (for SDK path); Trial (for CLI subprocess path)

### SDK Architecture

The TypeScript SDK (`@openai/codex-sdk`) is a **thin CLI wrapper** -- it spawns the
`codex` CLI binary and exchanges JSONL events over stdin/stdout. It does NOT call
OpenAI APIs directly. This means:

- The SDK provides **no additional capabilities** beyond what `codex exec --json` offers
- The SDK adds a **Node.js runtime dependency** that a shell subprocess does not
- The SDK inherits **all CLI stability characteristics** since it delegates to the CLI
- There is also a **Native SDK** (Rust-powered via napi-rs) that bypasses the CLI spawn,
  but this is even less stable

### SDK API Surface

```typescript
import { Codex } from "@openai/codex-sdk";
const codex = new Codex();
const thread = codex.startThread();

// Buffered execution
const result = await thread.run(prompt);  // returns Turn { finalResponse, items }

// Streaming execution
for await (const event of thread.runStreamed(prompt)) {
  // event types: "item.completed", "turn.completed"
}
```

Configuration: `workingDirectory`, `skipGitRepoCheck`, `outputSchema` (supports Zod),
`env`, `config` (TOML-style overrides), `baseUrl`.

### SDK vs CLI Subprocess: Decision Matrix

| Dimension | CLI Subprocess | TypeScript SDK | Winner |
|-----------|---------------|----------------|--------|
| **Stability** | Core `exec` flags are stable | Beta, 415 versions, no stability guarantee | CLI |
| **Dependencies** | Shell only (sh/bash) | Node.js 18+, npm package | CLI |
| **Event handling** | Parse JSONL from stdout | Typed async generator | SDK (ergonomics) |
| **Schema validation** | `--output-schema` flag | Zod schema objects | SDK (ergonomics) |
| **Error handling** | Exit codes + stderr | Try/catch with typed errors | SDK (ergonomics) |
| **Maintenance** | Version pin in package.json or script | npm dependency updates | Roughly equal |
| **Debugging** | Raw JSONL visible in logs | Abstracted away | CLI |
| **Cross-language** | Works from any language | TypeScript/JavaScript only | CLI |
| **Thread resume** | `codex exec resume --last` | `codex.resumeThread(id)` | SDK (programmatic) |

### Recommendation

**Use CLI subprocess, not the TypeScript SDK.** Rationale:

1. The SDK is a wrapper around the CLI -- it adds abstraction without adding capability.
   When the underlying CLI changes, the SDK must catch up, creating a double-update risk.
2. The orchestrator (nefario) runs inside Claude Code, which spawns shell subprocesses.
   Adding a Node.js runtime layer between the shell and the CLI is unnecessary complexity.
3. The CLI subprocess approach works identically for Codex, Aider, Gemini CLI, and any
   future tool. The SDK approach is Codex-specific, defeating the purpose of a
   tool-agnostic abstraction.
4. The Beta status and 415-version churn of the SDK indicate it is not yet stable enough
   for a dependency.

**Exception**: If the roadmap ever includes building a standalone TypeScript orchestrator
(outside Claude Code), the SDK's typed event stream and Zod schema support would justify
the dependency. But that is not the current architecture.

---

## 3. Filesystem Isolation for Concurrent Agent Execution

### State of the Art (2026-03-17)

Four isolation patterns exist, ranging from simple to complex:

### Pattern 1: Git Worktrees (Adopt ring)

The dominant pattern for local multi-agent coding. Used by Codex Desktop, Claude Code,
Conductor, and the despicable-agents orchestrator itself.

**How it works**: `git worktree add ../agent-task-1 -b task-1` creates an isolated
checkout sharing the same `.git` object database. Each agent operates in its own
directory with its own branch.

**Strengths**:
- Zero additional tooling required (Git built-in)
- Native branch/commit/merge workflow -- results are already in Git
- Low overhead (shared object database, no file duplication)
- Well-understood by all coding tools (every CLI tool works in a worktree)

**Weaknesses**:
- Isolates files but NOT runtime environment (shared ports, databases, services)
- Worktree creation adds ~1-3 seconds per task (acceptable but not free)
- Worktree cleanup requires explicit management (`git worktree remove`)
- Cannot prevent agents from reading each other's worktrees (filesystem is shared)

**Production evidence**: Widely adopted. Multiple blog posts, tools (Uzi), and platform
features (Upsun) document this pattern in production use.

### Pattern 2: Container Isolation (Trial ring)

Containers wrap each agent in an isolated environment with its own filesystem,
network namespace, and process space.

**Implementations**:
- **Container Use** (Dagger) -- open-source tool combining Docker containers with Git
  worktrees. Each agent gets a containerized sandbox. Integrates with Zed editor.
  Early-stage software with known issues.
- **E2B** -- cloud-hosted sandboxes for agent execution. Strong isolation but adds
  network latency and cloud dependency.
- **SandboxAI** -- Docker-based with Kubernetes roadmap.

**Strengths**:
- Full environment isolation (filesystem, network, processes)
- Prevents cross-agent interference at the OS level
- Can enforce resource limits (CPU, memory, time)

**Weaknesses**:
- Docker overhead (~2-5 seconds startup per container)
- Complexity: container image management, volume mounts, network config
- Results must be extracted from container (volume mount or `docker cp`)
- Not all coding CLI tools are container-aware (tool config paths, auth tokens,
  credential files may not be available inside containers)

**Production evidence**: Container Use is early-stage. E2B has production customers
but is cloud-only. No evidence of container isolation being used for local
multi-harness orchestration at the scale this project needs.

### Pattern 3: Overlay Filesystems (Assess ring)

Copy-on-write filesystems that let agents see and modify files without touching
the original.

**Implementation**: **AgentFS** (Turso) -- SQLite-backed delta layer over a read-only
host filesystem base layer. Uses FUSE on Linux, NFS localhost server on macOS.
Supports `agentfs run claude` to wrap any agent in a sandboxed session.

**Strengths**:
- Kernel-level write isolation (agents cannot modify host files)
- Full audit trail (all changes recorded in SQLite)
- No duplication of the source tree (copy-on-write)
- Deletions tracked via whiteout mechanism

**Weaknesses**:
- Platform-specific: FUSE on Linux, NFS hack on macOS (different behavior/performance)
- AgentFS is at version 0.4.1 -- early-stage, insufficient production signals
- Changes live in SQLite, not Git -- must be extracted and committed separately
- FUSE/NFS introduces I/O overhead for every file operation (unquantified)
- macOS NFS approach may interact poorly with tools that check filesystem type

**Production evidence**: Turso is actively developing AgentFS with framework integrations
(Mastra, Claude Agent SDK, OpenAI Agents SDK), but no public production deployments at
scale. The concept is sound; the implementation is too young to depend on.

### Pattern 4: Lock Files / Cooperative Isolation (Hold ring)

Agents coordinate access to shared files through advisory locks, file ownership
manifests, or prompt-based conventions.

**How it works**: The orchestrator assigns file ownership (e.g., "Agent A owns src/auth/,
Agent B owns src/api/") and agents respect boundaries by convention.

**Strengths**:
- Zero infrastructure overhead
- Simple to implement (orchestrator just includes ownership in the prompt)

**Weaknesses**:
- Advisory only -- no enforcement. LLM agents can and do violate boundaries.
- Fails for shared files (package.json, config files, shared types)
- Merge conflicts still possible if boundaries are crossed
- No isolation of build artifacts, node_modules, or other generated files

**Production evidence**: This is what despicable-agents does today (prompt-based
file ownership). It works for sequential tasks but is insufficient for true
parallel execution.

### Isolation Pattern Recommendation

| Pattern | Ring | When to Use | When NOT to Use |
|---------|------|-------------|-----------------|
| Git worktrees | **Adopt** | Default for all parallel agent tasks. Proven, zero-dependency, Git-native. | When runtime isolation is also needed (shared databases, ports) |
| Containers | **Trial** | When agents need runtime isolation (running tests, starting servers) | For pure code-edit tasks (overhead not justified) |
| Overlay FS (AgentFS) | **Assess** | When agents are untrusted or changes need atomic accept/reject | For trusted agent workflows where Git branching suffices |
| Lock files | **Hold** | Never as sole mechanism for parallel work | Anywhere parallel file access is possible |

### Definitive Statement on Worktree Isolation

**Git worktrees are the correct default isolation mechanism for concurrent agent
filesystem access in this project.** This is not a tentative assessment -- it is the
established production pattern adopted by every major multi-agent coding tool.

The document should state this definitively rather than as an open question. The open
question is not "should we use worktrees?" but "when do we need isolation beyond
worktrees?" The answer: when agents need to run tests, start servers, or access shared
services in ways that could conflict. For pure code-editing delegation, worktrees are
sufficient and optimal.

Per-delegation worktree creation IS practical at scale. Worktree creation cost is
~1-3 seconds (dominated by checkout, not Git internals). Cleanup can be batched.
The orchestrator already supports worktrees. The roadmap should treat worktree-per-task
as the baseline, not an option.

---

## 4. Specific Inputs for Document Iteration

### Worktree Isolation (Open Question #2 in current doc)

The current document asks: "Is per-delegation worktree creation practical at scale?"

**Answer: Yes.** Rewrite as a definitive statement:

> Per-task worktree creation is the standard isolation pattern for parallel agent
> execution. Creation overhead is ~1-3 seconds per worktree, acceptable for tasks
> that run for minutes. Cleanup is handled by `git worktree remove` after result
> merge. The orchestrator already creates worktrees for its own parallel execution;
> extending this to external harness tasks requires no new mechanism.
>
> Worktrees isolate code but not runtime environment. Tasks that run tests against
> shared databases or start servers on fixed ports need additional isolation
> (containers or port allocation) beyond worktrees alone.

### AGENTS.md Spec Stability (Open Question #4 in current doc)

**Ring: Trial** -- AGENTS.md moved to Linux Foundation (AAIF) governance. Spec is
simple enough that breaking changes are unlikely to be severe (it is a Markdown file
with optional frontmatter). The bigger risk is fragmentation -- tool-specific extensions
that break cross-tool portability. Monitor AAIF governance decisions. The spec's
simplicity is its stability guarantee.

### Result Collection Without Structured Output (Open Question #5 in current doc)

For tools without JSON output (Aider), three approaches exist:

1. **Git diff parsing** -- extract changed files and line counts from `git diff --stat`.
   Gives file-level granularity but not semantic understanding. Cost: zero.
2. **LLM summarization of diffs** -- feed `git diff` to a small model (sonnet-class)
   for semantic summary. Cost: ~1-3 cents per task. Latency: 2-5 seconds.
3. **Commit message as summary** -- Aider auto-generates commit messages. These are
   often adequate summaries. Parse the last commit message. Cost: zero.

**Recommendation**: Use commit messages as the primary summary source for Aider.
Fall back to git diff parsing for file-level details. Reserve LLM summarization
for cases where the orchestrator needs semantic understanding beyond what the commit
message provides.

---

## 5. Codex-First Roadmap Inputs

### Risks

| Risk | Severity | Mitigation |
|------|----------|------------|
| Codex CLI breaking changes | Medium | Pin versions, test against alpha channel, abstract CLI invocation |
| Model quality parity (o3/o4-mini vs Opus) | High | Start with tasks where model quality is less critical (formatting, boilerplate, simple edits). Benchmark on representative tasks before expanding scope. |
| JSONL event format changes | Low | Core event types (thread/turn/item) are stable; detailed fields may change. Parse defensively. |
| Codex CLI availability (not installed) | Low | Fail fast with clear error. Adapter is opt-in, not default. |
| Cost unpredictability | Medium | Codex uses OpenAI billing. Token costs differ from Anthropic. Track per-task cost via usage events in JSONL stream. |

### Dependencies

1. **Codex CLI installed and authenticated** (`CODEX_API_KEY` or `~/.codex/auth.json`)
2. **Git worktree support** (already implemented in the orchestrator)
3. **AGENTS.md generation** from AGENT.md (instruction format translation -- engineering
   effort, not a technology dependency)
4. **JSONL parser** for result collection (trivial -- line-delimited JSON)
5. **JSON Schema** for structured output validation (define expected result shape)

### Recommended Roadmap Phases

**Phase 1: Prove the interface** (Trial validation)
- Build minimal Codex CLI adapter: `codex exec --json --full-auto --output-schema`
- Single task type: pure code edits (no tests, no web search)
- Manual instruction injection (write AGENTS.md by hand, not automated translation)
- Validate: JSONL parsing, result collection, exit code handling
- Success criteria: one nefario-orchestrated task completed via Codex with result
  quality comparable to Claude Code for that task type

**Phase 2: Automate instruction translation**
- Build AGENT.md -> AGENTS.md translator (strip frontmatter, adapt sections)
- Strip Claude Code-specific instructions from task prompts
- Test with multiple specialist agents (not just one)

**Phase 3: Integrate with orchestrator routing**
- Add harness selection to nefario configuration (not planning logic)
- Per-task-type routing rules (e.g., "formatting tasks -> Codex, reasoning tasks -> Claude")
- Cost tracking and quality comparison across harnesses

**Phase 4: Second harness (Aider)**
- Validates that the abstraction is truly tool-agnostic
- Different result collection path (git diff vs JSONL)
- If Phase 4 requires significant adapter rework, the abstraction failed

### What NOT to Build

- **Do not build a TypeScript orchestrator** -- the orchestrator is nefario running
  inside Claude Code. Adding a Node.js layer is unnecessary complexity.
- **Do not build container isolation** for Phase 1-3 -- worktrees are sufficient for
  code-editing tasks.
- **Do not build model routing intelligence** -- start with explicit user configuration,
  not automated quality-based routing.
- **Do not build an A2A integration** -- zero adoption in coding tools. Monitor only.

---

## Sources

- [Codex CLI Changelog](https://developers.openai.com/codex/changelog)
- [Codex CLI Reference](https://developers.openai.com/codex/cli/reference/)
- [Codex SDK Documentation](https://developers.openai.com/codex/sdk/)
- [Codex Non-Interactive Mode](https://developers.openai.com/codex/noninteractive)
- [Codex TypeScript SDK (GitHub)](https://github.com/openai/codex/tree/main/sdk/typescript)
- [Codex SDK (npm)](https://www.npmjs.com/package/@openai/codex-sdk)
- [Codex GitHub Releases](https://github.com/openai/codex/releases)
- [Container Use (InfoQ)](https://www.infoq.com/news/2025/08/container-use/)
- [AgentFS Overlay (Turso)](https://turso.tech/blog/agentfs-overlay)
- [AgentFS Documentation](https://docs.turso.tech/agentfs/introduction)
- [Parallel Code Agents (Kanaries)](https://docs.kanaries.net/topics/AICoding/parallel-code-agents)
- [Git Worktrees for AI Agents (Medium)](https://medium.com/@mabd.dev/git-worktrees-the-secret-weapon-for-running-multiple-ai-coding-agents-in-parallel-e9046451eb96)
- [Git Worktrees for AI (Upsun)](https://devcenter.upsun.com/posts/git-worktrees-for-parallel-ai-coding-agents/)
