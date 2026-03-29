# Lucy Review -- adapter-interface-definition

## Verdict: ADVISE

### Requirement Traceability

| Original Requirement (Issue 1.1) | Plan Element | Status |
|----------------------------------|-------------|--------|
| `DelegationRequest`: agent name, task prompt, instruction file path, working directory, model tier, required tools list | Task 1 field table: `agent_name`, `task_prompt`, `translated_instruction_path`, `working_directory`, `model_tier`, `required_agent_tools` | Covered |
| `DelegationResult`: exit code, changed files, stdout summary, stderr, raw diff reference | Task 1 field table: `exit_code`, `changed_files`, `task_summary`, `stderr`, `raw_diff_path` | Covered |
| No implementation -- types and contracts only | Plan produces only `docs/adapter-interface.md` + two link edits | Covered |
| Language/format matches surrounding codebase (document the decision) | Format Decision section using Markdown field tables + YAML examples, matching `agent-anatomy.md` | Covered |
| Types are defined and documented | Task 1 deliverable | Covered |
| Interface is minimal -- covers Codex and Aider, nothing more | Field inclusion/exclusion table with YAGNI justification | Covered |
| No harness-specific fields in shared types | Verification step 5 explicitly checks this | Covered |
| Link into existing docs structure | Task 2: architecture.md row + roadmap forward pointer | Covered |

All stated requirements trace to plan elements. No requirements are missing.

### Drift Assessment

The plan is tightly scoped. Two tasks, one new file, two single-line edits. No code, no configuration, no tests to write. This matches the issue's "types and contracts only" constraint.

### Findings

1. [SCOPE]: Three fields added beyond roadmap scope
   SCOPE: `timeout_ms`, `success`, `duration_ms` in DelegationRequest/DelegationResult
   CHANGE: No change needed -- the plan already documents the justification for each and explicitly applies the YAGNI filter to reject four other proposed fields.
   WHY: The synthesis provides clear traceability: `timeout_ms` is referenced in Issue 2.1 and 3.2 acceptance criteria, `success` prevents abstraction leakage (orchestrator would otherwise need per-tool exit code knowledge), `duration_ms` avoids a breaking change when M4 progress monitoring needs it. Four other proposed fields were correctly rejected. The YAGNI filter was applied; these three passed it with documented rationale. Noting for the record but not blocking.
   TASK: 1

2. [CONVENTION]: Back-link pattern in Task 1 prompt differs slightly from existing docs
   SCOPE: `docs/adapter-interface.md` cross-reference header
   CHANGE: The Task 1 prompt specifies a back-link to both `architecture.md` AND `external-harness-roadmap.md`. The existing pattern in `agent-anatomy.md` links only to `architecture.md`. The roadmap doc itself uses `architecture.md | external-harness-integration.md` (two links separated by pipe). Ensure the two-link format uses the pipe separator pattern: `[< Back to Architecture Overview](architecture.md) | [External Harness Roadmap](external-harness-roadmap.md)`.
   WHY: The roadmap document already establishes the pipe-separated two-link pattern. The Task 1 prompt's cross-reference section (line 215) does specify this exact format, so it is correct. However, the document structure outline (line 102) says only "Back-link to architecture.md + external-harness-roadmap.md" using a plus sign, which is ambiguous. The software-docs-minion should follow the explicit format on line 215, not the abbreviated outline on line 102. Minor ambiguity, low risk since the explicit format is stated.
   TASK: 1

3. [CONVENTION]: Field naming renames should be noted as divergences from roadmap vocabulary
   SCOPE: `translated_instruction_path` (was `instruction_file_path`), `task_summary` (was `stdout_summary`), `raw_diff_path` (was `raw_diff_reference`), `required_agent_tools` (was `required_tools`)
   CHANGE: The "Fields Considered and Excluded" section documents rejected fields, but the four field renames from roadmap vocabulary are documented only in the synthesis conflict resolution, not in the Task 1 prompt's deliverable structure. Ensure the spec document itself notes these renames (or at minimum, the Format Decision section acknowledges that field names were refined from the roadmap's working vocabulary).
   WHY: Downstream issues (1.2, 2.1, 2.2, 3.1, etc.) reference the roadmap's original field names. If the adapter-interface.md silently uses different names without a mapping note, adapter authors cross-referencing the roadmap will encounter name mismatches. A brief "Field names refined from roadmap" note prevents confusion.
   TASK: 1

### Convention Compliance

- **CLAUDE.md "English only" for technical artifacts**: Satisfied. All deliverables are English Markdown.
- **CLAUDE.md "Do NOT modify the-plan.md"**: Satisfied. No plan modifications proposed.
- **CLAUDE.md "Never delete remote branches"**: Not applicable.
- **CLAUDE.md Engineering Philosophy (YAGNI/KISS)**: Satisfied. Plan explicitly applies YAGNI filter to proposed fields, rejects four, includes three with justification.
- **CLAUDE.md "No PII, no proprietary data"**: Satisfied. Specification document contains no PII.
- **docs/ back-link pattern**: Addressed in finding 2.
- **docs/ hub-and-spoke linking**: Task 2 correctly adds the architecture.md row and roadmap forward pointer.
- **CLAUDE.local.md external-harness branch targeting**: Not directly relevant to this plan (no PR is being created in this plan), but nefario should ensure the eventual PR targets `external-harness`, not `main`.

### Scope Containment

No scope creep detected. The plan produces exactly what Issue 1.1 asks for: a type definition and contract specification document, plus the minimal cross-reference edits to integrate it into the existing doc structure. The behavioral contract section (lifecycle, error handling, adapter boundaries) is explicitly part of "types and contracts" -- it defines what adapters must and must not do, which is the contract half of the deliverable.
