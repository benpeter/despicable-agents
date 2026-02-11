# Phase 3: Synthesis -- Documentation Consistency Audit (Path Decoupling)

## Delegation Plan

**Team name**: audit-docs-consistency
**Description**: Fix documentation inconsistencies remaining after PR #20 (path decoupling). Four tasks across three files, plus one clarification edit to CLAUDE.md and orchestration.md.

---

### Task 1: Fix compaction-strategy.md directory structure diagram

- **Agent**: software-docs-minion
- **Model**: sonnet
- **Mode**: bypassPermissions
- **Blocked by**: none
- **Approval gate**: no
- **Prompt**: |
    Fix the directory structure diagram in `docs/compaction-strategy.md` (Section 2, "Directory Structure", around line 33) to match the actual implementation in SKILL.md.

    **Current (wrong):**
    ```
    $TMPDIR/nefario-{slug}-XXXXXX/
      phase1-metaplan.md
      phase2-{agent-name}.md        # one per specialist
      phase3-synthesis.md
      phase3.5-{reviewer-name}.md   # one per reviewer (BLOCK/ADVISE only)
    ```

    **Correct (per SKILL.md lines 82-96):**
    The implementation uses a two-step creation:
    1. `mktemp -d "${TMPDIR:-/tmp}/nefario-scratch-XXXXXX"` -- creates the base scratch dir
    2. `mkdir "$SCRATCH_DIR/${slug}"` -- creates a slug subdirectory inside it

    So the directory tree should show:
    ```
    $SCRATCH_DIR/                               # mktemp -d "${TMPDIR:-/tmp}/nefario-scratch-XXXXXX"
      {slug}/
        phase1-metaplan.md
        phase2-{agent-name}.md                  # one per specialist
        phase3-synthesis.md
        phase3.5-{reviewer-name}.md             # one per reviewer (BLOCK/ADVISE only)
    ```

    Key differences to fix:
    - Prefix is `nefario-scratch-` not `nefario-{slug}-` (slug is a subdirectory, not part of the mktemp template)
    - Use `$SCRATCH_DIR` as the top-level label (this is the variable name used everywhere in SKILL.md)
    - Show `{slug}/` as a subdirectory
    - Include `${TMPDIR:-/tmp}` fallback notation (matching SKILL.md line 83)

    Also update line 30 if it shows the old `mktemp` command. The correct command is:
    ```sh
    mktemp -d "${TMPDIR:-/tmp}/nefario-scratch-XXXXXX"
    ```

    The surrounding text at lines 40-41 (about slug derivation) is still correct -- just note that the slug is a subdirectory, not part of the mktemp template.

    **Do NOT change**: Lines 63-64 (lifecycle section) are already correct. Do not modify any other section.

    **File**: `/Users/ben/github/benpeter/despicable-agents/docs/compaction-strategy.md`
    **Branch**: nefario/decouple-self-referential-assumptions (already checked out)

- **Deliverables**: Updated `docs/compaction-strategy.md` with corrected directory structure diagram
- **Success criteria**: The directory structure example matches SKILL.md lines 82-96 exactly

---

### Task 2: Annotate Decision 21 as partially superseded

- **Agent**: software-docs-minion
- **Model**: sonnet
- **Mode**: bypassPermissions
- **Blocked by**: none
- **Approval gate**: no
- **Prompt**: |
    Add a supersession annotation to Decision 21 in `docs/decisions.md`.

    Decision 21 ("Scratch Files and Compaction Checkpoints for Context Overflow Prevention") at line 268 describes the pre-decoupling scratch file model. Its Choice field references `nefario/scratch/{slug}/` and its Consequences field references `nefario/scratch/` (gitignored). These are now incorrect -- Decision 26 moved scratch files to `$TMPDIR` via `mktemp -d`.

    Decision 26 (line 337) already says "Supersedes the scratch file portions of Decision 21" in its Rationale, but Decision 21 itself has no annotation. A reader encountering Decision 21 first (numerical order) would think the old convention is current.

    **What to do**: Add a `**Note**` row to Decision 21's table, following the exact same pattern used in Decision 14 (line 180):

    ```
    | **Note** | Scratch file path convention (`nefario/scratch/`) superseded by Decision 26 (2026-02-10). Compaction checkpoint design remains current. |
    ```

    Place it as the last row of the table, after `**Consequences**` (line 277).

    **Do NOT**:
    - Rewrite the Choice, Alternatives rejected, Rationale, or Consequences fields. These are historical records of what was decided at the time. ADRs are immutable; new context means new ADR, not revision of old ones.
    - Change the Status from "Implemented" to anything else. The decision WAS implemented; portions were later superseded.
    - Add explanatory text about the new model. That is Decision 26's job.

    **File**: `/Users/ben/github/benpeter/despicable-agents/docs/decisions.md`
    **Branch**: nefario/decouple-self-referential-assumptions (already checked out)

- **Deliverables**: Updated `docs/decisions.md` with Note row on Decision 21
- **Success criteria**: Decision 21 has a Note row cross-referencing Decision 26, matching Decision 14's annotation pattern

---

### Task 3: Reconcile TEMPLATE.md role across CLAUDE.md and orchestration.md

- **Agent**: software-docs-minion
- **Model**: sonnet
- **Mode**: bypassPermissions
- **Blocked by**: none
- **Approval gate**: no
- **Prompt**: |
    Fix a consistency contradiction about the TEMPLATE.md file's role. Three documents make incompatible claims:

    - **SKILL.md** (lines 1105-1106): "The report format is defined inline below in the Wrap-up Sequence section. No external template file dependency is required." -- SKILL.md explicitly disclaims dependency on TEMPLATE.md.
    - **CLAUDE.md** (line 61): "generate an execution report following the template at `docs/history/nefario-reports/TEMPLATE.md`." -- Directs agents to follow TEMPLATE.md as if it's the authority.
    - **orchestration.md** (line 474): "The full template is maintained at `docs/history/nefario-reports/TEMPLATE.md`. Do not reproduce it here." -- Defers to TEMPLATE.md as the canonical format definition.

    SKILL.md is the operational authority (it controls runtime behavior). TEMPLATE.md is a useful human-readable reference but is NOT a runtime dependency. CLAUDE.md and orchestration.md must be updated to reflect this.

    **Edit 1 -- CLAUDE.md line 61:**

    Change:
    ```
    generate an execution report following the template at `docs/history/nefario-reports/TEMPLATE.md`.
    ```

    To:
    ```
    generate an execution report following the format defined in the nefario skill (`skills/nefario/SKILL.md`).
    ```

    This removes the misleading TEMPLATE.md dependency. The SKILL.md reference is more accurate: sessions running `/nefario` already have SKILL.md loaded, and sessions NOT running `/nefario` should not be generating reports anyway.

    **Edit 2 -- orchestration.md line 474:**

    Change:
    ```
    The full template is maintained at `docs/history/nefario-reports/TEMPLATE.md`. Do not reproduce it here.
    ```

    To:
    ```
    The operational report format is defined in `skills/nefario/SKILL.md`. A human-readable format reference is maintained at `docs/history/nefario-reports/TEMPLATE.md`.
    ```

    This preserves the TEMPLATE.md cross-reference (it's genuinely useful for contributors reading the docs) while making the authority relationship clear.

    **Do NOT**:
    - Modify SKILL.md (it is already correct)
    - Modify TEMPLATE.md itself (it can stay as-is; its role is clear from the referencing documents)
    - Change anything else in CLAUDE.md or orchestration.md

    **Files**:
    - `/Users/ben/github/benpeter/despicable-agents/CLAUDE.md` (line 61)
    - `/Users/ben/github/benpeter/despicable-agents/docs/orchestration.md` (line 474)
    **Branch**: nefario/decouple-self-referential-assumptions (already checked out)

- **Deliverables**: Updated CLAUDE.md (1 line) and orchestration.md (1 line)
- **Success criteria**: Both files acknowledge SKILL.md as the operational authority for report format, with TEMPLATE.md as reference only

---

### Task 4: Simplify README.md scratch file description

- **Agent**: user-docs-minion
- **Model**: sonnet
- **Mode**: bypassPermissions
- **Blocked by**: none
- **Approval gate**: no
- **Prompt**: |
    Update the scratch file description in README.md line 124 (Current Limitations section) to remove an internal implementation detail that is misleading after the path decoupling.

    **Current text (line 124):**
    ```
    - **Context window pressure.** Complex orchestrations with many specialists can approach context limits. The project uses scratch files (preserved as companion directories in PRs) and compaction checkpoints, but very large plans may require manual intervention.
    ```

    **New text:**
    ```
    - **Context window pressure.** Complex orchestrations with many specialists can approach context limits. The project uses temporary scratch files and compaction checkpoints to manage context, but very large plans may require manual intervention.
    ```

    The change removes "(preserved as companion directories in PRs)" which describes an internal mechanism. The companion directory pattern still exists but is an implementation detail documented in `docs/orchestration.md`, not something README users need to know. "temporary scratch files" is more accurate post-decoupling (they now live in `$TMPDIR`).

    **Do NOT** change anything else in README.md.

    **File**: `/Users/ben/github/benpeter/despicable-agents/README.md`
    **Branch**: nefario/decouple-self-referential-assumptions (already checked out)

- **Deliverables**: Updated README.md line 124
- **Success criteria**: The limitation description is accurate and does not expose internal implementation details

---

## Cross-Cutting Coverage

| Dimension | Coverage | Justification |
|-----------|----------|---------------|
| Testing | Not included | No code changes, no executable output. Pure documentation text edits. |
| Security | Not included | No attack surface, no auth, no user input, no secrets, no new dependencies. |
| Usability -- Strategy | Not included | No user-facing feature changes. The README edit (Task 4) improves clarity but does not change user journeys. |
| Usability -- Design | Not included | No user-facing interfaces produced. |
| Documentation | Covered by Tasks 1-4 | This IS the documentation task. |
| Observability | Not included | No runtime components produced. |

## Architecture Review Agents

- **Always**: security-minion, test-minion, ux-strategy-minion, software-docs-minion, lucy, margo
- **Conditional**: none triggered (no runtime components, no UI, no web-facing output)

Note: Given this is a pure documentation consistency audit with 4 small text edits (~15 lines total), the calling session should consider presenting the Phase 3.5 review as streamlined -- all ALWAYS reviewers run but the expectation is rapid APPROVE verdicts.

## Conflict Resolutions

### Scope breadth (margo vs. lucy + software-docs-minion)

**margo** recommended 2 tasks (compaction-strategy.md + Decision 21 annotation). **lucy** recommended 5 tasks. **software-docs-minion** recommended 4 tasks.

**Resolution**: 4 tasks. I verified each contested item by reading the actual files:

1. **compaction-strategy.md** -- All agree. Included (Task 1).
2. **Decision 21 annotation** -- All agree. Included (Task 2).
3. **CLAUDE.md + orchestration.md TEMPLATE.md contradiction** -- margo said "CLAUDE.md -- no scratch references" and "orchestration.md -- TEMPLATE.md reference at line 474 is valid (file exists)." margo is factually wrong here. The issue is not whether TEMPLATE.md exists (it does) but whether CLAUDE.md and orchestration.md contradict SKILL.md about which file is authoritative for report format. They do. SKILL.md line 1106 explicitly says "No external template file dependency is required" while CLAUDE.md says "following the template at TEMPLATE.md." This is a genuine consistency issue within the audit scope. Included (Task 3).
4. **README.md line 124** -- margo said "generic reference to 'scratch files' is accurate." margo is partially right -- "scratch files" is generic. But the parenthetical "(preserved as companion directories in PRs)" describes an internal mechanism that is confusing after decoupling. This is a minor but real improvement. Included (Task 4).

### Excluded items

5. **commit-workflow.md hardcoded `main`** (lucy Finding 7) -- **Excluded.** While Decision 26 decoupled `main` branch hardcoding, this finding is about branch naming conventions in a workflow document, not about scratch/report path consistency. It is a valid finding for a separate task, not this audit. Flagged as out-of-scope follow-up.
6. **Decision 14 TEMPLATE.md annotation** (lucy Finding 6) -- **Excluded.** The TEMPLATE.md role is clarified by Task 3. Adding another annotation to Decision 14 (which already has a Note about Decision 25) would be over-annotating. Decision 14's rejection of "separate template file" was about a runtime dependency; TEMPLATE.md was later created as a reference doc, which is a different thing. The distinction is clear enough without annotation.
7. **TEMPLATE.md header note** (software-docs-minion Task 4) -- **Excluded.** TEMPLATE.md is out of scope (it lives in `docs/history/`). The role clarification in CLAUDE.md and orchestration.md (Task 3) is sufficient. Adding a note to TEMPLATE.md itself is belt-and-suspenders.

## Risks and Mitigations

1. **Decision 21 over-editing**: Mitigated by explicit "Do NOT rewrite" constraints in the Task 2 prompt. The annotation follows the existing Decision 14 pattern exactly.
2. **TEMPLATE.md/SKILL.md drift**: After Task 3, the authority relationship is documented. No automated sync mechanism (YAGNI per margo). Future drift is a documentation maintenance responsibility.
3. **commit-workflow.md hardcoded `main`**: Flagged but excluded. Should be addressed in a separate PR. The commit-workflow.md file has 5+ `main` references that need coordinated update with the mermaid diagram.

## Execution Order

All 4 tasks are independent (no dependencies between them). They can execute in parallel:

```
Batch 1 (parallel):
  Task 1: compaction-strategy.md  (software-docs-minion)
  Task 2: decisions.md            (software-docs-minion)
  Task 3: CLAUDE.md + orchestration.md (software-docs-minion)
  Task 4: README.md               (user-docs-minion)
```

No approval gates. All changes are low-risk, easily reversible text edits.

## Verification Steps

After all tasks complete:

1. Grep for `nefario/scratch/` in all in-scope files -- should only appear in Decision 21 body (historical, annotated) and Decision 26 Rationale (historical reference to what was changed).
2. Grep for `TEMPLATE.md` in CLAUDE.md and orchestration.md -- should no longer present TEMPLATE.md as the authority; should reference SKILL.md as operational source.
3. Verify `docs/compaction-strategy.md` directory structure matches SKILL.md lines 82-96.
4. Verify README.md line 124 no longer mentions companion directories.
5. Verify Decision 21 has a Note row matching Decision 14's annotation pattern.

## Out-of-Scope Findings (for future work)

- **commit-workflow.md**: 5+ hardcoded `main` references need updating to "default branch" with dynamic detection. Separate PR recommended.
- **commit-workflow-security.md**: lucy noted line 225 has a `main/master` reference. Not in audit scope.
- **nefario/scratch/ directory**: Still exists on disk with legacy files. Cleanup is not a documentation task. Separate cleanup PR recommended.
