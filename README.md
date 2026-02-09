# Despicable Agents

[![93% Vibe_Coded](https://img.shields.io/badge/93%25-Vibe_Coded-ff69b4?style=for-the-badge&logo=claude&logoColor=white)](https://github.com/trieloff/vibe-coded-badge-action)

19 specialist agents for [Claude Code](https://code.claude.com). Deep domain experts that work alone or as a coordinated team -- install once, use everywhere.

## What you get

```
@gru Should we adopt A2A or double down on MCP?

@security-minion Review this auth flow for vulnerabilities

@debugger-minion This function leaks memory under load -- find the root cause

@frontend-minion Refactor this component to use web components instead of React

/nefario Build an MCP server with OAuth, tests, and user docs
```

Single-domain work goes directly to the specialist. Multi-domain work goes to `/nefario`, which plans across specialists and coordinates execution.

## Install

```bash
git clone https://github.com/benpeter/despicable-agents.git
cd despicable-agents && ./install.sh
```

This symlinks all 19 agents to `~/.claude/agents/` so they are available in every Claude Code session. To remove them: `./install.sh uninstall`.

## Agent Roster

| Group | Agent | Focus |
|-------|-------|-------|
| **Boss** | `gru` | AI/ML technology radar, strategic decisions |
| **Foreman** | `nefario` | Multi-agent orchestration, task decomposition |
| **Protocol & Integration** | `mcp-minion` | MCP server development, SDK, transports |
| | `oauth-minion` | OAuth 2.0/2.1, token management |
| | `api-design-minion` | REST, GraphQL, API ergonomics |
| **Infrastructure & Data** | `iac-minion` | IaC, CI/CD, containerization |
| | `edge-minion` | CDN, edge compute, load balancing |
| | `data-minion` | Data architecture, modeling, databases |
| **Intelligence** | `ai-modeling-minion` | LLM integration, prompt engineering |
| **Development & Quality** | `frontend-minion` | Frontend, components, TypeScript |
| | `test-minion` | Test strategy, automation, QA |
| | `debugger-minion` | Debugging, root cause analysis |
| | `devx-minion` | CLI design, SDK design, developer tooling |
| **Security & Observability** | `security-minion` | AppSec, threat modeling, supply chain |
| | `observability-minion` | Monitoring, logging, tracing |
| **Design & Documentation** | `ux-strategy-minion` | Usability, simplification, user advocacy |
| | `ux-design-minion` | Visual design, interaction design, design systems |
| | `software-docs-minion` | Architecture and API documentation |
| | `user-docs-minion` | Tutorials, help content, end-user docs |

## How It Works

Three tiers. **Gru** is the strategic brain -- ask it whether to adopt a technology. **Nefario** is the orchestrator -- give it a complex task and it decomposes, delegates, and coordinates across specialists. **Minions** are the 17 domain experts that do the actual work.

When you invoke `/nefario`, it runs a five-phase process: meta-planning (which specialists to consult), specialist planning (parallel domain input), synthesis (unified execution plan with tasks and owners), architecture review (cross-cutting concerns like security and testing), and execution (parallel task dispatch to specialists).

See [Orchestration](docs/orchestration.md) for the full guide.

## Documentation

- [Architecture Overview](docs/architecture.md) -- system design, hierarchy, agent groups
- [Agent Anatomy](docs/agent-anatomy.md) -- file structure, frontmatter, overlay mechanism
- [Orchestration](docs/orchestration.md) -- five-phase planning, delegation, nefario usage
- [Build Pipeline](docs/build-pipeline.md) -- building agents, versioning, the `/lab` skill
- [Deployment](docs/deployment.md) -- symlink deployment, `install.sh`
- [Design Decisions](docs/decisions.md) -- architectural tradeoffs and rationale

## Contributing

All content must be in English. No PII, no proprietary data -- agents are published under Apache 2.0 and must stay that way.

`the-plan.md` is the canonical spec and source of truth for all agents. Propose changes there via pull request. Respect agent boundaries: each agent's "Does NOT do" section defines where its responsibility ends and another's begins.

Prefer lightweight, vanilla solutions. Do not reach for frameworks unless they earn their weight.

## License

[Apache License 2.0](LICENSE)
