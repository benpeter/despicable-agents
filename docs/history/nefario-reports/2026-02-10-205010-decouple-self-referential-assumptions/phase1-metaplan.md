# Meta-Plan: Decouple Self-Referential Assumptions

## Self-Referential Touchpoint Audit

Before identifying planning consultants, here is the complete inventory of
self-referential touchpoints discovered by reading the codebase. Each touchpoint
is a location where despicable-agents assumes it is both the tooling AND the
target project.

### Category 1: Scratch Files and Report Paths (SKILL.md)

The SKILL.md hardcodes `nefario/scratch/{slug}/` as the scratch directory and
`docs/history/nefario-reports/` as the report output directory. Both are paths
within the despicable-agents repo itself.

**Files**: `skills/nefario/SKILL.md` (32 references to `nefario/scratch`, 33+
references to `docs/history/nefario-reports`)

**Impact**: When operating on an external project, scratch files and reports
would be written into the target project, which is desirable for reports (the
target project should own its history) but NOT for scratch files (orchestration
internals should not pollute the target). Need a clear "scratch = temp/tooling"
vs "reports = target project artifact" split.

### Category 2: Git Operations (SKILL.md)

Phase 4 creates a feature branch (`nefario/<slug>`), runs `git pull --rebase`,
`git checkout -b`, auto-commits, and creates PRs. All git operations
implicitly target the current working directory. When the user invokes
`/nefario` from an external project, git operations should target that
project's repo -- this already works by cwd convention, but the branch
naming assumes a nefario-orchestrated context.

**Files**: `skills/nefario/SKILL.md` (Phase 4, Wrap-up), `docs/commit-workflow.md`

**Impact**: Low risk -- cwd-based git already works. Branch naming is fine.
The main issue is that `git checkout main` at wrap-up assumes `main` is the
default branch (could be `master` or other).

### Category 3: Report Template and CI (TEMPLATE.md, GitHub Actions)

The report template references `docs/history/nefario-reports/` as a fixed path.
The CI workflow (`.github/workflows/regenerate-report-index.yml`) is specific to
the despicable-agents repo. The `build-index.sh` script is repo-specific tooling.

**Files**: `docs/history/nefario-reports/TEMPLATE.md`,
`.github/workflows/regenerate-report-index.yml`,
`docs/history/nefario-reports/build-index.sh`

**Impact**: For external projects, reports should go into the target project but
the CI workflow and index builder would not exist there. Report generation needs
to be self-contained (no CI dependency for basic operation).

### Category 4: Hooks and Settings (.claude/)

The `.claude/settings.json` hooks reference `$CLAUDE_PROJECT_DIR/.claude/hooks/`
which is project-scoped. The hooks (commit-point-check.sh, track-file-changes.sh)
and sensitive-patterns.txt are in the despicable-agents repo's `.claude/` directory.

**Files**: `.claude/settings.json`, `.claude/hooks/commit-point-check.sh`,
`.claude/hooks/track-file-changes.sh`, `.claude/hooks/sensitive-patterns.txt`

**Impact**: When running against an external project, these hooks are only
active if the external project has its own `.claude/settings.json`. The commit
workflow hooks are general-purpose enough to work in any project, but they are
currently deployed only in the despicable-agents repo. This is a packaging
question: should the hooks be part of the toolkit distribution?

### Category 5: Despicable-Lab Skill (project-local)

The `/despicable-lab` skill reads `the-plan.md`, agent directories
(`gru/`, `nefario/`, `lucy/`, `margo/`, `minions/*/`), and
`validate-overlays.sh`. This is correctly self-referential -- it only makes
sense when operating on despicable-agents itself.

**Files**: `.claude/skills/despicable-lab/SKILL.md`

**Impact**: None needed. This skill is correctly scoped to the despicable-agents
project. It should remain project-local.

### Category 6: Despicable-Prompter Skill (project-local but should be global)

The `/despicable-prompter` skill is currently project-local
(`.claude/skills/despicable-prompter/`). It has no project-specific references
in its SKILL.md -- it is a generic briefing coach. But because it is project-local,
it is only available when the user is working inside the despicable-agents repo.

**Files**: `.claude/skills/despicable-prompter/SKILL.md`

**Impact**: Users working on external projects cannot use `/despicable-prompter`.
Per the task description, it should read context from the TARGET project, not
despicable-agents. Solution: make it a global skill (symlinked to
`~/.claude/skills/`).

### Category 7: CLAUDE.md and CLAUDE.local.md

The project CLAUDE.md describes the despicable-agents structure and rules (e.g.,
"Do NOT modify the-plan.md"). When nefario operates on an external project, the
external project's CLAUDE.md should govern -- and it does, because Claude Code
loads CLAUDE.md from the cwd. No action needed.

**Files**: `CLAUDE.md`, `CLAUDE.local.md`

**Impact**: None. This works correctly by cwd convention. But SKILL.md references
`docs/commit-workflow.md` and `docs/orchestration.md` as relative links from the
SKILL.md location, which resolve to the despicable-agents repo, not the target.

### Category 8: nefario/AGENT.md References

The nefario AGENT.md mentions `docs/history/nefario-reports/` in its Final
Deliverables section. When nefario operates on an external project, this
reference should resolve to the target project.

**Files**: `nefario/AGENT.md` (line 649)

**Impact**: Low -- this is informational text telling nefario where reports go.
The SKILL.md drives the actual behavior, so fixing SKILL.md is what matters.

### Category 9: install.sh

The install script symlinks agents and the nefario skill from the repo to
`~/.claude/`. It does NOT install hooks or the despicable-prompter skill.

**Files**: `install.sh`

**Impact**: Medium. install.sh should also install despicable-prompter as a
global skill if we are promoting it. It should also consider whether hooks
should be installable for external projects.

### Category 10: Greenfield (Empty Directory) Scenario

Running nefario against an empty directory would fail because:
- No `.claude/` directory exists (no hooks)
- No `docs/history/nefario-reports/` for reports (SKILL.md `mkdir -p` handles this)
- No `nefario/scratch/` directory (SKILL.md `mkdir -p` handles this)
- Git may not be initialized

The `mkdir -p` calls in SKILL.md handle directory creation. Git initialization
would need to be handled or explicitly documented as a prerequisite.

---

## Planning Consultations

### Consultation 1: Scratch File and Report Path Architecture

- **Agent**: devx-minion
- **Planning question**: The nefario SKILL.md currently hardcodes `nefario/scratch/{slug}/` for orchestration scratch files and `docs/history/nefario-reports/` for execution reports. Both paths live inside the project that invoked nefario. For external projects: (a) should scratch files go into the target project or into a global temp location? (b) should reports always go into the target project? (c) what is the cleanest way to make SKILL.md path-agnostic -- should we use environment variables, a config file, or cwd-relative conventions? Consider the greenfield scenario (empty directory, no existing structure).
- **Context to provide**: `skills/nefario/SKILL.md` (Scratch File Convention, Report Generation sections), `docs/history/nefario-reports/TEMPLATE.md`, the touchpoint audit above
- **Why this agent**: devx-minion specializes in CLI design, configuration patterns, and developer onboarding. The path resolution strategy is fundamentally a developer experience question -- how does the tool discover where to put its artifacts?

### Consultation 2: Skill Packaging and Global Distribution

- **Agent**: devx-minion
- **Planning question**: Currently, despicable-agents has three skills: `/nefario` (global via symlink), `/despicable-lab` (project-local, should stay), and `/despicable-prompter` (project-local, should become global). The `install.sh` script installs agents and the nefario skill but not the prompter or hooks. What is the right packaging model for making despicable-agents a portable toolkit? Consider: (a) which artifacts are "toolkit" vs "project-specific"? (b) should `install.sh` grow to install all global components? (c) should hooks (commit workflow) be part of the global install or remain project-local? (d) how should external projects opt into report history, CI workflows, etc.?
- **Context to provide**: `install.sh`, `.claude/settings.json`, `.claude/hooks/*.sh`, `.claude/skills/despicable-prompter/SKILL.md`, `.claude/skills/despicable-lab/SKILL.md`
- **Why this agent**: devx-minion owns CLI tool design, installation patterns, and developer onboarding flows. This is a distribution and packaging question.

**NOTE**: Both consultations go to devx-minion because they are tightly coupled -- the path resolution strategy directly impacts the packaging model. Keeping them with one agent avoids conflicting recommendations.

### Consultation 3: Context Resolution for Despicable-Prompter

- **Agent**: ux-strategy-minion
- **Planning question**: The `/despicable-prompter` skill coaches users to write good `/nefario` briefings. Currently it is project-local to despicable-agents. When promoted to a global skill, it will be invoked from any project. The skill itself has no project-specific references, but the user experience question is: should `/despicable-prompter` read any context from the target project (CLAUDE.md, README, directory structure) to produce more relevant briefings? Or should it remain a pure input-transformation skill that operates only on the user's text? If it should read context, what is the minimal context set that adds value without over-coupling?
- **Context to provide**: `.claude/skills/despicable-prompter/SKILL.md`, `CLAUDE.md`
- **Why this agent**: ux-strategy-minion specializes in user journey design, cognitive load, and simplification. This is a question about what information improves the user's experience versus what adds complexity without proportional value.

### Cross-Cutting Checklist

- **Testing**: Include test-minion for planning. The decoupling changes will touch hooks (bash scripts), SKILL.md behavior, and install.sh. We need a testing strategy for verifying both modes (self-evolution and external project) work. Planning question: What is the testing approach for verifying a skill works correctly across different project contexts (own repo vs. external repo vs. greenfield)?
- **Security**: Exclude from planning. The changes are structural (path resolution, packaging) not security-sensitive. No new attack surface, auth, or input handling. Security-minion will still review the plan in Phase 3.5.
- **Usability -- Strategy**: ALWAYS include. See Consultation 3 above (ux-strategy-minion). Planning question: What is the optimal user experience for switching between "operate on self" and "operate on external project" modes? Should it be explicit (flag/config) or implicit (detect from context)?
- **Usability -- Design**: Exclude from planning. No user-facing interfaces are being built. The changes are to CLI skills and configuration files.
- **Documentation**: ALWAYS include. Planning question for software-docs-minion: What documentation needs to change to support the "use despicable-agents as a portable toolkit" story? Consider: docs/deployment.md, docs/orchestration.md, README (if it exists), CLAUDE.md, and the report template. What documentation should the toolkit generate in external projects (e.g., a report history README)?
- **Observability**: Exclude from planning. No runtime components are being created. This is a structural refactoring of configuration and paths.

### Anticipated Approval Gates

1. **Path Resolution Strategy** (MUST gate): Hard to reverse, high blast radius. The decision about where scratch files and reports go when operating on external projects will propagate through SKILL.md, AGENT.md, TEMPLATE.md, and all downstream phases. Multiple valid approaches exist (env var, config file, cwd convention, XDG dirs). This must be approved before implementation.

2. **Packaging Model for install.sh** (OPTIONAL gate): Medium reversibility, medium blast radius. The decision about what install.sh installs (just agents? hooks too? prompter?) affects how users adopt the toolkit. Could be gated or handled as a notification.

### Rationale

This task is primarily a **developer experience and architecture** challenge, not a coding challenge. The core question is: how should a toolkit that currently assumes "I am operating on myself" discover and respect the boundary between "tooling project" and "target project"?

devx-minion is the primary specialist because this is fundamentally about CLI tool packaging, configuration, and developer onboarding. ux-strategy-minion adds value because the mode-switching experience (self vs. external) is a usability question. software-docs-minion ensures documentation accurately reflects the new two-mode reality. test-minion provides a testing strategy for multi-context behavior.

Other agents (iac-minion, security-minion, etc.) do not add planning value here -- the changes are structural, not infrastructure or security-related. They will review the plan in Phase 3.5 as mandatory reviewers.

### Scope

**Goal**: Despicable-agents cleanly separates "tooling that operates on any project" from "this project's own structure," so users can apply the agent team to external projects or greenfield directories without self-referential behavior.

**In scope**:
- SKILL.md path resolution for scratch files and reports
- install.sh expansion to cover all global artifacts
- despicable-prompter promotion to global skill
- AGENT.md references to report paths
- Hook packaging decision (project-local vs. global)
- Greenfield scenario support
- Documentation updates for the new two-mode model
- Testing strategy for multi-context verification

**Out of scope**:
- Agent system prompts (domain knowledge content)
- RESEARCH.md files
- the-plan.md
- Despicable-lab skill (correctly project-local)
- CI workflow changes (the GitHub Actions workflow is specific to the despicable-agents repo and should remain so)
- New features beyond what is needed for decoupling
