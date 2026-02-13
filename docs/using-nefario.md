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

Nefario follows a structured process: plan with specialists, review the plan, execute, then verify the results. The status line and all approval prompts include the current phase, so you always know where you are in the process. Here is what you experience at each phase.

**Phase 1 -- Meta-Planning.** Nefario reads your codebase and figures out which specialists to consult. You see the proposed team -- each specialist listed with a brief rationale for why they were selected, plus a list of available specialists that were not selected. You then approve the team, adjust it (add or remove specialists), or reject the orchestration entirely; if you make large changes, nefario refreshes the plan to account for the new team composition. This is a quick confirmation, not a detailed review -- glance at the names, make sure nothing is missing or surprising, and approve.

**Phase 2 -- Specialist Planning.** The specialists you confirmed in Phase 1 are consulted in parallel for domain-specific input. You see a brief status marker when this phase begins, then wait while the specialists work in parallel. Each specialist contributes recommendations, proposed tasks, and risk assessments from their area of expertise.

**Phase 3 -- Synthesis.** You see a brief status marker when this phase begins. Nefario consolidates all specialist input into a single execution plan: specific tasks, owners, dependencies, and agent prompts. Conflicts between specialists are resolved. Cross-cutting concerns (security, testing, documentation, usability, observability) are verified -- if a specialist did not raise them, nefario adds them. You receive the plan for review.

**Phase 3.5 -- Architecture Review.** You see a brief status marker when this phase begins. Cross-cutting reviewers examine the synthesized plan. Security and testing reviews are mandatory; others trigger based on plan scope. Reviewers return APPROVE, ADVISE (non-blocking warnings), or BLOCK (halts until resolved); if you adjust the reviewer set and the changes are significant, nefario re-evaluates the plan with the updated reviewers. This catches architectural issues that are cheap to fix in a plan and expensive to fix in code.

**Phase 4 -- Execution.** You see a brief status marker when this phase begins. After you approve the plan, specialist agents are spawned with prompts from the plan. Independent tasks run in parallel; dependent tasks run in sequence. At high-impact decision points, approval gates pause execution and ask for your input. When all tasks finish, post-execution verification begins.

**Phase 5 -- Code Review (conditional).** Runs when Phase 4 produced or modified code. Three reviewers -- code-review-minion, lucy, and margo -- examine the output for quality, convention adherence, and over-engineering. Issues are routed back to the producing agent for fixes (capped at 2 rounds). You do not see this unless a problem surfaces.

**Phase 6 -- Test Execution (conditional).** Runs when tests exist in the project. Executes in layers: lint/type-check, unit tests, integration/E2E. Failures are routed to the producing agent. Pre-existing failures are non-blocking. You do not see this unless a problem surfaces.

**Phase 7 -- Deployment (conditional).** Only runs when you explicitly requested deployment at plan approval time. Runs existing deployment commands (e.g., `./install.sh`). You do not see this unless a problem surfaces.

**Phase 8 -- Documentation (conditional).** Runs when execution outcomes trigger documentation needs (new APIs, architecture changes, user-facing features). Technical and user-facing documentation are updated in parallel. You do not see this unless a problem surfaces.

After all applicable phases complete, you receive a wrap-up summary with the results. Git commit output is suppressed via `--quiet` flags -- only errors appear inline.

## Working Directory

Nefario operates on whichever project your Claude Code session is in. Reports, feature branches, and commits all target the current working directory's project. No configuration is needed -- invoke `/nefario` from any project after installing the toolkit.

## Tips for Success

**Be specific in your task description.** Include context about target users, required features, and constraints. "Build an MCP server with auth" is vague. "Build an MCP server for GitHub integration with OAuth device flow, targeting developers using Claude Code" gives nefario and the specialists clear direction.

**Review the plan before approving.** The synthesis phase presents a complete execution plan. If something looks wrong or incomplete, ask for modifications before execution begins.

**For simple tasks, skip nefario.** If you know exactly which specialist you need and the scope is clear, call them directly with `@specialist-name`. Orchestration overhead is unnecessary for single-domain work.

**Trust the specialists.** Nefario consults domain experts for planning, which catches issues early. If oauth-minion says "device flow is better than web redirect for CLI tools," that is domain expertise you benefit from.

**Use MODE: PLAN for simpler multi-agent tasks.** The skill supports a simplified mode that skips specialist consultation and has nefario plan directly. This works well when you know which 2-3 agents you need and the handoffs are straightforward.

## Working with Project Skills

If your project ships Claude Code skills (in `.claude/skills/` or `.skills/`), nefario discovers and incorporates them automatically during planning. No configuration is needed -- skills with a `name` and `description` in their SKILL.md frontmatter are detected in Phase 1 and woven into the execution plan alongside built-in specialists.

For example, if you have CDD skills installed and run `/nefario 'build a new block'`, nefario includes the CDD skill in the plan without any extra setup.

### How Skills Appear in the Plan

External skills are marked `(project skill)` in the execution plan so you can distinguish them from built-in specialists. Orchestration skills -- those with their own multi-phase workflow -- appear as a single task with a `Phases:` line rather than being decomposed into sub-tasks. Leaf skills appear in the `Available Skills` section of relevant task prompts.

### Overriding Skill Selection

If nefario picks the wrong handler for a task, correct it at the plan approval gate. Use the "Request changes" flow and specify which skill or agent should handle it:

```
Use the CDD skill for block building instead of frontend-minion.
```

Nefario regenerates the affected plan section with your override applied.

### Troubleshooting

**Skill not detected?** Verify the skill directory exists under `.claude/skills/` or `.skills/` and that its SKILL.md has `name` and `description` fields in the YAML frontmatter. Skills missing either field are silently skipped.

**Wrong skill selected?** Override at the plan approval gate as described above.

For the full discovery mechanism, precedence rules, and skill maintainer guidance, see [External Skill Integration](external-skills.md).

## Status Line

You can add a live status line to Claude Code that shows the current nefario task while orchestration is running.

### Setup

Requires `jq` (`brew install jq` on macOS if not already installed).

Run `/despicable-statusline` from within the despicable-agents repository. This is a project-local skill available when Claude Code is running in this repo. The effect is global -- it modifies `~/.claude/settings.json` -- so you only need to run it once.

The skill handles your existing configuration automatically:

- **No status line configured** -- sets up a complete default showing directory, model, context usage, and nefario status.
- **Standard status line without nefario** -- appends the nefario snippet to your existing command.
- **Nefario status already present** -- does nothing. Safe to re-run.
- **Non-standard setup** (e.g., a script file) -- prints manual instructions instead of modifying your config.

The skill validates JSON before and after writing, creates a backup at `~/.claude/settings.json.backup-statusline`, and rolls back on failure. It is idempotent -- safe to run multiple times.

Restart Claude Code or start a new conversation to activate.

### What It Shows

When nefario is orchestrating, the status bar appends the current phase and task summary after the standard info, updating at each phase transition:

`~/my-project | Claude Opus 4 | Context: 12% | P2 Planning | Build MCP server with OAuth...`

When nefario is not running, the status bar shows just the directory, model, and context usage.

### How It Works

The status line command extracts `session_id` from the JSON that Claude Code pipes to it, and writes it to `/tmp/claude-session-id` so the nefario skill can discover it. When nefario starts orchestrating, it reads the session ID from that file and writes the current phase and task summary to `/tmp/nefario-status-<session-id>`. The file is updated at each phase transition so the status line always reflects the current phase. The status line command checks for this file and appends its contents. When orchestration finishes, nefario removes the file.

<details>
<summary>Manual configuration (alternative)</summary>

If you prefer manual control or the skill cannot auto-modify your config, add the following to `~/.claude/settings.json`. If you already have a `statusLine` entry, merge the nefario-specific part (the `f="/tmp/nefario-status-..."` line) into your existing command.

```json
{
  "statusLine": {
    "type": "command",
    "command": "input=$(cat); dir=$(echo \"$input\" | jq -r '.workspace.current_dir // \"?\"'); model=$(echo \"$input\" | jq -r '.model.display_name // \"?\"'); used=$(echo \"$input\" | jq -r '.context_window.used_percentage // \"\"'); sid=$(echo \"$input\" | jq -r '.session_id // \"\"'); [ -n \"$sid\" ] && echo \"$sid\" > /tmp/claude-session-id; result=\"$dir | $model\"; if [ -n \"$used\" ]; then result=\"$result | Context: $(printf '%.0f' \"$used\")%\"; fi; f=\"/tmp/nefario-status-$sid\"; [ -n \"$sid\" ] && [ -f \"$f\" ] && ns=$(cat \"$f\" 2>/dev/null) && [ -n \"$ns\" ] && result=\"$result | $ns\"; echo \"$result\""
  }
}
```

Restart Claude Code or start a new conversation to activate.

If the skill's default command changes in the future, the SKILL.md at `.claude/skills/despicable-statusline/SKILL.md` is the authoritative source.

</details>

---

For the technical architecture behind the orchestration process, see [Orchestration Architecture](orchestration.md).
