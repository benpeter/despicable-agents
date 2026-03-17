## Domain Plan Contribution: api-design-minion

### Recommendations

#### 1. Use Exact Tool Names as the Capability Vocabulary

The system already has a single, well-established vocabulary for tool capabilities: the exact tool names used in AGENT.md `tools:` frontmatter and in `DelegationRequest.required_agent_tools`. These are: `Read`, `Write`, `Edit`, `Bash`, `Glob`, `Grep`, `WebSearch`, `WebFetch`.

**Do not introduce an abstraction layer** (e.g., `code-edit`, `web-access`, `shell-execution`). Here is why:

- **The vocabulary already exists and is authoritative.** Every AGENT.md file already declares requirements using exact tool names. The adapter interface spec (`required_agent_tools`) already adopted this vocabulary. Introducing a second vocabulary (categories) creates a mapping problem with zero benefit.
- **Categories create ambiguity at the boundary.** Does `code-edit` mean `Read + Write + Edit`, or just `Edit`? Does `web-access` mean `WebSearch`, `WebFetch`, or both? Every category requires a definition, and every definition is a judgment call that can diverge from what agents actually need. Exact names have no ambiguity.
- **The set is small and stable.** Eight tool names is not a vocabulary that needs abstraction for manageability. Categories help when vocabularies are large (hundreds of items) or unstable (changing weekly). Neither applies here.
- **Cross-layer consistency eliminates translation bugs.** The data flows: `AGENT.md tools:` -> config loader capability check -> `DelegationRequest.required_agent_tools` -> adapter. If every layer uses the same strings, there is no translation step, no mapping table to maintain, and no opportunity for a category mapping to silently drift from actual tool behavior.

A future tool with novel capabilities (e.g., a `DatabaseQuery` tool) would just add a new name to the list. Categories would not help with that -- you would still need to update the category mapping.

#### 2. Hardcode the Capability Registry in the Loader, Not in the Config

The capability registry should be a hardcoded data structure in the config loader source code, not a user-editable section in `routing.yml` or a separate file.

**Why hardcoded:**

- **Capabilities are facts about tool implementations, not user preferences.** Aider does not support `Bash` -- that is a property of Aider, not a routing decision. Users should not be able to (or need to) declare what a harness can do. The loader knows.
- **Fewer moving parts.** A separate capability file or an embedded `capabilities:` block in the config is another thing to get wrong, another validation target, and another surface for stale data. The loader is the single point that needs to know.
- **Version-pinned correctness.** When a new adapter is added (M2, M3, future milestones), the developer adding the adapter also updates the capability registry in the same codebase. This is a compile-time guarantee (or its shell equivalent) that capability data matches adapter code.
- **Zero-config coherence.** The implicit `claude-code` default must know its own capabilities without any config file existing. Hardcoding is the only design where zero-config works without a fallback file.

**Concrete structure** (pseudo-code; actual implementation per devx-minion's shell conventions):

```
# Capability registry -- hardcoded in the config loader
# Each harness maps to the set of tool names it supports.
# Tool names match AGENT.md `tools:` field values exactly.

CAPABILITIES = {
  "claude-code": ["Read", "Write", "Edit", "Bash", "Glob", "Grep", "WebSearch", "WebFetch"],
  "codex":       ["Read", "Write", "Edit", "Bash"],
  "aider":       ["Read", "Write", "Edit"]
}
```

When a new adapter is introduced (e.g., Gemini CLI in M5), a single line is added to this registry. No config changes, no documentation changes, no user action.

**What users see when gating fails:**

```
Error: Cannot route security-minion to 'aider'.
  Agent requires: Bash, WebSearch
  Aider supports: Read, Write, Edit
  Unsupported tools: Bash, WebSearch

Fix: Route security-minion to a harness that supports these tools,
     or override in the 'agents:' section of .nefario/routing.yml.
```

This error message is actionable because it uses the exact tool names from the agent's `tools:` field -- the user can cross-reference directly without mentally translating categories.

#### 3. Match the Adapter Interface Vocabulary Exactly

The config layer MUST use the same vocabulary as `DelegationRequest.required_agent_tools`. This is not just a recommendation -- it is a contract alignment requirement.

The data flow is:

```
AGENT.md tools: [Read, Edit, Bash, WebSearch]
         |
         v
Config loader reads tools: field
         |
         v
Capability gating: check each tool name against harness capabilities
         |
         v
DelegationRequest.required_agent_tools: [Read, Edit, Bash, WebSearch]
         |
         v
Adapter receives and respects the tool list
```

If any layer uses a different vocabulary, you need a mapping function. Mapping functions are maintenance surface, bug surface, and testing surface. There is no upside to a second vocabulary when the first one is already defined and used end-to-end.

#### 4. Do Not Add a `capabilities:` Section to routing.yml

I anticipate a temptation to add a user-editable capabilities block to the config for "extensibility." Resist it. Reasons:

- **Users cannot meaningfully declare capabilities.** If a user says `aider` supports `Bash`, but it does not, the task will fail at runtime with a confusing tool error instead of a clear config-time rejection. The capability registry exists to prevent exactly this failure mode.
- **Extensibility for unknown harnesses is YAGNI.** The roadmap explicitly scopes M1-M4 to Claude Code, Codex, and Aider. M5+ adds Gemini. Each new harness requires adapter code anyway -- adding a capability line to the registry at that point is trivial.
- **Config complexity budget.** The config already has four sections (`default`, `groups`, `agents`, `model-mapping`). A fifth section for capabilities overflows the complexity budget for a file that most users will never edit (zero-config default). Every section is a thing to document, validate, and explain in error messages.

#### 5. Capability Gating Should Be Fail-Fast at Load Time

The adapter interface spec says capability gating happens at "config load time" (Issue #139 acceptance criteria). I want to reinforce why this matters from an API design perspective:

- **Fail-fast is a contract guarantee.** If the config loads successfully, every routing decision in it is satisfiable. This is a strong invariant that simplifies all downstream code -- adapters never need to check capabilities, and the orchestrator never needs to handle "incompatible harness" errors mid-execution.
- **Load-time validation enables dry-run checking.** A user can validate their config before running a session. This is impossible if capability checks are deferred to request time.
- **The error surface is bounded.** All capability errors surface in one place (config loading), in one format (the actionable error message above), at one time (startup). No scattered error handling.

Corollary: the loader must have access to all agent `tools:` declarations at load time. This means it needs to read AGENT.md frontmatter for every agent referenced in the config (directly or via group membership). This is a dependency the implementation must account for.

#### 6. The `model-mapping` Section Should Allow Harness-Level Defaults

The current power-user example already shows the right pattern:

```yaml
model-mapping:
  codex:
    opus: o3
    sonnet: o4-mini
```

One design clarification: if a harness appears in `model-mapping` but omits a tier, the adapter should use its own sensible default (per the adapter interface spec: "apply a sensible default rather than failing"). The config loader should NOT reject a model-mapping that omits a tier. This is intentional -- it allows partial specification.

However, if a harness does NOT appear in `model-mapping` at all, the adapter uses its built-in defaults. This means `model-mapping` is entirely optional -- consistent with the zero-to-power-user progressive disclosure.

### Proposed Tasks

#### Task 1: Define the Capability Registry

- Hardcode a capability map in the config loader: harness name -> list of supported tool names.
- Tool names match `AGENT.md tools:` field values exactly (the eight names: Read, Write, Edit, Bash, Glob, Grep, WebSearch, WebFetch).
- Initial registry covers three harnesses: `claude-code` (all eight), `codex` (Read, Write, Edit, Bash), `aider` (Read, Write, Edit).
- Adding a new harness = adding one line. No config changes.

#### Task 2: Implement Capability Gating in the Config Loader

- At config load time, for each routing rule (agent or group), resolve the target harness and validate that every tool in the agent's `tools:` frontmatter is in the harness capability set.
- Produce an actionable error message on mismatch listing: agent name, target harness, required tools, supported tools, unsupported tools, and a fix suggestion.
- If a group routes to a constrained harness, validate ALL agents in that group, not just the first one. Report all violations, not just the first.
- Validation requires reading AGENT.md frontmatter for relevant agents. The loader must know where AGENT.md files live (likely passed as a parameter or derived from project structure).

#### Task 3: Document the Capability Vocabulary Contract

- Document in the schema reference that capability names are exact tool names from AGENT.md `tools:` fields.
- Document that the registry is maintained in the loader source code and is not user-editable.
- Include the three-harness capability table in the routing.yml documentation.

### Risks and Concerns

1. **Loader needs access to AGENT.md frontmatter at load time.** Capability gating requires knowing each agent's `tools:` list. If the loader runs before AGENT.md files are available (e.g., agents are installed via symlinks that may not exist in all environments), gating will fail. The implementation must handle: (a) agents referenced in config but whose AGENT.md cannot be found, and (b) agents whose AGENT.md has no `tools:` field (meaning all tools -- which implies claude-code-only routing unless the user explicitly acknowledges the full tool set).

2. **Missing `tools:` field means "all tools."** Per the project's CLAUDE.md notes on tool filtering: "Omitting `tools:` entirely gives ALL tools." An agent without a `tools:` field effectively requires all eight tools. This means routing such an agent to `aider` or `codex` should fail capability gating unless the user overrides. This is correct behavior but may surprise users who have not thought about it. The error message should explain that the missing `tools:` field implies all tools.

3. **Codex tool set may expand.** The current Codex capability list (Read, Write, Edit, Bash) is based on the feasibility study assessment. If Codex adds WebSearch or similar capabilities, the hardcoded registry must be updated. This is low-risk because adding a capability is additive (it can only enable more routing options, never break existing ones) and requires a one-line code change.

4. **Group membership is not machine-readable today.** The plan defines groups in prose (e.g., "Protocol & Integration" contains mcp-minion, oauth-minion, api-design-minion, api-spec-minion) but there is no structured mapping file. Either the config loader needs a hardcoded group->agent mapping, or group names in `routing.yml` must match something discoverable. This is primarily ai-modeling-minion's concern (Consultation 3), but it affects capability gating because validating all agents in a group requires knowing which agents are in the group.

### Additional Agents Needed

None beyond those already identified in the meta-plan. The four consultations (devx-minion, api-design-minion, ai-modeling-minion, security-minion) plus the cross-cutting reviewers (ux-strategy-minion, software-docs-minion, test-minion) cover the capability gating design comprehensively.

One note for **ai-modeling-minion** (Consultation 3): The group membership question directly affects capability gating. If groups are arbitrary user-defined labels, capability gating cannot validate group members without the user also declaring membership. If groups are canonical (matching the-plan.md taxonomy), the loader can resolve members from the project structure. This coupling should be resolved in the synthesis phase, not independently.
