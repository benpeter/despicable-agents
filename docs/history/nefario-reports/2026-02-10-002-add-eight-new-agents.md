---
type: nefario-report
version: 1
date: "2026-02-10"
sequence: 002
task: "Add 8 new agents to the team (lucy, margo, accessibility, seo, sitespeed, api-spec, code-review, product-marketing)"
mode: full
agents-involved: [nefario, software-docs-minion, test-minion, security-minion, ux-strategy-minion, lucy, margo]
task-count: 16
gate-count: 1
outcome: completed
---

| Metric | Value |
|--------|-------|
| Date | 2026-02-10 |
| Task | Add 8 new agents to the despicable-agents team |
| Duration | ~90m (across 2 sessions due to context limit) |
| Outcome | completed |
| Planning Agents | 5 agents consulted |
| Review Agents | 7 reviewers (6 ALWAYS + 1 conditional) |
| Execution Agents | 11 /lab builds in parallel |
| Gates Presented | 1 of 1 approved |
| Files Changed | 16 created, 16 modified |
| Outstanding Items | 1 item (install.sh arithmetic bug) |

## Executive Summary

Added 8 new agents expanding the team from 19 to 27: 2 governance agents (lucy, margo) as top-level directories and 6 new minions (accessibility-minion, seo-minion, sitespeed-minion, api-spec-minion, code-review-minion, product-marketing-minion). Each agent received full /lab research and build. Three existing agents were rebuilt with narrowed boundaries (api-design-minion, ux-design-minion, frontend-minion bumped to v1.1). Nefario was updated to v1.5 with expanded roster, delegation table (+35 rows), and Phase 3.5 reviewer table (6 ALWAYS + 4 conditional). All downstream files updated (CLAUDE.md, README.md, install.sh, 5 docs files, lab SKILL.md).

## Decisions

#### Decision: Agent Directory Structure

**Rationale**:
- lucy and margo placed as top-level directories (like gru/nefario) to signal governance role
- Rejected: making them minions (they serve structurally different role -- review every plan, not execute domain work)
- Top-level directories signal the four-tier hierarchy: Boss, Foreman, Governance, Minions

#### Decision: Boundary Adjustments for Existing Agents

**Rationale**:
- api-design-minion v1.1: Narrowed to exclude OpenAPI spec authoring (now api-spec-minion)
- ux-design-minion v1.1: WCAG deep work delegated to accessibility-minion
- frontend-minion v1.1: Performance measurement delegated to sitespeed-minion
- Each boundary change creates a clean handoff point with the new specialist

**Conflict Resolutions**: None. All specialists agreed on boundary delineations during planning.

## Phases Executed

| Phase | Agents |
|-------|--------|
| Meta-plan | nefario |
| Specialist Planning | software-docs-minion, test-minion, ux-strategy-minion |
| Synthesis | nefario |
| Architecture Review | security-minion, test-minion, ux-strategy-minion, software-docs-minion, lucy, margo, software-docs-minion (BLOCK then APPROVE) |
| Execution | 11 /lab build agents (parallel), vendor-neutral fix agent, cross-check agent |

## Files Created/Modified

| File Path | Action | Description |
|-----------|--------|-------------|
| lucy/AGENT.md | created | Governance agent: intent alignment, repo conventions |
| lucy/RESEARCH.md | created | Backing research for lucy |
| margo/AGENT.md | created | Governance agent: simplicity enforcement, YAGNI/KISS |
| margo/RESEARCH.md | created | Backing research for margo |
| minions/accessibility-minion/AGENT.md | created | WCAG 2.2 conformance specialist |
| minions/accessibility-minion/RESEARCH.md | created | Backing research |
| minions/seo-minion/AGENT.md | created | SEO and GEO specialist |
| minions/seo-minion/RESEARCH.md | created | Backing research |
| minions/sitespeed-minion/AGENT.md | created | Core Web Vitals and performance |
| minions/sitespeed-minion/RESEARCH.md | created | Backing research |
| minions/api-spec-minion/AGENT.md | created | OpenAPI/AsyncAPI spec authoring |
| minions/api-spec-minion/RESEARCH.md | created | Backing research |
| minions/code-review-minion/AGENT.md | created | Code quality review specialist |
| minions/code-review-minion/RESEARCH.md | created | Backing research |
| minions/product-marketing-minion/AGENT.md | created | Product positioning and messaging |
| minions/product-marketing-minion/RESEARCH.md | created | Backing research |
| minions/api-design-minion/AGENT.md | modified | v1.1: boundary narrowed for api-spec-minion |
| minions/ux-design-minion/AGENT.md | modified | v1.1: a11y deep work to accessibility-minion |
| minions/frontend-minion/AGENT.md | modified | v1.1: perf measurement to sitespeed-minion |
| nefario/AGENT.generated.md | modified | v1.5 baseline from /lab build |
| nefario/AGENT.md | modified | v1.5 merged (generated + overrides) |
| the-plan.md | modified | 8 new agent specs, expanded delegation table |
| nefario/AGENT.overrides.md | modified | Added 4 new Phase 3.5 reviewer rows |
| CLAUDE.md | modified | Agent count 19→27, added lucy/margo dirs |
| README.md | modified | Agent count 19→27, expanded roster table |
| install.sh | modified | Added lucy/margo symlink blocks |
| docs/architecture.md | modified | Updated hierarchy, groups, mermaid diagrams |
| docs/orchestration.md | modified | Updated Phase 3.5 reviewer table |
| docs/build-pipeline.md | modified | Updated counts 19→27 |
| docs/decisions.md | modified | Updated counts, added Decision 20 |
| .claude/skills/lab/SKILL.md | modified | Updated counts, file locations table |

## Approval Gates

| Gate Title | Agent | Confidence | Outcome | Rounds |
|------------|-------|------------|---------|--------|
| the-plan.md spec changes | nefario | HIGH | approved | 1 |

## Outstanding Items

- [ ] install.sh has a pre-existing bug: `((installed_count++))` with `set -e` fails when count starts at 0. New agent symlinks were created manually. The script needs a fix (e.g., `installed_count=$((installed_count + 1))` or `((++installed_count))` or `|| true`).

## Timing

| Phase | Duration |
|-------|----------|
| Meta-plan | ~3m |
| Specialist Planning | ~5m |
| Synthesis | ~5m |
| Architecture Review | ~8m (1 BLOCK + revision) |
| Execution (Task 1-11: specs + /lab) | ~45m |
| Execution (Task 13-16: merge + downstream + deploy) | ~20m |
| Wrap-up | ~5m |
| **Total** | **~90m** |
