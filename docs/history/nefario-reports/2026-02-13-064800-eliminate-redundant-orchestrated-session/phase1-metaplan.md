# Phase 1: Meta-Plan

## Task Summary

Replace the dedicated boolean marker file (`/tmp/claude-commit-orchestrated-${SID}`)
with a check for the nefario status file (`/tmp/nefario-status-${SID}`) in the
commit hook and SKILL.md lifecycle instructions. This eliminates tmp file sprawl
and removes a coordination point nefario must explicitly manage.

## Scope

**In scope:**
- `.claude/hooks/commit-point-check.sh` -- change orchestration detection from
  dedicated marker to nefario-status file check
- `skills/nefario/SKILL.md` -- remove all `touch` and `rm -f` instructions for
  `claude-commit-orchestrated`
- `docs/commit-workflow.md` -- update documentation to reflect the new mechanism

**Out of scope:**
- Change ledger mechanism, defer/declined markers
- Status file write/read format
- `despicable-statusline` skill
- Historical report files in `docs/history/`

## Analysis

### Files Requiring Changes

| File | Change | Lines |
|------|--------|-------|
| `.claude/hooks/commit-point-check.sh` | Replace marker path on L140 with nefario-status path | ~2 lines |
| `skills/nefario/SKILL.md` L569 | Remove `claude-commit-orchestrated` from reject cleanup (keep `nefario-status` removal) | ~1 line |
| `skills/nefario/SKILL.md` L1217-1218 | Remove entire `touch` instruction for orchestrated marker | ~2 lines |
| `skills/nefario/SKILL.md` L1759-1760 | Remove `rm -f claude-commit-orchestrated` line (keep `nefario-status` removal) | ~1 line |
| `docs/commit-workflow.md` L259 | Update description of suppression mechanism | ~3 lines |

### Key Design Consideration

**Timing difference**: The nefario-status file is created at Phase 1 (meta-plan
start, SKILL.md L368), while the orchestrated marker was created at Phase 4
(branch resolution, SKILL.md L1218). This means the commit hook will be
suppressed *earlier* -- during planning phases P1-P3.5 as well as execution.

This is the correct behavior: during planning phases, there are no code changes
to commit (those happen in P4+), so the hook would exit anyway due to empty
ledger/no git changes. Suppressing the hook earlier is harmless and arguably
more correct -- it avoids unnecessary hook execution during orchestration.

The nefario-status file is deleted at wrap-up (SKILL.md L1761), which is the
same time the orchestrated marker was deleted. So the "end" lifecycle is identical.

For the reject/abandon path (SKILL.md L569), the nefario-status file is already
cleaned up in the same command. Removing `claude-commit-orchestrated` from that
line is sufficient.

### Risk Assessment

**Low risk**: This is a straightforward search-and-replace across 3 active files
with a clear before/after. The behavioral contract is preserved (file exists =
suppress, file absent = prompt). No new logic is introduced.

## Planning Consultations

### Consultation 1: Shell Script and Lifecycle Validation

- **Agent**: devx-minion
- **Planning question**: Review the commit hook's orchestration check (lines 139-143 of `commit-point-check.sh`) and the three SKILL.md locations where the orchestrated marker is managed (L569, L1218, L1760). Confirm that replacing the marker check with a nefario-status file check introduces no edge cases -- specifically: (a) Are there any scenarios where the nefario-status file might not exist during an active orchestration? (b) Is the `-f` test sufficient, or should the hook also verify the file is non-empty? (c) The nefario-status file exists from P1 while the old marker existed from P4 -- does earlier suppression create any issues with the commit ledger or other hooks?
- **Context to provide**: `commit-point-check.sh` (full file), SKILL.md lines 360-370 (status file creation), 565-570 (reject cleanup), 1210-1220 (marker creation), 1755-1765 (wrap-up cleanup)
- **Why this agent**: DevX expertise in CLI tool lifecycle, shell scripting patterns, and session management. Owns the hook design domain.

### Cross-Cutting Checklist

- **Testing** (test-minion): NOT included for planning. The changes are to a shell script and a markdown skill file. The test strategy is straightforward (manual verification of hook behavior with/without status file). test-minion may be included in execution if the plan calls for a test script, but their domain expertise is not needed to *plan* these changes. Phase 6 post-execution testing will validate behavior.
- **Security** (security-minion): NOT included for planning. The change swaps one file-existence check for another. No new attack surface, no auth changes, no user input handling changes. The status file already has `chmod 600` (SKILL.md L369). The security posture is unchanged or marginally improved (fewer tmp files).
- **Usability -- Strategy** (ux-strategy-minion): NOT included for planning. The issue explicitly states "No behavioral change from the user's perspective." This is an internal refactoring of a mechanism invisible to users. Including ux-strategy would produce no actionable planning input.
- **Usability -- Design** (ux-design-minion, accessibility-minion): NOT included. No user-facing interfaces are affected.
- **Documentation** (software-docs-minion): Include -- see Consultation 2 below.
- **Observability** (observability-minion, sitespeed-minion): NOT included for planning. No runtime services, no metrics, no logging changes.

### Consultation 2: Documentation Impact Assessment

- **Agent**: software-docs-minion
- **Planning question**: Review the documentation references to `claude-commit-orchestrated` in `docs/commit-workflow.md` (line 259) and `docs/using-nefario.md` (if any). Identify all documentation locations that describe the orchestrated-session marker mechanism and need updating. Should the explanation in commit-workflow.md Section 7 be rewritten to describe the nefario-status file approach, or is a simpler edit sufficient? Are there any doc-only files outside `docs/history/` that reference this marker?
- **Context to provide**: `docs/commit-workflow.md` lines 255-270, `docs/using-nefario.md` lines 195-210, the grep results showing all `claude-commit-orchestrated` references
- **Why this agent**: Owns architecture and workflow documentation. Can identify documentation locations the shell script expert might miss.

### Consultation 3: User Documentation Review

- **Agent**: user-docs-minion
- **Planning question**: Does the user-facing documentation (guides, tutorials, troubleshooting) reference the `claude-commit-orchestrated` marker in any way that end users would need to understand or interact with? If so, what needs updating? If not, confirm that this internal mechanism change has no user-doc impact.
- **Context to provide**: Grep results for `claude-commit-orchestrated` across all non-history docs
- **Why this agent**: The issue says "No behavioral change from the user's perspective" -- user-docs-minion validates that claim from the documentation side.

### Consultation 4: Product Messaging Review

- **Agent**: product-marketing-minion
- **Planning question**: This is a pure internal refactoring with no behavioral change. Confirm that no product-facing messaging, changelogs, or feature descriptions reference the `claude-commit-orchestrated` mechanism. Is there any product messaging impact from this change?
- **Context to provide**: Summary of the change (internal mechanism swap, no behavioral change)
- **Why this agent**: Included per user request. Validates that the internal mechanism is not surfaced in any product-facing content.

## Anticipated Approval Gates

**None anticipated.** Per the gate classification matrix:
- Reversibility: EASY (all changes are to config/script/docs, trivially revertible)
- Blast radius: LOW (the commit hook and SKILL.md are self-contained; no downstream tasks depend on this)
- No multiple-valid-approaches ambiguity -- there is one clear approach (swap the file check)

This task should execute without approval gates. The cross-cutting Phase 3.5 review and Phase 5 code review provide sufficient quality assurance.

## Rationale

This is a narrow, well-scoped refactoring with clear before/after semantics. Only
**devx-minion** brings genuinely needed domain expertise (shell script lifecycle
validation). **software-docs-minion** ensures documentation coverage.
**user-docs-minion** and **product-marketing-minion** are included per the user's
explicit request -- their consultation questions are scoped to confirm no impact
rather than generate new content.

Other specialists (frontend, data, API, infrastructure, etc.) have zero overlap
with this task domain. Cross-cutting agents (security, testing, observability) are
not needed for *planning* -- their concerns are either inapplicable or handled by
post-execution phases.

## External Skill Integration

### Discovered Skills

| Skill | Location | Classification | Domain | Recommendation |
|-------|----------|---------------|--------|----------------|
| despicable-lab | `.claude/skills/despicable-lab/` | LEAF | Agent spec rebuild | Not relevant -- no agent specs are changing |
| despicable-statusline | `.claude/skills/despicable-statusline/` | LEAF | Status line configuration | Not relevant -- explicitly out of scope per issue |

### Precedence Decisions

No precedence conflicts. Neither discovered skill overlaps with the task domain
(commit hook shell scripting, SKILL.md lifecycle instructions).
