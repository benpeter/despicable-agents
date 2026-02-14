[< Back to README](../README.md)

# Agent Catalog

Reference listing of all 27 agents with descriptions, model tiers, example
invocations, and key boundaries. For orchestrated multi-domain tasks, see
[Using Nefario](using-nefario.md).

## How to choose

```
I know exactly what I need          --> find your specialist below
I have a multi-domain task          --> /nefario
I need a technology radar opinion   --> @gru
I'm not sure where to start         --> @gru for strategy, /nefario for execution
```

---

## Boss

### `gru`

AI/ML technology landscape analyst and strategic technology advisor. Evaluates
emerging AI technologies using adopt/trial/assess/hold framework, tracks
foundation model evolution, agent protocol maturity, and regulation timelines.

- **Model**: opus
- **Example**: `@gru Should we adopt MCP or wait for A2A to mature? Give me a ring classification with timeframe.`
- **Does NOT do**: implement AI systems (ai-modeling-minion), build MCP servers (mcp-minion), write production code

---

## Foreman

### `nefario`

Multi-agent orchestrator specializing in task decomposition, delegation, and
coordination. Coordinates handoffs between specialists, synthesizes results,
and manages the plan-execute-verify cycle.

- **Model**: sonnet
- **Example**: `/nefario Build an MCP server with OAuth, tests, and user docs`
- **Does NOT do**: write code (delegates to minions), make strategic technology decisions (gru), perform any specialist work

---

## Governance

### `lucy`

Project consistency guardian and human intent alignment reviewer. Verifies plans
match user intent, enforces repo conventions and CLAUDE.md compliance, catches
goal drift in multi-phase orchestrations.

- **Model**: opus
- **Example**: `@lucy Review this plan against the original request -- does it deliver what was asked for?`
- **Does NOT do**: task decomposition (nefario), domain correctness assessment (specialist minions), simplicity/complexity judgment (margo)

### `margo`

Architectural simplicity enforcer and YAGNI/KISS guardian. Reviews plans and
code for unnecessary complexity (including infrastructure overhead and
operational burden), over-engineering, scope creep, and dependency bloat.

- **Model**: opus
- **Example**: `@margo Audit this architecture -- is the complexity justified by actual requirements?`
- **Does NOT do**: domain-correctness assessment (specialist minions), task orchestration (nefario), strategic technology decisions (gru)

---

## Protocol & Integration

### `mcp-minion`

MCP server development, tool/resource/prompt design, transports, and MCP OAuth
flows. TypeScript SDK patterns and production-ready MCP implementations.

- **Model**: sonnet
- **Example**: `@mcp-minion Build an MCP server that exposes our project database as resources with Streamable HTTP transport`
- **Does NOT do**: general OAuth implementation (oauth-minion), infrastructure provisioning (iac-minion), security audits (security-minion)

### `oauth-minion`

OAuth 2.0/2.1 protocol flows, PKCE, Dynamic Client Registration, token
management, and MCP-specific OAuth debugging.

- **Model**: sonnet
- **Example**: `@oauth-minion Implement authorization code flow with PKCE for our single-page app`
- **Does NOT do**: general API security beyond OAuth (security-minion), infrastructure provisioning (iac-minion), MCP protocol implementation (mcp-minion)

### `api-design-minion`

REST and GraphQL API design with focus on developer ergonomics. Resource
modeling, versioning strategies, rate limiting, pagination, error schemas,
webhooks, and SDK-friendly design.

- **Model**: sonnet
- **Example**: `@api-design-minion Design a REST API for our project management domain with cursor pagination and RFC 9457 errors`
- **Does NOT do**: OpenAPI/AsyncAPI spec authoring (api-spec-minion), backend business logic implementation, API documentation prose (software-docs-minion)

### `api-spec-minion`

OpenAPI/AsyncAPI spec authoring, validation, Spectral linting, contract-first
workflows, SDK generation configuration, and breaking change detection.

- **Model**: opus
- **Example**: `@api-spec-minion Write an OpenAPI 3.1 spec for this API design and configure Spectral linting rules`
- **Does NOT do**: API design decisions (api-design-minion), API documentation prose (software-docs-minion), security review of specs (security-minion)

---

## Infrastructure & Data

### `iac-minion`

Terraform, Docker, GitHub Actions, serverless platforms, and deployment
automation. Infrastructure provisioning, CI/CD pipelines, containerization,
reverse proxies, cloud cost optimization, and deployment strategy selection.

- **Model**: sonnet
- **Example**: `@iac-minion Set up a GitHub Actions pipeline with Docker build, test, and deploy stages`
- **Does NOT do**: application security audits (security-minion), OAuth implementation (oauth-minion), application code (domain minions), edge-layer runtime behavior (edge-minion)

### `edge-minion`

CDN configuration, edge workers (Cloudflare/Fastly), load balancing, caching
strategies, and content delivery optimization. Covers edge-layer behavior on
serverless platforms (Cloudflare Workers/Pages, Vercel, Netlify).

- **Model**: sonnet
- **Example**: `@edge-minion Design a caching strategy for our API with Fastly VCL -- target 90% cache hit ratio`
- **Does NOT do**: origin server infrastructure (iac-minion), full-stack serverless deployment configuration (iac-minion), application security policies (security-minion), API design (api-design-minion)

### `data-minion`

Database architecture, schema design, and data modeling across paradigms.
Polyglot persistence decisions, event streaming with Kafka, document/vector/
key-value/edge/time-series/graph/SQL databases.

- **Model**: sonnet
- **Example**: `@data-minion Recommend a database stack for our app: user profiles, full-text search, and vector embeddings`
- **Does NOT do**: provision database infrastructure (iac-minion), query performance profiling (observability-minion), data visualization (frontend-minion)

---

## Intelligence

### `ai-modeling-minion`

Prompt engineering, Anthropic API integration, multi-agent architecture design,
LLM cost and latency optimization, model selection guidance, and structured
output validation.

- **Model**: opus
- **Example**: `@ai-modeling-minion Design a system prompt for our customer support agent with tool use and prompt caching`
- **Does NOT do**: MCP protocol implementation (mcp-minion), infrastructure provisioning for AI services (iac-minion), security review of prompts (security-minion)

---

## Development & Quality

### `frontend-minion`

React architecture, TypeScript, component libraries (React Spectrum, Radix,
shadcn/ui), CSS architecture, state management, build tooling (Vite), and
performance optimization implementation.

- **Model**: sonnet
- **Example**: `@frontend-minion Refactor this page to use React Spectrum components with CSS Modules and lazy-loaded routes`
- **Does NOT do**: visual design decisions (ux-design-minion), UX strategy (ux-strategy-minion), backend code (domain minions)

### `test-minion`

Test strategy, test automation, coverage analysis, and CI test pipeline
optimization. Unit, integration, and end-to-end testing across frameworks.

- **Model**: sonnet
- **Example**: `@test-minion Design a test strategy for our API -- unit tests for business logic, integration tests for endpoints, E2E for critical paths`
- **Does NOT do**: debug production issues (debugger-minion), security/penetration testing (security-minion), provision test infrastructure (iac-minion)

### `debugger-minion`

Systematic root cause analysis, stack trace interpretation, log correlation,
git bisect, memory/CPU profiling, and reverse engineering of dependencies.

- **Model**: opus
- **Example**: `@debugger-minion This function leaks memory under load -- find the root cause using heap snapshots`
- **Does NOT do**: write tests (test-minion), fix security vulnerabilities (security-minion), design observability systems (observability-minion)

### `devx-minion`

CLI design, SDK design, developer onboarding flows, configuration file design,
and developer tooling. Minimizes time-to-first-success for developer-facing
tools.

- **Model**: sonnet
- **Example**: `@devx-minion Design a CLI for our service with intuitive subcommands, shell completions, and helpful error messages`
- **Does NOT do**: end-user documentation (user-docs-minion), visual UI design (ux-design-minion), API protocol design (api-design-minion)

### `code-review-minion`

Code quality review, PR review standards, static analysis configuration, bug
pattern detection, and review automation.

- **Model**: sonnet
- **Example**: `@code-review-minion Review this PR for code quality -- check complexity, duplication, and naming conventions`
- **Does NOT do**: security vulnerability assessment (security-minion), test strategy or implementation (test-minion), production debugging (debugger-minion)

---

## Security & Observability

### `security-minion`

Application and infrastructure security: threat modeling, vulnerability
analysis, OWASP Top 10, AI/LLM security, container security, and supply chain
security posture evaluation.

- **Model**: opus
- **Example**: `@security-minion Threat model our MCP server -- identify attack surfaces, especially prompt injection vectors`
- **Does NOT do**: implement OAuth flows (oauth-minion), write infrastructure code (iac-minion), design prompts (ai-modeling-minion)

### `observability-minion`

Logs, metrics, traces (three pillars), OpenTelemetry instrumentation, Coralogix
platform, Prometheus/Grafana, SLO/SLI design, alert strategy, and cost
optimization.

- **Model**: sonnet
- **Example**: `@observability-minion Design an observability stack for our microservices -- structured logging, distributed tracing, and SLO-based alerts`
- **Does NOT do**: fix bugs found via observability (debugger-minion), provision monitoring infrastructure (iac-minion), security event monitoring (security-minion)

---

## Design & Documentation

### `ux-strategy-minion`

User journey mapping, simplification audits, cognitive load reduction, feature
prioritization from UX perspective, friction logging, and heuristic evaluation.

- **Model**: sonnet
- **Example**: `@ux-strategy-minion Run a simplification audit on our onboarding flow -- where are users dropping off?`
- **Does NOT do**: visual design or wireframes (ux-design-minion), UI code implementation (frontend-minion), end-user documentation (user-docs-minion)

### `ux-design-minion`

UI/UX design, design systems, responsive design, visual hierarchy, interaction
design, accessible design patterns, and design token architecture.

- **Model**: sonnet
- **Example**: `@ux-design-minion Design a component library with design tokens, dark mode support, and responsive breakpoints`
- **Does NOT do**: UX strategy or user research (ux-strategy-minion), WCAG compliance auditing (accessibility-minion), frontend code implementation (frontend-minion)

### `software-docs-minion`

Architecture documentation (C4 model, diagrams), ADRs, API docs, READMEs,
developer onboarding guides, and Mermaid diagram creation.

- **Model**: sonnet
- **Example**: `@software-docs-minion Create a C4 context and container diagram for our system with Mermaid`
- **Does NOT do**: end-user documentation (user-docs-minion), UX copy (ux-design-minion), API design itself (api-design-minion)

### `user-docs-minion`

User guides, tutorials, troubleshooting guides, in-app help text, FAQs, and
release notes for end users.

- **Model**: sonnet
- **Example**: `@user-docs-minion Write a getting-started tutorial for new users that gets them to first success in under 5 minutes`
- **Does NOT do**: architecture documentation (software-docs-minion), API reference docs (software-docs-minion), CLI help text (devx-minion)

### `product-marketing-minion`

Product positioning, feature messaging, launch narratives, competitive
differentiation, and developer-facing copy.

- **Model**: opus
- **Example**: `@product-marketing-minion Write the positioning section for our README -- lead with the problem, not the features`
- **Does NOT do**: end-user tutorials (user-docs-minion), UX strategy or research (ux-strategy-minion), architecture documentation (software-docs-minion)

---

## Web Quality

### `accessibility-minion`

WCAG 2.2 conformance auditing, assistive technology testing, ARIA
implementation review, screen reader testing, and accessibility CI integration.

- **Model**: sonnet
- **Example**: `@accessibility-minion Audit this page for WCAG 2.2 AA conformance -- check keyboard nav, screen reader, and color contrast`
- **Does NOT do**: visual design decisions (ux-design-minion), frontend implementation of fixes (frontend-minion), test automation strategy (test-minion)

### `seo-minion`

Technical SEO, structured data/schema.org, meta tags, crawlability, indexing
strategy, and Core Web Vitals as ranking signals.

- **Model**: sonnet
- **Example**: `@seo-minion Audit our site for technical SEO -- structured data, meta tags, crawlability, and indexing issues`
- **Does NOT do**: page performance optimization (sitespeed-minion), CDN and caching configuration (edge-minion), content writing (user-docs-minion)

### `sitespeed-minion`

Core Web Vitals, performance budgets, Lighthouse audits, loading strategy
optimization, bundle analysis, and performance regression detection.

- **Model**: sonnet
- **Example**: `@sitespeed-minion Run a Lighthouse audit and define performance budgets for our landing page -- target LCP under 2.5s`
- **Does NOT do**: code splitting implementation (frontend-minion), CDN caching and edge compression (edge-minion), server-side performance (iac-minion)
