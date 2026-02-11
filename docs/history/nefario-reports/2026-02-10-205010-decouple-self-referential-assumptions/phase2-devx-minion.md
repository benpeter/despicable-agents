# Domain Plan Contribution: devx-minion

## Recommendations

### Question 1: Scratch File and Report Path Architecture

#### (a) Scratch files: target project or global temp location?

**Recommendation: Use a global temp location, not the target project.**

Scratch files are orchestration internals -- they are ephemeral session state, not project artifacts. Putting them in the target project violates separation of concerns: the user did not ask for a `nefario/scratch/` directory in their project, and it creates a cognitive overhead of "what is this directory and do I need to worry about it?" even when gitignored.

The cleanest approach: use the operating system's temp directory, namespaced by session.

```
/tmp/nefario-scratch-{session-id}/{slug}/
  phase1-metaplan.md
  phase2-{agent-name}.md
  ...
```

Key properties:
- **Automatically cleaned on reboot.** No stale scratch directories accumulating in projects.
- **No gitignore pollution.** External projects do not need to add `nefario/scratch/` to their `.gitignore`.
- **Session-isolated.** Using `CLAUDE_SESSION_ID` (or a fallback UUID) prevents cross-session collisions.
- **No greenfield burden.** An empty directory works immediately -- no need to `mkdir -p` inside the project.

The `{session-id}` component is important for parallel orchestration sessions against the same project. Without it, two `/nefario` runs with the same slug would clobber each other.

**Fallback behavior**: If `CLAUDE_SESSION_ID` is not available (defensive coding), generate a random suffix (e.g., `$(date +%s)-$$`). This is a belt-and-suspenders measure -- `CLAUDE_SESSION_ID` is reliably provided by Claude Code.

**Scratch path variable**: Define a single path variable at the top of SKILL.md so every reference can use it:

```
SCRATCH_DIR="/tmp/nefario-scratch-${CLAUDE_SESSION_ID}/${slug}"
```

All 32+ references in SKILL.md change from `nefario/scratch/{slug}/` to `${SCRATCH_DIR}/`. This is a mechanical find-and-replace after the variable is defined.

**Migration for self-evolution mode**: When operating on despicable-agents itself, scratch files also go to `/tmp/`. The current `nefario/scratch/` directory in the repo becomes vestigial -- it can be removed (along with its `.gitkeep` and `.gitignore` entry) as part of cleanup. No backward compatibility concern because scratch files are never committed.

#### (b) Should reports always go into the target project?

**Recommendation: Yes, always write reports into the target project -- but make the path configurable with a sensible default.**

Reports are project artifacts, not tooling internals. They document what happened to the project and why. They should live alongside the code they describe. This is the same principle as ADRs (Architecture Decision Records) or changelogs: the history belongs with the thing it describes.

**Default path**: `docs/nefario-reports/`

Note the simplification from `docs/history/nefario-reports/`. The `history/` nesting adds no value and makes the path longer. For external projects encountering this for the first time, `docs/nefario-reports/` is more intuitive. However, if this naming change is contentious or breaks too many existing references, keeping `docs/history/nefario-reports/` is fine -- the important thing is that the path is cwd-relative.

**Path resolution priority** (first match wins):

1. `NEFARIO_REPORTS_DIR` environment variable (explicit override for CI or custom setups)
2. Existing `docs/nefario-reports/` or `docs/history/nefario-reports/` directory (detect convention already in use)
3. Default: `docs/nefario-reports/` (created with `mkdir -p` on first use)

Step 2 is critical: it means the self-evolution path (despicable-agents operating on itself) continues to work without changes as long as the existing directory exists. And external projects that have already generated reports keep their existing layout.

**Greenfield scenario**: For an empty directory, `mkdir -p docs/nefario-reports/` creates the full path. SKILL.md already uses `mkdir -p` so this works. The first report will create the directory structure.

**Report template path**: The TEMPLATE.md file should NOT be copied into target projects. The SKILL.md contains all the instructions for report generation -- the template is documentation for humans reading the despicable-agents repo. SKILL.md should be fully self-contained regarding report format.

**CI and index generation**: The `build-index.sh` script and GitHub Actions workflow remain in the despicable-agents repo. External projects that want an index can copy the script. This is an opt-in enhancement, not a required component.

#### (c) Cleanest way to make SKILL.md path-agnostic?

**Recommendation: cwd-relative conventions as the primary mechanism, with environment variable escape hatches.**

This follows the configuration hierarchy principle: zero-config works for 80% of users, environment variables serve the remaining 20%.

**Three-layer approach:**

**Layer 1 -- Convention (zero-config):**
- Scratch files: `/tmp/nefario-scratch-${CLAUDE_SESSION_ID}/{slug}/`
- Reports: `docs/nefario-reports/` (relative to cwd, auto-detected or created)
- Git operations: cwd's repository (already works)

This layer requires no configuration. A user runs `/nefario` in any project and everything just works.

**Layer 2 -- Detection (auto-adapt):**
- If `docs/history/nefario-reports/` exists (legacy layout), use it
- If `docs/nefario-reports/` exists (new layout), use it
- If neither exists, create `docs/nefario-reports/`

This layer handles migration and mixed environments without user action.

**Layer 3 -- Environment variables (explicit override):**
- `NEFARIO_REPORTS_DIR` -- override report output directory
- `NEFARIO_SCRATCH_DIR` -- override scratch file location (rare, but useful for debugging)

These are never required. They exist for edge cases: CI pipelines that want reports in a specific location, or debugging sessions that need persistent scratch files.

**Why NOT a config file?** A `.nefario.yml` or similar adds a file to every project, requires a schema, needs documentation, and must be parsed. For two path settings, this is overkill. Environment variables are lighter, universally supported, and already the established pattern in 12-factor tools. If configuration needs grow later, a config file can be added -- but YAGNI says not now.

**Why NOT just environment variables for everything?** Because requiring environment variables to be set before first use fails the zero-config test. Most users should never need to set anything. Environment variables are the escape hatch, not the front door.

**SKILL.md implementation pattern:**

At the top of the SKILL.md (in the "Scratch File Convention" section), define the resolution logic in prose that the LLM can follow:

```
### Path Resolution

At the start of Phase 1, resolve these paths:

1. **Scratch directory**: Use `/tmp/nefario-scratch-${CLAUDE_SESSION_ID}/{slug}/`.
   Override: set NEFARIO_SCRATCH_DIR environment variable.

2. **Report directory**: Check in order:
   a. NEFARIO_REPORTS_DIR environment variable (if set, use it)
   b. `docs/nefario-reports/` relative to cwd (if exists, use it)
   c. `docs/history/nefario-reports/` relative to cwd (if exists, use it -- legacy layout)
   d. Default: create and use `docs/nefario-reports/` relative to cwd

Store both resolved paths in session context for use throughout all phases.
```

This is a "resolve once, use everywhere" pattern. The LLM resolves the paths at Phase 1 and uses them consistently across all 9 phases.

### Question 2: Skill Packaging and Global Distribution

#### (a) Which artifacts are "toolkit" vs "project-specific"?

**Toolkit artifacts** (global, installed once, work everywhere):

| Artifact | Current Location | Install Target |
|----------|-----------------|----------------|
| Agent AGENT.md files (27) | `{agent}/AGENT.md` | `~/.claude/agents/{name}.md` |
| Nefario skill | `skills/nefario/SKILL.md` | `~/.claude/skills/nefario/` |
| Despicable-prompter skill | `.claude/skills/despicable-prompter/` | `~/.claude/skills/despicable-prompter/` |
| Commit workflow hooks | `.claude/hooks/*.sh` | See discussion below |
| Sensitive patterns | `.claude/hooks/sensitive-patterns.txt` | See discussion below |

**Project-specific artifacts** (stay in the despicable-agents repo, never installed globally):

| Artifact | Reason |
|----------|--------|
| `/despicable-lab` skill | Only operates on despicable-agents itself |
| `the-plan.md` | Canonical spec for this project |
| `RESEARCH.md` files | Backing research, not deployed |
| `AGENT.generated.md` / `AGENT.overrides.md` | Build artifacts |
| `docs/` (all documentation) | Project documentation |
| `.github/workflows/` | CI for this repo only |
| `CLAUDE.md` / `CLAUDE.local.md` | Project instructions |

#### (b) Should install.sh grow to install all global components?

**Recommendation: Yes, but with clear sections and an optional uninstall.**

The current `install.sh` already installs agents and the nefario skill. Extending it to also install the prompter skill is a minimal, natural expansion. The script should communicate clearly what it installs:

```
Installing despicable-agents toolkit:
  Agents:  27 agents -> ~/.claude/agents/
  Skills:  /nefario, /despicable-prompter -> ~/.claude/skills/
```

**What install.sh should NOT do**: Install hooks. Hooks are covered in (c) below.

**Uninstall completeness**: The existing `uninstall` command must be updated to also remove the prompter skill symlink. This is a consistency requirement -- if `install` puts it there, `uninstall` must clean it up.

**Output format**: The current output is clear and follows good CLI patterns. Add the prompter entry and keep the style consistent.

#### (c) Should hooks be global install or project-local?

**Recommendation: Keep hooks project-local. Provide a bootstrap command instead of global installation.**

Hooks are inherently project-scoped in Claude Code (they run from `$CLAUDE_PROJECT_DIR/.claude/hooks/`). Installing them globally does not work -- Claude Code discovers hooks from the project's `.claude/settings.json`, not a global location.

The correct approach is a bootstrap command that sets up hooks in a target project:

```bash
./install.sh init-hooks [target-dir]
```

This command would:
1. Create `<target-dir>/.claude/hooks/` if it does not exist
2. Copy `commit-point-check.sh`, `track-file-changes.sh`, and `sensitive-patterns.txt` to that directory
3. Create or merge `<target-dir>/.claude/settings.json` with the hook configuration
4. Set execute permissions on hook scripts

**Why copy, not symlink?** Because hooks need to travel with the project. If hooks were symlinked to the despicable-agents repo, every machine that clones the target project would need despicable-agents installed at the same path. Copying makes the hooks self-contained in the target project.

**Why not global install?** Claude Code's hook system is project-scoped. There is no `~/.claude/hooks/` global hook directory. Even if there were, different projects may need different hook configurations. Project-local is the right boundary.

**Merge behavior for settings.json**: If the target project already has a `.claude/settings.json`, the init-hooks command must merge rather than overwrite. This means reading the existing file, adding the hook entries if not present, and writing back. This is the trickiest part of the implementation but essential for not breaking existing project settings.

**Alternative considered**: A post-install instruction that says "copy these files manually." This fails the time-to-first-success metric -- it adds friction and steps. An automated command is worth the implementation cost.

#### (d) How should external projects opt into report history, CI workflows, etc.?

**Recommendation: Progressive opt-in via convention, not configuration.**

External projects get reports automatically (the nefario skill writes them to `docs/nefario-reports/`). Beyond that, everything is opt-in:

| Feature | Opt-in mechanism | Effort |
|---------|-----------------|--------|
| Execution reports | Automatic (default SKILL.md behavior) | Zero |
| Report index | Copy `build-index.sh` to project, run manually or add to CI | Low |
| Index CI workflow | Copy and adapt `.github/workflows/regenerate-report-index.yml` | Medium |
| Commit workflow hooks | Run `./install.sh init-hooks <project-dir>` | Low |
| Gitignore for scratch | Not needed (scratch is in /tmp/) | Zero |

**No "init" or "eject" ceremony**. The toolkit should work the moment the user runs `/nefario` in a project. Reports appear, scratch files are invisible, hooks are optional. This is the zero-config philosophy applied to project integration.

**Documentation for opt-in features**: A section in the README (or a dedicated `docs/external-projects.md` in the despicable-agents repo) should document these opt-in features clearly. This is the only place that needs to explain the full picture.

## Proposed Tasks

### Task 1: Refactor SKILL.md path resolution

**What to do**: Replace all hardcoded `nefario/scratch/{slug}/` references with temp-directory-based scratch paths, and all `docs/history/nefario-reports/` references with the resolved report directory path. Add the path resolution logic at the top of the SKILL.md.

**Deliverables**:
- Updated `skills/nefario/SKILL.md` with path resolution section and all references updated
- Removal of `nefario/scratch/` directory, `.gitkeep`, and `.gitignore` entry for scratch files

**Dependencies**: Must be done first -- all other tasks depend on the path resolution decision.

### Task 2: Promote despicable-prompter to global skill

**What to do**: Move the despicable-prompter skill from `.claude/skills/despicable-prompter/` to `skills/despicable-prompter/` (alongside the nefario skill in the repo structure). Update `install.sh` to symlink it to `~/.claude/skills/despicable-prompter/`.

**Deliverables**:
- `skills/despicable-prompter/SKILL.md` (moved from `.claude/skills/despicable-prompter/`)
- Updated `install.sh` with prompter installation and uninstallation
- Updated `.claude/skills/despicable-prompter/SKILL.md` -> symlink or removed (replaced by global)

**Dependencies**: None (independent of Task 1)

### Task 3: Add init-hooks bootstrap command to install.sh

**What to do**: Add an `init-hooks` subcommand to `install.sh` that copies hook scripts and settings to a target project directory.

**Deliverables**:
- Updated `install.sh` with `init-hooks [target-dir]` subcommand
- Settings.json merge logic (read existing, add hooks, write back)
- Updated help text showing all commands

**Dependencies**: None (independent of Tasks 1-2)

### Task 4: Update nefario AGENT.md references

**What to do**: Update informational references to `docs/history/nefario-reports/` in `nefario/AGENT.md` to use language that does not assume a fixed path (e.g., "the project's report directory").

**Deliverables**:
- Updated `nefario/AGENT.md` with path-agnostic language

**Dependencies**: Task 1 (path resolution decision must be finalized first)

### Task 5: Update documentation for two-mode model

**What to do**: Update `docs/deployment.md`, `docs/orchestration.md`, and the project README to document the "toolkit for any project" model. Add a section explaining how external projects use despicable-agents.

**Deliverables**:
- Updated `docs/deployment.md` (new section on external project usage)
- Updated `docs/orchestration.md` (updated report path references)
- Updated `CLAUDE.md` (if it contains self-referential assumptions that affect external usage)
- Updated report template path references in `docs/history/nefario-reports/TEMPLATE.md`

**Dependencies**: Tasks 1, 2, 3 (must document the final state, not the intermediate state)

### Task 6: Clean up vestigial self-referential artifacts

**What to do**: Remove `nefario/scratch/` directory and its `.gitkeep`, update `.gitignore` to remove the scratch entry, and verify no remaining hardcoded self-references exist in toolkit artifacts.

**Deliverables**:
- Removed `nefario/scratch/` directory
- Updated `.gitignore` (remove scratch-related entries)
- Audit confirming no remaining self-referential paths in toolkit artifacts

**Dependencies**: Task 1 (scratch files must be moved to /tmp/ first)

## Risks and Concerns

### Risk 1: Scratch file loss on reboot

Using `/tmp/` means scratch files are cleaned on system reboot. If an orchestration is interrupted and the machine reboots, the scratch files are gone. The report's "Working Files" section that copies scratch to a companion directory mitigates this for completed orchestrations. For interrupted ones, the partial report (written at Phase 3) plus git history should provide recovery.

**Mitigation**: Accept this as a tradeoff. Scratch files are debugging aids, not critical data. The session transcript (Claude Code's own conversation log) is the authoritative record.

### Risk 2: CLAUDE_SESSION_ID availability

The temp path depends on `CLAUDE_SESSION_ID` being available. If Claude Code ever changes this environment variable name or stops providing it, the scratch path resolution fails.

**Mitigation**: SKILL.md should include a fallback (timestamp-based random suffix). Document the dependency explicitly.

### Risk 3: settings.json merge complexity

The `init-hooks` command needs to merge into existing `.claude/settings.json` files without breaking them. JSON merge is non-trivial in bash (requires `jq` deep merge).

**Mitigation**: Require `jq` as a prerequisite (already required by the hooks themselves). Use `jq`'s `*` (multiply/merge) operator for deep merge. Test against edge cases: empty file, missing file, existing hooks with different matchers.

### Risk 4: Migration path for existing despicable-agents users

Changing report paths and removing the scratch directory could confuse users who have existing workflows. The detection layer (step 2 in path resolution) handles the report path. But users with scripts that reference `nefario/scratch/` will need to update.

**Mitigation**: The scratch directory was always gitignored and ephemeral. Document the change in the PR description and release notes. No migration script needed.

### Risk 5: Default branch assumption

SKILL.md wraps up with `git checkout main && git pull --rebase`. Not all projects use `main` as their default branch.

**Mitigation**: Replace with a dynamic lookup: `git symbolic-ref refs/remotes/origin/HEAD | sed 's@^refs/remotes/origin/@@'` to detect the default branch. Fall back to `main` if the lookup fails.

## Additional Agents Needed

**test-minion** should be consulted for planning (not just Phase 3.5 review). The specific question: "What is the testing approach for verifying that SKILL.md path resolution works correctly across three scenarios: (1) operating on despicable-agents itself, (2) operating on an external project with existing structure, (3) operating on a greenfield empty directory?" The path resolution logic is the highest-risk change and needs a concrete verification strategy.

The meta-plan already includes test-minion in the cross-cutting checklist, but I recommend elevating it to a full planning consultation because the testing strategy should inform the implementation approach, not just verify it after the fact.

All other specialists identified in the meta-plan (ux-strategy-minion for prompter context, software-docs-minion for documentation) are appropriate. No additional agents beyond test-minion elevation are needed.
