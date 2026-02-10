# Phase 1: Meta-Plan

## Task Summary

Rethink the despicable-agents project documentation with a product marketing lens, producing two outcomes: (1) rewrite user-facing docs (README, docs/) to tell a compelling story that communicates the project's unique value, and (2) embed a lightweight marketing-awareness step into nefario's Phase 8 documentation process so future orchestrations automatically apply marketing judgment to documentation output.

## Planning Consultations

### Consultation 1: Product Positioning and Messaging Strategy

- **Agent**: product-marketing-minion
- **Planning question**: Given the despicable-agents project (27 coordinated specialist agents for Claude Code, multi-phase orchestration, governance layer, cross-cutting review), what is the positioning strategy for its README and docs? Specifically: (a) What is the core value proposition -- what job does this project do for developers that nothing else does? (b) What are the 3-5 supporting messages that highlight unique differentiators (orchestration, governance, specialist depth, cross-cutting review, build/deploy system)? (c) What is the right messaging hierarchy for the README -- what comes first, second, third? (d) What competitive alternatives exist (even if just "do nothing" or "write your own prompts") and how should we position against them? (e) What is the right tone for an OSS GitHub project -- where is the line between compelling and overselling? (f) How should the marketing lens step be structured for Phase 8 -- what triage categories make sense, and what criteria distinguish headline-worthy from mention-worthy from document-only?
- **Context to provide**: Current README.md, docs/architecture.md, the product-marketing-minion's own AGENT.md (for its README positioning framework), the project's CLAUDE.md (engineering philosophy, Helix Manifesto principles)
- **Why this agent**: product-marketing-minion owns positioning, value propositions, developer-facing messaging, README strategy, and feature triage -- this is its core domain. It brings the Dunford positioning framework, jobs-to-be-done analysis, and developer marketing principles needed to transform utility docs into a compelling narrative.

### Consultation 2: Documentation Information Architecture

- **Agent**: software-docs-minion
- **Planning question**: Looking at the current docs/ structure (architecture.md as hub, six sub-documents, plus ancillary docs), how should the information architecture be reorganized to serve two distinct audiences: (a) users who want to understand and use the agents (README -> getting started -> usage patterns), and (b) contributors/extenders who need technical reference (architecture, agent anatomy, build pipeline, deployment, decisions)? Specifically: (i) What is the right navigation structure -- should docs/architecture.md remain the hub, or should there be separate user-guide and reference sections? (ii) Which current docs are user-facing vs. contributor-facing, and are any misclassified? (iii) What content gaps exist for a "first 30 seconds" experience -- can someone go from README to running their first agent command without confusion? (iv) How should cross-linking work between README and docs/ to minimize clicks while keeping README concise? (v) What docs content needs rewriting vs. restructuring vs. is fine as-is?
- **Context to provide**: Current README.md, docs/architecture.md (hub page with sub-document index), all docs/*.md filenames and their first sections, the project's CLAUDE.md for conventions
- **Why this agent**: software-docs-minion owns architecture documentation, information architecture, and documentation structure. It brings C4 diagramming expertise, doc-as-code patterns, and experience with hub-and-spoke navigation that is needed to restructure the docs for two audiences.

### Consultation 3: User Journey and Cognitive Load

- **Agent**: ux-strategy-minion
- **Planning question**: Evaluate the current documentation from a user journey and cognitive load perspective. A new developer arrives at the GitHub repo. (a) What is their likely journey through the docs today, and where do they get stuck or confused? (b) What is the cognitive load of the current README -- does the 27-agent roster table overwhelm before communicating value? (c) How should the "four tiers" concept be introduced -- is the current one-paragraph explanation sufficient, or does it need progressive disclosure? (d) What is the right balance between showing the system's sophistication (which builds trust) and keeping it simple (which enables adoption)? (e) For the Phase 8 marketing lens, what user-facing changes are "headline-worthy" from a UX perspective -- what criteria should nefario use to judge impact on the user's experience?
- **Context to provide**: Current README.md, docs/orchestration.md Section 1 (the user-facing "Using Nefario" section), the success criteria from the task (especially the "30 seconds to getting-started" criterion)
- **Why this agent**: ux-strategy-minion owns user journey mapping, cognitive load assessment, and simplification audits. Every plan needs this agent's perspective (ALWAYS include per cross-cutting checklist). The README is the project's primary user interface for first impressions -- UX strategy expertise is essential to get the information hierarchy right.

### Consultation 4: Developer Experience and Onboarding Path

- **Agent**: devx-minion
- **Planning question**: Evaluate the getting-started and onboarding experience for a developer who has just found this project. (a) Is the current install path (clone + ./install.sh) the right zero-to-value flow, and what friction points exist? (b) After install, what does a developer do next -- is the path from "installed" to "first successful agent interaction" clear? (c) Should there be a "first 5 minutes" guide showing concrete examples beyond the README's code block? (d) How should the README's example block (the five @agent examples) be structured -- are they the right examples, and do they communicate value or just syntax? (e) For the docs, should there be a dedicated "quickstart" or "getting started" page separate from README, or is inline-in-README sufficient?
- **Context to provide**: Current README.md (especially the "Install" and "What you get" sections), docs/deployment.md (symlink model), docs/orchestration.md Section 1 (nefario usage guide)
- **Why this agent**: devx-minion owns developer onboarding, CLI design, and developer experience. The transition from "read README" to "use agents" is a developer experience problem -- devx-minion brings expertise in zero-to-value flows, error messages, and configuration friction that complements the marketing and documentation perspectives.

## Cross-Cutting Checklist

- **Testing**: Exclude from planning. This task produces no executable code -- it produces documentation files (Markdown) and a small addition to SKILL.md instructions. No test infrastructure applies.
- **Security**: Exclude from planning. No attack surface, authentication, user input processing, or secrets management involved. The only content constraint (no PII, publishable under Apache 2.0) is already covered by existing CLAUDE.md rules.
- **Usability -- Strategy**: INCLUDED as Consultation 3 (ux-strategy-minion). Planning question addresses user journey, cognitive load, and information hierarchy for the README as primary user interface.
- **Usability -- Design**: Exclude from planning. No user-facing interfaces are being produced -- this is Markdown documentation, not UI components. Visual design and WCAG compliance do not apply.
- **Documentation**: INCLUDED as Consultation 2 (software-docs-minion). This task IS primarily a documentation task -- software-docs-minion's information architecture expertise is core to the plan. user-docs-minion is not included for planning because the distinction between user-guide content and technical-reference content is better assessed by software-docs-minion (who owns IA) with devx-minion providing the onboarding perspective.
- **Observability**: Exclude from planning. No runtime components, services, or APIs are being created.

## Anticipated Approval Gates

Based on the task's two-outcome structure and the reversibility/blast-radius analysis:

1. **README and documentation restructure plan** (MUST gate) -- Hard to reverse once written (messaging and structure set expectations that propagate to all other docs) AND high blast radius (downstream doc-writing tasks depend on the agreed structure and messaging hierarchy). The gate would present the positioning strategy, messaging hierarchy, proposed README structure, and docs reorganization plan before any writing begins.

2. **Phase 8 marketing lens specification** (OPTIONAL gate, recommend including) -- Easy to reverse (small addition to SKILL.md instructions) but affects all future orchestrations. The specification is a judgment call with multiple valid approaches (how lightweight, what triage categories, where in the phase). Worth gating because it permanently changes nefario's behavior.

Gate budget: 2 gates (well within the 3-5 budget). Both are judgment-heavy decisions where multiple valid approaches exist.

## Rationale

Four specialists are consulted because the task spans four distinct domains:

- **product-marketing-minion** brings the positioning frameworks (Dunford, JTBD, value proposition canvas) needed to transform utility-focused docs into a compelling narrative. Without this perspective, the docs would be restructured but not repositioned.
- **software-docs-minion** brings information architecture expertise to restructure docs/ for two audiences (users vs. contributors). Without this, the marketing messaging might be strong but poorly organized.
- **ux-strategy-minion** brings user journey and cognitive load analysis to ensure the README works as a first-impression interface. Without this, the README might have strong messaging but poor information hierarchy.
- **devx-minion** brings developer onboarding expertise to ensure the path from "found the repo" to "using agents" is frictionless. Without this, the docs might tell a compelling story but leave developers unsure what to do next.

These four together cover: what to say (product-marketing), how to organize it (software-docs), how to present it (ux-strategy), and how to make it actionable (devx). No other specialists have planning-relevant expertise for this documentation-only task.

## Scope

**In scope**:
- README.md content, structure, and messaging
- docs/ user-facing pages: architecture.md, orchestration.md (Section 1), deployment.md, agent-anatomy.md, build-pipeline.md, decisions.md
- Navigation and cross-linking between README and docs/
- Potential new docs pages (e.g., quickstart guide, usage guide) if specialists recommend them
- Phase 8 documentation phase in SKILL.md: adding a marketing lens triage step
- Messaging consistency across README, docs/architecture.md, and orchestration.md

**Out of scope**:
- AGENT.md files (system prompts, not user docs)
- RESEARCH.md files
- the-plan.md (canonical spec, human-edited only)
- CLAUDE.md / CLAUDE.local.md
- install.sh
- SKILL.md internals beyond Phase 8 documentation instructions
- nefario/AGENT.md (system prompt changes)
- Execution report template or index
- Hook scripts or settings.json
- docs/compaction-strategy.md, docs/commit-workflow.md, docs/commit-workflow-security.md (internal technical docs that are not part of the user-facing documentation surface)
