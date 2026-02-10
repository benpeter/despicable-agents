# UX Strategy Review: Decouple Self-Referential Assumptions

## Verdict

**ADVISE**

## Analysis

### Strengths

The delegation plan successfully implements the "no mode switch" principle:
- CWD as the only context (no config files, no flags)
- Environment variables used sparingly for overrides only
- Greenfield scenario properly addressed (git guards, dynamic branch detection, graceful directory creation)
- Path resolution convention is intuitive (detection order: env var > newer convention > legacy > create default)
- Scratch files in `$TMPDIR` keep user's project clean

### Advisory Issues

#### 1. CLAUDE_SESSION_ID fallback discoverability

**Issue**: Scratch path depends on `CLAUDE_SESSION_ID` with timestamp fallback (`$(date +%s)-$$`). Creates two different path patterns users might encounter when debugging.

**Impact**: When users need to find scratch files (failed orchestration, debugging), the fallback pattern is opaque (timestamp is meaningless).

**Recommendation**: Task 2, point 6 already requires showing resolved path in CONDENSE. Emphasize this must show ACTUAL path, not template. Example: `/tmp/nefario-scratch/abc123xyz/slug/` not `$TMPDIR/nefario-scratch/${CLAUDE_SESSION_ID}/slug/`.

#### 2. Report directory creation messaging

**Issue**: First nefario run in greenfield creates `docs/history/` tree with `mkdir -p`. User sees new directories appear in their project without explicit notification.

**Impact**: Adding directories to user's project is significant footprint. User should know when files/directories are created.

**Recommendation**: At wrap-up, if report directory was just created, include single-line note: "Created report directory: docs/history/nefario-reports/". Or show report path in final CONDENSE line. Makes directory creation visible and discoverable.

#### 3. Environment variable discoverability

**Issue**: `NEFARIO_REPORTS_DIR` override exists but only documented in SKILL.md source. External users won't discover it.

**Impact**: Advanced users wanting custom report location (e.g., `.nefario/reports/`) need to know escape hatch exists.

**Recommendation**: In Task 5 (README update), ensure "What Happens in Your Project" section mentions: "Report location can be customized via `NEFARIO_REPORTS_DIR` environment variable."

#### 4. Git initialization guidance for greenfield

**Issue**: When git not detected, warning is passive: "No git repo detected, skipping branch creation." Doesn't guide whether user SHOULD initialize git.

**Impact**: In greenfield scenario, user might want git but hasn't initialized yet. Passive warning doesn't help them opt-in to automatic branching/commits/PR workflow.

**Recommendation**: Make warning actionable: "No git repo detected. Run `git init` if you want automatic branching and commits." Minor copy change in Task 2 git operations section.

## Summary

Core architecture is sound. CWD-relative, convention-based, zero-config, with proper greenfield handling. Advisory recommendations improve discoverability and reduce "where did that come from?" moments. None are blocking.

All issues addressable with minor documentation/messaging additions in already-planned tasks.
