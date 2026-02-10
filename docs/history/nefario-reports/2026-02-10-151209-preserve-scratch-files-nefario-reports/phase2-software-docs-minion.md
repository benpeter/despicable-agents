# Domain Plan Contribution: software-docs-minion

## Recommendations

### Section Placement: After "Agent Contributions", Before "Execution"

The scratch files section belongs between Agent Contributions (section 5) and Execution (section 6) in the current report body order. Rationale:

1. **Inverted pyramid alignment**: The report's structure flows from "what happened" (Summary, Task, Decisions) through "who contributed" (Agent Contributions) to "what was produced" (Execution, Process Detail, Metrics). Scratch files are the raw evidence behind agent contributions -- they belong immediately after the summary of those contributions, before the execution outcomes.

2. **Reader flow**: A reader who drills into Agent Contributions and wants to see the full specialist output naturally looks for the link to raw files next, not after scrolling past execution tables and process detail.

3. **Alternative considered -- after Process Detail**: This would bury the scratch file links deep in the report. Most readers who want scratch files are investigating a specific decision or agent contribution, not process timing. Rejected.

4. **Alternative considered -- inside Agent Contributions `<details>`**: This conflates two different things: the summary of contributions (curated) and the raw files (archival). Keeping them separate is cleaner and makes the scratch files discoverable without expanding the collapsible block. Rejected.

### Markdown Format: Flat List with Relative Links

Use a flat bulleted list with relative links to files in the sibling directory. The directory name matches the report filename without `.md`, so links are predictable:

```markdown
## Scratch Files

<details>
<summary>Scratch Files (12 files)</summary>

- [Phase 1: Meta-plan](preserve-scratch-files-nefario-reports/phase1-metaplan.md)
- [Phase 2: devx-minion](preserve-scratch-files-nefario-reports/phase2-devx-minion.md)
- [Phase 2: software-docs-minion](preserve-scratch-files-nefario-reports/phase2-software-docs-minion.md)
- [Phase 3: Synthesis](preserve-scratch-files-nefario-reports/phase3-synthesis.md)
- [Phase 3.5: security-minion](preserve-scratch-files-nefario-reports/phase3.5-security-minion.md)
- [Phase 3.5: lucy](preserve-scratch-files-nefario-reports/phase3.5-lucy.md)
- [Phase 5: code-review-minion](preserve-scratch-files-nefario-reports/phase5-code-review-minion.md)

</details>
```

Key format decisions:

- **Collapsible `<details>` block**: Consistent with Agent Contributions and Process Detail sections. Keeps the report scannable. File count in the summary line gives a quick signal of orchestration complexity.
- **Relative links**: The companion directory is a sibling in the same `docs/history/nefario-reports/` folder, so relative links like `slug-name/phase2-devx-minion.md` work in both GitHub web view and local editors.
- **Label format: "Phase N: description"**: Each link label uses `Phase N: agent-name` or `Phase N: description` (e.g., "Phase 1: Meta-plan", "Phase 2: devx-minion"). This groups files visually by phase and tells the reader what each file contains without opening it.

### Grouping: Flat List Ordered by Phase, Not Grouped by Phase

List every file individually, ordered by phase number (1, 2, 2, 2, 3, 3.5, 3.5, 5, 6, 8). Do NOT group files under phase subheadings. Rationale:

- Most orchestration runs produce 8-18 scratch files. This is small enough that a flat list is scannable.
- Phase subheadings (`### Phase 2 files`, `### Phase 3.5 files`) add visual noise without improving navigation at this scale.
- The `Phase N:` prefix in each label already provides grouping.
- If a phase produced no files (e.g., Phase 6 skipped), there is simply no entry for that phase -- no empty subheading to explain away.

### Backward Compatibility: Section Absent = No Scratch Files

For existing reports, "section absent = no scratch files" is sufficient and correct. Reasons:

1. **Existing reports have no companion directories.** The scratch files for those runs are either deleted or sitting in `nefario/scratch/` (gitignored). Retroactively creating empty directories or placeholder sections adds no value.
2. **Template version is already `2`.** The version field in frontmatter tells readers which template was used. No need for a separate "scratch files: none" marker. A reader encountering an older report without this section knows why.
3. **No template version bump needed.** This is an additive change within the v2 template -- adding an optional section. Reports without it are valid v2 reports. Bumping to v3 would be YAGNI since the frontmatter version is not used for conditional rendering.

### Report Checklist Update

The TEMPLATE.md "Report Writing Checklist" at the bottom needs a new step between current step 9 (Agent Contributions) and step 10 (Execution). The new step:

```
9.5. Write Scratch Files section (collapsible, list all files in companion directory with phase labels)
```

Renumber subsequent steps accordingly.

## Proposed Tasks

### Task 1: Update TEMPLATE.md with Scratch Files Section

**What to do**: Add a new section "## Scratch Files" to the TEMPLATE.md body structure, positioned between the current "5. Agent Contributions" and "6. Execution" sections. Renumber sections 6-8 to 7-9. Add the section template with `<details>` block, file listing format, and label convention. Update the Report Writing Checklist with the new step.

**Deliverables**:
- Updated `docs/history/nefario-reports/TEMPLATE.md`

**Dependencies**: None. Can run first.

### Task 2: Verify Relative Link Paths Work in GitHub Rendering

**What to do**: Confirm that relative links from a markdown file to files in a sibling directory (e.g., `[label](slug-name/phase1-metaplan.md)`) render correctly on GitHub. This is a quick manual check or can be verified by examining existing GitHub rendering behavior for sibling-directory links.

**Deliverables**:
- Confirmation that the link format works, or an alternative format if it does not.

**Dependencies**: Task 1 (need to know the format before verifying it works).

### Task 3: Update index.md Format (if needed)

**What to do**: Evaluate whether `index.md` or `build-index.sh` need any changes to account for companion directories. My recommendation: no changes needed. The index links to report `.md` files, not scratch directories. The companion directory is discoverable from the report itself.

**Deliverables**:
- Confirmation that no index changes are needed, or minimal changes if required.

**Dependencies**: None.

## Risks and Concerns

### Risk 1: GitHub Rendering of Relative Links to Sibling Directories

Relative links in markdown on GitHub generally work for files in the same directory and subdirectories. Links to a sibling directory (same parent) like `slug-name/file.md` should work because the companion directory is a child of the same `nefario-reports/` parent. However, this should be verified before the format is locked in. If GitHub mangles these links, an alternative is to use the full relative path from the repo root: `docs/history/nefario-reports/slug-name/phase1-metaplan.md`.

**Mitigation**: Task 2 above explicitly validates this.

### Risk 2: Large Companion Directories Bloating Git History

Scratch files are currently gitignored. Moving them into `docs/history/nefario-reports/slug-name/` means they will be committed and tracked in git. Some scratch files are substantial (the `phase3-synthesis.md` files seen in the current scratch directory range from 16KB to 42KB). Across many orchestration runs, this will accumulate.

**Mitigation**: This is an accepted tradeoff (the task explicitly asks for preservation). But note that the total per-run is typically 80-200KB of markdown, which is reasonable for git. If it becomes a concern later, a separate ADR can address archival strategy (e.g., git-lfs, periodic pruning).

### Risk 3: Scratch File Naming Inconsistency

The current scratch file convention in SKILL.md defines the naming pattern (`phase1-metaplan.md`, `phase2-{agent}.md`, etc.), but the actual files in existing scratch directories show some variation (e.g., `task7-consistency-check.md` in the `extend-nefario-post-execution-phases` run). The template should document that the file list is auto-generated from whatever files exist in the companion directory, not hardcoded to a fixed set.

**Mitigation**: The TEMPLATE.md section should describe the listing as "all files found in the companion directory" rather than prescribing a fixed set. The SKILL.md collection logic handles discovering files.

### Risk 4: Report-Scratch Slug Mismatch

The companion directory name must exactly match the report filename minus `.md`. If the slug generation differs between Phase 1 (scratch directory creation) and wrap-up (report filename generation), the link paths will break. Currently the SKILL.md says to reuse the Phase 1 slug for the report filename, but the report filename also includes a timestamp prefix that the scratch directory does not have.

**Mitigation**: The companion directory in `docs/history/nefario-reports/` should use the FULL report filename minus `.md` (e.g., `2026-02-10-143322-improve-nefario-reporting-visibility/`), not just the slug. This means the SKILL.md collection step copies from `nefario/scratch/{slug}/` to `docs/history/nefario-reports/{report-basename-without-md}/`. This rename is handled by the SKILL.md logic, not the template.

## Additional Agents Needed

None. The current team is sufficient. The changes are to documentation templates (TEMPLATE.md) and orchestration workflow (SKILL.md), which are squarely within software-docs-minion and devx-minion territory. No runtime code, UI, or infrastructure is involved.
