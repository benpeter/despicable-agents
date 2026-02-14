# Lucy Review: domain-separation Plan

**Verdict: ADVISE**

The plan aligns well with the user's stated intent and respects CLAUDE.md conventions. Two advisory items require attention before or during execution but do not warrant blocking.

---

## Requirement Traceability

| Original Requirement | Plan Element | Status |
|---|---|---|
| Clear boundary between domain-specific config and domain-independent infra | Task 1 (audit), Task 2 (extraction + markers) | COVERED |
| Hypothetical domain adapter can define own phases/gates/roster without editing infra files | Task 2 (DOMAIN.md extraction), Task 3 (assemble.sh) | COVERED |
| Documentation explains adapter vs. framework boundary | Task 4 (docs/domain-adaptation.md) | COVERED |
| Existing software-dev behavior preserved identically | Task 5 (behavioral equivalence verification) | COVERED |
| Scope-in: nefario SKILL.md orchestration logic | Task 1 + Task 2 (SKILL.md annotated with section markers) | COVERED |
| Scope-out: Not building non-software domain agent sets | Task 2 "What NOT to do" explicitly excludes this | COVERED |
| Scope-out: Not changing AGENT.md file format | Adapter uses same YAML-frontmatter + markdown convention | COVERED |
| Scope-out: Not modifying Claude Code platform integration | No plan element touches platform integration | COVERED |
| "Do not dismiss as YAGNI" constraint honored | Plan explicitly addresses this in conflict resolution, rejects section-markers-only | COVERED |

All four success criteria from the original request map to plan deliverables. No stated requirement is unaddressed.

---

## Findings

### 1. SCOPE: `disassemble.sh` is not traceable to any stated requirement

**CHANGE**: Task 3 creates a `disassemble.sh` reverse-assembly script that restores template markers from an assembled AGENT.md.

**WHY this is a concern**: The original request asks for separation of domain config from infrastructure and a way for forkers to define their own adapters. The reverse operation (disassembling a materialized AGENT.md back into template + adapter) serves a maintenance scenario the user did not request. This is a "nice-to-have" adjacent feature. It adds scope (another script to test and maintain) without tracing to a stated requirement.

**Recommendation**: Remove `disassemble.sh` from Task 3. If the need materializes later, it can be added as a follow-up. This aligns with the project's YAGNI principle in CLAUDE.md. If nefario disagrees, the justification must be tied to a stated requirement, not a hypothetical convenience.

**Severity**: Low. The script is small and self-contained, so the risk is maintenance burden, not architectural damage.

---

### 2. CONVENTION: Assembly changes the `install.sh` contract documented in CLAUDE.md

**CHANGE**: Task 3 modifies `install.sh` to run `assemble.sh` before symlinking, and adds a `--domain` flag.

**WHY this is a concern**: The project's `CLAUDE.md` documents the deployment command as `./install.sh  # Symlinks 27 agents and 2 skills`. After this change, `install.sh` has a hidden prerequisite (assembly must succeed) and a new flag (`--domain`). The CLAUDE.md deployment section will become stale. Additionally, the current `install.sh` supports `install` and `uninstall` subcommands; the `--domain` flag needs to coexist with this existing argument parsing.

**Recommendation**: Task 3 or a follow-up commit must update the CLAUDE.md Deployment section to reflect the new `--domain` flag and assembly step. Task 3's prompt should explicitly note the existing `install`/`uninstall` subcommand pattern so devx-minion integrates the flag cleanly rather than breaking the existing interface.

**Severity**: Low. Documentation staleness, not behavioral breakage.

---

## Items Verified (No Issues Found)

- **CLAUDE.md "Do NOT modify the-plan.md" rule**: No task touches `the-plan.md`. Compliant.
- **CLAUDE.md "All artifacts in English" rule**: All deliverables are English markdown and shell scripts. Compliant.
- **CLAUDE.md "No PII, no proprietary data" rule**: No PII or proprietary content introduced. Compliant.
- **CLAUDE.md Engineering Philosophy (KISS, lightweight, vanilla)**: Assembly uses only bash/sed/awk. No external dependencies. Single-file adapter (not multi-file directory). Compliant.
- **Scope containment**: The plan does not build non-software adapters, does not add runtime config loading, does not introduce a plugin lifecycle, does not add validation tooling. All explicit scope-out items are respected.
- **Behavioral preservation**: Task 5 is dedicated to verifying semantic equivalence of assembled output against the pre-refactor AGENT.md via git diff. This directly addresses the "existing orchestration works identically" success criterion.
- **Approval gate placement**: The gate after Task 2 (adapter format design) is well-placed. The adapter format is the architectural decision that all downstream work depends on. Correct use of the gating mechanism.
- **Agent selection matches user directive**: The user specified "ai-modeling, lucy, margo, devx as the roster." The plan uses ai-modeling-minion (Tasks 1, 2, 5), devx-minion (Task 3), and software-docs-minion (Task 4). software-docs-minion was not in the user's roster specification but is reasonable for the documentation task. No concern -- the user's roster was for planning consultation, and software-docs-minion is an execution agent for a docs deliverable that directly maps to a stated requirement.
- **Conflict resolution quality**: All five conflicts are resolved with clear rationale, and each resolution traces to either a stated requirement or a CLAUDE.md convention. The middle-path resolution (single-file extraction for AGENT.md, section markers for SKILL.md) is proportional to the problem.
