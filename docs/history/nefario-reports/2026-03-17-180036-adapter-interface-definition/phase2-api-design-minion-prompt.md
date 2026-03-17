You are contributing to the PLANNING phase of a multi-agent project.
You are NOT executing yet — you are providing your domain expertise
to help build a comprehensive plan.

## Project Task
Define the `DelegationRequest` and `DelegationResult` types that all adapters implement for a multi-harness orchestrator (nefario). These types are the contract between the orchestrator and external coding tool adapters (Codex CLI, Aider, future tools).

Fields specified in the roadmap:
- `DelegationRequest`: agent name, task prompt (already stripped of Claude Code-specific instructions), instruction file path, working directory, model tier (`opus` | `sonnet`), required tools list
- `DelegationResult`: exit code, changed files (from git diff), stdout summary, stderr, raw diff reference
- No implementation — types and contracts only
- Language/format matches the surrounding codebase (document the decision; do not assume)

Acceptance criteria:
- Types are defined and documented
- Interface is minimal — covers Codex and Aider use cases, nothing more
- No harness-specific fields in the shared types

## Your Planning Question
The `DelegationRequest` and `DelegationResult` types define the contract between the nefario orchestrator and external coding tool adapters (Codex CLI, Aider, future tools). Given the fields listed in the roadmap, what is the minimal, well-structured interface? Specifically:
(a) Should model tier be an enum or a string?
(b) Should changed files be a list of paths or include richer metadata (e.g., added/modified/deleted)?
(c) Should exit code distinguish between adapter failure vs. task failure?
(d) Are there any fields needed to support both Codex (structured JSON output) and Aider (git-diff-based collection) that the roadmap spec might be missing?

## Context
Read these files for context:
- /Users/ben/github/benpeter/despicable-agents/.claude/worktrees/external-harness/docs/external-harness-integration.md (gap analysis, current delegation model, tool inventory)
- /Users/ben/github/benpeter/despicable-agents/.claude/worktrees/external-harness/docs/external-harness-roadmap.md (Issue 1.1 scope, Issues 2.1-2.2 and 3.1-3.3 for downstream consumer context)

Important: The codebase is pure Markdown + shell (no JS/TS/Python). There is no programming language code.

## Instructions
1. Read relevant files to understand the current state
2. Apply your domain expertise to the planning question
3. Identify risks, dependencies, and requirements from your perspective
4. If you believe additional specialists should be involved that
   aren't already part of the planning, say so and explain why
5. Return your contribution in this format:

## Domain Plan Contribution: api-design-minion

### Recommendations
<your expert recommendations for this aspect of the task>

### Proposed Tasks
<specific tasks that should be in the execution plan>
For each task: what to do, deliverables, dependencies

### Risks and Concerns
<things that could go wrong from your domain perspective>

### Additional Agents Needed
<any specialists not yet involved who should be, and why>
(or "None" if the current team is sufficient)

6. Write your complete contribution to /var/folders/3k/bfjvvz9s6dvdn_hvlhvr8lc00000gn/T//nefario-scratch-6xYwvg/adapter-interface-definition/phase2-api-design-minion.md
