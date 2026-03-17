## Meta-Plan

### Planning Consultations

#### Consultation 1: YAML Schema Design and Config Loading Architecture
- **Agent**: devx-minion
- **Planning question**: The routing config at `.nefario/routing.yml` needs a YAML schema with three resolution layers (agent > group > default), model-mapping per harness, and capability gating. The project is shell-based (bash, awk -- see `install.sh` and `assemble.sh` for conventions). What is the right approach for YAML parsing and validation in a bash/shell context? Should we use `yq`, a small Python script, or pure awk? What error messages and validation patterns give the best developer experience for config errors (invalid harness names, unknown agent names, missing required fields)? Consider that zero-config (no file) must silently default to claude-code.
- **Context to provide**: `docs/external-harness-integration.md` (Routing and Configuration section, lines 257-300), `docs/adapter-interface.md` (full document -- defines types the config references), `install.sh` and `assemble.sh` (for shell conventions), `docs/external-harness-roadmap.md` (#139 scope and acceptance criteria)
- **Why this agent**: devx-minion owns CLI design, configuration files, and error messages. The config loader is fundamentally a developer experience problem -- clear validation, actionable errors, and a zero-friction default path.

#### Consultation 2: Capability Gating Data Model
- **Agent**: api-design-minion
- **Planning question**: The config loader must validate that each agent's `tools:` requirements (from AGENT.md frontmatter) are satisfiable by the target harness's capabilities. This requires a capability registry mapping harness names to supported tool sets. Where should this registry live -- hardcoded in the loader, a separate YAML file, or embedded in `routing.yml`? What is the right granularity for capability names (exact tool names like `Bash`, `WebSearch` vs. capability categories like `code-edit`, `web-access`)? The adapter interface spec uses `required_agent_tools` with exact tool names (`Read`, `Edit`, `Bash`, `WebSearch`). Should the config layer use the same vocabulary?
- **Context to provide**: `docs/adapter-interface.md` (DelegationRequest.required_agent_tools field), `docs/external-harness-integration.md` (Tool Inventory section -- tool parity row in gap analysis, capability comparison across harnesses), AGENT.md frontmatter samples showing `tools:` field values
- **Why this agent**: api-design-minion owns interface design, type vocabularies, and contract clarity. The capability registry is a contract between the routing config, the adapter interface, and the AGENT.md frontmatter -- getting the vocabulary and granularity right now prevents cascading rework in M2-M3.

#### Consultation 3: Config Resolution Logic and User-Level Override Merge
- **Agent**: ai-modeling-minion
- **Planning question**: The config has two sources: project-level `.nefario/routing.yml` and an optional user-level override. The resolution order within a single config is agent > group > default > implicit claude-code. How should user-level overrides merge with project-level? Full replacement, deep merge, or per-section override? The group names in the config (e.g., `code-writers`, `data-analysts` in the power-user example) do not match the canonical group names in the agent roster (e.g., "Development & Quality Minions", "Infrastructure & Data Minions"). Should the config reference canonical group IDs, or let users define arbitrary groupings? If arbitrary, how do we validate agent membership? This matters for the SKILL.md prompt construction -- nefario builds task prompts referencing agent names, and the routing layer intercepts at Phase 4.
- **Context to provide**: `docs/external-harness-integration.md` (Routing and Configuration section), `docs/external-harness-roadmap.md` (full M1 scope), `nefario/AGENT.md` (Phase 4 execution model), `domains/software-dev/DOMAIN.md` (agent roster with canonical group names)
- **Why this agent**: ai-modeling-minion owns multi-agent architectures and orchestration design. The config resolution logic determines how nefario's routing dispatch works. The group-naming question is fundamentally about agent taxonomy and how the orchestrator maps agent identities to execution targets.

#### Consultation 4: Security Review of Config Loading
- **Agent**: security-minion
- **Planning question**: The config loader reads YAML from two filesystem locations and uses it to determine which external tools execute tasks. What are the security considerations? Specifically: (1) Can a malicious `routing.yml` in a cloned repo redirect tasks to a compromised tool? (2) Should user-level config always take precedence over project-level for security-sensitive settings? (3) The adapter interface requires `working_directory` validation (path traversal prevention) -- should similar validation apply to config file paths? (4) Are there YAML-specific attack vectors (billion laughs, anchor references) that the parser must handle?
- **Context to provide**: `docs/adapter-interface.md` (Behavioral Contract section -- security requirements), `docs/external-harness-integration.md` (Routing section), `docs/external-harness-roadmap.md` (#139 scope)
- **Why this agent**: security-minion must evaluate any configuration surface that controls code execution routing. A routing config is a trust boundary -- it determines which tool processes each task.

### Cross-Cutting Checklist

- **Testing**: Include test-minion for planning. The acceptance criteria are concrete and testable (minimal config loads, power-user config loads, capability gating rejects invalid routing, zero-config defaults). test-minion should advise on test approach for a shell-based config loader (unit tests via bats? integration tests?).
- **Security**: Included as Consultation 4 above. Config loading is a trust boundary.
- **Usability -- Strategy**: ALWAYS include. How does the routing config fit the user journey from "I just use Claude Code" to "I want to try Codex for some agents"? Is the progressive disclosure right (zero-config -> minimal default -> groups -> per-agent)? ux-strategy-minion should evaluate whether the config complexity ladder matches real user progression.
- **Usability -- Design**: Not needed for planning. No UI components. The config is a YAML file edited directly (per roadmap YAGNI constraints: "No configuration UI").
- **Documentation**: Include software-docs-minion for planning. The schema needs documentation -- both inline (comments in example configs) and as a reference page. software-docs-minion should advise on where the schema reference lives (new doc page? section in existing doc?) and what format (annotated examples vs. field tables).
- **Observability**: Not needed. No runtime component -- this is a config loader that runs at orchestration startup, not a production service.

### Notable Exclusions

- **data-minion**: YAML config is not a database schema. The "schema" here is a configuration file format, not a data model requiring database expertise.
- **iac-minion**: Despite this being configuration-related, the config is application-level (routing rules), not infrastructure (Terraform, Docker, CI/CD). No infrastructure provisioning or deployment changes.
- **mcp-minion**: The external harness integration explicitly bypasses MCP ("MCP is not the right delegation layer" per the feasibility study). No MCP concepts in the config.

### Anticipated Approval Gates

1. **YAML schema definition** (MUST gate) -- The schema defines the contract that all subsequent milestones (M2-M4) implement against. Hard to reverse once adapters are built against it. High blast radius (every downstream issue depends on #139). Key decisions requiring approval: group naming convention (canonical vs. arbitrary), capability registry location, user-override merge semantics.

2. **Capability registry data model** (likely part of the schema gate above) -- Whether capabilities are hardcoded or externalized, and what vocabulary they use, affects every adapter implementation.

### Rationale

This task is primarily a developer experience and interface design problem, secondarily a security concern:

- **devx-minion** is the natural primary because the config loader's core job is clear errors, progressive complexity, and zero-friction defaults -- all devx concerns.
- **api-design-minion** is needed because the capability gating creates a contract between the config surface, the adapter interface types, and the AGENT.md frontmatter. Getting the type vocabulary right requires interface design thinking.
- **ai-modeling-minion** is needed because the config resolution logic directly shapes how nefario routes during Phase 4, and the group taxonomy question ties into the multi-agent architecture.
- **security-minion** is needed because any configuration that controls which tool executes code is a trust boundary.
- **ux-strategy-minion** and **software-docs-minion** provide cross-cutting review of the progressive disclosure model and documentation approach.
- **test-minion** advises on how to test a shell-based config loader.

### Scope

**What this task achieves**: Define the YAML schema for `.nefario/routing.yml` and implement a config loader with validation. The loader reads the config, resolves which harness handles each agent, validates capability compatibility, and provides actionable errors on misconfiguration. Zero-config (no file) defaults to claude-code.

**In scope**:
- YAML schema definition (default, groups, agents, model-mapping)
- Resolution order implementation (agent > group > default > implicit claude-code)
- Capability gating (validate agent tools vs. harness capabilities at load time)
- Project-level and user-level config loading with merge semantics
- Validation with actionable error messages
- Shell-based implementation matching project conventions

**Out of scope**:
- Adapter implementation (M2-M3)
- "Did you mean?" suggestions (per roadmap YAGNI)
- JSON Schema output (per roadmap YAGNI)
- CI/CD environment variable overrides (per roadmap YAGNI)
- Configuration UI (per roadmap YAGNI)
- Phase 4 dispatch integration (#148, M4)

### External Skill Integration

No external skills detected relevant to this task. `despicable-lab` and `despicable-statusline` are project-local skills for agent management and status display, neither of which covers configuration schema or loader implementation.
