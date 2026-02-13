## Task: Add run-title convention and update gate specifications in SKILL.md

**File**: `/Users/ben/github/benpeter/2despicable/3/skills/nefario/SKILL.md`

You are editing the nefario orchestration skill specification. The goal is
to ensure every AskUserQuestion gate includes the orchestration run title
(`$summary`) so the user can identify which run they are deciding on --
critical for parallel nefario sessions in different terminals.

### What to do

**Step 1: Add centralized convention note** (after existing header constraint)

Find the existing AskUserQuestion `header` constraint note. It reads:

```
> Note: AskUserQuestion `header` values must not exceed 12 characters.
> The `P<N> <Label>` convention reserves 3-5 chars for the phase prefix.
```

Add this new note immediately after (with a blank line separator):

```
> Note: Every AskUserQuestion `question` field must end with
> `\n\nRun: $summary` on a dedicated trailing line. This ensures the
> user can identify which orchestration run a gate belongs to, even when
> the status line is hidden by the AskUserQuestion prompt. The `$summary`
> value is established in Phase 1 and capped at 40 characters.
```

IMPORTANT: Use `> Note:` format (not `> **Run-title convention**:`) to match the adjacent constraint's formatting pattern.

**Step 2: Update gates with literal-string questions**

The centralized convention handles most gates. But gates whose `question`
spec uses a full literal string need explicit updates so the LLM does not
reproduce the literal verbatim without the trailing line.

Update these gates:

1. **Post-exec gate** (~line 1477): The worst offender -- zero context.
   Change from:
   ```
   - `question`: "Post-execution phases for this task?"
   ```
   To:
   ```
   - `question`: "Post-execution phases for Task N: <task title>?\n\nRun: $summary"
   ```
   This adds BOTH task-level context (which task's post-execution) AND
   run-level context.

2. **P4 Calibrate gate** (~line 1541): Currently a full literal.
   Change from:
   ```
   - `question`: "5 consecutive approvals without changes. Gates well-calibrated?"
   ```
   To:
   ```
   - `question`: "5 consecutive approvals without changes. Gates well-calibrated?\n\nRun: $summary"
   ```

3. **PR gate** (~line 1869): Currently a full literal with slug.
   Change from:
   ```
   - `question`: "Create PR for nefario/<slug>?"
   ```
   To:
   ```
   - `question`: "Create PR for nefario/<slug>?\n\nRun: $summary"
   ```

4. **Existing PR gate** (~line 2061): Currently a full literal.
   Change from:
   ```
   - `question`: "PR #<existing-pr> exists on this branch. Update its description with this run's changes?"
   ```
   To:
   ```
   - `question`: "PR #<existing-pr> exists on this branch. Update its description with this run's changes?\n\nRun: $summary"
   ```

5. **Confirm (reject) gate** (~line 1501): This gate has a multi-line
   formatted question string. Add the `Run:` line at the very end of the
   formatted block. The current spec shows a fenced code block for the
   question format. Add `\nRun: $summary` as the last line inside that
   format, after the "Alternative:" line. The result should look like:

   ```
   Reject <task title>?

   Dependent tasks that will also be dropped:
     Task N: <title> -- <1-sentence deliverable description>
     Task M: <title> -- <1-sentence deliverable description>

   Alternative: Select "Cancel" then choose "Request changes" for a less drastic revision.

   Run: $summary
   ```

**Step 3: Add `$summary` to compaction checkpoint focus strings**

This ensures `$summary` survives context compaction so the convention
can be applied in later phases.

1. **Phase 3 compaction**: Find the focus string that starts with:
   ```
   Preserve: current phase (3.5 review next), synthesized execution plan, inline agent summaries, task list, approval gates, team name, branch name, scratch directory path.
   ```
   Add `$summary` after "branch name":
   ```
   Preserve: current phase (3.5 review next), synthesized execution plan, inline agent summaries, task list, approval gates, team name, branch name, $summary, scratch directory path.
   ```

2. **Phase 3.5 compaction**: Find the focus string that starts with:
   ```
   Preserve: current phase (4 execution next), final execution plan with ADVISE notes incorporated, inline agent summaries, gate decision briefs, task list with dependencies, approval gates, team name, branch name, scratch directory path.
   ```
   Add `$summary` after "branch name":
   ```
   Preserve: current phase (4 execution next), final execution plan with ADVISE notes incorporated, inline agent summaries, gate decision briefs, task list with dependencies, approval gates, team name, branch name, $summary, scratch directory path.
   ```

### What NOT to do

- Do NOT modify `header` fields. They stay as-is (12-char cap, phase identity).
- Do NOT rewrite question content for gates that use template-style specs
  (e.g., `<1-sentence task summary>`, `the one-sentence finding description`).
  The centralized convention handles these -- the LLM will apply the rule.
- Do NOT add a template variable like `$run_line`. SKILL.md is not a template
  engine. The convention is an instruction, not a variable substitution.
- Do NOT modify any AskUserQuestion `options` -- only `question` fields change.
- Do NOT change anything outside the AskUserQuestion specifications and
  compaction focus strings.

### Deliverables

- Updated `skills/nefario/SKILL.md` with:
  1. Centralized run-title convention note (after the header constraint)
  2. Five gate `question` field updates (post-exec, calibrate, PR, existing PR, confirm)
  3. Two compaction focus string updates (Phase 3, Phase 3.5)

When you finish your task, mark it completed with TaskUpdate and
send a message to the team lead with:
- File paths with change scope and line counts (e.g., "src/auth.ts (new OAuth flow, +142 lines)")
- 1-2 sentence summary of what was produced
This information populates the gate's DELIVERABLE section.
