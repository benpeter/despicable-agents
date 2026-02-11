## Domain Plan Contribution: lucy

### Recommendations

I audited all in-scope files for internal consistency regarding the four dimensions in the planning question. Below is a finding-by-finding analysis organized by category, followed by proposed tasks.

#### Category 1: Scratch File Location

The decoupled model (Decision 26, SKILL.md) uses `mktemp -d` in `$TMPDIR`. SKILL.md and `docs/compaction-strategy.md` are fully updated. However:

**Finding 1 [CONVENTION]**: `docs/decisions.md` Decision 21 (lines 274, 277) still describes the pre-decoupling scratch model as current:
- Line 274: `"Write full phase outputs to scratch files (nefario/scratch/{slug}/)"` -- presents the old path as the current design.
- Line 277: `"Session-specific scratch directories under nefario/scratch/ (gitignored)"` -- states consequences that are no longer true (files are in `$TMPDIR`, not gitignored).

Decision 26 (line 345) explicitly says it "supersedes the scratch file portions of Decision 21," but Decision 21 itself has no annotation indicating it was superseded. A reader encountering Decision 21 first (which is likely, given numerical order) would believe `nefario/scratch/` is the current convention.

**Finding 2 [CONVENTION]**: `docs/compaction-strategy.md` Section 2 "Directory Structure" (line 33) uses `$TMPDIR/nefario-{slug}-XXXXXX/` as the path pattern, while SKILL.md (line 83-84) uses `${TMPDIR:-/tmp}/nefario-scratch-XXXXXX`. The naming patterns differ:
- compaction-strategy.md: `nefario-{slug}-XXXXXX` (slug in mktemp template, "nefario-" prefix)
- SKILL.md: `nefario-scratch-XXXXXX` (no slug in mktemp template, slug as subdirectory, "nefario-scratch-" prefix)

SKILL.md is the operational specification; compaction-strategy.md is the design rationale. SKILL.md creates `$SCRATCH_DIR/${slug}/` as a subdirectory, while compaction-strategy.md shows the slug baked into the mktemp template itself. These are structurally different approaches. SKILL.md is authoritative; compaction-strategy.md must match.

**Finding 3 [CONVENTION]**: `docs/compaction-strategy.md` "Lifecycle" section (line 63) says `"Cleanup: Scratch directories are cleaned up at wrap-up. OS-level $TMPDIR cleanup provides a safety net for interrupted sessions."` This matches SKILL.md. However, line 64 says `"Git: Scratch files live outside the project tree ($TMPDIR), so no gitignore rules are needed."` This is correct post-decoupling. No issue here -- just confirming.

#### Category 2: Report Directory Detection

SKILL.md (lines 100-103) defines the detection order:
1. `docs/nefario-reports/` relative to cwd
2. `docs/history/nefario-reports/` relative to cwd
3. Default: create `docs/history/nefario-reports/` relative to cwd

`docs/orchestration.md` (lines 453-455) correctly mirrors this with `<report-dir>` abstraction and the same three-step detection. No inconsistency.

**Finding 4 [CONVENTION]**: `docs/history/nefario-reports/TEMPLATE.md` (line 7) says `"Reports are written to docs/history/nefario-reports/<YYYY-MM-DD>-<HHMMSS>-<slug>.md"` -- this hardcodes the path instead of using the cwd-relative detection model from SKILL.md. The TEMPLATE.md file lives inside the despicable-agents project, so it describes the specific path for THIS project, which is defensible. However, TEMPLATE.md line 13 says `"Create docs/history/nefario-reports/ directory if it doesn't exist"` which is the old imperative form rather than the detection-first approach.

This is a borderline finding. TEMPLATE.md is a reference document within the despicable-agents project (not a portable artifact), so hardcoded paths to the project's own report directory are acceptable. However, the TEMPLATE.md is referenced by CLAUDE.md (line 61) as "the template" and by orchestration.md (line 474) as the maintained template. If a reader follows those references expecting a portable template, the hardcoded paths may confuse.

**Recommendation**: Accept TEMPLATE.md's hardcoded paths as project-specific documentation. The operational behavior is governed by SKILL.md, which is correctly decoupled. TEMPLATE.md describes the format, not the resolution logic.

#### Category 3: TEMPLATE.md's Role

**Finding 5 [CONSISTENCY]**: There is a semantic contradiction between SKILL.md and the documents that reference TEMPLATE.md:

- SKILL.md (line 1105-1106): `"The report format is defined inline below in the Wrap-up Sequence section. No external template file dependency is required."` -- SKILL.md explicitly disclaims dependency on TEMPLATE.md.
- CLAUDE.md (line 61): `"generate an execution report following the template at docs/history/nefario-reports/TEMPLATE.md"` -- CLAUDE.md directs agents to follow TEMPLATE.md.
- `docs/orchestration.md` (line 474): `"The full template is maintained at docs/history/nefario-reports/TEMPLATE.md. Do not reproduce it here."` -- orchestration.md defers to TEMPLATE.md as the canonical format definition.

The contradiction: SKILL.md says the format is self-contained (no external dependency). CLAUDE.md and orchestration.md say the format is defined by TEMPLATE.md. In practice, SKILL.md governs runtime behavior (it is loaded when `/nefario` runs), so its inline format definition is what actually gets used. TEMPLATE.md is a reference artifact for humans reading the docs.

This is the most significant consistency issue. Post-decoupling, SKILL.md is explicitly self-contained. The external references to TEMPLATE.md create confusion about which is authoritative. They need to agree on roles:
- Option A: TEMPLATE.md is the human-readable reference; SKILL.md is the operational implementation. Both define the same format. Cross-references should say "for the format reference, see TEMPLATE.md" (not "follow the template at").
- Option B: TEMPLATE.md is removed entirely; SKILL.md is the single source. CLAUDE.md and orchestration.md reference SKILL.md directly.

Option A is minimal-change and preserves TEMPLATE.md's value as a readable reference without requiring agents to go find it at runtime. Option B is cleaner but removes a useful human-readable document.

**Finding 6 [CONVENTION]**: `docs/decisions.md` Decision 14 (line 177) includes: `"(2) Separate template file (docs/history/nefario-reports/.template.md): rejected because it creates a coordination point that must stay in sync with SKILL.md; template is small enough to embed directly."` This is the original Decision 14 reasoning -- it explicitly rejected a separate template file. Yet TEMPLATE.md now exists (created later). Decision 14 was not updated to reflect this. The text says "rejected" but the alternative was subsequently implemented.

This is historical context that should be annotated, not rewritten. Decision 14 made the right call at the time; the template was later created for human reference (not as a runtime dependency). An annotation clarifying the evolution would resolve the confusion.

#### Category 4: Decoupled Path Terminology

**Finding 7 [CONVENTION]**: `docs/commit-workflow.md` (lines 13, 18-19, 52, 96) hardcodes `main` as the default branch:
- Line 13: `"create a feature branch from main"`
- Line 18: `"Pull latest main"`
- Line 19: `"Create the feature branch from the now-up-to-date main"`
- Line 52: `"Return to main: git checkout main && git pull --rebase"`
- Line 96 (mermaid): `"git checkout main && git pull --rebase"`

SKILL.md (lines 119-123, 1023-1025) uses dynamic default branch detection:
`git symbolic-ref refs/remotes/origin/HEAD 2>/dev/null | sed 's@^refs/remotes/origin/@@'` with fallback to `main`.

Decision 26 explicitly decoupled the `main` hardcoding. `commit-workflow.md` was not updated. This is a clear inconsistency: the design document describes the pre-decoupling behavior while the operational specification (SKILL.md) implements the decoupled behavior.

**Finding 8 [CONVENTION]**: `docs/commit-workflow.md` is listed as in-scope for this audit. The branching section describes `main` in 5+ locations. This file was designed before Decision 26 and not touched by the decoupling PR. It should use "default branch" terminology with a note about dynamic detection, matching SKILL.md.

**Finding 9 [NO ISSUE]**: `docs/orchestration.md` Section 5 "Commit Points in Execution Flow" (line 507-512) uses generic terminology: `"feature branch is created from HEAD"`, `"non-main branch"`, `"the default branch"`. This is already consistent with the decoupled model. The only `main` reference is in `nefario/<slug>` as a branch naming example, which is correct (the branch name itself is not the default branch).

**Finding 10 [NO ISSUE]**: `CLAUDE.md`, `README.md`, `docs/architecture.md`, `docs/deployment.md`, `docs/build-pipeline.md`, `docs/agent-anatomy.md`, `docs/using-nefario.md` -- no hardcoded `nefario/scratch/` paths, no `main` branch assumptions, no stale TEMPLATE.md references beyond those already flagged. These files are clean.

**Finding 11 [CONVENTION]**: `install.sh` -- no inline comments reference scratch paths, report paths, or branch names. The script handles agent and skill symlinks only. Clean.

#### Summary of Findings Requiring Action

| # | Category | Severity | File | Issue |
|---|----------|----------|------|-------|
| 1 | CONVENTION | Medium | `docs/decisions.md` D21 | Pre-decoupling scratch path described as current; no supersession annotation |
| 2 | CONVENTION | Low | `docs/compaction-strategy.md` | Scratch dir naming pattern diverges from SKILL.md |
| 4 | CONVENTION | Info | `docs/history/nefario-reports/TEMPLATE.md` | Hardcoded report path (acceptable for project-specific doc) |
| 5 | CONSISTENCY | High | CLAUDE.md + orchestration.md vs SKILL.md | Contradictory statements about TEMPLATE.md authority |
| 6 | CONVENTION | Low | `docs/decisions.md` D14 | "Rejected" separate template, but it now exists |
| 7 | CONVENTION | Medium | `docs/commit-workflow.md` | Hardcoded `main` branch (5+ locations) not updated for dynamic detection |

### Proposed Tasks

#### Task 1: Annotate Decision 21 with supersession note (Finding 1)

**What**: Add a `Note` row to Decision 21's table: `"Scratch file path convention (`nefario/scratch/`) superseded by Decision 26 (2026-02-10). Scratch files now use mktemp -d in $TMPDIR. See Decision 26 for current model."` Do NOT rewrite the Decision 21 body -- it is accurate historical context.

**Deliverables**: Updated `docs/decisions.md`, Decision 21 table only.

**Dependencies**: None.

#### Task 2: Align compaction-strategy.md scratch path pattern with SKILL.md (Finding 2)

**What**: Update `docs/compaction-strategy.md` Section 2 "Directory Structure" (lines 30-40) to match SKILL.md's actual pattern:
- Change `$TMPDIR/nefario-{slug}-XXXXXX/` to show the two-step creation: `mktemp -d "${TMPDIR:-/tmp}/nefario-scratch-XXXXXX"` then `mkdir "$SCRATCH_DIR/${slug}"`.
- Update the directory tree example to show `$SCRATCH_DIR/{slug}/` structure.
- Add `${TMPDIR:-/tmp}` fallback notation to match SKILL.md.

**Deliverables**: Updated `docs/compaction-strategy.md`, Section 2 only.

**Dependencies**: None.

#### Task 3: Reconcile TEMPLATE.md role across CLAUDE.md, orchestration.md, and SKILL.md (Finding 5)

**What**: Adjust the cross-references to clarify roles without removing TEMPLATE.md:
- `CLAUDE.md` line 61: Change `"following the template at docs/history/nefario-reports/TEMPLATE.md"` to `"following the format defined in the nefario SKILL.md (see docs/history/nefario-reports/TEMPLATE.md for the human-readable format reference)"`.
- `docs/orchestration.md` line 474: Change `"The full template is maintained at docs/history/nefario-reports/TEMPLATE.md. Do not reproduce it here."` to `"The report format is defined in the nefario SKILL.md, which is the operational authority. A human-readable format reference is maintained at docs/history/nefario-reports/TEMPLATE.md."`.

This preserves TEMPLATE.md as a reference document while making SKILL.md the acknowledged authority.

**Deliverables**: Updated `CLAUDE.md` (1 line), updated `docs/orchestration.md` (1-2 lines).

**Dependencies**: None.

#### Task 4: Annotate Decision 14 regarding TEMPLATE.md evolution (Finding 6)

**What**: Add a `Note` row to Decision 14's table: `"The rejected 'separate template file' alternative was later implemented as docs/history/nefario-reports/TEMPLATE.md -- a human-readable format reference, not a runtime dependency. SKILL.md remains the operational authority per Decision 26. The original rejection rationale (coordination cost) is mitigated by SKILL.md being the single source of truth for runtime behavior."` This is historical annotation, not a rewrite.

**Deliverables**: Updated `docs/decisions.md`, Decision 14 table only.

**Dependencies**: Task 3 (establishes the role clarification that this note references).

#### Task 5: Update commit-workflow.md for dynamic default branch (Finding 7)

**What**: Replace hardcoded `main` references with "default branch" terminology in `docs/commit-workflow.md`:
- Line 13: `"create a feature branch from main"` -> `"create a feature branch from the default branch"`
- Lines 18-19: Update pre-flight description to reference "default branch" with a note that detection uses `git symbolic-ref refs/remotes/origin/HEAD` (falling back to `main`).
- Line 32-33: `"non-main branch"` -> `"non-default branch"`; `"on main or master"` -> `"on the default branch"`
- Line 52: `"Return to main: git checkout main && git pull --rebase"` -> `"Return to default branch: git checkout <default-branch> && git pull --rebase"` with a note about dynamic detection.
- Line 96 (mermaid diagram): Update the `git checkout main` line similarly.
- Line 358-359: Update the `main`/`master` references in safety rails to use "default branch" with note.

**Deliverables**: Updated `docs/commit-workflow.md` (6-8 line edits across the file).

**Dependencies**: None.

### Risks and Concerns

1. **Over-editing historical decisions**: Decisions 14 and 21 are historical records. The proposed changes are annotations (Note rows), not rewrites. Reviewers should verify the annotations do not alter the original decision semantics.

2. **TEMPLATE.md role ambiguity persists**: Even after Task 3, TEMPLATE.md and SKILL.md define the same format in two places. If they drift, the problem recurs. The mitigation is that SKILL.md is explicitly marked as authoritative. A stronger mitigation would be adding a note at the top of TEMPLATE.md saying "This is a human-readable reference. The operational format is defined in skills/nefario/SKILL.md." This is a small addition that could be folded into Task 3.

3. **commit-workflow.md mermaid diagram**: Changing the mermaid diagram (Task 5, line 96) requires care to keep it syntactically valid. The `git checkout <default-branch>` notation inside a sequence diagram box needs to be parseable by mermaid.

4. **Scope boundary**: `docs/commit-workflow-security.md` also has a `main/master` reference (line 225). This file was not listed in the in-scope section of the planning question. If it is in scope, it should be included in Task 5. If not, flag it as an out-of-scope finding for a future pass.

### Additional Agents Needed

None. The five proposed tasks are documentation edits requiring consistency checking (lucy's domain) and text editing (software-docs-minion or the executing agent). No domain expertise beyond what is already in the planning team is needed.
