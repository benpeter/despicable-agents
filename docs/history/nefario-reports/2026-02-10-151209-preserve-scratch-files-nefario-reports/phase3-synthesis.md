# Synthesis: Preserve Scratch Files in Nefario Execution Reports

## Delegation Plan

**Team name**: preserve-scratch-files
**Description**: Add companion directory support to nefario execution reports, preserving all intermediate planning artifacts alongside reports for full decision trail inspectability.

---

## Conflict Resolutions

### Conflict 1: Individual file links vs. directory link + manifest table

**software-docs-minion** recommends a flat bulleted list with individual relative links to each scratch file. **ux-strategy-minion** recommends a single directory link plus a phase-grouped manifest table.

**Resolution: Directory link + simple file list (hybrid).**

Both specialists make valid points. ux-strategy-minion is correct that individual links create false affordance and cognitive load for the PR reviewer (Audience A). software-docs-minion is correct that a manifest table with manually curated "Contents" descriptions adds generation complexity that violates YAGNI.

The resolution: a collapsible section with one directory link and a flat file listing (no table, no description column). The file listing uses the `Phase N: label` format from software-docs-minion for orientation, but does not attempt to generate descriptions. This serves both audiences: Audience A sees a collapsed block by default; Audience B expands it, gets the directory link, and sees the file listing for orientation before browsing.

Rationale for rejecting ux-strategy-minion's manifest table: generating a table with a "Contents" column per phase requires the SKILL.md to include logic for parsing file names and mapping them to phase descriptions. This is over-engineered for what amounts to a navigational convenience. The filenames themselves (e.g., `phase2-devx-minion.md`) are self-describing to anyone who knows the nefario process, which is the entire target audience.

### Conflict 2: "Scratch Files" vs. "Working Files"

**software-docs-minion** uses "Scratch Files". **ux-strategy-minion** recommends "Working Files" because "scratch" implies disposability.

**Resolution: "Working Files".**

ux-strategy-minion is right. The purpose of this feature is preservation. Calling the section "Scratch Files" sends a contradictory signal -- "here are the disposable files we preserved for you." "Working Files" communicates "intermediate work products" without the connotation of disposability. The internal directory can remain `nefario/scratch/` (it is an internal convention), but the user-facing label in the report should be "Working Files."

### Conflict 3: Section placement

**software-docs-minion** places it between Agent Contributions and Execution. **ux-strategy-minion** places it after Process Detail, before Metrics.

**Resolution: After Process Detail, before Metrics (ux-strategy-minion's placement).**

ux-strategy-minion's rationale is stronger: working files are raw archival material. They belong after all synthesized content (summary, decisions, contributions, execution, process detail). A reader should exhaust the curated content before reaching raw files. Placing them between Agent Contributions and Execution interrupts the flow from "who contributed" to "what was produced." The inverted pyramid principle already governing the template supports putting raw reference material near the bottom.

---

## Execution Plan

### Task 1: Update SKILL.md wrap-up sequence with scratch file collection

- **Agent**: devx-minion
- **Model**: sonnet
- **Mode**: bypassPermissions
- **Blocked by**: none
- **Approval gate**: no
- **Prompt**: |
    You are updating the nefario orchestration skill to collect scratch files
    into a companion directory alongside execution reports.

    ## Task

    Update `skills/nefario/SKILL.md` to add a scratch file collection step
    in the Wrap-up Sequence section. The new step goes between the current
    step 3 (auto-commit remaining changes) and step 4 (write execution report).

    ## What to Change

    ### Change 1: Move timestamp capture earlier

    Currently SKILL.md says to capture HHMMSS "at the moment of writing the
    report" (line 799-800). Change this to "at the start of the wrap-up
    sequence" so both the companion directory name and report filename share
    the exact same timestamp.

    In the Wrap-up Sequence, after step 1 ("Review all deliverables"), add
    a step to capture the timestamp:

    ```
    2. **Capture timestamp** -- record the current local time as HHMMSS
       (24-hour, zero-padded). This timestamp is used for both the companion
       directory name and the report filename. Capture it once; reuse it
       throughout wrap-up.
    ```

    Renumber subsequent steps accordingly.

    ### Change 2: Add scratch file collection step

    After "Auto-commit remaining changes" (which becomes step 4 after
    renumbering), add:

    ```
    5. **Collect working files** -- if the scratch directory
       `nefario/scratch/{slug}/` exists and contains files, copy them
       to a companion directory alongside the report:
       - Derive the companion directory name from the report filename:
         `docs/history/nefario-reports/<YYYY-MM-DD>-<HHMMSS>-<slug>/`
         (report filename without `.md` extension)
       - Create the companion directory: `mkdir -p <companion-dir>`
       - Copy all files: `cp -r nefario/scratch/{slug}/* <companion-dir>/`
       - Record the list of copied filenames in session context for report
         generation (the Working Files section)
       - If the scratch directory does not exist or is empty, skip this step.
         The report's Working Files section will say "None".
       - Note: scratch files are committed to git. Verify no secrets were
         captured during planning before committing.
    ```

    Renumber subsequent steps. The full sequence becomes:

    ```
    1. Review all deliverables
    2. Capture timestamp (HHMMSS, reuse for companion dir + report filename)
    3. Verification summary (consolidate Phase 5-8 outcomes)
    4. Auto-commit remaining changes
    5. Collect working files (copy scratch dir to companion dir)
    6. Write execution report (now with Working Files section linking
       to companion directory)
    7. Regenerate index
    8. Commit the report + companion directory together
    9. Offer PR creation
    10. Return to main
    11. Present report path, PR URL, branch name, verification summary
    12. Shutdown teammates
    13. TeamDelete
    14. Report final status
    ```

    ### Change 3: Update report writing step

    In step 6 (write execution report), update the timestamp reference to
    say "use the HHMMSS captured in step 2" instead of "capture HHMMSS as
    the current local time."

    ## What NOT to Change

    - Do not change the scratch file convention section (directory structure,
      naming, lifecycle -- those remain as-is)
    - Do not change Phases 1-8 logic
    - Do not change the report template (that is a separate task)
    - Do not modify build-index.sh

    ## Deliverables

    - Updated `skills/nefario/SKILL.md`

    ## Context

    Read the current SKILL.md at `skills/nefario/SKILL.md`. The Wrap-up
    Sequence starts at line 785 ("### Wrap-up Sequence (MANDATORY)").
    The companion directory naming must match the report filename minus
    `.md` -- e.g., if the report is `2026-02-10-143322-foo.md`, the
    companion dir is `2026-02-10-143322-foo/`.
- **Deliverables**: Updated `skills/nefario/SKILL.md` with new wrap-up step and updated timestamp handling
- **Success criteria**: The wrap-up sequence includes a working file collection step between auto-commit and report writing; timestamp is captured once and reused

### Task 2: Update TEMPLATE.md with Working Files section

- **Agent**: software-docs-minion
- **Model**: sonnet
- **Mode**: bypassPermissions
- **Blocked by**: none (can run in parallel with Task 1)
- **Approval gate**: no
- **Prompt**: |
    You are updating the nefario execution report template to include a new
    "Working Files" section for preserved scratch files.

    ## Task

    Update `docs/history/nefario-reports/TEMPLATE.md` to add a "Working Files"
    section to the report body and the report writing checklist.

    ## What to Change

    ### Change 1: Add Working Files section to body structure

    Add a new section between the existing "7. Process Detail" and "8. Metrics"
    sections. This becomes section 8; Metrics becomes section 9. The section
    format:

    ```markdown
    ### 8. Working Files

    Preserved intermediate artifacts from the orchestration run. Inside a
    collapsible `<details>` block.

    When a companion directory exists (scratch files were collected at wrap-up):

    ```markdown
    ## Working Files

    <details>
    <summary>Working files (N files)</summary>

    Companion directory: [<YYYY-MM-DD>-<HHMMSS>-<slug>/](./<YYYY-MM-DD>-<HHMMSS>-<slug>/)

    - [Phase 1: Meta-plan](./companion-dir/phase1-metaplan.md)
    - [Phase 2: devx-minion](./companion-dir/phase2-devx-minion.md)
    - [Phase 2: software-docs-minion](./companion-dir/phase2-software-docs-minion.md)
    - [Phase 3: Synthesis](./companion-dir/phase3-synthesis.md)
    - [Phase 3.5: security-minion](./companion-dir/phase3.5-security-minion.md)
    - ...

    </details>
    ```

    When no companion directory exists (no scratch files for this run):

    ```markdown
    ## Working Files

    None
    ```

    Important notes for the template:
    - The companion directory is a sibling directory in the same
      `docs/history/nefario-reports/` folder, named as the report filename
      without `.md` (e.g., `2026-02-10-143322-slug/`)
    - Relative links use `./companion-dir/filename.md` format
    - File list is generated from whatever files actually exist in the companion
      directory -- not a fixed set
    - Label convention: `Phase N: description` where description is derived from
      filename (phase1-metaplan -> "Meta-plan", phase2-{agent} -> agent name,
      phase3-synthesis -> "Synthesis", phase3.5-{agent} -> agent name,
      phase5-{agent} -> agent name, phase6-test-results -> "Test results",
      phase7-deployment -> "Deployment", phase8-{name} -> name)
    - N in the summary line is the actual file count
    - Blank line after `<summary>` and before `</details>` for GitHub rendering
    - Section is ABSENT for existing/older reports (backward compatibility:
      absence = no working files)

    ### Change 2: Update Report Writing Checklist

    Add a new step between the current step 11 ("Write Process Detail") and
    step 12 ("Write Metrics"):

    ```
    12. Write Working Files section (collapsible, list all files in companion
        directory with phase labels; or "None" if no companion directory)
    ```

    Renumber "Write Metrics" to step 13, and subsequent steps accordingly.

    ### Change 3: Renumber Metrics

    In the body structure, rename "### 8. Metrics" to "### 9. Metrics" since
    Working Files is now section 8.

    ## What NOT to Change

    - Do not change the YAML frontmatter schema (no new frontmatter fields)
    - Do not change template version number (this is an additive change within v2)
    - Do not change any existing section content (Summary, Task, Decisions,
      Agent Contributions, Execution, Process Detail, Metrics)
    - Do not modify build-index.sh or SKILL.md (separate tasks)
    - Do not retroactively modify existing reports

    ## Deliverables

    - Updated `docs/history/nefario-reports/TEMPLATE.md`

    ## Context

    Read the current TEMPLATE.md at `docs/history/nefario-reports/TEMPLATE.md`.
    The body structure currently has 8 sections (Report Title through Metrics).
    Working Files becomes section 8, pushing Metrics to section 9.
- **Deliverables**: Updated `docs/history/nefario-reports/TEMPLATE.md` with Working Files section and updated checklist
- **Success criteria**: Template includes a Working Files section with correct format, placement (between Process Detail and Metrics), and the checklist reflects the new step

### Task 3: Verify build-index.sh compatibility

- **Agent**: devx-minion
- **Model**: sonnet
- **Mode**: bypassPermissions
- **Blocked by**: none (can run in parallel with Tasks 1-2)
- **Approval gate**: no
- **Prompt**: |
    You are verifying that the build-index.sh script is compatible with
    companion directories being added alongside report files.

    ## Task

    Confirm that `docs/history/nefario-reports/build-index.sh` does not need
    changes to handle companion directories. The script currently uses the glob
    pattern `"$SCRIPT_DIR"/????-??-??-*-*.md` on line 18 to find report files.

    ## What to Verify

    1. The glob `????-??-??-*-*.md` explicitly requires a `.md` extension.
       Companion directories (e.g., `2026-02-10-143322-slug/`) do not end in
       `.md` and will not match. Confirm this.

    2. Run the script to verify it still produces correct output:
       ```
       cd /Users/ben/github/benpeter/despicable-agents
       bash docs/history/nefario-reports/build-index.sh
       ```
       Then check `docs/history/nefario-reports/index.md` for correct content.

    3. Simulate a companion directory to double-check:
       ```
       mkdir -p docs/history/nefario-reports/2026-02-10-143322-test-companion/
       touch docs/history/nefario-reports/2026-02-10-143322-test-companion/phase1-metaplan.md
       bash docs/history/nefario-reports/build-index.sh
       # Verify index.md does NOT include the companion directory
       cat docs/history/nefario-reports/index.md
       # Clean up
       rm -rf docs/history/nefario-reports/2026-02-10-143322-test-companion/
       ```

    ## Deliverables

    - Confirmation that no changes are needed to build-index.sh
    - Or, if the glob does match directories, a minimal fix

    ## What NOT to Change

    - Do not modify build-index.sh unless the verification reveals a bug
    - Do not modify TEMPLATE.md or SKILL.md
    - Clean up any test files/directories you create
- **Deliverables**: Verification result (confirmation or fix)
- **Success criteria**: build-index.sh glob does not match companion directories; index output is unchanged

---

## Cross-Cutting Coverage

- **Testing** (test-minion): Excluded. No executable code is produced -- only documentation templates and orchestration workflow instructions (SKILL.md markdown). Task 3 provides manual verification of build-index.sh compatibility, which is the only script involved.
- **Security** (security-minion): Addressed within Task 1 prompt. The SKILL.md update includes a note about verifying no secrets were captured in scratch files before committing. No new attack surface is created -- this copies existing local files into git.
- **Usability -- Strategy** (ux-strategy-minion): Addressed in planning. ux-strategy-minion's recommendations shaped the design: collapsible section, "Working Files" naming, placement after Process Detail, progressive disclosure for two audiences.
- **Usability -- Design** (ux-design-minion, accessibility-minion): Excluded. No user-facing interfaces are produced. The report is a markdown file rendered by GitHub.
- **Documentation** (software-docs-minion): Addressed. Task 2 is entirely a documentation template update. The TEMPLATE.md changes document the new section format and update the writing checklist.
- **Observability** (observability-minion, sitespeed-minion): Excluded. No runtime components, services, or APIs are produced. This is a documentation/workflow change.

## Architecture Review Agents

- **Always**: security-minion, test-minion, ux-strategy-minion, software-docs-minion, lucy, margo
- **Conditional**: None triggered (no runtime components, no UI, no web-facing components)

## Risks and Mitigations

### R1: Timestamp mismatch between companion directory and report filename (MEDIUM)

If the timestamp is captured at different moments for the companion directory vs. report filename, they will not match, breaking the naming convention.

**Mitigation**: Task 1 explicitly moves timestamp capture to the start of the wrap-up sequence (step 2), before both the companion directory creation and report writing. Both derive from the same captured value.

### R2: Repository bloat over time (LOW)

Each run adds 50-200KB of markdown files to git. Over 100 runs: 5-20MB. Negligible for a git repo.

**Mitigation**: No action now. Scratch files are markdown only (no binaries). Monitor after 20-30 runs. If needed, a retention policy can be added as a future ADR.

### R3: Scratch files may contain sensitive content (LOW)

Scratch files are copies of agent planning outputs. Moving them from gitignored `nefario/scratch/` to tracked `docs/history/nefario-reports/` elevates the exposure.

**Mitigation**: Task 1 includes a note in the SKILL.md: "scratch files are committed to git. Verify no secrets were captured during planning." Planning documents should not contain credentials, but the reminder ensures awareness.

### R4: Naming variation in scratch files (LOW)

Actual scratch files may not all follow the strict naming convention (e.g., `task7-consistency-check.md` was observed in past runs). The template listing must handle whatever files actually exist.

**Mitigation**: Task 2 specifies that the file list is "generated from whatever files actually exist in the companion directory -- not a fixed set." The label convention handles common patterns and falls back gracefully for unexpected names.

### R5: Incomplete companion directories from aborted runs (LOW)

If an orchestration is aborted, the companion directory may contain only partial files (Phase 1-2).

**Mitigation**: Acceptable. An incomplete companion directory alongside a report with `outcome: aborted` or `outcome: partial` is self-documenting. No special handling needed.

## Execution Order

All three tasks can run in **parallel** -- no sequential dependencies:

```
Batch 1 (parallel):
  Task 1: SKILL.md wrap-up sequence update (devx-minion)
  Task 2: TEMPLATE.md Working Files section (software-docs-minion)
  Task 3: build-index.sh verification (devx-minion)
```

No approval gates. All changes are additive, easy to reverse (config/docs), and have low blast radius. The gate classification matrix says: Easy to Reverse + Low Blast Radius = NO GATE.

## Verification Steps

After all tasks complete:

1. **SKILL.md**: Verify the wrap-up sequence has the new step 5 (collect working files) with correct ordering, and timestamp capture is in step 2.
2. **TEMPLATE.md**: Verify Working Files section is between Process Detail and Metrics, uses collapsible `<details>`, and checklist has the new step.
3. **build-index.sh**: Verify the script was confirmed compatible (or fixed if needed).
4. **Integration check**: The companion directory name (`<date>-<HHMMSS>-<slug>/`) must match the report filename (`<date>-<HHMMSS>-<slug>.md`) minus the extension. Verify this is consistent between SKILL.md and TEMPLATE.md.
5. **Existing reports**: Confirm no existing reports or index entries were modified.
