# Advisory Report

**Question**: Should the run title shown in approval gates use a full-length summary instead of the 40-character truncated version designed for the status line?

**Confidence**: HIGH

**Recommendation**: Introduce a second variable (`$summary_full`) retaining the complete first line of the task description (capped at 120 characters) for use in gate question fields, while preserving the existing 40-character `$summary` for the status line.

## Executive Summary

The fix to issue #83 (PR #96, commit 394e4dc) added run-title context to all AskUserQuestion gates in SKILL.md by appending `\n\nRun: $summary` to each gate's question field. This was a valuable improvement -- gates now carry session context so users can identify which orchestration run a gate belongs to.

However, the implementation reuses `$summary`, a variable defined in Phase 1 with a 40-character cap. That cap was designed for the status line sentinel file, where the total line budget is approximately 64 characters (prefix + summary + ellipsis). Approval gates display in a dialog/prompt UI with substantially more space -- both horizontally and vertically. Truncating the run title to 40 characters in gates discards useful context unnecessarily.

The fix is straightforward: define a second variable in Phase 1 that retains the full first line of the task description (or a longer cap such as 120 characters), and use that variable in gate question fields. The status line continues using the 40-character version. This is a low-risk, low-effort change with clear user benefit.

## Team Consensus

No specialists were consulted -- the task is fully scoped and self-contained. The following points represent the investigation findings:

1. The truncation in gates is an unintended side effect of variable reuse, not a deliberate design choice.
2. Gates have more display space than the status line and benefit from longer context.
3. The fix requires only SKILL.md changes (no agent changes, no deployment changes).
4. The existing 40-char cap remains correct for the status line use case.

## Dissenting Views

None -- no specialist consultation was performed, and the finding is unambiguous. The truncation is clearly unnecessary in the gate context.

## Supporting Evidence

### Status Line Constraints

The status line sentinel file has a practical display budget of approximately 64 characters. The format is `<icon> P<N> <phase-name> | <summary>...`, where the prefix consumes ~24 characters, leaving ~40 for the summary. The 40-character cap is well-calibrated for this context.

### Gate Display Context

AskUserQuestion gates render in Claude Code's interactive prompt UI. The question field supports multi-line content (the fix already uses `\n\n` for separation). There is no meaningful horizontal or vertical constraint that would require truncation to 40 characters. A 120-character summary would display comfortably.

### Variable Reuse Pattern

Phase 1 currently defines `$summary` once and it is used in two contexts with different display constraints:
- Status line sentinel: tight space, 40-char cap appropriate
- Gate question fields: ample space, 40-char cap unnecessary

This is a classic "one variable, two contexts" issue resolved by introducing a context-appropriate variant.

## Risks and Caveats

1. **Minimal implementation risk**: The change is confined to SKILL.md Phase 1 (variable definition) and the gate question templates. No code, no agent files, no deployment artifacts are affected.
2. **Edge case -- very long task descriptions**: If a user provides an extremely long first line (e.g., pasting a paragraph as a single line), the `$summary_full` variable could become unwieldy. A 120-character cap provides a reasonable upper bound while being 3x the current limit.
3. **Consistency consideration**: After the change, `Run:` lines in gates will show longer text than the status line. This is intentional and appropriate -- the two contexts serve different purposes (quick glance vs. decision-making context).

## Next Steps

1. **Create a GitHub issue** capturing this finding as a low-priority enhancement. If priority labels are not available, create a "nice-to-have" label.
2. **When implemented**: Modify SKILL.md Phase 1 to define both `$summary` (40-char, status line) and `$summary_full` (120-char, gates). Update all `AskUserQuestion` gate templates to use `$summary_full` in the `Run:` line.
3. **Scope**: SKILL.md only. No changes needed to AGENT.md, the-plan.md, or any agent files.

## Conflict Resolutions

None. No conflicts arose -- single-source investigation with unambiguous findings.
