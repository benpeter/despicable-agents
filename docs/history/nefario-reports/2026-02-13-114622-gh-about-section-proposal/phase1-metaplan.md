# Meta-Plan: GitHub About Section Proposal

## Task Summary

Propose description, website URL, and topics for the despicable-agents GitHub
repo About section, which is currently empty. This is an advisory task -- no
code changes, purely recommendation and analysis.

## Planning Consultations

### Consultation 1: Product Positioning and Messaging

- **Agent**: product-marketing-minion
- **Planning question**: Given that despicable-agents is an open-source (Apache 2.0) specialist agent framework for Claude Code with 27 agents, phased orchestration, and built-in governance -- what description (max ~350 chars) best communicates the value proposition to developers discovering the repo on GitHub? Consider: what makes this different from other AI agent frameworks? What keywords should appear in the description for scanning readability? Should the tone lean technical/functional or slightly playful (given the Despicable Me naming)?
- **Context to provide**: README.md content, architecture overview, the "What You Get" section listing key differentiators (phased orchestration, research-backed domain experts, governance gates, execution reports)
- **Why this agent**: Product-marketing-minion specializes in positioning, feature messaging, and competitive differentiation. A GitHub description is a micro-positioning statement -- it needs to communicate value in one glance.

### Consultation 2: Discoverability and Topic Strategy

- **Agent**: seo-minion
- **Planning question**: What GitHub topics maximize discoverability for this repo? Consider: (1) what terms developers search when looking for Claude Code extensions, AI agent frameworks, or multi-agent orchestration tools; (2) which existing GitHub topic ecosystems have active communities (e.g., `claude`, `anthropic`, `ai-agents`, `llm`); (3) the balance between broad topics (high traffic, low signal) and specific topics (low traffic, high relevance); (4) GitHub's topic limit and best practices for topic count. Research what topics competing/related repos use (e.g., claude-code tools, MCP servers, AI agent frameworks).
- **Context to provide**: Repo metadata (language: Shell, license: Apache 2.0), key technology associations (Claude Code, Agent Teams, MCP), the project's domain (multi-agent orchestration, domain specialists, governance)
- **Why this agent**: SEO-minion understands discoverability, keyword strategy, and how platform-specific metadata (GitHub topics) drives organic discovery. Topics are GitHub's equivalent of meta tags.

### Consultation 3: Feature Naming and Value Proposition Clarity

- **Agent**: ux-strategy-minion
- **Planning question**: From a user journey perspective, a developer lands on this GitHub repo page and sees the About section first. What information hierarchy best serves the "should I care about this?" decision in 3 seconds? Should the description lead with what it IS (specialist agent team for Claude Code), what it DOES (orchestrated multi-agent execution with governance), or what PROBLEM it solves (complex tasks get decomposed across domain experts)? Does the Despicable Me theming help or hurt first-impression comprehension for developers who have never heard of this project?
- **Context to provide**: README.md first screen, the examples section showing usage patterns, the install flow
- **Why this agent**: UX-strategy-minion evaluates cognitive load and first-impression clarity. The About section is the repo's "above the fold" -- it must pass a snap judgment test.

## Cross-Cutting Checklist

- **Testing**: NOT included for planning. This is a metadata/content advisory task with no executable output.
- **Security**: NOT included for planning. No code, no attack surface, no secrets. GitHub About fields are public metadata on an already-public repo.
- **Usability -- Strategy**: INCLUDED (Consultation 3). The About section is a user-facing touchpoint that directly affects the "discover and evaluate" user journey.
- **Usability -- Design**: NOT included for planning. No UI components or visual design involved -- GitHub renders the About section in a fixed layout.
- **Documentation**: NOT included for planning. The About section is not documentation; it is metadata. software-docs-minion and user-docs-minion have no relevant planning input here, though their existing work (README, docs/) informs the content.
- **Observability**: NOT included for planning. No runtime components.

## Anticipated Approval Gates

None anticipated. This is an advisory task -- the output is a recommendation, not an execution artifact. The user will decide what to set in the GitHub About section based on the advisory report.

## Rationale

Three specialists are consulted because the About section sits at the intersection of three concerns:

1. **Messaging** (product-marketing-minion): The description is a positioning statement. Getting the value proposition wrong means developers scroll past.
2. **Discoverability** (seo-minion): Topics are the primary mechanism for organic GitHub discovery. Wrong topics mean the right audience never finds the repo.
3. **First-impression UX** (ux-strategy-minion): The About section is the first thing visitors see. Information hierarchy and cognitive load determine whether they read further.

Agents NOT consulted and why:
- **gru**: No technology evaluation needed. This is about presentation, not technical direction.
- **software-docs-minion / user-docs-minion**: The existing README and docs are inputs, not outputs. No documentation is being produced.
- **All development/infrastructure/security agents**: No code, infra, or security surface involved.

## Scope

**In scope**: Recommend specific text for the description field (~350 char max), a website URL (or recommendation to leave blank), and a curated list of GitHub topics with rationale for each.

**Out of scope**: Modifying the README, changing repo settings beyond the About section, creating a project website, redesigning the repo structure.

## External Skill Integration

### Discovered Skills

| Skill | Location | Classification | Domain | Recommendation |
|-------|----------|---------------|--------|----------------|
| despicable-lab | .claude/skills/despicable-lab/ | LEAF | Agent build/rebuild | Not relevant -- task does not involve agent regeneration |
| despicable-statusline | .claude/skills/despicable-statusline/ | LEAF | Claude Code status line config | Not relevant -- task does not involve status line configuration |

### Precedence Decisions

No precedence conflicts. Neither discovered skill overlaps with the task domain (product messaging, discoverability, UX strategy).
