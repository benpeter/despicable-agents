[< Back to README](../README.md)

# Using Nefario

Nefario is the orchestrator for complex, multi-domain tasks. When a task spans multiple specialist areas, nefario decomposes it, routes work to the right experts, and coordinates their collaboration.

## When to Use Nefario

Use `/nefario` when your task requires multiple specialists working together. Use individual agents directly for single-domain work.

**Use `/nefario` for:**

- "Build an MCP server with OAuth, tests, and user documentation" -- spans mcp-minion, oauth-minion, test-minion, user-docs-minion
- "Create a new REST API with security review, observability, and API docs" -- spans api-design-minion, security-minion, observability-minion, software-docs-minion
- "Add edge caching to our app with monitoring and performance testing" -- spans edge-minion, observability-minion, test-minion
- "Design and implement a user onboarding flow with UI, docs, and analytics" -- spans ux-strategy-minion, ux-design-minion, frontend-minion, user-docs-minion, observability-minion

**Call specialists directly for:**

- "Fix this CSS layout bug in the header component" -- `@frontend-minion`
- "Review this API design for REST best practices" -- `@api-design-minion`
- "Should we adopt the new Agent-to-Agent protocol?" -- `@gru`
- "Write a troubleshooting guide for this error message" -- `@user-docs-minion`
- "Debug why this function is leaking memory" -- `@debugger-minion`

**Rule of thumb**: If you can name the single specialist who should handle it, call them directly. If you need to say "we'll need X, Y, and Z working together," use `/nefario`.

## How to Invoke

```
/nefario <describe your task>
```

Be specific in your task description. More context leads to better planning.

**Good examples:**
```
/nefario Build an MCP server that provides GitHub repository tools with OAuth
authentication. Include tests and user documentation. Target users are
developers integrating GitHub into their Claude workflows.

/nefario Create a REST API for user management (CRUD operations) with JWT
authentication, rate limiting, comprehensive error handling, OpenAPI
documentation, and observability instrumentation.

/nefario Design and implement a developer onboarding tutorial for our CLI tool.
The tutorial should walk through installation, basic usage, and common
workflows. Include interactive examples and troubleshooting tips.
```

**Less helpful examples:**
```
/nefario Build something with MCP
/nefario Make the API better
/nefario Fix the docs
```

## What Happens: The Nine Phases

Nefario follows a structured process: plan with specialists, review the plan, execute, then verify the results. Here is what you experience at each phase.

**Phase 1 -- Meta-Planning.** Nefario reads your codebase and figures out which specialists to consult. You see the list of specialists and what each will be asked. No action needed from you -- this is informational.

**Phase 2 -- Specialist Planning.** Specialists are consulted in parallel for domain-specific input. This runs in the background. Each specialist contributes recommendations, proposed tasks, and risk assessments from their area of expertise. You wait while this happens.

**Phase 3 -- Synthesis.** Nefario consolidates all specialist input into a single execution plan: specific tasks, owners, dependencies, and agent prompts. Conflicts between specialists are resolved. Cross-cutting concerns (security, testing, documentation, usability, observability) are verified -- if a specialist did not raise them, nefario adds them. You receive the plan for review.

**Phase 3.5 -- Architecture Review.** Before you see the final plan, cross-cutting reviewers examine it. Security and testing reviews are mandatory; others trigger based on plan scope. Reviewers return APPROVE, ADVISE (non-blocking warnings), or BLOCK (halts until resolved). This catches architectural issues that are cheap to fix in a plan and expensive to fix in code.

**Phase 4 -- Execution.** After you approve the plan, specialist agents are spawned with prompts from the plan. Independent tasks run in parallel; dependent tasks run in sequence. At high-impact decision points, approval gates pause execution and ask for your input. When all tasks finish, post-execution verification begins.

**Phase 5 -- Code Review (conditional).** Runs when Phase 4 produced or modified code. Three reviewers -- code-review-minion, lucy, and margo -- examine the output for quality, convention adherence, and over-engineering. Issues are routed back to the producing agent for fixes (capped at 2 rounds). You do not see this unless a problem surfaces.

**Phase 6 -- Test Execution (conditional).** Runs when tests exist in the project. Executes in layers: lint/type-check, unit tests, integration/E2E. Failures are routed to the producing agent. Pre-existing failures are non-blocking. You do not see this unless a problem surfaces.

**Phase 7 -- Deployment (conditional).** Only runs when you explicitly requested deployment at plan approval time. Runs existing deployment commands (e.g., `./install.sh`). You do not see this unless a problem surfaces.

**Phase 8 -- Documentation (conditional).** Runs when execution outcomes trigger documentation needs (new APIs, architecture changes, user-facing features). Technical and user-facing documentation are updated in parallel. You do not see this unless a problem surfaces.

After all applicable phases complete, you receive a wrap-up summary with the results.

## Tips for Success

**Be specific in your task description.** Include context about target users, required features, and constraints. "Build an MCP server with auth" is vague. "Build an MCP server for GitHub integration with OAuth device flow, targeting developers using Claude Code" gives nefario and the specialists clear direction.

**Review the plan before approving.** The synthesis phase presents a complete execution plan. If something looks wrong or incomplete, ask for modifications before execution begins.

**For simple tasks, skip nefario.** If you know exactly which specialist you need and the scope is clear, call them directly with `@specialist-name`. Orchestration overhead is unnecessary for single-domain work.

**Trust the specialists.** Nefario consults domain experts for planning, which catches issues early. If oauth-minion says "device flow is better than web redirect for CLI tools," that is domain expertise you benefit from.

**Use MODE: PLAN for simpler multi-agent tasks.** The skill supports a simplified mode that skips specialist consultation and has nefario plan directly. This works well when you know which 2-3 agents you need and the handoffs are straightforward.

---

For the technical architecture behind the orchestration process, see [Orchestration Architecture](orchestration.md).
