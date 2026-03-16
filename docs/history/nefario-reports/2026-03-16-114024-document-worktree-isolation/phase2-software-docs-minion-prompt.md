You are contributing to the PLANNING phase of a multi-agent project.
You are NOT executing yet — you are providing your domain expertise
to help build a comprehensive plan.

## Project Task
Document the already-working capability of running parallel nefario orchestrations
in separate git worktrees. Add a section to the orchestration docs covering:
- How it works: `claude -w auth-refactor` then `/nefario` in each terminal
- When to use it: Independent workstreams that don't touch the same files
- Merge-back workflow: Standard git PRs from each worktree branch
- What NOT to expect: No automatic merge, no cross-session coordination

No code changes. No framework changes. Pure documentation.

## Your Planning Question
Where should worktree isolation documentation live within the existing docs structure?
Options: (a) new section in `docs/orchestration.md` (e.g., after Section 5),
(b) new linked sub-doc `docs/worktree-isolation.md`,
(c) section in the user-facing `docs/using-nefario.md`.

Consider the hub-and-spoke architecture in `docs/architecture.md` and the split
between contributor/architecture docs and user-facing docs. What cross-references
are needed?

## Context
Read these files:
- docs/architecture.md (hub structure, sub-document table)
- docs/orchestration.md (current 5 sections)
- docs/using-nefario.md (user-facing guide)

## Instructions
1. Read relevant files to understand the current state
2. Apply your domain expertise to the planning question
3. Identify risks, dependencies, and requirements from your perspective
4. If you believe additional specialists should be involved that
   aren't already part of the planning, say so and explain why
5. Return your contribution in this format:

## Domain Plan Contribution: software-docs-minion

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
6. Write your complete contribution to `/var/folders/3k/bfjvvz9s6dvdn_hvlhvr8lc00000gn/T//nefario-scratch-Vb3HFr/document-worktree-isolation/phase2-software-docs-minion.md`
