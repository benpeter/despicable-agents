# Meta-Plan: External Harness Integration -- Report Iteration + Codex-First Roadmap

## Scope

**In scope**:
- Iterate docs/external-harness-integration.md with 5 user feedback items (configuration gap, model specification, worktree isolation, quality parity, Aider result collection)
- Create a Codex-first implementation roadmap as sequenced GitHub issues under docs/

**Out of scope**:
- Changing nefario's orchestration code or SKILL.md
- Building adapters or any implementation work
- Modifying the-plan.md or agent definitions

## Planning Consultations

### Consultation 1: Multi-Harness Architecture & Model Mapping

- **Agent**: ai-modeling-minion
- **Planning question**: The report needs to address two tightly coupled concerns: (1) How should routing configuration work so users specify which tasks go to Codex vs Claude Code vs others? What configuration DX patterns exist for model/tool routing in multi-agent systems? (2) How should the existing `model:` frontmatter pattern (opus/sonnet) translate to external harness model selection? Should there be a quality-tier abstraction (e.g., "high/standard") that maps to provider-specific models, or should users specify exact model names per harness? Consider the roadmap milestone structure for Codex integration -- what is the right decomposition of the adapter, config schema, instruction translation, and result collection into sequenced implementation steps?
- **Context to provide**: docs/external-harness-integration.md (full document), nefario AGENT.md model selection section, current `model:` frontmatter usage in agent specs
- **Why this agent**: Core expertise in prompt engineering, multi-agent architectures, and model selection. The configuration gap, model specification, and quality parity feedback items are fundamentally about how an orchestrator reasons about model capabilities and routing.

### Consultation 2: Technology Radar & Tool Ecosystem Assessment

- **Agent**: gru
- **Planning question**: For the Codex-first roadmap: what is the current state of Codex CLI's automation interface stability? Are there API/CLI breaking changes expected? For the report iteration: the user wants worktree isolation stated definitively -- what is the state of the art for concurrent agent filesystem isolation in coding tools? Are there patterns from other multi-agent systems that address this without worktrees (e.g., container isolation, overlay filesystems, lock files)? Also: should the roadmap account for Codex's TypeScript SDK as an alternative invocation path to CLI subprocess?
- **Context to provide**: docs/external-harness-integration.md sections on Codex CLI, worktree isolation, open questions
- **Why this agent**: Technology landscape assessment, tool maturity evaluation, and strategic sequencing decisions. Gru can assess whether Codex CLI is stable enough to build on and identify risks the roadmap should account for.

### Consultation 3: Developer Experience for Routing Configuration

- **Agent**: devx-minion
- **Planning question**: The biggest gap in the report is configuration DX -- how does a user specify "route security-minion tasks to Claude Code but code-review-minion tasks to Codex"? What configuration format is most ergonomic? Consider: (1) Where should this config live? (CLAUDE.md? A dedicated file like `.nefario/routing.yml`? Per-project vs global?) (2) What granularity? (per-agent, per-task-type, per-domain-group, regex on task titles?) (3) How should defaults work? (Claude Code for everything unless overridden?) (4) How does model specification fit into routing config vs agent frontmatter? Design the configuration surface for the report, and identify which roadmap issues need to address config format vs config implementation vs config documentation.
- **Context to provide**: docs/external-harness-integration.md, CLAUDE.md structure, current agent frontmatter format
- **Why this agent**: CLI/SDK design, configuration file design, developer onboarding. The routing configuration is fundamentally a DX problem -- the technical mechanism is secondary to whether developers can understand and maintain the config.

### Consultation 4: Adapter Protocol & Instruction Translation

- **Agent**: mcp-minion
- **Planning question**: The roadmap needs to define the adapter interface -- the contract between nefario's delegation layer and each external tool. Two questions for planning: (1) What should the adapter interface look like? (input: prompt + config, output: structured result + file changes + exit status -- but what exact shape?) (2) For instruction translation, the report shows AGENT.md maps cleanly to Markdown formats but frontmatter fields do not. Should the adapter strip frontmatter entirely and pass it as runtime config, or should there be a translation step that maps frontmatter to tool-native equivalents? Also consider: the report lists result collection for Aider (git diff only) as an open question -- the user wants "LLM-based diff summarization" stated as the answer. How should this be positioned in the roadmap (which issue, what dependencies)?
- **Context to provide**: docs/external-harness-integration.md sections on instruction format translation, result collection, gap analysis
- **Why this agent**: Protocol design expertise (tool/resource interfaces, transport layers). The adapter is essentially a protocol bridge between nefario's delegation contract and each tool's CLI interface.

### Consultation 5: Documentation Structure & Roadmap Format

- **Agent**: software-docs-minion
- **Planning question**: Two documentation deliverables need structure advice: (1) The report iteration -- five specific changes need to be integrated without bloating the document. Should any sections be restructured, or are the changes purely additive? The "Open Questions" section will shrink (items 2, 3, 5 get resolved) -- should it be renamed or restructured? (2) The roadmap document -- what is the right format for "sequenced GitHub issues ready for creation"? Should it be a flat list with dependency annotations, a milestone/epic structure, or something else? Where should it live under docs/? (e.g., docs/roadmaps/codex-integration.md, docs/external-harness-roadmap.md, or a subdirectory?) Consider that the roadmap should be extensible for future tools (Aider, Gemini CLI) without requiring restructuring.
- **Context to provide**: docs/ directory structure, docs/external-harness-integration.md, docs/architecture.md hub structure
- **Why this agent**: Architecture documentation, document structure, information hierarchy. Ensures both deliverables are well-structured and findable.

### Consultation 6: Intent Alignment Review

- **Agent**: lucy
- **Planning question**: The user gave 5 specific feedback items with clear directives (e.g., "state as answer, not open question", "address definitively"). Review these directives against the current report to identify: (1) Are there any contradictions between the feedback items? (e.g., does resolving the model specification feedback conflict with the configuration gap feedback?) (2) Does the "Codex-first roadmap" scope align with the report's own recommendations, or does the roadmap assume decisions the report hasn't made? (3) The user says quality parity is "user's responsibility" but also wants framework-level model specification -- is there tension here that needs resolution in the plan? (4) The user scoped out "changing nefario" but the roadmap covers "nefario Phase 4 integration" -- where is the line?
- **Context to provide**: User's 5 feedback items (verbatim from task), docs/external-harness-integration.md, task scope definition
- **Why this agent**: Intent alignment, goal drift detection, contradiction identification. Lucy catches scope ambiguity before it propagates into execution.

## Cross-Cutting Checklist

- **Testing**: Exclude from planning. Both deliverables are documentation artifacts (research report + roadmap). No executable output. The roadmap will *describe* testing issues but does not itself need test coverage.
- **Security**: Exclude from planning. The report explicitly lists security threat model as out of scope. The roadmap may include a security-related issue (adapter trust model) but this is a roadmap item, not a planning concern.
- **Usability -- Strategy**: ALWAYS include. Covered by devx-minion (Consultation 3) which focuses on configuration DX -- the primary usability surface for multi-harness delegation. The routing configuration is a user journey design problem.
- **Usability -- Design**: Exclude. No user-facing interfaces produced. Both deliverables are Markdown documents.
- **Documentation**: ALWAYS include. Covered by software-docs-minion (Consultation 5) for both document structure and roadmap format.
- **Observability**: Exclude. No runtime components. The roadmap may describe observability needs (adapter logging) but this is content within the roadmap, not an observability concern for the deliverables themselves.

## Anticipated Approval Gates

1. **Report iteration content** (likely MUST gate): The revised report resolves open questions and adds new sections. Since downstream roadmap issues reference the report's conclusions, the report should be approved before the roadmap is finalized. Hard to reverse (report is a reference document), high blast radius (roadmap depends on it).

2. **Roadmap structure and issue sequencing** (likely MUST gate): The roadmap defines implementation order and issue scope. Multiple valid decompositions exist (judgment call). Hard to reverse once issues are created from it.

Gate budget: 2 gates, well within the 3-5 target.

## Rationale

The six agents are chosen to cover distinct aspects of the two deliverables:

- **ai-modeling-minion** handles the hardest conceptual questions: model mapping, routing logic, and quality-tier abstraction. These are the core architectural decisions.
- **gru** provides technology landscape grounding: Codex stability, worktree isolation state of the art, and strategic sequencing risks.
- **devx-minion** designs the configuration surface -- the most user-visible part of the system and the biggest gap identified in user feedback.
- **mcp-minion** defines the adapter protocol contract -- the technical backbone of the roadmap's implementation issues.
- **software-docs-minion** ensures both deliverables are well-structured and the roadmap format supports future extensibility.
- **lucy** validates that the feedback items and scope boundaries are internally consistent before execution.

Agents NOT included and why:
- **margo**: Not needed for planning. Both deliverables are documentation. Margo reviews execution plans for over-engineering, which is not applicable to research iteration and roadmap authoring.
- **test-minion, security-minion, observability-minion**: The deliverables are documents, not code or infrastructure. These agents would contribute to roadmap *content* (e.g., "include a testing issue"), which the executing agent can handle without specialist planning input.
- **ux-design-minion, accessibility-minion, sitespeed-minion**: No user interfaces involved.

## External Skill Integration

No external skills detected relevant to this task. Project-local skills (despicable-lab, despicable-statusline, despicable-prompter, nefario) are for agent building, status display, briefing coaching, and orchestration respectively -- none address research report authoring or roadmap creation.
