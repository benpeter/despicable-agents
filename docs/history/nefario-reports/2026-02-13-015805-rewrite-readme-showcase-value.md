---
type: nefario-report
version: 3
date: "2026-02-13"
time: "01:58:05"
task: "Rewrite README to showcase what despicable-agents uniquely provides"
mode: full
agents-involved: [product-marketing-minion, ux-strategy-minion, user-docs-minion, lucy, margo, security-minion, test-minion, software-docs-minion, nefario]
task-count: 1
gate-count: 1
outcome: completed
---

# Rewrite README to showcase what despicable-agents uniquely provides

## Summary

Rewrote README.md with a value-first structure that communicates what despicable-agents provides over simpler agent setups within 60 seconds. Added "What You Get" section covering four differentiators (phased orchestration, research-backed domain experts, built-in governance, goodies), merged duplicate Examples/Try It sections, rewrote How It Works as a user-experience flow, and corrected the "six mandatory reviewers" error to five. A documentation audit identified 4 MUST-fix items in decisions.md for follow-up.

## Original Prompt

> Rewrite README to showcase what despicable-agents uniquely provides
>
> **Outcome**: The README clearly communicates what despicable-agents gives you that simpler agent setups don't, so that someone evaluating the project understands its value proposition within 60 seconds of reading. Currently the README describes low-level structure without conveying the system's distinctive capabilities.
>
> **Success criteria**:
> - README contains a "What You Get" section before Examples that covers the structure draft below
> - Examples section is updated to demonstrate capabilities that justify multi-agent orchestration (not things a single agent could do equally well)
> - All existing README sections are reviewed and updated where they undersell or fail to differentiate the system
> - No inaccuracies introduced — all claims match current codebase capabilities
> - README remains scannable (bullet-based, no walls of text)

## Key Design Decisions

#### Value-first opening over structural description

**Rationale**:
- All four specialists agreed the current README leads with architecture ("a team of domain specialists, an orchestrator...") when it should lead with what the user gets
- First-time evaluators need to understand "why this over a single Claude Code session" within 15 seconds

**Alternatives Rejected**:
- Keep structural opening with a value paragraph below: rejected because the first sentence determines whether readers continue

#### Merge Examples and Try It into single section

**Rationale**:
- Both sections demonstrated the same invocation patterns with near-identical examples (@security-minion appeared in both)
- Merging frees ~20 lines for the new "What You Get" section without increasing total README length

**Alternatives Rejected**:
- Keep separate sections with different focus: rejected because the cognitive load of "didn't I just read this?" outweighs any benefit of separating single-agent from orchestrated examples

#### Five mandatory reviewers (correcting from six)

**Rationale**:
- Four canonical sources (the-plan.md, nefario/AGENT.md, skills/nefario/SKILL.md, docs/orchestration.md) consistently list five mandatory reviewers
- ux-strategy-minion was moved from mandatory to discretionary pool

**Alternatives Rejected**:
- Leave as six: rejected because it's factually wrong

#### Reframe "mostly vibe-coded" limitation

**Rationale**:
- The vibe-coded badge serves as a personality signal and social hook on GitHub
- Repeating the same framing as a limitation header undermines the substance the README establishes
- Changed to "AI-assisted prompt authoring" while keeping the same explanatory text

**Alternatives Rejected**:
- Remove limitation entirely: rejected because honesty about AI-assisted authoring builds trust
- Remove badge: rejected because it has GitHub discovery value

### Conflict Resolutions

None. All four specialists converged on the same structural recommendations. The reviewer count correction was unanimously flagged.

## Phases

### Phase 1: Meta-Plan

Nefario analyzed the task and identified three specialists for planning: product-marketing-minion (value proposition and positioning), ux-strategy-minion (60-second scan target and progressive disclosure), and user-docs-minion (accuracy verification). The user requested adding lucy (governance alignment) during the team approval gate. Four project-local skills were discovered (despicable-lab, despicable-statusline, despicable-prompter, nefario); none were relevant to execution.

### Phase 2: Specialist Planning

Four specialists contributed in parallel. product-marketing-minion drafted the "What You Get" structure and filled the gap placeholders (governance gates, install-once-available-everywhere, status line integration). ux-strategy-minion mapped the information journey and proposed progressive disclosure ordering. user-docs-minion verified claims against the codebase and flagged the "six mandatory reviewers" error. lucy identified the same reviewer count error against four canonical sources and flagged undersold governance capabilities.

### Phase 3: Synthesis

Nefario synthesized a single-task plan: one product-marketing-minion execution with one approval gate. Seven conflict resolutions were recorded (reviewer count, agent count precision, vibe-coded badge, Examples/Try It merge, section ordering, experimental framing removal, governance depth vs. scannability). Model was upgraded from sonnet to opus per lucy's review and user instruction.

### Phase 3.5: Architecture Review

Five mandatory reviewers examined the plan. security-minion APPROVED (no attack surface). test-minion ADVISED (link validation, automated fact-checking). software-docs-minion ADVISED (8-item documentation impact checklist). lucy ADVISED (model mismatch, Phase 7 omission in description, skill directory ordering). margo ADVISED (prompt over-prescriptive, but single-task structure correct). All advisories folded into the execution prompt.

### Phase 4: Execution

product-marketing-minion rewrote [README.md](../../README.md) in a single pass: 141 lines with the value-first structure. All seven critical accuracy claims verified against source files. The approval gate was presented and approved.

### Phase 5: Code Review

Skipped (no executable code produced -- README.md only).

### Phase 6: Test Execution

Skipped (no test infrastructure for README content).

### Phase 7: Deployment

Skipped (not requested).

### Phase 8: Documentation

software-docs-minion audited all docs/ files for inconsistencies with the rewritten README. Found 4 MUST-fix items in decisions.md (stale "6 ALWAYS reviewers" references) and 2 SHOULD-fix items (ambiguous "six dimensions/groups" references). A follow-up nefario prompt was written to the companion directory for subsequent remediation. No files were edited (docs/ changes were explicitly de-scoped).

<details>
<summary>Agent Contributions (4 planning, 5 review)</summary>

### Planning

**product-marketing-minion**: Drafted value proposition and "What You Get" structure. Filled gap placeholders with governance gates and install-once-available-everywhere.
- Adopted: all four "What You Get" bullets, Examples/Try It merge, section reordering
- Risks flagged: overpromising, agent count confusion, vibe-coded badge vs credibility

**ux-strategy-minion**: Mapped information journey, proposed progressive disclosure ordering.
- Adopted: section order (value, what you get, examples, install, how it works, agents, docs, limitations), merge Examples/Try It
- Risks flagged: "What You Get" must contain demonstrable outcomes

**user-docs-minion**: Verified README claims against codebase, flagged reviewer count error.
- Adopted: outcome language over inventory language, five-reviewer correction
- Risks flagged: overpromising as top risk

**lucy**: Identified five-reviewer error against four canonical sources, flagged undersold governance.
- Adopted: reviewer count correction, governance visibility improvements, model upgrade to opus
- Risks flagged: accuracy claims contradicted by canonical spec

### Architecture Review

**security-minion**: APPROVE. No security concerns -- static markdown only.

**test-minion**: ADVISE. Recommended link validation and automated fact-checking steps.

**software-docs-minion**: ADVISE. Produced 8-item documentation impact checklist for Phase 8.

**lucy**: ADVISE. Flagged model mismatch (sonnet vs opus spec), Phase 7 omission, skill directory ordering.

**margo**: ADVISE. Noted prompt over-prescriptive but single-task structure with one gate is appropriate simplicity.

</details>

## Execution

### Tasks

| # | Task | Agent | Status |
|---|------|-------|--------|
| 1 | Rewrite README.md with value-first structure | product-marketing-minion | completed |

### Files Changed

| File Path | Action | Description |
|-----------|--------|-------------|
| [README.md](../../README.md) | modified | Full rewrite: value-first structure, "What You Get" section, merged Examples, rewritten How It Works, corrected reviewer count, reframed limitations |

### Approval Gates

| Gate Title | Agent | Confidence | Outcome | Rounds |
|------------|-------|------------|---------|--------|
| Rewrite README.md | product-marketing-minion | HIGH | approved | 1 |

#### Rewrite README.md

**Decision**: Accept the complete README rewrite with value-first structure (141 lines).
**Rationale**: Opens with outcomes, "What You Get" covers all four required bullets, all accuracy claims verified, merged duplicate sections, 141 lines within 120-150 target.
**Rejected**: Marketing buzzwords, experimental framing, separate Try It section, six-reviewer claim.
**Confidence**: HIGH
**Outcome**: approved

## Verification

| Phase | Result |
|-------|--------|
| Code Review | Skipped (no executable code) |
| Test Execution | Skipped (no test infrastructure) |
| Deployment | Skipped (not requested) |
| Documentation | Audit completed: 4 MUST findings in decisions.md, 2 SHOULD findings. Follow-up prompt written. |

## Working Files

<details>
<summary>Working files (28 files)</summary>

Companion directory: [2026-02-13-015805-rewrite-readme-showcase-value/](./2026-02-13-015805-rewrite-readme-showcase-value/)

- [Original Prompt](./2026-02-13-015805-rewrite-readme-showcase-value/prompt.md)

**Outputs**
- [Phase 1: Meta-plan](./2026-02-13-015805-rewrite-readme-showcase-value/phase1-metaplan.md)
- [Phase 2: product-marketing-minion](./2026-02-13-015805-rewrite-readme-showcase-value/phase2-product-marketing-minion.md)
- [Phase 2: ux-strategy-minion](./2026-02-13-015805-rewrite-readme-showcase-value/phase2-ux-strategy-minion.md)
- [Phase 2: user-docs-minion](./2026-02-13-015805-rewrite-readme-showcase-value/phase2-user-docs-minion.md)
- [Phase 2: lucy](./2026-02-13-015805-rewrite-readme-showcase-value/phase2-lucy.md)
- [Phase 3: Synthesis](./2026-02-13-015805-rewrite-readme-showcase-value/phase3-synthesis.md)
- [Phase 3.5: security-minion](./2026-02-13-015805-rewrite-readme-showcase-value/phase3.5-security-minion.md)
- [Phase 3.5: test-minion](./2026-02-13-015805-rewrite-readme-showcase-value/phase3.5-test-minion.md)
- [Phase 3.5: software-docs-minion](./2026-02-13-015805-rewrite-readme-showcase-value/phase3.5-software-docs-minion.md)
- [Phase 3.5: docs checklist](./2026-02-13-015805-rewrite-readme-showcase-value/phase3.5-docs-checklist.md)
- [Phase 3.5: lucy](./2026-02-13-015805-rewrite-readme-showcase-value/phase3.5-lucy.md)
- [Phase 3.5: margo](./2026-02-13-015805-rewrite-readme-showcase-value/phase3.5-margo.md)
- [Phase 8: software-docs](./2026-02-13-015805-rewrite-readme-showcase-value/phase8-software-docs.md)
- [Follow-up: docs alignment prompt](./2026-02-13-015805-rewrite-readme-showcase-value/followup-docs-alignment-prompt.md)

**Prompts**
- [Phase 1: Meta-plan prompt](./2026-02-13-015805-rewrite-readme-showcase-value/phase1-metaplan-prompt.md)
- [Phase 2: product-marketing-minion prompt](./2026-02-13-015805-rewrite-readme-showcase-value/phase2-product-marketing-minion-prompt.md)
- [Phase 2: ux-strategy-minion prompt](./2026-02-13-015805-rewrite-readme-showcase-value/phase2-ux-strategy-minion-prompt.md)
- [Phase 2: user-docs-minion prompt](./2026-02-13-015805-rewrite-readme-showcase-value/phase2-user-docs-minion-prompt.md)
- [Phase 2: lucy prompt](./2026-02-13-015805-rewrite-readme-showcase-value/phase2-lucy-prompt.md)
- [Phase 3: Synthesis prompt](./2026-02-13-015805-rewrite-readme-showcase-value/phase3-synthesis-prompt.md)
- [Phase 3.5: security-minion prompt](./2026-02-13-015805-rewrite-readme-showcase-value/phase3.5-security-minion-prompt.md)
- [Phase 3.5: test-minion prompt](./2026-02-13-015805-rewrite-readme-showcase-value/phase3.5-test-minion-prompt.md)
- [Phase 3.5: software-docs-minion prompt](./2026-02-13-015805-rewrite-readme-showcase-value/phase3.5-software-docs-minion-prompt.md)
- [Phase 3.5: lucy prompt](./2026-02-13-015805-rewrite-readme-showcase-value/phase3.5-lucy-prompt.md)
- [Phase 3.5: margo prompt](./2026-02-13-015805-rewrite-readme-showcase-value/phase3.5-margo-prompt.md)
- [Phase 4: product-marketing-minion prompt](./2026-02-13-015805-rewrite-readme-showcase-value/phase4-product-marketing-minion-prompt.md)
- [Phase 8: software-docs-minion prompt](./2026-02-13-015805-rewrite-readme-showcase-value/phase8-software-docs-minion-prompt.md)

</details>
