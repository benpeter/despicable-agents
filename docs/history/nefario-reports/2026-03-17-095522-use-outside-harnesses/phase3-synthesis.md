## Delegation Plan

**Team name**: external-harness-research
**Description**: Research feasibility of delegating specialist work to external LLM coding tools (Cursor, Aider, Codex CLI, etc.) alongside Claude Code subagents. Deliverable is a single research report at `docs/external-harness-integration.md`.

---

### Conflict Resolutions

**1. Report file name**: ai-modeling-minion proposed `docs/external-harness-delegation.md`; software-docs-minion proposed `docs/external-harness-integration.md`; mcp-minion proposed `docs/external-harnesses.md`. **Resolution**: Use `docs/external-harness-integration.md` per software-docs-minion's reasoning -- "integration" signals the topic without implying a conclusion, and it pairs naturally with the existing `docs/external-skills.md`.

**2. Scope framing -- research vs. design**: lucy flagged that ai-modeling-minion and devx-minion contributions lean toward design (abstraction layer architecture, harnesses.toml schema, error message templates). mcp-minion contributions are correctly research-scoped. **Resolution**: All specialist design insights are valuable as research evidence but must be framed as "what a wrapper would need to address" rather than "how to build it." Each task prompt includes an explicit scope guard. The report's Recommendations section provides directional guidance, not implementation specifications.

**3. MCP role**: mcp-minion correctly identified MCP is wrong for the delegation layer but valuable at the context-sharing layer. ai-modeling-minion included MCP as one of three coordination patterns. gru did not emphasize MCP. **Resolution**: The report models mcp-minion's three-layer stack (Process Invocation / Context Sharing / Orchestration Protocol) and positions MCP at Layer 2 only. No MCP advocacy in recommendations.

**4. Task granularity**: ai-modeling-minion proposed 3 tasks (all sections of one report). gru proposed 5 tasks. devx-minion proposed 5 tasks. software-docs-minion proposed 4 tasks. lucy proposed 4 tasks. **Resolution**: Since the deliverable is a single research report written by one agent, consolidate into 2 execution tasks: (1) write the report, (2) add cross-links. One agent, one file, two commits. This aligns with the project's "more code, less blah, blah" principle. The report author receives all specialist evidence in their prompt.

**5. Tool count**: gru inventoried 12 tools. The report should cover all that gru assessed but focus depth on the 6 feasible-today tools (Claude Code, Codex CLI, Aider, Gemini CLI, Copilot CLI, Cline CLI). Watch/hold tools get brief coverage.

---

### Task 1: Write the research report

- **Agent**: ai-modeling-minion
- **Delegation type**: standard
- **Model**: opus
- **Mode**: default
- **Blocked by**: none
- **Approval gate**: yes
- **Gate reason**: This is the primary deliverable and the sole output of the entire orchestration. The feasibility recommendation (success criterion 5) will shape future architectural decisions about the framework. Hard to reverse once published and cross-linked. High blast radius: the cross-link task depends on it, and future work on multi-harness support will reference it.
- **Prompt**: |
    You are writing a research report: `docs/external-harness-integration.md`

    **SCOPE GUARD: This is a research task. Document what exists and assess
    feasibility. Do not produce implementation designs, architecture proposals,
    or code. Where the research identifies that "an abstraction would be needed,"
    describe what it would need to do, not how it should be structured.**

    **PUBLISHABILITY GUARD: This report is published under Apache 2.0. It must
    be vendor-neutral. Do not reflect any local technology biases. Do not
    mention any specific company's internal usage. Tool names (Cursor, Aider,
    Codex CLI) are fine -- they are public products.**

    ## What to produce

    A feasibility study at `docs/external-harness-integration.md` that answers:
    "Can the despicable-agents orchestrating session delegate tasks to external
    LLM coding tools the same way it delegates to Claude Code subagents?"

    The report must satisfy six success criteria:

    1. **Inventory of LLM coding tools and their context-injection mechanisms**
    2. **Analysis of how AGENT.md knowledge maps to each tool's instruction format**
    3. **Feasibility assessment: can a delegation wrapper start an external tool, inject agent knowledge, and collect results**
    4. **Gap analysis: what the current Agent tool provides vs. what a wrapper can replicate** -- this MUST be a structured comparison table, not narrative
    5. **Clear recommendation: feasible now / feasible with constraints / not yet feasible** -- this is the core deliverable. Apply the verdict per-tool or per-tool-category. You own this recommendation explicitly.
    6. **Research written to a new doc under docs/**

    ## Report structure

    Follow this structure (from software-docs-minion). Open with back-link to
    architecture.md. Use `---` between major sections. Use Mermaid where it
    clarifies flow. Use tables over narrative wherever possible.

    ```
    # External Harness Integration

    [< Back to Architecture Overview](architecture.md)

    ## Problem Statement
    What limitation does single-harness lock-in create?
    What would multi-harness delegation enable?

    ## Current Delegation Model
    How nefario delegates today (subagent spawning, Task tool, scratch files).
    The five interface points of the current contract:
    (a) prompt delivery, (b) context injection, (c) file access,
    (d) result collection, (e) error handling.
    Which parts are Claude-Code-specific vs. harness-agnostic.

    ## Tool Inventory
    Per-tool profiles. For each tool: CLI headless interface, instruction
    injection mechanism, result collection format, auto-approve flag,
    maturity assessment. Focus depth on 6 feasible-today tools. Brief
    coverage for watch/hold tools.

    ## Instruction Format Landscape
    How AGENT.md five-section template maps to each tool's instruction
    format (AGENTS.md, .cursorrules/.mdc, CONVENTIONS.md, etc.).
    Include a translation table: AGENT.md section x target format.
    Document known lossy translations (e.g., tools: field has no
    equivalent in Aider; model: field uses different identifiers).

    ## Protocol Landscape
    Three-layer model: Process Invocation / Context Sharing /
    Orchestration Protocol. Assess MCP (wrong for delegation, useful
    for context sharing), A2A (architecturally closest but zero
    adoption in coding tools), ACP (emerging, assess-ring), and
    CLI subprocess (pragmatic default). Include comparison table.

    ## Gap Analysis
    STRUCTURED TABLE comparing what the current Claude Code Task tool
    provides vs. what each candidate tool can replicate vs. what is
    lost. Dimensions: prompt delivery, context injection, file access,
    result collection, error handling, progress monitoring, model
    routing, cost tracking, tool parity.

    ## Feasibility Assessment
    Per-tool or per-category verdict using three tiers:
    - Feasible now (build adapters with current tool capabilities)
    - Feasible with constraints (what limitations exist)
    - Not yet feasible (what would need to change)
    Include "why not" dimension: reasons not to support external
    harnesses (complexity, maintenance, consistency).

    ## Recommendations
    The feasibility recommendation. Directional, not prescriptive.
    Sequencing if multiple tools are feasible. What would need to
    change in nefario's delegation model (at the concept level).
    Technology radar rings (adopt/trial/assess/hold) per tool as
    delegation targets.

    ## Out of Scope
    Security threat model for external tool execution.
    UX design for multi-harness workflows.
    Cost comparison across providers.
    Implementation of any wrapper or adapter.

    ## Open Questions
    Unresolved items needing further investigation.
    ```

    ## Evidence from specialist planning

    Use the following specialist evidence to inform your research. These are
    planning-phase contributions, not execution outputs. Synthesize their
    findings into the report structure above.

    ### From gru (technology radar)

    Tool landscape with 12 tools assessed. Key findings:
    - 6 tools feasible today: Claude Code (adopt), Codex CLI (trial), Aider
      (trial), Gemini CLI (trial), Copilot CLI (trial), Cline CLI (trial)
    - 4 tools assess-ring: Continue, Goose, Kilo, Amp, Cursor CLI
    - 1 tool hold: Windsurf (no headless CLI)
    - Three convergence patterns: invocation (`-p` flag), instruction format
      (AGENTS.md under Linux Foundation), auto-approve flags
    - Instruction format landscape table (9 formats, which tools read which)
    - ACP protocol (Assess ring) -- agent-editor protocol, not orchestrator-agent
    - Hype filter: individual tools mature, multi-tool orchestration is frontier
      (no public production signals)

    Use gru's full tool capability table as the basis for the Tool Inventory
    section. The table is in the scratch file at:
    `/var/folders/3k/bfjvvz9s6dvdn_hvlhvr8lc00000gn/T//nefario-scratch-kifrP8/use-outside-harnesses/phase2-gru.md`

    ### From ai-modeling-minion (delegation model analysis)

    Current subagent contract has five interface points: prompt delivery,
    context injection, file access, result collection, error handling.
    Three coordination patterns for external tools: CLI wrapper (Pattern A),
    MCP tool use (Pattern B), A2A protocol (Pattern C). Instruction format
    translation is the core complexity (AGENT.md -> AGENTS.md / .mdc / .aider).
    Key constraints: shared filesystem assumption, no context window sharing
    (favorable), tool subset differences, model routing translation, active
    monitoring (CLI wait is actually simpler than current polling).

    Full analysis at:
    `/var/folders/3k/bfjvvz9s6dvdn_hvlhvr8lc00000gn/T//nefario-scratch-kifrP8/use-outside-harnesses/phase2-ai-modeling-minion.md`

    ### From mcp-minion (protocol analysis)

    MCP is wrong for delegation layer (short tool calls, not multi-minute
    coding tasks). MCP Tasks primitive is experimental, solves duration but
    not delegation semantics. A2A is architecturally closer but zero adoption
    in coding tools. Three-layer model:
    - Layer 3: Orchestration Protocol (delegation, lifecycle, results)
    - Layer 2: Context Sharing Protocol (MCP well-suited here)
    - Layer 1: Process Invocation (subprocess, transport)
    Result collection requirements: structured deliverable metadata,
    completion signal, error propagation, progress streaming, git state handback.

    Full analysis at:
    `/var/folders/3k/bfjvvz9s6dvdn_hvlhvr8lc00000gn/T//nefario-scratch-kifrP8/use-outside-harnesses/phase2-mcp-minion.md`

    ### From devx-minion (developer experience)

    Wrapper should be invisible to nefario (facade pattern). Config-driven
    routing via harnesses.toml. Two instruction channels per tool: persistent
    (conventions file) + per-task (message flag). Three-component error messages.
    Zero-config default to Claude Code. Key DX dimensions to cover in report:
    invocation ergonomics, configuration discoverability, first-run experience,
    error catalog, observability for user, escape hatches, translation fidelity.
    YAGNI tension: zero-cost for users who do not use external harnesses.

    Full analysis at:
    `/var/folders/3k/bfjvvz9s6dvdn_hvlhvr8lc00000gn/T//nefario-scratch-kifrP8/use-outside-harnesses/phase2-devx-minion.md`

    ### From lucy (governance review)

    Two traceability gaps corrected: (1) feasibility recommendation must have
    explicit owner (you own it), (2) gap analysis must be structured table.
    Scope drift warnings: frame as research not design. Report must be
    vendor-neutral and publishable. Convention requirements: back-link,
    English, tables over narrative, date-stamp tool assessments.

    ### From software-docs-minion (document structure)

    Report structure (used above). Location: `docs/external-harness-integration.md`.
    Lead with problem not tools. Separate inventory (descriptive) from analysis
    (evaluative). Matrix AND per-tool sections. Dedicated "Out of Scope" section.
    Decision-record tone: show what was considered and assessed.
    Cross-link from architecture.md (sub-documents table), external-skills.md,
    and orchestration.md.

    ## Constraints

    - The report must include a "Last assessed: 2026-03-17" note
    - Frame tool limitations as "as of [date], tool X does not support Y"
      rather than permanent assertions
    - Include Mermaid diagrams for: (1) current delegation flow, (2) where
      an external harness adapter would conceptually sit
    - Target 1500-2500 words of prose + tables. Prefer tables.
    - Do not produce: implementation designs, API contracts, code,
      harnesses.toml schemas, error message templates, or architecture
      proposals. Describe what would be needed, not how to build it.
    - Do NOT modify any file other than `docs/external-harness-integration.md`

    ## Files to read for context

    - `docs/orchestration.md` -- current delegation model (Section 1, especially Phase 4)
    - `docs/external-skills.md` -- related concept (external skills vs. external harnesses)
    - `docs/architecture.md` -- where this doc fits in the hub-and-spoke structure
    - `nefario/AGENT.md` -- the orchestrator agent (delegation table, task prompts)
    - `skills/nefario/SKILL.md` -- Phase 4 execution details
    - The four scratch files referenced above for specialist evidence

- **Deliverables**: `docs/external-harness-integration.md` -- complete research report
- **Success criteria**: All six success criteria are addressed. Gap analysis is a structured table. Feasibility recommendation uses the three-tier verdict. Report follows project documentation conventions. Vendor-neutral and publishable.

---

### Task 2: Add cross-links to existing docs

- **Agent**: software-docs-minion
- **Delegation type**: standard
- **Model**: sonnet
- **Mode**: default
- **Blocked by**: Task 1
- **Approval gate**: no
- **Gate reason**: N/A -- additive cross-links to existing docs. Easy to reverse, low blast radius.
- **Prompt**: |
    You are adding cross-links for the new research report
    `docs/external-harness-integration.md` to three existing documents.

    **SCOPE GUARD: This is a research task. Document what exists and assess
    feasibility. Do not produce implementation designs, architecture proposals,
    or code.**

    ## What to do

    1. **`docs/architecture.md`**: Add a row to the "Sub-Documents" table
       (the table under "## Sub-Documents" or similar heading listing all
       docs with descriptions):

       | [External Harness Integration](external-harness-integration.md) | Feasibility study: delegating execution to external LLM coding tools alongside Claude Code subagents |

    2. **`docs/external-skills.md`**: Add a brief cross-reference noting
       the related concept. External skills are Claude Code native extensions;
       external harness integration explores using non-Claude-Code execution
       tools. Add 1-2 sentences in an appropriate location (e.g., a "Related"
       section at the end, or a note in the introduction). Keep it minimal.

    3. **`docs/orchestration.md`**: In the Phase 4 section, add a brief note
       that the current execution model assumes Claude Code subagents, with
       a link to the feasibility study exploring external harnesses. One
       sentence, not a paragraph.

    ## What NOT to do

    - Do not modify `docs/external-harness-integration.md`
    - Do not modify any other files
    - Do not add lengthy descriptions -- cross-links should be 1-2 sentences each
    - Do not restructure or reformat the existing documents

    ## Files to read

    - `docs/architecture.md` -- find the sub-documents table
    - `docs/external-skills.md` -- find the right place for a cross-reference
    - `docs/orchestration.md` -- find Phase 4 section

- **Deliverables**: Updated `docs/architecture.md`, `docs/external-skills.md`, `docs/orchestration.md` with cross-links
- **Success criteria**: Three files updated with minimal, accurate cross-links. No other files modified.

---

### Cross-Cutting Coverage

- **Testing**: Not included. This task produces a research document, not code, configuration, or infrastructure. No executable output to test.
- **Security**: Not included as a separate task. The report's "Out of Scope" section notes that security threat modeling for external tool execution is deferred. Security implications are acknowledged but not deeply analyzed -- appropriate for a research report that precedes any implementation decision. If the recommendation leads to implementation, security-minion reviews the implementation plan.
- **Usability -- Strategy**: Covered within Task 1's prompt. The report addresses DX dimensions (invocation ergonomics, configuration discoverability, error experience, escape hatches) as research findings, informed by devx-minion's planning contribution. ux-strategy-minion's journey coherence perspective is not needed for a research report that has no user journey to assess.
- **Usability -- Design**: Not included. No user-facing interface is being produced.
- **Documentation**: Task 1 IS the documentation deliverable. Task 2 integrates it into the existing doc structure. software-docs-minion planned the structure and reviews via Phase 5.
- **Observability**: Not included. No runtime component is being produced.

---

### Architecture Review Agents

- **Mandatory** (5): security-minion, test-minion, ux-strategy-minion, lucy, margo
- **Discretionary picks**:
  - **software-docs-minion**: The sole deliverable is a research document. Document structure, progressive disclosure, and consistency with project doc conventions are the primary quality dimensions. References Tasks 1 and 2.
- **Not selected**: ux-design-minion (no UI produced), accessibility-minion (no web UI produced), sitespeed-minion (no web runtime produced), observability-minion (no runtime components), user-docs-minion (no end-user documentation change)

---

### Risks and Mitigations

| # | Risk | Severity | Mitigation |
|---|------|----------|------------|
| 1 | **Design document masquerading as research** -- specialist contributions lean toward "how to build it" | HIGH | Explicit scope guard in Task 1 prompt. lucy's DRIFT-1/DRIFT-2 warnings embedded. Post-execution review by lucy (Phase 5) catches remaining drift. |
| 2 | **Result collection is the hard problem** -- tools vary dramatically in output format (JSON, git diff, text, nothing) | MEDIUM | Report must identify this as the key gap honestly. The gap analysis table makes this visible per tool. |
| 3 | **Tool landscape volatility** -- a report written today may be partially stale in weeks | MEDIUM | Include "Last assessed: 2026-03-17" date. Frame limitations as "as of [date]" not permanent assertions. |
| 4 | **Report bloat** -- 6 specialists produced extensive input; the report could become 4000+ words | MEDIUM | Prompt constrains to 1500-2500 words + tables. Tables preferred over narrative. "More code, less blah, blah." |
| 5 | **Tool advocacy** -- gru's adopt/trial ratings could read as endorsements | LOW | Report presents ratings as assessed options for delegation fitness, not general tool quality. Neutral framing. |
| 6 | **CLAUDE.local.md leakage** -- local tech biases could leak into publishable report | LOW | Explicit publishability guard in prompt. Phase 5 lucy review catches vendor-specific language. |

---

### Execution Order

```
Batch 1: Task 1 (ai-modeling-minion writes report)
         [APPROVAL GATE on Task 1]
Batch 2: Task 2 (software-docs-minion adds cross-links)
```

Two batches, one gate. The gate is between Task 1 and Task 2 because the
cross-links depend on the report existing and being approved.

---

### Verification Steps

After all tasks complete:
1. `docs/external-harness-integration.md` exists and contains all six sections
2. The gap analysis section contains a structured comparison table (not just narrative)
3. The feasibility recommendation uses the three-tier verdict (feasible now / with constraints / not yet feasible)
4. The report opens with `[< Back to Architecture Overview](architecture.md)`
5. `docs/architecture.md` sub-documents table includes the new report
6. `docs/external-skills.md` cross-references the new report
7. `docs/orchestration.md` Phase 4 section links to the new report
8. No vendor-specific or proprietary language in the report
9. Report includes "Last assessed: 2026-03-17"
