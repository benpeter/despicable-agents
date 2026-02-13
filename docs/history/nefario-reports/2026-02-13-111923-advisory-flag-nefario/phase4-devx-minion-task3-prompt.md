You are adding the advisory-mode behavioral divergence to the nefario skill.
This is the core change: where the advisory flow separates from normal execution
and how it terminates.

## What to Do

Edit `/Users/ben/github/benpeter/2despicable/2/skills/nefario/SKILL.md` with these changes:

**Change 1: Advisory Synthesis variant** -- Find the Phase 3 synthesis section. After the normal
synthesis prompt block (the block that ends with the closing ``` of the prompt) and before
the paragraph that says "Nefario will return a structured delegation plan.", add:

```markdown
### Advisory Synthesis (when `advisory-mode` is active)

When `advisory-mode` is active, replace the standard synthesis prompt above with:

    Task:
      subagent_type: nefario
      description: "Nefario: advisory synthesis"
      model: opus
      prompt: |
        MODE: SYNTHESIS
        ADVISORY: true

        You are synthesizing specialist planning contributions into a
        team recommendation. This is an advisory-only orchestration --
        no code will be written, no branches created, no PRs opened.

        Do NOT produce task prompts, agent assignments, execution order,
        approval gates, or delegation plan structure. Produce an advisory
        report using the advisory output format defined in your AGENT.md.

        ## Original Task
        <insert the user's task>

        ## Specialist Contributions

        Read the following scratch files for full specialist contributions:
        <list each file path: $SCRATCH_DIR/{slug}/phase2-{agent}.md>

        ## Key consensus across specialists:
        <paste the inline summaries collected during Phase 2>

        ## Instructions
        1. Review all specialist contributions
        2. Resolve any conflicts between recommendations
        3. Identify consensus and dissent -- preserve minority positions
        4. Produce an advisory report with executive summary, team consensus,
           dissenting views, supporting evidence, risks, next steps, and
           conflict resolutions
        5. Write your complete advisory synthesis to
           $SCRATCH_DIR/{slug}/phase3-synthesis.md

The advisory synthesis output goes to the same scratch file path
(`phase3-synthesis.md`) as a normal synthesis. The content differs
(advisory report vs. delegation plan) but the file location is consistent.
```

**Change 2: Advisory Termination** -- Find the Compaction Checkpoint section at the end of Phase 3.
After the paragraph that says "Do NOT re-prompt at subsequent boundaries." and before the
line that updates the status file for Phase 3.5 (the line with `echo "⚗︎ P3.5 Review`),
add:

```markdown
### Advisory Termination (when `advisory-mode` is active)

When `advisory-mode` is active, after Phase 3 synthesis completes:

1. **Skip the compaction checkpoint** -- there is no Phase 4 to preserve
   context for. The session is about to wrap up.

2. **Skip Phases 3.5 through 8 entirely** -- no architecture review,
   no execution, no code review, no tests, no deployment, no documentation.

3. **Proceed directly to Advisory Wrap-up** (below).

Do NOT present the Execution Plan Approval Gate. There is no execution plan.
Do NOT present the Reviewer Approval Gate. There is no plan to review.
Do NOT create a branch, make commits (other than the report), or open a PR.
```

**Change 3: Advisory Wrap-up** -- Add immediately after the Advisory Termination section:

```markdown
### Advisory Wrap-up

When `advisory-mode` is active, replace the standard Phases 3.5-8 and
wrap-up sequence with the following:

1. **Capture timestamp** -- record current local time as HHMMSS (same
   convention as standard wrap-up step 2).

2. **Collect working files** -- copy scratch files to companion directory
   (same logic as standard wrap-up step 5, including sanitization).
   Advisory runs produce fewer files (no Phase 3.5+), so the companion
   directory will be smaller.

3. **Write advisory report** -- write to
   `<REPORT_DIR>/<YYYY-MM-DD>-<HHMMSS>-<slug>.md` using the report
   template with these frontmatter values:

   ```yaml
   mode: advisory
   task-count: 0
   gate-count: 0
   ```

   Follow the advisory-mode conditional rules in `TEMPLATE.md`:
   - Include: Summary, Original Prompt, Key Design Decisions, Phases
     (1-3 narrative; 3.5-8 as "Skipped (advisory-only orchestration)."),
     Agent Contributions (planning only), Team Recommendation, Working Files
   - Omit: Execution, Decisions, Verification, Test Plan

   The **Team Recommendation** section is the advisory deliverable. Populate
   it from the advisory synthesis output (executive summary, consensus,
   dissenting views, recommendations, conditions to revisit).

4. **Commit report and companion directory** -- if in a git repo,
   auto-commit with message:
   `docs: add nefario advisory report for <slug>`
   Use `--quiet`. Commit to the CURRENT branch (no feature branch creation).

5. **Clean up** -- remove scratch directory (`rm -rf "$SCRATCH_DIR"`).
   Remove status file:
   `SID=$(cat /tmp/claude-session-id 2>/dev/null); rm -f /tmp/nefario-status-$SID`

6. **Present to user** -- print:
   ```
   Advisory report: <absolute report path>
   Working files: <absolute companion directory path>
   ```
   No PR URL, no branch name, no checkout hint.

**What advisory wrap-up does NOT do**:
- No branch creation (`git checkout -b`)
- No PR creation (`gh pr create`)
- No PR gate (no AskUserQuestion for PR)
- No team shutdown (no TeamCreate was done)
- No post-execution verification summary
- No existing-PR detection or update

**If the user requests execution after advisory**: Respond: "Advisory mode is
complete. To execute, start a new orchestration: `/nefario <task>`." Do not
convert an advisory session into an execution session mid-stream.
```

## What NOT to Do
- Do not modify the normal (non-advisory) synthesis prompt
- Do not modify Phase 3.5, 4, 5-8 sections -- advisory skips them, does not alter them
- Do not create a separate wrap-up section far from the divergence point -- keep
  the advisory flow readable top-to-bottom at the divergence location
- Do not modify `the-plan.md`

## Context
- devx-minion specified the advisory termination and wrap-up behavior
- ai-modeling-minion specified the `ADVISORY: true` directive approach (not MODE: ADVISORY)
- The advisory synthesis prompt uses `MODE: SYNTHESIS` + `ADVISORY: true`
- The advisory report format is defined in AGENT.md (Task 1)
- The report template conditional rules are defined in TEMPLATE.md (Task 4)
- These changes add ~100-120 lines to SKILL.md

## Deliverables
- Modified `skills/nefario/SKILL.md` with advisory synthesis prompt, advisory
  termination, and advisory wrap-up sections

When you finish your task, report:
- File paths with change scope and line counts
- 1-2 sentence summary of what was produced
