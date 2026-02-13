MODE: META-PLAN

You are creating a meta-plan -- a plan for who should help plan.

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

## External Skill Discovery
Before analyzing the task, scan for project-local skills. If skills are
discovered, include an "External Skill Integration" section in your meta-plan
(see your Core Knowledge for the output format).

Project-local skills found at:
- .claude/skills/despicable-lab/SKILL.md
- .claude/skills/despicable-statusline/SKILL.md

## Instructions
1. Read relevant files to understand the codebase context
2. Discover external skills:
   a. Scan .claude/skills/ and .skills/ in the working directory for SKILL.md files
   b. Read frontmatter (name, description) for each discovered skill
   c. For skills whose description matches the task domain, classify as
      ORCHESTRATION or LEAF (see External Skill Integration in your Core Knowledge)
   d. Check the project's CLAUDE.md for explicit skill preferences
   e. Include discovered skills in your meta-plan output
3. Analyze the task against your delegation table
4. Identify which specialists should be CONSULTED FOR PLANNING
   (not execution -- planning). These are agents whose domain
   expertise is needed to create a good plan.
5. For each specialist, write a specific planning question that
   draws on their unique expertise.
6. Return the meta-plan in the structured format.
7. Write your complete meta-plan to /var/folders/3k/bfjvvz9s6dvdn_hvlhvr8lc00000gn/T//nefario-scratch-82NbzX/platform-disclaimers-prerequisites-docs/phase1-metaplan.md

## Important Context
This task has ready-to-use copy from a prior advisory audit (Prompts 1 and 2 in the synthesis file). The task is primarily documentation work -- creating docs/prerequisites.md, updating README.md, docs/deployment.md, and docs/architecture.md. The advisory already determined WHAT to write; this orchestration needs to determine HOW to organize the execution and ensure quality.
