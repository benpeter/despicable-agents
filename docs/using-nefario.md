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

If you have a rough idea but aren't sure how to structure it, run `/despicable-prompter` first — it transforms vague descriptions into structured `/nefario` briefings with clear outcomes, success criteria, and scope.

## GitHub Issue Integration

Both `/nefario` and `/despicable-prompter` accept `#<n>` as the first argument to fetch task context from GitHub issues via the `gh` CLI.

**Usage examples:**

```
/despicable-prompter #42
/nefario #42
```

When you use `#<n>` syntax:

- **With `/despicable-prompter #42`**: Fetches issue #42, generates a structured brief from its body, then writes the brief back to the issue (updates both title and body). The brief is also displayed in chat for your review before starting work.

- **With `/nefario #42`**: Fetches issue #42 and uses its body as the task description for all phases. The issue body is treated as if you had typed it directly after `/nefario`.

**Appending additional context:**

You can add extra instructions after the issue number:

```
/despicable-prompter #42 also consider caching requirements
/nefario #42 skip phase 8
```

For `/despicable-prompter`, trailing text is appended to the issue body before generating the brief. For `/nefario`, trailing text is appended to the task prompt but not written back to the issue.

**Requirements:**

- The `gh` CLI must be installed and authenticated
- The issue must exist in the current repository
- For `/despicable-prompter`, the issue body must not contain secrets or sensitive content (checked before writing back)

**Automatic PR linking:**

When `/nefario` completes work started from an issue, it adds `Resolves #N` to the PR description, triggering GitHub's auto-close when the PR merges.

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

## Working Directory

Nefario operates on whichever project your Claude Code session is in. Reports, feature branches, and commits all target the current working directory's project. No configuration is needed -- invoke `/nefario` from any project after installing the toolkit.

## Tips for Success

**Be specific in your task description.** Include context about target users, required features, and constraints. "Build an MCP server with auth" is vague. "Build an MCP server for GitHub integration with OAuth device flow, targeting developers using Claude Code" gives nefario and the specialists clear direction.

**Review the plan before approving.** The synthesis phase presents a complete execution plan. If something looks wrong or incomplete, ask for modifications before execution begins.

**For simple tasks, skip nefario.** If you know exactly which specialist you need and the scope is clear, call them directly with `@specialist-name`. Orchestration overhead is unnecessary for single-domain work.

**Trust the specialists.** Nefario consults domain experts for planning, which catches issues early. If oauth-minion says "device flow is better than web redirect for CLI tools," that is domain expertise you benefit from.

**Use MODE: PLAN for simpler multi-agent tasks.** The skill supports a simplified mode that skips specialist consultation and has nefario plan directly. This works well when you know which 2-3 agents you need and the handoffs are straightforward.

## Status Line

You can add a live status line to Claude Code that shows the current nefario task while orchestration is running.

### Setup

Requires `jq` (`brew install jq` on macOS if not already installed).

Add the following to `~/.claude/settings.json`. If you already have a `statusLine` entry, merge the nefario-specific part (the `f="/tmp/nefario-status-..."` line) into your existing command.

```json
{
  "statusLine": {
    "type": "command",
    "command": "input=$(cat); dir=$(echo \"$input\" | jq -r '.workspace.current_dir // \"?\"'); model=$(echo \"$input\" | jq -r '.model.display_name // \"?\"'); used=$(echo \"$input\" | jq -r '.context_window.used_percentage // \"\"'); result=\"$dir | $model\"; if [ -n \"$used\" ]; then result=\"$result | Context: $(printf '%.1f' \"$used\")% used\"; fi; f=\"/tmp/nefario-status-${CLAUDE_SESSION_ID}\"; [ -f \"$f\" ] && ns=$(cat \"$f\" 2>/dev/null) && [ -n \"$ns\" ] && result=\"$result | $ns\"; echo \"$result\""
  }
}
```

Restart Claude Code or start a new conversation to activate.

### What It Shows

When nefario is orchestrating, the status bar appends the task summary after the standard info:

`~/my-project | Claude Opus 4 | Context: 12.3% used | Build MCP server with OAuth...`

When nefario is not running, the status bar shows just the directory, model, and context usage.

### How It Works

When nefario starts orchestrating, it writes a one-line task summary to a temporary file (`/tmp/nefario-status-<session-id>`). The status line command checks for this file and appends its contents. When orchestration finishes, nefario removes the file. If you run multiple Claude Code windows simultaneously, each shows its own nefario task independently -- no conflicts.

---

For the technical architecture behind the orchestration process, see [Orchestration Architecture](orchestration.md).
