---
type: nefario-report
version: 3
date: "2026-02-13"
time: "11:46:22"
task: "Propose description, website, and topics for the GitHub About section"
mode: advisory
agents-involved: [product-marketing-minion, seo-minion, ux-strategy-minion, lucy, nefario]
task-count: 0
gate-count: 0
outcome: completed
---

# Propose description, website, and topics for the GitHub About section

## Summary

Four specialists analyzed the despicable-agents GitHub About section (currently empty) across product positioning, SEO discoverability, UX strategy, and project consistency. The team reached strong consensus: lead with "specialist agent team for Claude Code," highlight governance gates as the primary differentiator, use 8 curated topics anchored by `claude-code` and `ai-agents`, and leave the website field blank. Confidence is HIGH because all recommendations are grounded in the project's existing canonical language and the decision is easily reversible.

## Original Prompt

> Propose description, website, topics for the GH about section of the repo.

## Key Design Decisions

#### Description length: short (106 chars) vs. long (299 chars)

**Rationale**:
- The short version survives GitHub's truncation in all display contexts (search results, sidebar, pinned repos, org pages)
- The README already handles the longer pitch one click away
- The 106-char version is complete: it answers what, where, how many, and why-different

**Alternatives Rejected**:
- 299-char version: adds domain list, reviewer count, and install convenience, but this detail only displays on the repo page sidebar, not in search results. Viable alternative if maximum information density is preferred.

#### Topic count: 8 topics

**Rationale**:
- 8 is the balance point between lucy's conservative 5-7 (accuracy-first) and seo-minion's expansive 10 (coverage-first)
- Every included topic is verified-accurate against the canonical docs
- Below the 20-topic GitHub maximum, above the minimum for adequate discovery

**Alternatives Rejected**:
- 5-7 topics: misses ecosystem anchors (`anthropic`, `developer-tools`) that cost nothing to include
- 10 topics: includes `prompt-engineering` (attracts wrong audience) and `agent-teams` (not yet established)

### Conflict Resolutions

**Description length**: ux-strategy-minion (106 chars) vs. product-marketing-minion (299 chars). Resolved in favor of short -- survives truncation everywhere, matches README's concise style. Long version preserved as explicit alternative.

**`claude` topic inclusion**: seo-minion excluded (redundant with `claude-code`), product-marketing and ux-strategy included. Resolved in favor of inclusion -- 6,927 repos, zero cost, exact target audience.

**`prompt-engineering` topic**: seo-minion included, others excluded. Resolved in favor of exclusion -- while technically accurate, the topic attracts developers seeking prompt templates, not an agent team.

## Phases

### Phase 1: Meta-Plan

Nefario identified three specialists for planning: product-marketing-minion (value proposition and competitive positioning), seo-minion (GitHub topic strategy), and ux-strategy-minion (first-impression information hierarchy). Lucy was added at the user's request to verify consistency with the project's established identity. No external skills were relevant to this metadata task.

### Phase 2: Specialist Planning

**product-marketing-minion** analyzed the competitive landscape (wshobson/agents, ruvnet/claude-flow, VoltAgent) and identified governance gates as an uncontested positioning axis. Proposed three candidate descriptions with trade-off analysis. Recommended "fun names, serious descriptions" as the tone principle.

**seo-minion** researched 12 GitHub topic ecosystems, examining repository counts and usage patterns across 6 comparable repos. Proposed 10 topics in three tiers (platform identity, domain descriptors, ecosystem anchors). Deliberately excluded `llm` (too broad at 39k repos), `framework` (inaccurate), and `autonomous-agents` (misleading).

**ux-strategy-minion** grounded the description in cognitive science -- the satisficing two-stage pattern where developers pattern-match in <2 seconds then assess value. Recommended leading with WHAT IT IS for fastest categorization. Analyzed GitHub truncation thresholds and determined the first ~100 characters must be self-sufficient.

**lucy** verified strong internal consistency across all canonical documents (CLAUDE.md, README.md, the-plan.md, architecture.md). The phrase "specialist agent team for Claude Code" appears in nearly identical form across all four. Provided an accuracy audit classifying potential topics as Accurate, Borderline, or Avoid.

### Phase 3: Synthesis

Nefario synthesized contributions into a unified advisory report. Strong consensus existed across all four specialists on the core recommendations. Two conflicts required resolution: description length (short vs. long) and topic composition (conservative vs. expansive). Both were resolved with clear rationale and the minority positions preserved as alternatives.

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

**product-marketing-minion**: Competitive analysis showing governance gates as uncontested differentiator. Three candidate descriptions with trade-off analysis. "Fun names, serious descriptions" tone principle.
- Adopted: governance-first positioning, 106-char description structure, topic recommendations for `claude-code`, `ai-agents`, `claude`, `developer-tools`
- Risks flagged: agent count staleness, quantity comparison with competitors claiming 100+ agents

**seo-minion**: Most detailed topic ecosystem research with repository counts for every relevant topic. Three-tier topic strategy (platform identity, domain descriptors, ecosystem anchors). Competitive topic analysis across 6 comparable repos.
- Adopted: tiered topic strategy, `claude-agents` early-presence play, `agent-orchestration` niche targeting, exclusion of `llm` and `framework`
- Risks flagged: emerging topic instability, quarterly review cadence recommendation

**ux-strategy-minion**: Cognitive science grounding for description structure (satisficing pattern). Truncation threshold analysis across GitHub display contexts. Theming impact assessment.
- Adopted: lead with WHAT IT IS, 106-char length target, "let name carry personality, description carry information"
- Risks flagged: description truncation varies, competitive positioning against quantity-claiming repos

**lucy**: Consistency audit across all canonical documents. Topic accuracy classification (Accurate/Borderline/Avoid). Identified that "specialist agent team for Claude Code" appears in all canonical docs.
- Adopted: reuse existing language, avoid new terminology, 5 "Avoid" topic exclusions (`framework`, `autonomous-agents`, `automation`, `mcp`, `ai-framework`)
- Risks flagged: agent count maintenance burden (accepted -- matches existing convention)

</details>

## Team Recommendation

**Use the short description (106 chars), leave website blank, apply 8 topics.**

### Consensus

| Position | Agents | Strength |
|----------|--------|----------|
| Lead with "specialist agent team for Claude Code" | All four | Unanimous |
| Governance gates as primary differentiator | All four | Unanimous |
| Leave website blank | All four | Unanimous |
| Fun names, serious descriptions | product-marketing, ux-strategy, lucy | Strong |
| Include exact count "27" | All four | Unanimous |
| Exclude `framework`, `autonomous-agents`, `automation` | All four | Unanimous |

### Recommended Values

**Description** (106 chars):

> Specialist agent team for Claude Code -- 27 domain experts with orchestration and governance gates.

**Alternative description** (299 chars):

> 27 specialist agents for Claude Code with phased orchestration and governance gates. Domain experts for security, testing, API design, infrastructure, and more -- each with strict boundaries. Five mandatory reviewers check every plan before code runs. Install once, use in any project.

**Website**: Leave blank.

**Topics** (8): `claude-code`, `ai-agents`, `agent-orchestration`, `claude`, `multi-agent`, `claude-agents`, `developer-tools`, `anthropic`

### Implementation

```bash
gh repo edit --description "Specialist agent team for Claude Code -- 27 domain experts with orchestration and governance gates."
gh repo edit --add-topic claude-code --add-topic ai-agents --add-topic agent-orchestration --add-topic claude --add-topic multi-agent --add-topic claude-agents --add-topic developer-tools --add-topic anthropic
```

### When to Revisit

1. Agent count changes (agents added or removed from the roster)
2. A dedicated documentation site or landing page is created (add as website URL)
3. GitHub introduces new discovery mechanisms or changes topic behavior
4. `claude-agents` or `agent-orchestration` topic ecosystems stagnate after 6 months (swap for alternatives)
5. Anthropic introduces official terminology for Claude Code agent collections

### Strongest Arguments

**For short description (106 chars)** (adopted):

| Argument | Agent |
|----------|-------|
| Survives truncation in all GitHub display contexts | ux-strategy-minion |
| README handles the longer pitch one click away | ux-strategy-minion |
| Matches existing project style (concise, functional) | lucy |

**For long description (299 chars)** (not adopted, but preserved):

| Argument | Agent |
|----------|-------|
| Lists concrete domains (security, testing, API) for pattern-matching | product-marketing-minion |
| "Five mandatory reviewers" is the strongest trust signal | product-marketing-minion |
| More search keyword surface area | seo-minion |

## Working Files

<details>
<summary>Working files (13 files)</summary>

Companion directory: [2026-02-13-114622-gh-about-section-proposal/](./2026-02-13-114622-gh-about-section-proposal/)

- [Original Prompt](./2026-02-13-114622-gh-about-section-proposal/prompt.md)

**Outputs**
- [Phase 1: Meta-plan](./2026-02-13-114622-gh-about-section-proposal/phase1-metaplan.md)
- [Phase 2: product-marketing-minion](./2026-02-13-114622-gh-about-section-proposal/phase2-product-marketing-minion.md)
- [Phase 2: seo-minion](./2026-02-13-114622-gh-about-section-proposal/phase2-seo-minion.md)
- [Phase 2: ux-strategy-minion](./2026-02-13-114622-gh-about-section-proposal/phase2-ux-strategy-minion.md)
- [Phase 2: lucy](./2026-02-13-114622-gh-about-section-proposal/phase2-lucy.md)
- [Phase 3: Synthesis](./2026-02-13-114622-gh-about-section-proposal/phase3-synthesis.md)

**Prompts**
- [Phase 1: Meta-plan prompt](./2026-02-13-114622-gh-about-section-proposal/phase1-metaplan-prompt.md)
- [Phase 2: product-marketing-minion prompt](./2026-02-13-114622-gh-about-section-proposal/phase2-product-marketing-minion-prompt.md)
- [Phase 2: seo-minion prompt](./2026-02-13-114622-gh-about-section-proposal/phase2-seo-minion-prompt.md)
- [Phase 2: ux-strategy-minion prompt](./2026-02-13-114622-gh-about-section-proposal/phase2-ux-strategy-minion-prompt.md)
- [Phase 2: lucy prompt](./2026-02-13-114622-gh-about-section-proposal/phase2-lucy-prompt.md)
- [Phase 3: Synthesis prompt](./2026-02-13-114622-gh-about-section-proposal/phase3-synthesis-prompt.md)

</details>
