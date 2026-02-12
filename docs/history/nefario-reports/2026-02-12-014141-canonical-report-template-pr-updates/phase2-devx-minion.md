## Domain Plan Contribution: devx-minion

### Recommendations

#### A. Inconsistency Audit Across Existing Reports

Having reviewed 7 reports spanning v1 (sequence-numbered) and v2 (timestamp-based), the specific inconsistencies that the template must eliminate are:

**Section naming drift**:
- "Executive Summary" (5 older reports) vs "Summary" (3 newer reports) -- the TEMPLATE.md says "Summary" but older reports pre-date it
- "Task" (1 report, `2026-02-10-162741`) vs "Original Prompt" (newer reports) -- transition happened mid-stream
- "Key Design Decisions" (1 report, `2026-02-11-143008`) vs "Decisions" (TEMPLATE.md standard)

**Frontmatter field drift**:
- v1 reports: `sequence`, no `time`, no `version`
- v2 reports (TEMPLATE-compliant): `type`, `version: 2`, `date`, `time`, `task`, `mode`, `agents-involved`, `task-count`, `gate-count`, `outcome`
- The `2026-02-11-143008` (external-skill-integration) and `2026-02-11-132900` (remove-overlay-mechanism) reports use a DIFFERENT v2-era frontmatter: `task`, `source-issue`, `date`, `branch`, `status`, `agents-consulted`, `agents-reviewed`, `tasks-executed`, `gates`, `verification` -- 10 fields but WRONG 10 fields. This is the most damaging inconsistency because these are the TWO MOST RECENT reports.

**Section ordering variance**:
- TEMPLATE.md order: Summary, Original Prompt, Decisions, Agent Contributions, Execution, Process Detail, Working Files, Metrics
- `2026-02-11-143008` order: Executive Summary, Original Prompt, Key Design Decisions, Agent Contributions, Execution, Verification, Conflicts Resolved, Outstanding Items, Working Files
- `2026-02-11-132900` order: Executive Summary, Original Prompt, Execution, Decisions, Agent Contributions, Verification, Working Files
- The v1 reports have completely different structures (Decisions as table rows, header block with metrics inline)

**Missing sections**:
- Neither of the two most recent reports has "Process Detail" (the collapsible section with phases/timing/outstanding)
- Neither has "Metrics" table
- The `2026-02-11-132900` report puts "Execution" before "Decisions" -- inverted from template
- "Conflict Resolutions" appears as standalone H2 in `2026-02-11-143008` but is inline under Decisions in TEMPLATE.md

**Working Files formatting**:
- `2026-02-11-143008` and `2026-02-11-132900`: flat list, no `<details>` wrapper, no relative links (just directory reference + filename list)
- TEMPLATE-compliant reports (`2026-02-10-163605`, `2026-02-10-163014`, `2026-02-10-162741`): proper `<details>`, relative links, file count in summary

#### B. Optimal Template Structure for LLM Determinism

The template must be structured as a **literal fill-in-the-blank document** -- not guidelines with examples. LLMs drift when given "write something like this." They follow precisely when given "copy this structure verbatim and fill in the bracketed placeholders."

**Recommendation 1: Replace the current example-based TEMPLATE.md with a single canonical template written as literal markdown with `{PLACEHOLDER}` tokens.** Every section header is fixed text. Every piece of variable content is a named placeholder. The LLM copies the structure and replaces placeholders -- it never invents structure.

Concrete structure (the canonical section order from the issue, mapped to what works):

```markdown
---
type: nefario-report
version: 3
date: "{YYYY-MM-DD}"
time: "{HH:MM:SS}"
task: "{one-line task description}"
source-issue: {N or omit line}
mode: {full | plan}
agents-involved: [{list}]
task-count: {N}
gate-count: {N}
outcome: {completed | partial | aborted}
---

# {task frontmatter value}

## Summary

{2-3 sentences. What changed and why it matters.}

## Original Prompt

{blockquote for <20 lines, collapsible for >=20 lines}

## Key Design Decisions

{Each decision as H4 with Rationale + Alternatives Rejected + optional Gate outcome/Confidence}

### Conflict Resolutions

{List of conflicts and how resolved, or "None."}

## Phases

{Narrative-style description of how the orchestration flowed. 1-2 paragraphs covering the arc from meta-plan through execution. Uses narrative style, not tables.}

## Agent Contributions

<details>
<summary>Agent contributions ({N} planning, {N} review)</summary>

### Planning

{Per-agent: name, recommendation, adopted items, risks}

### Architecture Review

{Per-agent: verdict + proportional detail}

</details>

## Execution

### Tasks

{Table: #, Task, Agent, Status}

### Files Changed

{Table: File Path, Action, Description -- ALL files in PR}

### Approval Gates

{Table: Gate Title, Agent, Confidence, Outcome, Rounds}

{Per-gate H4 with Decision, Rationale, Rejected}

## Verification

{Table: Phase, Result -- code review, tests, deployment, docs}

## External Skills

{Conditional: only if external skills were discovered. Table: Skill, Classification, Recommendation, Tasks Used.}

## Working Files

<details>
<summary>Working files ({N} files)</summary>

{Companion directory link + relative links to ALL files}

</details>

## Test Plan

{Conditional: only if tests were produced or test strategy is notable.}

## Post-Nefario Updates

{Conditional: only when subsequent commits land on the same branch after initial report.}
```

**Recommendation 2: Rename "Decisions" to "Key Design Decisions".** This matches the issue spec and is more descriptive than the generic "Decisions." The two most recent reports already use "Key Design Decisions" -- this aligns the template with observed LLM preference.

**Recommendation 3: Add a "Phases" section in narrative style.** The issue specifically calls for this, referencing PR #33 narrative style. This replaces the "Process Detail" collapsible section's "Phases Executed" table with readable prose. The timing and outstanding items from "Process Detail" move into existing sections (Metrics absorbs timing, outstanding items go into a final section or stay in Process Detail if retained).

**Recommendation 4: Flatten "Process Detail" into the report body.** The current template nests Verification, Timing, and Outstanding Items inside a collapsible "Process Detail" wrapper. This hides important information (verification results) behind a click. Pull Verification out as a top-level H2. Move Timing into Metrics or the Phases narrative. Move Outstanding Items into a dedicated section or append to Verification.

**Recommendation 5: Drop the "Metrics" section.** It duplicates data available in frontmatter and other sections. Every field in the Metrics table is already present somewhere: date (frontmatter), task (frontmatter), duration (Phases narrative), outcome (frontmatter), agent counts (Agent Contributions summary line), gates (Execution section), files (Execution section), outstanding (wherever they land). Metrics is a DRY violation that the LLM sometimes fills inconsistently. If machine-readable summary data is needed, frontmatter serves that purpose.

**Recommendation 6: Conditional sections use explicit inclusion rules.** Write rules as: "Include this section IF {condition}. Omit entirely IF {condition}." Not "optional." The word "optional" gives the LLM latitude to include or exclude based on vibes. Explicit conditions are deterministic.

Conditional section rules:
- **External Skills**: Include IF meta-plan discovered 1+ external skills. Omit IF none discovered.
- **Test Plan**: Include IF execution produced test files or test strategy decisions were made. Omit IF no tests involved.
- **Post-Nefario Updates**: Include IF this is an update to an existing report (subsequent nefario run or manual addition). Never present in initial report generation.
- **Conflict Resolutions**: Always include as subsection of Key Design Decisions. Content is "None." if no conflicts.

#### C. PR Body Generation (Report = PR Body)

The current mechanism (strip frontmatter, pipe to `gh pr create --body-file`) is sound. Two adjustments:

**Recommendation 7: The report structure must render cleanly in both GitHub file view AND GitHub PR description view.** This means:
- No raw HTML that GitHub sanitizes differently in markdown files vs PR bodies (test: `<details>` and `<summary>` work in both -- confirmed)
- Relative links in Working Files use `./` prefix so they work in the file context. In PR body context, they become broken links -- this is acceptable because PR reviewers navigate from the Files Changed tab, not from embedded links. Document this tradeoff.
- The `Resolves #N` line (for issue-linked PRs) should go at the very end of the body, after all sections. This is a GitHub convention and keeps it visible.

**Recommendation 8: The title for the PR comes from the frontmatter `task` field, truncated to 70 characters.** This is already the convention but should be explicit in the template.

#### D. Post-Nefario Update Mechanism

This is the most nuanced design question. Three options evaluated:

**Option 1: Auto-detect on re-run (nefario convention)**
- On Phase 4 branch creation, detect existing PR on current branch via `gh pr list --head <branch> --json number`
- If PR exists, after wrap-up, append a "Post-Nefario Updates" section to both the report file AND the PR body
- Pros: zero friction, fully automatic
- Cons: Requires nefario to read and edit an existing report file (fragile string manipulation), couples nefario to GitHub API for PR body updates, adds complexity to an already-long SKILL.md

**Option 2: Standalone command**
- A simple shell function or skill: `nefario-update-pr` that reads the most recent report on the current branch, diffs the commits since the report was written, and appends a summary
- Pros: decoupled from nefario orchestration, user-invokable
- Cons: Another tool to maintain, user must remember to run it

**Option 3: Manual section with template**
- The report template includes a commented-out "Post-Nefario Updates" section
- When subsequent work lands, the user (or a nefario re-run) appends the section manually
- Pros: simplest, no automation needed, no fragile file editing
- Cons: relies on human discipline, easy to forget

**Recommendation 9: Use Option 1 (auto-detect) with a lightweight implementation.** The mechanism:

1. During Phase 4 branch setup, check: `gh pr list --head $(git branch --show-current) --json number,body --jq '.[0]'`
2. If a PR exists, set `existing-pr: <number>` in session context
3. At wrap-up, after writing the NEW report (a separate report file -- do NOT edit the original):
   a. Generate a "Post-Nefario Updates" markdown block:
      ```
      ## Post-Nefario Updates

      ### {YYYY-MM-DD} {HH:MM:SS} -- {one-line summary}

      {2-3 sentences describing what changed and why}

      **Commits**: {N} commits since initial PR
      **Files**: {changed file list, max 5}
      **Report**: [{new-report-slug}](./path-to-new-report.md)
      ```
   b. Append this block to the PR body using `gh pr edit <number> --body-file`
   c. The NEW report is a complete standalone report (not a delta). It links back to the original report.

This approach:
- Never edits existing report files (historical immutability preserved)
- Creates a new report for the new work (complete, standalone)
- Appends to the PR body only (mutable artifact, appropriate for updates)
- Uses `gh pr edit` which is a single API call
- If `gh` is unavailable, prints a nudge: "PR #N exists on this branch. Run `gh pr edit <N>` to update the description."

**Recommendation 10: Nefario re-runs on the same branch should detect and handle gracefully.** When nefario detects it is running on a branch that already has a PR:
- Do NOT create a new branch (current behavior is correct -- stay on existing branch)
- Do NOT create a new PR (detect existing, update it)
- DO write a new report file (separate from the original)
- DO append "Post-Nefario Updates" to the existing PR body

#### E. Template Version Bump

**Recommendation 11: Bump template version to 3.** The structural changes (new section order, renamed sections, new conditional sections, narrative Phases) are significant enough to warrant a version bump. This lets `build-index.sh` handle v1, v2, and v3 reports differently if needed. The frontmatter field set changes slightly (adding `source-issue` as a standard optional field that was previously ad-hoc).

### Proposed Tasks

#### Task 1: Rewrite TEMPLATE.md as canonical fill-in template (version 3)
- **What**: Replace the current example-based TEMPLATE.md with a literal template using `{PLACEHOLDER}` syntax. Every section is defined with exact heading, content guidance, and conditional inclusion rules.
- **Deliverables**: Updated `docs/history/nefario-reports/TEMPLATE.md`
- **Dependencies**: None (first task)
- **Key decisions**:
  - Section order: frontmatter, Summary, Original Prompt, Key Design Decisions (with Conflict Resolutions subsection), Phases (narrative), Agent Contributions (collapsible), Execution (tasks + files + gates), Verification, External Skills (conditional), Working Files (collapsible), Test Plan (conditional), Post-Nefario Updates (conditional)
  - Drop Metrics section (DRY violation with frontmatter)
  - Drop Process Detail wrapper (flatten Verification to top-level, merge Timing into Phases narrative)
  - Rename "Decisions" to "Key Design Decisions"
  - Add "Phases" narrative section
  - Bump version to 3

#### Task 2: Update SKILL.md Report Generation and Wrap-up Sequence
- **What**: Update the inline report format guidance in SKILL.md to reference TEMPLATE.md as the single source of truth (currently SKILL.md says "report format is defined inline below" but TEMPLATE.md also exists -- this dual-source is a consistency risk). Add the "Post-Nefario Updates" PR body update mechanism to the wrap-up sequence.
- **Deliverables**: Updated `skills/nefario/SKILL.md` (Report Generation section, Wrap-up Sequence, Data Accumulation)
- **Dependencies**: Task 1 (template must be finalized first)
- **Key changes**:
  - Report Template subsection: point to TEMPLATE.md as canonical, remove inline duplication
  - Wrap-up Sequence: add PR detection step, add PR body update logic for existing PRs
  - Data Accumulation: add `existing-pr` tracking in Phase 4

#### Task 3: Update Report Writing Checklist
- **What**: The checklist at the bottom of TEMPLATE.md must match the new section order exactly. Each step should reference a section by name and number.
- **Deliverables**: Updated checklist in `docs/history/nefario-reports/TEMPLATE.md`
- **Dependencies**: Task 1

### Risks and Concerns

1. **LLM adherence to the new template may still drift on the first few runs.** Even a literal fill-in template can be deviated from if the LLM's training data biases toward a different report structure. Mitigation: the SKILL.md Wrap-up Sequence should include an explicit instruction: "Read TEMPLATE.md. Follow it exactly. Do not invent sections or reorder them."

2. **The `gh pr edit` mechanism for Post-Nefario Updates depends on `gh` CLI being authenticated and available.** This is already a dependency for PR creation, so it is not new risk, but the fallback path (printing a nudge) must be tested.

3. **Dual-source risk between SKILL.md and TEMPLATE.md.** Currently SKILL.md says "report format is defined inline below" AND TEMPLATE.md exists. This is the root cause of the frontmatter drift in the two most recent reports -- the LLM followed the SKILL.md inline hints instead of reading TEMPLATE.md. The fix is to make SKILL.md explicitly reference TEMPLATE.md as the source of truth and remove inline format duplication.

4. **Dropping the Metrics section may surprise users who grep reports for summary data.** Mitigation: frontmatter contains the same data in a more machine-parseable format. `build-index.sh` already reads frontmatter.

5. **The "Phases" narrative section requires the LLM to write prose, which is harder to template than tables.** Provide 2-3 example paragraphs in the template guidance to anchor the expected style and length (targeting 3-6 sentences).

6. **Existing reports are NOT modified (historical immutability constraint).** The v3 template must coexist with v1 and v2 reports. `build-index.sh` must handle all three versions. This is already the case for v1/v2 -- adding v3 is incremental.

### Additional Agents Needed

- **software-docs-minion**: Should review the template structure for documentation consistency and cross-reference integrity (TEMPLATE.md references from SKILL.md, orchestration.md, etc.). Already likely in the plan given this is a documentation-heavy task.
- **ai-modeling-minion**: Should evaluate whether the template structure is actually deterministic for LLM generation -- they have domain expertise on prompt engineering and LLM output consistency that is directly relevant to "can the LLM follow this template reliably."

No other additional agents needed. The current team should be sufficient for this scope.
