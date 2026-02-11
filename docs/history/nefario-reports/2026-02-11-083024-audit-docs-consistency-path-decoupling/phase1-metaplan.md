# Meta-Plan: Audit Documentation Consistency After Path Decoupling

## Task Summary

Audit all in-scope documentation files for consistency with PR #20 (decouple self-referential path assumptions). Ensure no stale references to hardcoded paths, no contradictions about scratch/report directories, uniform use of `$SCRATCH_DIR` and cwd-relative conventions, and accurate cross-references.

## Findings from Codebase Analysis

The primary sources of truth (SKILL.md, compaction-strategy.md, orchestration.md) are already updated to the new `$TMPDIR`-based scratch model. However, several files contain stale references:

### Known Inconsistencies Found

1. **`docs/decisions.md` Decision 21** (lines 274, 277): Still describes the original choice as `nefario/scratch/{slug}/` and consequences as "Session-specific scratch directories under `nefario/scratch/` (gitignored)." Decision 26 supersedes the scratch portions of Decision 21, but Decision 21's own text was not updated to reflect this. The Choice and Consequences fields still read as if they are current.

2. **`CLAUDE.md`** (line 61): References `docs/history/nefario-reports/TEMPLATE.md` as the report template location. SKILL.md no longer references TEMPLATE.md -- the report format is now defined inline in SKILL.md. While TEMPLATE.md still exists on disk, the CLAUDE.md instruction to "follow the template at `docs/history/nefario-reports/TEMPLATE.md`" is potentially misleading since SKILL.md is now the authoritative source.

3. **`docs/decisions.md` Decision 26** (line 345): References `nefario/scratch/` as something being decoupled from, which is accurate historical context. Similarly line 346 says "`.gitignore` entries for `nefario/scratch/` removed" -- also accurate historical context. These references in Decision 26 are correct (they describe what was changed FROM), unlike Decision 21 which describes the old approach as the current choice.

4. **Cross-reference accuracy**: `docs/compaction-strategy.md` line 7 references `../skills/nefario/SKILL.md` -- this is correct. The compaction-strategy.md content was updated in the PR and now correctly describes the `$TMPDIR`-based model. The `docs/orchestration.md` Section 4 (Execution Reports) references report directory detection logic that aligns with SKILL.md.

5. **TEMPLATE.md existence**: TEMPLATE.md still exists at `docs/history/nefario-reports/TEMPLATE.md`. The SKILL.md defines the report format inline and does not reference TEMPLATE.md. CLAUDE.md still points to TEMPLATE.md. This creates ambiguity about which is authoritative.

6. **README.md line 124**: Mentions "scratch files (preserved as companion directories in PRs)" -- this is accurate for the current model where scratch files are copied to companion directories at wrap-up.

---

## Planning Consultations

### Consultation 1: Documentation Structure and Cross-Reference Audit
- **Agent**: software-docs-minion
- **Planning question**: Given the path decoupling changes in PR #20 (scratch files moved from `nefario/scratch/` to `$TMPDIR` via `mktemp -d`, report directory detection now cwd-relative, SKILL.md now defines report format inline instead of referencing TEMPLATE.md), what is the right approach to update `docs/decisions.md` Decision 21 -- should the original Choice/Consequences text be amended with a "Superseded by Decision 26" note, or should the Decision 21 text itself be rewritten to reflect the current state? Additionally, what should happen to `docs/history/nefario-reports/TEMPLATE.md` now that SKILL.md defines the format inline -- should it be deleted, kept as historical reference, or explicitly marked as deprecated? Consider that CLAUDE.md still references it. Examine cross-references between docs/orchestration.md, docs/compaction-strategy.md, docs/deployment.md, and SKILL.md to identify any other stale links or descriptions.
- **Context to provide**: `docs/decisions.md` (full file), `docs/compaction-strategy.md`, `docs/orchestration.md`, `CLAUDE.md`, `skills/nefario/SKILL.md`, `docs/history/nefario-reports/TEMPLATE.md`
- **Why this agent**: Software-docs-minion specializes in architectural documentation consistency, cross-reference integrity, and documentation structure decisions (like when to amend vs. annotate historical decision records).

### Consultation 2: User-Facing Documentation Consistency
- **Agent**: user-docs-minion
- **Planning question**: Review `docs/using-nefario.md` and `README.md` from the perspective of a new user encountering the toolkit for the first time. After the path decoupling, do these files give an accurate picture of how scratch files and reports work? Specifically: (1) Does the "Current Limitations" section in README.md (line 124, "scratch files (preserved as companion directories in PRs)") accurately describe the current behavior? (2) Does `docs/using-nefario.md` need any updates to reflect the decoupled path model, or does its current level of abstraction ("reports, feature branches, and commits all target the current working directory's project") already cover the new behavior correctly? (3) Are there any user-facing implications of the path change that should be mentioned but are not?
- **Context to provide**: `README.md`, `docs/using-nefario.md`, `skills/nefario/SKILL.md` (Path Resolution section)
- **Why this agent**: User-docs-minion evaluates documentation from the end-user perspective, focusing on whether the docs accurately communicate behavior without requiring users to understand implementation details.

### Consultation 3: Intent Alignment Review
- **Agent**: lucy
- **Planning question**: Check whether the in-scope documentation files (docs/*.md, SKILL.md, CLAUDE.md, README.md, install.sh) are internally consistent with each other regarding (1) where scratch files are created, (2) how report directories are detected, (3) the role of TEMPLATE.md, and (4) terminology used for the decoupled path model. Specifically, CLAUDE.md line 61 says "generate an execution report following the template at `docs/history/nefario-reports/TEMPLATE.md`" but SKILL.md defines the format inline. Decision 21 in decisions.md still describes the pre-decoupling scratch path as the current choice. Do these create convention violations or intent drift? What is the minimal set of changes needed to restore consistency without rewriting accurate historical context?
- **Context to provide**: `CLAUDE.md`, `docs/decisions.md`, `docs/orchestration.md`, `docs/compaction-strategy.md`, `skills/nefario/SKILL.md`
- **Why this agent**: Lucy specializes in repo convention enforcement, cross-file consistency, and detecting intent drift -- exactly the class of problems this audit targets.

### Consultation 4: Simplicity and Scope Check
- **Agent**: margo
- **Planning question**: This task is a documentation consistency audit. Is the scope appropriately bounded? Are there any signs of over-engineering risk (e.g., rewriting historical decision records when annotation would suffice, creating new documentation when edits to existing docs would work, or adding explanatory text that is not needed)? What is the simplest set of changes that achieves the stated success criteria (no stale hardcoded paths, consistent scratch/report descriptions, accurate cross-references, uniform terminology, aligned CLAUDE.md)?
- **Context to provide**: The task description and success criteria, `docs/decisions.md` Decision 21 and Decision 26, `CLAUDE.md`
- **Why this agent**: Margo enforces YAGNI/KISS and prevents scope creep. For a documentation audit, the risk is over-editing -- changing things that are not actually broken. Margo's role is to identify the minimal change set.

---

## Cross-Cutting Checklist

- **Testing**: Exclude. This task produces only documentation edits. Existing tests (`tests/test-no-hardcoded-paths.sh`) already validate the code-level path changes. No new executable output is being produced.
- **Security**: Exclude. No attack surface, auth, user input, secrets, or infrastructure changes. Pure documentation edits.
- **Usability -- Strategy**: Excluded per user constraint (limited to software-docs-minion, user-docs-minion, lucy, margo). User-docs-minion covers the user-facing documentation perspective. The user-facing implications are minimal (path changes are internal to the orchestration machinery).
- **Usability -- Design**: Exclude. No user-facing interfaces involved.
- **Documentation**: Included. software-docs-minion (architecture docs) and user-docs-minion (user-facing docs) are both consulted.
- **Observability**: Exclude. No runtime components involved.

---

## Anticipated Approval Gates

**None expected.** This is a documentation consistency audit. All changes are additive annotations or minor text corrections to existing files. The reversibility is high (text edits) and blast radius is low (no downstream tasks depend on the documentation text). Per the gate classification matrix, this falls into the NO GATE category.

The execution plan itself will go through the standard plan approval gate, which is sufficient for a task of this scope.

---

## Rationale

Four specialists are consulted, matching the user's constraint:

- **software-docs-minion**: The primary expert for architectural documentation structure, decision record conventions, and cross-reference integrity. Owns the question of how to handle Decision 21's stale text and TEMPLATE.md's status.
- **user-docs-minion**: Evaluates README.md and using-nefario.md from the user perspective. Ensures the path changes do not create user-facing confusion.
- **lucy**: Cross-file consistency enforcement. Catches convention violations between CLAUDE.md, SKILL.md, and docs that individual doc specialists might not see.
- **margo**: Scope guard. Ensures the audit produces the minimal necessary changes without over-editing historical records or adding unnecessary new content.

---

## Scope

**In scope**:
- `docs/architecture.md` -- check for stale scratch/report path references
- `docs/orchestration.md` -- verify scratch/report descriptions match SKILL.md
- `docs/compaction-strategy.md` -- verify scratch directory description matches SKILL.md
- `docs/decisions.md` -- update Decision 21 to reflect supersession by Decision 26
- `docs/deployment.md` -- check for any scratch/report path references
- `docs/using-nefario.md` -- verify user-facing descriptions are accurate
- `skills/nefario/SKILL.md` -- reference only (already updated, serves as source of truth)
- `CLAUDE.md` -- update TEMPLATE.md reference
- `README.md` -- verify scratch file description accuracy
- `install.sh` -- check inline comments for path references

**Out of scope**:
- `AGENT.md` system prompts (per user constraint)
- `RESEARCH.md` files (per user constraint)
- `the-plan.md` (per user constraint)
- `docs/history/nefario-reports/` execution reports (per user constraint, these are historical records)
- Test files (per user constraint)
- `docs/agent-anatomy.md`, `docs/build-pipeline.md`, `docs/agent-catalog.md` (no scratch/report path references expected; included in scope only if a specialist identifies a reference)
- `docs/commit-workflow.md`, `docs/commit-workflow-security.md` (no scratch/report path references)
