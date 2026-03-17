# Phase 3.5 Review -- margo (Simplicity / YAGNI / KISS)

## Verdict: ADVISE

The plan is well-scoped to the original request and the core design decisions (TSV inline, suffix-stripping, majority-wins) are the right simple choices. No unnecessary abstractions, no new dependencies, no framework introductions. The task count (5) is proportional to the change surface (2 shell scripts + 5 documentation files). The approval gate on Task 2 is justified given the blast radius of commit message format decisions.

Three items warrant attention:

---

### Warning 1: Deduplication complexity in track-file-changes.sh (Task 1)

- **SCOPE**: Task 1, dedup logic in `track-file-changes.sh`
- **CHANGE**: The plan proposes per-tuple `(file_path, agent_type)` deduplication using `grep -qF` with a constructed tab-delimited prefix. This replaces the current single-line `grep -qFx "$file_path"` with branching logic (agent_type present vs. absent) and string construction via `printf '%s\t%s'`.
- **WHY**: The added complexity is marginal but the justification is weak. The stated reason -- "same file from different agents should both be recorded" -- describes a scenario that occurs rarely (multiple agents editing the same file in one session) and the consumer (commit-point-check.sh) immediately deduplicates back down to file_path only for staging. The extra ledger entries serve no downstream purpose: the majority-wins scope derivation does not need per-file attribution -- it just counts agent_type occurrences. A simpler approach that still gets correct scope derivation: keep the current `grep -qFx "$file_path"` dedup (one entry per file), and also maintain a separate simple counter -- or even simpler, just let the Stop hook count the first `agent_type` it sees per file. The current plan works correctly; this is a "watch for unnecessary complexity creep" note, not a blocker.
- **TASK**: devx-minion implementing Task 1 should consider whether per-file dedup (current behavior) with the agent_type column appended is sufficient. If the Stop hook's majority-wins logic can work with one entry per file (using the last-writer's agent_type), the dedup logic stays simple.

### Warning 2: Task 5 touches 5 files for documentation consistency

- **SCOPE**: Task 5 (software-docs-minion)
- **CHANGE**: Task 5 updates 5 separate files: SKILL.md, commit-workflow-security.md, DOMAIN.md, deployment.md, decisions.md. This is the most diffuse task in the plan.
- **WHY**: Each individual update is small and justified -- the concern is not scope creep but execution risk. Touching 5 files across different directories increases the chance of inconsistency or partial completion. The plan already acknowledges the "Co-Authored-By specified in 4 locations" drift risk (Risk 4). Adding the Agent trailer to these same locations means the specification surface grows from 4 to 8 touchpoints. This is accidental complexity from documentation duplication, not from this plan specifically, but this plan makes it worse.
- **TASK**: Consider whether the decisions.md entry and the DOMAIN.md update can simply reference `docs/commit-workflow.md` as the canonical format spec rather than repeating the format inline. Single source of truth for the trailer format reduces future drift.

### Warning 3: Test count may be over-specified for a first iteration

- **SCOPE**: Task 3 (test-minion)
- **CHANGE**: 23 test cases for two shell scripts totaling approximately 430 lines of code.
- **WHY**: The test suite is thorough and the cases are well-chosen. However, 23 tests for what is fundamentally "read two extra fields, validate with regex, write a tab-separated line" is on the high side. The validation edge cases (tests 6-9) and dedup cases (10-12) are valuable. The Stop hook tests (17-23) are lighter by design, which is appropriate. This is not a blocker -- comprehensive tests for hooks that silently swallow errors (ERR trap) are genuinely the only safety net, as the plan notes. Just be aware that the test script may end up larger than the code it tests, which is a mild proportionality signal.
- **TASK**: test-minion should prioritize the high-value cases (validation, dedup, backward compatibility, scope derivation) and not pad the script to hit exactly 23 if some cases prove redundant during implementation.

---

No BLOCKs. The plan is proportional to the problem, uses no unnecessary technology or abstraction layers, and the core design decisions favor simplicity correctly. The three items above are watch-points, not obstacles.
