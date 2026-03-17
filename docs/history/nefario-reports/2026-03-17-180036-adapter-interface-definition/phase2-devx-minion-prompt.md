You are contributing to the PLANNING phase of a multi-agent project.
You are NOT executing yet — you are providing your domain expertise
to help build a comprehensive plan.

## Project Task
Define the `DelegationRequest` and `DelegationResult` types that all adapters implement for a multi-harness orchestrator. The codebase is entirely Markdown and shell scripts — no programming language code exists.

## Your Planning Question
The despicable-agents codebase is entirely Markdown and shell scripts -- no programming language code exists. The roadmap says "Language/format matches the surrounding codebase (document the decision; do not assume)." What is the right format for defining `DelegationRequest` and `DelegationResult` types in a Markdown-native project? Options include:
(a) pure Markdown specification with field tables
(b) YAML schema definition (like JSON Schema in YAML)
(c) TypeScript type definitions as a reference spec even though no TS exists in the project
(d) shell-level conventions (env vars, exit codes, file paths)

Consider that downstream consumers (Issue 1.2 config loading, Issues 2.1/3.2 adapter wrappers) will need to implement against this contract. What format gives the clearest contract while respecting the codebase's character?

## Context
Read these files for context:
- /Users/ben/github/benpeter/despicable-agents/.claude/worktrees/external-harness/install.sh (representative shell script)
- /Users/ben/github/benpeter/despicable-agents/.claude/worktrees/external-harness/assemble.sh (representative shell script)
- /Users/ben/github/benpeter/despicable-agents/.claude/worktrees/external-harness/CLAUDE.md (technology preferences: lightweight, vanilla)
- /Users/ben/github/benpeter/despicable-agents/.claude/worktrees/external-harness/docs/external-harness-roadmap.md (YAGNI constraint, "What NOT to Build" section)

## Instructions
1. Read relevant files to understand the current state
2. Apply your domain expertise to the planning question
3. Identify risks, dependencies, and requirements from your perspective
4. If you believe additional specialists should be involved that
   aren't already part of the planning, say so and explain why
5. Return your contribution in this format:

## Domain Plan Contribution: devx-minion

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

6. Write your complete contribution to /var/folders/3k/bfjvvz9s6dvdn_hvlhvr8lc00000gn/T//nefario-scratch-6xYwvg/adapter-interface-definition/phase2-devx-minion.md
