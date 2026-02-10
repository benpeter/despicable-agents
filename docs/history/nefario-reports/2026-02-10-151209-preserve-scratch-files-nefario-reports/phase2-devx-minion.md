# Domain Plan Contribution: devx-minion

## Recommendations

### 1. Copy BEFORE the report is written, not after

The report needs to link to scratch files by relative path. If the companion directory does not exist yet when the report is generated, the links are speculative (you are linking to something that might fail to copy). By copying first, the report generation step can:

- Confirm which files actually exist in the companion directory.
- Generate accurate links (no dead links from copy failures).
- Include a file manifest derived from what was actually collected, not what was expected.

The right insertion point in the wrap-up sequence (SKILL.md lines 786-811) is between step 3 (auto-commit remaining changes) and step 4 (write execution report). This becomes step 3.5:

```
1. Review all deliverables
2. Verification summary
3. Auto-commit remaining changes
3.5 NEW: Copy scratch files to companion directory
4. Write execution report (now with links to companion files)
5. Regenerate index
6. Commit the report + companion directory together
...
```

Committing the companion directory together with the report in step 6 keeps them atomic -- a single commit means the report and its scratch files never exist separately in git history.

### 2. Use `cp -r` with the full directory, not selective collection

Selective collection adds complexity with no proportional benefit. The scratch files are small markdown files (typically 5-15 per run, each under 10KB). A full `cp -r` of the scratch directory:

- Is simple and predictable (KISS).
- Preserves the complete decision trail, which is the stated goal.
- Avoids a "which files matter?" decision that would need to be maintained as phases evolve.
- Total size per run: typically 50-150KB. Negligible in a git repo.

The only transformation needed: none. The filenames already encode phase and agent (e.g., `phase2-devx-minion.md`, `phase3-synthesis.md`), which provides all the labeling needed.

### 3. Create companion directory ONLY when scratch files exist

Unconditional creation violates KISS. An empty directory is noise:

- It adds a directory to git that communicates nothing.
- It requires `.gitkeep` or similar to even persist in git.
- It creates confusion ("why is this empty?").

The logic should be:

```
scratch_dir="nefario/scratch/${slug}"
if [ -d "$scratch_dir" ] && [ "$(ls -A "$scratch_dir")" ]; then
  companion_dir="docs/history/nefario-reports/${report_stem}"
  mkdir -p "$companion_dir"
  cp -r "$scratch_dir"/* "$companion_dir"/
fi
```

Where `report_stem` is the report filename without `.md` (e.g., `2026-02-10-143322-improve-nefario-reporting-visibility`).

For aborted runs: if the scratch directory does not exist or is empty, the companion directory is simply not created. The report template section for scratch files should say "None" or be omitted entirely, which is consistent with how the template handles other optional sections (e.g., "If no gates: 'None'").

### 4. Handle the slug-to-path mapping carefully

There is a subtle naming gap. The scratch directory uses the slug alone (`nefario/scratch/{slug}/`), but the companion directory uses the full report stem that includes date and time (`docs/history/nefario-reports/<date>-<time>-<slug>/`). The slug is available early (Phase 1), but the date-time prefix is only known at report write time.

The orchestrator already generates the report filename at wrap-up. The companion directory name must be derived from that same filename. The sequence should be:

1. Generate the report filename: `report_file="docs/history/nefario-reports/${date}-${time}-${slug}.md"`
2. Derive companion dir: `companion_dir="${report_file%.md}"`
3. Copy scratch files into `companion_dir`
4. Write the report to `report_file` with links relative to `companion_dir`

This means the timestamp must be captured BEFORE the copy, not during report writing. The current SKILL.md already says to capture HHMMSS "at the moment of writing the report" -- this should be tightened to "at the start of the wrap-up sequence" so both the companion directory and the report share the same timestamp.

### 5. Keep build-index.sh unchanged

The current glob pattern in build-index.sh is `"$SCRIPT_DIR"/????-??-??-*-*.md` (line 18). This explicitly matches `.md` files. Companion directories (which do not end in `.md`) will never match this glob. No guard is needed. This is already correct by construction.

### 6. Linking format in the report

The report should include a single directory-level link plus a manifest, not individual file links. Reasoning:

- Individual links to 10-15 files clutter the report.
- A manifest (simple list with phase labels) provides the decision trail index.
- The directory link lets readers browse freely.

Suggested format for the report (collapsible, consistent with existing patterns):

```markdown
## Scratch Files

<details>
<summary>Scratch Files (12 files)</summary>

Companion directory: [preserve-scratch-files-nefario-reports/](./2026-02-10-HHMMSS-preserve-scratch-files-nefario-reports/)

| File | Phase | Description |
|------|-------|-------------|
| phase1-metaplan.md | Meta-plan | Specialist selection and planning questions |
| phase2-devx-minion.md | Planning | Developer experience recommendations |
| phase2-software-docs-minion.md | Planning | Documentation structure recommendations |
| phase3-synthesis.md | Synthesis | Consolidated execution plan |
| phase3.5-lucy.md | Review | Consistency review verdict |
| phase3.5-margo.md | Review | Simplicity review verdict |

</details>
```

The description column can be auto-generated from file naming convention:
- `phase1-*` -> "Meta-plan" phase, description from metaplan title
- `phase2-*` -> "Planning" phase, agent name from filename
- `phase3-synthesis*` -> "Synthesis"
- `phase3.5-*` -> "Review"
- `phase5-*` -> "Code Review"
- `phase6-*` -> "Test Execution"
- `phase7-*` -> "Deployment"
- `phase8-*` -> "Documentation"

This mapping is static and can be hardcoded in SKILL.md instructions without needing a script.

## Proposed Tasks

### Task 1: Add scratch file collection to SKILL.md wrap-up sequence

**What to do**: Insert a new step between auto-commit (step 3) and report writing (step 4) in the Wrap-up Sequence section of SKILL.md. The step should:
1. Check if `nefario/scratch/{slug}/` exists and is non-empty.
2. Generate the report filename stem (date-time-slug, no `.md`).
3. Create the companion directory at `docs/history/nefario-reports/{stem}/`.
4. Copy all files from the scratch directory into the companion directory.
5. Record the list of copied files (filenames only) in session context for report generation.

Also update the timestamp capture instruction: move it from "at the moment of writing the report" to "at the start of the wrap-up sequence" so both the companion directory name and report filename share the same timestamp.

**Deliverables**: Updated `skills/nefario/SKILL.md` with the new step and updated timestamp instruction.

**Dependencies**: None (this is the foundational task).

### Task 2: Add Scratch Files section to TEMPLATE.md

**What to do**: Add a new "Scratch Files" section to the report body template. Place it after "Process Detail" and before "Metrics" (it is supplementary reference material, less important than process detail, more important than raw metrics). The section should:
- Be inside a collapsible `<details>` block (consistent with Agent Contributions and Process Detail).
- Include a directory link and file manifest table.
- Document the "None" case for when no companion directory exists.
- Add the section to the Report Writing Checklist.

**Deliverables**: Updated `docs/history/nefario-reports/TEMPLATE.md`.

**Dependencies**: Task 1 (needs to know the companion directory naming convention).

### Task 3: Verify build-index.sh compatibility

**What to do**: Confirm that `build-index.sh` does not need changes. The glob `????-??-??-*-*.md` already excludes directories. Run the script against the reports directory to verify it still produces correct output if a companion directory existed alongside a report file.

**Deliverables**: Confirmation that no changes are needed (or a 1-line fix if the glob does match directories unexpectedly).

**Dependencies**: None (can run in parallel with Tasks 1-2).

## Risks and Concerns

### R1: Scratch files may contain sensitive content (LOW)

Scratch files are copies of agent planning outputs. The existing SKILL.md already has a security sanitization rule for the verbatim prompt in the report. However, scratch files are raw agent outputs -- they might contain references to local paths, temporary credentials mentioned in task descriptions, etc.

**Mitigation**: The existing sanitization convention applies at report write time. Scratch files, being planning documents, should not contain secrets (agents do not handle credentials). The copy is wholesale -- no transformation. If a scratch file somehow contains sensitive data, it was already written to disk in `nefario/scratch/` (just gitignored). Moving it to a tracked directory elevates the risk. The SKILL.md instruction should include a note: "Scratch files are committed to git. Ensure no secrets were captured during planning."

### R2: Repository bloat over time (LOW)

Each orchestration run adds 50-150KB of scratch files to git. Over 100 runs, that is 5-15MB. This is negligible for a git repo. However, binary files or unusually large outputs could be an issue.

**Mitigation**: Scratch files are markdown only. The convention enforces this. No action needed now; monitor after 20-30 runs.

### R3: Aborted or partial runs produce incomplete companion directories (LOW)

If an orchestration is aborted mid-run, the scratch directory may contain only Phase 1-2 files. The companion directory will be incomplete but still valuable (it shows how far planning got).

**Mitigation**: This is acceptable behavior. An incomplete companion directory alongside a report with `outcome: aborted` or `outcome: partial` is self-documenting. No special handling needed.

### R4: Timestamp must be captured before copy, not during report write (MEDIUM)

If the timestamp is captured at different moments for the companion directory name vs. the report filename, they will not match. This would break the "directory named to match the report filename" success criterion.

**Mitigation**: Task 1 explicitly addresses this by moving the timestamp capture earlier in the wrap-up sequence. Both the companion directory and report filename derive from the same captured timestamp.

## Additional Agents Needed

None. The current team (devx-minion for workflow, software-docs-minion for template, ux-strategy-minion for usability) covers all dimensions. The build-index.sh verification (Task 3) is a simple glob check that any agent can handle -- no iac-minion or shell specialist needed.
