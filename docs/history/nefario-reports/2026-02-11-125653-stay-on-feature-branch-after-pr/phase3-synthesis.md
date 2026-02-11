# Phase 3: Synthesis -- Stay on Feature Branch After PR Creation

## Delegation Plan

**Team name**: stay-on-feature-branch
**Description**: Remove the "return to default branch" behavior after PR creation so developers stay on the feature branch for continued local testing.

### Specialist Consensus

Both specialists (devx-minion, software-docs-minion) fully agree on:
- Remove the checkout, do not make it configurable (YAGNI)
- Preserve sentinel/marker cleanup in step 11
- Four files need updates: SKILL.md, commit-workflow.md, decisions.md, orchestration.md (verify-only)
- Historical reports are immutable -- do not touch
- The final summary should show current branch + escape hatch command

No conflicts to resolve.

### Task 1: Update SKILL.md and all documentation to stay on feature branch after PR

- **Agent**: devx-minion
- **Model**: sonnet
- **Mode**: bypassPermissions
- **Blocked by**: none
- **Approval gate**: no
- **Prompt**: |

    ## Task: Stay on feature branch after PR creation

    Remove the "return to default branch" behavior from the nefario skill
    and update all documentation to match. After PR creation (or decline),
    the session should stay on the feature branch.

    ### Why

    Developers want to continue local testing after PR creation without
    manually switching branches. No downstream workflows depend on being
    back on main. Standard Git tooling (gh pr create, git push) does not
    switch branches as a side effect. The existing branch creation logic
    already handles starting on a feature branch (SKILL.md line 715:
    "If already on a non-default feature branch, use it").

    ### What to change

    **File 1: `skills/nefario/SKILL.md`**

    (a) Step 11 (lines 1129-1138): Change the title from "Return to default
    branch" to "Clean up session markers". KEEP the marker/sentinel cleanup
    lines (rm -f commands for orchestrated-session marker and status sentinel).
    REMOVE the default branch detection and `git checkout --quiet <default-branch>
    && git pull --quiet --rebase` command. Update the instruction to say the
    session stays on the feature branch. Change "Include branch name in final
    summary" to "Include current branch name and a hint to return to default
    branch when ready: `git checkout <default-branch> && git pull --rebase`".
    Keep "If not in a git repo, skip this step."

    (b) Wrap-up Sequence step 9 (lines 1278-1280): Remove the checkout command
    entirely. Keep the step numbering intact (renumber if needed). The default
    branch detection can be removed from this step since it is no longer needed
    for checkout. Note: the final summary (step 10) should still mention the
    branch name.

    (c) Wrap-up Sequence step 10 (line 1281): Add "current branch name" and
    "hint to switch back to default branch" to the list of things presented
    to the user, alongside report path, PR URL, and Verification summary.

    **File 2: `docs/commit-workflow.md`**

    (a) Lines 50-53: Replace "After PR creation (or if declined): 1. Return
    to main: `git checkout main && git pull --rebase`. 2. Include the branch
    name..." with text stating the session stays on the feature branch, and
    the final summary includes a command to return to the default branch when
    ready.

    (b) Mermaid diagram (line 96): Remove the line
    `Main->>Git: git checkout main && git pull --rebase`. Add a note at the
    end: `Note over Main: Stays on nefario/<slug> branch`. Ensure the mermaid
    block is valid syntax.

    (c) Line 153: Change "Return to main after PR creation (or decline)." to
    "Stay on feature branch after PR creation (or decline). Final summary
    includes escape hatch to return to default branch."

    (d) Summary table (line 418): Change the row from
    `| **Return to main** | After PR (or decline) | After PR (or decline) |`
    to `| **Post-PR branch** | Stays on feature branch | Stays on feature branch |`

    **File 3: `docs/decisions.md`**

    Decision 18 (line 233): Update the Choice field to replace "return to main
    after PR" with "stay on feature branch after PR". Update the Consequences
    field (line 236) to replace "return to main after PR" with "stay on feature
    branch after PR (developer can continue local testing; final summary includes
    escape hatch to return to default branch)". Add a revision date marker
    showing the revision date (2026-02-11) to the Date field alongside the
    existing dates.

    **File 4: `docs/orchestration.md`**

    Review Section 5 and the wrap-up narrative for any text that explicitly
    says the session returns to main. The current text at line 98 says
    "A final report summarizes deliverables..." which does not reference branch
    behavior. If no explicit reference exists, no change is needed. Only update
    if you find text that contradicts the new behavior.

    ### What NOT to do

    - Do NOT modify any files under `docs/history/nefario-reports/` -- these
      are immutable historical records.
    - Do NOT add configuration flags or options for this behavior. Simply
      remove the checkout. YAGNI.
    - Do NOT change the branch creation logic (lines 711-725 in SKILL.md).
    - Do NOT change PR creation logic (step 10 in SKILL.md).
    - Do NOT remove the sentinel/marker cleanup commands from step 11.
      These are independent of branch state and must be preserved.

    ### Consistency improvement (while editing)

    The software-docs-minion noted that `docs/commit-workflow.md` uses
    hardcoded `main` where SKILL.md uses dynamic `<default-branch>`. Since
    you are already editing these lines, use `<default-branch>` consistently
    in the updated text (not hardcoded `main`). This is a minor consistency
    fix, not a scope expansion.

    ### Deliverables

    - Updated `skills/nefario/SKILL.md`
    - Updated `docs/commit-workflow.md`
    - Updated `docs/decisions.md`
    - Verified `docs/orchestration.md` (updated only if needed)

    ### Success criteria

    - Step 11 in SKILL.md no longer contains any `git checkout` command
    - Wrap-up step 9 in SKILL.md no longer contains any `git checkout` command
    - Sentinel cleanup (rm -f commands) is preserved in step 11
    - All four references in commit-workflow.md reflect "stay on feature branch"
    - Mermaid diagram is valid and no longer shows checkout step
    - Decision 18 reflects the revised behavior
    - Final summary instructions include current branch name + escape hatch

- **Deliverables**: Updated SKILL.md, commit-workflow.md, decisions.md; verified orchestration.md
- **Success criteria**: All "return to default branch" references replaced with "stay on feature branch"; sentinel cleanup preserved; mermaid diagram valid

### Cross-Cutting Coverage

- **Testing**: Not applicable -- no executable code changes. Documentation/skill-spec only.
- **Security**: Not applicable -- no attack surface, auth, or secret handling changes.
- **Usability -- Strategy**: Covered by the issue itself. The change improves developer UX by not disrupting local testing flow. The escape hatch (command in final summary) ensures developers who want to return to main can do so trivially.
- **Usability -- Design**: Not applicable -- no user-facing interfaces produced.
- **Documentation**: Covered directly by Task 1 -- all four documentation files are updated as part of the single task.
- **Observability**: Not applicable -- no runtime components.

### Architecture Review Agents

- **Always**: security-minion, test-minion, ux-strategy-minion, software-docs-minion, lucy, margo
- **Conditional**: None triggered. No runtime components, no UI, no web-facing output.

**Recommendation to skip Phase 3.5 review for this change**: This is a small, easily reversible documentation change with zero code impact. All six mandatory reviewers would evaluate 4 text file edits removing a branch checkout command. The risk of over-engineering the review process exceeds the risk of the change itself. However, per protocol, Phase 3.5 is never skipped without explicit user consent -- so this recommendation is presented for the user to decide at the plan approval gate.

### Conflict Resolutions

None. Both specialists fully agreed on approach, file list, and risks.

### Risks and Mitigations

| Risk | Likelihood | Impact | Mitigation |
|------|-----------|--------|------------|
| Sentinel cleanup accidentally removed alongside checkout | Low | Medium | Task prompt explicitly calls out preserving rm -f commands; success criteria verifies it |
| Mermaid diagram syntax breaks after edit | Low | Low | Success criteria includes valid mermaid syntax check |
| Decision 18 revision reopens unrelated aspects | Low | Low | Task prompt scopes revision to "return to main" aspect only |
| Next nefario session starts on stale feature branch | Already exists | Low | Branch creation logic already handles this (line 715); no new mitigation needed |

### Execution Order

```
Batch 1: Task 1 (devx-minion) -- all edits in a single pass
```

Single task, single agent, single batch. No gates beyond plan approval.

### Verification Steps

After Task 1 completes:
1. Confirm `git checkout` does not appear in SKILL.md step 11 or wrap-up step 9
2. Confirm `rm -f` cleanup commands remain in SKILL.md step 11
3. Confirm commit-workflow.md mermaid diagram does not reference checkout
4. Confirm decisions.md Decision 18 reflects revised behavior
5. Confirm orchestration.md is either unchanged or updated consistently
