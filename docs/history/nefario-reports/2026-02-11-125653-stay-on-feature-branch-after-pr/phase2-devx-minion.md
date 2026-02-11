## Domain Plan Contribution: devx-minion

### Recommendations

**1. No downstream tools or workflows depend on being back on main after PR creation.**

I traced every reference to the "return to default branch" behavior across the codebase. The relevant touchpoints are:

- `skills/nefario/SKILL.md` step 11 (wrap-up): `git checkout --quiet <default-branch> && git pull --quiet --rebase`
- `skills/nefario/SKILL.md` step 9 in the wrap-up sequence (line 1279-1280): same checkout
- `docs/commit-workflow.md` line 52: `Return to main: git checkout main && git pull --rebase`
- `docs/commit-workflow.md` line 96 (mermaid diagram): `Main->>Git: git checkout main && git pull --rebase`
- `docs/orchestration.md` line 98: mentions wrap-up report but does not reference branch state
- `docs/decisions.md` line 236: mentions "return to main after PR" as a consequence

The next nefario session already handles the case where it starts on a feature branch -- `SKILL.md` line 715: "If already on a non-default feature branch, use it (do not create a nested branch)." This means if the user runs `/nefario` again after a PR, the existing branch logic works correctly regardless of which branch they are on. There is no hidden dependency on being on `main`.

The branch creation logic (SKILL.md lines 711-725) has a clean fork:
- On default branch: pull, create feature branch
- On feature branch: use it as-is

Both paths are exercised today. Staying on the feature branch after PR creation simply means the next session is more likely to hit the "already on feature branch" path, which already works.

**2. The final summary message should change to reflect the current branch state.**

Currently, SKILL.md step 11 says "Include branch name in final summary." This is good -- it already tells the user which branch was used. But the messaging should shift from "you are back on main, here is the branch if you need it" to "you are still on the feature branch, switch to the default branch when ready."

The summary should include:
- Current branch name (the feature branch)
- A one-liner showing how to return to the default branch: `git checkout <default-branch> && git pull --rebase`
- The PR URL (already present)

This follows CLI design best practices: tell the user their current state, and tell them how to change it if they want to. Do not assume what they want to do next.

**3. Do NOT make this configurable. Simply remove the checkout.**

Rationale:
- **YAGNI**: There is no demonstrated use case for returning to main. The original behavior was a convention borrowed from typical PR workflows, not a response to a user need.
- **Zero-config wins**: Adding a flag (`--stay-on-branch` / `--return-to-main`) creates configuration surface area for a decision that has one clearly correct answer. The developer wants to stay on the branch to test locally -- that is the whole point of the issue.
- **The escape hatch is trivial**: `git checkout main` is a 2-second operation that every developer knows. Providing the command in the summary message makes it a one-copy-paste action. Switching back to main is cheap; losing your local testing context because the tool switched branches for you is not.
- **Convention alignment**: GitHub CLI (`gh pr create`) does not switch branches after creating a PR. `git push` does not switch branches. No standard Git tooling changes your branch as a side effect of a remote operation. The current "return to main" behavior is actually the aberrant one.

### Proposed Tasks

**Task 1: Remove the checkout-to-default-branch step from SKILL.md wrap-up**

What to do:
- In `skills/nefario/SKILL.md`, step 11 (line 1129-1138): Remove the `git checkout --quiet <default-branch> && git pull --quiet --rebase` command. Keep the cleanup of the orchestrated-session marker and status sentinel (those are independent of branch state). Keep "Include branch name in final summary."
- In `skills/nefario/SKILL.md`, wrap-up sequence step 9 (line 1279-1280): Remove the checkout command. Keep the default branch detection (it may still be needed for other references, but verify).
- Update the final summary message instruction to say: "Include current branch name and a hint to switch back: `git checkout <default-branch> && git pull --rebase`"

Deliverables: Updated `skills/nefario/SKILL.md`
Dependencies: None

**Task 2: Update commit-workflow.md to match the new behavior**

What to do:
- Line 50-53: Change "After PR creation (or if declined): 1. Return to main..." to "After PR creation (or if declined), the working directory stays on the feature branch. The final summary includes a command to return to the default branch when ready."
- Line 96 (mermaid diagram): Remove the `Main->>Git: git checkout main && git pull --rebase` step from the sequence diagram.
- Line 153-154: Update the orchestrated flow description (step 6: "Return to main after PR creation (or decline)") to reflect staying on the feature branch.
- Line 418 (summary table): Update "Return to main | After PR (or decline) | After PR (or decline)" to reflect the new behavior for both session types.

Deliverables: Updated `docs/commit-workflow.md`
Dependencies: Task 1 (SKILL.md is the source of truth; docs follow)

**Task 3: Update orchestration.md references**

What to do:
- Review `docs/orchestration.md` for any references to returning to main after PR. The delegation flow mermaid diagram (lines 163-281) does not show post-PR branch behavior, so it likely needs no change. Verify and update if needed.
- `docs/decisions.md` line 236 mentions "return to main after PR" as a consequence. Update this line.

Deliverables: Updated `docs/orchestration.md` and `docs/decisions.md` (if changes needed)
Dependencies: Task 1

### Risks and Concerns

**Risk 1: Next nefario session starts on a stale feature branch**

If the user runs `/nefario` with a new task while still on a previous feature branch, the branch creation logic (SKILL.md line 715) will use the existing branch instead of creating a new one. This is the existing behavior and is actually correct -- but the user might not realize they are on an old branch.

Mitigation: This is already handled. The branch creation step logs which branch is being used. No new mitigation needed. The risk exists today (user could manually check out a feature branch before running nefario) and the existing logic handles it.

**Risk 2: Single-agent sessions also return to main**

The commit-workflow.md summary table (line 418) shows "Return to main" applies to both single-agent and orchestrated sessions. The issue mentions nefario specifically, but the same logic likely applies to single-agent sessions via the Stop hook.

Mitigation: Apply the same change to single-agent sessions. The rationale is identical -- after creating a PR, the developer wants to stay on the branch. The Stop hook behavior should match.

**Risk 3: Forgetting to clean up markers/sentinels before vs. after checkout removal**

The marker cleanup (`rm -f /tmp/claude-commit-orchestrated-$SID` and `rm -f /tmp/nefario-status-$SID`) currently happens in the same step 11 as the checkout. When removing the checkout, ensure the cleanup commands remain. They are not dependent on branch state.

Mitigation: Code review should verify marker cleanup is preserved. This is a straightforward "keep the cleanup, remove the checkout" edit.

### Additional Agents Needed

None. This is a focused change to orchestration workflow documentation (SKILL.md + docs). No code is being written, no tests need updating, no security implications. The devx-minion perspective plus lucy (consistency review) and margo (simplicity check) from the standard Phase 3.5 reviewers are sufficient.
