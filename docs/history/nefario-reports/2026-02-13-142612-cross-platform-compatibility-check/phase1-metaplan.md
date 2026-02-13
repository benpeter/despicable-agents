# Phase 1: Meta-Plan -- Cross-Platform Compatibility Check

## Task Summary

Audit all executable artifacts in despicable-agents (shell scripts, hook scripts,
SKILL.md bash snippets, deployment model) for cross-platform compatibility across
macOS, Linux, and Windows. Determine current platform support status. Produce:
1. An assessment of what works/breaks on each platform
2. Documentation disclaimers for current platform specificity
3. Documentation of required command-line tools with install instructions
4. A roadmap for achieving cross-platform stability

## Scope

**In scope:**
- `install.sh` (deployment script)
- `.claude/hooks/track-file-changes.sh` (PostToolUse hook)
- `.claude/hooks/commit-point-check.sh` (Stop hook)
- `.claude/hooks/sensitive-patterns.txt` (consumed by hooks)
- `.claude/settings.json` (hook registration, env vars)
- `skills/nefario/SKILL.md` (bash snippets for scratch dirs, status files)
- `skills/despicable-prompter/SKILL.md` (mktemp usage)
- `.claude/skills/despicable-lab/SKILL.md` (project-local skill)
- `.claude/skills/despicable-statusline/SKILL.md` (jq dependency)
- `the-plan.md` deployment section (`realpath` usage)
- `docs/deployment.md` (deployment documentation)
- `README.md` (install instructions, limitations section)
- Symlink-based deployment model (fundamental architecture)

**Out of scope:**
- AGENT.md content (pure markdown, platform-independent)
- RESEARCH.md content (not deployed)
- Agent system prompt logic (runs inside Claude Code, not OS-level)
- Claude Code platform support itself (Anthropic's responsibility)

## Initial Platform Concern Inventory

### Identified Issues (from codebase scan)

| # | File | Concern | macOS | Linux | Windows |
|---|------|---------|-------|-------|---------|
| 1 | `install.sh` | `ln -sf` symlinks | OK | OK | Broken (requires admin/dev mode, different syntax) |
| 2 | `install.sh` | `readlink` (no `-f` flag on macOS) | OK (used without `-f`) | OK | N/A (no readlink) |
| 3 | `install.sh` | `BASH_SOURCE[0]` | OK (bash 3.2+) | OK | Needs bash (Git Bash or WSL) |
| 4 | `install.sh` | ANSI color codes (`\033[...`) | OK | OK | Partial (Windows Terminal OK, cmd.exe broken) |
| 5 | hooks/*.sh | `#!/usr/bin/env bash` shebang | OK | OK | Broken natively; needs Git Bash/WSL |
| 6 | hooks/*.sh | `local -a` (indexed arrays) | OK | OK | Needs bash 4+ |
| 7 | hooks/*.sh | `local -A` (associative arrays) | Needs bash 4+ (macOS ships 3.2!) | OK (bash 5+) | Needs bash 4+ |
| 8 | hooks/*.sh | `jq` dependency | Not preinstalled | Not preinstalled | Not preinstalled |
| 9 | hooks/*.sh | Hardcoded `/tmp/` paths | OK | OK | Broken (no /tmp/ natively) |
| 10 | hooks/*.sh | `grep -qFx` flags | OK | OK | Needs GNU grep or equivalent |
| 11 | SKILL.md | `mktemp -d` with template | OK | OK | Broken natively |
| 12 | SKILL.md | `${TMPDIR:-/tmp}` | OK | OK | Partial ($TMPDIR may differ) |
| 13 | SKILL.md | `chmod 700` / `chmod 600` | OK | OK | No-op or broken on NTFS |
| 14 | the-plan.md | `realpath` in deployment snippets | Not preinstalled (need coreutils) | OK | Broken natively |
| 15 | settings.json | `$CLAUDE_PROJECT_DIR` in hook commands | OK | OK | Shell expansion may differ |
| 16 | Deployment model | Symlinks as core architecture | OK | OK | Fundamentally problematic |
| 17 | statusline skill | `command -v jq` dependency check | OK | OK | Needs bash environment |

### Key Observation

**macOS has a bash 3.2 problem.** The hook scripts use `local -A` (associative
arrays), which requires bash 4+. macOS ships bash 3.2 (2007) due to GPLv3
licensing. Users who installed bash via Homebrew have bash 5+ at
`/usr/local/bin/bash` or `/opt/homebrew/bin/bash`, but `#!/usr/bin/env bash`
resolves to the system bash 3.2 unless PATH is configured. This means hooks
may already be broken on stock macOS.

---

## Planning Consultations

### Consultation 1: Shell Script Cross-Platform Audit

- **Agent**: iac-minion
- **Planning question**: Given the three shell scripts (`install.sh`, `track-file-changes.sh`, `commit-point-check.sh`) and the bash snippets embedded in SKILL.md files, what is the minimal set of changes needed to support macOS (including stock bash 3.2), Linux, and Windows (Git Bash / WSL)? Specifically: (a) Can we avoid bash 4+ features in hooks to support stock macOS? (b) What is the Windows story -- do we target Git Bash, WSL, or PowerShell? (c) Should we use `$TMPDIR` consistently instead of hardcoded `/tmp/`? (d) What is the cross-platform equivalent for symlinks on Windows -- junctions, mklink, or copy-based deployment? (e) Are there POSIX-only alternatives for the bash-specific features used?
- **Context to provide**: `install.sh`, `.claude/hooks/track-file-changes.sh`, `.claude/hooks/commit-point-check.sh`, `.claude/settings.json`, the bash snippets from `skills/nefario/SKILL.md` (lines 257-270, 375-396), `the-plan.md` deployment section (lines 1604-1625)
- **Why this agent**: iac-minion has deep expertise in shell scripting, Docker, CI/CD, and infrastructure automation across platforms. This is fundamentally an infrastructure portability question.

### Consultation 2: Developer Experience for Multi-Platform Setup

- **Agent**: devx-minion
- **Planning question**: How should we document platform requirements and installation prerequisites for a tool that currently targets macOS/Linux with bash? Consider: (a) What is the right format for a "prerequisites" section -- table, checklist, or platform-specific tabs? (b) Should we provide a "check prerequisites" script or command? (c) How should we communicate "macOS-only for now" without making the project look immature? (d) What is the best way to document required CLI tools (git, jq, bash 4+, gh) with install instructions that work across package managers (brew, apt, dnf, choco, winget)? (e) The user wants an approach like "just paste this list and ask Claude Code to install them" -- is that viable and how should we format it?
- **Context to provide**: Current `README.md` (especially Install section and Current Limitations), `docs/deployment.md`, the list of identified external dependencies (bash 4+, jq, git, gh CLI, realpath/coreutils)
- **Why this agent**: devx-minion specializes in developer onboarding, CLI design, error messages, and making tooling approachable. The documentation and prerequisite communication is a developer experience challenge.

### Consultation 3: Documentation Strategy

- **Agent**: software-docs-minion
- **Planning question**: We need to produce three documentation artifacts: (a) A platform support disclaimer for README.md and docs (what format, where to place it, how to phrase it for an open-source project that is currently macOS/Linux-only), (b) A prerequisites/dependencies page documenting all required CLI tools with per-platform install instructions, (c) A "cross-platform roadmap" section or tracking issue format for the path to Windows support. How should these integrate with the existing docs structure (README.md -> docs/architecture.md hub -> sub-docs)? Should the prerequisites doc be standalone or part of deployment.md?
- **Context to provide**: `README.md`, `docs/architecture.md` (sub-documents table), `docs/deployment.md`, identified platform issues inventory
- **Why this agent**: software-docs-minion handles architecture documentation, README structure, and documentation organization. This is a documentation structure and placement question.

### Consultation 4: Security Review of Platform Mitigations

- **Agent**: security-minion
- **Planning question**: The hook scripts and SKILL.md use `mktemp -d` with `chmod 700` for scratch directories and `/tmp/` for session state files. If we make these cross-platform: (a) Are there security implications of using `$TMPDIR` on Windows (less restrictive permissions model)? (b) The current `chmod 600`/`chmod 700` calls are security controls -- what replaces them on Windows/NTFS? (c) The `sensitive-patterns.txt` fail-closed design -- does it remain safe if `grep` behavior differs across platforms? (d) Any concerns with the symlink-to-junction migration path on Windows?
- **Context to provide**: `.claude/hooks/commit-point-check.sh` (especially the security-relevant sections: sensitive file filtering, fail-closed pattern, tmp file paths), `.claude/hooks/track-file-changes.sh` (path injection validation), `skills/nefario/SKILL.md` scratch directory section
- **Why this agent**: security-minion reviews threat models and identifies risks in infrastructure changes. Cross-platform temp file handling and permission models are security-sensitive.

### Cross-Cutting Checklist

- **Testing**: Include test-minion for planning? **No** -- this is an advisory/audit task, not producing executable code. Testing concerns (e.g., "how would we test cross-platform?") are covered by iac-minion's CI/CD expertise. If this moves to execution, test-minion would be involved.
- **Security**: **Yes** -- included as Consultation 4. Temp file handling, permission models, and symlink security on Windows are genuine security concerns.
- **Usability -- Strategy**: **Yes** -- partially covered by devx-minion (Consultation 2) who handles developer onboarding UX. A separate ux-strategy-minion consultation is not needed because the "users" here are developers installing a CLI tool, which falls squarely in devx-minion's domain. ux-strategy-minion's journey mapping expertise is not additive for a developer tooling prerequisite audit.
- **Usability -- Design**: **No** -- no user-facing interfaces are being produced. This is documentation and shell script analysis.
- **Documentation**: **Yes** -- included as Consultation 3 (software-docs-minion). user-docs-minion is not needed separately because the audience is developers/contributors, not end-users of a product.
- **Observability**: **No** -- no runtime components are being created or modified.

### Anticipated Approval Gates

This is an advisory-mode task producing a report with recommendations and documentation prompts. The primary deliverable is the advisory report itself. No approval gates are anticipated because:

1. The report produces recommendations, not code changes
2. The documentation prompts are provided for the user to review and apply at their discretion
3. No irreversible decisions are being made

If the user decides to act on the cross-platform roadmap, that would be a separate `/nefario` execution session with its own gates.

### Rationale

Four specialists were selected because the task spans four distinct domains:

1. **iac-minion** (primary): The core technical audit -- what breaks, what the fixes are, cross-platform shell scripting expertise
2. **devx-minion**: How to communicate platform requirements to developers -- the UX of installation and prerequisites
3. **software-docs-minion**: Where and how to place the documentation within the existing docs structure
4. **security-minion**: Whether cross-platform adaptations introduce security regressions in the temp file and permission model

Agents NOT consulted and why:
- **debugger-minion**: No debugging needed -- this is analysis, not troubleshooting a failure
- **frontend-minion**: No frontend components involved
- **test-minion**: No test code being written in this advisory phase
- **ux-strategy-minion**: Developer tooling UX is covered by devx-minion; no product UX journey involved

### External Skill Integration

#### Discovered Skills

| Skill | Location | Classification | Domain | Recommendation |
|-------|----------|---------------|--------|----------------|
| despicable-lab | `.claude/skills/despicable-lab/` | LEAF | Agent build/rebuild pipeline | Not relevant -- this task does not rebuild agents |
| despicable-statusline | `.claude/skills/despicable-statusline/` | LEAF | Claude Code status line config | Peripheral -- has a `jq` dependency worth noting in the prerequisites audit, but the skill itself is not needed for planning |

#### Precedence Decisions

No precedence conflicts. Neither discovered skill overlaps with the advisory task's domain.
