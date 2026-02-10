# Phase 3: Synthesis -- Documentation Rethink with Product Marketing Lens

## Delegation Plan

**Team name**: docs-rethink
**Description**: Rewrite project documentation with product marketing lens and embed marketing awareness into nefario's Phase 8.

---

### Conflict Resolutions

**1. README length target vs. content additions.**
devx-minion recommends a hard cap of 120 lines. software-docs-minion wants a full documentation links section with two subsections (user-facing, contributor). product-marketing-minion wants a messaging hierarchy with 7 layers. ux-strategy-minion wants a "Try it" section added.

**Resolution**: Target 100-130 lines. The content must fit; the line count is a constraint, not a goal. Achieve this by: (a) making the full agent roster collapsible (saves ~30 lines), (b) merging "What you get" and "Try it" into a single section that shows examples and bridges to first use, (c) keeping "How It Works" to 5-7 lines maximum. The README is a landing page, not a manual.

**2. Three new docs pages vs. KISS.**
software-docs-minion proposes three new pages: overview.md, using-nefario.md, agent-catalog.md. This increases doc count by 1 net (3 added, 2 archived). margo would likely flag three new pages as potential over-engineering for a 27-agent project.

**Resolution**: Create two new pages, not three. `docs/using-nefario.md` (extracted from orchestration.md Section 1) is clearly needed -- the best user content is currently buried. `docs/agent-catalog.md` is also needed -- it absorbs the full roster from README and gives each agent a proper entry. Drop `docs/overview.md` -- the README itself serves as the overview when rewritten with the marketing lens, and architecture.md already covers the system design for anyone who wants depth. This avoids content duplication between README and overview.md (software-docs-minion's own Risk 1).

**3. Phase 8 triage framework: marketing tiers vs. UX criteria.**
product-marketing-minion proposes a 3-tier system (Headline/Notable/Document-only) with 5 decision criteria. ux-strategy-minion proposes a 3-bucket system (README-worthy/Changelog-docs-worthy/Silent) with 5 different criteria. The frameworks are compatible but overlapping.

**Resolution**: Merge into a single 3-tier system. Use product-marketing-minion's tier names (cleaner) and merge the decision criteria from both specialists. The merged criteria evaluate: (1) new capability, (2) user-visible impact, (3) differentiator strength, (4) changed mental model, (5) breaking change. This is addressed in the Phase 8 spec task (Task 5).

**4. architecture.md: keep as hub vs. strip to contributor-only.**
software-docs-minion recommends stripping architecture.md of user-facing content and making it contributor-only. The current architecture.md is also the primary entry point from README's Documentation section.

**Resolution**: Keep architecture.md as the contributor hub but update it to redirect users. Add a one-line redirect at the top pointing to the new user-facing docs. Strip the agent groups table (now in agent-catalog.md) and the system context narrative (README covers this). Keep: design philosophy, sub-documents index, cross-cutting concerns detail. README links to both user docs and architecture.md directly.

**5. install.sh changes.**
devx-minion recommends adding post-install orientation to install.sh output. This is out of scope per the task definition ("no code beyond the SKILL.md phase instruction update"). install.sh is a script, not documentation.

**Resolution**: Exclude install.sh changes from this plan. The README "Try it" section covers the post-install gap. If install.sh improvements are desired, they belong in a separate task.

---

### Risks and Mitigations

**Risk 1: Over-marketing an OSS project** (raised by product-marketing-minion, ux-strategy-minion)
Applying marketing frameworks to open-source documentation could produce copy that feels corporate or salesy.
*Mitigation*: The tone guide in the positioning strategy constrains language. Every claim must be verifiable by reading the codebase. "Senior engineer describing their architecture" is the tone model. Review criterion: if a sentence contains an adjective that cannot be verified in 60 seconds, remove it.

**Risk 2: Positioning claims going stale** (raised by product-marketing-minion)
Comparative positioning depends on competitors not evolving.
*Mitigation*: Position on what the project IS, not what competitors are NOT. "Built-in governance" is self-contained. "No other collection has governance" is fragile. The README should not include a comparison table.

**Risk 3: README restructure breaking links** (raised by product-marketing-minion, software-docs-minion)
Moving sections and changing headings breaks inbound links from docs, bookmarks, and external references.
*Mitigation*: Task 6 (cross-link verification) explicitly audits all internal references. For heading changes, add HTML anchor tags for backward compatibility where needed.

**Risk 4: Content duplication between README and docs** (raised by software-docs-minion)
User-facing content in both README and docs/ pages will drift apart.
*Mitigation*: README uses "teaser + link" pattern -- brief statement with link to authoritative page. README does not restate content from docs pages in abbreviated form. The authoritative version lives in docs/; README points to it.

**Risk 5: Agent catalog maintenance burden** (raised by software-docs-minion)
27-entry catalog needs updating when agents change.
*Mitigation*: Structure the catalog so the frequently-changing parts (one-line description, group membership) are easy to update. The catalog is a reference page, not a marketing page -- it can be straightforward. Note in the catalog's header that entries should be updated when AGENT.md files change.

**Risk 6: Phase 8 triage becoming a checkbox** (raised by ux-strategy-minion)
If criteria are too complex, nefario treats them as a checklist rather than a judgment call.
*Mitigation*: Keep the triage to 3 tiers with 5 decision criteria. The instruction to product-marketing-minion should emphasize "classify and recommend" not "rewrite." The marketing lens adds judgment, not process.

---

### Tasks

#### Task 1: Write positioning strategy document

- **Agent**: product-marketing-minion
- **Model**: sonnet
- **Mode**: default
- **Blocked by**: none
- **Approval gate**: yes (Gate 1 -- all downstream tasks depend on this messaging foundation)
- **Gate reason**: The positioning strategy determines the value proposition, messaging hierarchy, and tone for all documentation. Getting this wrong propagates through every deliverable. Hard to reverse (messaging consistency), high blast radius (5 dependent tasks).
- **Prompt**: |
    Write a positioning strategy document for the despicable-agents project. This document becomes the source of truth for all documentation writing in this project.

    **Context**: despicable-agents is a team of 27 specialist agents for Claude Code, organized into a four-tier hierarchy: Gru (strategic boss), Nefario (orchestrator), Lucy+Margo (governance), and 23 domain-specialist minions. The key differentiator is not agent count (competitors have 100+) but coordination quality: structured multi-phase orchestration, built-in governance review, and strict specialist boundaries with deterministic routing.

    **Include these sections**:

    1. **Core value proposition** (one sentence). Lead with the job-to-be-done, not the feature count. The user's struggle: complex tasks that span multiple domains get shallow treatment from a single AI session.

    2. **Supporting messages** (3-5). Each must be: a specific, verifiable fact about the project (not a comparative claim); accompanied by proof points from the codebase; and self-contained (true regardless of what competitors do).

    3. **Messaging hierarchy for README**. Define what goes where, in what order. The ordering must follow adoption-first logic: value proposition -> examples showing value -> install -> try it -> how it works -> agent reference -> documentation links -> contributing -> license. The full 27-agent roster should be collapsible or linked to a reference page, not inline as a 30-row table.

    4. **Tone guide for OSS**. Specific do/don't rules. Key principle: write like a senior engineer describing their team's architecture to another senior engineer. Specific, factual, slightly proud, willing to acknowledge tradeoffs. No superlatives, no hype, no marketing adjectives without proof. Every claim verifiable by reading the codebase.

    5. **Current limitations** to state transparently. Include: Claude Code platform dependency, subagent nesting limitation, context window constraints for large orchestrations, the 97% vibe-coded reality.

    **Do NOT**:
    - Include a comparison table against competitors (too aggressive for OSS README)
    - Use superlatives ("best", "most powerful", "comprehensive")
    - Make comparative claims that depend on competitors NOT doing something
    - Write the actual README (that is a separate task)

    **Read these files for context**:
    - `/Users/ben/github/benpeter/despicable-agents/README.md` (current README)
    - `/Users/ben/github/benpeter/despicable-agents/docs/architecture.md` (system design)
    - `/Users/ben/github/benpeter/despicable-agents/docs/orchestration.md` (lines 1-103, user-facing section)
    - `/Users/ben/github/benpeter/despicable-agents/docs/decisions.md` (design tradeoffs)

    **Write output to**: `/Users/ben/github/benpeter/despicable-agents/nefario/scratch/rethink-docs-product-marketing-lens/positioning-strategy.md`

    **Length target**: 150-250 lines. Dense and operational, not fluffy.
- **Deliverables**: `nefario/scratch/rethink-docs-product-marketing-lens/positioning-strategy.md`
- **Success criteria**: Document contains all 5 sections. Value proposition leads with user benefit not feature count. Supporting messages are verifiable facts. Tone guide has concrete do/don't rules. No superlatives or hype language.

---

#### Task 2: Create docs/using-nefario.md (user-facing orchestration guide)

- **Agent**: software-docs-minion
- **Model**: sonnet
- **Mode**: default
- **Blocked by**: Task 1 (uses positioning strategy for tone and framing)
- **Approval gate**: no
- **Prompt**: |
    Extract and refine the user-facing orchestration content from docs/orchestration.md into a new standalone page: `docs/using-nefario.md`.

    **What to extract**: Section 1 of orchestration.md ("Using Nefario", lines 9-103). This includes: when to use nefario vs. direct agents, invocation examples, the nine-phase walkthrough, tips for success.

    **What to change during extraction**:
    - Remove the "Platform Constraint" paragraph (lines 100-102) -- this is a contributor implementation detail, not user-facing.
    - Rewrite the nine-phase walkthrough to emphasize the user's experience at each phase (what they see, what they decide, what happens in the background) rather than the technical implementation. Keep the phase names and numbers consistent with the existing documentation.
    - Add a one-line navigation link at the top: `[< Back to README](../README.md)`
    - Add a note at the bottom linking to the full orchestration architecture doc: "For the technical architecture behind the orchestration process, see [Orchestration Architecture](orchestration.md)."

    **What NOT to do**:
    - Do not modify the existing orchestration.md yet (Task 4 handles that)
    - Do not add content that is not already in Section 1 -- this is extraction plus refinement, not new writing
    - Do not use marketing language or superlatives. This is a usage guide, not a sales pitch. Keep the tone factual and practical.

    **Read the positioning strategy for tone guidance**: `/Users/ben/github/benpeter/despicable-agents/nefario/scratch/rethink-docs-product-marketing-lens/positioning-strategy.md`

    **Read the source content**: `/Users/ben/github/benpeter/despicable-agents/docs/orchestration.md` (lines 1-103)

    **Write to**: `/Users/ben/github/benpeter/despicable-agents/docs/using-nefario.md`
- **Deliverables**: `docs/using-nefario.md`
- **Success criteria**: Standalone page that covers when/how to use nefario. No contributor implementation details. Links back to README and forward to orchestration architecture. Phase walkthrough is user-experience-oriented.

---

#### Task 3: Create docs/agent-catalog.md (per-agent reference)

- **Agent**: software-docs-minion
- **Model**: sonnet
- **Mode**: default
- **Blocked by**: Task 1 (uses positioning strategy for framing)
- **Approval gate**: no
- **Prompt**: |
    Create a reference page listing all 27 agents with structured entries: `docs/agent-catalog.md`.

    **Structure**:
    1. A brief intro paragraph (2-3 sentences) explaining what this page is and how to use it.
    2. A "How to choose" decision guide: "Single-domain work? Call the specialist directly with @name. Multi-domain work? Use /nefario." Then a brief group-level guide: "Security concern? @security-minion. API design? @api-design-minion. Not sure? @gru for strategic questions, /nefario for complex tasks."
    3. Agents organized by group (same 9 groups as the README roster: Boss, Foreman, Governance, Protocol & Integration, Infrastructure & Data, Intelligence, Development & Quality, Security & Observability, Design & Documentation, Web Quality).
    4. Each agent entry contains:
       - Agent name (as code: `agent-name`)
       - One-line description
       - Model tier (opus or sonnet -- read from AGENT.md frontmatter `model:` field)
       - Example invocation: one realistic `@agent` command showing a concrete use case
       - Key boundaries: 2-3 abbreviated "Does NOT do" items with delegation targets (read from AGENT.md "Does NOT do" section)

    **Navigation**: Add `[< Back to README](../README.md)` at the top.

    **Read all AGENT.md files for accurate information**. The agent directories are:
    - `/Users/ben/github/benpeter/despicable-agents/gru/AGENT.md`
    - `/Users/ben/github/benpeter/despicable-agents/nefario/AGENT.md`
    - `/Users/ben/github/benpeter/despicable-agents/lucy/AGENT.md`
    - `/Users/ben/github/benpeter/despicable-agents/margo/AGENT.md`
    - `/Users/ben/github/benpeter/despicable-agents/minions/*/AGENT.md` (23 minion agents)

    **Read the positioning strategy for tone**: `/Users/ben/github/benpeter/despicable-agents/nefario/scratch/rethink-docs-product-marketing-lens/positioning-strategy.md`

    **Do NOT**:
    - Invent capabilities -- only document what is in the AGENT.md files
    - Use marketing language -- this is a factual reference page
    - Link to RESEARCH.md files -- those are not user-facing
    - Include the full "Does NOT do" list -- abbreviate to 2-3 key boundaries

    **Write to**: `/Users/ben/github/benpeter/despicable-agents/docs/agent-catalog.md`
- **Deliverables**: `docs/agent-catalog.md`
- **Success criteria**: All 27 agents listed with accurate descriptions from AGENT.md. Each entry has name, description, model tier, example invocation, and key boundaries. Organized by group. Decision guide at top.

---

#### Task 4: Rewrite README.md

- **Agent**: product-marketing-minion
- **Model**: sonnet
- **Mode**: default
- **Blocked by**: Task 1 (positioning strategy), Task 2 (using-nefario.md must exist for linking), Task 3 (agent-catalog.md must exist for linking)
- **Approval gate**: no (the positioning strategy gate covers the messaging decisions; this is execution of that strategy)
- **Prompt**: |
    Rewrite README.md following the approved positioning strategy.

    **Read the positioning strategy**: `/Users/ben/github/benpeter/despicable-agents/nefario/scratch/rethink-docs-product-marketing-lens/positioning-strategy.md`

    **Structure (in this order)**:

    1. **Title + badge + one-line value proposition**. The 97% Vibe_Coded badge stays. The one-line description leads with user benefit. Use the value proposition from the positioning strategy.

    2. **Examples showing value**. Restructure the current "What you get" examples:
       - Lead with concept, then illustrate. "Single-domain work goes to the specialist. Multi-domain work goes to /nefario."
       - Show 2-3 examples max (not 5). Lead with universally relatable ones (security review, debugging), not domain-specific ones (A2A/MCP).
       - Make /nefario the climax example, separated and highlighted.
       - Label the code block: "In any Claude Code session:" so readers know where to type.

    3. **Install**. Keep the current install section. Add a one-line prerequisite: "Requires [Claude Code](https://docs.anthropic.com/en/docs/claude-code)."

    4. **Try it**. Bridge from install to first use (15-20 lines max). Show one single-agent example and one nefario example with brief explanation of what happens. Include: "Agents are invoked with `@name`. The `/nefario` skill coordinates multiple agents for complex tasks." This section replaces the gap between install and roster.

    5. **How It Works**. Brief (5-7 lines). The four-tier concept in scannable form. Governance presented as a benefit ("every plan is reviewed for intent alignment and over-engineering before execution"), not as a tier the user must learn. Link to docs/using-nefario.md for the full orchestration guide.

    6. **Agent Roster**. Use a collapsible `<details>` element with summary "See all 27 agents". Inside: the current group table (same format) with agent names linking to `docs/agent-catalog.md#agent-name` sections. Outside the collapsible: a compact group summary (7 groups with agent counts).

    7. **Documentation**. Two subsections:
       - "Using the agents:" links to docs/using-nefario.md and docs/agent-catalog.md
       - "Contributing and extending:" links to docs/architecture.md and docs/decisions.md

    8. **Current Limitations**. Brief, honest section (4-6 lines). Include the limitations from the positioning strategy. This builds trust.

    9. **Contributing**. Keep concise. Same content as current.

    10. **License**. Same as current.

    **Hard constraints**:
    - Target 100-130 lines total (current is 92 lines -- this allows modest growth from new sections)
    - No superlatives, no hype, no marketing adjectives
    - Every claim verifiable by reading the codebase
    - Tone: senior engineer describing their architecture to another senior engineer
    - All links to docs/ pages must use relative paths
    - Keep the Despicable Me naming -- it is charming and distinctive

    **Read the current README**: `/Users/ben/github/benpeter/despicable-agents/README.md`
    **Verify these docs exist before linking**: `docs/using-nefario.md`, `docs/agent-catalog.md`

    **Do NOT**:
    - Include a competitor comparison table
    - Write more than 130 lines
    - Change the install commands
    - Remove the 97% Vibe_Coded badge
    - Link to docs that do not exist

    **Write to**: `/Users/ben/github/benpeter/despicable-agents/README.md`
- **Deliverables**: Updated `README.md`
- **Success criteria**: Follows positioning strategy messaging hierarchy. Value proposition leads. Examples are concept-first. "Try it" section bridges install to first use. Roster is collapsible. Length is 100-130 lines. No superlatives.

---

#### Task 5: Write Phase 8 marketing lens specification

- **Agent**: product-marketing-minion
- **Model**: sonnet
- **Mode**: default
- **Blocked by**: Task 1 (positioning strategy, triage categories)
- **Approval gate**: yes (Gate 2 -- this permanently changes nefario's behavior for all future orchestrations)
- **Gate reason**: The Phase 8 marketing lens becomes a permanent part of nefario's orchestration process. Getting the triage criteria wrong means every future documentation phase applies bad judgment. Hard to reverse (embedded in SKILL.md), high blast radius (affects all future orchestrations).
- **Prompt**: |
    Write the updated Phase 8 sub-step 8b specification for nefario's SKILL.md. This adds a marketing lens with explicit triage instructions to the documentation phase.

    **Context**: Currently, SKILL.md Phase 8 sub-step 8b says: "if checklist includes README or user-facing docs, spawn product-marketing-minion to review. Otherwise skip." This is too vague. The update adds a three-tier triage framework so product-marketing-minion knows exactly how to classify and act on each change.

    **The three tiers** (merged from product-marketing-minion and ux-strategy-minion planning input):

    Tier 1 -- Headline Feature (prominent placement):
    - The change introduces a new capability (user can do something they could not before)
    - AND it strengthens a core differentiator (orchestration, governance, specialist depth, install-once model)
    - OR it changes the user's mental model (how they think about the system)
    - Action: Recommend specific README changes with proposed copy. Flag if core positioning needs update.

    Tier 2 -- Notable Enhancement (mentioned in context):
    - The change improves an existing capability in a user-visible way
    - OR it removes a friction point in the getting-started or daily-use journey
    - OR it is a breaking change (always Tier 2 minimum)
    - Action: Recommend where to mention in existing docs. Include in release notes.

    Tier 3 -- Document Only (no promotional treatment):
    - Internal improvement, bug fix, refactor, or maintenance item
    - User's experience is unchanged
    - Action: Confirm documentation coverage is sufficient. No README or positioning changes.

    **Decision criteria** (evaluated in order):
    1. Does this change what the project can do? (new capability = Tier 1 candidate)
    2. Would a user notice this during normal usage? (yes = Tier 2 minimum; no = Tier 3)
    3. Does this strengthen a core differentiator? (if yes, consider promoting one tier)
    4. Does this change the user's mental model? (if yes = Tier 1)
    5. Is this a breaking change? (always Tier 2 minimum for migration guide)

    **Write the replacement text for SKILL.md Phase 8, step 4** (sub-step 8b). The replacement should:
    - Keep the same trigger condition (checklist includes README or user-facing docs)
    - Add the triage framework as instructions to product-marketing-minion
    - Specify what product-marketing-minion receives (checklist, execution summary, current README)
    - Specify what product-marketing-minion returns (tier classification for each change, recommendations per tier)
    - Keep it concise -- this goes in a SKILL.md instruction block, not a strategy document

    **Read the current SKILL.md Phase 8**: `/Users/ben/github/benpeter/despicable-agents/skills/nefario/SKILL.md` (lines 658-688)
    **Read the positioning strategy for tier definitions**: `/Users/ben/github/benpeter/despicable-agents/nefario/scratch/rethink-docs-product-marketing-lens/positioning-strategy.md`

    **Do NOT**:
    - Rewrite any part of SKILL.md outside of Phase 8 step 4 (sub-step 8b)
    - Change the trigger conditions for Phase 8
    - Change sub-step 8a (software-docs-minion + user-docs-minion)
    - Make the marketing lens blocking (it should remain non-blocking)
    - Add a new phase or sub-step

    **Write output to**: `/Users/ben/github/benpeter/despicable-agents/nefario/scratch/rethink-docs-product-marketing-lens/phase8-marketing-lens-spec.md`

    The output should contain:
    1. The exact replacement text for SKILL.md Phase 8 step 4
    2. A brief rationale for each tier definition (for the approval gate review)
- **Deliverables**: `nefario/scratch/rethink-docs-product-marketing-lens/phase8-marketing-lens-spec.md`
- **Success criteria**: Three-tier framework with clear decision criteria. Replacement text is drop-in ready for SKILL.md. Marketing lens is non-blocking. Instructions to product-marketing-minion are specific enough for consistent judgment.

---

#### Task 6: Update existing docs and cross-link verification

- **Agent**: software-docs-minion
- **Model**: sonnet
- **Mode**: default
- **Blocked by**: Task 2 (using-nefario.md), Task 3 (agent-catalog.md), Task 4 (README)
- **Approval gate**: no
- **Prompt**: |
    Update existing docs to reflect the new documentation structure and verify all cross-links.

    **Part A: Trim orchestration.md**
    - Read `/Users/ben/github/benpeter/despicable-agents/docs/orchestration.md`
    - Remove Section 1 ("Using Nefario", lines 9-103) which has been extracted to using-nefario.md
    - Add a redirect note at the top (after the back-link): "For the user-facing orchestration guide, see [Using Nefario](using-nefario.md)."
    - Renumber remaining sections (Section 2 becomes Section 1, etc.)
    - Update the introductory paragraph to reflect that this document now covers the architecture, not the usage guide
    - Keep the back-link to architecture.md

    **Part B: Update architecture.md**
    - Read `/Users/ben/github/benpeter/despicable-agents/docs/architecture.md`
    - Add a redirect note after the first paragraph: "New to the project? See [Using Nefario](using-nefario.md) for how to use the orchestrator, or [Agent Catalog](agent-catalog.md) for per-agent reference."
    - Update the Sub-Documents table to include using-nefario.md and agent-catalog.md as user-facing docs
    - Remove the Agent Groups table (this content now lives in agent-catalog.md) -- replace with a one-line reference: "For per-agent details, see [Agent Catalog](agent-catalog.md)."
    - Keep: Design Philosophy, System Context diagram, Three-Tier Hierarchy diagram, Cross-Cutting Concerns, Sub-Documents table

    **Part C: Archive stale docs**
    - Move `/Users/ben/github/benpeter/despicable-agents/docs/overlay-implementation-summary.md` to `/Users/ben/github/benpeter/despicable-agents/docs/history/overlay-implementation-summary.md`
    - Move `/Users/ben/github/benpeter/despicable-agents/docs/validation-verification-report.md` to `/Users/ben/github/benpeter/despicable-agents/docs/history/validation-verification-report.md`
    - Check if architecture.md Sub-Documents table references either file and update/remove those references

    **Part D: Cross-link verification**
    After completing Parts A-C, verify all cross-links:
    - README links to docs/ pages all resolve (check using-nefario.md, agent-catalog.md, architecture.md, decisions.md exist)
    - User-facing docs (using-nefario.md, agent-catalog.md) link back to README
    - User-facing docs do NOT link into contributor internals (build-pipeline.md, commit-workflow.md, etc.)
    - Contributor docs (architecture.md, orchestration.md) link to each other correctly
    - No broken links from heading changes
    - Report any broken links found

    **Do NOT**:
    - Modify README.md (Task 4 handles that)
    - Modify using-nefario.md or agent-catalog.md (Tasks 2 and 3 handle those)
    - Modify SKILL.md
    - Change the content of contributor-only docs (build-pipeline.md, decisions.md, etc.) beyond link fixes
    - Delete any docs that are not explicitly listed for archival
- **Deliverables**: Updated `docs/orchestration.md`, updated `docs/architecture.md`, archived stale docs, cross-link verification report
- **Success criteria**: orchestration.md no longer contains Section 1. architecture.md redirects users to new pages. Stale docs archived. All cross-links verified working.

---

#### Task 7: Apply Phase 8 marketing lens to SKILL.md

- **Agent**: software-docs-minion
- **Model**: sonnet
- **Mode**: default
- **Blocked by**: Task 5 (Phase 8 spec must be approved at Gate 2 first)
- **Approval gate**: no
- **Prompt**: |
    Apply the approved Phase 8 marketing lens specification to SKILL.md.

    **Read the approved spec**: `/Users/ben/github/benpeter/despicable-agents/nefario/scratch/rethink-docs-product-marketing-lens/phase8-marketing-lens-spec.md`

    **Read the current SKILL.md**: `/Users/ben/github/benpeter/despicable-agents/skills/nefario/SKILL.md`

    **What to do**: Replace SKILL.md Phase 8 step 4 (sub-step 8b, currently lines 682-683) with the replacement text from the approved spec. This is a surgical edit -- change only the sub-step 8b content.

    **Verify after editing**:
    - The surrounding Phase 8 structure (steps 1-3, step 5-6) is unchanged
    - The new sub-step 8b text is properly indented and formatted to match the rest of SKILL.md
    - The trigger condition still references "checklist includes README or user-facing docs"

    **Do NOT**:
    - Change any other part of SKILL.md
    - Change Phase 8 steps 1-3, 5, or 6
    - Add new phases or sub-steps
    - Change formatting conventions used elsewhere in SKILL.md

    **Write to**: `/Users/ben/github/benpeter/despicable-agents/skills/nefario/SKILL.md` (edit in place)
- **Deliverables**: Updated `skills/nefario/SKILL.md` with new Phase 8 sub-step 8b
- **Success criteria**: Only sub-step 8b changed. Triage framework present in the instruction text. Rest of SKILL.md unchanged.

---

### Cross-Cutting Coverage

1. **Testing**: Not applicable. This is a docs-only task with no executable code output. The SKILL.md change is a prompt instruction update, not code.

2. **Security**: Not applicable. No attack surface, authentication, user input handling, secrets, or dependency changes. Documentation changes only.

3. **Usability -- Strategy**: Covered. ux-strategy-minion contributed to planning (Phase 2). Their recommendations on adoption-first ordering, progressive disclosure, and roster redesign are incorporated into the README structure (Task 4) and the Phase 8 triage criteria (Task 5). No separate execution task needed -- their input shapes the prompts.

4. **Usability -- Design**: Not applicable. No user-facing interfaces are produced. This is documentation (Markdown files), not UI.

5. **Documentation**: This IS the documentation task. software-docs-minion (Tasks 2, 3, 6, 7) and product-marketing-minion (Tasks 1, 4, 5) are the primary executors.

6. **Observability**: Not applicable. No runtime components, services, or APIs produced.

### Architecture Review Agents

- **Always**: security-minion, test-minion, ux-strategy-minion, software-docs-minion, lucy, margo
- **Conditional**: none triggered (no UI components, no web-facing runtime, no multi-service runtime)

Note: For this docs-only task, the ALWAYS reviewers will primarily verify that the plan does not introduce scope creep (margo), stays aligned with human intent (lucy), maintains documentation quality standards (software-docs-minion), and does not inadvertently affect UX coherence (ux-strategy-minion). security-minion and test-minion will likely APPROVE quickly as there is no code or attack surface.

---

### Execution Order

```
Batch 1 (parallel):
  Task 1: Positioning strategy document [product-marketing-minion]
  ── GATE 1: Positioning strategy approval ──

Batch 2 (parallel, after Gate 1 clears):
  Task 2: Create docs/using-nefario.md [software-docs-minion]
  Task 3: Create docs/agent-catalog.md [software-docs-minion]
  Task 5: Write Phase 8 marketing lens spec [product-marketing-minion]
  ── GATE 2: Phase 8 marketing lens approval ──

Batch 3 (after Tasks 2, 3 complete):
  Task 4: Rewrite README.md [product-marketing-minion]

Batch 4 (parallel, after Tasks 4 complete + Gate 2 clears):
  Task 6: Update existing docs + cross-link verification [software-docs-minion]
  Task 7: Apply Phase 8 spec to SKILL.md [software-docs-minion]
```

Gate 1 blocks Batch 2 entirely (messaging foundation).
Gate 2 blocks only Task 7 (SKILL.md edit). Tasks 2, 3, 4, 6 can proceed independently of Gate 2.
Task 4 requires Tasks 2 and 3 to be complete (needs to verify links exist).
Task 6 requires Task 4 to be complete (needs to verify README links).
Task 7 requires Gate 2 to clear (needs approved spec).

---

### Verification Steps

After all tasks complete:

1. **Link integrity**: Open README.md and verify every `docs/` link resolves. Open each new doc (using-nefario.md, agent-catalog.md) and verify back-links to README work.

2. **Message consistency**: Verify the value proposition in README matches the positioning strategy. Verify tone across README, using-nefario.md, and agent-catalog.md is consistent (factual, no superlatives).

3. **Content coverage**: Verify README addresses all success criteria from the original task: value proposition leads, features are scannable, meta layers are surfaced, limitations are stated, getting-started path is obvious, technical docs reachable in 1-2 clicks.

4. **SKILL.md integrity**: Verify Phase 8 sub-step 8b is updated and the rest of SKILL.md is unchanged. Run a diff against the previous version to confirm surgical edit.

5. **No orphans**: Verify archived docs are in docs/history/. Verify no docs/ page links to the archived files.

6. **Line count**: Verify README is between 100-130 lines.
