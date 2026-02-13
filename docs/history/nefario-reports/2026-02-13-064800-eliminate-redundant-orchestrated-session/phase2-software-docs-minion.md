# Phase 2: software-docs-minion

## Planning Question

Review documentation references to `claude-commit-orchestrated` outside `docs/history/`. Identify all locations that describe the orchestrated-session marker mechanism and need updating. Assess whether a rewrite or simpler edit is appropriate.

## Findings

### Files outside `docs/history/` that reference the marker

**1. `docs/commit-workflow.md` -- Line 259** (primary documentation)

The paragraph in Section 7 "Hook Composition" reads:

> During nefario-orchestrated sessions, the Stop hook is suppressed via a session-scoped marker file (`/tmp/claude-commit-orchestrated-<session-id>`). The marker is created at the start of Phase 4 (execution) and removed at wrap-up. When the marker exists, the hook exits 0 immediately, producing no output. This prevents the hook's commit checkpoint from conflicting with the SKILL.md-driven auto-commit flow.

This is the sole substantive explanation of the marker mechanism in live documentation. It describes the full lifecycle: creation time, removal time, hook behavior, and purpose.

**2. `docs/commit-workflow.md` -- Line 311** (tangential reference)

The "Infinite Loop Protection" paragraph mentions a different marker file (`/tmp/claude-commit-declined-<session-id>`) using identical naming convention language. This reference is NOT about the orchestrated marker, but shares the same `/tmp/claude-*-<session-id>` naming pattern. No change needed here unless the declined marker is also being consolidated, which is out of scope.

**3. `docs/decisions.md` -- Line 223** (Decision 17: Report Generation Enforcement)

The "Alternatives rejected" column mentions a `(2) **SessionEnd hook with marker file**` pattern but does NOT reference `claude-commit-orchestrated` by name. This is a generic reference to the marker file concept. No edit needed.

**4. `skills/nefario/SKILL.md` -- Lines 569, 1218, 1760** (implementation instructions)

Three references in the SKILL.md itself:
- Line 569: Wrap-up cleanup command that removes both files
- Line 1218: Phase 4 creation of the marker
- Line 1760: Alternative cleanup path

These are implementation references, not documentation. They are in scope for the devx-minion or whoever edits the SKILL.md, not for documentation edits.

**5. `.claude/hooks/commit-point-check.sh` -- Line 140** (implementation)

The hook script itself. Again, implementation, not documentation.

### Files inside `docs/history/` (for completeness)

16 files across multiple nefario-reports reference the marker. Per the task instructions, these are excluded from the edit scope. Historical reports are immutable records and should not be retroactively modified.

### Other non-history docs files checked (no references found)

- `docs/architecture.md` -- no reference
- `docs/agent-catalog.md` -- no reference
- `docs/commit-workflow-security.md` -- no reference
- `docs/orchestration.md` -- no reference
- `docs/deployment.md` -- no reference
- `docs/using-nefario.md` -- no reference
- `docs/external-skills.md` -- not checked (no grep match)
- `docs/compaction-strategy.md` -- not checked (no grep match)

## Recommendations

### A simpler edit is sufficient -- not a rewrite

The documentation impact is contained to **one paragraph** in `docs/commit-workflow.md` (line 259). The surrounding Section 7 structure, the flowchart, and the hook settings JSON do not reference the marker. The change is a mechanism swap (check a different file), not a conceptual change (the purpose and behavior are identical).

**Proposed replacement for line 259:**

Replace the current paragraph with one that describes the new approach. The key changes are:

1. Replace `/tmp/claude-commit-orchestrated-<session-id>` with `/tmp/nefario-status-<session-id>`
2. Remove the sentence about "created at the start of Phase 4 and removed at wrap-up" since the nefario-status file has a different lifecycle (created at session start by SKILL.md, removed at wrap-up) and is managed by nefario for its own purposes
3. Clarify that the hook now piggybacks on the nefario status file rather than managing a dedicated marker

Suggested text:

> During nefario-orchestrated sessions, the Stop hook is suppressed by checking for the nefario status file (`/tmp/nefario-status-<session-id>`). This file is created when nefario orchestration begins and removed at wrap-up. When the file exists, the hook exits 0 immediately, producing no output. This prevents the hook's commit checkpoint from conflicting with the SKILL.md-driven auto-commit flow.

This is a single-paragraph edit. No structural changes to the document. No new sections needed.

### No changes to other docs files

- `docs/decisions.md` does not reference the specific marker file path; no edit needed.
- `docs/commit-workflow-security.md` discusses security properties of hooks generically; no edit needed.
- `docs/history/*` is immutable; no edit.

## Proposed Tasks

### Task 1: Update `docs/commit-workflow.md` Section 7 paragraph (line 259)

**Scope**: Replace the single paragraph describing the orchestrated marker mechanism with one describing the nefario-status file approach.

**Deliverable**: Updated paragraph in `docs/commit-workflow.md` line 259.

**Effort**: Minimal -- single paragraph replacement.

**Dependencies**: Must happen in the same PR as the hook script change and SKILL.md change, so the documentation stays in sync with the implementation.

## Risks and Concerns

1. **Lifecycle accuracy**: The replacement text must accurately describe the nefario-status file's lifecycle. The current marker was "created at Phase 4, removed at wrap-up." The nefario-status file appears to be created earlier (session start / Phase 1) and removed at wrap-up. The documentation must reflect the actual new lifecycle, not copy the old one. The implementer editing the hook and SKILL.md should confirm the exact creation and removal points so the doc update is accurate.

2. **The `claude-commit-declined` marker (line 311) is a separate concern**: This is a different marker file (`/tmp/claude-commit-declined-<session-id>`) for a different purpose (tracking user rejection of commit prompts). It should NOT be consolidated with the nefario-status file because it serves a distinct role in single-agent sessions. No documentation change needed here, but flagging to avoid scope creep.

3. **History docs immutability**: The `docs/history/` files contain many references to `claude-commit-orchestrated`. These must not be edited. They are historical records of the decisions and designs that led to the current state. The new mechanism is documented in the live docs; history explains the old mechanism.

## Additional Agents Needed

None for the documentation task. The single-paragraph edit is straightforward and within scope for whatever agent executes the implementation (likely devx-minion or whoever handles the hook + SKILL.md changes). The documentation edit should be bundled with the implementation changes rather than assigned as a separate execution task.
