# Domain Plan Contribution: test-minion

## Recommendations

### 1. Testing Strategy for Skill Portability

The core testing challenge here is that the nefario SKILL.md is a natural-language instruction file consumed by an LLM, not executable code. This limits what automated tests can verify directly. The testing strategy should operate at three levels:

**Level 1: Static analysis (fast, automated, run in CI)**
Verify that skill files and install scripts contain no hardcoded references to despicable-agents-specific paths or structures. This is the highest-value, lowest-cost test tier.

**Level 2: Structural validation (fast, automated, run in CI)**
Verify that the path resolution patterns used in SKILL.md are parameterized (or parameterizable), that the install script works in clean environments, and that the directory structures the skill expects can be created from scratch.

**Level 3: Smoke tests against real directory layouts (medium speed, automated)**
Create temporary directories mimicking the three target scenarios (self-repo, external project, greenfield) and validate that the concrete artifacts (scratch directories, report directories, gitignore patterns) can be created and function correctly.

Full end-to-end testing of nefario running against a temp directory is not practical as an automated test -- it would require LLM invocation and would be slow, expensive, and non-deterministic. Reserve that for manual acceptance testing.

### 2. What the SKILL.md Hardcodes Today

After reading `skills/nefario/SKILL.md` thoroughly, the self-referential assumptions fall into these categories:

| Hardcoded Pattern | Where in SKILL.md | Nature of Assumption |
|---|---|---|
| `nefario/scratch/{slug}/` | Lines 79-131, throughout | Scratch dir is always at repo-root `nefario/scratch/` |
| `docs/history/nefario-reports/` | Lines 1041-1065 | Reports dir is always at repo-root `docs/history/nefario-reports/` |
| `docs/history/nefario-reports/TEMPLATE.md` | Line 1008 | Template lives in target project |
| `docs/history/nefario-reports/build-index.sh` | Referenced in TEMPLATE.md | Index builder is in target project |
| `docs/commit-workflow.md` | Lines 655, 924 | Commit workflow doc is in target project |
| `git checkout main && git pull --rebase` | Line 1061 | Always returns to `main` branch |
| `nefario/<slug>` branch prefix | Line 525 | Branch naming assumes nefario context |
| `.gitignore` for `nefario/scratch/` | `.gitignore` line 12 | Target project gitignores nefario scratch |

The `.claude/skills/despicable-lab/SKILL.md` and `.claude/skills/despicable-prompter/SKILL.md` are project-local skills that are appropriately self-referential -- they only operate on despicable-agents itself and should stay that way.

### 3. Path Resolution Testing Approach

For each of the three scenarios:

**(a) Self-repo (despicable-agents operating on itself)**

This is the regression scenario. The test verifies that after decoupling, the self-evolution workflow still works -- nefario can still generate reports into `docs/history/nefario-reports/`, use `nefario/scratch/` for working files, and the build-index script still functions.

Test approach: Run existing tests (`tests/run-tests.sh`, `tests/test-commit-hooks.sh`) and add a new test that validates the report and scratch directory structures exist and are properly gitignored.

**(b) External existing project**

The skill needs to resolve scratch and report directories relative to the target project, not relative to the despicable-agents repo. The decoupled SKILL.md should use working directory (cwd) as the base for all path resolution.

Test approach: Create a temp directory with a git repo, run the directory/file creation steps that SKILL.md specifies (mkdir for scratch, mkdir for reports), and verify the paths resolve correctly. No need to invoke the LLM -- just test the structural assumptions.

**(c) Greenfield (empty directory)**

Same as (b) but with no existing git history, no `.gitignore`, no `docs/` directory. The skill must handle creating all structures from scratch.

Test approach: Create an empty temp directory, `git init`, and verify that all mkdir/touch operations succeed. Verify that the gitignore entries needed for scratch files are documented (or that the skill instructs their creation).

### 4. Hardcoded Path Detection Test

This is the single highest-value automated test. A grep-based scan that fails CI if forbidden patterns appear in deployable files.

What to scan:
- `skills/nefario/SKILL.md` -- the main deployable skill
- `nefario/AGENT.md` -- the deployable agent
- `install.sh` -- the deployment script

What to flag:
- Literal `nefario/scratch/` (should become a parameterized or cwd-relative pattern)
- Literal `docs/history/nefario-reports/` (should become configurable)
- Literal `docs/commit-workflow.md` (should become a conditional reference)
- References to `the-plan.md` in skill files (that is despicable-agents internal)
- References to `despicable-agents` as a hardcoded path component
- References to specific agent directories (`gru/`, `lucy/`, `margo/`, `minions/`) in the skill file

What NOT to flag:
- References within project-local skills (`despicable-lab`, `despicable-prompter`) -- these are intentionally self-referential
- References in `CLAUDE.md` -- project documentation is allowed to reference its own structure
- References in `docs/` -- documentation is self-referential by nature
- References in existing report files under `docs/history/` -- these are historical artifacts

### 5. Regression Tests for Self-Evolution

The self-evolution path (despicable-agents operating on itself) needs explicit regression coverage:

1. **install.sh test**: Run `./install.sh` in a temp HOME directory, verify symlinks are created at expected locations. Run `./install.sh uninstall`, verify symlinks are removed. This test already partially exists in concept but should be formalized.

2. **build-index.sh test**: Run the index builder against a set of test report files, verify it produces valid markdown output. This script has no tests today.

3. **validate-overlays.sh test**: Already covered by `tests/run-tests.sh` with 10 fixtures. This is the most mature test suite in the project.

4. **commit-hooks test**: Already covered by `tests/test-commit-hooks.sh` with 18 tests.

5. **Skill self-reference test**: New test that verifies `SKILL.md` can reference its own project structure when cwd IS the despicable-agents repo. After decoupling, the skill should work via cwd-based resolution, and operating on itself becomes just another case of "cwd is an existing project."

### 6. Smoke Test Against Temp Directory

A smoke test that exercises the structural operations (not LLM operations) from SKILL.md against a temp directory would provide high confidence. This test would:

1. Create a temp directory with `git init`
2. Execute the mkdir commands the skill uses: `mkdir -p <scratch-dir>/<slug>/`
3. Verify the directory was created
4. Simulate writing a scratch file
5. Execute the report directory creation: `mkdir -p <report-dir>/`
6. Verify the directory was created
7. Simulate writing a report file with YAML frontmatter
8. Run `build-index.sh` against the report directory (if the index builder is also decoupled)
9. Verify the index was generated
10. Clean up

This is NOT an end-to-end nefario run. It validates the filesystem operations the skill depends on. It runs in under 2 seconds.

A full nefario smoke test (spawning the LLM against a temp directory) should be documented as a manual acceptance test procedure, not an automated test. The cost (LLM API calls, non-determinism, execution time) does not justify automation.

## Proposed Tasks

### Task 1: Create hardcoded-path detection test

**What**: Write a bash test script (`tests/test-no-hardcoded-paths.sh`) that greps deployable skill and agent files for self-referential path patterns. Fails if any are found.

**Deliverables**:
- `tests/test-no-hardcoded-paths.sh` -- the test script
- Allowlist file or inline exceptions for patterns that are legitimately self-referential (project-local skills)

**Dependencies**: Must run AFTER the paths in SKILL.md are decoupled (otherwise this test will fail by design, which is fine -- it can be written first as a "red" test that documents what needs to change).

**Patterns to detect** (initial set, refined during implementation):
```
# In skills/nefario/SKILL.md and nefario/AGENT.md:
nefario/scratch/          # hardcoded scratch path
docs/history/nefario-reports/  # hardcoded report path
docs/commit-workflow.md   # hardcoded doc reference
the-plan.md               # internal project file reference
```

### Task 2: Create structural smoke test for three project contexts

**What**: Write a bash test script (`tests/test-skill-portability.sh`) that creates three temporary directory layouts and validates that the filesystem operations SKILL.md depends on work correctly in each context.

**Deliverables**:
- `tests/test-skill-portability.sh`

**Dependencies**: Depends on the decoupled path resolution design being finalized (Task 1 from another specialist defines what the new paths look like). Can be written in parallel with the path decoupling work if the target path scheme is agreed upon.

**Test scenarios**:
1. Self-repo: clone or symlink the despicable-agents repo into a temp dir, verify scratch and report dirs resolve
2. External project: create a temp dir with `git init`, existing `package.json`, verify scratch and report dirs resolve
3. Greenfield: create an empty temp dir with `git init`, verify scratch and report dirs resolve

### Task 3: Add install.sh portability test

**What**: Write a test that runs `install.sh` with a mocked HOME directory to verify symlink creation works regardless of the repo location on disk.

**Deliverables**:
- Test function added to existing test suite or new `tests/test-install.sh`

**Dependencies**: None. Can be written against the current install.sh.

### Task 4: Add build-index.sh test

**What**: Write a test for the report index builder script using synthetic report fixtures.

**Deliverables**:
- `tests/test-build-index.sh` with 3-5 fixtures covering: valid v2 report, valid v1 (legacy) report, report with missing frontmatter (should warn and skip), empty reports directory

**Dependencies**: None. Can be written against the current build-index.sh.

### Task 5: Document manual acceptance test procedure for nefario-against-temp-dir

**What**: Write a manual test runbook that a human can follow to verify nefario works end-to-end against a non-despicable-agents project.

**Deliverables**:
- Section in `tests/README.md` or standalone `tests/MANUAL-ACCEPTANCE.md`

**Dependencies**: Depends on the decoupling being complete. This is the final validation step.

## Risks and Concerns

### Risk 1: Over-testing natural language instructions

SKILL.md is consumed by an LLM, not by a parser. There is a risk of writing tests that validate structural properties of the markdown but miss the actual failure mode (the LLM misinterpreting ambiguous instructions). Mitigation: focus tests on concrete filesystem operations and path patterns, not on the prose content.

### Risk 2: Hardcoded path detection false positives

The detection test may flag legitimate references. For example, `nefario/scratch/` appears in `.gitignore` and in documentation -- those are not bugs, they are correct references to the project's own structure. Mitigation: the test should have a clear allowlist mechanism, and the allowlist should be minimal and documented.

### Risk 3: Test maintenance burden from three-context testing

Testing three directory layouts triples the surface area. If the path resolution scheme changes, all three tests break. Mitigation: use a single test function parameterized over the three contexts. Keep test setup minimal -- do not replicate full project structures, only the parts the skill touches.

### Risk 4: Self-evolution regression during decoupling

The highest-probability failure mode is breaking the self-evolution path (despicable-agents operating on itself) while decoupling for external use. Mitigation: write the self-evolution regression tests FIRST, before any decoupling changes begin. Run them after every change.

### Risk 5: SKILL.md path variables not being resolved at runtime

If the decoupling introduces variables like `{scratch_dir}` or configuration lookups, there is no guarantee the LLM will resolve them correctly across different Claude Code versions or session types. Mitigation: prefer convention over configuration. A simple rule like "scratch directory is always `.nefario/scratch/` relative to cwd" is more robust than a configurable path.

## Additional Agents Needed

**devx-minion** should contribute to the question of what the decoupled path conventions should look like. The test strategy depends on knowing what the target state is -- I can write tests that verify absence of hardcoded paths, but the devx-minion should define what the replacement convention is (e.g., `.nefario/` in project root, XDG-style config, environment variables).

If devx-minion is already in the planning set, no additional agents are needed. If not, they should be added.
