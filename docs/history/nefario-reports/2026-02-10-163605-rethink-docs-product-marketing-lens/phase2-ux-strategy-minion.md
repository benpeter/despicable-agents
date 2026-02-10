# Domain Plan Contribution: ux-strategy-minion

## Recommendations

### (a) Where a new developer gets stuck today

I walked through the README and docs as a first-time visitor. The journey has five friction points, ordered by severity:

**Friction 1 (Major): The roster table creates a wall before communicating why it matters.**
The 27-row agent table at line 33-63 of README.md is the single largest element on the page. A developer scanning top-to-bottom hits "What you get" (5 code examples -- good), then "Install" (3 lines -- good), then immediately a 30-row table of names they have no context for. The table answers "what agents exist?" but nobody is asking that question yet. They are asking "what can I do with this?" and "is this worth my time?" The table triggers satisficing behavior in the wrong direction: scan, feel overwhelmed, leave.

**Friction 2 (Major): No path from install to first success.**
After `git clone && ./install.sh`, what does the developer do? The README gives five example invocations in "What you get" but they appear *before* the install section. A developer who has just installed the tool must scroll back up or mentally note those examples. There is no "try this now" moment after install. The JTBD gap: the developer hired this project for "make my Claude Code sessions smarter" but there is no moment where they experience that outcome.

**Friction 3 (Moderate): The "How It Works" paragraph is a single dense block.**
Lines 66-68 pack four tiers, nine phases, and six named concepts (meta-planning, synthesis, architecture review, etc.) into one paragraph. This violates recognition-over-recall: the reader must hold all these concepts simultaneously. No visual structure helps them chunk the information. After reading it, most developers will remember "it's complicated" rather than any specific detail.

**Friction 4 (Moderate): The documentation section is a flat list of six links with no guidance.**
Lines 74-79 list six docs with brief descriptions. A new developer does not know which one to read. Should they start with Architecture Overview? Agent Anatomy? Orchestration? The links are organized by topic, not by task or journey stage. There is no "start here" signal.

**Friction 5 (Minor): The "What you get" examples mix tiers without explanation.**
The five examples span @gru, @security-minion, @debugger-minion, @frontend-minion, and /nefario. The reader sees two invocation syntaxes (@ and /) without understanding why they differ. The last example (/nefario) is qualitatively different from the others (orchestration vs. single-agent), but nothing signals that difference until the "How It Works" section 40 lines later.

### (b) Does the 27-agent roster table overwhelm?

Yes. The table is the single biggest cognitive load problem in the README. Applying Hick's Law: 27 items means log2(27) = ~4.75 units of decision complexity. But the user is not even making a decision -- they are trying to understand the product. The table forces them to process 27 unfamiliar names before they have a mental model for what those names mean.

The Kano analysis is telling: the table is an **indifferent feature** for first-time visitors (does not affect their satisfaction positively or negatively -- they skip it) and a **performance feature** for returning users (who want to look up a specific agent). Putting an indifferent/returning-user feature prominently in the first-visit experience is a structural error.

**Recommendation**: Replace the full roster table with a compact group summary (7 groups, not 27 agents) in the README body. The group summary communicates breadth without granularity overload. Move the full roster to a dedicated reference page or a collapsible details element. A developer who wants to know "do you have an agent for X?" can find it; a developer who wants to understand the product is not forced to wade through it.

### (c) How should "four tiers" be introduced?

The current approach (one paragraph at line 66) violates progressive disclosure: it reveals all complexity at once. The four-tier concept has two jobs to do:

1. **Mental model job**: Help the developer understand that this is not just 27 flat agents -- there is a hierarchy with distinct roles.
2. **Usage guidance job**: Help the developer know when to use @agent vs. /nefario vs. trust governance to work automatically.

These are different jobs at different moments in the journey. The mental model job belongs early (after value proposition, before details). The usage guidance job belongs at the point of action (after install, when they are deciding what to do).

**Recommendation**: Introduce tiers through progressive disclosure in three layers:

- **Layer 1 (README, inline)**: A visual or structural hint -- group the "What you get" examples by tier. Show @gru for strategy, @specialist for single-domain, /nefario for multi-domain. Three categories, not four -- governance is invisible to the user (they do not invoke lucy or margo directly), so introducing it at this layer adds complexity without utility.
- **Layer 2 (README, "How It Works")**: A brief structural explanation with a simple visual (not a Mermaid diagram -- those do not render in all contexts). Three to four sentences max. Mention governance here as "quality assurance that runs automatically."
- **Layer 3 (docs/architecture.md)**: The full hierarchy with the Mermaid diagram, all 27 agents, group descriptions, and cross-cutting concerns. This is where depth belongs.

Key insight: governance (lucy/margo) is a background process. Users do not interact with it directly. Foregrounding it in the README makes the system seem more complex than the user's actual experience. Mention it as a benefit ("every plan is reviewed for intent alignment and over-engineering"), not as a tier the user needs to understand.

### (d) Balance between sophistication and adoption

This is the central tension. The project IS sophisticated -- 27 agents, nine phases, governance layer, approval gates, overlay system. That sophistication is the product's genuine value. But sophistication communicated poorly reads as complexity, and complexity repels adoption.

The resolution comes from Don Norman's visibility principle: **make the sophisticated parts visible at the moment they become relevant, not before.**

**Adoption-first ordering:**
1. What can I do with this? (value -- 5 seconds)
2. How do I get it? (install -- 15 seconds)
3. What do I do first? (first command -- 30 seconds)
4. How does it work? (mental model -- 2 minutes)
5. How sophisticated is it? (depth -- 5+ minutes, self-directed)

The current README jumps from step 2 to step 5 (the roster table and dense "How It Works" paragraph). Steps 3 and 4 are missing or misplaced.

**Recommendation**: Restructure the README to follow this adoption-first ordering. The sophistication content (full roster, nine-phase detail, cross-cutting concerns) belongs in docs/, not README. The README should make the reader feel "I can use this in 2 minutes" -- not "I need to understand 27 agents and nine phases before I start."

The "showing sophistication builds trust" argument is valid but secondary. Trust is built by *experiencing* sophistication, not by reading about it. A developer who runs `/nefario Build an MCP server with tests` and gets a well-structured, reviewed result trusts the system. A developer who reads about nine phases before trying anything does not -- they just feel the barrier to entry is high.

### (e) Phase 8 marketing lens: "headline-worthy" criteria from a UX perspective

The question is: when nefario's Phase 8 produces documentation, how should it judge which changes deserve prominent visibility (README, changelog) versus quiet documentation?

From a UX impact perspective, "headline-worthy" means the change materially alters what the user can do or how they experience the product. Here are five criteria, ordered by impact:

1. **New capability**: The user can now do something they could not do before. A new agent, a new invocation pattern, a new integration. This always affects the value proposition and deserves README/changelog prominence.

2. **Removed friction**: A pain point in the getting-started or daily-use journey is eliminated. Faster install, simpler invocation, better error messages. This affects adoption and retention -- mention in README if it changes the getting-started path, changelog otherwise.

3. **Changed mental model**: The user needs to think about the system differently. A tier is added or removed, the orchestration phases change, governance behavior changes. This requires updating conceptual documentation (README "How It Works", architecture.md) because the user's existing understanding is now wrong.

4. **Changed defaults or behavior**: Something the user relied on now works differently. A phase that was optional is now mandatory, a gate threshold changed, an agent's scope expanded or contracted. This is changelog-mandatory and may warrant README mention if it affects first-run experience.

5. **Internal improvement only**: Better code quality, refactored internals, updated RESEARCH.md. The user's experience is unchanged. Document in commit messages and technical docs only. Never headline.

The triage rule for Phase 8: **If the change alters the user's journey (what they do, what they see, what they need to understand), it is headline-worthy. If the change is invisible to the user's experience, it is not.**

This maps cleanly to a three-bucket system:
- **README-worthy**: Criteria 1 and 3 (new capabilities, changed mental models)
- **Changelog/docs-worthy**: Criteria 2 and 4 (friction removal, behavior changes)
- **Silent**: Criterion 5 (internal-only improvements)

## Proposed Tasks

### Task 1: Restructure README information hierarchy

**What to do**: Rewrite README.md to follow the adoption-first ordering: value proposition -> install -> first command -> mental model -> depth pointers. Replace the 27-agent roster table with a compact group summary. Add a "Try it" section immediately after install. Simplify the "How It Works" section into scannable chunks with progressive disclosure.

**Deliverables**:
- Rewritten README.md with new section ordering and content
- The full 27-agent roster either in a collapsible details element or moved to a reference page

**Dependencies**: Depends on product-marketing-minion's positioning strategy (what the value proposition says) and software-docs-minion's information architecture (where depth content lives). This task should execute after those strategies are agreed upon at the approval gate.

### Task 2: Create a progressive disclosure path from README to docs

**What to do**: Restructure the README's documentation links section from a flat list into a task-oriented navigation. Separate "getting started" content from "reference" content. Add a clear "start here" signal. Ensure the path from README -> first success takes no more than two clicks.

**Deliverables**:
- Revised documentation links section in README.md
- If software-docs-minion recommends a quickstart page: outline its structure and key sections from a journey perspective (what the user needs to know at each step, what to defer)

**Dependencies**: Depends on software-docs-minion's information architecture plan (what pages exist and how they are organized).

### Task 3: Simplify the "How It Works" section

**What to do**: Break the single dense paragraph into a scannable structure. Introduce the four tiers progressively: specialist -> orchestrator -> governance (as background benefit, not a tier to learn) -> strategic advisor. Use the three-layer progressive disclosure model from recommendation (c). Remove or defer the nine-phase enumeration -- it belongs in docs/orchestration.md, not README.

**Deliverables**:
- Rewritten "How It Works" section in README.md
- Clear cross-link to docs/orchestration.md for phase details

**Dependencies**: Same as Task 1. Part of the README rewrite, but called out separately because it requires specific structural decisions about progressive disclosure depth.

### Task 4: Define Phase 8 "headline-worthy" triage criteria

**What to do**: Write a concise set of triage criteria for nefario's Phase 8 documentation step that applies a UX-impact lens. The criteria should be embeddable in SKILL.md instructions -- brief enough that nefario can apply them without spawning a separate agent, but specific enough to produce consistent judgments.

**Deliverables**:
- Triage criteria specification (the five-criterion model from recommendation (e), condensed to operational rules)
- Recommended insertion point and wording for SKILL.md Phase 8 instructions

**Dependencies**: Depends on product-marketing-minion's triage framework (which may have its own categories). The UX criteria should complement, not duplicate, the marketing criteria. Merge point needed.

### Task 5: Audit docs/orchestration.md Section 1 for user journey coherence

**What to do**: Review the "Using Nefario" section (lines 1-103 of orchestration.md) through the lens of a developer who just installed the agents and wants to try /nefario for the first time. Identify where the section assumes knowledge the reader does not have, where examples could be more concrete, and where the "Tips for Success" could be reframed as a decision framework rather than advice.

**Deliverables**:
- Annotated friction log for orchestration.md Section 1
- Recommended revisions (specific text changes or restructuring)

**Dependencies**: None -- can run in parallel with other tasks. But revisions should be consistent with the README messaging established in Tasks 1-3.

## Risks and Concerns

### Risk 1: Marketing tone creeping into technical documentation
The task explicitly asks for a "product marketing lens." For an OSS GitHub project, there is a narrow band between "compelling" and "cringe." Developers are hostile to marketing language in technical contexts. Superlatives ("best-in-class," "revolutionary"), vague claims ("supercharge your workflow"), and hype language will actively repel the target audience. The success criterion ("no hype, no empty superlatives") is correct but needs enforcement during execution. Every claim in the README must be verifiable by the reader within 60 seconds of installing.

### Risk 2: Progressive disclosure hiding essential information too aggressively
If we move too much from README to docs/, the README becomes too thin and fails to communicate the system's genuine depth. The 27-agent count is a real differentiator -- hiding it entirely would be a mistake. The goal is to communicate "27 specialists" as a headline fact without forcing the reader to process all 27 names. The group summary approach threads this needle, but execution needs to verify that the summary still communicates breadth.

### Risk 3: The "first command" experience depends on Claude Code working
The README can describe what to type, but the actual first-run experience depends on Claude Code's behavior -- agent discovery, error messages if something goes wrong, response quality. If a developer installs, types `@security-minion Review this auth flow`, and gets a poor or confusing response, no amount of README polish helps. This is outside the docs task's scope, but it is worth noting that the documentation can only set expectations -- it cannot guarantee the experience meets them.

### Risk 4: Phase 8 triage criteria becoming another checkbox
If the marketing lens criteria are too complex or too numerous, nefario will treat them as a checklist to satisfy rather than a judgment to exercise. The criteria need to be simple enough to internalize (three buckets, clear decision rules) rather than detailed enough to cover every edge case. Err on the side of fewer rules with clear intent over more rules with complete coverage.

## Additional Agents Needed

**user-docs-minion** should review the final README and any new getting-started content for clarity from an end-user documentation perspective. The current planning team covers positioning (product-marketing), structure (software-docs), journey (ux-strategy), and onboarding (devx), but user-docs-minion brings expertise in tutorial writing, readability, and the specific challenge of writing for developers who are reading while doing. This is especially relevant if a quickstart guide is created.

No other additional agents are needed. The current four-specialist planning team covers the necessary domains.
