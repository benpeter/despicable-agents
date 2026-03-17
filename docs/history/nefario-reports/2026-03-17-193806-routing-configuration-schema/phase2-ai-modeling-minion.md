## Domain Plan Contribution: ai-modeling-minion

### Recommendations

**1. Use canonical group IDs, not arbitrary groupings.**

The power-user example in the feasibility study uses `code-writers` and `data-analysts` -- names that do not exist in the agent roster. This creates an indirection problem: who belongs to `code-writers`? The config cannot answer that question without an additional membership mapping, which adds complexity with no proportional benefit.

The nefario AGENT.md roster already defines 9 canonical groups with clear, stable membership:

| Canonical Group ID (proposed slug) | Members |
|-------------------------------------|---------|
| `boss` | gru |
| `governance` | lucy, margo |
| `protocol-integration` | mcp-minion, oauth-minion, api-design-minion, api-spec-minion |
| `infrastructure-data` | iac-minion, edge-minion, data-minion |
| `intelligence` | ai-modeling-minion |
| `development-quality` | frontend-minion, test-minion, debugger-minion, devx-minion, code-review-minion |
| `security-observability` | security-minion, observability-minion |
| `design-documentation` | ux-strategy-minion, ux-design-minion, software-docs-minion, user-docs-minion, product-marketing-minion |
| `web-quality` | accessibility-minion, seo-minion, sitespeed-minion |

The config loader should derive this mapping from the roster in the nefario AGENT.md (or from a canonical registry that both nefario and the config loader share). If a `groups:` key references a name not in the canonical set, validation raises a hard error with the list of valid group IDs.

Rationale: Arbitrary group names require the user to define membership somewhere, turning a simple routing config into a dual-purpose roster+routing file. This violates the single-responsibility principle and creates a second source of truth for agent grouping that can drift from the-plan.md. Canonical IDs keep the config purely about routing decisions. The per-agent `agents:` override already covers any case where the canonical grouping does not match the user's routing intent.

**2. User-level overrides should use shallow merge per top-level key, not deep merge.**

Proposed merge behavior for `~/.nefario/routing.yml` (user) over `.nefario/routing.yml` (project):

| Key | Merge strategy | Rationale |
|-----|----------------|-----------|
| `default` | User replaces project | Single scalar value -- no meaningful "merge" |
| `model-mapping` | User replaces entire block per harness | Deep-merging individual tier entries across two files creates invisible interactions where the user cannot tell which file set `opus` for `codex`. Full replacement per harness is predictable. |
| `groups` | User entries override project entries for the same group; project entries for other groups are preserved | Allows user to reroute a specific group without restating the entire project config |
| `agents` | Same as groups -- per-key override with preservation | Same rationale |

This is "shallow merge per section" -- not full replacement (too blunt, forces user to restate everything) and not recursive deep merge (too subtle, makes override reasoning hard). It matches how CLAUDE.md and most YAML config hierarchies (e.g., Docker Compose, npm config) work in practice.

The user file should be optional and explicitly documented as user-scope (not committed to the repo). A `.gitignore` entry for `~/.nefario/` is implicit since it is outside the repo, but document this in the config loading section.

**3. Model-mapping should be optional with sensible defaults.**

If `model-mapping` is absent, the config loader should use hardcoded defaults per harness:

```yaml
# Implicit defaults when model-mapping is omitted
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

These defaults are embedded in the config loader, not in the YAML schema definition. They represent "reasonable starting points" and will evolve as models change. Storing them in code (not config) means the user gets updated defaults on upgrade without touching their config.

When the user provides a `model-mapping` for a specific harness, it fully replaces that harness's defaults (per recommendation 2). When the user omits `model-mapping` entirely, all defaults apply.

Model IDs are opaque strings passed to the adapter -- the config loader does not validate them against any model registry. Validation happens at invocation time when the adapter passes the ID to the CLI tool. This avoids coupling the config loader to provider-specific model catalogs that change frequently.

**4. Resolution order documentation should be explicit in the schema, not just the code.**

The resolution chain `agent > group > default > implicit claude-code` is the core routing logic. It should appear as a comment in every example config and in the schema documentation. Users will debug routing issues by understanding this chain. Make it visible, not buried in implementation.

**5. Capability gating should be load-time, not runtime.**

The feasibility study already calls for this. Reinforcing: capability gating must happen when the config is loaded, before any Phase 4 task is dispatched. A harness capability registry (static, per-adapter) lists which tools each harness supports. The config loader cross-references each agent's `tools:` frontmatter against the target harness's capabilities. Failure is a hard error with the specific tool that is missing and the specific agent that requires it.

Example error: `Routing error: security-minion requires [Bash, WebSearch] but aider supports [Read, Write, Edit]. Route security-minion to a harness with Bash and WebSearch support, or override in the agents: section.`

This is critical for multi-agent orchestration reliability. A routing misconfiguration discovered mid-Phase-4 after three agents have already committed changes is far more costly than a startup failure.

**6. Config file location should be `.nefario/routing.yml` (project-level) with no environment variable override for M1.**

The roadmap's "What NOT to Build" section correctly excludes CI/CD env var overrides. Reinforcing this: environment variable overrides for config values are a premature abstraction. If CI/CD needs arise, they belong in a future milestone after the config surface is proven stable. Adding env var precedence now would create a third layer in the merge hierarchy that complicates debugging for zero current consumers.

### Proposed Tasks

**Task 1: Define canonical group ID registry**
- Extract the 9 canonical group slugs and their agent memberships from the nefario AGENT.md roster
- Decide where to persist this mapping (options: embedded in config loader code, or a small YAML file like `.nefario/groups.yml` that is generated from the-plan.md)
- My recommendation: embed in code for M1, extract to a generated file in a future milestone if the roster changes frequently enough to warrant it
- Agent: devx-minion (config design) with ai-modeling-minion supporting (agent roster knowledge)

**Task 2: Define YAML schema for `.nefario/routing.yml`**
- Four top-level keys: `default` (string, required if file exists), `model-mapping` (map of harness -> tier -> model ID, optional), `groups` (map of canonical group ID -> harness, optional), `agents` (map of agent name -> harness, optional)
- Document the resolution order as a schema-level comment
- Include the minimal and power-user examples from the feasibility study, updated to use canonical group IDs
- Agent: devx-minion (primary, schema design) with ai-modeling-minion supporting (model-mapping semantics)

**Task 3: Implement config loading with validation**
- Load from `.nefario/routing.yml` (project) and `~/.nefario/routing.yml` (user, optional)
- Apply shallow-merge-per-section strategy
- Validate: all harness names reference known adapters, all group names reference canonical IDs, all agent names reference the agent roster, model-mapping tiers are `opus` or `sonnet` only
- Hard error with actionable message on any validation failure
- Zero-config path: missing file returns a config object where everything resolves to `claude-code`
- Agent: devx-minion (primary, implementation) with test-minion supporting (validation test cases)

**Task 4: Implement capability gating**
- Define a static capability registry per harness (which tools each harness supports)
- At config load time, for every agent routed to a non-claude-code harness, check the agent's `tools:` frontmatter against the harness capability list
- Produce a clear error listing the agent, the missing tool, and the assigned harness
- Agent: devx-minion (primary) with ai-modeling-minion supporting (tool requirement analysis)

**Task 5: Implement resolve function**
- `resolve(agentName: string, config: RoutingConfig) -> { harness: string, model: string }`
- Follows the `agent > group > default > implicit claude-code` chain
- Returns both the harness identifier and the resolved model ID for the agent's tier
- Agent: devx-minion

### Risks and Concerns

**Risk 1: Canonical group IDs create rigidity if the roster evolves.**
- Likelihood: Low (roster has been stable since v1.5; the-plan.md is human-edited and changes slowly)
- Impact: Low (adding a new group is a one-line code change in the config loader)
- Mitigation: Derive group IDs from the roster programmatically if possible, so changes propagate. If the group registry is code-embedded, add a test that verifies it matches the current AGENT.md roster.

**Risk 2: Model ID opacity means typos are invisible until invocation.**
- Likelihood: Medium (model IDs like `claude-opus-4-6` vs `claude-opus-4.6` are easy to mistype)
- Impact: Medium (task fails at invocation time, not config load time; debugging requires checking adapter logs)
- Mitigation: For M1, accept this risk. Document that model IDs are opaque strings and typos will cause runtime failures. In a future milestone, adapters could expose a `validate_model(id)` method that the config loader calls.

**Risk 3: Shallow-merge-per-section surprises users who expect deep merge on model-mapping.**
- Likelihood: Low (most users will have either a project config or a user config, not both)
- Impact: Low (clear documentation and an example of the merge behavior prevents confusion)
- Mitigation: Document the merge strategy with a concrete before/after example showing project config, user config, and effective config.

**Risk 4: The user-level override path (`~/.nefario/routing.yml`) creates a global routing preference that applies across all projects.**
- Likelihood: Medium (a user working on multiple projects may want different routing per project)
- Impact: Medium (user unknowingly routes agents to a wrong harness for a project where it does not apply)
- Mitigation: Consider making the user-level path per-project rather than global. Alternative: document that user-level config is global and per-project overrides should go in the project-level file. For M1, keep it simple -- user-level is global.

**Risk 5: Capability gating requires maintaining a static capability list per harness.**
- Likelihood: High (tools evolve their capabilities; Aider may add Bash support in a future version)
- Impact: Low (false negatives are preferable to false positives -- an outdated capability list blocks a valid routing, which is visible and fixable; an overly permissive list lets an invalid routing through, which causes mid-execution failures)
- Mitigation: Version-pin adapter capability lists alongside adapter version requirements. When a harness version changes, the capability list is reviewed as part of adapter maintenance.

### Additional Agents Needed

- **devx-minion** (primary implementer): Config schema design, YAML loading, validation logic, resolve function. This is configuration file design -- devx-minion's core domain.
- **test-minion** (supporting): Validation test cases for config loading, merge behavior, capability gating error messages, zero-config path, and the resolve function's precedence chain.
- **lucy** (governance review): Verify that canonical group IDs align with the roster in the-plan.md and that the config surface is consistent with existing project conventions.
- **margo** (governance review): Verify that the config surface is minimal -- no speculative keys, no over-engineering of the merge strategy.
