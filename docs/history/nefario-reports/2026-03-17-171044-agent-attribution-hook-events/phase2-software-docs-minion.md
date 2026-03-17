# Phase 2: software-docs-minion Planning Contribution

## Planning Question
Which documents need updating if the ledger format changes? At minimum: `docs/commit-workflow.md` Sections 5 and 6. Are there other downstream references?

## Analysis

I performed a comprehensive search across all non-history documentation files for references to the change ledger format, `Co-Authored-By` trailer, commit message format, `track-file-changes.sh`, `commit-point-check.sh`, and the PostToolUse hook. Here is the complete inventory of documents that reference the commit attribution or ledger format, organized by impact severity.

## Documents Requiring Updates

### Tier 1: Direct format specifications (must update)

These documents define the ledger format or commit message format. If the format changes, these are broken until updated.

| Document | Sections | What references the format |
|----------|----------|---------------------------|
| `docs/commit-workflow.md` | Section 5 (Commit Message Convention) | `Co-Authored-By: Claude <noreply@anthropic.com>` template for both single-agent and orchestrated sessions |
| `docs/commit-workflow.md` | Section 6 (File Change Tracking) | Ledger format definition: "plain text file, one absolute file path per line". Ledger Interface, Lifecycle table, PostToolUse hook example code |
| `skills/nefario/SKILL.md` | Phase 4 (Execution) | Lines 1794-1796: auto-commit format with `Co-Authored-By: Claude <noreply@anthropic.com>`. Lines 1791-1802: full auto-commit-after-gate flow referencing "change ledger" |
| `skills/nefario/SKILL.md` | Wrap-up section | Lines 2200-2203: auto-commit remaining changes from change ledger |
| `domains/software-dev/DOMAIN.md` | Commit Conventions section | Line 389: `Co-Authored-By: Claude <noreply@anthropic.com>` trailer specification |
| `.claude/hooks/track-file-changes.sh` | Entire file | The hook that writes the ledger -- format changes require hook changes |
| `.claude/hooks/commit-point-check.sh` | Lines 312-351 | Reads the ledger; generates the commit checkpoint message including `Co-Authored-By` trailer template |

### Tier 2: Referential (should update for consistency)

These documents reference the ledger or commit format conceptually but do not define the exact format. They need review for accuracy but may only require minor wording adjustments.

| Document | Sections | What references the format |
|----------|----------|---------------------------|
| `docs/orchestration.md` | Section 5 (Commit Points in Execution Flow) | References "change ledger" by name in commit checkpoint and auto-commit descriptions. References "Co-Authored-By" conceptually via commit-workflow.md link. |
| `docs/commit-workflow-security.md` | Section 1 (Input Validation for File Paths) | References PostToolUse hook and `jq -r '.tool_input.file_path'` extraction. If the hook input schema changes (e.g., to include `agent_id`/`agent_type`), the security analysis of the extraction code needs updating. |
| `docs/commit-workflow-security.md` | Section 6 (Fail-Closed Behavior) | References "Ledger file unreadable" scenario. If ledger format changes from plain text to structured format, the fail-closed analysis may need revision. |
| `docs/deployment.md` | Hook Deployment section | Describes `track-file-changes.sh` purpose as "Appends modified file paths to a session-scoped change ledger." If the ledger gains additional fields, this description needs updating. |
| `docs/decisions.md` | Decision 18 | References "change ledger" and auto-commit mechanism. References "Co-Authored-By" trailer indirectly via rationale about commit safety coming from technical rails. |

### Tier 3: No update needed

These documents reference the commit workflow only by linking to it, or mention commits only in passing. They do not contain format details.

| Document | Reason no update needed |
|----------|------------------------|
| `docs/architecture.md` | Only links to commit-workflow.md and commit-workflow-security.md in the sub-documents table. Link text is generic. |
| `docs/using-nefario.md` | Mentions commits only as "Git commit output is suppressed via `--quiet` flags" and "No branch, no commits." No format details. |
| `docs/claudemd-template.md` | No commit or ledger references. |
| `docs/domain-adaptation.md` | No commit or ledger references. |
| `.claude/settings.json` | References hook script paths, not formats. Unchanged unless new hooks are added. |
| `docs/history/nefario-reports/*` | Historical reports are immutable records. Never update. |

## Recommendations

### 1. If the ledger format changes from plain-text-paths to structured records

If `agent_id`/`agent_type` are added to the ledger (e.g., as JSON lines or tab-separated fields), the following are affected:

- **`track-file-changes.sh`**: Must extract `agent_id`/`agent_type` from the PostToolUse hook input JSON and write them alongside the file path.
- **`commit-point-check.sh`**: Must parse the new format when reading the ledger. Must use the agent identity when generating the `Co-Authored-By` trailer or commit message scope.
- **`docs/commit-workflow.md` Section 6**: Ledger Interface definition must be rewritten to document the new format.
- **`docs/commit-workflow-security.md` Section 1**: Security analysis of the parsing code must be updated for the new extraction logic.

### 2. If only the Co-Authored-By trailer changes

If the change is limited to making the trailer agent-specific (e.g., `Co-Authored-By: frontend-minion (Claude) <noreply@anthropic.com>`), the impact is smaller:

- **`docs/commit-workflow.md` Section 5**: Update the two format blocks (single-agent and orchestrated).
- **`skills/nefario/SKILL.md` Phase 4**: Update the auto-commit template.
- **`domains/software-dev/DOMAIN.md`**: Update the Commit Conventions trailer line.
- **`commit-point-check.sh`**: Update the checkpoint message template.

### 3. Documentation update order

Execute documentation updates in this order to maintain consistency at each step:

1. Hook scripts (source of truth for runtime behavior)
2. `docs/commit-workflow.md` Sections 5 and 6 (canonical format specification)
3. `skills/nefario/SKILL.md` (orchestration instructions that reference the format)
4. `domains/software-dev/DOMAIN.md` (domain-specific commit conventions)
5. `docs/commit-workflow-security.md` (security analysis of the new format)
6. `docs/orchestration.md` Section 5 (referential, verify consistency)
7. `docs/deployment.md` Hook Deployment (update description if ledger format changed)
8. `docs/decisions.md` (add new decision entry for the format change rationale)

### 4. Risk: format specification drift

The `Co-Authored-By` trailer is currently specified in **four separate locations** (commit-workflow.md, SKILL.md, DOMAIN.md, commit-point-check.sh). This is a duplication risk -- if any location is missed during the update, the format will drift. Consider whether the commit message format could be defined in one canonical location with the others referencing it.

## Dependencies

- Need to know from the implementation agent: will the ledger format change, or only the commit message/trailer? This determines whether the documentation scope is Tier 1 only (5-7 files) or Tier 1 + Tier 2 (up to 10 files).
- Need to know from the devx/hook implementation: what fields from hook events (`agent_id`, `agent_type`) will be available and in what format. The documentation must match the actual hook input schema.

## Proposed Tasks

1. **Update commit-workflow.md Sections 5 and 6** -- Rewrite the commit message format templates and ledger interface definition to include agent attribution. Update the PostToolUse hook example code if the hook changes.

2. **Update SKILL.md commit references** -- Update the auto-commit template in Phase 4 and Wrap-up to use agent-attributed trailers/messages.

3. **Update DOMAIN.md commit conventions** -- Update the `Co-Authored-By` trailer specification in the software-dev domain adapter.

4. **Update commit-workflow-security.md** -- If the hook input parsing changes, update the security analysis of the extraction code (Section 1) and fail-closed scenarios (Section 6).

5. **Update orchestration.md and deployment.md** -- Verify consistency of ledger and commit references after primary docs are updated.

6. **Add decision entry in decisions.md** -- Document the rationale for adding agent attribution to commits (what was decided, what was rejected, why).
