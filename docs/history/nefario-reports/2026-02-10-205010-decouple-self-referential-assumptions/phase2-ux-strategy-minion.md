# Domain Plan Contribution: ux-strategy-minion

## Recommendations

### 1. Implicit Detection via CWD, Not Explicit Flags

The mode-switching question ("am I operating on myself or on an external project?") should be resolved **implicitly from the working directory**, never through an explicit flag or config toggle.

**Rationale (Jobs-to-be-Done):** The user's job is "get work done on whatever project I'm in." They are not hiring despicable-agents to manage modes. A `--mode=external` flag would violate Krug's "Don't Make Me Think" -- it forces the user to understand an internal architectural distinction that has nothing to do with their task. It is an implementation detail leaking into the user experience.

CWD-based detection already matches the user's mental model: "I'm in ~/myproject, so tools should operate on myproject." This is how every Unix tool works -- `git`, `npm`, `make` all operate on the current directory without requiring "target project" flags. Any deviation from this convention would create cognitive dissonance.

**Specific heuristic:** The skill should resolve context purely from `pwd`. No environment variable, no `.despicable-agents.yml` config file, no `--target` flag. If the user is in `~/github/despicable-agents`, the tool operates on despicable-agents. If in `~/myproject`, it operates on myproject. If in an empty directory, it bootstraps there.

**Why not a config file?** Because config files require the user to know the tool exists before they can use it (violates progressive disclosure), create a chicken-and-egg problem in greenfield scenarios, and add a permanent maintenance burden for a decision that can be inferred 100% of the time.

### 2. Scratch Files: Use OS Temp, Not Target Project

Scratch files are orchestration internals. They belong to the **tooling's process**, not to the **target project's codebase**. Writing `nefario/scratch/` into the target project violates the principle of invisible computing -- the orchestration machinery should not leave traces in the user's project.

**Recommendation:** Write scratch files to a temp location derived from the session:

```
$TMPDIR/nefario-scratch/{slug}/
```

Or, if persistence across sessions matters for debugging:

```
~/.cache/nefario/{slug}/
```

The XDG base directory spec (`$XDG_CACHE_HOME` or `~/.cache`) is the established Unix convention for "data the tool needs but the user doesn't."

**Key UX principle:** The user should never discover scratch files by accident. They should never show up in `git status`, never appear in their file tree, never require a `.gitignore` entry. The current model requires `.gitignore` to hide orchestration internals -- that is the tooling asking the project to accommodate it rather than the tooling accommodating the project.

**Exception for self-evolution:** When operating on despicable-agents itself, the current `nefario/scratch/` location is actually correct because the scratch files document the toolkit's own evolution and are already gitignored. But this should not be special-cased in code -- it should just be the general behavior (temp dir) applied uniformly, with the despicable-agents repo optionally choosing to configure something different if desired.

### 3. Reports: Always Target Project, Created On Demand

Execution reports are project artifacts -- they document decisions made about that project. They should always go into the target project.

**But do not assume a report directory exists.** The skill already uses `mkdir -p`, which is correct. The key UX improvement is: do not assume a `docs/history/nefario-reports/` convention. Use it as a sensible default, but make it discoverable and overridable via the project's own `CLAUDE.md` if the project has a different documentation convention.

**Greenfield consideration:** For an empty directory, writing a report to `docs/history/nefario-reports/` creates a deep directory structure before the user has established any conventions. This could feel presumptuous. Consider either:

- (a) Writing reports to a shallower default (`reports/` or `.nefario/reports/`) and letting projects override, or
- (b) Asking the user at the PR-creation gate (which already exists) whether to include the report, with the default path shown and editable.

I lean toward **(a)** because it avoids adding another decision point to an already decision-rich workflow. The report path is a Kano "must-be" -- it should just work without thought.

### 4. Despicable-Prompter: Read Minimal Context, Not None

The prompter should **read lightweight context from the target project** to produce better briefings. A pure input-transformation skill (no context) would miss easily available information that would make briefs substantially more relevant.

**The minimal context set that adds value:**

1. **README.md** (if exists) -- project name, purpose, 1-2 sentence summary. Allows the prompter to frame outcomes in terms of the actual project rather than generic placeholders.
2. **CLAUDE.md** (if exists) -- project constraints, technology preferences, engineering philosophy. Allows the prompter to pre-populate the Constraints section with real constraints rather than guessing.
3. **Directory listing** (top-level `ls`) -- a scan of what exists. Allows the prompter to scope "In/Out" more accurately (e.g., it can see there's a `src/` directory and a `tests/` directory).

**What NOT to read:**

- File contents beyond README/CLAUDE.md (over-coupling, slow, may hallucinate about code it half-understands)
- Git history (irrelevant to briefing construction)
- Package manifests (too implementation-heavy for intent-focused briefings)
- Nested directory structure (diminishing returns past top-level)

**Cognitive load analysis:** Reading 3 lightweight files adds ~200ms and zero user-facing complexity. The user never sees "reading project context..." -- they just get a better brief. This is calm technology: the skill is more helpful without being more visible.

**Failure mode is benign:** If none of these files exist (greenfield), the prompter falls back to pure input-transformation mode. No error, no warning, no behavioral change the user would notice. Progressive degradation, not progressive disclosure -- the user does not need to know context is being read.

### 5. Mode-Switching Experience: There Is No "Switch"

The most important UX recommendation is: **there should be no perceptible mode switch at all.** The user should never think "I need to switch from self-evolution mode to external-project mode." The tool should simply work wherever it is invoked.

This means:

- No "mode" terminology in documentation or output
- No flags, configs, or environment variables for mode selection
- No behavioral differences the user would notice between "operating on self" and "operating on external"
- Scratch files, reports, git operations, and context resolution all derive from cwd uniformly

The only legitimate difference is that `despicable-lab` is only available when inside the despicable-agents repo (because it is a project-local skill). This is correct and needs no explanation -- it simply does not appear in the skill list when the user is elsewhere.

### 6. Greenfield Scenario: Fail Gracefully, Assume Nothing

For an empty directory:

- **Git not initialized:** The skill should detect this and either initialize git (with user confirmation) or proceed without git operations and warn that commits/branches/PRs will be skipped. Do not fail silently. Do not fail loudly with a stack trace. Fail with one clear sentence: "No git repository found. Commits and PRs will be skipped."
- **No CLAUDE.md:** Proceed without project constraints. Nefario and the prompter both gracefully degrade.
- **No existing structure:** `mkdir -p` handles directory creation. Do not create elaborate scaffolding -- let the execution tasks create what they need.

The greenfield scenario should feel like starting a fresh project with a helpful assistant, not like bootstrapping a framework. Calm technology principle: the tool helps without demanding setup.

## Proposed Tasks

### Task 1: Define Path Resolution Convention in SKILL.md

**What to do:** Replace all hardcoded `nefario/scratch/{slug}/` references in SKILL.md with a temp-directory convention (`$TMPDIR` or `~/.cache/nefario/`). Replace `docs/history/nefario-reports/` with a cwd-relative default that is documented as overridable.

**Deliverables:**
- Updated path convention documented in SKILL.md preamble
- All scratch file references updated
- Report path uses a sensible default with override mechanism

**Dependencies:** Depends on devx-minion's path resolution architecture recommendation. The UX recommendation is "use temp for scratch, cwd-relative for reports" -- the devx-minion will determine the exact mechanism.

### Task 2: Add Lightweight Context Reading to Despicable-Prompter

**What to do:** Add a "Context Discovery" section to the prompter SKILL.md that instructs it to read README.md, CLAUDE.md, and top-level directory listing from the cwd before generating the brief. Make this entirely invisible to the user -- no "reading context..." output. If files are absent, fall back silently to pure input-transformation.

**Deliverables:**
- Updated SKILL.md with context discovery section
- Updated examples showing context-informed output (e.g., project name in outcome, real constraints in Constraints section)

**Dependencies:** Depends on despicable-prompter being promoted to a global skill (install.sh task).

### Task 3: Greenfield Scenario Handling

**What to do:** Add a "Greenfield Detection" section to SKILL.md Phase 4 (or pre-Phase 4) that checks for git initialization, handles the empty-directory case gracefully, and skips git operations with a clear one-line warning when git is not available.

**Deliverables:**
- Greenfield detection logic in SKILL.md
- Clear, minimal user-facing messages for each degraded-mode scenario
- No git? One warning line, skip git ops.
- No CLAUDE.md? Proceed silently.
- No existing docs? Create on demand.

**Dependencies:** None.

## Risks and Concerns

### Risk 1: Scratch File Accessibility for Debugging

Moving scratch files out of the project directory makes them harder to find when debugging a failed orchestration. Currently a developer can `ls nefario/scratch/` to see what happened. With temp files, they would need to know the temp path.

**Mitigation:** Print the scratch directory path once at Phase 1 start (already part of the CONDENSE output pattern). Ensure the wrap-up summary includes the scratch path. For the `~/.cache` option, files persist across sessions, making post-mortem debugging possible.

### Risk 2: Report Path Disagreement Across Projects

Different projects may want reports in different locations. If we default to `docs/history/nefario-reports/`, some projects will find this presumptuous. If we default to something shallow like `.nefario/reports/`, some will want it integrated into their docs structure.

**Mitigation:** Use a sensible default and document how to override via CLAUDE.md. Do not build a config file system for this -- a CLAUDE.md instruction like "Nefario reports go to `docs/adr/`" is sufficient and uses the existing convention.

### Risk 3: Prompter Context Reading Creates Expectation of Project Understanding

If the prompter reads README.md and uses project terminology in the brief, users may expect the prompter to deeply understand their codebase. When it then produces a generic brief for a complex task, the gap between "it knows my project name" and "it doesn't know my architecture" could feel inconsistent.

**Mitigation:** Keep context use extremely shallow -- project name, stated constraints, directory structure for scoping. Do not attempt to infer architecture, purpose, or domain from file contents. The prompter remains an input-transformation skill that happens to know the project's name and declared constraints.

### Risk 4: Self-Evolution Path Regression

The despicable-agents repo currently relies on `nefario/scratch/` being inside the repo (gitignored). Moving to a temp directory changes this for the self-evolution use case too. Developers used to `ls nefario/scratch/` would need to change habits.

**Mitigation:** This is a short-term adjustment. The benefit (clean separation) outweighs the cost (learning the new path). Include the scratch path in the Phase 1 CONDENSE output so it is always discoverable. The `nefario/scratch/` directory can remain in the repo as a historical artifact or be removed with a note in the migration guide.

## Additional Agents Needed

None. The current planning team (devx-minion for architecture/packaging, ux-strategy-minion for experience design, software-docs-minion for documentation, test-minion for verification strategy) covers all necessary perspectives. The metaplan correctly identified the consultants.
