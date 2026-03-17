# Phase 3: Synthesis -- Execution Plan

## Delegation Plan

**Team name**: harness-iteration-roadmap
**Description**: Iterate the external harness integration report with user feedback (configuration gap, worktree isolation, quality parity, Aider result collection) and create a Codex-first implementation roadmap document with GitHub-issue-ready format.

### Task 1: Iterate docs/external-harness-integration.md

- **Agent**: software-docs-minion
- **Delegation type**: standard
- **Model**: sonnet
- **Mode**: default
- **Blocked by**: none
- **Approval gate**: yes
- **Gate reason**: Report changes establish the technical positions (routing config design, worktree isolation stance, quality parity policy, result collection strategy) that the roadmap document must reference and build upon. Approving the wrong position in the report would cascade into a misaligned roadmap.
- **Prompt**: |
    You are iterating docs/external-harness-integration.md based on user feedback and specialist analysis. Read the current document at `/Users/ben/github/benpeter/despicable-agents/.claude/worktrees/use-outside-harnesses/docs/external-harness-integration.md` before making any changes.

    ## Changes Required

    Make these five changes to the report. Preserve the existing section structure, `---` delimiter pattern, and document voice. Do not touch the Executive Summary table or Technology Radar table -- they remain accurate.

    ### Change 1: Add "Routing and Configuration" Section

    Add a new section between "Recommendations" and "Out of Scope" (after the ACP Protocol subsection, before the `---` that precedes Out of Scope). Title: "Routing and Configuration".

    This section describes how users would specify harness routing and model selection. Content to include:

    **Configuration surface**: A single YAML file at a project-level location (e.g., `.nefario/routing.yml`), with an optional user-level override. Zero-config baseline: if no file exists, everything routes to Claude Code (current behavior unchanged).

    **Three granularity levels**: default harness (global), per-agent-group routing, and per-agent routing. Resolution order: agent-specific > group-specific > explicit default > implicit default (claude-code). Users configure only the layers they need. A minimal config to try one agent on Codex is ~5 lines.

    **Model specification**: The AGENT.md `model:` field (opus/sonnet) expresses quality-tier intent, not a specific model ID. A `model-mapping` section in the routing config translates quality tiers to provider-specific model identifiers per harness (e.g., opus -> o3 for Codex, opus -> claude-opus-4-6 for Aider). Two tiers (high/standard) map to the existing opus/sonnet values. Users explicitly choose which model each harness uses; the orchestrator does not auto-detect quality differences.

    **Capability gating**: The routing layer validates at config load time that a routed agent's tool requirements (from AGENT.md `tools:` field) are satisfiable by the target harness. For example, routing security-minion (which requires Bash and WebSearch) to Aider (which has neither) produces a hard error with actionable guidance.

    Keep this section to 40-60 lines. Describe the design space and recommended approach, not a full schema definition. Schema details belong in the roadmap.

    Include a brief YAML example showing a minimal config (2-3 lines) and a power-user config (~15 lines) demonstrating default, group, and agent-level routing with model mapping.

    ### Change 2: Resolve Open Question 2 (Worktree Isolation)

    Remove Open Question 2 from the Open Questions section. Replace it with a definitive statement in the Gap Analysis table's "Parallel delegation race conditions" context, or add a brief subsection to the new Routing and Configuration section.

    The definitive position: **Git worktrees are the correct default isolation mechanism for concurrent agent filesystem access.** This is the established production pattern adopted by every major multi-agent coding tool (Codex Desktop, Claude Code, Conductor). Per-task worktree creation is practical at scale -- creation overhead is ~1-3 seconds per worktree, acceptable for tasks that run for minutes. The orchestrator already creates worktrees for its own parallel execution; extending this to external harness tasks requires no new mechanism.

    Note that worktrees isolate code but not runtime environment. Tasks that run tests against shared databases or start servers on fixed ports need additional isolation beyond worktrees alone. Also note that concurrent Claude Code agents already face the same isolation challenge -- this is a pre-existing concern, not one introduced by external harnesses.

    ### Change 3: Resolve Open Question 3 (Quality Parity)

    Remove Open Question 3 from the Open Questions section. Add a brief statement in the Recommendations section (after the sequencing subsection):

    **Quality parity**: Quality assessment across harnesses is the user's responsibility, not the orchestrator's. The orchestrator does not track per-tool quality outcomes or auto-compensate for model differences. The routing configuration provides model specification per harness (see Routing and Configuration), giving users explicit control over which models run which tasks.

    ### Change 4: Resolve Open Question 5 (Aider Result Collection)

    Remove Open Question 5 from the Open Questions section. Update the Aider subsection in Feasibility Assessment and the "Result collection" row in Gap Analysis.

    The definitive position: Tools without structured JSON output (Aider) use a two-layer result collection strategy. File changes are always derived mechanically from `git diff` (accurate, zero cost). Semantic summaries use LLM-based diff summarization -- a small, fast model processes the unified diff against the original task prompt to produce a structured summary. The cost (~500 input tokens + ~200 output tokens per delegation) and latency (~1-3 seconds) are negligible relative to multi-minute task execution. This is an accepted tradeoff, not an open question.

    Update the Gap Analysis "Result collection" row's Gap Severity from "Medium" to "Low-Medium" and add the resolution approach.

    ### Change 5: Add Frontmatter Note to Instruction Format Section

    In the "Key findings" bullets under "Instruction Format Translation", add a note:

    Frontmatter fields are stripped during instruction translation and passed as adapter runtime configuration. The Markdown body (five-section system prompt) is the only content written to tool-native instruction files. Model selection is handled through the routing configuration, not instruction file translation.

    ## After All Changes

    The Open Questions section should have exactly two remaining items:
    1. Instruction isolation (current item 1, unchanged)
    2. AGENTS.md spec stability (current item 4, unchanged)

    Renumber them as 1 and 2. Do not rename the section.

    Add a forward reference at the end of the Recommendations section: "For implementation sequencing, see [External Harness Roadmap](external-harness-roadmap.md)."

    ## What NOT To Do

    - Do not restructure the document beyond the five changes above
    - Do not modify the Executive Summary table, Technology Radar table, or Tool Inventory tables
    - Do not add content about protocols (A2A, MCP, ACP) -- those sections are settled
    - Do not add implementation details or code -- this is a feasibility study, not an implementation spec
    - Do not add estimated effort, timelines, or story points
    - Do not mention any specific company names beyond tool names (no "Adobe", no vendor-specific references)
    - Keep the document under 340 lines total (currently ~273)
    - Preserve the `*Last assessed: 2026-03-17*` date

    ## ADVISORY (from architecture review)

    - Ensure the YAML examples in the routing configuration section use generic model names that will remain valid. Use current real model identifiers (o3, o4-mini, claude-opus-4-6, gemini-2.5-pro) rather than speculative future names.
    - The config file location (.nefario/routing.yml) is a recommendation, not a commitment. Frame it as the proposed location, noting it follows the .github/, .vscode/ dotfile convention.

- **Deliverables**: Updated `docs/external-harness-integration.md` with five changes integrated
- **Success criteria**:
  - New "Routing and Configuration" section exists between Recommendations and Out of Scope (40-60 lines)
  - Open Questions section has exactly 2 items (instruction isolation + AGENTS.md stability)
  - Gap Analysis "Result collection" row updated with resolution
  - Feasibility Assessment Aider subsection updated with LLM summarization as definitive approach
  - Forward reference to roadmap document added in Recommendations
  - Document total under 340 lines

### Task 2: Create docs/external-harness-roadmap.md

- **Agent**: software-docs-minion
- **Delegation type**: standard
- **Model**: sonnet
- **Mode**: default
- **Blocked by**: Task 1
- **Approval gate**: no
- **Prompt**: |
    You are creating a new roadmap document at `/Users/ben/github/benpeter/despicable-agents/.claude/worktrees/use-outside-harnesses/docs/external-harness-roadmap.md`.

    Read the approved report at `/Users/ben/github/benpeter/despicable-agents/.claude/worktrees/use-outside-harnesses/docs/external-harness-integration.md` first (it will have been updated by a prior task) to ensure roadmap content aligns with the report's positions.

    ## Document Structure

    Use a two-level hierarchy: Milestones containing Issues. This maps directly to GitHub's milestone+issue model.

    ```
    # External Harness Integration Roadmap

    [< Back to Architecture Overview](architecture.md) | [Feasibility Study](external-harness-integration.md)

    *Last assessed: 2026-03-17*

    ## How to Use This Document
    ## Scope and Boundaries
    ## Milestone 1: ...
    ### Issue 1.1: ...
    ### Issue 1.2: ...
    ## Milestone 2: ...
    ### Issue 2.1: ...
    ...
    ## Milestone N: ...
    ## Future Milestones
    ```

    ## Content Sections

    ### How to Use This Document

    Brief description (3-5 lines): This document defines the implementation roadmap for external harness integration. Each milestone is a GitHub milestone; each issue is a GitHub issue. To create issues from this document, use each "Issue N.M" heading as the issue title and the content as the issue body. Dependencies become issue references once created. Once issues are created, track progress in the GitHub milestone -- this document becomes the historical record of initial planning.

    ### Scope and Boundaries

    State explicitly:
    - **In scope**: Adapter layer between nefario's execution phase and external CLI tools. Configuration surface for routing and model specification. Codex CLI as first adapter. Cross-tool abstractions validated by a second adapter (Aider).
    - **Out of scope**: Changes to nefario's planning phases (1-3.5). Changes to agent specs or AGENT.md format. Quality tracking or auto-routing intelligence. Protocol integrations (A2A, MCP delegation, ACP).
    - **Nefario change boundary**: Changes are limited to Phase 4 execution routing (the step where nefario spawns execution agents via the Task tool). Planning phases 1-3.5 are unchanged.
    - **YAGNI principle**: Build only the Codex adapter concretely. Extract the cross-tool interface after the second adapter (Aider) validates the abstraction. Do not pre-build adapters for tools not yet committed to.

    ### Milestones and Issues

    Create the following milestones and issues based on specialist input. Use this issue template:

    ```markdown
    ### Issue N.M: [Short Title]

    **Goal**: One sentence.

    **Scope**:
    - Bullet list of deliverables

    **Depends on**: Issue N.X (or "None")

    **Acceptance criteria**:
    - Verifiable outcomes

    **Notes**: Optional context
    ```

    Do NOT include estimated effort, story points, or assignees.

    #### Milestone 1: Adapter Foundation

    Cross-tool abstractions that all future adapters build on. These are validated by the Codex adapter (Milestone 2) and proven generic by the Aider adapter (Milestone 3).

    Issues:

    **Issue 1.1: Adapter Interface Definition**
    Goal: Define the contract between the orchestrator and any external harness adapter.
    Scope:
    - Define DelegationRequest type: prompt (string), workingDirectory (path to worktree), model (provider-specific ID), qualityTier (high/standard), autoApprove (boolean), timeout (ms), contextFiles (optional paths), environment (optional env vars)
    - Define DelegationResult type: exitCode, status (completed/failed/timeout), changedFiles (from git diff: path, action, lines added/removed), summary (string, source varies by adapter), stdout/stderr (truncated, for debugging), optional usage (tokens, duration)
    - Define instruction file lifecycle: write to worktree before invocation, clean up after completion/failure
    - Define pre-invocation git ref capture (for diffing against tools that auto-commit)
    Depends on: None
    Acceptance criteria:
    - Types are documented in a design doc or code
    - Interface handles both structured-output tools (Codex) and git-diff-only tools (Aider) without branching in the orchestrator
    Notes: The interface is request-response, not streaming. Progress monitoring is adapter-internal. Multi-turn is not supported (single-shot invocation, matching current subagent model).

    **Issue 1.2: Routing Configuration Schema**
    Goal: Define the YAML configuration format for harness routing and model specification.
    Scope:
    - YAML schema for routing config file (location: project-level dotfile directory, user-level XDG-convention path)
    - Three granularity levels: default, per-group, per-agent. Resolution order: agent > group > default > implicit (claude-code)
    - Model-mapping section: quality tiers (high/standard from opus/sonnet) to provider-specific model IDs per harness
    - Harness configuration section: per-harness flags, model defaults
    - Environment variable overrides for CI/CD
    - JSON Schema definition for validation and editor support
    - Zero-config behavior: no file = everything routes to Claude Code
    Depends on: Issue 1.1 (needs to know what config the adapter consumes)
    Acceptance criteria:
    - JSON Schema validates example configs
    - Minimal config (route one agent to Codex) is 5 lines or fewer
    - Invalid agent/group names produce errors with "did you mean?" suggestions
    - Missing harness binary produces error with install guidance
    Notes: Config is validated at session startup, not at delegation time. Fail fast.

    **Issue 1.3: AGENT.md Instruction Translator**
    Goal: Extract the Markdown body from AGENT.md and write tool-native instruction files.
    Scope:
    - Strip all YAML frontmatter from AGENT.md
    - Write Markdown body to tool-native format (AGENTS.md for Codex, CONVENTIONS.md for Aider, GEMINI.md for Gemini CLI)
    - Strip Claude Code-specific instructions from task prompts (references to TaskUpdate, SendMessage, scratch directory conventions)
    - Handle instruction isolation: check for conflicting instruction files in worktree, document conflicts and let user resolve (Milestone 1 approach)
    Depends on: None
    Acceptance criteria:
    - Translated instruction files contain only the five-section Markdown body (Identity, Core Knowledge, Working Patterns, Output Standards, Boundaries)
    - No frontmatter fields leak into instruction files
    - Claude Code-specific tool references are stripped from task prompts
    Notes: The translator writes files to the worktree root. Cleanup is part of the adapter lifecycle (Issue 1.1).

    #### Milestone 2: Codex CLI Adapter

    First concrete adapter. Validates the foundation from Milestone 1 against a real tool.

    Issues:

    **Issue 2.1: Codex CLI Invocation Wrapper**
    Goal: Spawn `codex exec` as a subprocess with correct flags, model, and working directory.
    Scope:
    - Map DelegationRequest fields to Codex CLI flags: --model (from routing config), --full-auto, --json (JSONL to stderr), -o (result file), --output-schema (optional structured output), cwd (worktree path)
    - Configurable timeout (default: 30 minutes)
    - Pin to specific Codex CLI version range
    - Capture pre-invocation git ref for post-invocation diffing
    Depends on: Issue 1.1, Issue 1.2, Issue 1.3
    Acceptance criteria:
    - Codex exec spawns successfully with correct flags in a worktree
    - Model is resolved from routing config (not hardcoded)
    - Timeout kills the process and returns status: "timeout"
    Notes: Use CLI subprocess, not the TypeScript SDK. The SDK is a wrapper around the CLI that adds a Node.js dependency without adding capabilities.

    **Issue 2.2: Codex Result Collector**
    Goal: Parse Codex output into a normalized DelegationResult.
    Scope:
    - Parse JSONL event stream for: file changes, errors, token usage
    - Parse structured output (from --output-schema) if provided
    - Map exit codes: 0 = completed, non-zero = failed (classify stderr for retryable vs. fatal)
    - Derive changedFiles from git diff against pre-invocation ref
    - Extract summary from structured output or final message
    Depends on: Issue 2.1
    Acceptance criteria:
    - DelegationResult is populated for success, failure, and timeout cases
    - changedFiles matches actual file changes (verified against git diff)
    - Token usage is captured when available

    **Issue 2.3: Codex Adapter Validation**
    Goal: Validate the complete Codex adapter with representative tasks.
    Scope:
    - Run 5 representative task types through both Claude Code and Codex CLI: code generation (new file), code modification (edit existing), test writing, documentation writing, multi-file refactoring
    - Compare: files changed match expectations, no regressions, result format is consumable by orchestrator
    - Document quality delta per task type (observation only, no auto-routing)
    Depends on: Issue 2.1, Issue 2.2
    Acceptance criteria:
    - All 5 task types complete via Codex adapter
    - DelegationResult is well-formed for each
    - Quality observations documented (not automated)

    #### Milestone 3: Aider Adapter + Result Summarization

    Second adapter validates that the Milestone 1 abstractions are truly tool-agnostic. If this milestone requires significant rework of Milestone 1 interfaces, the abstraction failed.

    Issues:

    **Issue 3.1: Result Summarization Service**
    Goal: Generate semantic summaries from git diffs for tools without structured output.
    Scope:
    - Input: git diff (unified format) + original task prompt
    - Output: summary string + changedFiles array (for DelegationResult)
    - Call a small, fast LLM model with the diff and prompt for structured summary
    - Define prompt template for diff summarization
    - Benchmark cost and latency with real diffs
    Depends on: Issue 1.1 (needs DelegationResult shape)
    Acceptance criteria:
    - Produces coherent summaries for diffs of varying size (10 lines to 500 lines)
    - Cost per summarization < $0.01
    - Latency < 5 seconds
    Notes: Reusable for any future tool without structured output. Testable independently with synthetic diffs before the Aider adapter exists.

    **Issue 3.2: Aider Invocation Wrapper**
    Goal: Spawn Aider as a subprocess with correct flags, model, and working directory.
    Scope:
    - Map DelegationRequest fields to Aider flags: --message (prompt), --model (from routing config), --yes (auto-approve), --auto-commits, --read (context files), cwd (worktree path)
    - Generate CONVENTIONS.md from AGENT.md body (using Issue 1.3 translator)
    - Handle Aider's lack of Bash/WebSearch: if task prompt references these tools, fail with guidance before invocation (capability gating)
    Depends on: Issue 1.1, Issue 1.2, Issue 1.3
    Acceptance criteria:
    - Aider spawns successfully with correct flags in a worktree
    - Model is resolved from routing config
    - Tasks requiring Bash or WebSearch are rejected with clear error

    **Issue 3.3: Aider Result Collector**
    Goal: Collect results from Aider using git diff and LLM summarization.
    Scope:
    - Derive changedFiles from git diff against pre-invocation ref (handles Aider's --auto-commits)
    - Use Result Summarization Service (Issue 3.1) for summary
    - Parse Aider commit message as supplementary summary source
    - Map exit codes
    Depends on: Issue 3.1, Issue 3.2
    Acceptance criteria:
    - DelegationResult populated for success and failure cases
    - changedFiles accurate despite Aider's auto-commits
    - Summary is coherent (from LLM summarization)

    **Issue 3.4: Aider Adapter Validation + Abstraction Check**
    Goal: Validate Aider adapter and verify the cross-tool abstraction holds.
    Scope:
    - Run the same 5 representative tasks from Issue 2.3 through Aider
    - Compare DelegationResult shape and content with Codex results
    - Document quality delta per task type
    - If Milestone 1 interfaces needed changes, document what changed and why (abstraction health check)
    Depends on: Issue 3.2, Issue 3.3, Issue 2.3
    Acceptance criteria:
    - All task types that Aider supports (code gen, code mod, refactoring) complete successfully
    - Tasks Aider cannot support (those requiring Bash/WebSearch) are correctly rejected
    - DelegationResult format is identical between Codex and Aider adapters
    Notes: If this issue reveals that Milestone 1 abstractions need significant changes, those changes should be scoped as separate issues, not folded into this validation.

    #### Milestone 4: Orchestrator Integration

    Wire the adapter layer into nefario's Phase 4 execution loop.

    Issues:

    **Issue 4.1: Phase 4 Routing Dispatch**
    Goal: Route execution tasks through the adapter layer based on routing configuration.
    Scope:
    - At Phase 4 step 3 (task spawning), consult routing config for each agent
    - If route = claude-code, use existing Task tool path (unchanged)
    - If route = external harness, invoke through adapter
    - Result normalization: all adapters produce DelegationResult, orchestrator processes identically
    Depends on: Milestone 2 (minimum), Milestone 3 (for full coverage)
    Acceptance criteria:
    - Full nefario orchestration with at least one task routed to Codex
    - Remaining tasks on Claude Code work unchanged
    - Orchestrator code changes limited to Phase 4 execution routing

    **Issue 4.2: Progress Monitoring Integration**
    Goal: Surface adapter progress in the orchestrator's status mechanism.
    Scope:
    - Codex: pipe JSONL progress events to orchestrator status (task started, files changed, completion)
    - Aider: report only start/complete (opaque execution)
    - Other future tools: define progress event contract for adapters
    Depends on: Issue 4.1
    Acceptance criteria:
    - User can see which external tasks are running and their high-level status
    - No polling required for external harness tasks (event-driven or completion-based)

    ### Future Milestones

    These milestones are sketched at headline level only. Full issue decomposition happens when the team commits to building them.

    **Milestone 5: Gemini CLI Adapter** -- Third adapter for Google models. Clean JSON output makes result collection straightforward. Main challenge: Google auth in headless environments. Validates that the adapter abstraction works across three fundamentally different tools (Codex = OpenAI models + JSONL, Aider = any model + git diffs, Gemini CLI = Google models + JSON).

    **Milestone 6: Capability-Based Routing** -- Extend the routing config with task-characteristic matching. Route tasks based on tool requirements (e.g., tasks requiring Bash automatically stay on Claude Code or Codex, never Aider). Requires a machine-readable capability registry per harness.

    **Milestone 7: Quality Outcome Logging** -- Optional per-harness outcome tracking. Record harness, model, task type, success/failure, and whether human override was needed. Write to a local JSONL file. Enables data-driven routing decisions over time. Note: this is an observability tool for the user, not auto-routing intelligence.

    **Milestone 8: Hardening** -- Reasoning effort translation per harness, retry policies, circuit breaker for harness failures, per-harness cost tracking.

    ## Dependencies

    | Dependency | Required By | Notes |
    |-----------|-------------|-------|
    | Codex CLI installed and authenticated | Milestone 2 | `CODEX_API_KEY` or saved auth |
    | Aider installed and configured | Milestone 3 | API key for chosen provider |
    | Git worktree support in orchestrator | Milestone 1 | Already implemented |
    | Nefario Phase 4 delegation hook | Milestone 4 | Narrow change: routing dispatch in execution loop |

    ## Risks

    | Risk | Severity | Mitigation |
    |------|----------|------------|
    | Codex CLI breaking changes (pre-1.0, multiple releases/day) | Medium | Pin to specific version. Wrap CLI invocation behind adapter abstraction. Test against alpha channel in CI. |
    | Model quality parity gap (o3/o4-mini vs. Opus for complex reasoning) | High | Start with task types where model quality is less critical (formatting, boilerplate, simple edits). Quality assessment is user's responsibility. |
    | Instruction isolation conflicts | Medium | Milestone 1: document and let user resolve. Future: explore tool-specific config suppression flags. |
    | Abstraction fails at second adapter | Medium | Milestone 3 explicitly validates the abstraction. If significant rework needed, it proves the abstraction was premature. |
    | AGENTS.md spec instability | Low | Spec is simple (Markdown + optional frontmatter). Under Linux Foundation governance. Breaking changes unlikely to be severe. |
    | Worktree instruction file pollution | Medium | Adapter lifecycle includes cleanup. Write with marker for emergency cleanup. Capture pre-invocation git ref. |

    ## What NOT to Build

    Applying YAGNI:
    - **No TypeScript orchestrator** -- nefario runs inside Claude Code. No Node.js layer.
    - **No container isolation** for Milestones 1-4 -- worktrees suffice for code-editing tasks.
    - **No auto-routing intelligence** -- users declare routing, the system follows.
    - **No A/B testing of harnesses** -- users compare manually if desired.
    - **No A2A or ACP protocol integration** -- zero adoption in coding tools. Monitor only.
    - **No GUI for routing config** -- YAML is sufficient for power users who configure routing.
    - **No quality tracking or benchmarking** -- user's responsibility per explicit feedback.

- **Deliverables**: New file `docs/external-harness-roadmap.md`
- **Success criteria**:
  - Document follows milestone/issue hierarchy with 4 concrete milestones + 4 future milestones
  - Each issue has: title, goal, scope, depends on, acceptance criteria
  - Issues are directly usable as GitHub issue bodies
  - No estimated effort, story points, or assignees
  - Future milestones are headline-level only (2-3 sentences each)
  - Nefario change boundary explicitly stated in Scope and Boundaries
  - YAGNI: only Codex adapter is fully decomposed; Aider validates the abstraction
  - Document is vendor-neutral and publishable under Apache 2.0

### Task 3: Update cross-links in docs/architecture.md

- **Agent**: software-docs-minion
- **Delegation type**: standard
- **Model**: sonnet
- **Mode**: default
- **Blocked by**: Task 2
- **Approval gate**: no
- **Prompt**: |
    Add the new roadmap document to the architecture.md sub-documents table.

    Read `/Users/ben/github/benpeter/despicable-agents/.claude/worktrees/use-outside-harnesses/docs/architecture.md`.

    In the "Contributor / Architecture" table, add a new row immediately after the "External Harness Integration" row:

    ```
    | [External Harness Roadmap](external-harness-roadmap.md) | Implementation roadmap: Codex CLI adapter, cross-tool abstractions, future tool milestones |
    ```

    Make only this one change. Do not modify any other content.

- **Deliverables**: Updated `docs/architecture.md` with roadmap link
- **Success criteria**:
  - New row appears in the Contributor / Architecture sub-documents table
  - Link path is correct (`external-harness-roadmap.md`)
  - No other changes to architecture.md

---

### Cross-Cutting Coverage

- **Testing**: Not applicable. Both deliverables are research/planning documents with no executable output. No tests to write or run.
- **Security**: Not applicable. No code, no APIs, no user input handling, no secrets. The documents discuss security concerns (instruction isolation, credential exposure) at the design level -- these are already covered in the report content.
- **Usability -- Strategy**: Not applicable for planning phase. The routing configuration DX is a core topic of the report iteration (Change 1) -- ux-strategy's concerns are embedded in the content via devx-minion's specialist contribution. No separate UX review of documentation format needed.
- **Usability -- Design**: Not applicable. No user-facing interfaces produced.
- **Documentation**: Covered by Tasks 1-3 directly. Both deliverables ARE documentation.
- **Observability**: Not applicable. No runtime components.

### Architecture Review Agents

- **Mandatory** (5): security-minion, test-minion, ux-strategy-minion, lucy, margo
- **Discretionary picks**:
  - None selected. All tasks produce documentation only (no UI, no web-facing code, no runtime components, no coordinated logging). No discretionary reviewer's domain signal is triggered by the plan content.
- **Not selected**: ux-design-minion, accessibility-minion, sitespeed-minion, observability-minion, user-docs-minion

### Conflict Resolutions

**Config file location**: ai-modeling-minion proposed `.despicable/harness-routing.yaml`, devx-minion proposed `.nefario/routing.yml`. Lucy suggested `.claude/harness-config.yml`. Resolution: The report should propose a location (following the dotfile convention pattern) but frame it as a recommendation, not a commitment. The exact location is an implementation decision for the roadmap's Issue 1.2. The report uses `.nefario/routing.yml` as the example (devx-minion's recommendation) since it follows the `.github/`, `.vscode/` naming convention and is tool-namespaced. The specific location is not load-bearing for the report's purpose.

**Roadmap milestone count**: ai-modeling-minion proposed 4 milestones (M0-M3). gru proposed 4 phases. mcp-minion proposed 6 sequenced issues. devx-minion proposed 11 issues across 4 categories. Resolution: Consolidated into 4 concrete milestones (Adapter Foundation, Codex Adapter, Aider Adapter + Summarization, Orchestrator Integration) with 4 future milestones (Gemini, Capability Routing, Quality Logging, Hardening). ai-modeling-minion's M0 (config schema) is folded into Milestone 1 as it is foundation work. mcp-minion's 6-issue sequence maps cleanly into the milestone structure. devx-minion's 11 issues are consolidated where overlap exists (config format + validation + resolver = Issue 1.2).

**Adapter interface: define first vs. extract after**: Lucy's YAGNI warning says "Build the Codex adapter. Extract the interface after Aider validates it." mcp-minion recommends defining DelegationRequest/DelegationResult types upfront. Resolution: Define a minimal interface in Issue 1.1 (types, not code). The Codex adapter implements against it. If the Aider adapter (Milestone 3) reveals the interface was wrong, Issue 3.4 explicitly tracks what changed. This balances YAGNI with the practical need for a target shape when building the first adapter. The interface is a design document, not a framework.

**Aider result collection approach**: ai-modeling-minion recommended commit message as primary summary (free, immediate), with LLM summarization as optional enhancement. mcp-minion recommended LLM summarization as a dedicated service. User explicitly stated "if LLM diff summarization is the only option, then that's what it is." Resolution: LLM-based diff summarization is the primary approach (Issue 3.1), aligned with user feedback. Commit messages are supplementary data, not the primary summary source.

### Risks and Mitigations

1. **Report bloat**: The new Routing and Configuration section could expand beyond the 40-60 line target. Mitigation: Task 1 prompt explicitly caps the section and instructs to keep schema details in the roadmap.

2. **Roadmap staleness**: Once GitHub issues are created, the roadmap document becomes a historical record. Mitigation: The "How to Use" preamble states this explicitly. The document defines initial planning, not a living tracker.

3. **Premature abstraction in roadmap**: Despite YAGNI warnings, the roadmap could over-specify cross-tool abstractions. Mitigation: Lucy's YAGNI constraints are embedded in the Task 2 prompt. Future milestones are headline-level only.

4. **Config file location debate in report**: Picking a specific location may draw review feedback. Mitigation: Framed as "proposed location" with rationale, not a binding decision.

### Execution Order

```
Task 1 (report iteration)
  |
  v  [APPROVAL GATE]
  |
Task 2 (roadmap creation)
  |
  v
Task 3 (architecture.md cross-link)
```

Batch 1: Task 1 (serial, gated)
Batch 2: Task 2 (after gate approval)
Batch 3: Task 3 (after Task 2)

All tasks are sequential. Task 1's gate ensures report positions are approved before the roadmap references them. Task 3 is a trivial cross-link update.

### Verification Steps

After all tasks complete:
1. Verify `docs/external-harness-integration.md` has exactly 2 open questions (instruction isolation + AGENTS.md stability)
2. Verify `docs/external-harness-roadmap.md` exists and has the milestone/issue structure
3. Verify `docs/architecture.md` links to the new roadmap document
4. Verify forward reference from report to roadmap exists in Recommendations section
5. Verify back-link from roadmap to report exists in roadmap header
6. Verify no mention of company names (beyond tool names) in either document
7. Verify both documents have `*Last assessed: 2026-03-17*` date stamps
