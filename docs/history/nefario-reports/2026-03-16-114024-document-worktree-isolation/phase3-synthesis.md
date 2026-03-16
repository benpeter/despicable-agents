## Delegation Plan

**Team name**: document-worktree-isolation
**Description**: Document the existing capability of running parallel nefario orchestrations in separate git worktrees. Pure documentation -- three file edits, no code changes.

### Task 1: Add Section 6 "Parallel Orchestration with Git Worktrees" to docs/orchestration.md
- **Agent**: software-docs-minion
- **Delegation type**: standard
- **Model**: sonnet
- **Mode**: default
- **Blocked by**: none
- **Approval gate**: no
- **Prompt**: |
    You are updating `docs/orchestration.md` to add a new Section 6 documenting
    parallel nefario orchestrations via git worktrees. This is a pure documentation
    task -- no code changes, no new features, no framework changes. You are documenting
    an already-working capability.

    ## What to do

    1. Add a new `## 6. Parallel Orchestration with Git Worktrees` section after
       Section 5 (Commit Points in Execution Flow), before the end of the file.
       Follow the existing section pattern: numbered heading, brief intro, then subsections.

    2. Update the document's introductory paragraph (line 7) to mention the new section.
       Currently it reads: "...commit points in the execution flow (Section 5)."
       Append: "...and parallel orchestration via git worktrees (Section 6)."

    3. Structure the new section as follows:

    ```
    ## 6. Parallel Orchestration with Git Worktrees

    Brief intro: Running multiple nefario orchestrations simultaneously in separate
    git worktrees. Each session operates independently with its own branch, scratch
    files, and reports.

    ### When to Use Worktree Isolation
    - Independent workstreams that don't touch the same files
    - Examples: auth refactor + docs overhaul, API v2 + new monitoring stack
    - Anti-pattern: two streams that both modify the same config file or schema

    ### How It Works
    - `git worktree add` creates an independent working directory with its own checkout
    - `claude -w <worktree-name>` opens a Claude Code session scoped to that worktree
    - `/nefario` in each terminal runs independent orchestrations
    - Each session gets its own `nefario/<slug>` branch, scratch files, and execution reports
    - Sessions share the same git object database but have separate working trees

    ### Merge-Back Workflow
    - Standard git PRs from each worktree branch to main
    - Same review/merge process as any feature branch
    - Merge conflicts resolved manually if worktrees drifted into shared files
    - After merge, clean up worktrees with `git worktree remove`

    ### Limitations
    - No automatic merge between sessions
    - No cross-session coordination or awareness
    - Each session has its own context window -- no shared state
    - File conflicts discovered at PR merge time, not during execution
    - Worktrees that modify the same files will require manual conflict resolution
    ```

    ## Writing guidelines

    - Match the existing document's tone and density. Sections 1-5 are technical
      reference material, not tutorials. Section 6 should read the same way.
    - Keep command examples minimal. Show `git worktree add` and `claude -w` once each.
      Do NOT write a git worktree tutorial -- assume the reader knows git or can look it up.
    - The Limitations subsection must be unambiguous: each session is fully independent.
      No shared planning, no conflict detection, no synchronized gates.
    - Do not imply cross-session coordination exists or is planned.
    - Keep the section to roughly 40-60 lines of Markdown. Sections 1-5 are longer
      because they cover complex multi-step processes; worktree isolation is simple
      and should stay concise.

    ## What NOT to do

    - Do NOT modify any other files (cross-references are handled in separate tasks)
    - Do NOT add a new sub-document -- this goes in the existing file
    - Do NOT add entries to `docs/architecture.md` sub-document table
    - Do NOT write a git worktree tutorial or man page
    - Do NOT propose any code changes or new features

    ## File to edit

    `docs/orchestration.md` -- the full file is 611 lines. You are adding Section 6
    after the last line and updating the intro paragraph at line 7.

- **Deliverables**: Updated `docs/orchestration.md` with Section 6 and updated intro paragraph
- **Success criteria**: Section 6 exists after Section 5, intro paragraph references Section 6, content covers when/how/merge/limitations, document reads cohesively

### Task 2: Add cross-reference in docs/using-nefario.md
- **Agent**: software-docs-minion
- **Delegation type**: standard
- **Model**: sonnet
- **Mode**: default
- **Blocked by**: Task 1
- **Approval gate**: no
- **Prompt**: |
    You are adding a brief tip about parallel orchestrations to `docs/using-nefario.md`.
    This is a cross-reference to the new Section 6 in `docs/orchestration.md`
    (which already exists by the time this task runs).

    ## What to do

    Add a new tip to the "Tips for Success" section. Place it after the existing
    "Use MODE: PLAN for simpler multi-agent tasks" tip and before "Working with
    Project Skills". The tip should:

    1. Start with a bold lead like the existing tips: **Run parallel orchestrations
       in separate git worktrees.**
    2. Explain in 2-3 sentences that you can run multiple `/nefario` sessions
       simultaneously using git worktrees, each operating independently on its own
       branch. This is useful when you have independent workstreams that don't touch
       the same files.
    3. Link to the full guide: "See [Parallel Orchestration with Git Worktrees](orchestration.md#6-parallel-orchestration-with-git-worktrees) for setup and limitations."

    ## What NOT to do

    - Do NOT repeat the full content from Section 6 -- this is a pointer, not a duplicate
    - Do NOT restructure the existing Tips for Success section
    - Do NOT modify any other section of the file
    - Do NOT modify any other files

    ## File to edit

    `docs/using-nefario.md` -- the Tips for Success section starts at line 126.
    Add the new tip after line 136 (the MODE: PLAN tip paragraph) and before
    line 145 ("## Working with Project Skills").

- **Deliverables**: Updated `docs/using-nefario.md` with new parallel orchestration tip
- **Success criteria**: New tip exists in Tips for Success, links to orchestration.md Section 6, is 3-5 lines, does not duplicate Section 6 content

### Task 3: Add forward-reference in docs/commit-workflow.md
- **Agent**: software-docs-minion
- **Delegation type**: standard
- **Model**: sonnet
- **Mode**: default
- **Blocked by**: Task 1
- **Approval gate**: no
- **Prompt**: |
    You are adding a brief forward-reference about worktree-based parallel
    orchestration to `docs/commit-workflow.md`. This is a small addition to
    Section 1 (Branching Strategy).

    ## What to do

    In Section 1, after the "Branch creation rules" subsection (which ends at
    line 33), add a brief note (1-2 sentences) explaining that when using git
    worktrees for parallel orchestration, each worktree independently creates
    its own `nefario/<slug>` branch following the same naming convention. Link
    to the full guide: "See [Parallel Orchestration with Git Worktrees](orchestration.md#6-parallel-orchestration-with-git-worktrees)."

    ## What NOT to do

    - Do NOT restructure the existing branching section
    - Do NOT add more than 2-3 sentences
    - Do NOT modify any other section of the file
    - Do NOT modify any other files

    ## File to edit

    `docs/commit-workflow.md` -- the Branch creation rules subsection ends at line 33.
    Add the note after line 33 and before the "### PR Creation at Wrap-Up" heading
    at line 35.

- **Deliverables**: Updated `docs/commit-workflow.md` with worktree forward-reference
- **Success criteria**: Note exists after Branch creation rules, links to orchestration.md Section 6, is 1-3 sentences, does not restructure existing content

### Cross-Cutting Coverage

- **Testing**: Not applicable. Pure documentation task with no executable output.
- **Security**: Not applicable. No code, no auth, no APIs, no user input, no infrastructure changes.
- **Usability -- Strategy**: Not applicable. Documenting an existing capability, not introducing new user-facing features. No journey changes, no cognitive load impact.
- **Usability -- Design**: Not applicable. No user-facing interfaces produced.
- **Documentation**: Covered by Tasks 1-3 (software-docs-minion). This IS the documentation task.
- **Observability**: Not applicable. No runtime components produced.

### Architecture Review Agents

- **Mandatory** (5): security-minion, test-minion, ux-strategy-minion, lucy, margo
- **Discretionary picks**: none
  - ux-design-minion: NO -- no UI components or visual layouts produced
  - accessibility-minion: NO -- no web-facing HTML/UI produced
  - sitespeed-minion: NO -- no web-facing runtime code produced
  - observability-minion: NO -- no runtime components produced
  - user-docs-minion: NO -- changes are to contributor/architecture docs, not end-user docs. End users of the despicable-agents toolkit are developers reading architecture docs, which is software-docs-minion territory.
- **Not selected**: ux-design-minion, accessibility-minion, sitespeed-minion, observability-minion, user-docs-minion

### Conflict Resolutions

None. Single specialist (software-docs-minion) provided the only planning contribution. No conflicting recommendations to resolve.

### Risks and Mitigations

1. **Scope creep into git tutorial territory.** Mitigated by explicit prompt instructions to keep command examples minimal and assume git knowledge. The Limitations subsection must be factual and unambiguous.

2. **Implying cross-session coordination exists or is planned.** Mitigated by explicit prompt instruction: "Do not imply cross-session coordination exists or is planned." The Limitations subsection must clearly state each session is fully independent.

3. **Stale command examples.** The `claude -w` flag syntax could change. Mitigated by keeping examples minimal (one occurrence) and noting they reflect current CLI usage. Acceptable risk for documentation.

4. **orchestration.md growing too long.** Currently 611 lines, will reach approximately 660-680. Within tolerance -- the document is well-sectioned with clear boundaries. Not actionable now but noted for future consideration.

### Execution Order

```
Batch 1: Task 1 (Section 6 in orchestration.md)
  |
  +-- no gate --
  |
Batch 2: Task 2 (cross-ref in using-nefario.md) + Task 3 (forward-ref in commit-workflow.md) [parallel]
```

Tasks 2 and 3 both depend on Task 1 (the link target must exist) but are independent of each other and can run in parallel.

No mid-execution approval gates. All three tasks are additive documentation edits that are easy to reverse and have no downstream dependents beyond each other. Per the gate classification matrix: easy to reverse + low blast radius = NO GATE.

### Verification Steps

After all three tasks complete:
1. Verify `docs/orchestration.md` contains Section 6 with four subsections (When to Use, How It Works, Merge-Back, Limitations)
2. Verify the intro paragraph on line 7 references Section 6
3. Verify `docs/using-nefario.md` Tips for Success has the new parallel orchestration tip with a working link
4. Verify `docs/commit-workflow.md` Section 1 has the worktree forward-reference with a working link
5. Verify all three Markdown link anchors resolve correctly (anchor text matches heading slugs)
