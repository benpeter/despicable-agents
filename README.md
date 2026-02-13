# Despicable Agents

![⚗️ despicable](https://img.shields.io/badge/%E2%9A%97%EF%B8%8F-despicable-FFC107?style=for-the-badge&labelColor=FFF8E1)
[![98% Vibe_Coded](https://img.shields.io/badge/98%25-Vibe_Coded-ff69b4?style=for-the-badge&logo=claude&logoColor=white)](https://github.com/trieloff/vibe-coded-badge-action)

Structured orchestration, domain specialists, and governance gates for [Claude Code](https://docs.anthropic.com/en/docs/claude-code). Built on [Agent Teams](https://code.claude.com/docs/en/agent-teams). 27 agents, 2 skills, available in every session after a one-time install.

## What You Get

- **Phased orchestration** -- nine structured phases from meta-planning through parallel execution to post-execution verification (code review, test runs, docs updates). User approval gates at every phase transition so you stay in control.
- **Research-backed domain experts** -- 27 agents built from domain research, each with strict boundaries so delegation is unambiguous. Security questions go to security-minion, not a generalist. OAuth goes to oauth-minion, not the API designer.
- **Built-in governance and quality gates** -- five mandatory reviewers (security-minion, test-minion, ux-strategy-minion, lucy, margo) examine every plan before code runs. Post-execution code review and test execution verify the output.
- **Goodies**
  - Execution reports committed to repo history
  - `/despicable-prompter` turns a rough idea or `#42` issue reference into a structured brief
  - `/despicable-lab` for version-tracked agent maintenance
  - Automatic [context management](docs/compaction-strategy.md) -- scratch files, compaction checkpoints, and context-aware gating keep long orchestrations on track
  - Install once, available everywhere via symlinks

## Examples

Single-domain work goes to the specialist. Multi-domain work goes to `/nefario`.

```
# Need to validate your auth flow?
@security-minion Review this auth flow for vulnerabilities
# -> threat model, specific findings, remediation steps

# Leaking memory under load?
@debugger-minion This function leaks memory under load -- find the root cause
# -> root cause analysis, fix, verification approach

# Multi-domain task? Nefario plans across specialists and coordinates execution.
/nefario Build an OAuth-secured API with tests and user docs
# -> orchestrated plan across api-design, oauth, test, and user-docs specialists
#    reviewed by governance before execution

# Got a GitHub issue? Point nefario at it -- issue in, PR out.
/nefario #42
# -> orchestrated plan, governance review, parallel execution, PR with "Resolves #42"

# Need specialist analysis without code changes? Advisory mode.
/nefario --advisory Should we use WebSockets or SSE for real-time updates?
# -> specialist team evaluates, produces recommendation report, no code touched

# Rough idea? Turn it into a structured brief first.
/despicable-prompter Add rate limiting with monitoring
/despicable-prompter #42
# -> structured brief with outcomes, success criteria, and scope
```

## Install

Requires [Claude Code](https://docs.anthropic.com/en/docs/claude-code).

```bash
git clone https://github.com/benpeter/despicable-agents.git
cd despicable-agents && ./install.sh
```

Symlinks 27 agents and 2 skills (`/nefario`, `/despicable-prompter`) to `~/.claude/`. Available in every Claude Code session. To remove: `./install.sh uninstall`.

### Using on Other Projects

After install, agents and skills are available in any Claude Code session regardless of working directory. Invoke `@agent-name` or `/nefario` from your project. Reports, branches, and commits target the current project -- no configuration required.

Nefario automatically discovers and delegates to project-local skills (`.skills/`, `.claude/skills/`). See [External Skill Integration](docs/external-skills.md) for details.

### Prerequisites

Tested on macOS and Linux. Windows has not been tested -- you may or may not get this to work using [WSL](https://github.com/benpeter/despicable-agents/issues/103).

The install script needs only `git`. The commit workflow hooks additionally need **bash 4+** and **jq** -- see [Prerequisites](docs/prerequisites.md) for details, or paste the [quick setup prompt](docs/prerequisites.md#quick-setup) into Claude Code.

## How It Works

You describe a task. Nefario (orchestrator) figures out which specialists to consult, gathers their domain input in parallel, and synthesizes an execution plan. Five mandatory reviewers -- security-minion, test-minion, ux-strategy-minion, Lucy (intent alignment), and Margo (simplicity) -- examine the plan before any code runs. You approve the plan. Specialists execute in parallel where possible, with approval gates at high-impact decisions. After execution, code review and test runs verify the output. You get a wrap-up summary and an execution report committed to the repo.

The four named roles:

- **Gru** (AI visionary) -- technology radar, strategic direction
- **Nefario** (orchestrator) -- task decomposition, delegation, coordination
- **Lucy** (governance) -- intent alignment, repo conventions, consistency
- **Margo** (governance) -- simplicity enforcement, YAGNI/KISS

Plus 23 minions across 7 domain groups doing the specialist work.

See [Using Nefario](docs/using-nefario.md) for the full orchestration guide.

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

## Contributing

All content in English. No PII, no proprietary data -- agents are published under Apache 2.0. `the-plan.md` is the canonical spec and source of truth. Propose changes there via pull request. Respect agent boundaries: each agent's "Does NOT do" section defines where its scope ends.

## License

[Apache License 2.0](LICENSE)
