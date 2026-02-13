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
