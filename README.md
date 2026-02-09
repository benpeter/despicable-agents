# Despicable Agents

A specialist agent team for [Claude Code](https://code.claude.com) with 19 domain-expert agents organized as a coordinated team. Each agent is a deep specialist in their domain, designed to work independently or collaboratively on complex technical tasks.

## Overview

The agent team follows a hierarchical structure inspired by effective delegation patterns:

- **Gru** (the boss) - AI technology radar and strategic decision support
- **Nefario** (the foreman) - Task orchestration and multi-agent coordination
- **17 Minions** (domain specialists) - Deep expertise across six technical domains

All agents are generic domain specialists with no project-specific knowledge, making them reusable across different projects. Project context lives in each project's `CLAUDE.md` file, not in the agents themselves.

## Agent Roster

### The Boss

- **gru** - AI/ML technology landscape, trend evaluation, strategic technology decisions

### The Foreman

- **nefario** - Task orchestration, multi-agent coordination, work decomposition

### The Minions

#### Protocol & Integration
How systems talk to each other: protocols, auth, API contracts.

- **mcp-minion** - Model Context Protocol server development, SDK, transports, deployment
- **oauth-minion** - OAuth 2.0/2.1, token management, MCP-specific OAuth patterns
- **api-design-minion** - API design, REST, GraphQL, protocol selection, developer ergonomics

#### Infrastructure & Data
Where things run, how they scale, where data lives.

- **iac-minion** - Infrastructure as Code, CI/CD, containerization, deployment
- **edge-minion** - CDN, edge computing, load balancing, edge workers
- **data-minion** - Data architecture, modern databases, data modeling

#### Intelligence
AI/ML systems and LLM integration.

- **ai-modeling-minion** - AI/LLM integration, prompt engineering, multi-agent architectures

#### Development & Quality
Building, verifying, and debugging code.

- **frontend-minion** - Frontend implementation, React, TypeScript, component architecture
- **test-minion** - Test strategy, test automation, quality assurance
- **debugger-minion** - Debugging, root cause analysis, reverse engineering
- **devx-minion** - Developer experience, CLI design, SDK design, developer tooling

#### Security & Observability
Keeping things safe, visible, and reliable.

- **security-minion** - Application security, infrastructure security, threat modeling
- **observability-minion** - Observability, monitoring, logging, tracing, performance analysis

#### Design & Documentation
How things look, feel, and are explained.

- **ux-strategy-minion** - UX strategy, usability, simplification, user advocacy
- **ux-design-minion** - UI/UX design, visual design, interaction design, design systems
- **software-docs-minion** - Technical/architectural documentation for developers
- **user-docs-minion** - End-user documentation, tutorials, help content

## Quick Start

### Installation

Deploy all agents to your Claude Code environment:

```bash
# Clone the repository
git clone https://github.com/yourusername/despicable-agents.git
cd despicable-agents

# Install all agents
./install.sh
```

To uninstall:

```bash
./install.sh uninstall
```

After deployment, agents are immediately available in Claude Code.

**Specialist agents** (minions, gru) can be invoked from any session using the `@agent` syntax:

```
@gru should we adopt the new A2A protocol?
@frontend-minion help me optimize this React component
@security-minion review this auth flow
```

**Nefario** (the orchestrator) is invoked via the `/nefario` skill, which handles the planning-then-execution workflow:

```
/nefario coordinate the team to build a new MCP server
```

The skill spawns nefario as a planning subagent to decompose the task, then
executes the plan by creating a team and spawning the recommended specialists.
See [ARCHITECTURE.md](ARCHITECTURE.md) for details on why this pattern is used.

### Using the /lab Skill

The project includes a `/lab` skill for checking agent versions and rebuilding agents when the spec changes:

```bash
# Symlink the lab skill
ln -sf "$(realpath .claude/skills/lab)" ~/.claude/skills/lab

# In Claude Code, use:
/lab status    # Check which agents need rebuilding
/lab rebuild   # Rebuild outdated agents
```

## Using Nefario

Nefario is your orchestrator for complex, multi-domain tasks. When a task spans multiple specialist areas, nefario decomposes it, routes work to the right experts, and coordinates their collaboration.

### When to Use Nefario

Use `/nefario` when your task requires multiple specialists working together. Use individual agents directly for single-domain work.

**Use `/nefario` for:**
- "Build an MCP server with OAuth, tests, and user documentation" (spans mcp-minion, oauth-minion, test-minion, user-docs-minion)
- "Create a new REST API with security review, observability, and API docs" (spans api-design-minion, security-minion, observability-minion, software-docs-minion)
- "Add edge caching to our app with monitoring and performance testing" (spans edge-minion, observability-minion, test-minion)
- "Design and implement a user onboarding flow with UI, docs, and analytics" (spans ux-strategy-minion, ux-design-minion, frontend-minion, user-docs-minion, observability-minion)

**Call specialists directly for:**
- "Fix this CSS layout bug in the header component" → `@frontend-minion`
- "Review this API design for REST best practices" → `@api-design-minion`
- "Should we adopt the new Agent-to-Agent protocol?" → `@gru`
- "Write a troubleshooting guide for this error message" → `@user-docs-minion`
- "Debug why this function is leaking memory" → `@debugger-minion`

**Rule of thumb**: If you can name the single specialist who should handle it, call them directly. If you need to say "we'll need X, Y, and Z working together," use `/nefario`.

### How to Invoke

```
/nefario <describe your task>
```

Be specific in your task description. More context leads to better planning.

**Good examples:**
```
/nefario Build an MCP server that provides GitHub repository tools with OAuth authentication. Include tests and user documentation. Target users are developers integrating GitHub into their Claude workflows.

/nefario Create a REST API for user management (CRUD operations) with JWT authentication, rate limiting, comprehensive error handling, OpenAPI documentation, and observability instrumentation.

/nefario Design and implement a developer onboarding tutorial for our CLI tool. The tutorial should walk through installation, basic usage, and common workflows. Include interactive examples and troubleshooting tips.
```

**Less helpful examples:**
```
/nefario Build something with MCP
/nefario Make the API better
/nefario Fix the docs
```

### What Happens: The Four Phases

Nefario uses a structured planning process that taps into specialist expertise before execution begins.

#### Phase 1: Meta-Planning

Nefario reads your codebase and analyzes the task against its delegation table to figure out which specialists should contribute to the planning.

**Example output:**
```
Meta-Plan
---------
I'll consult 4 specialists for planning input:

1. mcp-minion - MCP server architecture, tool schema design, transport selection
2. oauth-minion - OAuth 2.0 flow design, token management, security considerations
3. test-minion - Test strategy for MCP servers, integration test patterns
4. user-docs-minion - Documentation structure for developer audiences

These specialists cover the core domains. I'll synthesize their input into
a coordinated execution plan.
```

You don't need to approve the meta-plan. It's just showing you who will weigh in.

#### Phase 2: Specialist Planning

Each specialist is spawned as a subagent and asked for their domain-specific planning input. This happens in parallel.

**Example outputs (abbreviated):**

`@mcp-minion`:
```
Domain Plan Contribution: mcp-minion

Recommendations:
- Use stdio transport for simplicity (developer audience)
- Design tools with clear schemas and rich descriptions
- Implement resource listing for repository browsing
- Add sampling for common workflows

Proposed Tasks:
1. Define tool schemas for repo operations (list, read, search)
2. Implement MCP server with stdio transport
3. Add error handling for API rate limits

Risks:
- GitHub API rate limits need graceful handling
- Large repository operations may timeout
```

`@oauth-minion`:
```
Domain Plan Contribution: oauth-minion

Recommendations:
- Use OAuth 2.0 Device Flow (better UX for CLI tools)
- Implement token refresh to avoid re-auth
- Store tokens securely (system keychain)

Proposed Tasks:
1. Implement OAuth 2.0 device flow
2. Add token refresh logic
3. Integrate with MCP server auth handlers

Risks:
- Token storage security critical
- Device flow requires user to visit browser
```

All specialists contribute their perspective in parallel.

#### Phase 3: Synthesis

Nefario takes all the specialist input and consolidates it into a final execution plan with specific tasks, owners, dependencies, and complete agent prompts.

**Example output:**
```
Delegation Plan
===============

Team name: github-mcp-server
Description: MCP server providing GitHub repository tools with OAuth authentication

Task 1: OAuth Implementation
Agent: oauth-minion
Model: sonnet
Blocked by: none
Deliverables:
  - OAuth device flow implementation in src/auth/oauth.js
  - Token refresh logic
  - Keychain integration for secure storage
Prompt: |
  Implement OAuth 2.0 authentication for a GitHub MCP server using the device
  flow pattern. Target audience is developers using this server in Claude Code.

  Requirements:
  - Device flow (better UX than web redirect for CLI context)
  - Token refresh to minimize re-authentication
  - Secure token storage using system keychain
  - Clear error messages when auth fails

  Create src/auth/oauth.js with exported functions for:
  - initiateDeviceFlow()
  - pollForToken()
  - refreshToken()
  - getStoredToken()

  Do NOT implement the MCP server integration (mcp-minion handles that).
  Focus only on the OAuth flow and token management.

Task 2: MCP Server Core
Agent: mcp-minion
Model: sonnet
Blocked by: Task 1
Deliverables:
  - MCP server implementation in src/server.js
  - Tool schemas for GitHub operations
  - Integration with OAuth module
Prompt: |
  [detailed prompt for mcp-minion...]

Task 3: Test Suite
Agent: test-minion
Model: sonnet
Blocked by: Task 2
...

Task 4: User Documentation
Agent: user-docs-minion
Model: sonnet
Blocked by: Task 2
...

Risks and Mitigations:
- Rate limiting: Implement exponential backoff and clear user messaging
- Token security: Use system keychain, never log tokens
- Large repos: Add pagination and timeout handling

Verification Steps:
1. Test OAuth flow end-to-end
2. Verify MCP server responds to tool calls
3. Run integration tests
4. Validate documentation completeness
```

At this point, nefario presents the plan and waits for your approval.

#### Phase 4: Execution

After you approve, the main session creates a team and spawns the specialist agents with the prompts from the plan. Independent tasks run in parallel. Tasks with dependencies run in sequence.

You see progress updates as agents complete their work. When all tasks finish, results are synthesized and presented to you.

### Tips for Success

**Be specific in your task description.** Include context about the target users, required features, and any constraints. "Build an MCP server with auth" is vague. "Build an MCP server for GitHub integration with OAuth device flow, targeting developers using Claude Code" gives nefario and the specialists clear direction.

**Review the plan before approving.** The synthesis phase presents a complete execution plan. If something looks wrong or incomplete, you can ask for modifications before execution begins.

**For simple tasks, skip nefario.** If you know exactly which specialist you need and the scope is clear, just call them directly with `@specialist-name`. You don't need orchestration overhead for single-domain work.

**Trust the specialists.** Nefario consults experts for planning, which catches issues early. If oauth-minion says "device flow is better than web redirect for CLI tools," that's domain expertise you benefit from.

**Use the shortcut for simpler multi-agent tasks.** The skill supports MODE: PLAN which skips specialist consultation and has nefario plan directly. This works well for tasks where you know which 2-3 agents you need and the handoffs are straightforward.

## Directory Structure

```
despicable-agents/
├── the-plan.md              # Canonical spec (source of truth, human-edited)
├── CLAUDE.md                # Project instructions
├── LICENSE                  # Apache 2.0
├── README.md                # This file
│
├── .claude/
│   └── skills/
│       └── lab/             # Skill for checking and rebuilding agents
│
├── gru/
│   ├── AGENT.md            # Deployable agent file
│   └── RESEARCH.md         # Domain research backing the system prompt
│
├── nefario/
│   ├── AGENT.md
│   └── RESEARCH.md
│
└── minions/
    ├── mcp-minion/
    │   ├── AGENT.md
    │   └── RESEARCH.md
    ├── oauth-minion/
    │   ├── AGENT.md
    │   └── RESEARCH.md
    ├── api-design-minion/
    │   ├── AGENT.md
    │   └── RESEARCH.md
    ├── iac-minion/
    │   ├── AGENT.md
    │   └── RESEARCH.md
    ├── edge-minion/
    │   ├── AGENT.md
    │   └── RESEARCH.md
    ├── data-minion/
    │   ├── AGENT.md
    │   └── RESEARCH.md
    ├── ai-modeling-minion/
    │   ├── AGENT.md
    │   └── RESEARCH.md
    ├── frontend-minion/
    │   ├── AGENT.md
    │   └── RESEARCH.md
    ├── test-minion/
    │   ├── AGENT.md
    │   └── RESEARCH.md
    ├── debugger-minion/
    │   ├── AGENT.md
    │   └── RESEARCH.md
    ├── devx-minion/
    │   ├── AGENT.md
    │   └── RESEARCH.md
    ├── security-minion/
    │   ├── AGENT.md
    │   └── RESEARCH.md
    ├── observability-minion/
    │   ├── AGENT.md
    │   └── RESEARCH.md
    ├── ux-strategy-minion/
    │   ├── AGENT.md
    │   └── RESEARCH.md
    ├── ux-design-minion/
    │   ├── AGENT.md
    │   └── RESEARCH.md
    ├── software-docs-minion/
    │   ├── AGENT.md
    │   └── RESEARCH.md
    └── user-docs-minion/
        ├── AGENT.md
        └── RESEARCH.md
```

## Key Concepts

### The Plan

`the-plan.md` is the canonical specification for all agents. It defines:

- Agent remits (what each agent does and does NOT do)
- Tools and model assignments
- Delegation patterns (which agents collaborate on which tasks)
- System prompt structure requirements
- Versioning metadata

**Important**: Only the human owner should modify `the-plan.md`. Agents read it but never edit it.

### Agent Files

Each agent directory contains two files:

- **AGENT.md** - The deployable agent file with YAML frontmatter and system prompt. This is what Claude Code loads.
- **RESEARCH.md** - Comprehensive domain research that backs the system prompt. Not deployed, kept as reference for rebuilds.

### Versioning

Agent versions are tracked through two metadata fields:

| Field | Location | Purpose |
|-------|----------|---------|
| `spec-version` | Agent spec in `the-plan.md` | Current version of the spec |
| `x-plan-version` | `AGENT.md` frontmatter | Spec version this build was based on |
| `x-build-date` | `AGENT.md` frontmatter | When `AGENT.md` was last generated |

When `x-plan-version` in an `AGENT.md` is less than the current `spec-version` in `the-plan.md`, that agent needs regeneration.

### Agent Boundaries

Each agent has clear boundaries defined in their "Does NOT do" section. These boundaries create clean handoff points for delegation. When an agent encounters work outside their domain, they delegate to the appropriate specialist.

For example:
- **mcp-minion** delegates general OAuth work to **oauth-minion**
- **frontend-minion** delegates visual design decisions to **ux-design-minion**
- **debugger-minion** delegates security vulnerability fixes to **security-minion**

### Team Coordination

Agents can work:

- **Independently** - Single agent handles the entire task
- **With support** - Primary agent leads, supporting agents provide input
- **As a team** - Coordinated by **nefario**, multiple agents collaborate

Nefario's system prompt includes a delegation table that maps task types to primary and supporting agents, enabling automatic routing of complex work.

## Design Principles

### Generic Domain Specialists

Agents are deep domain experts, not project-specific assistants. They bring expertise without assumptions about your project structure, tech stack, or business domain. Project-specific context belongs in your project's `CLAUDE.md` file.

### Publishable

All agents are publishable under Apache 2.0. They contain:

- No personally identifiable information (PII)
- No proprietary patterns or trade secrets
- No project-specific implementation details

This makes the agents safe to share and reuse across organizations.

### Composable

Agents can be combined into different teams for different projects. Use all 19 for comprehensive coverage, or deploy only the agents relevant to your project. Each agent's clear boundaries make delegation unambiguous.

### Persistent Learners

All agents use `memory: user` to build knowledge across sessions. They learn from mistakes, remember patterns that work, and continuously improve. Their memory is scoped to your user account, so learnings persist across all projects.

## Contributing

Contributions are welcome. When contributing:

### Requirements

- **All content must be in English** - Code, documentation, research, and agent prompts
- **No PII** - No names, emails, company-specific data, or personal information
- **No proprietary data** - Agents must remain publishable under Apache 2.0
- **Follow agent boundaries** - Respect the "Does NOT do" sections; don't expand remits without discussion

### Making Changes

1. **Research changes**: Update `RESEARCH.md` in the agent's directory with new findings
2. **Spec changes**: Propose changes to `the-plan.md` via pull request
3. **Build changes**: If the spec changes, bump the `spec-version` and rebuild affected agents
4. **Test**: Deploy locally and verify the agent works as expected
5. **Document**: Update this README if you add new agents or change the structure

### Pull Request Process

1. Fork the repository
2. Create a feature branch
3. Make your changes following the requirements above
4. Test your changes locally
5. Submit a pull request with a clear description of what changed and why

## License

Apache License 2.0. See [LICENSE](LICENSE) for full text.

This project is designed to be freely usable, modifiable, and shareable. All agents and supporting documentation are provided under the same license.

## Resources

- [Claude Code Documentation](https://code.claude.com/docs)
- [Claude Code Agent Specification](https://code.claude.com/docs/en/sub-agents)
- [Agent Teams in Claude Code](https://code.claude.com/docs/en/agent-teams)
- [Model Context Protocol](https://modelcontextprotocol.io)

## Support

For issues, questions, or suggestions:

- Open an issue on GitHub
- Review existing issues before creating new ones
- Provide clear reproduction steps for bugs
- Include agent name and version for agent-specific issues

---

Built with Claude Code. Maintained by domain specialists (the agents themselves).
