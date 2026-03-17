# DevX Minion: Configuration DX for Harness Routing

## Summary

Harness routing configuration is the critical DX surface for multi-harness delegation. The design must satisfy three constraints simultaneously: (1) zero-config for users who only use Claude Code, (2) simple override for users who want one external harness, (3) fine-grained control for users who want per-agent or per-task-type routing. The recommendation is a single YAML file at `.nefario/routing.yml` (project-scoped, checked in) with a global user-level override at `~/.config/nefario/routing.yml`, using a layered defaults model where "Claude Code for everything" is the implicit baseline.

---

## 1. Where Should Config Live?

### Recommendation: `.nefario/routing.yml` (project) + `~/.config/nefario/routing.yml` (user)

**Why not CLAUDE.md?**
CLAUDE.md is Claude Code's instruction file. Routing config controls which tool runs -- it is operational configuration, not agent instructions. Mixing routing rules into CLAUDE.md violates separation of concerns and creates a file that serves two masters. It also means the routing config only works when Claude Code is the orchestrator, which is ironic for a feature whose purpose is to be harness-agnostic.

**Why not AGENT.md frontmatter?**
AGENT.md frontmatter already has a `model` field (opus/sonnet) which describes the quality tier the agent needs. Adding a `harness` field to frontmatter conflates two concerns: what the agent IS (identity, capabilities, model tier) vs. how the agent is INVOKED (which tool, which runtime). The invocation decision depends on user preferences, API key availability, and cost constraints -- none of which belong in the agent definition. Agent definitions should remain harness-agnostic.

**Why not DOMAIN.md?**
DOMAIN.md is the domain adapter. Routing is orthogonal to domain -- a regulatory compliance domain could route to Codex just as easily as a software development domain. Embedding routing in the domain adapter would force every domain to declare routing, even if most domains are identical.

**Why `.nefario/routing.yml`?**

| Factor | Assessment |
|--------|------------|
| Discoverability | `.nefario/` directory is a natural namespace for nefario-specific config. Users who `ls -a` will find it. |
| Separation of concerns | Routing config is cleanly separated from agent definitions, domain adapters, and Claude Code instructions. |
| Version control | Project-level file can be checked into the repo, letting teams share routing decisions. |
| Convention | Follows the `.github/`, `.vscode/`, `.cursor/` pattern of tool-specific dotfiles. |
| YAML format | Routing rules have moderate nesting (defaults, per-agent overrides, per-group overrides). YAML handles this well. TOML would work but is less familiar to the target audience. JSON lacks comments. |

**Why a user-level override?**

Some routing decisions are personal, not project-level: "I have a Codex API key but my teammate does not" or "I prefer Aider for all editing tasks." The user-level file at `~/.config/nefario/routing.yml` (following XDG conventions) provides this without polluting project config. User config takes precedence over project config (standard layering).

### Merge Semantics

```
Effective config = implicit defaults <- project .nefario/routing.yml <- user ~/.config/nefario/routing.yml
```

Later layers override earlier layers. Per-agent rules override per-group rules which override defaults. Environment variables override everything (for CI/CD).

---

## 2. What Granularity?

### Recommendation: Three levels -- default, per-group, per-agent

These three levels map to real user intent:

| Level | User intent | Example |
|-------|------------|---------|
| **Default** | "Use Codex for everything unless I say otherwise" | `default: codex` |
| **Per-group** | "Route all security-related agents to Claude Code (I trust it more for security), but everything else to Codex" | `groups: { security: claude-code }` |
| **Per-agent** | "Route code-review-minion to Claude Code specifically because it needs Bash access, which Codex has in sandbox but Aider lacks" | `agents: { code-review-minion: claude-code }` |

**Why not per-task-type or regex on task titles?**
Per-task-type routing (e.g., "all review tasks go to Claude Code") sounds appealing but creates a leaky abstraction. Task types are defined by the domain adapter's phase configuration, not by the user. Users think in terms of agents ("code-review-minion"), not task types ("review"). Regex on task titles is even worse -- it is fragile, hard to debug, and invites the kind of clever-but-brittle patterns that make configuration a maintenance burden.

**Why groups work**: The domain adapter already organizes agents into named groups (Protocol & Integration, Development & Quality, Security & Observability, etc.). These groups have semantic meaning -- all agents in a group share capability profiles. Routing at the group level is a natural shorthand.

---

## 3. How Should Defaults Work?

### Recommendation: Claude Code is the implicit default. Config is purely opt-in.

If `.nefario/routing.yml` does not exist, all agents run on Claude Code via the Task tool. This is the current behavior. No configuration file is needed for the current workflow.

If the file exists but an agent is not mentioned in any rule, it falls through to the default. If no default is specified, the implicit default is `claude-code`.

This means a minimal config for "try Codex for one agent" is:

```yaml
# .nefario/routing.yml
agents:
  frontend-minion: codex
```

That is it. Five lines, one decision. Every other agent continues to use Claude Code. The user does not need to enumerate all 23 minions.

---

## 4. Proposed Configuration Schema

```yaml
# .nefario/routing.yml
#
# Harness routing configuration for nefario orchestration.
# Agents not matched by any rule use the default harness (claude-code).

# Which harness to use when no specific rule matches.
# Omit this line to default to claude-code.
default: claude-code

# Per-harness configuration (API keys, model preferences, flags).
harnesses:
  codex:
    model: o3                    # default model for this harness
    flags: ["--full-auto"]       # additional CLI flags
    # API key: reads from OPENAI_API_KEY env var (no secrets in config)
  aider:
    model: claude-3-5-sonnet     # model name in aider's format
    flags: ["--yes", "--no-suggest-shell-commands"]
  claude-code:
    # No configuration needed -- this is the native harness.
    # Model is controlled by AGENT.md frontmatter.

# Route entire agent groups to a harness.
# Group names match the groups defined in DOMAIN.md.
groups:
  # "development-quality" is the group containing frontend-minion,
  # test-minion, debugger-minion, devx-minion, code-review-minion
  development-quality: codex

# Route specific agents to a harness. Overrides group-level routing.
agents:
  security-minion: claude-code   # override group default for security
  code-review-minion: claude-code  # needs Bash + Grep, keep on Claude Code
```

### Schema Validation Rules

1. `default` must be a known harness identifier (`claude-code`, `codex`, `aider`, `gemini`).
2. `harnesses` is optional. Only needed when configuring non-default flags or models.
3. `groups` keys must match group names from the active DOMAIN.md. Invalid group names produce a startup error with a "did you mean?" suggestion listing valid groups.
4. `agents` keys must match agent names from the active DOMAIN.md agent roster. Invalid agent names produce a startup error listing valid agents.
5. Unknown top-level keys are errors (not silently ignored). This catches typos.
6. The config file is validated at session startup (Phase 0), not at delegation time. Fail fast.

### Resolution Order

```
agent-specific rule > group-specific rule > explicit default > implicit default (claude-code)
```

### Environment Variable Overrides

For CI/CD and one-off overrides:

```bash
NEFARIO_DEFAULT_HARNESS=codex     # override the default
NEFARIO_HARNESS_security_minion=claude-code  # override a specific agent
```

Env vars use `_` instead of `-` for shell compatibility. Agent names are mapped: `security-minion` becomes `security_minion`.

---

## 5. Model Specification: Routing Config vs. Agent Frontmatter

This is the trickiest design boundary. Today, `model: opus` in AGENT.md frontmatter tells Claude Code which Anthropic model to use. In a multi-harness world, "opus" is meaningless to Codex (which uses o3/o4-mini) or Aider (which is model-agnostic).

### Recommendation: Agent frontmatter declares INTENT, routing config declares IMPLEMENTATION

| Concern | Where it lives | Example |
|---------|---------------|---------|
| Quality tier intent | AGENT.md frontmatter `model: opus` | "This agent needs deep reasoning" |
| Provider-specific model | `.nefario/routing.yml` harness config `model: o3` | "When running on Codex, use o3" |
| Tier-to-model mapping | Routing config or adapter defaults | `opus -> o3 (codex), opus -> claude-3-5-opus (aider)` |

The adapter could provide sensible tier-to-model defaults:

```yaml
# In .nefario/routing.yml or as built-in defaults
model-mapping:
  codex:
    opus: o3
    sonnet: o4-mini
  aider:
    opus: claude-3-5-opus
    sonnet: claude-3-5-sonnet
  gemini:
    opus: gemini-2.5-pro
    sonnet: gemini-2.5-flash
```

This preserves agent portability. An AGENT.md with `model: opus` works on any harness -- the routing layer translates the intent to the correct provider-specific model.

---

## 6. Capability Gating

Not all harnesses support all tools. The routing layer must prevent routing an agent to a harness that cannot satisfy the agent's capability requirements.

| Capability | Claude Code | Codex CLI | Aider |
|-----------|-------------|-----------|-------|
| File read/write | Yes | Yes | Yes |
| Bash execution | Yes | Yes (sandboxed) | No |
| Web search | Yes | No | No |
| Grep/Glob | Yes | Yes | No (uses shell) |
| Git operations | Yes | Yes | Yes (native) |

**The routing layer should validate at config load time**: if `security-minion` requires `Bash` (per its AGENT.md `tools` field) and is routed to Aider, emit:

```
Error: security-minion requires Bash but aider does not support it.

  .nefario/routing.yml:12
    security-minion: aider

  security-minion's AGENT.md declares these tools:
    Read, Glob, Grep, Bash, Edit, Write, WebSearch, WebFetch

  aider supports: file read/write, git operations

  Options:
    - Route security-minion to claude-code or codex instead
    - Remove Bash and WebSearch from security-minion's required tools
      (only if those capabilities are not needed for the task)
```

This is a hard error, not a warning. Routing to an incapable harness guarantees failure. The error message tells the user exactly what is wrong, what is expected, and how to fix it -- three components of a good error message.

---

## 7. Progressive Disclosure

The configuration surface should follow a progressive disclosure curve:

| User sophistication | Config needed | What they see |
|---|---|---|
| **Default user** (Claude Code only) | Nothing. No file. Zero config. | Current behavior, unchanged. |
| **Curious user** (wants to try Codex) | 2-line file: `default: codex` | Everything routes to Codex. If it fails, delete the file. |
| **Power user** (mixed routing) | 10-15 line file with agent overrides | Fine-grained control per agent or group. |
| **CI/CD user** (env var overrides) | Environment variables only | Override project defaults for automation without modifying files. |

---

## 8. Risks and Dependencies

### Risks

| Risk | Severity | Mitigation |
|------|----------|------------|
| Config drift between project and user levels creates confusing behavior | Medium | Print effective routing table at session startup (CONDENSE level) so user sees what is active. Provide `nefario routing --show` command. |
| Group names in DOMAIN.md change, breaking routing.yml references | Low | Validate at startup. Provide "did you mean?" suggestions. |
| Users configure a harness they do not have installed (no `codex` binary) | High | Check harness binary availability at config load time. Error with install instructions. |
| Model mapping becomes stale as providers release new models | Medium | Treat built-in mappings as defaults. Always allow explicit override in routing config. |
| Security: routing to external harnesses may expose secrets via different sandbox models | High | Out of scope for config DX (security-minion's concern) but routing validation should warn when routing to less-sandboxed harnesses. |

### Dependencies

| Dependency | Blocks |
|-----------|--------|
| Harness adapter abstraction (the wrapper layer described in external-harness-integration.md) | Everything. Config is meaningless without adapters to consume it. |
| Group name formalization in DOMAIN.md | Per-group routing. Currently groups are prose in DOMAIN.md, not structured data. Need a `groups` field in DOMAIN.md frontmatter. |
| Capability registry per harness | Capability gating validation. Need a machine-readable list of what each harness supports. |
| CLI detection (`which codex`, `which aider`) | Binary availability check at startup. |

---

## 9. Roadmap Issue Mapping

These are the discrete issues that need to be created, organized by concern:

### Config Format (design)
1. **Design routing.yml schema** -- Define YAML schema, validation rules, merge semantics, env var override format. This planning contribution is the starting point. Deliverable: JSON Schema or TypeScript type definition for routing.yml.
2. **Design model-mapping defaults** -- Define tier-to-model mapping for each supported harness. Research current model names for Codex, Aider, Gemini CLI. Deliverable: default mapping table.
3. **Formalize agent groups in DOMAIN.md** -- Add `groups` structured field to DOMAIN.md frontmatter so routing.yml can reference groups by name. Currently groups are prose headings, not machine-readable.

### Config Implementation (code)
4. **Config loader and validator** -- Parse routing.yml, merge project + user layers, validate against DOMAIN.md roster and groups, check harness binary availability. Fail fast with actionable errors.
5. **Capability gating** -- Build capability registry per harness. Validate agent tool requirements against harness capabilities at config load time.
6. **Routing resolver** -- Given an agent name, resolve through the precedence chain (agent > group > default > implicit) and return the harness identifier + model + flags.
7. **Env var override layer** -- Parse NEFARIO_DEFAULT_HARNESS and NEFARIO_HARNESS_* env vars, merge into effective config.

### Config Documentation
8. **Routing configuration guide** -- User-facing docs: quickstart (2-line config), reference (full schema), examples (common patterns), troubleshooting (common errors). Progressive disclosure in docs structure.
9. **Error message catalog** -- Design all validation error messages following three-component pattern (what went wrong, how to fix, how to get help). Include "did you mean?" for typos, install instructions for missing binaries, capability mismatch details.

### Integration
10. **Nefario SKILL.md integration** -- Add routing resolution to Phase 4 execution loop. Before spawning each agent, resolve harness through routing config. If harness is claude-code, use existing Task tool path. If external, invoke through adapter abstraction.
11. **Routing table display** -- At session startup, print effective routing table (CONDENSE level). Provide `nefario routing --show` for explicit inspection.

---

## 10. What NOT to Build

Applying YAGNI:

- **No GUI for routing config.** YAML is fine. Power users who configure routing can edit YAML.
- **No routing history or analytics.** Do not track which harness was used for which task. Users can see this in execution reports.
- **No auto-routing based on task content.** Do not try to infer the best harness from the task description. Users declare routing, the system follows it.
- **No A/B testing of harnesses.** Do not run the same task on two harnesses and compare. Users can do this manually if they want.
- **No per-task-type routing.** Agent-level and group-level granularity is sufficient. Task types are an implementation detail of the domain adapter, not a user-facing concept.
- **No hot-reload of routing config.** Config is read at session startup. If the user changes it, they start a new session. This is consistent with how CLAUDE.md works.
