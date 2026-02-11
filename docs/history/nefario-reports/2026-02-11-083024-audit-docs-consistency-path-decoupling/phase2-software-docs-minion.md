# Domain Plan Contribution: software-docs-minion

## Recommendations

### 1. Decision 21 -- Annotate, Do Not Rewrite

Decision 21 is a historical record. It documents a choice made on 2026-02-10 that was valid at the time. Decision 26 already states "Supersedes the scratch file portions of Decision 21" in its Rationale field, which is the correct ADR pattern. The right treatment for Decision 21 is:

- **Add a Status annotation**: Change `Status` from `Implemented` to `Superseded (scratch file portions)` with a forward-reference: "Scratch file path and lifecycle portions superseded by [Decision 26](#decision-26-decouple-toolkit-from-self-referential-path-assumptions). The compaction checkpoint portions remain current."
- **Do NOT rewrite the body text**. The original text (`nefario/scratch/{slug}/`, `.gitignore` entries, etc.) is what was actually decided. Rewriting it erases the historical context that Decision 26 was created to address. ADRs are immutable records -- new context means new ADR, not revision of old ones.
- **Do NOT mark the entire decision as superseded**, because the compaction checkpoint portions (the second prong) are still fully current and unchanged by Decision 26.

This follows the ADR management pattern: annotate with status and cross-reference, never delete or rewrite accepted decisions.

### 2. TEMPLATE.md -- Keep as Reference, Mark Relationship

The TEMPLATE.md file at `docs/history/nefario-reports/TEMPLATE.md` should be **kept** but its relationship to SKILL.md should be clarified. Here is the analysis:

- SKILL.md (line 1105-1106) says: "The report format is defined inline below in the Wrap-up Sequence section. No external template file dependency is required." This means SKILL.md is the operational source of truth at runtime.
- `docs/orchestration.md` (line 474) says: "The full template is maintained at `docs/history/nefario-reports/TEMPLATE.md`. Do not reproduce it here." This is now stale -- the template is reproduced in SKILL.md, and orchestration.md should point to the template as reference documentation, not as the operational dependency.
- `CLAUDE.md` (line 61) says: "generate an execution report following the template at `docs/history/nefario-reports/TEMPLATE.md`." This is stale -- reports are generated following the inline format in SKILL.md at runtime.

Recommendation:
- **Keep TEMPLATE.md** as contributor-facing reference documentation. It provides a well-structured, readable template that is easier to review than parsing it out of SKILL.md's operational instructions. It is also referenced by existing reports in `docs/history/`.
- **Add a note at the top of TEMPLATE.md** clarifying that the operational source of truth is SKILL.md, and this file serves as reference documentation for contributors reviewing report format.
- **Update orchestration.md line 474** to say the template is maintained as reference at TEMPLATE.md and the operational format is defined in SKILL.md.
- **Update CLAUDE.md line 61** to remove the instruction to follow TEMPLATE.md, since SKILL.md handles this at runtime. Replace with a reference to SKILL.md as the report format authority, or simplify to say "the report index is regenerated automatically by CI on push to main" (keeping only the CI fact, since the format instruction is redundant with SKILL.md).

### 3. Decision 21 -- Specific Stale Content

Two specific fields in Decision 21 contain hardcoded `nefario/scratch/` paths that are factually incorrect under the current model:

- **Choice field**: "`nefario/scratch/{slug}/`" -- this path no longer exists. Under Decision 26, scratch uses `$TMPDIR` via `mktemp -d`.
- **Consequences field**: "Session-specific scratch directories under `nefario/scratch/` (gitignored)" -- scratch directories are now in `$TMPDIR`, no gitignore needed.

Per my recommendation in section 1, these should NOT be rewritten. The annotation on the Status field provides the cross-reference. A reader encountering Decision 21 will see the superseded note and follow it to Decision 26 for current behavior. This is the standard ADR pattern.

### 4. Cross-Reference Audit Results

I examined all in-scope documentation files for stale cross-references. Here are the findings:

**docs/decisions.md:**
- Decision 21 Status needs superseded annotation (covered above)
- Decision 26 Rationale correctly references `nefario/scratch/` and `docs/history/nefario-reports/TEMPLATE.md` as the OLD paths that were decoupled. These are correct historical references, not stale -- they describe what was changed FROM.

**docs/orchestration.md:**
- Line 474: "The full template is maintained at `docs/history/nefario-reports/TEMPLATE.md`. Do not reproduce it here." -- **STALE**. Should be updated to clarify that SKILL.md is the operational authority and TEMPLATE.md is reference.
- All other scratch file references in this file use `$SCRATCH_DIR` or generic terms (e.g., "scratch files", "scratch directory path") -- these are correct and decoupled.

**docs/compaction-strategy.md:**
- All scratch file references use `$TMPDIR`, `mktemp -d`, and `$SCRATCH_DIR/{slug}/` -- **correct and current**. This file was already updated during PR #20.
- Line 64: "Scratch files live outside the project tree (`$TMPDIR`), so no gitignore rules are needed." -- **correct**.

**docs/deployment.md:**
- No stale scratch references. No TEMPLATE.md references. **Clean**.

**docs/architecture.md:**
- Line 137: Links to "[Context Management](compaction-strategy.md)" with description "Scratch file pattern for phase outputs..." -- **correct**, generic language.
- No stale path references. **Clean**.

**CLAUDE.md:**
- Line 61: "generate an execution report following the template at `docs/history/nefario-reports/TEMPLATE.md`." -- **STALE**. Reports are generated by SKILL.md at runtime; this instruction is misleading for sessions that load CLAUDE.md but are not running the nefario skill.

**README.md:**
- No stale scratch or template references. **Clean**.

**install.sh:**
- No comments referencing scratch paths or TEMPLATE.md. **Clean**.

**docs/using-nefario.md:**
- No stale references to scratch paths, TEMPLATE.md, or hardcoded locations. **Clean**.

**skills/nefario/SKILL.md:**
- All scratch references use `$SCRATCH_DIR`, `mktemp -d`, `$TMPDIR` -- **correct**.
- Lines 1105-1106: "The report format is defined inline below... No external template file dependency is required." -- **correct and consistent with the decoupled model**.
- Report directory detection uses cwd-relative logic -- **correct**.

### 5. Summary of All Stale Items Found

| File | Line(s) | Issue | Fix |
|------|---------|-------|-----|
| `docs/decisions.md` | Decision 21 Status | Status says "Implemented" but scratch portions are superseded | Change to `Superseded (scratch file portions)` with forward-ref to Decision 26 |
| `docs/orchestration.md` | 474 | Says template is "maintained at" TEMPLATE.md as if it is the operational authority | Clarify SKILL.md is operational authority, TEMPLATE.md is contributor reference |
| `CLAUDE.md` | 61 | Instructs following TEMPLATE.md for report generation | Remove or update; SKILL.md handles this at runtime |


## Proposed Tasks

### Task 1: Annotate Decision 21 Status in docs/decisions.md

**What to do**: Change the Status field of Decision 21 from `Implemented` to `Superseded (scratch file portions)`. Add a note: "Scratch file path and lifecycle portions superseded by [Decision 26](#decision-26-decouple-toolkit-from-self-referential-path-assumptions). Compaction checkpoint design remains current."

**Deliverables**: Updated `docs/decisions.md` with annotated Decision 21

**Dependencies**: None

### Task 2: Update orchestration.md TEMPLATE.md reference

**What to do**: Update line 474 of `docs/orchestration.md` from "The full template is maintained at `docs/history/nefario-reports/TEMPLATE.md`. Do not reproduce it here." to something like: "The report format reference is at `docs/history/nefario-reports/TEMPLATE.md`. The operational format used at runtime is defined in the [nefario skill](../skills/nefario/SKILL.md)."

**Deliverables**: Updated `docs/orchestration.md`

**Dependencies**: None

### Task 3: Update CLAUDE.md report generation instruction

**What to do**: Update the "Orchestration Reports" section in CLAUDE.md (line 61) to remove the instruction to follow TEMPLATE.md. The current text says: "generate an execution report following the template at `docs/history/nefario-reports/TEMPLATE.md`." This should say something like: "generate an execution report following the format defined in the nefario skill (SKILL.md)." Or simplify to just note that reports are generated during `/nefario` orchestration and the index is regenerated by CI.

**Deliverables**: Updated `CLAUDE.md`

**Dependencies**: None

### Task 4: Add relationship note to TEMPLATE.md

**What to do**: Add a brief note at the top of `docs/history/nefario-reports/TEMPLATE.md` (after the H1 heading, before any content) clarifying: "This file is contributor-facing reference documentation for the report format. The operational source of truth for report generation at runtime is defined inline in `skills/nefario/SKILL.md`. Keep both in sync when the format changes."

**Deliverables**: Updated `docs/history/nefario-reports/TEMPLATE.md`

**Dependencies**: None


## Risks and Concerns

1. **Dual-source drift between TEMPLATE.md and SKILL.md**: If both files define the report format and neither is marked as derivative, they will drift. The proposed note in Task 4 mitigates this by establishing SKILL.md as the authority, but there is no automated sync mechanism. Recommendation: accept this as a documentation maintenance responsibility; automated sync is YAGNI given the current team size and change frequency.

2. **Decision 21 partial-supersession is unusual**: Most ADR patterns are fully superseded or fully current. Partially superseding a decision (scratch portions superseded, compaction portions current) is less common. Risk: future readers may be confused by the split. Mitigation: the status annotation explicitly names which portions are superseded and which remain, and the forward-reference to Decision 26 provides the full context.

3. **CLAUDE.md changes affect all sessions**: CLAUDE.md is loaded in every Claude Code session in this project. The TEMPLATE.md reference there is misleading but also mostly harmless (the nefario skill overrides it at runtime). The risk of updating it is low; the risk of NOT updating it is that a session without the nefario skill loaded might try to follow TEMPLATE.md directly and produce an inconsistent report.

4. **Existing nefario reports in docs/history/ reference old paths**: Some historical execution reports (e.g., `2026-02-10-003-prevent-context-overflow.md`) reference `nefario/scratch/` and the old `.gitignore` entries. These are historical records and should NOT be updated -- they accurately describe what happened during those orchestrations. They are out of scope per the task definition, but this should be noted explicitly to prevent well-intentioned cleanup from altering historical records.


## Additional Agents Needed

None. The current team is sufficient. The changes are purely documentation consistency -- no code, no security surface, no UX changes, no deployment changes. A lucy review during Phase 3.5 will catch any convention inconsistencies, and margo will flag if any of the proposed changes are over-engineered.
