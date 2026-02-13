# Domain Plan Contribution: devx-minion

## Recommendations

### Implementation-ready insertion point design for `--advisory` in SKILL.md

This contribution builds on my prior analysis (which established that advisory is a flag, not a separate skill) and the team's prior synthesis (which said "wait for pain, but the architecture is mapped"). The user has now decided to build it. What follows is an exact specification of where and how to modify SKILL.md, referencing line numbers and section headers from the current 1939-line file.

---

### (a) Flag parsing: integration with existing argument parsing

**Current state** (SKILL.md lines 23-100, "Argument Parsing" section):

The argument parsing currently handles three patterns:
1. `#<n>` (issue mode)
2. `#<n> <trailing text>` (issue mode with supplement)
3. Free text (no `#<n>` prefix)

**Insertion point**: Between the `Arguments:` declaration (line 25) and the first bullet point (line 27).

**Specification**:

Replace the arguments declaration line:

```
Arguments: `#<issue> | <task description>`
```

with:

```
Arguments: `[--advisory] #<issue> | <task description>`
```

Then add a new flag-parsing step BEFORE the three existing patterns:

```markdown
### Flag Extraction

Before parsing the task input, extract flags from the argument string:

- **`--advisory`**: If present anywhere in the input, remove it from the
  argument string and set `advisory-mode: true` in session context. The
  remaining string (after flag removal and whitespace trimming) is parsed
  normally as `#<issue>` or free text.

Flag extraction is position-independent: `/nefario --advisory #87`,
`/nefario #87 --advisory`, and `/nefario --advisory fix the auth flow`
are all valid. The flag is consumed before issue/text parsing begins.

If `--advisory` appears inside a `<github-issue>` tag (fetched issue body),
it is NOT treated as a flag -- the content boundary rule applies. Only
flags in the top-level argument string are extracted.
```

**Why this design**:
- Position-independence follows the principle of least surprise (users should not need to memorize flag position)
- Extracting before content parsing avoids ambiguity with trailing text
- The `<github-issue>` exemption prevents issue-body injection of the flag
- Single flag keeps the parsing simple; if more flags are ever needed, this establishes the pattern

**Frontmatter update** (SKILL.md line 9):

```yaml
argument-hint: "[--advisory] #<issue> | <task description>"
```

This immediately signals the capability at the invocation prompt. Users who type `/nefario` and glance at the hint discover advisory mode without consulting documentation.

---

### (b) Where the advisory branch diverges from normal flow

The advisory branch diverges at **two points**, not one. The prior analysis identified Phase 3/4 boundary as the single divergence. After closer reading, I identify an earlier divergence at Phase 3 synthesis (the synthesis prompt itself must change) and the terminal divergence after Phase 3 (no Phase 3.5 through 8).

**Divergence point 1: Phase 3 Synthesis prompt** (SKILL.md lines 657-709)

When `advisory-mode: true`, the synthesis prompt changes from `MODE: SYNTHESIS` producing an execution plan to `MODE: ADVISORY-SYNTHESIS` producing a recommendation synthesis. This is NOT just a cosmetic change -- the output structure differs.

**Current** Phase 3 synthesis prompt (line 672):

```
MODE: SYNTHESIS

You are synthesizing specialist planning contributions into a
final execution plan.
```

**Advisory variant** -- add a conditional block after the existing synthesis prompt section:

```markdown
### Advisory Synthesis (when `advisory-mode: true`)

When `advisory-mode` is active, replace the standard synthesis prompt with:

    Task:
      subagent_type: nefario
      description: "Nefario: advisory synthesis"
      model: opus
      prompt: |
        MODE: ADVISORY-SYNTHESIS

        You are synthesizing specialist planning contributions into a
        team recommendation. This is an advisory-only orchestration --
        no code will be written, no branches created, no PRs opened.

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
        4. Produce a team recommendation with:
           - Executive summary (2-3 sentences)
           - Consensus analysis (where the team agrees)
           - Points of disagreement (with each position stated fairly)
           - Recommended course of action
           - Conditions that would change the recommendation
           - Strongest arguments for and against
        5. This is an advisory report, NOT an execution plan. Do not
           produce task lists, agent assignments, or execution prompts.
           Produce analysis, reasoning, and recommendations.
        6. Write your complete advisory synthesis to
           $SCRATCH_DIR/{slug}/phase3-synthesis.md

The advisory synthesis output goes to the same scratch file path
(`phase3-synthesis.md`) as a normal synthesis. The content differs
(recommendation vs. execution plan) but the file location is consistent,
which keeps the companion directory structure uniform.
```

**Divergence point 2: After Phase 3 -- skip Phases 3.5 through 8** (the terminal divergence)

**Insertion point**: After the Phase 3 Compaction Checkpoint section (SKILL.md lines 711-725) and before Phase 3.5 (line 733).

Add a new section:

```markdown
### Advisory Termination (when `advisory-mode: true`)

When `advisory-mode` is active, after Phase 3 completes:

1. **Skip the compaction checkpoint** -- there is no Phase 4 to preserve
   context for, and the session is about to end. The compaction prompt
   references "Phase 3.5 review next" which is incorrect in advisory mode.

2. **Skip Phase 3.5 through Phase 8 entirely** -- no architecture review,
   no execution, no code review, no tests, no deployment, no documentation.

3. **Proceed directly to Advisory Wrap-up** (see below).

Do NOT present the Execution Plan Approval Gate. There is no execution
plan. Do NOT create a branch, make commits, or open a PR.
```

---

### (c) Advisory wrap-up: no branch, no PR, no commit of code

**Insertion point**: New section after the Advisory Termination section, before the existing "Execution Plan Approval Gate" section (SKILL.md line 1029). Alternatively, it could be placed within or adjacent to the existing "Wrap-up" section (line 1644), but I recommend placing it inline at the divergence point so the advisory flow reads top-to-bottom without jumping.

```markdown
### Advisory Wrap-up

When `advisory-mode` is active, replace the standard wrap-up sequence
(steps 7-14 in Phase 4 Wrap-up) with the following:

1. **Capture timestamp** -- record current local time as HHMMSS (same
   convention as standard wrap-up step 2).

2. **Collect working files** -- copy scratch files to companion directory
   (same logic as standard wrap-up step 5, including sanitization).
   Advisory runs produce fewer files (no phase 3.5+, no phase 4+), so
   the companion directory will be smaller.

3. **Write advisory report** -- write to
   `<REPORT_DIR>/<YYYY-MM-DD>-<HHMMSS>-<slug>.md` using the report
   template with the following frontmatter differences:

   ```yaml
   mode: advisory
   task-count: 0
   gate-count: 0
   ```

   The `mode: advisory` value is new. It must be added to the report
   template's allowed values for the `mode` field (currently `full | plan`).

   **Report content differences** (vs. standard execution report):
   - Summary: describes the advisory outcome, not execution outcome
   - Key Design Decisions: populated from synthesis recommendations
   - Phases 3.5 through 8: each says "Skipped (advisory-only orchestration)."
     Use a single line for each, not separate subsections.
   - Agent Contributions: populated normally (planning agents only, no
     review or code review subsections)
   - Execution section: omitted entirely (no tasks table, no files changed,
     no approval gates)
   - Decisions section: omitted (gate-count = 0)
   - Verification section: omitted (no phases ran)
   - External Skills: included if discovered, omitted if not
   - Working Files: populated normally (smaller set)
   - Test Plan: omitted
   - Add a new section: **Team Recommendation** -- this is the advisory
     deliverable. Contains the synthesis's recommendation, consensus
     analysis, dissenting positions, and conditions to revisit. This
     section replaces the Execution and Decisions sections as the
     primary content of the report.

4. **Commit report and companion directory** -- if in a git repo,
   auto-commit with message:
   `docs: add nefario advisory report for <slug>`
   Use `--quiet`. This commits to the CURRENT branch (main or whatever
   the user is on). No feature branch is created for advisory runs.

5. **Clean up** -- remove scratch directory (`rm -rf "$SCRATCH_DIR"`).
   Remove status file:
   `SID=$(cat /tmp/claude-session-id 2>/dev/null); rm -f /tmp/nefario-status-$SID`

6. **Present to user** -- print:
   ```
   Advisory report: <absolute report path>
   Working files: <absolute companion directory path>
   ```
   No PR URL, no branch name, no checkout hint. The advisory is
   complete. The report is the deliverable.

**What advisory wrap-up does NOT do**:
- No branch creation (no `git checkout -b`)
- No PR creation (no `gh pr create`)
- No PR gate (no AskUserQuestion for PR)
- No team shutdown (no TeamCreate was done, so no TeamDelete needed)
- No existing-PR detection or update
- No post-execution verification summary
```

---

### (d) Gate and synthesis prompt modifications

**Team Approval Gate** (SKILL.md lines 430-576): **No changes needed.**

The team approval gate works identically in advisory mode. The user still needs to approve which specialists to consult. The gate presentation, adjustment logic, and AskUserQuestion structure are all unchanged. The only difference is that nefario's Phase 1 meta-plan should be aware that this is advisory (so it selects analysis-oriented specialists rather than execution-oriented ones). This is handled by modifying the Phase 1 prompt, not the gate.

**Phase 1 Meta-Plan prompt** (SKILL.md lines 387-428): **Needs advisory context.**

When `advisory-mode: true`, append to the Phase 1 prompt (after the existing Instructions section):

```markdown
## Advisory Context
This is an advisory-only orchestration. The outcome will be a team
recommendation report, not code changes. When selecting specialists:
- Prioritize agents with analytical expertise over execution expertise
- Consider agents who can evaluate trade-offs and alternatives
- The planning questions should ask for assessment and analysis,
  not for task lists or execution plans
- Specialists should still return the standard contribution format
  (Recommendations, Proposed Tasks, Risks, Additional Agents) but
  "Proposed Tasks" should be analysis tasks (what to investigate,
  what to evaluate) not execution tasks (what to build, what to change)
```

**Phase 2 Specialist prompt** (SKILL.md lines 597-640): **Needs advisory context.**

When `advisory-mode: true`, add to each specialist's prompt (after the Instructions section):

```markdown
## Advisory Context
This is an advisory-only orchestration. Your contribution will feed
into a team recommendation, not an execution plan. Focus on analysis,
trade-offs, and recommendations rather than implementation tasks.
Your "Proposed Tasks" section should describe what should be evaluated
or investigated, not what code should be written.
```

**Reviewer Approval Gate** (SKILL.md lines 773-869): **Skipped entirely.**

In advisory mode, Phase 3.5 does not run. No reviewer gate is presented. This is handled by the Advisory Termination section above.

**Execution Plan Approval Gate** (SKILL.md lines 1029-1147): **Skipped entirely.**

In advisory mode, there is no execution plan. No gate is presented. This is handled by the Advisory Termination section above.

**Phase 3 Compaction Checkpoint** (SKILL.md lines 711-725): **Skipped in advisory mode.**

The compaction checkpoint text references "Phase 3.5 review next" which is wrong in advisory mode. Rather than creating an advisory variant of the compaction prompt, skip it. Advisory runs are shorter (3 phases vs. 9) and context pressure is lower.

---

### Status line updates

**Phase 1 status** (SKILL.md line 367): When `advisory-mode: true`:

```sh
echo "⚗︎ ADV P1 Meta-Plan | $summary" > /tmp/nefario-status-$SID
```

**Phase 2 status** (SKILL.md line 580): When `advisory-mode: true`:

```sh
echo "⚗︎ ADV P2 Planning | $summary" > /tmp/nefario-status-$SID
```

**Phase 3 status** (SKILL.md line 654): When `advisory-mode: true`:

```sh
echo "⚗︎ ADV P3 Synthesis | $summary" > /tmp/nefario-status-$SID
```

The `ADV` prefix provides instant visual distinction in the status line. No Phase 3.5+ status updates are needed because advisory mode terminates after Phase 3.

---

### Report template update

**TEMPLATE.md** (`docs/history/nefario-reports/TEMPLATE.md`): The `mode` field on line 16 currently allows `full | plan`. Add `advisory`:

```yaml
mode: {full | plan | advisory}
```

Add to the Template Notes section:

```markdown
### Advisory Mode Reports

When `mode: advisory`:
- Execution section: OMIT (no tasks, files, or gates)
- Decisions section: OMIT (no gates)
- Verification section: OMIT (no post-execution phases)
- Test Plan section: OMIT (no tests)
- Team Recommendation section: INCLUDE (advisory-specific; contains
  consensus, dissent, recommended action, and revisit conditions)
- Phases 3.5-8 in the Phases section: single line each:
  "Skipped (advisory-only orchestration)."
```

---

### Summary of all SKILL.md changes (exact section references)

| # | Section | Lines | Change Type | Description |
|---|---------|-------|-------------|-------------|
| 1 | Frontmatter `argument-hint` | 9 | Edit | Add `[--advisory]` prefix |
| 2 | Argument Parsing header | 25 | Edit | Update `Arguments:` declaration |
| 3 | Argument Parsing (new subsection) | After 25, before 27 | Insert | "Flag Extraction" subsection |
| 4 | Phase 1 Meta-Plan prompt | 387-428 | Conditional append | Advisory Context block in prompt |
| 5 | Phase 1 status line | 367 | Conditional edit | `ADV` prefix when advisory |
| 6 | Phase 2 status line | 580 | Conditional edit | `ADV` prefix when advisory |
| 7 | Phase 2 specialist prompt | 597-640 | Conditional append | Advisory Context block in prompt |
| 8 | Phase 3 status line | 654 | Conditional edit | `ADV` prefix when advisory |
| 9 | Phase 3 Synthesis | After 703 | Insert | Advisory Synthesis conditional section |
| 10 | After Phase 3 Compaction | After 725 | Insert | Advisory Termination section |
| 11 | After Advisory Termination | After new section | Insert | Advisory Wrap-up section |
| 12 | Core Rules | 20-21 | Conditional note | Advisory mode follows Phases 1-3 only |

Additionally:

| # | File | Change |
|---|------|--------|
| 13 | `TEMPLATE.md` | Add `advisory` to `mode` field; add advisory conditional rules |
| 14 | `build-index.sh` | Add `advisory` to mode display (if it filters/displays mode) |

## Proposed Tasks

### Task 1: Add flag parsing to SKILL.md

**What**: Insert the `--advisory` flag extraction subsection into the Argument Parsing section. Update the `Arguments:` declaration and frontmatter `argument-hint`.

**Deliverables**:
- Updated SKILL.md lines 9 (frontmatter), 25 (declaration), new "Flag Extraction" subsection before line 27
- Approximately 15-20 lines added

**Dependencies**: None

### Task 2: Add advisory context to Phase 1 and Phase 2 prompts

**What**: Add conditional "Advisory Context" blocks to the Phase 1 meta-plan prompt and the Phase 2 specialist prompt template. These blocks tell nefario and specialists that the outcome is a recommendation, not an execution plan.

**Deliverables**:
- Conditional block appended to Phase 1 prompt (after line 423)
- Conditional block appended to Phase 2 prompt template (after line 639)
- Status line updates for Phases 1-3 with `ADV` prefix
- Approximately 25-30 lines added

**Dependencies**: Task 1 (the flag must be parsed before prompts can reference it)

### Task 3: Add advisory synthesis, termination, and wrap-up sections

**What**: Add the advisory-specific Phase 3 synthesis prompt variant, the Advisory Termination section (skip Phases 3.5-8), and the Advisory Wrap-up section (report generation, no branch/PR).

**Deliverables**:
- Advisory Synthesis subsection after Phase 3 synthesis (after line 703)
- Advisory Termination subsection after Phase 3 compaction checkpoint (after line 725)
- Advisory Wrap-up subsection after Advisory Termination
- Approximately 80-100 lines added

**Dependencies**: Task 1 (references `advisory-mode` context), Task 2 (advisory synthesis builds on advisory Phase 2 outputs)

### Task 4: Update report template for advisory mode

**What**: Add `advisory` to the `mode` field in TEMPLATE.md. Add conditional section rules for advisory reports. Document the Team Recommendation section (advisory-specific).

**Deliverables**:
- Updated `docs/history/nefario-reports/TEMPLATE.md`
- Approximately 15-20 lines added

**Dependencies**: Task 3 (the advisory report format must be defined before the template can codify it)

### Task 5: Update Core Rules and description for advisory awareness

**What**: Update the SKILL.md description (frontmatter lines 3-8) and Core Rules (lines 20-21) to acknowledge that advisory mode follows only Phases 1-3. The current Core Rules say "You ALWAYS follow the full workflow" -- advisory mode is a defined exception that should be explicitly noted so the LLM does not fight the abbreviated flow.

**Deliverables**:
- Updated description to mention advisory capability
- Note in Core Rules: "When `advisory-mode` is active, the workflow comprises Phases 1-3 and Advisory Wrap-up. Phases 3.5-8 are not applicable."
- Approximately 5 lines changed

**Dependencies**: Task 1

### Task 6: Verify `build-index.sh` handles advisory mode

**What**: Check whether `build-index.sh` displays or filters by `mode`. If so, ensure `advisory` is handled. If it only reads frontmatter generically, no changes needed.

**Deliverables**:
- Updated `build-index.sh` if needed, or confirmation that no change is required

**Dependencies**: Task 4

## Risks and Concerns

### 1. Core Rules conflict (MEDIUM risk)

The Core Rules (SKILL.md lines 20-21) emphatically state: "You ALWAYS follow the full workflow... EVEN if it appears to be only a single-file or simple thing." This is a hard directive designed to prevent the LLM from skipping phases on its own initiative. Advisory mode intentionally skips Phases 3.5-8, which could create a conflict in the LLM's interpretation. **Mitigation**: Task 5 explicitly adds advisory as a defined exception to the Core Rules. This must be done carefully -- the exception should be narrow ("when `advisory-mode` is active") not broad ("when phases are not applicable").

### 2. Phase 3 synthesis quality without Phase 3.5 review (LOW risk)

In normal mode, Phase 3.5 (architecture review) catches issues in the synthesis before execution. In advisory mode, the synthesis IS the final output -- there is no review phase to catch quality issues. The synthesis goes directly into the report. **Mitigation**: The advisory synthesis prompt should be explicit about output quality expectations. The user's team approval gate still applies, so the team composition is vetted. The risk is low because advisory reports are analytical documents, not code -- a quality issue in an advisory is less consequential than a quality issue in an execution plan.

### 3. Scope creep: user wants to "continue to execution" after advisory (MEDIUM risk)

A user may invoke `--advisory`, see the recommendation, and then say "okay, go ahead and implement it." The SKILL.md should have a clear response for this. **Mitigation**: The Advisory Wrap-up section should include a note: "If the user requests execution after an advisory run, respond: 'Advisory mode is complete. To execute, start a new orchestration: `/nefario <same task description>`.' Do not convert an advisory session into an execution session mid-stream." This is a firm boundary, not a prompt.

### 4. Line count growth (LOW risk)

The prior synthesis estimated ~60-70 lines. My specification totals approximately 140-170 lines across all insertions. This is larger because I include the full advisory synthesis prompt, complete wrap-up steps, and explicit conditional notes -- all of which are necessary for unambiguous LLM interpretation. SKILL.md goes from ~1939 lines to ~2100-2110 lines, a ~8% increase. **Mitigation**: The advisory sections are self-contained and do not interleave with existing logic. They can be read and maintained independently. The conditional structure is simple: check `advisory-mode`, branch once.

### 5. Report format divergence (LOW risk)

Advisory reports have different sections than execution reports (Team Recommendation instead of Execution/Decisions/Verification). This creates two report "shapes" that `build-index.sh` and any future tooling must handle. **Mitigation**: The `mode: advisory` frontmatter field makes the distinction machine-readable. The TEMPLATE.md update in Task 4 documents the conditional rules. The section differences are handled by omission (OMIT WHEN advisory) rather than transformation, keeping the template clean.

## Additional Agents Needed

None. The current team is sufficient. The task is scoped to SKILL.md modification (text editing, not code) and report template updates. No API design, infrastructure, frontend, or security considerations are involved.

If `build-index.sh` needs non-trivial changes (Task 6), the devx-minion can handle shell script modifications within its domain. No additional specialist is needed for that.
