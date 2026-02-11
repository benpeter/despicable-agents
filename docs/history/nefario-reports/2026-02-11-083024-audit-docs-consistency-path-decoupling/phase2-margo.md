# Domain Plan Contribution: margo

## Recommendations

### Verdict: ADVISE

The scope is well-bounded. The actual change set is smaller than it might appear, and the primary over-engineering risk is turning a 2-file fix into a 10-file documentation rewrite. I identify exactly 2 files that need changes, and flag 1 file that should NOT be changed despite containing old paths.

### Assessment: What Actually Needs Fixing

I audited every in-scope file. Here is the complete inventory:

**Files with actual inconsistencies (MUST fix):**

1. **`/Users/ben/github/benpeter/despicable-agents/docs/compaction-strategy.md` line 33** -- Shows `$TMPDIR/nefario-{slug}-XXXXXX/` as the directory structure. SKILL.md (the source of truth for operational behavior) uses `nefario-scratch-XXXXXX` as the mktemp template, then creates `{slug}` as a subdirectory. The naming pattern and structure are wrong in compaction-strategy.md. This is the only genuine inconsistency between a current doc and the actual implementation.

2. **`/Users/ben/github/benpeter/despicable-agents/docs/decisions.md` Decision 21 (lines 274, 277)** -- The Choice and Consequences fields describe the OLD model (`nefario/scratch/{slug}/`, "gitignored"). Decision 26 explicitly says it "supersedes the scratch file portions of Decision 21" -- but Decision 21 itself has no annotation indicating this. A reader encountering Decision 21 in isolation would get the wrong picture.

**Files that are CLEAN (no changes needed):**

- `CLAUDE.md` -- no scratch references
- `README.md` -- generic reference to "scratch files" is accurate
- `docs/orchestration.md` -- uses generic "scratch files" language, no hardcoded paths; TEMPLATE.md reference at line 474 is valid (file exists)
- `docs/architecture.md` -- cross-references to compaction-strategy.md are correct
- `docs/deployment.md` -- no scratch references
- `skills/nefario/SKILL.md` -- already fully decoupled, uses `$SCRATCH_DIR` throughout; this IS the source of truth
- `install.sh` -- no scratch references

### Over-Engineering Risks

**Risk 1: Rewriting Decision 21 (HIGH risk of scope creep).** Decision 21 is a historical record. Rewriting its Choice/Consequences fields to reflect the current model destroys the historical accuracy of the decision log. Decision 26 already captures what changed and why. The correct fix is a single annotation line, not a rewrite.

**Risk 2: "While we're at it" documentation expansion.** The compaction-strategy.md fix is a 1-line path correction. Do not use this as an opportunity to rewrite surrounding paragraphs, add new explanatory sections, or restructure the document. The document is otherwise consistent with the decoupled model.

**Risk 3: Touching execution reports in `docs/history/`.** Many historical reports contain `nefario/scratch/` references. These are historical artifacts documenting what actually happened during those orchestrations. They are explicitly out of scope and must not be modified. The grep results show 56 files containing the old path -- this is correct and expected for historical records.

**Risk 4: The `nefario/scratch/` directory itself.** It still exists on disk with ~90 legacy files. Cleaning it up is tempting but is NOT a documentation consistency task. It is a separate cleanup task (and may have value as historical reference for the despicable-agents project itself). Do not bundle it into this PR.

## Proposed Tasks

### Task 1: Fix compaction-strategy.md directory structure diagram

**What to do:** Update line 33 of `docs/compaction-strategy.md` to match SKILL.md's actual directory creation pattern.

**Current (wrong):**
```
$TMPDIR/nefario-{slug}-XXXXXX/
  phase1-metaplan.md
  phase2-{agent-name}.md
  ...
```

**Correct (per SKILL.md):**
```
$SCRATCH_DIR/
  {slug}/
    phase1-metaplan.md
    phase2-{agent-name}.md
    ...
```

Where `$SCRATCH_DIR` is created via `mktemp -d "${TMPDIR:-/tmp}/nefario-scratch-XXXXXX"` and `{slug}` is a subdirectory. The surrounding text at lines 30-31 already mentions `mktemp -d` correctly; only the example directory tree at line 33 is wrong.

**Deliverable:** Updated `docs/compaction-strategy.md` (1 section changed, ~5 lines).
**Dependencies:** None.

### Task 2: Annotate Decision 21 as partially superseded

**What to do:** Add a `**Note**` row to Decision 21's table (same pattern used in Decision 14 which has: "Naming convention superseded by Decision 25"). The note should state that scratch file paths were superseded by Decision 26.

**Do NOT rewrite** the Choice or Consequences fields. They are historical records of what was decided at the time.

**Deliverable:** Updated `docs/decisions.md` (1 row added to Decision 21 table).
**Dependencies:** None.

### What NOT to do (explicit exclusions)

- Do not modify any files in `docs/history/nefario-reports/` -- historical records
- Do not rewrite Decision 21's Choice/Consequences fields
- Do not clean up or remove the `nefario/scratch/` directory
- Do not add new explanatory sections to any document
- Do not modify SKILL.md (it is already correct)
- Do not modify CLAUDE.md, README.md, orchestration.md, architecture.md, or deployment.md (they are already consistent)

## Risks and Concerns

1. **Task inflation.** The success criteria list 5 bullet points. Only 2 require actual file changes. The other 3 are verification-only (confirm cross-references resolve, confirm terminology is uniform, confirm CLAUDE.md aligns). These verifications should be done during the 2 file edits, not as separate tasks. Total task count for this audit should be 2, not 5+.

2. **Gold plating the annotation.** The Decision 21 annotation should be one line: "Scratch file path convention (`nefario/scratch/`) superseded by Decision 26 (2026-02-10)." Do not add a paragraph explaining the new model -- that is Decision 26's job and it already does it well.

3. **Terminology policing.** The success criteria mention "no mix of old and new conventions." In practice, the old convention only appears in Decision 21 (a historical record) and historical reports (out of scope). Every active document already uses the new convention. There is no mix to fix beyond the 2 items above.

## Additional Agents Needed

None. This is a 2-file, ~10-line change set. It does not need specialist planning from software-docs-minion, lucy, or anyone else. The complexity budget for this task is approximately zero, and adding reviewers would cost more than the work itself.
