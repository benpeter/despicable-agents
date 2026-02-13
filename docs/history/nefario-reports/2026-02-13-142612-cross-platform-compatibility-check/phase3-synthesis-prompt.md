MODE: SYNTHESIS
ADVISORY: true

You are synthesizing specialist planning contributions into a
team recommendation. This is an advisory-only orchestration --
no code will be written, no branches created, no PRs opened.

Do NOT produce task prompts, agent assignments, execution order,
approval gates, or delegation plan structure. Produce an advisory
report using the advisory output format defined in your AGENT.md.

## Original Task
check if we are fine on all platforms and if not, what it would take to be safe on windows, macOS, linux
we should think about adding documentation disclaimers that this is mac-only until we have that fixed (if the answer is "not yet")
also think about documenting all command line tools that are expected to be available
in the report, include prompts for
- the docs disclaimer for platform specificity for now
- documentation on required command line tools and how to install them ("ask claude code to do it for you, just paste the list")
- achieving cross-platform stability

## Specialist Contributions

Read the following scratch files for full specialist contributions:
- /var/folders/3k/bfjvvz9s6dvdn_hvlhvr8lc00000gn/T//nefario-scratch-W2FlrM/cross-platform-compatibility-check/phase2-iac-minion.md
- /var/folders/3k/bfjvvz9s6dvdn_hvlhvr8lc00000gn/T//nefario-scratch-W2FlrM/cross-platform-compatibility-check/phase2-devx-minion.md
- /var/folders/3k/bfjvvz9s6dvdn_hvlhvr8lc00000gn/T//nefario-scratch-W2FlrM/cross-platform-compatibility-check/phase2-software-docs-minion.md
- /var/folders/3k/bfjvvz9s6dvdn_hvlhvr8lc00000gn/T//nefario-scratch-W2FlrM/cross-platform-compatibility-check/phase2-security-minion.md

## Key consensus across specialists:

### iac-minion (Phase: planning)
Recommendation: Project is NOT cross-platform safe today. commit-point-check.sh uses bash 4+ features (fatal on stock macOS), all temp paths hardcode /tmp/ (broken on Windows), symlinks don't work on Windows Git Bash, jq is undocumented hard dependency.
Tasks: 5 -- Fix bash 4+ deps; Standardize temp paths; Copy-based fallback for install.sh; Platform docs; Shellcheck CI
Risks: Hook path coordination (high); Windows symlinks fundamentally limited; jq undocumented (high); chmod no-op on Windows
Conflicts: none

### devx-minion (Phase: planning)
Recommendation: Do Tier 1 (documentation) now, defer Tier 2 (script hardening) and Tier 3 (true cross-platform) per YAGNI. Use flat checklist for prerequisites, add ./install.sh check subcommand, frame as "tested on macOS and Linux" not "macOS/Linux only", provide Claude Code prompt for dependency installation.
Tasks: 3 -- README prerequisites and platform notes; install.sh check subcommand; deployment.md prerequisites update
Risks: Windows symlink model fundamentally incompatible; bash 3.2 silent failures; jq hidden dependency
Conflicts: none

### software-docs-minion (Phase: planning)
Recommendation: Two disclaimer locations (README + deployment.md), new standalone prerequisites.md, cross-platform roadmap as GitHub issue not docs page. macOS bash 3.2 is latent bug today.
Tasks: 5 -- README disclaimer; deployment.md platform table; docs/prerequisites.md; GitHub tracking issue; architecture.md table update
Risks: macOS bash 3.2 latent bug; documentation drift; overloading README
Conflicts: none

### security-minion (Phase: planning)
Recommendation: $TMPDIR on Windows per-user temp is more secure by default, but chmod is no-op creating fail-open condition. Fail-closed design in hooks is safe cross-platform. Do NOT use junctions as symlink replacement (directory-only, traversal attack risk). WSL is the safe path.
Tasks: 5 -- Secure temp directory abstraction; CRLF hardening; Windows deployment strategy; Security model docs; Platform detection in hooks
Risks: Silent security degradation (chmod no-op = fail-open); Enterprise blocks symlinks; Session ID in predictable paths; jq/grep availability
Conflicts: none

## Instructions
1. Review all specialist contributions
2. Resolve any conflicts between recommendations
3. Identify consensus and dissent -- preserve minority positions
4. Produce an advisory report with executive summary, team consensus,
   dissenting views, supporting evidence, risks, next steps, and
   conflict resolutions
5. The user specifically requested the report include ready-to-use prompts for:
   - docs disclaimer for platform specificity
   - documentation on required CLI tools with install instructions ("ask Claude Code to do it for you, just paste the list")
   - achieving cross-platform stability
   Include these as an appendix section in the advisory synthesis.
6. Write your complete advisory synthesis to
   /var/folders/3k/bfjvvz9s6dvdn_hvlhvr8lc00000gn/T//nefario-scratch-W2FlrM/cross-platform-compatibility-check/phase3-synthesis.md
