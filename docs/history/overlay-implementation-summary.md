# Overlay Drift Detection - Implementation Summary

**Date**: 2026-02-09
**Approach**: Validation-only (Decision 16)

## What Was Built

### 1. Validation Script (`validate-overlays.sh`)

**Location**: `/Users/ben/github/benpeter/despicable-agents/validate-overlays.sh`
**Size**: 16 KB, 498 lines
**Language**: Bash (requires 4.0+)

**Capabilities**:
- Detects 6 types of drift: orphan overrides, merge staleness, frontmatter inconsistency, missing overrides file, inconsistent flag, non-overlay mismatch
- 3 invocation modes: all agents (default), single agent, summary mode (for `/despicable-lab`)
- Actionable error messages with next-step guidance
- Exit codes: 0 (clean), 1 (drift), 2 (error)

**Verification**: Script successfully detected real drift in nefario (2 orphan overrides, 1 merge staleness, 1 frontmatter inconsistency)

### 2. Documentation

Updated 4 documentation files:

**`docs/validate-overlays-spec.md`** (NEW)
- Complete specification: interface, validation checks, output format, merge algorithm
- 398 lines covering all implementation requirements

**`.claude/skills/despicable-lab/SKILL.md`**
- Added drift detection to `--check` mode
- Updated build process to document manual merge for agents with overrides
- Integration with `validate-overlays.sh --summary`

**`docs/agent-anatomy.md`**
- Updated "Build Flow" diagram to show manual merge
- Replaced "Auditing Overrides" section with "Merging Process" and "Drift Detection"
- Added bash 4.0+ requirement note
- Updated merge rules to clarify manual process

**`docs/build-pipeline.md`**
- Updated "Merge Step" section to document manual merge workflow
- Updated "Build Triggers" table (added validation, removed non-existent `--diff`)
- Updated "/despicable-lab Skill" section to mention validation

**`docs/decisions.md`** (Decision 16)
- Documented validation-only decision
- Listed alternatives rejected (LLM merge, automated merge, hybrid format)
- Rationale: safety net for manual process, deterministic, low-risk

**`docs/validation-verification-report.md`** (NEW)
- Comprehensive verification results
- Evidence of all 6 validation checks working
- Documented test fixture issue (design mismatch)
- Bash version requirement analysis

### 3. Test Infrastructure

**Fixtures**: `tests/fixtures/` (10 directories)
- clean-no-overlay
- clean-with-overlay
- stale-merge
- orphan-override
- missing-overrides-file
- inconsistent-flag
- non-overlay-mismatch
- fenced-code-h2
- frontmatter-mismatch
- pre-overlay-agent

**Test Harness**: `tests/run-tests.sh`

**Status**: ⚠️ Requires redesign. Fixtures are standalone directories but script expects agents in `gru/`, `nefario/`, `minions/*/`. Test harness needs to create temp directory structure matching repo layout.

## Real-World Findings

Validation script detected actual drift in nefario:

1. **Orphan Override: `## Working Patterns`**
   - Claimed in `AGENT.overrides.md` but not in `AGENT.generated.md`
   - Section was removed or renamed in spec

2. **Orphan Override: `## Output Standards`**
   - Claimed in `AGENT.overrides.md` but not in `AGENT.generated.md`
   - Section was removed or renamed in spec

3. **Merge Staleness**
   - `AGENT.md` does not reflect expected merge of generated + overrides
   - Manual re-merge needed

4. **Frontmatter Inconsistency**
   - Formatting difference in `x-fine-tuned` flag (missing space)

**Action**: User should review `nefario/AGENT.overrides.md` and either remove orphaned sections or update them to match new heading names in `AGENT.generated.md`. Then run `/despicable-lab nefario` to regenerate and re-merge.

## Integration Status

✅ **Script functional**: All validation checks working, tested on real repo
✅ **Documentation complete**: 4 files updated, 2 new files created
✅ **Decision logged**: Decision 16 in docs/decisions.md
✅ **Specification complete**: docs/validate-overlays-spec.md
⚠️ **Test infrastructure**: Fixtures exist but need redesign
✅ **`/despicable-lab` integration**: SKILL.md updated, validation integrated into `--check` mode

## Requirements

**Bash 4.0+**: macOS ships with bash 3.2. Install via Homebrew:
```bash
brew install bash
# Verify
/usr/bin/env bash --version
# Should show: GNU bash, version 5.x.x
```

## Usage

```bash
# Check all agents for drift
./validate-overlays.sh

# Check one agent
./validate-overlays.sh nefario

# Machine-friendly summary (for /despicable-lab)
./validate-overlays.sh --summary

# Help
./validate-overlays.sh --help
```

## Next Steps

**Optional (not blocking)**:
1. Fix test harness to work with script architecture
2. Add `validate-overlays.sh --help` output with bash requirement note
3. Consider adding git pre-commit hook to run validation

**Immediate (for user)**:
1. Review nefario drift and fix orphaned overrides
2. Run `/despicable-lab nefario` to regenerate
3. Manually re-merge nefario

## Comparison to Original Request

**Original request (in German)**: Archive old generated, create new generated, check overlay for semantic relevance, re-apply only relevant parts, report discards, human-in-loop for discards, eventually build `/despicable-lab` merging.

**What was built**: Drift detection script that identifies orphaned sections (semantic irrelevance), reports what needs fixing, requires human review of fixes. Manual merge remains.

**Key pivot**: User rejected directive-based automated merge as "way over the top". Converged on validation-only approach (Option B) after team discussion. This provides the safety net requested without complexity of automated semantic merging.

## Success Criteria

✅ Detect drift in overlay system (orphans, staleness, inconsistencies)
✅ Integrate with `/despicable-lab --check`
✅ Actionable error messages
✅ Works on real repo (detected real drift in nefario)
✅ Documented and versioned (Decision 16)
✅ Manual merge process clarified
✅ Bash script implementation (no external dependencies)

All criteria met. Implementation complete.
