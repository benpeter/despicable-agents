# Meta-Plan: Preserve Scratch Files in Nefario Execution Reports

## Planning Consultations

### Consultation 1: Scratch File Collection and Lifecycle

- **Agent**: devx-minion
- **Planning question**: The SKILL.md wrap-up sequence currently writes a report to `docs/history/nefario-reports/<date>-<time>-<slug>.md` and then regenerates the index. We want to add a step that copies scratch files from `nefario/scratch/{slug}/` into a companion directory at `docs/history/nefario-reports/<date>-<time>-<slug>/` (matching the report filename without `.md`). What is the right point in the wrap-up sequence to perform this copy -- before or after the report is written? Should the copy be a simple `cp -r` or should files be selectively collected? How should we handle the case where the scratch directory does not exist (e.g., aborted runs)? Should the companion directory be created unconditionally or only when scratch files exist?
- **Context to provide**: `skills/nefario/SKILL.md` (wrap-up sequence, scratch file convention, report generation), `.gitignore` (scratch is gitignored, reports are tracked), `docs/history/nefario-reports/TEMPLATE.md` (report format)
- **Why this agent**: devx-minion owns CLI/workflow design and developer tooling patterns. The scratch-to-report pipeline is a developer workflow concern -- file lifecycle, naming conventions, and the interaction between gitignored scratch and git-tracked report artifacts.

### Consultation 2: Report Template and Linking

- **Agent**: software-docs-minion
- **Planning question**: The report TEMPLATE.md needs a new section that links to companion scratch files. Where should this section appear in the report body (the current structure is: Summary, Task, Decisions, Agent Contributions, Execution, Process Detail, Metrics)? What markdown format works best for linking to files in a sibling directory? Should the section list every file with a label, or group them by phase? Should existing reports (which will not have companion directories) need any annotation, or is "section absent = no scratch files" sufficient?
- **Context to provide**: `docs/history/nefario-reports/TEMPLATE.md` (full template), an example scratch directory listing (e.g., the `improve-nefario-reporting-visibility` scratch dir contents), the report naming convention
- **Why this agent**: software-docs-minion owns documentation structure, template design, and cross-referencing patterns. The question is fundamentally about documentation architecture -- where a new section fits, how to link related artifacts, and maintaining template coherence.

## Cross-Cutting Checklist

- **Testing**: Exclude. No executable code is produced -- only documentation templates and a shell workflow (SKILL.md instructions). The build-index.sh script might need a guard against companion directories, which is testable, but the scope explicitly excludes retroactive changes and the script already filters by glob pattern `????-??-??-*-*.md`. No test infrastructure exists for SKILL.md instructions.
- **Security**: Exclude. No new attack surface, no auth, no user input processing, no secrets handling. Scratch files are already local artifacts. Moving copies into the git-tracked reports directory does not change their security posture -- they already contain only planning outputs (no credentials by convention).
- **Usability -- Strategy**: ALWAYS include. Planning question: The scratch files capture the full decision trail of an orchestration run. From a user journey perspective, who is the audience for these preserved artifacts? Is it the same user reviewing the report, or a different person auditing decisions later? Does linking every scratch file create cognitive overload, or should the report surface only a summary link to the companion directory? How does this interact with the existing collapsible sections pattern (Agent Contributions and Process Detail are already in `<details>` blocks)?
- **Usability -- Design**: Exclude. No user-facing interfaces are produced. The output is markdown files and shell workflow instructions.
- **Documentation**: Covered by Consultation 2 (software-docs-minion). No separate user-docs-minion consultation needed -- there are no end-user-facing docs affected.
- **Observability**: Exclude. No runtime components, services, or APIs. This is a documentation/workflow change only.

## Anticipated Approval Gates

1. **Companion directory naming and collection strategy** (MUST gate): This decision locks in how companion directories are named, when they are created, and what is collected. Downstream tasks (TEMPLATE.md update, SKILL.md update, build-index.sh guard) all depend on this convention. Hard to reverse once reports with companion directories are committed. High blast radius (3+ dependents).

No other gates anticipated. The template section placement and SKILL.md integration are execution details that flow from the approved strategy.

## Rationale

Three specialists are consulted:

- **devx-minion**: Owns the workflow/tooling dimension -- when and how to copy files, lifecycle management, interaction with gitignore vs. tracked files. This is the core engineering question.
- **software-docs-minion**: Owns the template/documentation structure dimension -- where the new section goes, how to link, format conventions. This ensures the report remains coherent.
- **ux-strategy-minion**: Mandatory cross-cutting. Ensures the preserved artifacts actually serve the user rather than just accumulating noise.

Agents NOT consulted and why:
- **iac-minion**: No infrastructure changes. The build-index.sh script may need a minor guard, but this is a 1-line glob concern, not an infrastructure design question.
- **data-minion**: No data modeling or storage decisions.
- **security-minion**: No security surface change (see checklist above).
- **test-minion**: No testable code produced (see checklist above).

## Scope

**In scope**:
- `skills/nefario/SKILL.md`: Add scratch file collection step to wrap-up sequence
- `docs/history/nefario-reports/TEMPLATE.md`: Add scratch files section to report body, update report writing checklist
- `docs/history/nefario-reports/build-index.sh`: Guard against companion directories (if needed -- current glob may already exclude them)
- Companion directory convention: naming, creation timing, content selection

**Out of scope**:
- Scratch file content or format (what agents write to scratch files)
- Agent specs or planning phase logic
- Retroactive restructuring of existing reports
- Changes to the scratch file convention itself (the `nefario/scratch/` workflow is unchanged)
- Cleanup of old scratch files from `nefario/scratch/`
