## Domain Plan Contribution: software-docs-minion

### Recommendations

The "return to default branch" behavior is documented in **four active documents** that need updating, plus the **primary skill file** which is the source of truth for orchestration behavior. There are also historical report files that reference this behavior, but those are immutable records and must NOT be modified.

#### Complete Reference Inventory

**Files requiring changes (active, prescriptive documentation):**

1. **`skills/nefario/SKILL.md`** -- The primary source of truth. Contains two references:
   - Step 11 (line 1129-1137): "Return to default branch" with `git checkout --quiet <default-branch> && git pull --quiet --rebase`
   - Wrap-up Sequence step 9 (line 1278-1280): Duplicate of the same instruction in the mandatory wrap-up checklist

2. **`docs/commit-workflow.md`** -- The commit and branching design document. Contains four references:
   - Line 52: "Return to main: `git checkout main && git pull --rebase`" in the "PR Creation at Wrap-Up" section
   - Line 96: Mermaid sequence diagram showing `Main->>Git: git checkout main && git pull --rebase` as the final step
   - Line 153: "Return to main after PR creation (or decline)." in the Orchestrated Sessions trigger flow
   - Line 418: Summary table row: `| **Return to main** | After PR (or decline) | After PR (or decline) |`

3. **`docs/orchestration.md`** -- The architecture document for the orchestration process. Contains an indirect reference:
   - Section 5 "Commit Points in Execution Flow" references the behavior via "PR Creation at Wrap-Up" (links to commit-workflow.md). The flow description at the end of Section 1 (delegation flow diagram) does not explicitly show the branch checkout, but the narrative around wrap-up implies it.

4. **`docs/decisions.md`** -- Decision 18 (line 233-236). Contains two references:
   - Choice field: "return to main after PR"
   - Consequences field: "Branching logistics (pull --rebase before branch, return to main after PR) ensure clean workflow."

**Files that must NOT be changed (historical records):**

- All files under `docs/history/nefario-reports/` -- These are immutable execution reports. Multiple reports reference the old behavior (e.g., `2026-02-10-001-git-workflow-auto-commit.md`, various synthesis and phase files). Per project conventions, these are never modified.

#### Documentation Update Strategy

The change from "return to default branch after PR" to "stay on feature branch after PR" is a behavioral change to the orchestration workflow. It requires:

1. **Update the prescriptive text** in all four active documents to reflect the new behavior.
2. **Do NOT change historical reports** -- they correctly document what happened at the time.
3. **Update the Mermaid diagram** in `docs/commit-workflow.md` (line 59-97) to remove the final `git checkout main` step. This is a user-facing diagram that developers reference to understand the flow.
4. **Update Decision 18** in `docs/decisions.md` to note the revision. Since ADRs are immutable, the correct approach is either (a) add a "Revised" note inline (this project uses inline revisions for Decision 18 already) or (b) create a new decision that supersedes the branching logistics part of Decision 18.
5. **Keep cleanup behavior** -- The sentinel file removal (`rm -f /tmp/claude-commit-orchestrated-$SID` and `rm -f /tmp/nefario-status-$SID`) currently lives in step 11 alongside the branch checkout. These cleanup operations must be preserved even when removing the branch switch. They should remain in the wrap-up sequence regardless of branch behavior.

#### Consistency Note

`docs/commit-workflow.md` still uses hardcoded `main` in places (lines 52, 96) where `SKILL.md` already uses dynamic `<default-branch>` detection. This inconsistency predates this issue. The current task should either fix both (use dynamic detection AND remove the checkout) or at minimum update the behavior while keeping the existing inconsistency noted for a future cleanup. I recommend fixing both in one pass since we are already editing these lines.

### Proposed Tasks

**Task 1: Update `skills/nefario/SKILL.md` wrap-up steps**
- What: Replace step 11 "Return to default branch" with "Stay on feature branch". Keep the sentinel cleanup. Remove the `git checkout` and `git pull` commands. Update wrap-up sequence step 9 identically.
- Deliverables: Updated SKILL.md with consistent "stay on feature branch" behavior in both the wrap-up narrative (step 11) and the mandatory wrap-up sequence (step 9).
- Dependencies: None (this is the source of truth, update first).

**Task 2: Update `docs/commit-workflow.md`**
- What: Update four references (lines 52, 96, 153, 418). Change "Return to main" to "Stay on feature branch" or equivalent. Update the Mermaid sequence diagram to remove the final `git checkout main` line and instead show the feature branch as the final state.
- Deliverables: Updated commit-workflow.md with consistent behavior.
- Dependencies: Task 1 (SKILL.md is the source of truth; docs should reflect it).

**Task 3: Update `docs/decisions.md` Decision 18**
- What: Revise Decision 18 to note that branching logistics changed: the session now stays on the feature branch after PR creation instead of returning to the default branch. Add the rationale (developer can continue local testing without switching) and note that this supersedes the "return to main after PR" aspect of the original decision.
- Deliverables: Updated Decision 18 with revision note.
- Dependencies: Task 1.

**Task 4: Review `docs/orchestration.md` for implicit references**
- What: Check Section 5 for any text that implies the session returns to main after PR. The current text references commit-workflow.md, so it may be sufficient to update the linked document. Verify and update if needed.
- Deliverables: Verified or updated orchestration.md.
- Dependencies: Task 2 (since orchestration.md links to commit-workflow.md).

### Risks and Concerns

1. **Sentinel cleanup must survive the edit.** The current step 11 in SKILL.md bundles three behaviors: (a) remove orchestrated-session marker, (b) remove status sentinel, (c) checkout default branch. Removing (c) is the goal, but (a) and (b) must remain. There is a risk that an editing agent removes the entire step 11 block instead of surgically removing only the checkout command.

2. **Mermaid diagram validity.** The sequence diagram in `docs/commit-workflow.md` (lines 59-97) currently ends with the `git checkout main` step. Removing it changes the diagram's visual endpoint. The diagram should still convey a clear ending -- perhaps showing "Developer stays on nefario/<slug>" as the final note. Malformed Mermaid syntax after editing would silently break rendering.

3. **The summary table in commit-workflow.md (line 418) uses "Return to main" as a row label.** This needs to change to something like "Post-PR branch" with the new value being "Stays on feature branch" for both columns. The table structure needs consistent column values.

4. **Decision 18 revision scope.** Decision 18 was already revised once (from interactive commits to auto-commits). Adding another revision note is fine, but it should be clearly scoped to the "return to main" aspect only, not re-open the entire decision.

5. **`docs/using-nefario.md` is unaffected.** The user-facing guide does not mention post-PR branch behavior. No changes needed there, but consider whether to add a note that the developer stays on the feature branch. I would recommend NOT adding it -- it follows the principle of least surprise (staying where you are is the expected default), so documenting it would be documenting non-surprising behavior.

### Additional Agents Needed

None. The current team is sufficient. The documentation changes are straightforward text updates across four files, all within the software-docs domain. No code implementation, no test changes, no security implications beyond what the devx-minion would cover for the actual SKILL.md behavior change.
