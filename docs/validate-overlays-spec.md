# Validate-Overlays Script Specification

## Purpose

`validate-overlays.sh` detects drift in the despicable-agents overlay system. It verifies that `AGENT.md` files reflect the current merge state of `AGENT.generated.md` + `AGENT.overrides.md`, identifies orphaned override claims, and catches configuration inconsistencies.

This is a detection-only tool. It does NOT perform merges or modify files. It reports drift and provides actionable guidance for fixing it.

## Invocation Interface

### Synopsis

```bash
validate-overlays.sh [<agent-name>] [--summary]
```

### Arguments

- **No arguments**: Check all agent directories under the project root. Report summary table + detailed issues for all agents with drift.
- **`<agent-name>`**: Check a single agent directory (e.g., `nefario`, `frontend-minion`). Report detailed issues for that agent only.
- **`--summary`**: Machine-friendly summary output. Report one line per agent with status and issue count, no detail blocks. Designed for consumption by `/despicable-lab --check`.

### Examples

```bash
# Check all agents, show summary + details
validate-overlays.sh

# Check one agent, show details
validate-overlays.sh nefario

# Check all agents, show summary only (for /despicable-lab integration)
validate-overlays.sh --summary
```

### Exit Codes

- `0`: No drift detected, all checks pass
- `1`: Drift detected in one or more agents
- `2`: Script error (invalid arguments, missing dependencies, file system errors)

## Output Format

### Summary Table (default mode, no `--summary` flag)

When checking multiple agents, print a summary table followed by detailed issue blocks for agents with drift.

```
AGENT               STATUS    ISSUES
-----------------------------------------
nefario             DRIFT     3
frontend-minion     CLEAN     0
api-design-minion   DRIFT     1
gru                 CLEAN     0
...
-----------------------------------------
TOTAL: 19 agents, 2 with drift
```

- **AGENT**: Agent directory name
- **STATUS**: `CLEAN` (no issues) or `DRIFT` (one or more issues detected)
- **ISSUES**: Number of issues detected for this agent

After the summary table, print detailed issue blocks for each agent with `STATUS = DRIFT`.

### Summary-Only Output (`--summary` flag)

One line per agent, no table borders, no detail blocks. Designed for machine parsing.

```
nefario DRIFT 3
frontend-minion CLEAN 0
api-design-minion DRIFT 1
gru CLEAN 0
...
```

Format: `<agent-name> <STATUS> <issue-count>`

### Detailed Issue Blocks

For each agent with drift, print a detail block with the following format:

```
=== <agent-name> ===

<issue-type>: <description>
File: <file-path>
Line: <line-number> (if applicable)
<additional context>
Action: <actionable-next-step>

<issue-type>: <description>
...

---
```

#### Issue Types

1. **MERGE_STALENESS**: `AGENT.md` does not reflect current merge state
2. **ORPHAN_OVERRIDE**: `AGENT.overrides.md` claims a section that does not exist in `AGENT.generated.md`
3. **MISSING_OVERRIDES_FILE**: Agent has `x-fine-tuned: true` but no `AGENT.overrides.md`
4. **INCONSISTENT_FLAG**: Agent has `AGENT.overrides.md` but no `x-fine-tuned: true` in `AGENT.md`
5. **NON_OVERLAY_MISMATCH**: Agent without overrides has `AGENT.generated.md` and `AGENT.md` that differ
6. **FRONTMATTER_INCONSISTENCY**: Merged frontmatter does not match expected merge result

#### Actionable Next Steps

Every error message MUST include an `Action:` line with concrete next steps. Examples:

- `Action: Run /despicable-lab nefario to regenerate AGENT.generated.md and re-merge.`
- `Action: Review AGENT.overrides.md and remove or rename the orphaned section claim.`
- `Action: Remove x-fine-tuned flag from AGENT.md frontmatter or create AGENT.overrides.md.`
- `Action: Delete AGENT.generated.md or sync AGENT.md to match (copy AGENT.generated.md to AGENT.md).`

### Example Output (default mode, multiple agents)

```
AGENT               STATUS    ISSUES
-----------------------------------------
nefario             DRIFT     2
frontend-minion     CLEAN     0
api-design-minion   CLEAN     0
-----------------------------------------
TOTAL: 3 agents, 1 with drift

=== nefario ===

ORPHAN_OVERRIDE: Section claimed in overrides does not exist in generated
File: /Users/ben/github/benpeter/despicable-agents/nefario/AGENT.overrides.md
Section: ## Conflict Resolution
AGENT.generated.md does not contain a section with this heading.
Action: Review AGENT.overrides.md and remove or rename the orphaned section claim. Check if the section was removed from the-plan.md or if the heading changed.

MERGE_STALENESS: AGENT.md section differs from both generated and override
File: /Users/ben/github/benpeter/despicable-agents/nefario/AGENT.md
Section: ## Output Standards
Line: 342
The section in AGENT.md does not match AGENT.generated.md or AGENT.overrides.md.
This indicates a manual edit or stale merge.
Action: Run /despicable-lab nefario to regenerate AGENT.generated.md and re-merge. If the section was intentionally hand-edited, move the edit to AGENT.overrides.md.

---
```

### Example Output (summary mode)

```
nefario DRIFT 2
frontend-minion CLEAN 0
api-design-minion CLEAN 0
```

## Validation Checks

### 1. Merge Staleness Check

**Purpose**: Verify that `AGENT.md` reflects the current merge of `AGENT.generated.md` + `AGENT.overrides.md`.

**Logic**:

For each agent directory:

1. If `AGENT.overrides.md` exists:
   - Perform the merge algorithm (see Merge Algorithm section below) on `AGENT.generated.md` + `AGENT.overrides.md`
   - Compare the computed merge result to `AGENT.md`
   - If they differ, report `MERGE_STALENESS`

2. If `AGENT.overrides.md` does NOT exist:
   - If `AGENT.generated.md` exists, compare it to `AGENT.md` after normalization
   - If they differ, report `NON_OVERLAY_MISMATCH`
   - If `AGENT.generated.md` does not exist, skip this check (pre-overlay agent)

**Normalization**: Before comparison, normalize both files:
- Strip trailing whitespace from all lines
- Collapse consecutive blank lines to a single blank line
- Ensure file ends with exactly one newline

**Issue Type**: `MERGE_STALENESS` (if overrides exist) or `NON_OVERLAY_MISMATCH` (if no overrides)

**Action**:
- If overrides exist: `Run /despicable-lab <agent-name> to regenerate AGENT.generated.md and re-merge.`
- If no overrides: `Delete AGENT.generated.md or sync AGENT.md to match (copy AGENT.generated.md to AGENT.md).`

### 2. Orphan Override Check

**Purpose**: Detect sections in `AGENT.overrides.md` that do not exist in `AGENT.generated.md`.

**Logic**:

For each agent with `AGENT.overrides.md`:

1. Extract all H2 section headings from `AGENT.generated.md` (lines matching `^## .+$` that are not inside fenced code blocks)
2. Extract all "Section:" claims from `AGENT.overrides.md` (lines matching `^## Section: .+$`)
3. For each claimed section, verify a matching H2 heading exists in `AGENT.generated.md`
4. If no match, report `ORPHAN_OVERRIDE`

**Section Heading Match**: The claimed section name in `AGENT.overrides.md` must match an H2 heading in `AGENT.generated.md` exactly (case-sensitive, whitespace-normalized).

Example:
- `## Section: Approval Gates` in overrides matches `## Approval Gates` in generated
- `## Section: Cross-Cutting Concerns` in overrides matches `## Cross-Cutting Concerns` in generated

**Issue Type**: `ORPHAN_OVERRIDE`

**Action**: `Review AGENT.overrides.md and remove or rename the orphaned section claim. Check if the section was removed from the-plan.md or if the heading changed.`

### 3. Missing Overrides File Check

**Purpose**: Ensure `x-fine-tuned` flag consistency.

**Logic**:

For each agent:

1. Parse `AGENT.md` frontmatter and check for `x-fine-tuned: true`
2. If flag is present, verify `AGENT.overrides.md` exists
3. If file does not exist, report `MISSING_OVERRIDES_FILE`

**Issue Type**: `MISSING_OVERRIDES_FILE`

**Action**: `Remove x-fine-tuned flag from AGENT.md frontmatter or create AGENT.overrides.md if overrides are intended.`

### 4. Inconsistent Flag Check

**Purpose**: Ensure `x-fine-tuned` flag is set when overrides exist.

**Logic**:

For each agent:

1. If `AGENT.overrides.md` exists, verify `AGENT.md` frontmatter contains `x-fine-tuned: true`
2. If flag is missing or not `true`, report `INCONSISTENT_FLAG`

**Issue Type**: `INCONSISTENT_FLAG`

**Action**: `Run /despicable-lab <agent-name> to regenerate and re-merge (merge process auto-injects x-fine-tuned flag).`

### 5. Frontmatter Consistency Check

**Purpose**: Verify that `AGENT.md` frontmatter reflects the expected shallow merge of generated + override frontmatter.

**Logic**:

For each agent with `AGENT.overrides.md`:

1. Parse `AGENT.generated.md` frontmatter (YAML)
2. Parse `AGENT.overrides.md` frontmatter (YAML, if present)
3. Perform shallow merge: override keys win, non-overlapping keys preserved, auto-inject `x-fine-tuned: true`
4. Parse `AGENT.md` frontmatter
5. Compare computed merge result to actual `AGENT.md` frontmatter
6. If they differ, report `FRONTMATTER_INCONSISTENCY` with details of which keys differ

**Issue Type**: `FRONTMATTER_INCONSISTENCY`

**Action**: `Run /despicable-lab <agent-name> to regenerate and re-merge.`

## Merge Algorithm (for validation)

The script implements the merge algorithm to compute the expected `AGENT.md` for comparison. This is a read-only operation—the script does NOT write merged output.

### Frontmatter Merge

1. Parse `AGENT.generated.md` frontmatter (YAML between `---` delimiters)
2. Parse `AGENT.overrides.md` frontmatter (YAML between `---` delimiters, if present)
3. Shallow merge:
   - Start with all keys from generated frontmatter
   - Override with any keys from overrides frontmatter
   - Auto-inject `x-fine-tuned: true`
4. Result: merged frontmatter object

### Markdown Body Merge

1. Parse `AGENT.generated.md` body (content after closing `---`)
2. Parse `AGENT.overrides.md` body (content after closing `---` if frontmatter exists, else entire file)
3. Extract H2 sections from generated body:
   - A section starts at `^## .+$` and includes all content until the next `^## ` or EOF
   - H3 and below are part of the enclosing H2 section
   - Lines inside fenced code blocks (between triple backticks) are NOT section boundaries
4. Extract H2 sections from overrides body:
   - Same logic as generated
5. For each section in generated:
   - If a matching section exists in overrides (exact heading match), use the override section
   - Otherwise, use the generated section
6. Result: merged body with sections in the order they appear in generated, with override sections replacing generated sections where matches exist

### Section Boundary Detection

**H2 Section Start**: Line matching `^## .+$` that is NOT inside a fenced code block.

**Fenced Code Block**: Region between lines matching `^```[a-z]*$` (opening) and `^```$` (closing). Track fencing state while parsing to avoid false positives.

**Section End**: The next H2 section start OR end-of-file.

**H3 and below**: Lines starting with `### `, `#### `, etc. are part of the enclosing H2 section, NOT separate sections.

### Normalization

Before comparison, normalize both the computed merge and the actual `AGENT.md`:

1. Strip trailing whitespace from all lines
2. Collapse consecutive blank lines to a single blank line
3. Ensure file ends with exactly one newline

## Implementation Notes

### Language

Bash, for consistency with existing scripts in the repository and `/despicable-lab` skill.

### Dependencies

Standard UNIX utilities available on macOS and Linux:
- `bash` (4.0+)
- `grep`, `sed`, `awk`
- `diff` (for comparison)
- YAML parsing: Use a simple regex-based parser for the shallow structure needed (key-value pairs only, no nested structures)

### Performance

The script processes up to 19 agent directories. Expected runtime: under 1 second for all agents. File sizes are small (largest AGENT.md is ~30KB). In-memory processing is sufficient.

### Edge Cases

1. **No AGENT.generated.md**: Pre-overlay agent. Skip merge checks. Only verify `AGENT.md` does not have `x-fine-tuned: true`.

2. **Empty AGENT.overrides.md**: Treat as "no overrides" (same as file not existing).

3. **Malformed YAML frontmatter**: Report as `FRONTMATTER_INCONSISTENCY` with a note that YAML parsing failed.

4. **Section heading appears in code block**: Use fenced code block detection to avoid false positives. Track whether parser is inside a fenced block (between `^```[a-z]*$` and `^```$`).

5. **Multiple sections with same heading**: Undefined behavior in the overlay system (should not occur). If detected, report as `MERGE_STALENESS` with a note about duplicate headings.

6. **Override file claims section with different case**: No match. Report `ORPHAN_OVERRIDE`. Section matching is case-sensitive.

7. **Whitespace differences in headings**: Normalize whitespace (collapse multiple spaces to one, trim leading/trailing) before comparison.

8. **Agent directory without AGENT.md**: Skip with a warning (malformed agent directory).

## Integration with /despicable-lab

The `/despicable-lab --check` command calls `validate-overlays.sh --summary` and parses the output to report drift status.

Expected integration:

```bash
# In /despicable-lab --check logic
drift_output=$(validate-overlays.sh --summary)
if [ $? -eq 1 ]; then
  echo "Overlay drift detected:"
  echo "$drift_output" | grep DRIFT
  echo "Run /despicable-lab <agent-name> to regenerate."
fi
```

## Testing Strategy (for implementer reference)

Testing is Task #3 (separate from implementation). The test suite should include:

1. **Fixture agents**: Mock agent directories with known drift conditions
   - Clean agent (no overrides, files match)
   - Agent with overrides (clean merge)
   - Agent with orphan override
   - Agent with stale merge
   - Agent with missing `x-fine-tuned` flag
   - Agent with `x-fine-tuned` but no overrides file
   - Pre-overlay agent (no AGENT.generated.md)

2. **Test cases**:
   - Verify exit codes (0 for clean, 1 for drift, 2 for error)
   - Verify summary table format
   - Verify detail block format
   - Verify `--summary` flag output
   - Verify single-agent invocation
   - Verify orphan detection
   - Verify frontmatter merge logic
   - Verify section boundary detection (including code blocks)
   - Verify normalization (whitespace, blank lines)

3. **Test harness**: Bash script that sets up fixtures, runs `validate-overlays.sh`, and compares output to expected results.

## Future Enhancements (out of scope)

- `--fix` mode: Automatically re-merge drifted agents
- JSON output for programmatic consumption
- Diff output showing exact line-level differences
- Integration with pre-commit hooks to prevent drift commits

These are deferred. The current scope is detection-only with human-readable output.

## Conclusion

This specification defines a clear interface for detecting overlay drift. The script is a focused, read-only validation tool that integrates with the `/despicable-lab` build system. It provides actionable error messages, supports both human and machine consumption, and handles the edge cases inherent in the overlay system.

The implementer (Task #2) should follow this specification exactly. The tester (Task #3) should verify all checks and output formats against this document.
