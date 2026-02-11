# Despicable Agents

[![98% Vibe_Coded](https://img.shields.io/badge/98%25-Vibe_Coded-ff69b4?style=for-the-badge&logo=claude&logoColor=white)](https://github.com/trieloff/vibe-coded-badge-action)

A team of domain specialists, an orchestrator that coordinates them, and a governance layer that reviews every plan before execution -- for [Claude Code](https://docs.anthropic.com/en/docs/claude-code).

This project explores [Agent Teams](https://code.claude.com/docs/en/agent-teams), a research preview feature [released on February 5, 2026](https://www.anthropic.com/news/claude-opus-4-6), that enables multiple Claude Code sessions to coordinate autonomously on complex tasks.

## Examples

Single-domain work goes to the specialist. Multi-domain work goes to `/nefario`.

In any Claude Code session:

```
# Need to validate your auth flow?
@security-minion Review this auth flow for vulnerabilities
# → threat model, specific findings, remediation steps

# Leaking memory under load?
@debugger-minion This function leaks memory under load -- find the root cause
# → root cause analysis, fix, verification approach

# Multi-domain task? Nefario plans across specialists and coordinates execution.
/nefario Build an OAuth-secured API with tests and user docs
# → orchestrated plan across api-design, oauth, test, and user-docs specialists
#   reviewed by governance before execution
```

## Install

Requires [Claude Code](https://docs.anthropic.com/en/docs/claude-code).

```bash
git clone https://github.com/benpeter/despicable-agents.git
cd despicable-agents && ./install.sh
```

Installs 27 agents and 2 skills (`/nefario`, `/despicable-prompter`) to `~/.claude/`. Available in every Claude Code session. To remove: `./install.sh uninstall`.

### Using on Other Projects

After install, agents and skills are available in any Claude Code session regardless of working directory. Invoke `@agent-name` or `/nefario` from your project. Reports, branches, and commits target the current project -- no configuration required.

## Try It

Agents are invoked with `@name`. The `/nefario` skill coordinates multiple agents for complex tasks.

Start with a single specialist:

```
@security-minion Check this endpoint for injection vulnerabilities
```

The security specialist returns a structured review: threat model, findings by severity, and remediation guidance.

For work spanning multiple domains, use the orchestrator:

```
/nefario Add rate limiting to the API with monitoring and updated docs
```

Nefario consults the relevant specialists, synthesizes a plan, runs it through governance review (intent alignment, simplicity, security, testing), then executes across agents in parallel.

## How It Works

**Gru** sets technology direction. **Nefario** orchestrates complex tasks through a nine-phase process -- from planning through execution to post-execution verification. **Lucy** and **Margo** are governance: every plan is reviewed for intent alignment and over-engineering before execution. **23 minions** are the domain specialists that do the work.

Six mandatory reviewers check every plan. Plans that drift from what you asked for are caught. Over-engineering is flagged. See [Using Nefario](docs/using-nefario.md) for the full orchestration guide.

## Agents

4 named roles (Gru, Nefario, Lucy, Margo) and 23 minions across 7 domain groups.

See [Agent Catalog](docs/agent-catalog.md) for per-agent details.

<details>
<summary>Full agent roster</summary>

| Group | Agent | Focus |
|-------|-------|-------|
| **Boss** | `gru` | AI/ML technology radar, strategic decisions |
| **Foreman** | `nefario` | Multi-agent orchestration, task decomposition |
| **Governance** | `lucy` | Intent alignment, repo conventions, consistency |
| | `margo` | Simplicity enforcement, YAGNI/KISS |
| **Protocol & Integration** | `mcp-minion` | MCP server development, SDK, transports |
| | `oauth-minion` | OAuth 2.0/2.1, token management |
| | `api-design-minion` | REST, GraphQL, API ergonomics |
| | `api-spec-minion` | OpenAPI/AsyncAPI authoring, linting, governance |
| **Infrastructure & Data** | `iac-minion` | IaC, CI/CD, containerization |
| | `edge-minion` | CDN, edge compute, load balancing |
| | `data-minion` | Data architecture, modeling, databases |
| **Intelligence** | `ai-modeling-minion` | LLM integration, prompt engineering |
| **Development & Quality** | `frontend-minion` | Frontend, components, TypeScript |
| | `test-minion` | Test strategy, automation, QA |
| | `debugger-minion` | Debugging, root cause analysis |
| | `devx-minion` | CLI design, SDK design, developer tooling |
| | `code-review-minion` | Code quality, PR review, static analysis |
| **Security & Observability** | `security-minion` | AppSec, threat modeling, supply chain |
| | `observability-minion` | Monitoring, logging, tracing |
| **Design & Documentation** | `ux-strategy-minion` | Usability, simplification, user advocacy |
| | `ux-design-minion` | Visual design, interaction design, design systems |
| | `software-docs-minion` | Architecture and API documentation |
| | `user-docs-minion` | Tutorials, help content, end-user docs |
| | `product-marketing-minion` | Product positioning, feature messaging |
| **Web Quality** | `accessibility-minion` | WCAG 2.2 compliance, assistive technology |
| | `seo-minion` | SEO, structured data, generative engine optimization |
| | `sitespeed-minion` | Core Web Vitals, performance budgets |

</details>

## Documentation

**Using the agents:**
- [Using Nefario](docs/using-nefario.md) -- orchestration workflow, phases, when to use `/nefario` vs `@agent`
- [Agent Catalog](docs/agent-catalog.md) -- per-agent capabilities, boundaries, and usage

**Contributing and extending:**
- [Architecture Overview](docs/architecture.md) -- system design, hierarchy, agent groups
- [Design Decisions](docs/decisions.md) -- architectural tradeoffs with rationale and rejected alternatives

## Current Limitations

- **Claude Code dependency.** Agents are AGENT.md files consumed by Claude Code's agent loading. They are not standalone tools.
- **No subagent nesting.** Claude Code does not allow subagents to spawn other subagents. Only the main session dispatches to agents.
- **Context window pressure.** Complex orchestrations with many specialists can approach context limits. The project uses temporary scratch files and compaction checkpoints to manage context, but very large plans may require manual intervention.
- **97% vibe-coded.** The research is real and the architecture is deliberate, but the system prompt prose was generated with AI assistance and refined iteratively.

## Contributing

All content in English. No PII, no proprietary data -- agents are published under Apache 2.0. `the-plan.md` is the canonical spec and source of truth. Propose changes there via pull request. Respect agent boundaries: each agent's "Does NOT do" section defines where its scope ends.

## License

[Apache License 2.0](LICENSE)
