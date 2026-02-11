# Lucy Review: External Skill Integration

## Verdict: ADVISE

---

## Requirement Traceability

| # | Requirement (from issue #29 prompt.md) | Plan Element | Status |
|---|----------------------------------------|--------------|--------|
| R1 | Loose coupling -- external skills keep their own patterns | AGENT.md: no mandatory metadata; docs/external-skills.md "What NOT to Do" section | COVERED |
| R2 | Two usage modes: (a) drop into existing project, (b) skill maintainer documents integration surface | docs/external-skills.md: "How It Works" (user) + "For Skill Maintainers" (maintainer) | COVERED |
| R3 | No forking or modifying despicable-agents | Prompt-only changes, filesystem-as-registry | COVERED |
| R4 | Discovery of project-local skills during meta-plan | AGENT.md "Discovery" subsection, SKILL.md Phase 1 discovery step | COVERED |
| R5 | Execution-phase agents can invoke external skills | AGENT.md "Deferral Pattern" (LEAF: Available Skills in task prompts; ORCHESTRATION: deferred macro-task) | COVERED |
| R6 | No coupling direction from external skills back to despicable-agents | docs/external-skills.md "What NOT to Do": no despicable-agents-specific metadata, no coupling back | COVERED |
| R7 | Nefario defers to external orchestration skills (e.g., CDD phased workflow) | AGENT.md "Deferral Pattern"; SKILL.md Phase 4 "Deferred Tasks" section | COVERED |
| R8 | Precedence rules for overlapping domains | AGENT.md "Precedence" subsection (three tiers) | COVERED |
| R9 | Documentation from both perspectives (user + maintainer) | docs/using-nefario.md "Working with Project Skills" (user); docs/external-skills.md "For Skill Maintainers" (maintainer) | COVERED |
| R10 | Works with existing distribution (gh-upskill, etc.) | Implicit: filesystem scan has no opinion on installation method | COVERED |
| R11 | Acceptance test: CDD project + /nefario 'build a new block' uses CDD skill | Not executable (prompt-only changes), but the meta-plan discovery + deferral mechanism addresses the scenario | COVERED (design-level) |

All stated requirements have corresponding plan elements. No stated requirements are missing from the implementation.

---

## Findings

### 1. [CONVENTION] `the-plan.md` is untouched

Verified: `the-plan.md` contains zero matches for external-skill-related terms (`external skill`, `DEFERRED`, `discovery`, `precedence`). CLAUDE.md rule "Do NOT modify the-plan.md" is respected.

No action needed.

### 2. [COMPLIANCE] All artifacts in English

Verified: All 7 changed files are in English. Headers, body text, code examples, YAML frontmatter, and Mermaid diagrams are all English. Compliant with CLAUDE.md "All technical artifacts must be in English" directive.

No action needed.

### 3. [COMPLIANCE] Engineering philosophy (YAGNI/KISS/Helix Manifesto)

The implementation follows the stated philosophy well:
- Filesystem IS the registry (no new config files, no manifest, no skill catalog)
- Classification is a judgment call, not a scoring system
- No new scripts, no install.sh changes, no new tooling
- All changes are prompt text and documentation

Margo's Phase 3.5 review noted the same alignment. The only complexity introduced (`<external-skill>` content boundary tags) parallels the existing `<github-issue>` pattern.

No action needed.

### 4. [CONVENTION] Agent boundaries maintained

Nefario's boundaries ("What You Do NOT Do") are preserved. Discovery and delegation are coordination concerns, which are squarely in nefario's scope. The mechanism does not have nefario performing specialist work -- it routes to external skills the same way it routes to internal agents. Cross-cutting agents (security-minion, test-minion, lucy, margo) are explicitly preserved from override by external skills (AGENT.md "Precedence" tier 3 exception + docs/external-skills.md "Cross-Cutting Exception").

No action needed.

### 5. [ADVISE] docs/external-skills.md: `realpath` validation mentioned but not in SKILL.md

AGENT.md line 205 specifies: "Validate discovered paths with `realpath` to confirm they resolve within expected parent directories. Reject paths that escape via symlinks to unexpected locations." The docs/external-skills.md "Path Validation" section (line 43) echoes this.

However, the SKILL.md Phase 1 discovery instructions (lines 335-339) list steps a-e for the discovery sub-procedure but do not include a `realpath` validation step. If the calling session follows only the SKILL.md instructions (which it reads first), the path validation from AGENT.md may not be executed because it depends on the subagent (nefario) rather than the calling session performing it.

This is low severity because nefario-the-subagent reads its own AGENT.md and has the instruction. But the SKILL.md step list is what the calling session uses to formulate the prompt, and step 2 enumerates sub-steps a-e explicitly -- a reader might expect completeness.

RECOMMENDATION: Add a sub-step to SKILL.md Phase 1 step 2 (between current e and the closing of step 2): `f. Validate discovered paths with realpath (see External Skill Integration in your Core Knowledge)`.

### 6. [ADVISE] docs/external-skills.md line 8 references non-existent anchor

Line 8: `[Orchestration and Delegation](orchestration.md)`. Verified this file exists.

Line 7: `[Using Nefario](using-nefario.md)`. Verified this file exists.

Line 1: `[< Back to Architecture Overview](architecture.md)`. Verified this file exists.

All cross-references resolve. No action needed here.

### 7. [ADVISE] Minor: docs/external-skills.md "Known Limitations" -- missing frontmatter warning

Line 94: "Skills without a `name` or `description` in their SKILL.md frontmatter are skipped during discovery. No warning is surfaced."

The original issue success criteria include: "External skills do not need to be restructured, renamed, or moved to work with despicable-agents." Silently skipping skills with missing frontmatter could confuse a user who expects their skill to be discovered. This is a known-limitation callout, which is appropriate documentation, but a one-line ADVISE-level warning during meta-plan output (e.g., "Skipped 2 skills with missing frontmatter: .skills/foo, .skills/bar") would improve the user experience.

This is not a code change -- it would be a one-sentence addition to the AGENT.md discovery instructions. Low severity; the current documentation honestly flags the gap.

RECOMMENDATION: Consider adding to AGENT.md Discovery step 3: "If a SKILL.md lacks `name` or `description`, skip it and note the skip in the meta-plan output for user visibility."

### 8. [CONVENTION] Decision 28 format consistency

Decision 28 in `/Users/ben/github/benpeter/2despicable/3/docs/decisions.md` (lines 367-378) follows the established format: Status, Date, Choice, Alternatives rejected, Rationale, Consequences. All fields are present. The section heading and table structure match the pattern of Decisions 1-27.

No action needed.

### 9. [CONVENTION] architecture.md changes are minimal and consistent

The Composable bullet was extended with one clause about external skills. The Sub-Documents table gained one row for External Skill Integration. Both changes are proportional and follow the existing format.

No action needed.

### 10. [CONVENTION] README.md change is minimal

Two lines added: one sentence about external skill discovery in the "Using on Other Projects" section, and a link to docs/external-skills.md. This is proportional to a Tier 2 (Notable Enhancement) -- the feature is mentioned where it is relevant without inflating the README.

No action needed.

---

## Scope Assessment

No scope creep detected. The implementation delivers exactly what the issue requested:
- Discovery mechanism (AGENT.md + SKILL.md)
- Classification heuristic (ORCHESTRATION vs LEAF)
- Precedence rules (three tiers)
- Deferral pattern (macro-tasks for orchestration skills)
- Documentation from both user and maintainer perspectives
- No new code, scripts, or infrastructure

The changes are proportional to the problem: ~82 lines in AGENT.md, ~45 lines in SKILL.md, ~157 lines in a new architecture doc, ~28 lines in a user-facing doc, and small cross-reference updates. All prompt text and documentation.

---

## Summary

Two non-blocking advisories (SKILL.md completeness of discovery sub-steps, silent skip of skills with missing frontmatter). Both are polish items that could be addressed in a follow-up. The implementation is well-aligned with the original issue intent, compliant with CLAUDE.md conventions, and proportional in complexity. `the-plan.md` is untouched. Agent boundaries are maintained. All artifacts are in English.

VERDICT: ADVISE
WARNINGS:
- [convention] SKILL.md Phase 1 discovery sub-steps
  TASK: Task 2 (SKILL.md changes)
  CHANGE: Discovery sub-steps a-e in Phase 1 prompt template omit realpath validation that AGENT.md specifies
  RECOMMENDATION: Add sub-step f referencing realpath validation from Core Knowledge

- [usability] Silent skip of frontmatter-less skills
  TASK: Task 1 (AGENT.md changes)
  CHANGE: Discovery step 3 silently skips skills without name/description -- no user visibility
  RECOMMENDATION: Add a note in discovery instructions to surface skipped skills in meta-plan output
