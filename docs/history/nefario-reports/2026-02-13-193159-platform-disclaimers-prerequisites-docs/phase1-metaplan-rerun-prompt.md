MODE: META-PLAN

You are re-running the meta-plan after a team adjustment.

## Task

<github-issue>
## Context

A [cross-platform advisory audit](docs/history/nefario-reports/2026-02-13-142612-cross-platform-compatibility-check.md) by 4 specialists found that despicable-agents is **not cross-platform safe today**:

- **macOS**: Works with Homebrew bash. Stock macOS (bash 3.2) has a latent bug -- `commit-point-check.sh` uses bash 4+ features that silently fail.
- **Linux**: Fully supported.
- **Windows**: Not supported -- `install.sh` depends on POSIX symlinks.
- **jq** is an undocumented hard dependency (silent failures when missing).

This issue covers **Tier 1: Documentation** -- the immediate, low-effort work recommended by all 4 specialists.

## Tasks

- [ ] Add platform support disclaimer to README.md (blockquote after "Install" heading)
- [ ] Add prerequisites table to README.md (git, bash 4+, jq, gh)
- [ ] Add "Quick Setup via Claude Code" section to README.md with copy-pasteable prompt
- [ ] Add "Platform Notes" section to README.md (symlink explanation, WSL recommendation for Windows, bash 4+ note for macOS)
- [ ] Create `docs/prerequisites.md` with per-platform install commands (macOS/Homebrew, Debian/Ubuntu, Fedora/RHEL, Windows note)
- [ ] Add platform support table to `docs/deployment.md`
- [ ] Add prerequisites.md to `docs/architecture.md` sub-documents table
- [ ] Verify no overloading of README -- disclaimer should be minimal (1 blockquote), detail belongs in prerequisites.md

## Ready-to-Use Prompts

The advisory report includes ready-to-use copy for each artifact. See the [synthesis working file](docs/history/nefario-reports/2026-02-13-142612-cross-platform-compatibility-check/phase3-synthesis.md) (Appendix: Prompts 1 and 2).

## Related Issues

- Tier 2 (script hardening): #102
- Tier 3 (Windows/cross-platform support): #103

## Source

[Advisory report](docs/history/nefario-reports/2026-02-13-142612-cross-platform-compatibility-check.md) | PR #100
</github-issue>

## Working Directory
/Users/ben/github/benpeter/2despicable/3

## Original Meta-Plan

The following meta-plan was produced for the original team. Use it as context for the revised plan, not as a template to minimally edit.

Read the original meta-plan from: /var/folders/3k/bfjvvz9s6dvdn_hvlhvr8lc00000gn/T//nefario-scratch-82NbzX/platform-disclaimers-prerequisites-docs/phase1-metaplan.md

## Team Adjustment

Added: ai-modeling-minion. Removed: none.

Revised team: software-docs-minion, devx-minion, ai-modeling-minion.

## Constraints

- Keep the same scope and task description
- Preserve external skill integration decisions unless the team change removes all agents relevant to a skill's domain
- Generate planning consultations for ALL agents in the revised team
- Re-evaluate the cross-cutting checklist against the new team
- Produce output at the same depth and format as the original
- Do NOT change the fundamental scope of the task
- Do NOT add agents the user did not request (beyond cross-cutting requirements)
- Design planning questions as a coherent set -- each question should address aspects that no other agent on the team covers, and questions should reference cross-cutting boundaries where relevant

## Instructions
1. Read the original meta-plan for context
2. Generate planning consultations for all 3 agents in the revised team
3. Each agent's planning question should address aspects no other agent covers
4. Write your complete revised meta-plan to /var/folders/3k/bfjvvz9s6dvdn_hvlhvr8lc00000gn/T//nefario-scratch-82NbzX/platform-disclaimers-prerequisites-docs/phase1-metaplan-rerun.md
