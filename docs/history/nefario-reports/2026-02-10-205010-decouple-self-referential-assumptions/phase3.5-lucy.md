# Phase 3.5 Review: lucy (Intent Alignment & Convention Compliance)

**Verdict: ADVISE**

---

## Requirement Traceability

| # | User Requirement (from prompt.md) | Plan Coverage | Status |
|---|---|---|---|
| R1 | Full audit of self-referential touchpoints | Phase 1 meta-plan (10 categories) | COVERED |
| R2 | Each touchpoint resolved with clear delineation | Tasks 1-6 address categories 1,2,3,6,8,9; categories 4,5,7,10 explicitly scoped out or handled | COVERED |
| R3 | Reports write to target project | Task 2 (cwd-relative detection) | COVERED |
| R4 | Git operations target the target project | Task 2 (greenfield guards, dynamic default branch) | COVERED |
| R5 | `/despicable-prompter` reads context from target project | Conflict resolution: DEFERRED (correctly -- scope is promotion, not feature addition) | PARTIAL -- see ADVISE-1 |
| R6 | Greenfield empty directory works | Task 2 (git guards, mkdir -p) | COVERED |
| R7 | Self-evolution still works | Task 1 (regression tests), Task 6 (scenario 1) | COVERED |
| R8 | No behavioral regressions for self-evolution | Task 1 (pre-decoupling baseline), verification steps | COVERED |
| R9 | `/despicable-prompter` becomes global skill | Task 3 | COVERED |

All user-stated requirements are addressed. No requirements are orphaned.

---

## Findings

### ADVISE-1 [TRACE]: Requirement R5 partially deferred without user acknowledgment

**Requirement**: "/despicable-prompter reads context from the target project, not despicable-agents"

**Plan element**: Conflict resolution "Prompter context reading" (line 32-34) defers context reading as a future task. Task 3 promotes the prompter to a global skill, which means it will be invoked from the target project's cwd -- so it implicitly reads cwd context via Claude Code's own CLAUDE.md loading. But the user specifically called out "reads context from the target project" as a success criterion.

**Assessment**: The plan's approach (promote to global skill, cwd resolves naturally) likely satisfies the user's intent in practice. The prompter does not hardcode despicable-agents paths, so once global, it operates in the target project context. The explicit deferral of "read README.md, CLAUDE.md, ls" is correct scope containment -- that is a feature addition. However, the plan should explicitly state that R5 is satisfied by the global promotion (cwd = target project) rather than silently deferring it.

**Fix**: Add a sentence to the Task 3 prompt or the conflict resolution noting that global skill promotion satisfies R5 because the skill runs in the target project's context.

---

### ADVISE-2 [SCOPE]: `NEFARIO_REPORTS_DIR` environment variable is unrequested scope

**Plan element**: Task 2 report directory detection order includes `NEFARIO_REPORTS_DIR` as the first priority (line 175). Task 6 tests this env var (line 489).

**Requirement**: The user asked for decoupling, not configuration knobs. The plan itself rejects `NEFARIO_SCRATCH_DIR` on YAGNI grounds (line 22) but includes `NEFARIO_REPORTS_DIR` without the same scrutiny. No user requirement traces to this env var.

**Assessment**: This is mild scope creep. The detection logic (check `docs/nefario-reports/` then `docs/history/nefario-reports/`) is sufficient for decoupling. The env var adds a configuration surface that nobody has asked for. It is not harmful, but it is unjustified by the stated requirements and inconsistent with the YAGNI rejection of the scratch dir env var.

**Fix**: Remove `NEFARIO_REPORTS_DIR` from the detection order in Task 2 and remove the env var test from Task 6. If needed later, it can be added. This aligns with the plan's own stated principle: "No `NEFARIO_SCRATCH_DIR` override -- YAGNI. If needed later, it can be added." Apply the same standard to reports.

---

### ADVISE-3 [CONVENTION]: Task 5 README restructuring risks scope creep during execution

**Plan element**: Task 5 prompt instructs software-docs-minion to "Restructure the README to serve toolkit users as the PRIMARY audience while preserving the contributor path." This includes adding a "What Happens in Your Project" section, reorganizing for toolkit users, and "Move 'Contributing' details behind a link."

**Requirement**: The user asked to "decouple self-referential assumptions." Documentation updates that reflect the new paths are in scope. Repositioning the README's audience and restructuring its information architecture is a marketing/positioning exercise beyond the decoupling scope.

**Assessment**: Updating path references in docs is clearly in scope. Adding a brief section explaining what happens in external projects is reasonable. But "restructure the README to serve toolkit users as PRIMARY audience" and "Move Contributing details behind a link" is gold-plating -- it changes the project's communication strategy, not just its technical accuracy. The CLAUDE.md engineering philosophy says "More code, less blah, blah."

**Fix**: Scope Task 5's README changes to: (1) update path references to match new conventions, (2) update the install section to mention the prompter skill, (3) add a short "Using on Other Projects" note. Do NOT restructure the README's audience or move sections around. That is a separate task if the user wants it.

---

### ADVISE-4 [CONVENTION]: Task 1 test count may exceed project test conventions

**Plan element**: Task 1 creates two new test scripts. Task 6 creates a third. After execution, the project will have 5 test files (up from 2).

**Assessment**: This is not a violation per se, but the project's existing test footprint is minimal (2 files). Tripling the test count for a structural refactoring is proportionate to the risk (SKILL.md is the operational core), and the plan justifies it well (regression before, portability after). No action needed, but noting for transparency.

---

### ADVISE-5 [COMPLIANCE]: CLAUDE.md will need updating after execution

**Plan element**: Task 5 updates many docs but the plan does not explicitly mention updating `/Users/ben/github/benpeter/despicable-agents/CLAUDE.md` itself, which currently states:
- "`/despicable-prompter` -- project-local skill to coach intent-focused `/nefario` briefings (`.claude/skills/despicable-prompter/`)"
- "Symlinks all agents to ~/.claude/agents/ and /nefario skill to ~/.claude/skills/"

Both statements become stale after Tasks 3 (prompter promotion) and the install.sh update. Task 5's file list does not include CLAUDE.md.

**Fix**: Add CLAUDE.md to Task 5's file list with instructions to update the Structure section (prompter is now global at `skills/despicable-prompter/`) and the Deployment section (install.sh now installs 2 skills).

---

## Conflict Resolution Assessment

All six conflict resolutions are well-reasoned and aligned with CLAUDE.md engineering philosophy:

| Resolution | Alignment |
|---|---|
| Report path: keep `docs/history/nefario-reports/` default | Good -- avoids churn, backward-compatible |
| Scratch path: `$TMPDIR`-based | Good -- ephemeral data belongs in temp |
| First-run README: skip | Good -- YAGNI, respects user's project |
| Prompter context reading: defer | Good -- scope containment |
| Greenfield git: include as defensive guard | Good -- robustness, not a feature |
| `init-hooks`: defer | Good -- YAGNI, avoids jq dependency |
| Default branch: dynamic lookup | Good -- correctness fix, not a feature |

---

## Deferred Items Assessment

| Deferred Item | Should it be pulled in? | Rationale |
|---|---|---|
| Prompter context reading | No | Feature addition, not decoupling |
| `init-hooks` bootstrap | No | Complex, jq dependency, YAGNI |
| First-run README | No | YAGNI, footprint concern |

All deferred items are correctly deferred. None should be pulled in.

---

## Summary

The plan is well-aligned with the user's stated intent. The six tasks map cleanly to the decoupling goal. Conflict resolutions are sound and YAGNI-consistent. Five non-blocking advisories:

1. Clarify that R5 (prompter context) is satisfied by global promotion
2. Remove `NEFARIO_REPORTS_DIR` env var (YAGNI)
3. Constrain README restructuring in Task 5 to path updates only
4. (Informational) Test count growth is proportionate
5. Add CLAUDE.md to Task 5 update list
