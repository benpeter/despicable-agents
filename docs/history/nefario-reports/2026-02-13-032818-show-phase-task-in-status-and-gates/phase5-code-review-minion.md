# Code Review: Phase Context in Status Line and Gates

**VERDICT: ADVISE**

## Summary

The implementation is correct, well-structured, and meets all specified requirements. The changes are documentation-only (SKILL.md orchestration instructions + user guide updates), with no executable code, so the risk is extremely low. However, there are three advisory findings related to documentation clarity and consistency.

## FINDINGS

### [ADVISE] docs/using-nefario.md:100 -- Uncommitted wording change less specific than committed version

**Description**: The uncommitted change to line 100 replaces a specific, concrete description with a vaguer one.

**Committed version (f72ceb4)**:
```
The status line and gate headers show the current phase (`P1 Meta-Plan`, `P2 Planning`, etc.) so you always know where the orchestration stands.
```

**Uncommitted version**:
```
The status line and all approval prompts include the current phase, so you always know where you are in the process.
```

**Issue**: The uncommitted version is less specific. It says "all approval prompts include the current phase" but doesn't clarify HOW they include it (via the header field). The committed version explicitly mentions "gate headers" and provides examples of the format. This is more helpful to users who want to understand what to expect.

**FIX**: Revert to the committed version OR enhance the uncommitted version to be more concrete:
```
The status line and gate headers show the current phase (P1 Meta-Plan, P2 Planning, etc.), so you always know where you are in the process.
```

### [ADVISE] docs/using-nefario.md:194 -- Format detail unnecessarily removed

**Description**: Line 194 removes an illustrative format example from "How It Works".

**Committed version (f72ceb4)**:
```
...writes a phase-prefixed task summary (e.g., `P1 Meta-Plan | Build MCP server...`) to `/tmp/nefario-status-<session-id>`.
```

**Uncommitted version**:
```
...writes the current phase and task summary to `/tmp/nefario-status-<session-id>`.
```

**Issue**: The committed version provides a concrete example that helps users understand the exact format if they're debugging or building custom status line integrations. The uncommitted version is vaguer. While Task 2 instructions said "do NOT document the status file format... users see the rendered status line, not the raw file," the committed version struck a good balance by showing ONE example inline without documenting the full format specification.

**FIX**: Keep the committed version with the example. It aids understanding without being overly prescriptive.

### [NIT] skills/nefario/SKILL.md:1398 -- Header "P4 Calibr." uses abbreviation for 12-char limit

**Description**: The calibration gate header is abbreviated to "P4 Calibr." (12 chars) to fit the character limit. This is the only gate header that uses an abbreviation.

**Issue**: "Calibr." is not an obviously recognizable abbreviation. Users might expect "Calibrate" but see "Calibr." The truncation is necessary due to the hard 12-char limit ("P4 Calibrate" = 13 chars), but it creates a minor consistency issue where all other headers use full words.

**FIX**: Consider one of these alternatives (both fit within 12 chars):
1. `"P4 Calib"` (9 chars) -- drop the period, matches the pattern of other headers having no punctuation
2. `"P4 Tune"` (7 chars) -- use a synonym that fits without abbreviation

This is a NIT because the current implementation is acceptable and the gate is rarely seen (only after 5 consecutive approvals). But if consistency matters, a synonym would be cleaner.

## Positive Observations

1. **Comprehensive implementation**: All 8 primary gate headers are updated consistently. All 4 follow-up gates correctly preserve their existing headers (no phase prefix).

2. **Proper sequencing**: Status file writes are correctly placed BEFORE phase announcement markers at all boundaries (Phase 1, 2, 3, 3.5, 4).

3. **Mid-execution gate handling**: The P4 Gate correctly updates the status file to show gate state before presenting the gate, then reverts to "P4 Execution" after resolution. This provides accurate real-time status.

4. **Character limit documentation**: The added note about the 12-character header limit is well-placed and will help future maintainers avoid overflow issues.

5. **Task title in P4 Gate questions**: The question format enhancement ("Task N: <title> -- <decision>") provides valuable context during multi-task execution phases.

6. **Truncation adjustment**: Reducing the summary from 48 to 40 characters is appropriate given the phase prefix adds ~16 characters. The math is correct (~62 chars total).

7. **DRY principle**: The status file write pattern is intentionally NOT extracted to a helper function. The inline repetition is the right choice here -- it keeps each phase boundary self-contained and readable (5 instances with slight variations for different phase labels).

## Security

No security concerns. Changes are to documentation/specification files. No secrets, authentication, or user input handling.

## Complexity

No complexity concerns. All changes are additive string formatting. No control flow complexity introduced.

## Cross-Agent Integration

No integration concerns. The changes are confined to nefario's internal orchestration instructions and user documentation. The despicable-statusline skill is correctly identified as needing no changes (it reads the status file verbatim).

## Recommendation

**ADVISE** -- Accept the implementation but consider reverting the uncommitted docs/using-nefario.md changes to preserve the more specific, example-rich wording from the committed version (f72ceb4). The current uncommitted changes make the documentation vaguer without providing compensating benefits.

If the uncommitted changes are kept, ensure consistency with the committed commit message's claim that the implementation includes "phase-prefixed task summary" -- the phrase should appear in the docs.
