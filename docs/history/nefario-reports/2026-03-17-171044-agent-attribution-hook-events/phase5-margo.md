# Phase 5 Review: margo (Simplicity / YAGNI / KISS)

## Verdict: ADVISE

The changes are proportional to the problem (surfacing agent attribution from
hook events into commit messages). The core mechanism -- extending the TSV
ledger with two optional columns, deriving scope via suffix-stripping, and adding
`Agent:` trailers -- is straightforward and avoids new dependencies or
abstractions. Three non-blocking concerns below.

---

### Finding 1: test-hooks.sh is 479 lines of hand-rolled test framework

**File**: `.claude/hooks/test-hooks.sh`

**What is complex**: The test file reimplements test infrastructure from scratch:
setup/teardown with temp dirs, pass/fail counters, reporting, git repo
scaffolding helpers. 25 tests across 479 lines. Each test creates its own
session ID, ledger, and (for commit-hook tests) a disposable git repository
with tracked files, initial commits, and dirty working state.

**Why it appears accidental**: The git repo scaffolding (lines 301-338) is
duplicated conceptually in every commit-hook test -- each test calls
`make_git_repo`, sometimes adds extra files, commits, and modifies. This is
fine for a handful of tests but will scale poorly. More importantly, bash is
a fragile test medium: no assertion library, no diff on failure, no isolation
between tests beyond naming conventions.

**Assessment**: For 25 tests of two shell scripts, this is acceptable
complexity. The tests cover real concerns (TSV column counts, injection
validation, deduplication, scope derivation, tie-breaking). The alternative --
no tests, or pulling in bats/shunit2 -- would either lose coverage or add a
dependency. This is proportional *today*.

**Recommendation (non-blocking)**: Monitor test count. If this file grows past
~40 tests or 700 lines, extract the git-repo scaffolding into a shared
`test-helpers.sh` and consider migrating to `bats-core` (boring technology,
GA since 2017, zero runtime dependencies beyond bash). Do not act on this
now -- YAGNI applies until pain materializes.

---

### Finding 2: Majority-wins scope derivation in commit-point-check.sh adds
cognitive complexity for a rare case

**File**: `.claude/hooks/commit-point-check.sh` (lines 255-275)

**What is complex**: The hook iterates all agent types from the ledger, counts
file attributions per agent, selects the majority-wins agent with alphabetical
tie-breaking, then strips `-minion` to derive a commit scope. This is 20 lines
of associative-array logic in bash for a value that appears in a single
conventional-commit parenthetical.

**Why it appears accidental**: In practice, single-agent sessions produce one
agent type, and orchestrated sessions bypass this hook entirely (nefario status
file triggers early exit at line 142). The majority-wins logic will almost never
fire in the Stop hook path. The SKILL.md auto-commit instructions duplicate
the same majority-wins rule for orchestrated sessions, but that is prose
instructions to Claude, not code -- so the duplication is structural, not
copy-paste.

**Assessment**: The logic is correct and tested (Tests 21-23). It adds ~20 lines
and uses bash associative arrays, which are supported in bash 4+ (already a
prerequisite). The cognitive complexity increment is modest. Removing it would
mean the Stop hook cannot produce scoped commit messages, which would make
single-agent commits inconsistent with orchestrated commits.

**Recommendation (non-blocking)**: Accept as-is. The consistency argument
(single-agent and orchestrated commits use the same scope convention) justifies
the complexity. If a future simplification opportunity arises, consider whether
single-agent sessions even need scoped commits -- they could use bare
`<type>: <summary>` without scope. But that is a product decision, not a
complexity concern.

---

### Finding 3: commit-workflow-security.md Section 3 documents a pattern not
used in the changed files

**File**: `docs/commit-workflow-security.md` (lines 105-148, "The `exec @ARGV`
Perl Timeout Pattern")

**What is complex**: This section documents the security properties of a
`perl -e 'alarm 5; exec @ARGV'` timeout pattern in detail (how it works, why
it is safe, recommendations). This pattern does not appear in
`track-file-changes.sh` or `commit-point-check.sh`. The hooks use Claude Code's
built-in `timeout` field in the settings.json hook configuration instead.

**Why it appears accidental**: Documenting security properties of unused code
is speculative documentation -- it pays cognitive cost on every read without
providing value for the current implementation. If the pattern is used
elsewhere in the project, it belongs in a general security patterns doc, not
the commit-workflow-security assessment.

**Assessment**: This section predates the current changes (it was likely written
during the original commit-workflow design). Its presence in the security doc
is not harmful but adds ~45 lines of content that a reader must mentally skip
when reviewing the commit workflow's actual security properties.

**Recommendation (non-blocking)**: If Section 3 documents a pattern used
elsewhere in the project, move it to a shared security patterns document. If
it documents a pattern that was considered and rejected, add a note saying so.
If it is purely speculative ("we might use this someday"), remove it per YAGNI.
Low priority.

---

### Complexity Budget Tally

| Item | Type | Cost |
|------|------|------|
| TSV ledger format extension | Code change | 0 (incremental, no new abstraction) |
| Agent metadata validation (regex) | Code change | 0 (4 lines, essential for security) |
| Majority-wins scope derivation | Code change | 1 (new logic for rare path) |
| `Agent:` trailer generation | Code change | 0 (3 lines, straightforward) |
| test-hooks.sh (new) | Test file | 1 (hand-rolled framework, proportional today) |
| Decision 32 in decisions.md | Documentation | 0 (compact, well-justified) |
| SKILL.md auto-commit updates | Documentation | 0 (4 lines of prose change) |
| DOMAIN.md commit conventions section | Documentation | 0 (reference to canonical doc) |
| **Total** | | **2** |

Total complexity spend of 2 is well within budget for a feature that touches
two shell scripts, a test file, and four documentation files. No new
dependencies, no new abstraction layers, no new services.
