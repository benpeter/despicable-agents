[< Back to Architecture Overview](architecture.md) | [Adapter Interface](adapter-interface.md)

# Routing Configuration

`.nefario/routing.yml` controls which LLM coding harness executes each specialist agent's work during nefario's Phase 4 execution. Without this file, everything routes to Claude Code -- no configuration is required, and existing behavior is fully preserved. Project teams that want to run specific agent groups through Codex CLI or Aider create this file and commit it to `.nefario/`. A user-level override at `~/.claude/nefario/routing.yml` allows personal harness preferences without touching the project config.

---

## Format Decision

The routing configuration schema is defined as Markdown field tables with YAML examples. TypeScript interface notation and JSON Schema were considered and rejected:

- **TypeScript** would be appropriate if the config schema were consumed by a TypeScript runtime. The config loader is implemented in shell (`lib/load-routing-config.sh`); no TypeScript runtime is being introduced (see "No TypeScript orchestrator" in the roadmap YAGNI constraints).
- **JSON Schema** adds tooling overhead (validators, generators) for no present benefit. Validation is implemented directly in the config loader reading from these field tables, not from a machine-readable schema.
- **Markdown field tables** match the pattern used throughout this documentation (see `adapter-interface.md`, `agent-anatomy.md`), remain human and LLM-readable without tooling, and live in version control alongside the implementation.

---

## Examples

### Minimal Config

The simplest valid routing config has a single field:

```yaml
# .nefario/routing.yml
default: claude-code
```

This is the explicit equivalent of zero-config behavior. Every agent routes to Claude Code. Use this form when you want to commit a routing file as a placeholder or to document the intent explicitly, without changing any behavior.

### Group Routing

Route an entire agent group to a different harness while keeping everything else on Claude Code:

```yaml
# .nefario/routing.yml
default: claude-code

groups:
  development-quality: codex
```

All five agents in the `development-quality` group (`frontend-minion`, `test-minion`, `debugger-minion`, `devx-minion`, `code-review-minion`) now run through Codex CLI. Agents in all other groups continue to use Claude Code.

### Full Config

All four sections, with inline comments showing resolution order:

```yaml
# .nefario/routing.yml
#
# Resolution order: agents > groups > default > implicit claude-code

# (1) Fallback for any agent not matched by groups or agents sections.
default: claude-code

# (2) Route all agents in a group together.
#     Individual agent overrides in the agents section take precedence over this.
groups:
  development-quality: codex     # frontend, test, debugger, devx, code-review
  design-documentation: aider    # ux-strategy, ux-design, software-docs, user-docs, product-marketing

# (3) Per-agent overrides. An agent listed here is always routed here,
#     regardless of which group it belongs to.
agents:
  security-minion: claude-code   # Keep security analysis on Claude even if its group routes elsewhere
  software-docs-minion: claude-code  # software-docs needs WebSearch; aider does not support it

# (4) Translate quality-tier signals (opus, sonnet) to provider-specific model IDs.
#     If this section is absent, built-in defaults are used per harness.
model-mapping:
  claude-code:
    opus: claude-opus-4-6
    sonnet: claude-sonnet-4-5
  codex:
    opus: o3
    sonnet: o4-mini
  aider:
    opus: claude-opus-4-6
    sonnet: claude-sonnet-4-5
```

---

## Field Reference

### `default`

| Field | Required | Type | Description |
|-------|----------|------|-------------|
| `default` | yes | string (enum: `claude-code`, `codex`, `aider`) | The harness used for any agent not matched by a `groups` or `agents` entry. Must be one of the three valid harness names. |

The `default` field is required whenever a routing file exists. A routing file without `default` is rejected at load time.

### `groups`

| Field | Required | Type | Description |
|-------|----------|------|-------------|
| `groups` | no | map of canonical group ID to harness name | Routes all agents in a named group to the specified harness. Keys must be canonical group IDs (see Canonical Group IDs below). Values must be valid harness names. |

Keys are validated against the canonical group ID list. User-defined or freeform group names are not accepted -- see Fields Considered and Excluded.

### `agents`

| Field | Required | Type | Description |
|-------|----------|------|-------------|
| `agents` | no | map of agent name to harness name | Routes a single named agent to the specified harness, overriding any group-level or default assignment. Keys are agent names matching the `name:` field in each agent's `AGENT.md` frontmatter. Values must be valid harness names. |

Agent names are validated against AGENT.md files discovered under the project root. An `agents` entry for an unrecognized name is rejected at load time.

### `model-mapping`

| Field | Required | Type | Description |
|-------|----------|------|-------------|
| `model-mapping` | no | map of harness name to tier-model pairs | Translates quality-tier signals (`opus`, `sonnet`) to provider-specific model IDs for each harness. Top-level keys must be valid harness names. Each harness entry is a map with keys `opus` and/or `sonnet`, values being model ID strings. |

**Model ID constraints**: Model IDs must match `[a-zA-Z0-9._-]+` (no spaces, shell metacharacters, or control characters) and may not exceed 256 characters.

**Built-in defaults** (used when `model-mapping` is absent or a tier is not specified):

| Harness | `opus` | `sonnet` |
|---------|--------|----------|
| `claude-code` | `claude-opus-4-6` | `claude-sonnet-4-5` |
| `codex` | `o3` | `o4-mini` |
| `aider` | `claude-opus-4-6` | `claude-sonnet-4-5` |

---

## Resolution Order

For a given agent, the loader resolves harness assignment in this order:

1. **Agent-level override**: If the agent's name appears in the `agents` section, use that harness. Stop.
2. **Group-level override**: Find the canonical group this agent belongs to. If that group appears in the `groups` section, use that harness. Stop.
3. **Default**: Use the `default` field value.
4. **Implicit claude-code**: If no routing file exists, use `claude-code`. This is the zero-config path (see Zero-Config Behavior).

**Edge case -- agent in both `agents` and its group in `groups`**: The `agents` entry always wins. Group assignments are lower priority than agent-specific overrides. This is intentional: group routing sets a default for a family of agents, and agent overrides let you pull specific members out of that group assignment.

```yaml
groups:
  development-quality: codex     # Routes test-minion to codex...
agents:
  test-minion: claude-code        # ...but this wins: test-minion goes to claude-code
```

---

## Capability Gating

Capability gating prevents routing mismatches from failing mid-task. When a routing file is loaded, the loader validates that every agent routed to a non-Claude Code harness only requires tools that harness supports. A hard error is raised at load time if a required tool is missing -- the config is rejected before any task execution begins.

**When it runs**: At config load time, before Phase 4 execution starts.

**What it checks**: For each agent entry in `agents` and each member of each group entry in `groups`, the loader reads the agent's `tools:` frontmatter field. If no `tools:` field is present, the agent is treated as requiring the full Claude Code tool set. The loader then checks whether the target harness supports all required tools.

**Capability registry**:

| Harness | Supported Tools |
|---------|----------------|
| `claude-code` | Read, Write, Edit, Bash, Glob, Grep, WebSearch, WebFetch |
| `codex` | Read, Write, Edit, Bash, Glob, Grep |
| `aider` | Read, Write, Edit |

Agents requiring `Bash` or web access cannot be routed to `aider`. Agents requiring `WebSearch` or `WebFetch` cannot be routed to `codex` or `aider`.

**Example capability mismatch error**:

```
Error: Capability mismatch for software-docs-minion routed to aider

  in: .nefario/routing.yml

  software-docs-minion requires: Read Write Edit Bash Glob Grep WebSearch WebFetch
  aider supports:                Read Write Edit
  unsupported:                   Bash Glob Grep WebSearch WebFetch

  Harnesses supporting these tools: claude-code

Route software-docs-minion to a harness that supports these tools,
or remove the agent-level override to use the default harness.
```

**Note on `tools:` as a trusted input**: The capability gating reads the `tools:` field from each AGENT.md at validation time. This field is the canonical declaration of what tools an agent needs, authored by the agent maintainer. There is no integrity check on this field -- an agent file could declare fewer tools than it actually uses. This is an accepted limitation for Milestone 1: capability gating catches the common case (routing to a harness that clearly cannot support the agent) without requiring a deeper capability inference system.

---

## Zero-Config Behavior

If `.nefario/routing.yml` does not exist:

- All agents route to `claude-code`
- No validation runs
- `yq` and `jq` are not required
- Behavior is identical to existing nefario Phase 4 execution

Zero-config is the default and the common case. Teams that do not need multi-harness routing do not need to create this file.

---

## User-Level Override

A user-level routing config at `~/.claude/nefario/routing.yml` is merged over the project-level config when present. This allows personal harness preferences (such as routing through a locally-running model) without modifying the shared project config.

**Merge semantics**: Each top-level section merges independently, with user values taking precedence over project values:

- `default`: User value replaces project value entirely.
- `groups`: Per-key merge. User entries for matching group IDs override project entries; project-only group entries are preserved.
- `agents`: Per-key merge. User entries for matching agent names override project entries; project-only agent entries are preserved.
- `model-mapping`: Block-level replacement per harness. If a user config specifies a `codex` block, the entire project `codex` block is replaced -- tier keys within the harness are not merged individually.

**The `model-mapping` asymmetry is intentional.** `groups` and `agents` merge at the key level because overriding a single agent or group while keeping other project-defined entries is the expected use case. `model-mapping` replaces at the harness block level because partial tier overrides (e.g., overriding `opus` but keeping the project's `sonnet`) would make the effective model mapping non-obvious. If you override a harness in `model-mapping`, you own both tiers.

**Example showing the asymmetry**:

Project config:
```yaml
default: claude-code
groups:
  development-quality: codex
  design-documentation: aider
model-mapping:
  codex:
    opus: o3
    sonnet: o4-mini
```

User config at `~/.claude/nefario/routing.yml`:
```yaml
default: claude-code
groups:
  design-documentation: claude-code  # Override: route design-documentation back to claude-code
model-mapping:
  codex:
    opus: o3
    sonnet: o4-mini-mini  # Override: different codex sonnet model
    # NOTE: you must specify both tiers -- there is no tier-level fallback to project values
```

Merged result:
- `groups.development-quality` = `codex` (from project; user did not override it)
- `groups.design-documentation` = `claude-code` (user override wins)
- `model-mapping.codex` = `{ opus: o3, sonnet: o4-mini-mini }` (entire user block; project block is gone)

**Trust model**: The project-level config is authored by the repo and treated as untrusted input -- it cannot escalate routing to a more privileged path than what the user allows. The user-level config at `~/.claude/nefario/routing.yml` overrides the project config and is trusted (it is on the user's own filesystem). Both configs are validated independently before merge; a malformed project config fails before the user override is consulted.

---

## Canonical Group IDs

The `groups` section only accepts these canonical group IDs:

| Group ID | Members |
|----------|---------|
| `boss` | gru |
| `governance` | lucy, margo |
| `protocol-integration` | mcp-minion, oauth-minion, api-design-minion, api-spec-minion |
| `infrastructure-data` | iac-minion, edge-minion, data-minion |
| `intelligence` | ai-modeling-minion |
| `development-quality` | frontend-minion, test-minion, debugger-minion, devx-minion, code-review-minion |
| `security-observability` | security-minion, observability-minion |
| `design-documentation` | ux-strategy-minion, ux-design-minion, software-docs-minion, user-docs-minion, product-marketing-minion |
| `web-quality` | accessibility-minion, seo-minion, sitespeed-minion |

User-defined or freeform group names are not accepted -- see Fields Considered and Excluded.

---

## Validation Errors

The loader emits a single error per validation failure category, or a count header followed by individual errors when multiple failures exist in the same category.

**YAML syntax error**:
```
Error: YAML syntax error

  in: .nefario/routing.yml

  <yq parse error output>
```

**Missing required field**:
```
Error: Missing required field 'default'

  in: .nefario/routing.yml

Add a 'default' field specifying the harness for unmatched agents:

  default: claude-code

Valid harnesses: claude-code, codex, aider
```

**Unknown harness name**:
```
Error: Unknown harness 'gemini' in groups.infrastructure-data

  in: .nefario/routing.yml

Valid harnesses: claude-code, codex, aider
```

**Unknown group name**:
```
Error: Unknown group name 'code-writers' in groups

  in: .nefario/routing.yml

Valid group IDs: boss design-documentation development-quality governance
                 infrastructure-data intelligence protocol-integration
                 security-observability web-quality
```

**Unknown agent name**:
```
Error: Unknown agent name 'my-custom-agent' in agents

  in: .nefario/routing.yml

Valid agents are discovered from AGENT.md files under: /path/to/project
Run: find /path/to/project -name 'AGENT.md' | xargs grep '^name:' to see current list.
```

**Invalid model ID**:
```
Error: Invalid model ID 'my model!' in model-mapping.codex.sonnet

  in: .nefario/routing.yml

Model IDs must match [a-zA-Z0-9._-]+ (no spaces, shell metacharacters, or control characters).
Example: claude-opus-4-6, o3, o4-mini
```

**Capability mismatch** (see Capability Gating section for full format).

**YAML anchors** (disallowed for security):
```
Error: YAML anchors and aliases are not allowed

  in: .nefario/routing.yml

Remove anchor definitions (&name) and alias references (*name).
Repeat the values explicitly instead.
```

---

## Fields Considered and Excluded

These features were considered during design and excluded. The rationale is recorded here so future contributors understand the decision without re-litigating it.

| Feature | Excluded because |
|---------|-----------------|
| JSON Schema output | Adds tooling overhead (validators, generators) with no present benefit. Validation is implemented directly in the shell loader. |
| "Did you mean?" suggestions | Premature for a first implementation. A clear error with the valid values list is sufficient. Fuzzy matching adds code complexity with marginal value. |
| CI/CD environment variable overrides | Speculative. No known use case requires overriding routing config via environment variable in CI. Can be added when a concrete need exists. |
| User-editable `capabilities:` section | The capability registry (tool support per harness) is a property of the harness itself, not a user preference. Allowing users to override it would defeat capability gating. The registry is updated only when a harness's supported tool set changes. |
| Arbitrary/user-defined group names | Group names are validated against the canonical agent group taxonomy. Freeform group names (e.g., `code-writers`) would create an implicit mapping layer that diverges from the agent taxonomy and is invisible to capability gating. Groups must match canonical IDs. |

---

## Stability Note

This specification is part of Milestone 1 and may evolve as Milestone 2 (Codex) and Milestone 3 (Aider) validate the routing surface.
