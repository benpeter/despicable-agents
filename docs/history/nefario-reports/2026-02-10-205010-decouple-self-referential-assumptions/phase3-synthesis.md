# Delegation Plan: Decouple Self-Referential Assumptions

## Delegation Plan

**Team name**: decouple-toolkit
**Description**: Decouple despicable-agents from self-referential path assumptions so it works as a general-purpose toolkit on any project, including greenfield directories.

---

## Conflict Resolutions

### Report path: `docs/nefario-reports/` vs `docs/history/nefario-reports/`

devx-minion proposed simplifying to `docs/nefario-reports/` (shorter, more intuitive for new users). software-docs-minion's inventory shows all existing docs reference `docs/history/nefario-reports/`. ux-strategy-minion proposed an even shallower default or a `.nefario/reports/` hidden directory.

**Resolution**: Keep `docs/history/nefario-reports/` as the default for new projects. Rationale: (1) changing the path for the despicable-agents repo itself creates unnecessary churn across 10+ documents and CI, (2) the detection layer handles both layouts, (3) the `history/` nesting groups reports alongside other historical artifacts. The detection order is: existing `docs/nefario-reports/` > existing `docs/history/nefario-reports/` > create `docs/history/nefario-reports/`. This preserves backward compatibility while allowing external projects to use either convention.

No `NEFARIO_REPORTS_DIR` environment variable override. YAGNI -- the same reasoning that rejected `NEFARIO_SCRATCH_DIR` applies equally here. If needed later, it is a one-line addition.

### Scratch path: `$TMPDIR` with secure creation

devx-minion recommended `/tmp/nefario-scratch-${CLAUDE_SESSION_ID}/{slug}/`. ux-strategy-minion suggested `$TMPDIR` or `~/.cache/nefario/` (XDG convention). test-minion flagged that convention-over-configuration is more robust than parameterized paths for LLM consumption. security-minion identified symlink attacks, world-readable temp files, and session ID predictability as blocking issues.

**Resolution**: Use `mktemp -d` to create a secure, unpredictable scratch directory. The resulting path is used for all scratch file operations in the session. Rationale: `mktemp -d` atomically creates a directory with a randomized name (no symlink race), and `chmod 700` restricts access to the owning user. The `~/.cache` option was rejected because scratch files are ephemeral session state, not persistent cache. No `NEFARIO_SCRATCH_DIR` override -- YAGNI.

### First-run README in report directory

software-docs-minion proposed a 5-10 line README.md created on first report write. ux-strategy-minion flagged it as potentially intrusive.

**Resolution**: Skip the first-run README. Rationale: (1) the report files themselves contain YAML frontmatter that explains what they are, (2) creating a README in the user's project directory is a footprint decision that should not be made by the toolkit unilaterally, (3) YAGNI -- solve this if users report confusion. The report template's frontmatter and the despicable-agents README are sufficient documentation.

### Prompter context reading

ux-strategy-minion proposed reading README.md, CLAUDE.md, and `ls` from cwd to produce better briefings. This was not in the original devx-minion recommendations.

**Resolution**: Defer to a future task. Rationale: the current task scope is "decouple self-referential assumptions." Adding context reading to the prompter is a feature addition, not a decoupling change. The prompter currently works as a pure input-transformation skill, and promoting it to a global skill is sufficient for this task. Note: global skill promotion satisfies the requirement that the prompter "reads context from the target project" because it runs in the target project's cwd -- Claude Code's own CLAUDE.md loading provides project context naturally.

### Greenfield git handling

ux-strategy-minion recommended graceful degradation when git is not initialized. The current SKILL.md assumes git exists (branch creation, commits, PR).

**Resolution**: Include as a defensive improvement in the SKILL.md refactor (Task 2). The SKILL.md should check for git availability and degrade gracefully: skip branch creation, commits, and PR if no git repo exists, with an actionable warning ("No git repo detected. Run `git init` if you want automatic branching and commits."). This is not a new feature -- it is making the existing workflow robust for the greenfield case.

### `init-hooks` bootstrap command

devx-minion proposed an `init-hooks [target-dir]` subcommand for install.sh. Requires `jq` for settings.json merge.

**Resolution**: Defer. Rationale: (1) hooks are a project-local concern with complex merge semantics, (2) adding `jq` as a dependency contradicts the lightweight philosophy, (3) the current documentation can explain how to manually copy hooks. This can be a follow-up task when demand is established. Keeping scope tight.

### Default branch assumption

devx-minion flagged `git checkout main && git pull --rebase` as assuming `main`. The correct approach is dynamic lookup.

**Resolution**: Include in Task 2 (SKILL.md refactor). Replace `main` with a dynamic lookup using `git symbolic-ref refs/remotes/origin/HEAD`.

### commit-workflow.md references

margo flagged that Task 2's plan to change `docs/commit-workflow.md` references to "See the despicable-agents repository" creates a dangling cross-repo reference.

**Resolution**: Remove the references entirely. The commit workflow is a project-local convention (420 lines, not practical to inline), not a toolkit dependency. The SKILL.md's own commit instructions are self-contained.

---

## Risks and Mitigations

### Risk 1: Scratch file loss on reboot (devx-minion, ux-strategy-minion)
Using `$TMPDIR` means scratch files are cleaned on reboot. Interrupted orchestrations lose their scratch files.
**Mitigation**: Accept the tradeoff. Scratch files are debugging aids. The session transcript is the authoritative record. Completed orchestrations have their scratch files copied to the report companion directory.

### Risk 2: Scratch directory discoverability (ux-strategy-minion)
`mktemp -d` creates a randomized path that users cannot predict.
**Mitigation**: The CONDENSE output in Phase 1 shows the ACTUAL resolved scratch path (not a template). Users can find the path in the session output. This is explicitly required in the Task 2 prompt.

### Risk 3: Self-evolution regression (test-minion -- highest priority)
The most likely failure mode is breaking the despicable-agents-operating-on-itself path.
**Mitigation**: Write regression tests BEFORE making decoupling changes (Task 1 is regression tests). Run them after every change.

### Risk 4: Documentation-implementation drift (software-docs-minion)
Docs describe old paths while code uses new paths during parallel execution.
**Mitigation**: Documentation tasks (Task 4) execute AFTER implementation tasks (Tasks 1-3). Only the additive using-nefario.md update can run in parallel.

### Risk 5: Over-testing natural language instructions (test-minion)
SKILL.md is consumed by an LLM, not a parser. Tests can verify structural properties but not LLM interpretation.
**Mitigation**: Focus tests on concrete filesystem operations and grep-able path patterns, not prose content.

### Risk 6: Sensitive data in companion directories (security-minion)
Scratch files may contain prompts with credentials or API keys. Copying them to the report companion directory (git-tracked) risks committing sensitive data.
**Mitigation**: Add a sanitization/warning step before companion directory copy. Scan for common credential patterns; if found, warn and request confirmation. Explicitly documented in the Task 2 prompt.

---

## Tasks

### Task 1: Write regression tests for self-referential paths
- **Agent**: devx-minion
- **Model**: sonnet
- **Mode**: bypassPermissions
- **Blocked by**: none
- **Approval gate**: no
- **Prompt**: |
    You are writing regression tests BEFORE a decoupling refactor begins. These tests establish the baseline that must continue to pass after changes.

    ## Context
    The despicable-agents project is being decoupled from self-referential path assumptions. Currently, `skills/nefario/SKILL.md` hardcodes `nefario/scratch/{slug}/` for scratch files and `docs/history/nefario-reports/` for reports. The decoupling will move scratch files to `$TMPDIR` and make report paths cwd-relative with detection logic.

    Before any changes, you must write tests that verify the current self-referential behavior works AND that will catch regressions after decoupling.

    ## What to Do

    Create two test scripts:

    **1. `tests/test-no-hardcoded-paths.sh`** -- Static grep test
    Scan deployable toolkit files for hardcoded self-referential paths. This test should FAIL against the current codebase (it documents what needs to change). After decoupling, it should PASS.

    Files to scan:
    - `skills/nefario/SKILL.md`
    - `nefario/AGENT.md`

    Patterns to flag:
    - Literal `nefario/scratch/` (hardcoded scratch path -- should become `$TMPDIR`-based)
    - Literal `docs/history/nefario-reports/TEMPLATE.md` (hardcoded template reference -- should be self-contained)
    - Literal `docs/commit-workflow.md` as a hardcoded path (should be removed)
    - References to `the-plan.md` in skill files (internal project artifact)

    Patterns to ALLOW (not flag):
    - `docs/history/nefario-reports/` as a DEFAULT path in detection logic (this is the convention, not a hardcode)
    - References in project-local skills (`.claude/skills/despicable-lab/`, `.claude/skills/despicable-prompter/`)
    - References in `CLAUDE.md`, `docs/`, `tests/` (project documentation)
    - References in report files under `docs/history/`

    The test should output which patterns were found and in which files. Include a `--expect-fail` flag that inverts the exit code (for running against the pre-decoupling codebase).

    **Also include a report directory detection priority test section:**
    - Create a temp directory with BOTH `docs/nefario-reports/` and `docs/history/nefario-reports/`
    - Verify that a simple detection script selects `docs/nefario-reports/` first (newer convention takes priority over legacy)
    - This validates the detection order convention is unambiguous

    **2. `tests/test-install-portability.sh`** -- Install script test
    Run `install.sh` with a mocked `HOME` directory (temp dir) and verify:
    - All 27 agent symlinks are created in `$HOME/.claude/agents/`
    - The nefario skill symlink is created in `$HOME/.claude/skills/nefario`
    - The despicable-prompter skill symlink is created in `$HOME/.claude/skills/despicable-prompter`
    - All symlinks point to valid files
    - `install.sh uninstall` removes all symlinks
    - After uninstall, no symlinks remain

    Use a temporary HOME to avoid touching the real `~/.claude/`.

    ## What NOT to Do
    - Do not modify any source files -- only create test files
    - Do not write tests that require LLM invocation
    - Do not test the prompter skill content (out of scope for this task)
    - Do not write integration tests that require git operations

    ## Deliverables
    - `/Users/ben/github/benpeter/despicable-agents/tests/test-no-hardcoded-paths.sh` (executable)
    - `/Users/ben/github/benpeter/despicable-agents/tests/test-install-portability.sh` (executable)

    ## Existing Test Patterns
    Follow the style of existing tests at `tests/run-tests.sh` and `tests/test-commit-hooks.sh`. Use bash, set -euo pipefail, color output for pass/fail, exit 0 on success, exit 1 on failure.

    When you finish your task, mark it completed with TaskUpdate and send a message to the team lead summarizing what you produced and where the deliverables are. Include file paths.
- **Deliverables**: `tests/test-no-hardcoded-paths.sh`, `tests/test-install-portability.sh`
- **Success criteria**: Both scripts are executable. The hardcoded-path test fails against current codebase (documenting what needs to change). The detection priority test passes. The install portability test passes against the current install.sh (including prompter expectation once Task 3 completes).

### Task 2: Refactor SKILL.md path resolution
- **Agent**: devx-minion
- **Model**: sonnet
- **Mode**: bypassPermissions
- **Blocked by**: Task 1
- **Approval gate**: yes
- **Gate reason**: This is the highest-risk change. SKILL.md is the operational core of the nefario orchestration. Path resolution affects every phase. Hard to reverse (all scratch and report references change), high blast radius (every downstream task depends on these paths being correct).
- **Prompt**: |
    You are refactoring the nefario SKILL.md to remove all self-referential path assumptions.

    ## Context
    The despicable-agents project currently assumes it operates on itself. The SKILL.md hardcodes `nefario/scratch/{slug}/` for scratch files and references `docs/history/nefario-reports/` for reports. The goal is to make the skill work on ANY project (including greenfield empty directories) while continuing to work on despicable-agents itself.

    ## Path Resolution Convention

    Add a "Path Resolution" section near the top of SKILL.md (after "Scratch File Convention" header, replacing its current content). Define these rules:

    **Scratch directory** (secure creation, mandatory):
    - At Phase 1 start, create with: `SCRATCH_DIR=$(mktemp -d "${TMPDIR:-/tmp}/nefario-scratch-XXXXXX") && chmod 700 "$SCRATCH_DIR"`
    - The `XXXXXX` suffix is randomized by mktemp, preventing symlink attacks and directory enumeration
    - `chmod 700` restricts access to the owning user only
    - All scratch file writes within the session use this resolved path
    - Create a subdirectory for the slug: `mkdir "$SCRATCH_DIR/${slug}"`; use `$SCRATCH_DIR/${slug}/` for all scratch file references throughout the session
    - Lifecycle: cleaned up at wrap-up (see below). Interrupted sessions leave files in temp, cleaned on reboot.

    **Report directory** (cwd-relative detection):
    - Detection order (first match wins):
      1. `docs/nefario-reports/` relative to cwd (if exists)
      2. `docs/history/nefario-reports/` relative to cwd (if exists)
      3. Default: create `docs/history/nefario-reports/` relative to cwd
    - Create with `mkdir -p` on first use
    - When the report directory is first CREATED (not detected), include a single-line note in the wrap-up output: "Created report directory: <path>"

    **Git operations**:
    - Check if cwd is a git repo before branch creation, commits, PR
    - If no git repo: skip branch creation, commits, PR creation. Print: "No git repo detected. Run `git init` if you want automatic branching and commits."
    - Replace `git checkout main && git pull --rebase` with dynamic default branch detection: `git symbolic-ref refs/remotes/origin/HEAD | sed 's@^refs/remotes/origin/@@'`, falling back to `main`

    ## What to Change

    In `skills/nefario/SKILL.md`:

    1. **Replace the "Scratch File Convention" section** with a new "Path Resolution" section containing the rules above, followed by the scratch file directory structure and lifecycle documentation.

    2. **Update ALL references** to `nefario/scratch/{slug}/` throughout the file to use the resolved scratch path. There are ~32+ references. Systematically grep and replace every one. Run `grep -n 'nefario/scratch' skills/nefario/SKILL.md` to find them all. The test from Task 1 (`tests/test-no-hardcoded-paths.sh`) verifies completeness -- run it after changes.

    3. **Update report path references**: Wrap-up step 5 (companion directory) and step 6 (write report) use the resolved report directory. Remove the hardcoded path to `TEMPLATE.md` -- the SKILL.md already contains all report format instructions inline.

    4. **Update git operations**: Add git repo check before branch creation (Phase 4). Replace hardcoded `main` in wrap-up with dynamic default branch. Add graceful skip for commits and PR when no git repo.

    5. **Remove `docs/commit-workflow.md` references**: The two references to this file are project-local conventions, not toolkit dependencies. Remove them entirely.

    6. **Show resolved scratch path in CONDENSE output**: In Phase 1, after resolving paths, the CONDENSE line must include the ACTUAL resolved scratch path (e.g., `/tmp/nefario-scratch-a3F9xK/my-slug/`), not a template with variables.

    7. **Scratch cleanup at wrap-up**: After the companion directory copy step, add: remove the scratch directory (`rm -rf "$SCRATCH_DIR"`). Document that interrupted orchestrations leave scratch files in temp (cleaned on reboot).

    8. **Scratch sanitization before companion copy**: Before copying scratch files to the report companion directory (wrap-up step 5), scan for common credential patterns (`sk-`, `-----BEGIN.*PRIVATE KEY`, long base64 strings). If matches are found, warn the user and request confirmation before copying. Provide option to skip companion directory creation.

    ## What NOT to Change
    - Do not change the report format or template content
    - Do not change the nine-phase structure
    - Do not add new features (context reading, config files, env var overrides)
    - Do not change agent prompts beyond path references
    - Do not modify any files outside of `skills/nefario/SKILL.md`

    ## File to Modify
    `/Users/ben/github/benpeter/despicable-agents/skills/nefario/SKILL.md`

    ## Verification
    After making changes:
    - Run `bash tests/test-no-hardcoded-paths.sh` -- should PASS (no remaining self-referential paths)
    - Grep for remaining `nefario/scratch/` literals to confirm none remain
    - Grep for `NEFARIO_REPORTS_DIR` -- should find zero matches (removed, YAGNI)
    - Grep for `commit-workflow` -- should find zero matches

    When you finish your task, mark it completed with TaskUpdate and send a message to the team lead summarizing what you produced and where the deliverables are. Include file paths.
- **Deliverables**: Updated `skills/nefario/SKILL.md` with all path references decoupled
- **Success criteria**: `tests/test-no-hardcoded-paths.sh` passes for SKILL.md. No literal `nefario/scratch/` in SKILL.md. Report path uses detection logic without env var override. Git operations have greenfield guards. Scratch creation uses `mktemp -d` + `chmod 700`. Scratch cleanup at wrap-up. Sanitization before companion copy. No `commit-workflow.md` references.

### Task 3: Promote despicable-prompter to global skill and update install.sh
- **Agent**: devx-minion
- **Model**: sonnet
- **Mode**: bypassPermissions
- **Blocked by**: none (parallel with Tasks 1, 2)
- **Approval gate**: no
- **Prompt**: |
    You are promoting the despicable-prompter skill from a project-local skill to a globally-installed skill, and updating install.sh to handle it.

    ## Context
    The despicable-prompter skill currently lives at `.claude/skills/despicable-prompter/SKILL.md` (project-local to despicable-agents). For the toolkit to work on any project, the prompter needs to be installed globally alongside the nefario skill.

    This promotion satisfies the requirement that the prompter "reads context from the target project" -- as a global skill, it runs in the target project's cwd, and Claude Code's own CLAUDE.md loading provides project context naturally. No code changes to the prompter are needed.

    ## What to Do

    1. **Move the skill**: Copy `.claude/skills/despicable-prompter/SKILL.md` to `skills/despicable-prompter/SKILL.md` (alongside the existing `skills/nefario/` directory).

    2. **Replace the project-local skill with a symlink**: Remove `.claude/skills/despicable-prompter/SKILL.md` and replace the `.claude/skills/despicable-prompter/` directory with a symlink pointing to `../../skills/despicable-prompter`. This way, the skill still works locally during development via the project-local path, but the source of truth is in the `skills/` directory.

    3. **Update install.sh**:
       - Add despicable-prompter skill installation alongside the nefario skill:
         ```
         ln -sf "${SCRIPT_DIR}/skills/despicable-prompter" "${SKILLS_DIR}/despicable-prompter"
         ```
       - Update the install output to show the prompter:
         ```
         ✓ despicable-prompter skill
         ```
       - Update the uninstall function to remove the prompter symlink (verify it points to our project before removing, same pattern as nefario)
       - Update the help text to mention skills (plural)
       - Update the count to include the prompter

    ## What NOT to Do
    - Do not modify the SKILL.md content (no feature additions)
    - Do not add an `init-hooks` command (deferred)
    - Do not change the agent installation logic
    - Do not add any configuration files

    ## Files to Modify
    - `/Users/ben/github/benpeter/despicable-agents/install.sh`

    ## Files to Create/Move
    - `/Users/ben/github/benpeter/despicable-agents/skills/despicable-prompter/SKILL.md` (moved from `.claude/skills/despicable-prompter/SKILL.md`)

    ## Files to Replace with Symlink
    - `/Users/ben/github/benpeter/despicable-agents/.claude/skills/despicable-prompter` -> `../../skills/despicable-prompter`

    ## Verification
    After making changes:
    - Run `install.sh` and verify the prompter symlink appears at `~/.claude/skills/despicable-prompter`
    - Run `install.sh uninstall` and verify the prompter symlink is removed
    - Verify the `.claude/skills/despicable-prompter` symlink resolves correctly
    - If `tests/test-install-portability.sh` exists, run it to verify (it may need the prompter added to its expectations)

    When you finish your task, mark it completed with TaskUpdate and send a message to the team lead summarizing what you produced and where the deliverables are. Include file paths.
- **Deliverables**: Updated `install.sh`, moved `skills/despicable-prompter/SKILL.md`, symlink at `.claude/skills/despicable-prompter`
- **Success criteria**: `install.sh` installs and uninstalls the prompter skill. The project-local path still works via symlink. Install count is accurate.

### Task 4: Update AGENT.md, CLAUDE.md, documentation, and clean up artifacts
- **Agent**: software-docs-minion
- **Model**: sonnet
- **Mode**: bypassPermissions
- **Blocked by**: Task 2, Task 3
- **Approval gate**: no
- **Prompt**: |
    You are updating all documentation and project metadata to reflect the decoupled toolkit model. The SKILL.md has been refactored (Task 2) and install.sh updated (Task 3). Now everything else needs to match.

    ## Context
    despicable-agents has been decoupled from self-referential path assumptions:
    - Scratch files now use `mktemp -d` in `$TMPDIR` (not `nefario/scratch/`)
    - Report paths are detected cwd-relative (checking `docs/nefario-reports/` then `docs/history/nefario-reports/`, defaulting to creating `docs/history/nefario-reports/`)
    - No `NEFARIO_REPORTS_DIR` env var (YAGNI)
    - install.sh now also installs the despicable-prompter skill
    - Git operations have greenfield guards (graceful skip when no git repo)
    - The default branch is detected dynamically (not hardcoded to `main`)
    - Scratch directories use secure creation (`mktemp -d` + `chmod 700`) and are cleaned up at wrap-up

    ## What to Do

    ### 1. Update `nefario/AGENT.md`
    - Find references to `docs/history/nefario-reports/` and replace with path-agnostic language:
      - "written to `docs/history/nefario-reports/`" -> "written to the project's report directory"
      - "Report template at `docs/history/nefario-reports/TEMPLATE.md`" -> "Report template and format are defined in the nefario SKILL.md"
      - "Report index at `docs/history/nefario-reports/index.md`" -> "Report index is maintained in the project's report directory"
    - Find references to `nefario/scratch/` and update to describe the temp directory convention
    - Keep language concise. The AGENT.md does not need the full resolution logic -- that is in the SKILL.md.

    ### 2. Remove `nefario/scratch/` directory artifacts
    - Delete `nefario/scratch/.gitkeep`
    - Do NOT delete actual scratch files (they are from active orchestrations)

    ### 3. Update `.gitignore`
    - Remove the entries for `nefario/scratch/*` and `!nefario/scratch/.gitkeep`
    - These are no longer needed because scratch files go to `$TMPDIR`

    ### 4. Update `CLAUDE.md`
    - Update the Structure section: change despicable-prompter from "project-local skill" to describe its new location at `skills/despicable-prompter/`
    - Update the Deployment section: `install.sh` now installs 27 agents and 2 skills

    ### 5. Update `README.md`
    Scope: update path references and add brief external-use note. Do NOT restructure the README's audience or reorganize sections.
    - Update the install section to mention: "Installs 27 agents and 2 skills (`/nefario`, `/despicable-prompter`) to `~/.claude/`."
    - Add a brief "Using on Other Projects" note (3-5 lines max) after the install section: explain that after install, agents and skills are available in any Claude Code session. Reports are written to the target project. No configuration required.
    - Update any path references that are now stale

    ### 6. Update `docs/deployment.md`
    - Add a brief "Using the Toolkit" section BEFORE the existing development workflow section
    - What install.sh installs (27 agents, 2 skills, where they go)
    - Explain that hooks are NOT installed globally (project-local; users can copy manually)
    - Rename existing content to "Development Workflow" (for contributors)

    ### 7. Update `docs/orchestration.md`
    Update the 4 hardcoded path references:
    - Section 4 "Report Location and Naming": use path-agnostic language with default noted
    - Section 4 "Index": note that CI/index generation is project-specific
    - Section 5 "Feature Branch Creation": add note about greenfield (git init required)

    ### 8. Update `docs/compaction-strategy.md`
    Update Section 2 "Directory Structure" to reflect the new scratch path (`$TMPDIR`-based via `mktemp -d` instead of `nefario/scratch/{slug}/`)

    ### 9. Update `docs/architecture.md`
    Add one sentence to the opening paragraph: "The team operates on any project via Claude Code -- agents and skills are installed globally and invoked from the target project's working directory."

    ### 10. Update `docs/using-nefario.md`
    Add a brief section clarifying that nefario operates on whichever project the user's working directory is in. Reports, branches, and commits target the cwd project.

    ### 11. Add decision entry to `docs/decisions.md`
    Add a new decision documenting the decoupling:
    - Decision: Decouple toolkit from self-referential path assumptions
    - Context: Project assumed it operated on itself
    - Choice: CWD-relative paths with detection logic, scratch to temp with secure creation
    - Alternatives rejected: Config file (YAGNI), mode flags (leaks implementation), fixed paths (breaks portability), env var overrides (YAGNI)

    ## What NOT to Do
    - Do not create new documentation files
    - Do not modify SKILL.md or install.sh (already done in Tasks 2, 3)
    - Do not restructure the docs/ directory
    - Do not restructure the README's audience or move sections around
    - Do not add extensive "toolkit user guide" content -- keep it lean
    - Do not change the AGENT.md system prompt logic or capabilities

    ## Files to Modify
    - `/Users/ben/github/benpeter/despicable-agents/nefario/AGENT.md`
    - `/Users/ben/github/benpeter/despicable-agents/.gitignore`
    - `/Users/ben/github/benpeter/despicable-agents/CLAUDE.md`
    - `/Users/ben/github/benpeter/despicable-agents/README.md`
    - `/Users/ben/github/benpeter/despicable-agents/docs/deployment.md`
    - `/Users/ben/github/benpeter/despicable-agents/docs/orchestration.md`
    - `/Users/ben/github/benpeter/despicable-agents/docs/compaction-strategy.md`
    - `/Users/ben/github/benpeter/despicable-agents/docs/architecture.md`
    - `/Users/ben/github/benpeter/despicable-agents/docs/using-nefario.md`
    - `/Users/ben/github/benpeter/despicable-agents/docs/decisions.md`

    ## Files to Delete
    - `/Users/ben/github/benpeter/despicable-agents/nefario/scratch/.gitkeep`

    ## Verification
    - Run `tests/test-no-hardcoded-paths.sh` to verify AGENT.md passes
    - Grep CLAUDE.md for stale references to "project-local" prompter or "1 skill"
    - Verify all doc cross-references still resolve

    When you finish your task, mark it completed with TaskUpdate and send a message to the team lead summarizing what you produced and where the deliverables are. Include file paths.
- **Deliverables**: Updated `nefario/AGENT.md`, `.gitignore`, `CLAUDE.md`, `README.md`, `docs/deployment.md`, `docs/orchestration.md`, `docs/compaction-strategy.md`, `docs/architecture.md`, `docs/using-nefario.md`, `docs/decisions.md`, removed `.gitkeep`
- **Success criteria**: `tests/test-no-hardcoded-paths.sh` passes for AGENT.md. No self-referential scratch or report path assumptions in AGENT.md. `.gitignore` no longer references `nefario/scratch/`. CLAUDE.md reflects current prompter location and install count. README has brief external-use note without audience restructuring. All doc cross-references resolve.

---

## Cross-Cutting Coverage

| Dimension | Coverage | Justification |
|-----------|----------|---------------|
| **Testing** | Task 1 writes regression + detection priority tests. Phase 6 post-execution will run them. | Regression tests before changes (Task 1), verification after. |
| **Security** | Task 2 incorporates all four security-minion requirements: secure scratch creation (mktemp + chmod 700), no env var path injection (NEFARIO_REPORTS_DIR removed), scratch sanitization before companion copy, scratch cleanup at wrap-up. | security-minion BLOCK resolved by incorporating all mitigations into Task 2 prompt. |
| **Usability -- Strategy** | Core design principle: no mode switch, CWD is context, zero-config. Resolved path in CONDENSE, report directory creation notification, actionable git warning. | ux-strategy-minion's recommendations are the architectural foundation + UX polish incorporated. |
| **Usability -- Design** | No UI changes. | No user-facing interfaces are produced. |
| **Documentation** | Task 4 covers all documentation updates (merged from original Tasks 4+5, expanded with CLAUDE.md). | AGENT.md, CLAUDE.md, README, deployment, orchestration, compaction, architecture, using-nefario, decisions all updated. |
| **Observability** | No runtime components produced. | No services, APIs, or background processes. |

## Architecture Review Agents

- **Always**: security-minion, test-minion, ux-strategy-minion, software-docs-minion, lucy, margo
- **Conditional**: none triggered (no runtime components, no UI, no web-facing components)

## Revision History

This plan was revised to address Phase 3.5 review findings:

**BLOCK resolved (security-minion):**
- Scratch creation changed from `mkdir -p` to `mktemp -d` + `chmod 700` (symlink attack, world-readable files)
- `NEFARIO_REPORTS_DIR` env var removed entirely (eliminates arbitrary write vector; also YAGNI per lucy + margo)
- Scratch sanitization before companion directory copy added to Task 2
- Scratch cleanup at wrap-up added to Task 2

**ADVISE incorporated (lucy):**
- `NEFARIO_REPORTS_DIR` removed (ADVISE-2)
- README scope constrained to path updates + brief note, not audience restructuring (ADVISE-3)
- CLAUDE.md added to Task 4 update list (ADVISE-5)
- Prompter context satisfaction clarified in Task 3 prompt and conflict resolution (ADVISE-1)

**ADVISE incorporated (margo):**
- `NEFARIO_REPORTS_DIR` removed (same as lucy)
- Task 6 eliminated: detection priority test merged into Task 1; scenario tests dropped (testing bash, not toolkit)
- Task 2 prompt shortened from ~90 lines to ~60 lines (trust agent + test)
- commit-workflow.md references: remove entirely instead of dangling cross-repo reference

**ADVISE incorporated (ux-strategy-minion):**
- CONDENSE output shows resolved scratch path (Task 2, item 6)
- Report directory creation notification added (Task 2, report directory section)
- Actionable git warning wording specified ("Run `git init` if...")

**Structural changes:**
- Old Tasks 4 (AGENT.md cleanup) and 5 (docs) merged into new Task 4 (all docs + cleanup) assigned to software-docs-minion
- Old Task 6 (portability smoke tests) eliminated; detection priority test merged into Task 1
- Plan reduced from 6 tasks to 4 tasks

## Execution Order

```
Batch 1 (parallel, no dependencies):
  Task 1: Write regression tests + detection priority test
  Task 3: Promote despicable-prompter + update install.sh

  --- no gate ---

Batch 2 (after Task 1):
  Task 2: Refactor SKILL.md path resolution

  --- APPROVAL GATE: SKILL.md path refactor ---

Batch 3 (after Task 2 + Task 3):
  Task 4: Update AGENT.md, CLAUDE.md, documentation, clean up artifacts
```

**Gate count: 1** (SKILL.md path refactor). This is well within the 3-5 budget. Only one gate because:
- Task 1 (tests) is a safety net, not a decision point
- Task 3 (prompter promotion) is low-risk, additive, easily reversed
- Task 4 (docs + cleanup) is non-code, follows from Task 2 decisions, easily revised

## Verification Steps

After all tasks complete:
1. Run `tests/test-no-hardcoded-paths.sh` -- should PASS (all self-referential paths removed from toolkit artifacts, detection priority verified)
2. Run `tests/test-install-portability.sh` -- should PASS (install/uninstall works with prompter)
3. Run existing `tests/run-tests.sh` -- should PASS (no regressions in overlay validation)
4. Run existing `tests/test-commit-hooks.sh` -- should PASS (hooks unchanged)
5. Manual verification: skim SKILL.md for any remaining `nefario/scratch/` literals
6. Manual verification: grep SKILL.md for `NEFARIO_REPORTS_DIR` (should be zero)
7. Manual verification: grep SKILL.md for `commit-workflow` (should be zero)
8. Manual verification: review README.md for brief, non-restructured external-use note
