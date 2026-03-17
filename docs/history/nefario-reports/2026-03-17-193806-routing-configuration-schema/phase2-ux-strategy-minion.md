## Domain Plan Contribution: ux-strategy-minion

### Recommendations

#### 1. The Progressive Disclosure Ladder Is Correct -- But Needs One Calibration

The four levels -- zero-config, minimal default, groups, per-agent -- map well to a real user adoption journey. The progression follows what JTBD analysis predicts:

| Stage | User Job | Config Level | Cognitive Load |
|-------|----------|--------------|----------------|
| **Just works** | "I want agents to work like before" | Zero-config (no file) | Zero -- invisible computing |
| **Explicit control** | "I want to be deliberate about my default" | `default: claude-code` | Near-zero -- one line, one concept |
| **Experimentation** | "I want to try Codex for a batch of agents" | `groups:` block | Low -- one new concept (group routing) |
| **Fine-tuning** | "This specific agent works better on this tool" | `agents:` block | Moderate -- per-agent reasoning required |

This ladder respects Hick's Law: each step introduces exactly one new concept. Users satisfice at whatever level serves their job without being forced up the ladder.

**The calibration needed**: The `model-mapping` block sits awkwardly outside this ladder. It is an advanced concept that appears at any level (you might want a minimal config with a custom model mapping). It should be documented and positioned as orthogonal to the routing ladder -- a separate axis of customization, not a step in the progression. The schema should not require `model-mapping` for any level of routing config to work. If `model-mapping` is absent, adapters use sensible per-tool defaults. This is already implied in the adapter interface spec ("If the routing config has no model-mapping entry for a tier, the adapter should apply a sensible default"), but the config documentation must make this as explicit as the zero-config path.

#### 2. Group Names Must Be Canonical, Not User-Defined

The power-user example uses names like `code-writers` and `data-analysts`. The DOMAIN.md roster uses names like "Development & Quality Minions" and "Infrastructure & Data Minions." This is a friction source waiting to happen.

From a cognitive load perspective: if the user must invent group names AND remember which agents belong to each group, this is a recall task, not a recognition task (violates Nielsen Heuristic 6). The user has to hold a mental model of agent-to-group mappings that exists nowhere in the config file itself.

**Recommendation**: Use the canonical group IDs from the domain roster as the only valid group keys. Derive short, kebab-case IDs from the existing group names:

- `protocol-integration` (Protocol & Integration Minions)
- `infrastructure-data` (Infrastructure & Data Minions)
- `intelligence` (Intelligence Minions)
- `development-quality` (Development & Quality Minions)
- `security-observability` (Security & Observability Minions)
- `design-documentation` (Design & Documentation Minions)
- `web-quality` (Web Quality Minions)
- `governance` (Governance: lucy, margo)
- `boss` (The Boss: gru)

This converts the group config from a recall task to a recognition task. The user sees the same categories they already know from the agent roster. Validation can reject unknown group IDs with an actionable error listing valid groups.

The power-user example becomes:

```yaml
groups:
  development-quality: codex
  infrastructure-data: aider
```

If the user wants to route a subset of agents within a group differently, that is what the `agents:` block is for. This keeps the progressive disclosure clean: groups are coarse-grained by design, agents are fine-grained.

#### 3. Error Reporting Must Follow Three Principles

Since the roadmap explicitly excludes "did you mean?" suggestions and there is no configuration UI, error messages carry the entire burden of the user's debugging experience. This is a high-stakes area. Three principles:

**Principle 1: Name the violation, show the offending value, list valid alternatives.**

Bad: `Error: invalid harness name`
Good: `Error: unknown harness 'codex-cli' in agents.frontend-minion. Valid harnesses: claude-code, codex, aider`

This matches Nielsen Heuristic 9 (error messages should explain the problem and suggest solutions) without crossing into "did you mean?" territory. Listing valid options is a static enumeration, not a fuzzy match.

**Principle 2: Fail at load time with all errors, not just the first one.**

Users editing YAML often make multiple mistakes in one pass. Reporting only the first error creates a frustrating fix-one-reload-fix-another cycle. Collect all validation errors and report them together:

```
routing.yml: 3 errors found

  line 7: unknown harness 'codx' in groups.development-quality
          Valid harnesses: claude-code, codex, aider

  line 12: unknown agent 'frontent-minion' in agents
           Valid agents: frontend-minion, backend-minion, ...

  line 15: capability mismatch: security-minion requires [WebSearch]
           but aider does not support: WebSearch
           Either route security-minion to a harness with web access,
           or remove it from the agents: block (it will inherit from
           default or group).
```

**Principle 3: Distinguish schema errors from semantic errors.**

Schema errors (bad YAML, unknown top-level keys, wrong types) should fail fast with line numbers. Semantic errors (capability mismatches, unknown agent names) should be validated after parsing succeeds. This separation helps users know whether the problem is "I wrote bad YAML" vs. "I wrote valid YAML with wrong values." These are different mental models for debugging.

#### 4. The Zero-Config Path Deserves a Confirmation Signal

Zero-config (no file) is the right default, but it creates an invisible state. A user who *intended* to create a routing config but got the path wrong, or who is checking whether their config is loading, has no feedback signal (violates Nielsen Heuristic 1: visibility of system status).

**Recommendation**: When the orchestrator loads routing and finds no config file, emit a single-line log message at startup:

```
Routing: no .nefario/routing.yml found, all agents → claude-code
```

When a config is loaded:

```
Routing: loaded .nefario/routing.yml (3 agents overridden, 2 groups configured)
```

This is a peripheral signal (Calm Technology principle: communicate through peripheral awareness). It does not require user action, does not add a step, and does not demand attention. But it makes the routing state visible for the user who needs to verify it.

#### 5. User-Level Override Merge Should Be Full Replacement Per Block, Not Deep Merge

The merge semantics question (how user-level config combines with project-level) is an interaction design question masquerading as an engineering question. Deep merge is powerful but violates the principle of least surprise: the user cannot easily predict what the merged config looks like. When something goes wrong, they must hold two files in working memory and mentally simulate a merge -- high cognitive load.

**Recommendation**: Per-top-level-block replacement. If the user-level config has a `groups:` block, it entirely replaces the project-level `groups:` block. If the user-level config has no `groups:` block, the project-level `groups:` block is used. This matches how most YAML config systems work (Kubernetes, Docker Compose) and creates a simple mental model: "my file wins for any section I define."

The user-level config should NOT need to redeclare `default:` if they only want to override `agents:`. Each top-level key is independent. Only the keys present in the user-level file replace their project-level counterparts.

This model also helps with the confirmation signal (Recommendation 4): the startup log can say `Routing: loaded .nefario/routing.yml + user override (agents block overridden)` making merge behavior visible.

#### 6. Config File Location Should Communicate Scope

`.nefario/routing.yml` is the proposed project-level path. The user-level path is unspecified. Two considerations:

**Project-level**: `.nefario/` as a directory is good -- it groups nefario-specific config separate from application code. But the user must learn a new config directory. This is acceptable if `.nefario/` will hold more than one file in the future. If `routing.yml` will be the only file in this directory forever, consider `nefario.routing.yml` at the project root (one fewer directory to discover). However, the roadmap suggests `.nefario/` may accumulate more config over time, so the directory approach is forward-looking.

**User-level**: Follow the platform convention. `~/.config/nefario/routing.yml` on Linux/macOS is the XDG-compatible path. Since the project already uses `~/.claude/` for agents and skills, `~/.claude/nefario/routing.yml` would also be natural and discoverable for users already familiar with the `~/.claude/` hierarchy.

**Recommendation**: Use `~/.claude/nefario/routing.yml` for user-level. It keeps all agent-related config under `~/.claude/` and leverages existing user knowledge of that directory (recognition over recall).

### Proposed Tasks

I am not proposing implementation tasks (that is not my remit). I am identifying UX-critical deliverables that should be requirements within whatever tasks are defined:

1. **Error message spec**: Before implementation, define the error message format (multi-error reporting, schema vs. semantic error separation, valid-alternatives listing). This should be a reviewable artifact, not an implementation detail. Error messages are the primary UI for this feature.

2. **Annotated example configs**: Create 3-4 example configs at increasing complexity levels (zero-config explanation, minimal, group-level, full power-user) with inline YAML comments explaining each section. These examples ARE the documentation for most users -- they will copy-paste and modify rather than reading a schema reference. The examples should be the canonical way users learn the config surface.

3. **Startup routing summary**: Implement the single-line routing status message at orchestration startup (see Recommendation 4). This is a must-be feature (Kano): users will not notice it when it works, but will be confused and frustrated when they cannot tell whether their config loaded.

### Risks and Concerns

**Risk 1: Group name mismatch between config and mental model (HIGH)**

If the config uses user-defined group names instead of canonical IDs, users will make three predictable errors: (a) inventing names that don't match any real grouping, (b) assigning agents to groups they don't belong to, (c) creating overlapping or incomplete groups. All three create silent misconfiguration where the user believes agents are routed one way but they are not. Canonical group IDs eliminate this entire error class.

**Risk 2: Capability gating errors are confusing without tool-to-harness visibility (MEDIUM)**

The capability gating error says "agent X requires tool Y which harness Z doesn't support." But the user may not know what tools each agent requires (this information is buried in AGENT.md frontmatter). The error message must include the agent's tool requirements and the harness's capabilities so the user can make an informed decision without leaving the terminal to inspect AGENT.md files.

**Risk 3: Model-mapping complexity grows with harness count (LOW now, MEDIUM at M5+)**

Each new harness adds a column to the model-mapping matrix. With 3 harnesses and 2 tiers, that is 6 entries. With 6 harnesses, it is 12. The model-mapping block will become the most complex part of the config. Consider whether per-harness default models (a single default model per harness, not per tier) would satisfy most users, with the full tier mapping reserved for power users. This is a future concern, not an M1 blocker, but the schema should not make it hard to simplify later.

**Risk 4: User-level override creates invisible config state (MEDIUM)**

When a project config and user config are both active, debugging routing behavior requires knowing both files exist and what each contributes. The startup routing summary (Recommendation 4) partially mitigates this. Additionally, consider a `--show-routing` or equivalent diagnostic command that dumps the fully resolved routing table (which agent goes to which harness and why). This is a progressive disclosure pattern: invisible by default, available on request. This is NOT a "configuration UI" (excluded by YAGNI) -- it is a diagnostic tool.

### Additional Agents Needed

None beyond those already identified in the meta-plan. The consultations with devx-minion (error message implementation), api-design-minion (capability vocabulary), ai-modeling-minion (group taxonomy resolution), and security-minion (config trust boundary) cover the essential planning needs.

I do want to reinforce that **software-docs-minion** should treat the annotated example configs as a first-class documentation deliverable. For a YAML-edited config with no UI, the examples ARE the user interface. They deserve the same care as API reference documentation.
