---
type: nefario-report
version: 3
date: "2026-02-13"
time: "14:26:12"
task: "Cross-platform compatibility audit and documentation recommendations"
mode: advisory
agents-involved: [nefario, iac-minion, devx-minion, software-docs-minion, security-minion]
task-count: 0
gate-count: 0
outcome: completed
---

# Cross-platform compatibility audit and documentation recommendations

## Summary

Four specialists audited the despicable-agents shell scripts, hook scripts, SKILL.md bash snippets, and symlink-based deployment model for cross-platform compatibility. The project is NOT cross-platform safe today: it works on macOS (with Homebrew bash) and Linux, but stock macOS has a latent bash 3.2 bug in the commit hooks, and Windows is unsupported due to POSIX symlink dependencies. The team recommends documentation first (platform disclaimers, prerequisites page, Claude Code setup prompt), deferring code changes per YAGNI.

## Original Prompt

> check if we are fine on all platforms and if not, what it would take to be safe on windows, macOS, linux
> we should think about adding documentation disclaimers that this is mac-only until we have that fixed (if the answer is "not yet")
> also think about documenting all command line tools that are expected to be available
> in the report, include prompts for
> - the docs disclaimer for platform specificity for now
> - documentation on required command line tools and how to install them ("ask claude code to do it for you, just paste the list")
> - achieving cross-platform stability

## Key Design Decisions

#### Documentation First, Code Changes Later

**Rationale**:
- Consistent with the project's YAGNI/KISS philosophy from CLAUDE.md
- No evidence of Windows users hitting issues yet
- Documentation has high value (prevents confusion) with low effort
- Code hardening can be done independently when demand materializes

**Alternatives Rejected**:
- Immediate bash 3.2 fix + temp path standardization: deferred as Tier 2 (no user reports of breakage yet)
- Windows copy-based fallback in install.sh: deferred as Tier 3 (YAGNI -- no Windows users yet)

#### WSL as Recommended Windows Path (Not Git Bash)

**Rationale**:
- WSL provides full POSIX semantics with zero code changes
- Git Bash has fundamental limitations: symlinks become copies (breaking live-editing), chmod is a no-op, jq not bundled
- security-minion confirmed WSL preserves the full security model (chmod works, symlinks work)

**Alternatives Rejected**:
- Git Bash as primary: degraded experience (copies instead of symlinks), silent security model degradation
- Junction points on Windows: security-minion blocked -- junction traversal enables local privilege escalation
- PowerShell install script: requires full rewrite, adds maintenance burden, hooks still need bash

#### GitHub Issue for Cross-Platform Tracking (Not Docs Page)

**Rationale**:
- A roadmap in docs/ goes stale the moment work starts
- GitHub issue with checklist is a living artifact that can be assigned and tracked
- If a platform support decision is eventually made, that warrants an ADR

**Alternatives Rejected**:
- docs/cross-platform-roadmap.md: would go stale, no natural update trigger

### Conflict Resolutions

1. **Junction points**: iac-minion listed as an option for directory-level symlinks on Windows. security-minion blocked -- junction traversal is a real local privilege escalation vector. Resolved in favor of security-minion.

2. **Immediacy of code changes**: iac-minion proposed 5 implementation tasks. devx-minion recommended Tier 1 docs only, deferring code. Resolved in favor of devx-minion's tiered approach -- consistent with YAGNI.

3. **Prerequisites location**: software-docs-minion wanted standalone docs/prerequisites.md. devx-minion wanted inline README checklist. Resolved as complementary -- README gets a concise checklist, docs/prerequisites.md gets per-platform details.

## Phases

### Phase 1: Meta-Plan

Nefario identified 4 specialists for the audit: iac-minion (shell script portability), devx-minion (developer experience and documentation format), software-docs-minion (documentation structure and placement), and security-minion (security implications of cross-platform adaptations). Scope was defined as all executable shell artifacts, embedded bash snippets in SKILL.md files, the symlink deployment model, and documentation. AGENT.md/RESEARCH.md content (pure markdown) and Claude Code platform support itself were excluded. Two project-local skills were discovered (despicable-lab, despicable-statusline) but neither was relevant to the advisory task.

### Phase 2: Specialist Planning

**iac-minion** performed a comprehensive audit of all shell scripts, identifying 17 platform-specific issues. The most critical finding: `commit-point-check.sh` uses bash 4+ features (associative arrays via `local -A`, array initialization via `local -a x=()`) that cause fatal syntax errors on stock macOS bash 3.2. Also identified 6+ locations where temp paths hardcode `/tmp/` instead of `${TMPDIR:-/tmp}`, and catalogued all 12 external tool dependencies across the scripts.

**devx-minion** focused on how to communicate platform requirements. Recommended a 3-tier approach: Tier 1 (documentation now), Tier 2 (script hardening when needed), Tier 3 (true cross-platform, likely YAGNI). Provided the "paste into Claude Code" setup prompt concept and recommended framing as "tested on macOS and Linux" rather than "macOS/Linux only."

**software-docs-minion** recommended two-location disclaimers (README + deployment.md), a new standalone docs/prerequisites.md, and a GitHub tracking issue rather than a docs-page roadmap. Emphasized that the macOS bash 3.2 problem is a latent bug today, not just a future Windows concern.

**security-minion** analyzed the security implications of cross-platform temp file handling, permission models, and symlink alternatives. Key findings: chmod is a no-op on Windows NTFS (creating a fail-open condition), the fail-closed design in sensitive-patterns.txt is safe cross-platform (uses bash built-ins not grep), and junction points on Windows are a security risk (traversal attacks). Confirmed WSL as the safe path for Windows users.

### Phase 3: Synthesis

All four specialists reached strong consensus: the project works on macOS (with Homebrew bash) and Linux, stock macOS has a latent bug, and Windows is unsupported. The recommendation is documentation first, code changes later. The synthesis resolved three minor conflicts (junction safety, code change timing, prerequisites location) and produced three ready-to-use prompts for the user's requested deliverables.

### Phase 3.5: Architecture Review

Skipped (advisory-only orchestration).

### Phase 4: Execution

Skipped (advisory-only orchestration).

### Phase 5: Code Review

Skipped (advisory-only orchestration).

### Phase 6: Test Execution

Skipped (advisory-only orchestration).

### Phase 7: Deployment

Skipped (advisory-only orchestration).

### Phase 8: Documentation

Skipped (advisory-only orchestration).

## Agent Contributions

<details>
<summary>Agent Contributions (4 planning)</summary>

### Planning

**iac-minion**: Comprehensive shell script audit identifying 17 platform issues across macOS, Linux, and Windows. Key finding: commit-point-check.sh uses bash 4+ features fatal on stock macOS.
- Adopted: Platform issues inventory, external tool dependency catalog, POSIX alternatives for bash 4+ features, temp path inconsistency analysis
- Risks flagged: Hook path coordination (high) -- coupled temp paths across files; jq undocumented hard dependency (high) -- silent failures; Windows symlinks fundamentally limited

**devx-minion**: Developer experience analysis with tiered approach to cross-platform stability. Provided ready-to-use documentation copy and the "paste into Claude Code" setup prompt concept.
- Adopted: 3-tier approach (docs now, hardening later, true cross-platform deferred), "tested on macOS and Linux" framing, flat checklist format for prerequisites, Claude Code setup prompt
- Risks flagged: bash 3.2 silent failures on macOS, jq hidden dependency, Windows symlink model fundamentally incompatible

**software-docs-minion**: Documentation structure and placement strategy. Recommended two-location disclaimers, standalone prerequisites page, and GitHub issue for cross-platform tracking.
- Adopted: Two-location disclaimer strategy (README + deployment.md), standalone docs/prerequisites.md, GitHub issue for roadmap (not docs page), architecture.md table update
- Risks flagged: macOS bash 3.2 is latent bug today, documentation drift risk, overloading README

**security-minion**: Security analysis of cross-platform temp file handling, permission models, and symlink alternatives. Confirmed fail-closed design is safe, blocked junction points as insecure.
- Adopted: WSL as recommended Windows path, no junctions (traversal attack risk), CRLF normalization recommendation, chmod security model analysis
- Risks flagged: Silent security degradation on Windows (chmod no-op = fail-open), enterprise Windows blocks symlinks via group policy, session ID in predictable temp paths

</details>

## Team Recommendation

**Document the current state honestly (macOS + Linux supported, Windows not yet), defer code changes per YAGNI, and provide ready-to-use prompts for future hardening work.**

### Consensus

| Position | Agents | Strength |
|----------|--------|----------|
| Documentation first, code later | all 4 specialists | Strong -- unanimous, consistent with project philosophy |
| WSL as recommended Windows path | security-minion, devx-minion, iac-minion | Strong -- full POSIX semantics, zero code changes |
| No junction points on Windows | security-minion | Strong -- junction traversal is a real attack vector |
| macOS bash 3.2 is a latent bug today | iac-minion, devx-minion, software-docs-minion | Strong -- independently identified by 3 of 4 specialists |

### When to Revisit

1. A user reports that hooks fail on stock macOS (bash 3.2) -- triggers Tier 2 script hardening
2. A Windows user opens an issue asking for support -- triggers evaluation of WSL-only vs. copy-based fallback
3. The project gains CI -- triggers adding shellcheck and cross-platform matrix testing
4. The project gains contributors on Windows -- triggers architectural decision on deployment model

### Strongest Arguments

**For documentation first** (adopted):

| Argument | Agent |
|----------|-------|
| Consistent with YAGNI/KISS philosophy in CLAUDE.md | devx-minion |
| No evidence of users hitting these issues yet | devx-minion |
| Documentation prevents confusion with zero risk of regressions | software-docs-minion |
| The bash 3.2 bug is real but likely mitigated by Homebrew prevalence | iac-minion |

**For immediate code hardening** (not adopted, but preserved):

| Argument | Agent |
|----------|-------|
| bash 4+ fix is small (POSIX alternatives exist for every construct) | iac-minion |
| Silent failures are worse than explicit failures -- users don't know hooks are broken | iac-minion |
| $TMPDIR standardization prevents a class of future bugs atomically | iac-minion |
| chmod no-op on Windows is a fail-open security condition | security-minion |

## Working Files

<details>
<summary>Working files (13 files)</summary>

Companion directory: [2026-02-13-142612-cross-platform-compatibility-check/](./2026-02-13-142612-cross-platform-compatibility-check/)

- [Original Prompt](./2026-02-13-142612-cross-platform-compatibility-check/prompt.md)

**Outputs**
- [Phase 1: Meta-plan](./2026-02-13-142612-cross-platform-compatibility-check/phase1-metaplan.md)
- [Phase 2: iac-minion](./2026-02-13-142612-cross-platform-compatibility-check/phase2-iac-minion.md)
- [Phase 2: devx-minion](./2026-02-13-142612-cross-platform-compatibility-check/phase2-devx-minion.md)
- [Phase 2: software-docs-minion](./2026-02-13-142612-cross-platform-compatibility-check/phase2-software-docs-minion.md)
- [Phase 2: security-minion](./2026-02-13-142612-cross-platform-compatibility-check/phase2-security-minion.md)
- [Phase 3: Synthesis](./2026-02-13-142612-cross-platform-compatibility-check/phase3-synthesis.md)

**Prompts**
- [Phase 1: Meta-plan prompt](./2026-02-13-142612-cross-platform-compatibility-check/phase1-metaplan-prompt.md)
- [Phase 2: iac-minion prompt](./2026-02-13-142612-cross-platform-compatibility-check/phase2-iac-minion-prompt.md)
- [Phase 2: devx-minion prompt](./2026-02-13-142612-cross-platform-compatibility-check/phase2-devx-minion-prompt.md)
- [Phase 2: software-docs-minion prompt](./2026-02-13-142612-cross-platform-compatibility-check/phase2-software-docs-minion-prompt.md)
- [Phase 2: security-minion prompt](./2026-02-13-142612-cross-platform-compatibility-check/phase2-security-minion-prompt.md)
- [Phase 3: Synthesis prompt](./2026-02-13-142612-cross-platform-compatibility-check/phase3-synthesis-prompt.md)

</details>
