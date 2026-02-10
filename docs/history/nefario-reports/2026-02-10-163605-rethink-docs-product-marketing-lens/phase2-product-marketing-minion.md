# Domain Plan Contribution: product-marketing-minion

## Recommendations

### (a) Core Value Proposition and Job-to-be-Done

**The struggle**: Developers using Claude Code hit a ceiling when tasks span multiple domains. A single AI session does not have deep security expertise AND frontend expertise AND API design expertise AND testing strategy. The result: shallow output, missed concerns, rework. The alternative -- manually prompting separate specialists and stitching results together -- is tedious and error-prone. And nobody reviews the plan before execution, so architectural mistakes get baked in.

**The job-to-be-done**: "When I have a complex development task that spans security, API design, testing, infrastructure, and documentation, I want to brief one orchestrator and get back a reviewed, coordinated plan executed by domain experts -- so I can focus on decisions, not coordination."

**Core value proposition (one sentence)**:

> **despicable-agents gives Claude Code a team of 27 domain specialists, an orchestrator that coordinates them, and a governance layer that reviews every plan before execution.**

This is the "only-factor": no other Claude Code agent collection has all three of orchestration + specialist depth + pre-execution governance. The competitive alternatives have one or two of these, never all three.

**Job types addressed**:
- **Functional**: Get complex multi-domain tasks done correctly the first time (orchestration + specialists)
- **Emotional**: Confidence that nothing is missed -- security, testing, accessibility, documentation are all reviewed before code ships (governance)
- **Social**: Running a professional, rigorous development operation (the architecture review phase signals engineering discipline)

### (b) 3-5 Supporting Messages (Unique Differentiators)

Each supporting message maps to a unique attribute that alternatives lack.

**1. "27 specialists, each with strict boundaries -- no overlapping, no gaps"**
- **Attribute**: Every agent has a "Does NOT do" section naming handoff targets. The delegation table maps every task type to exactly one primary agent.
- **Value**: You get security advice from a security specialist, not from a generalist who also does frontend. Each agent's knowledge base is dense and domain-specific, not spread thin.
- **Proof points**: 27 agents across 7 groups. Delegation table with 40+ task-type mappings. Boundary enforcement via "Does NOT do" sections in every agent prompt.
- **Competitive gap**: awesome-claude-code-subagents has 126 agents but no boundary enforcement -- they overlap freely. wshobson/agents has 112 agents organized into plugins but no deterministic routing table.

**2. "Nefario orchestrates a nine-phase process -- from planning through post-execution verification"**
- **Attribute**: Multi-phase orchestration with specialist planning consultation, plan synthesis, architecture review, execution, code review, test execution, deployment, and documentation.
- **Value**: Complex tasks are not just split and dispatched. Specialists contribute to the plan, conflicts are resolved before execution, cross-cutting concerns are verified, and post-execution quality gates catch implementation issues.
- **Proof points**: Nine documented phases. Specialist consultation happens in parallel. Synthesis resolves inter-specialist conflicts. Architecture review runs 6 mandatory reviewers before any code is written.
- **Competitive gap**: claude-flow uses swarm intelligence (emergent coordination) rather than structured phases. vanzan01/collective has hub-and-spoke but no pre-execution review phase. wshobson/agents has sequential orchestrators but no parallel specialist consultation or governance review.

**3. "Lucy and Margo review every plan -- governance is built in, not bolted on"**
- **Attribute**: Two governance agents (lucy for intent alignment and convention enforcement, margo for simplicity and YAGNI) review every plan in Phase 3.5, alongside security-minion, test-minion, ux-strategy-minion, and software-docs-minion.
- **Value**: Plans that drift from what you asked for are caught before execution. Over-engineering is flagged. Security gaps are identified. This is not optional review -- it is mandatory for every orchestration.
- **Proof points**: 6 mandatory reviewers in every Phase 3.5 Architecture Review. APPROVE/ADVISE/BLOCK verdict system. 2-round cap on BLOCK resolution before user escalation.
- **Competitive gap**: No other Claude Code agent collection has dedicated governance agents. Most have no pre-execution review at all.

**4. "Install once, use everywhere -- agents are generic specialists, not project-specific"**
- **Attribute**: Agents use `memory: user` (not project-scoped). They have deep domain expertise without ties to any specific codebase. Project context belongs in the project's CLAUDE.md.
- **Value**: One `./install.sh` and every Claude Code session across all your projects gets 27 specialists. No per-project configuration needed. Agents learn your patterns over time.
- **Proof points**: Symlink deployment means edits are immediately live. Apache 2.0 license. No PII, no proprietary data.
- **Competitive gap**: Several alternatives require per-project plugin installation or configuration. vanzan01/collective requires npm install per project.

**5. "Open source, auditable, forkable -- every agent prompt is readable Markdown"**
- **Attribute**: Each agent is a single AGENT.md file with YAML frontmatter and a readable system prompt. RESEARCH.md files show the research backing each prompt. Decision log documents every architectural tradeoff.
- **Value**: You can read exactly what each agent knows. You can fork, modify, and contribute. No black-box orchestration. Decisions are documented with rejected alternatives.
- **Proof points**: Apache 2.0. 25 documented design decisions with alternatives and rationale. the-plan.md as canonical spec. All files are Markdown.
- **Competitive gap**: Many alternatives have prompts embedded in code or generated from templates that are harder to audit. despicable-agents is "Markdown all the way down."

### (c) Messaging Hierarchy for the README

**Layer 1: Core positioning (first 5 seconds)**

The current README opening line is good but undersells the uniqueness:
> "27 specialist agents for Claude Code. Deep domain experts that work alone or as a coordinated team -- install once, use everywhere."

Recommended revision to lead with the job, not the feature count:
> "Give Claude Code a team of domain experts. 27 specialist agents with an orchestrator, governance layer, and nine-phase process that turns complex tasks into reviewed, coordinated plans."

Or shorter:
> "A specialist team for Claude Code. 27 agents, one orchestrator, built-in governance."

**Layer 2: Show the value (next 15 seconds)**

Keep the "What you get" code block -- it is the strongest element in the current README. It demonstrates value through concrete examples, not descriptions. However, refine the examples to show the *range* of value:

```
@gru Should we adopt A2A or double down on MCP?          # strategic decision
@security-minion Review this auth flow for vulnerabilities # specialist depth
@debugger-minion This function leaks memory under load     # single-agent expert
/nefario Build an MCP server with OAuth, tests, and docs   # orchestrated team
```

Add a one-line annotation after: "Single-domain work goes directly to the specialist. Multi-domain work goes to `/nefario`, which plans across specialists, runs governance review, and coordinates execution."

**Layer 3: How it works (next 30 seconds)**

The current "How It Works" section is a dense paragraph. Restructure as a visual progression:

```
You brief nefario --> Specialists contribute expertise --> Plan is synthesized -->
Governance reviews --> You approve --> Agents execute --> Code reviewed, tested, documented
```

This is the nine phases in one line. Then 2-3 sentences of explanation. The detailed orchestration docs are linked, not inlined.

**Layer 4: Agent roster (scanning reference)**

Keep the table but make it collapsible or move it below "How It Works." The table is overwhelming as the third section -- it should follow after the reader understands the system, not before. Consider grouping it under a `<details>` tag with "See all 27 agents" as the summary.

**Layer 5: Install, docs, contributing, license**

These are fine as-is. Install is already concise. Documentation links are well-organized.

**Information priority (top to bottom)**:
1. One-line positioning (what + who + differentiator)
2. Code examples showing value (what you can do)
3. How it works (visual progression + brief explanation)
4. Install (two commands)
5. Agent roster (collapsible table)
6. Documentation links
7. Contributing, license

This reverses the current order, which has the agent roster above "How It Works." The roster is reference material; the process explanation is persuasion material.

### (d) Competitive Alternatives and Positioning Against Them

**Competitive landscape analysis**:

| Alternative | What it is | Strengths | Weaknesses (our differentiator) |
|---|---|---|---|
| **Do nothing / single Claude Code session** | Use Claude Code as-is, one session, one context | Zero setup. Good for simple, single-domain tasks. | No specialist depth. No cross-domain coordination. No pre-execution review. Complex tasks get shallow treatment. |
| **Write your own agent prompts** | Developer writes custom AGENT.md files per project | Total control. Project-specific. | Time-consuming. No orchestration. No governance. No boundary enforcement. Reinventing the wheel per project. |
| **VoltAgent/awesome-claude-code-subagents** (126 agents) | Curated collection with meta-orchestration agents | Large catalog. Good category coverage. | No strict boundaries (agents can overlap). No governance layer. No mandatory pre-execution review. Orchestration is separate meta-agents, not an integrated process. |
| **wshobson/agents** (112 agents, 73 plugins) | Plugin-based system with model-tiered orchestrators | Granular plugin loading (token efficiency). Progressive disclosure. | Sequential orchestration (not parallel specialist consultation). No governance agents. No architecture review phase. Plugin granularity adds configuration complexity. |
| **vanzan01/claude-code-sub-agent-collective** (30+ agents) | TDD-enforced hub-and-spoke with npm install | Mandatory TDD enforcement. Context engineering focus. | Fewer specialists (30 vs. 27 deep ones). Project-specific npm install. No governance layer. No multi-phase planning process. |
| **ruvnet/claude-flow** | Framework with swarm intelligence and MCP | Distributed swarm architecture. Enterprise features. | Framework, not specialist team. Emergent coordination, not structured phases. Requires more setup. |

**Positioning strategy**: Big-fish-small-pond.

despicable-agents does not compete on agent count (VoltAgent has 126, wshobson has 112). It competes on coordination quality. The positioning should be:

> "Other collections give you more agents. We give you a team."

The differentiator is not "27 agents" -- it is "27 agents + orchestrator + governance + nine-phase process." The number 27 is a supporting detail, not the headline.

Specifically, position on the three-pillar differentiator:
1. **Structured orchestration** (nine phases, parallel specialist consultation, plan synthesis) vs. sequential dispatch or emergent swarms
2. **Built-in governance** (lucy + margo + mandatory architecture review) vs. no review or optional review
3. **Strict boundaries with deterministic routing** (delegation table, "Does NOT do" sections) vs. overlapping catalogs

**Honest comparison stance**: The README should NOT include a comparison table. That would be too aggressive for OSS. Instead, position through specificity: describe what despicable-agents does in enough detail that the reader can infer the comparison themselves. "Governance agents review every plan before execution" implicitly says "alternatives do not do this" without saying it.

If a comparison page is desired, put it in `docs/` (not README), and follow the honest-comparison principle: acknowledge that alternatives with 100+ agents offer broader coverage, that swarm-based approaches offer more flexibility, and that per-project install gives more customization. Then show where despicable-agents is strongest: coordination quality, review rigor, and specialist depth.

### (e) Right Tone for OSS GitHub

**The line between compelling and overselling**:

- DO: State specific facts. "6 mandatory reviewers check every plan before execution." This is verifiable by reading the code.
- DO: Show, don't tell. The code example block is the strongest element -- it proves value without claiming it.
- DO: Use the project's own vernacular. The Despicable Me naming (gru, nefario, minions, lucy, margo) is charming and memorable. Lean into it -- it makes the project distinctive and human.
- DO: Let the architecture speak. The nine-phase process, the governance layer, the 25 documented design decisions -- these are impressive on their own. State them plainly.
- DO NOT: Use superlatives. "Best," "most powerful," "comprehensive" are red flags for developers.
- DO NOT: Use marketing adjectives without proof. "Blazingly fast orchestration" with no benchmarks is worse than saying nothing.
- DO NOT: Oversell scale. "27 agents" is strong enough. Don't inflate it to "massive specialist team."
- DO NOT: Claim to be the only option. "Unlike any other agent framework" is unverifiable and sounds defensive.
- DO NOT: Use urgency or hype language. "Revolutionary," "game-changing," "next-generation" -- all toxic for developer audiences.

**Tone model**: Write like a senior engineer describing their team's architecture to another senior engineer. Specific, factual, slightly proud, willing to acknowledge tradeoffs. The design decisions document (with its rejected alternatives and honest consequences) is the ideal tone model -- extend that tone to the README.

**The badge** (97% Vibe_Coded) already establishes the right tone: self-aware, slightly irreverent, honest about how the project was built. This is good. Keep it.

**Specific language preferences**:
- "specialists" over "AI agents" (more concrete)
- "orchestrator" over "coordinator" or "workflow engine" (more precise)
- "governance" over "quality assurance" or "review layer" (more authoritative)
- "nine-phase process" over "pipeline" or "workflow" (more specific)
- "install once, use everywhere" over "cross-project compatible" (more concrete)

### (f) Phase 8 Marketing Lens Triage Categories

Phase 8 currently has product-marketing-minion in sub-step 8b, triggered when the documentation checklist includes README or user-facing documentation. This is the right trigger, but the instruction to the agent is too vague: "product-marketing-minion reviews README and user-facing docs."

**Recommended triage structure for the marketing lens**:

The Phase 8 marketing lens should classify each user-visible change into one of three tiers, based on the change's impact on the project's positioning and the user's perception of value:

**Tier 1: Headline Feature (prominent placement)**
- Criteria: The change introduces a new capability that (a) directly addresses the project's core job-to-be-done, AND (b) differentiates from competitive alternatives, AND (c) is visible to the user without digging into docs.
- Action: Update README "What you get" section or "How It Works." Add to release notes lead paragraph. Consider whether it changes the core positioning statement.
- Examples: New governance agent, new orchestration phase, new agent group.

**Tier 2: Notable Enhancement (mentioned in context)**
- Criteria: The change improves an existing capability in a way that (a) a user would notice during normal usage, OR (b) addresses a known pain point, BUT (c) does not change what the project fundamentally does.
- Action: Mention in relevant docs section. Include in release notes body. Update agent roster table if applicable. No README structural change needed.
- Examples: New minion in existing group, improved orchestration step, new cross-cutting reviewer trigger, better error handling in a phase.

**Tier 3: Documented Only (no promotional treatment)**
- Criteria: The change is (a) an internal improvement that users do not directly interact with, OR (b) a bug fix or maintenance item, OR (c) a refactor with no user-visible behavior change.
- Action: Document in changelog. Update technical docs (architecture, build pipeline, decisions). No README or positioning changes.
- Examples: Build pipeline enhancement, overlay system improvement, hook script fix, RESEARCH.md update, internal documentation restructure.

**Decision criteria for triage** (in order of evaluation):

1. **Does this change what the project can do?** (new capability = Tier 1 candidate)
2. **Would a user notice this during normal usage?** (yes = Tier 2 minimum; no = Tier 3)
3. **Does this strengthen a core differentiator?** (orchestration, governance, specialist depth, or install-once model -- if yes, consider promoting one tier)
4. **Does this affect the competitive positioning?** (new capability that no alternative has = Tier 1; catching up to alternatives = Tier 2)
5. **Is this a breaking change?** (always Tier 2 minimum for migration guide requirements)

**Integration into SKILL.md Phase 8**:

Sub-step 8b should be updated to give product-marketing-minion explicit triage instructions:

```
## Sub-step 8b: Marketing Lens Review (conditional)

Trigger: Phase 8 checklist includes README review, new project README, or user-facing documentation.

Spawn product-marketing-minion with:
- The Phase 8 checklist
- The execution summary (what changed, why)
- Current README.md
- Instructions to:
  1. Classify each user-visible change as Tier 1 (Headline), Tier 2 (Notable), or Tier 3 (Document-only)
  2. For Tier 1 items: recommend specific README/messaging changes with proposed copy
  3. For Tier 2 items: recommend where to mention in existing docs
  4. For Tier 3 items: confirm documentation coverage is sufficient
  5. Flag if any change shifts the project's competitive positioning
```

This keeps the marketing lens lightweight (classification + recommendation, not rewriting) while ensuring that significant changes are not buried in technical docs when they deserve prominence.

## Proposed Tasks

### Task 1: Positioning Strategy and Messaging Hierarchy Document

**What to do**: Produce a positioning document that becomes the source of truth for all documentation writing. Contains: competitive alternatives analysis, core value proposition, 5 supporting messages with proof points, messaging hierarchy (what goes where in README and docs), tone guide, and the Phase 8 triage framework.

**Deliverables**: `nefario/scratch/rethink-docs-product-marketing-lens/positioning-strategy.md`

**Dependencies**: None (this is the foundation). All other writing tasks depend on this.

**Notes**: This task's output is the approval gate deliverable. No documentation writing should begin until the positioning strategy is approved.

### Task 2: README Rewrite

**What to do**: Rewrite README.md following the approved positioning strategy and messaging hierarchy. Lead with the core value proposition. Keep the code examples block (refined). Restructure information order per the hierarchy. Make agent roster collapsible. Keep install section concise.

**Deliverables**: Updated `README.md`

**Dependencies**: Task 1 (positioning strategy must be approved first)

**Notes**: This is the highest-impact deliverable. The README is the project's primary marketing document.

### Task 3: Phase 8 Marketing Lens Specification

**What to do**: Add the three-tier triage framework and updated sub-step 8b instructions to SKILL.md Phase 8. Ensure the trigger conditions are clear and the product-marketing-minion prompt includes triage criteria.

**Deliverables**: Updated section in `skills/nefario/SKILL.md` (Phase 8 section only)

**Dependencies**: Task 1 (triage categories must be agreed), Task 2 (README structure must be established as the reference for "what Tier 1 changes update")

**Notes**: This is the second outcome of the project -- making the marketing lens permanent. It should be a small, focused change to SKILL.md, not a large refactor.

### Task 4: Docs Restructure and Cross-Linking

**What to do**: Restructure docs/ navigation to serve two audiences (users and contributors). Update cross-links between README and docs. Ensure docs/orchestration.md Section 1 ("Using Nefario") is accessible as a standalone getting-started reference. Align tone and messaging with the positioning strategy.

**Deliverables**: Updated docs files (scope determined by software-docs-minion and ux-strategy-minion recommendations)

**Dependencies**: Task 1 (positioning strategy), Task 2 (README, since docs must align with README messaging)

**Notes**: This task's scope will be shaped by software-docs-minion's information architecture recommendations. product-marketing-minion's role here is reviewing for messaging consistency, not writing technical docs.

## Risks and Concerns

### Risk 1: Over-marketing an OSS project

**Risk**: Applying product marketing frameworks to an open-source project could produce copy that feels corporate or salesy, alienating the developer audience.

**Mitigation**: The tone guide in the positioning strategy explicitly constrains language. Every claim must be verifiable by reading the codebase. The "senior engineer describing their architecture" tone model provides a clear standard. Review the final README against this standard.

### Risk 2: Positioning claims that cannot be maintained

**Risk**: Claiming "no other collection has governance + orchestration + specialist depth" is true today but may not be true in 6 months. Positioning that depends on competitors NOT doing something is fragile.

**Mitigation**: Position on what the project IS, not on what competitors are NOT. "Built-in governance" is a statement about this project. "No other collection has governance" is a comparative claim that goes stale. The supporting messages should be self-contained facts, not comparative assertions.

### Risk 3: README restructure breaks existing links

**Risk**: Moving sections, making the roster collapsible, or changing headings could break inbound links from other docs, blog posts, or bookmarks.

**Mitigation**: Audit existing cross-references before restructuring. Maintain heading anchors where possible. If headings change, add HTML anchor tags for backward compatibility.

### Risk 4: Phase 8 marketing lens adds noise to small changes

**Risk**: Running product-marketing-minion on every documentation update (even trivial ones) adds cost and complexity without value.

**Mitigation**: The trigger is already conditional (only when checklist includes README or user-facing docs). The triage framework adds a further filter: Tier 3 items require only a "documentation coverage is sufficient" confirmation, which is a fast pass-through. The marketing lens adds judgment, not workload.

### Risk 5: Triage categories become stale

**Risk**: The Tier 1/2/3 definitions are based on the current competitive landscape and project scope. As the project evolves, what constitutes a "headline feature" may shift.

**Mitigation**: Triage criteria should be reviewed when the competitive landscape shifts or when the project's core differentiators change (e.g., if orchestration is no longer unique). The positioning strategy document should be treated as a living document, not a one-time artifact.

## Additional Agents Needed

None. The four-agent planning team (product-marketing-minion, software-docs-minion, ux-strategy-minion, devx-minion) covers the full scope:

- Positioning and messaging: product-marketing-minion (this contribution)
- Information architecture: software-docs-minion
- User journey and cognitive load: ux-strategy-minion
- Developer onboarding path: devx-minion

user-docs-minion is not needed for planning because the documentation being produced is primarily README and architecture-level docs (software-docs-minion's domain), not tutorials or how-to guides (user-docs-minion's domain). If the plan evolves to include a standalone quickstart guide, user-docs-minion should be brought in at execution time for that specific task.
