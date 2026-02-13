---
type: nefario-report
version: 3
date: "2026-02-13"
time: "02:12:16"
task: "Add documentation for /despicable-statusline skill"
source-issue: 43
mode: full
agents-involved: [software-docs-minion, user-docs-minion, security-minion, test-minion, lucy, margo, code-review-minion, nefario]
task-count: 2
gate-count: 0
outcome: completed
---

# Add documentation for /despicable-statusline skill

## Summary

Documented the `/despicable-statusline` project-local skill in two existing documentation files. The Status Line section in `docs/using-nefario.md` now leads with the automated skill as the primary setup method, describes four user-perspective outcomes, and collapses the manual JSON config into a fallback block. A new Project-Local Skills subsection in `docs/deployment.md` distinguishes project-local skills from globally-installed ones.

## Original Prompt

> **Outcome**: The /despicable-statusline skill is documented in the project's docs so that users understand what it does, when to use it, and what it modifies before invoking it.
>
> **Success criteria**:
> - Skill is listed in relevant project documentation (README or docs/)
> - Documentation explains what the skill does, what it modifies (~/.claude/settings.json), and the four config states it handles
> - Documentation mentions idempotency and safety (backup/rollback)
>
> **Scope**:
> - In: Project-level documentation for the skill (README, docs/)
> - Out: Changes to the SKILL.md itself, changes to nefario's SKILL.md, statusline styling

## Key Design Decisions

#### Augment existing pages instead of creating a new doc

**Rationale**:
- The skill is a single-purpose setup utility, too small to justify its own documentation page
- Both `docs/using-nefario.md` (user-facing) and `docs/deployment.md` (contributor-facing) already have natural insertion points

**Alternatives Rejected**:
- New standalone `docs/statusline.md`: Would fragment the docs tree for a minor feature

#### No README changes

**Rationale**:
- The README already lists `/despicable-statusline` in the Structure section (CLAUDE.md line 13)
- The install line accurately describes what `install.sh` deploys (globally-installed skills only)
- The project-local vs. global distinction belongs in `docs/deployment.md`, not the README

**Alternatives Rejected**:
- Add project-local skills note to README: Would duplicate `docs/deployment.md` content and blur the README's role as concise introduction

#### User-perspective outcomes instead of state machine

**Rationale**:
- Users think "I have no status line configured" not "I am in State A"
- Four bullet points describing outcomes are more scannable than a state transition diagram

**Alternatives Rejected**:
- State A/B/C/D labels in user docs: Implementation detail that doesn't help users

### Conflict Resolutions

user-docs-minion proposed adding a project-local skills note to the README. software-docs-minion argued against it because the README already references the skill and the install scope would be misrepresented. Resolved in favor of no README change -- the distinction belongs in `docs/deployment.md`.

## Phases

### Phase 1: Meta-Plan

Identified this as a documentation-only task requiring two specialists: software-docs-minion for architectural placement and user-docs-minion for user-facing presentation. All cross-cutting concerns (testing, security, observability) were excluded as not applicable. Two project-local skills discovered but neither used as execution tools.

### Phase 2: Specialist Planning

software-docs-minion recommended augmenting two existing pages with no new standalone doc. Flagged manual JSON drift risk. user-docs-minion recommended presenting config states as user-perspective outcomes with a single before/after example. Flagged project-local discoverability as a risk. The two specialists disagreed on README changes.

### Phase 3: Synthesis

Merged both contributions into a 2-task parallel plan. Resolved the README conflict in favor of no change. No approval gates needed -- both tasks are additive markdown edits with zero downstream dependents.

### Phase 3.5: Architecture Review

Five mandatory reviewers (security-minion, test-minion, software-docs-minion, lucy, margo) all returned APPROVE. No discretionary reviewers needed -- the plan produces only text edits to existing documentation files.

### Phase 4: Execution

Both tasks executed in parallel. user-docs-minion restructured the Status Line section in `docs/using-nefario.md` (+19 lines net). software-docs-minion added the Project-Local Skills subsection to `docs/deployment.md` (+12 lines net).

### Phase 5: Code Review

Three reviewers (code-review-minion, lucy, margo) all returned APPROVE. NITs noted: margo suggested trimming the backup filename from user-facing docs (acceptable as-is), lucy noted the model name in the example will go stale (minor).

### Phase 6: Test Execution

Skipped (no test infrastructure, no tests produced).

### Phase 7: Deployment

Skipped (not requested).

### Phase 8: Documentation

The Phase 3.5 documentation impact checklist had 4 items, all satisfied by the execution tasks themselves. Cross-reference link from `docs/deployment.md` to `using-nefario.md#status-line` verified. SKILL.md authoritative source reference verified in the manual fallback block. No additional documentation work needed.

<details>
<summary>Agent Contributions (2 planning, 5 review)</summary>

### Planning

**software-docs-minion**: Recommended augmenting two existing pages (using-nefario.md and deployment.md) with no new standalone doc.
- Adopted: Two-page strategy, no README change, cross-reference pattern
- Risks flagged: Manual JSON snippet drift from skill's actual command

**user-docs-minion**: Recommended presenting config states as user-perspective outcomes with brief safety callout and progressive disclosure via collapsed manual section.
- Adopted: Four-outcome bullet list, safety note, `<details>` fallback block
- Risks flagged: Duplication between manual/automated docs, project-local discoverability, State D user experience

### Architecture Review

**security-minion**: APPROVE. No security concerns -- documentation-only plan with no attack surface.

**test-minion**: APPROVE. No testable claims -- documentation describes existing implemented behavior.

**software-docs-minion**: APPROVE. Documentation impact checklist produced (4 items). Plan has adequate coverage.

**lucy**: APPROVE. All user requirements covered. No scope creep, no convention violations.

**margo**: APPROVE. Plan is proportional. Two tasks for two files, no bloat.

### Code Review

**code-review-minion**: APPROVE. Markdown well-formed, links valid, technical details accurate against SKILL.md.

**lucy**: APPROVE. Tightly scoped to stated intent. No drift, no convention violations.

**margo**: APPROVE. Documentation proportional to feature. No unnecessary abstractions.

</details>

## Execution

### Tasks

| # | Task | Agent | Status |
|---|------|-------|--------|
| 1 | Restructure Status Line section in docs/using-nefario.md | user-docs-minion | completed |
| 2 | Add project-local skills to docs/deployment.md Skills section | software-docs-minion | completed |

### Files Changed

| File Path | Action | Description |
|-----------|--------|-------------|
| [docs/using-nefario.md](../../using-nefario.md) | modified | Restructured Status Line section: leads with automated skill, four user-perspective outcomes, safety note, collapsed manual fallback |
| [docs/deployment.md](../../deployment.md) | modified | Added Project-Local Skills subsection with table listing /despicable-lab and /despicable-statusline |

### Approval Gates

No approval gates in this plan.

## Verification

| Phase | Result |
|-------|--------|
| Code Review | 3 APPROVE (code-review-minion, lucy, margo) |
| Test Execution | Skipped (no test infrastructure) |
| Deployment | Skipped (not requested) |
| Documentation | Checklist fulfilled by execution (4/4 items verified) |

<details>
<summary>Working Files (21 files)</summary>

Companion directory: [2026-02-13-021216-add-despicable-statusline-docs/](./2026-02-13-021216-add-despicable-statusline-docs/)

- [Original Prompt](./2026-02-13-021216-add-despicable-statusline-docs/prompt.md)

**Outputs**
- [Phase 1: Meta-plan](./2026-02-13-021216-add-despicable-statusline-docs/phase1-metaplan.md)
- [Phase 2: software-docs-minion](./2026-02-13-021216-add-despicable-statusline-docs/phase2-software-docs-minion.md)
- [Phase 2: user-docs-minion](./2026-02-13-021216-add-despicable-statusline-docs/phase2-user-docs-minion.md)
- [Phase 3: Synthesis](./2026-02-13-021216-add-despicable-statusline-docs/phase3-synthesis.md)
- [Phase 3.5: docs-checklist](./2026-02-13-021216-add-despicable-statusline-docs/phase3.5-docs-checklist.md)
- [Phase 3.5: software-docs-minion](./2026-02-13-021216-add-despicable-statusline-docs/phase3.5-software-docs-minion.md)
- [Phase 5: code-review-minion](./2026-02-13-021216-add-despicable-statusline-docs/phase5-code-review-minion.md)
- [Phase 5: lucy](./2026-02-13-021216-add-despicable-statusline-docs/phase5-lucy.md)
- [Phase 5: margo](./2026-02-13-021216-add-despicable-statusline-docs/phase5-margo.md)

**Prompts**
- [Phase 1: Meta-plan prompt](./2026-02-13-021216-add-despicable-statusline-docs/phase1-metaplan-prompt.md)
- [Phase 2: software-docs-minion prompt](./2026-02-13-021216-add-despicable-statusline-docs/phase2-software-docs-minion-prompt.md)
- [Phase 2: user-docs-minion prompt](./2026-02-13-021216-add-despicable-statusline-docs/phase2-user-docs-minion-prompt.md)
- [Phase 3: Synthesis prompt](./2026-02-13-021216-add-despicable-statusline-docs/phase3-synthesis-prompt.md)
- [Phase 3.5: security-minion prompt](./2026-02-13-021216-add-despicable-statusline-docs/phase3.5-security-minion-prompt.md)
- [Phase 3.5: test-minion prompt](./2026-02-13-021216-add-despicable-statusline-docs/phase3.5-test-minion-prompt.md)
- [Phase 3.5: software-docs-minion prompt](./2026-02-13-021216-add-despicable-statusline-docs/phase3.5-software-docs-minion-prompt.md)
- [Phase 3.5: lucy prompt](./2026-02-13-021216-add-despicable-statusline-docs/phase3.5-lucy-prompt.md)
- [Phase 3.5: margo prompt](./2026-02-13-021216-add-despicable-statusline-docs/phase3.5-margo-prompt.md)
- [Phase 4: user-docs-minion prompt](./2026-02-13-021216-add-despicable-statusline-docs/phase4-user-docs-minion-prompt.md)
- [Phase 4: software-docs-minion prompt](./2026-02-13-021216-add-despicable-statusline-docs/phase4-software-docs-minion-prompt.md)

</details>
