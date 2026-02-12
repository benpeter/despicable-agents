# Phase 3: Synthesis -- Evaluate DESPICABLE.md Configuration

## Delegation Plan

**Team name**: evaluate-despicable-md-config
**Description**: Produce a decision document evaluating whether consuming projects should have dedicated DESPICABLE.md / DESPICABLE.local.md files. Consultation only -- no code.

---

### Conflict Resolution

**Core conflict**: 4 of 5 specialists (gru, lucy, margo, devx-minion) recommend against DESPICABLE.md. 1 specialist (software-docs-minion) recommends for it.

**Resolution: Reject DESPICABLE.md. Recommend CLAUDE.md section convention instead.**

Rationale for siding with the majority:

1. **Precedent weight**: Decisions 26 (rejected .nefario.yml) and 27 (removed overlay mechanism) were made within the past week. Both applied YAGNI to reject configuration infrastructure with zero demonstrated demand. Introducing DESPICABLE.md immediately after these decisions would contradict freshly-established project principles.

2. **Zero consumers**: The toolkit has exactly one consuming project (itself). Building per-project configuration infrastructure for zero external consumers is the textbook YAGNI failure mode that margo identified.

3. **Platform integration**: CLAUDE.md is automatically loaded by Claude Code. DESPICABLE.md would require explicit Read calls in agents -- fragile discovery that gru, devx-minion, and lucy all flagged as a high-severity risk.

4. **Industry direction**: gru's analysis shows the ecosystem consolidating toward fewer config files (AGENTS.md standard, ESLint flat config trajectory, Cursor consolidating .cursorrules). Introducing a new dedicated file swims against this tide.

5. **Complexity asymmetry**: margo's cost analysis (7 complexity points for DESPICABLE.md vs. 0 for CLAUDE.md sections) is uncontested by software-docs-minion's contribution, which acknowledges the overhead but argues separation of concerns justifies it.

**Why software-docs-minion's position was not adopted**: The separation-of-concerns argument is valid in principle but disproportionate for the current configuration surface. As devx-minion noted, the despicable-agents config is closer to Prettier (few preferences) than ESLint (complex plugin architecture). The configuration use cases identified (agent exclusion, domain spin, orchestration overrides) are either already handled by existing CLAUDE.md patterns, should not be configurable at all (ALWAYS reviewers, Phase 3.5 skip), or have too low utility to justify new infrastructure. software-docs-minion's documentation burden estimate (1200-1500 lines for dedicated file vs. 400-600 for CLAUDE.md section) itself demonstrates the overhead differential.

---

### Task 1: Write ADR Decision Document

- **Agent**: software-docs-minion
- **Delegation type**: standard
- **Model**: sonnet
- **Mode**: default
- **Blocked by**: none
- **Approval gate**: no
- **Prompt**: |
    Write a new decision entry (Decision 29) in `/Users/ben/github/benpeter/despicable-agents/docs/decisions.md`.

    ## Context

    The team evaluated whether consuming projects should have dedicated
    DESPICABLE.md and DESPICABLE.local.md files for framework-specific
    configuration of the despicable-agents toolkit. Five specialists were
    consulted: gru (technology radar), lucy (governance/compliance),
    margo (simplicity/YAGNI), devx-minion (developer experience), and
    software-docs-minion (documentation architecture).

    ## Decision to Record

    **Decision 29: Reject DESPICABLE.md, Adopt CLAUDE.md Section Convention**

    Use this format (matching the existing table format in decisions.md):

    ```
    ### Decision 29: Reject DESPICABLE.md, Adopt CLAUDE.md Section Convention

    | Field | Value |
    |-------|-------|
    | **Status** | Decided |
    | **Date** | 2026-02-12 |
    | **Choice** | ... |
    | **Alternatives rejected** | ... |
    | **Rationale** | ... |
    | **Consequences** | ... |
    ```

    Field content:

    **Choice**: Do not introduce DESPICABLE.md or DESPICABLE.local.md. Consuming
    projects configure despicable-agents behavior via a `## Despicable Agents`
    section in their existing CLAUDE.md (public) and CLAUDE.local.md (private).
    Nefario reads this section via Claude Code's automatic CLAUDE.md loading --
    no new discovery logic required. Re-evaluate when 2+ consuming projects
    demonstrate configuration needs that CLAUDE.md sections cannot serve,
    or when Claude Code adopts AGENTS.md support (whichever comes first).

    **Alternatives rejected**: (1) Dedicated DESPICABLE.md + DESPICABLE.local.md
    files for framework-specific config. Rejected because: zero consuming
    projects exist to demonstrate need (YAGNI); contradicts Decisions 26
    (.nefario.yml rejected) and 27 (overlay removal) made within the same week;
    requires explicit Read calls in agents since Claude Code does not auto-load
    custom files; creates precedence complexity (4-file hierarchy); industry
    consolidating toward fewer config files (AGENTS.md standard). (2) Status quo
    with no guidance. Rejected because consuming projects would rediscover
    configuration patterns inconsistently.

    **Rationale**: 4 of 5 consulted specialists recommended against DESPICABLE.md.
    Key factors: CLAUDE.md is auto-loaded by Claude Code (zero infrastructure);
    the configuration surface is small (few preferences, not a plugin architecture);
    Decision 5 establishes CLAUDE.md as the canonical project customization surface;
    the ecosystem is consolidating config files, not proliferating them. The
    dissenting view (software-docs-minion) valued separation of concerns, but the
    configuration volume does not justify a dedicated file -- the analogy is
    Prettier (section in package.json) not ESLint (dedicated file). Lucy
    additionally identified that any configuration mechanism must protect ALWAYS
    reviewers (security-minion, test-minion, lucy, margo) from exclusion --
    this constraint applies regardless of config surface and should be enforced
    in nefario.

    **Consequences**: Consuming projects add a `## Despicable Agents` section
    to CLAUDE.md for framework preferences. CLAUDE.local.md handles private/local
    overrides. No new files, discovery logic, or precedence rules needed. Future
    documentation should include examples of the section convention. ALWAYS
    reviewer protection should be enforced in nefario (separate future task,
    not part of this decision). If AGENTS.md support arrives in Claude Code,
    the section convention migrates trivially.

    ## Placement

    Add this decision under a new section heading:

    ```
    ## Configuration (Decisions 29+)
    ```

    Place it after the existing "Orchestration Improvements (Decisions 25-28)"
    section, at the end of the file.

    ## What NOT to do

    - Do not modify any other decisions
    - Do not create new files -- only append to the existing decisions.md
    - Do not add content beyond the decision entry and its section heading
    - Do not include the dissenting view as a separate section -- it is covered
      in the Rationale field

- **Deliverables**: Updated `/Users/ben/github/benpeter/despicable-agents/docs/decisions.md` with Decision 29
- **Success criteria**: Decision 29 follows the same table format as Decisions 1-28; captures the recommendation, rejected alternatives, rationale (including dissent), consequences, and re-introduction trigger

---

### Cross-Cutting Coverage

- **Testing**: Not applicable -- this task produces a decision document, not code or configuration. No executable output to test.
- **Security**: Covered within the decision rationale. Lucy identified the ALWAYS reviewer protection concern. The decision document captures this as a consequence (future enforcement task). No security review of the document itself is needed.
- **Usability -- Strategy**: Covered by the evaluation itself. All 5 specialists assessed the developer/user experience implications. The decision to use CLAUDE.md sections was driven by discoverability, cognitive overhead, and onboarding friction analysis from devx-minion and gru.
- **Usability -- Design**: Not applicable -- no user-facing interfaces produced.
- **Documentation**: The deliverable IS documentation. software-docs-minion authors it. No separate documentation review needed.
- **Observability**: Not applicable -- no runtime components produced.

### Architecture Review Agents

- **Always**: security-minion, test-minion, ux-strategy-minion, software-docs-minion, lucy, margo
- **Conditional**: none triggered

Note: Phase 3.5 applies to this plan. However, given that the deliverable is a single decision entry in an existing file, and that all 6 ALWAYS reviewers' domains were already represented in the specialist consultation (lucy, margo, devx-minion covered governance and usability; gru covered security implications; software-docs-minion is the authoring agent), the review prompts should focus on verifying the decision document accurately represents the consultation findings rather than introducing new architectural concerns.

### Conflict Resolutions

| Conflict | Resolution | Rationale |
|----------|-----------|-----------|
| software-docs-minion (ADOPT) vs. gru, lucy, margo, devx-minion (REJECT) | REJECT DESPICABLE.md | 4-to-1 consensus; YAGNI precedent (Decisions 26, 27); zero consumers; platform auto-loading advantage; industry consolidation trend. Dissenting separation-of-concerns argument valid but disproportionate for current config surface. |

### Risks and Mitigations

| Risk | Source | Severity | Mitigation |
|------|--------|----------|------------|
| Decision reopened without new evidence | margo | Low | Decision 29 includes explicit re-introduction trigger: "2+ consuming projects demonstrate need OR Claude Code adopts AGENTS.md" |
| CLAUDE.md config parsing is unstructured | lucy | Low | Current config is natural language interpreted by LLM. If complexity grows, structured blocks (YAML in CLAUDE.md) can be added later. YAGNI for now. |
| ALWAYS reviewer bypass via CLAUDE.local.md | lucy | Medium | Documented as consequence in Decision 29. Enforcement in nefario is a separate future task (not in scope of this consultation). |
| AGENTS.md convergence changes the landscape | gru | Medium | Decision 29 includes re-evaluation trigger for AGENTS.md adoption. Section convention migrates trivially to AGENTS.md. |
| Evaluation creates momentum to build anyway | margo | Low | Decision document explicitly states "do not build" with clear re-introduction criteria. |

### Execution Order

```
Batch 1: Task 1 (write Decision 29)
  |
Phase 3.5: Architecture review of the decision document
  |
Done -- single deliverable, presented to user
```

No approval gates. The decision document is the final deliverable presented directly to the user for review. Zero gates is appropriate because:
- Blast radius is low (one file edit, no downstream tasks)
- Easy to reverse (decision entries can be amended)
- The user explicitly requested a consultation, so the output IS the approval artifact

### External Skills

No external skills detected in project.

### Verification Steps

1. Decision 29 exists in `docs/decisions.md` with correct table format
2. The Choice field captures the CLAUDE.md section convention recommendation
3. The Alternatives rejected field covers both DESPICABLE.md and status quo
4. The Rationale field includes the dissenting view and why it was not adopted
5. The Consequences field includes the re-introduction trigger and ALWAYS reviewer protection note
6. The decision is placed under a new "Configuration (Decisions 29+)" section heading
