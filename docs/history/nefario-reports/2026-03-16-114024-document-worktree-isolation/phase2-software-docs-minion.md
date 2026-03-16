## Domain Plan Contribution: software-docs-minion

### Recommendations

**Placement: Option (a) -- new section in `docs/orchestration.md`, Section 6.**

This is the clear winner. Here is the reasoning:

1. **`docs/orchestration.md` is the right home.** Worktree isolation is an operational pattern for running the orchestration process. The document already covers the full orchestration lifecycle: phases (Section 1), delegation (Section 2), gates (Section 3), reports (Section 4), and commit points (Section 5). Parallel worktree sessions are a natural extension of commit points and branching -- they describe how to run multiple orchestrations concurrently by leveraging git's built-in worktree mechanism. Section 6 slots in cleanly after commit points.

2. **Option (b) -- a standalone sub-doc -- is overkill.** The content scope is small: a few paragraphs covering when/how/limitations. Creating `docs/worktree-isolation.md` would add a row to the sub-document table in `architecture.md`, inflate the hub-and-spoke graph, and produce a file with barely two screenfuls of content. The existing docs already trend toward this problem (11 contributor/architecture sub-docs). The documentation minimalism principle says: don't create a new document when an existing one can absorb the content without becoming unwieldy. `orchestration.md` is long but well-sectioned -- one more section does not push it past the threshold.

3. **Option (c) -- `docs/using-nefario.md` -- is tempting but wrong.** The user-facing guide explains *what you experience* at each phase. Worktree isolation is a *how-to for power users*, not a phase explanation. It belongs in the contributor/architecture tier. However, `using-nefario.md` should gain a brief cross-reference (2-3 sentences in the "Tips for Success" section) pointing advanced users to the orchestration doc for parallel session setup.

**Cross-references needed:**

- `docs/using-nefario.md` "Tips for Success" section: add a tip about parallel orchestrations linking to the new Section 6.
- `docs/commit-workflow.md` Section 1 (Branching Strategy): add a note that worktree-based sessions each create their own `nefario/<slug>` branch in their own worktree, with a forward-reference to orchestration.md Section 6.
- No change needed to `docs/architecture.md` sub-document table (no new sub-doc is being created).

**Section structure for the new Section 6:**

The section should follow the same pattern as existing sections (numbered heading, brief intro, then subsections). Proposed outline:

```
## 6. Parallel Orchestration with Git Worktrees

Brief intro: what this enables, when you'd want it.

### When to Use Worktree Isolation
- Independent workstreams that don't touch the same files
- Examples: auth refactor + docs overhaul, API v2 + new monitoring
- Anti-pattern: two streams that both modify the same config or schema

### How It Works
- `git worktree add` creates an independent working directory
- `claude -w <worktree-name>` opens a session in that worktree
- `/nefario` in each terminal runs independent orchestrations
- Each session gets its own branch, scratch files, reports

### Merge-Back Workflow
- Standard git PRs from each worktree branch
- Same as any feature branch -- review, merge, delete worktree
- Merge conflicts resolved manually if worktrees drifted into shared files

### Limitations
- No automatic merge between sessions
- No cross-session coordination or awareness
- Each session has its own context window (no shared state)
- Conflicting file edits discovered at PR merge time, not during execution
```

### Proposed Tasks

**Task 1: Add Section 6 to `docs/orchestration.md`**
- What: Write Section 6 "Parallel Orchestration with Git Worktrees" following the outline above. Place it after Section 5 (Commit Points). Update the document's introductory paragraph (line 7) to mention the new section.
- Deliverables: Updated `docs/orchestration.md` with Section 6.
- Dependencies: None.

**Task 2: Add cross-reference in `docs/using-nefario.md`**
- What: Add a new tip to the "Tips for Success" section (after the existing tips, before "Working with Project Skills"). The tip should briefly explain that you can run parallel nefario orchestrations in separate git worktrees, with a link to `orchestration.md` Section 6 for the full guide. Keep it to 3-4 sentences -- enough that a user knows the capability exists and where to learn more.
- Deliverables: Updated `docs/using-nefario.md` with the new tip.
- Dependencies: Task 1 (the link target must exist).

**Task 3: Add forward-reference in `docs/commit-workflow.md`**
- What: In Section 1 (Branching Strategy), after the "Branch creation rules" subsection, add a brief note (1-2 sentences) that when using git worktrees for parallel orchestration, each worktree independently creates its own `nefario/<slug>` branch. Link to `orchestration.md` Section 6. This is a minor addition -- do not restructure the existing content.
- Deliverables: Updated `docs/commit-workflow.md` with the forward-reference.
- Dependencies: Task 1 (the link target must exist).

### Risks and Concerns

1. **Scope creep into git tutorial territory.** The section must document the orchestration pattern, not teach git worktrees. Assume the reader knows `git worktree add` or can look it up. A one-line command example is sufficient; a full walkthrough of worktree management is out of scope and would make the section stale as git evolves.

2. **Implying cross-session coordination exists or is planned.** The "Limitations" subsection must be unambiguous. Users will read "parallel orchestration" and assume there is some coordination layer. The section needs to set expectations clearly: each session is fully independent. No shared planning, no conflict detection, no synchronized gates.

3. **Stale example commands.** If the section includes literal `claude -w` commands, those will break if Claude Code changes its worktree flag syntax. Keep the command examples minimal and note they reflect current Claude Code CLI usage.

4. **orchestration.md length.** The document is already 611 lines. Adding Section 6 will push it to roughly 660-680 lines. This is within tolerance -- the document is well-structured with clear section boundaries and a table of contents in the intro paragraph. But it should not grow further without considering a split.

### Additional Agents Needed

None. This is a pure documentation task touching three existing Markdown files. No code changes, no UX decisions, no security surface. A single documentation specialist (software-docs-minion) is sufficient for execution. Lucy and margo should review per standard Phase 3.5 process, but no additional planning input is needed.
