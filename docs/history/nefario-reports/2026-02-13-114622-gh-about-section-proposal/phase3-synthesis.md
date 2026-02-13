# Advisory Report

**Question**: What should the GitHub "About" section (description, website, topics) contain for the despicable-agents repository?
**Confidence**: HIGH
**Recommendation**: Use a concise, front-loaded description based on the README opening line; leave the website blank; apply 8 carefully selected topics balancing niche precision with ecosystem discovery.

## Executive Summary

Four specialists (product-marketing-minion, seo-minion, ux-strategy-minion, lucy) converged on the same core recommendations with strong consensus. The description should lead with what the project IS ("specialist agent team for Claude Code"), include the agent count (27) as a scope signal, and highlight governance gates as the primary differentiator -- the one feature no competitor leads with. The website field should be left blank (unanimous). Topics should number 8-10, anchored by `claude-code` and `ai-agents`, with niche terms like `claude-agents` and `agent-orchestration` for precision targeting.

The primary tension is between a short, scannable description (~106 characters, ux-strategy-minion) and a longer, information-dense one (~299 characters, product-marketing-minion). Both are well-reasoned, and the choice depends on whether you optimize for instant pattern-matching or for search-result persuasion. The recommendation below provides both options with a clear pick.

Confidence is HIGH because: all four specialists independently arrived at compatible recommendations, the project's canonical documents are internally consistent (giving a solid foundation), and the decision is easily reversible (the About section can be changed at any time via the GitHub UI).

## Team Consensus

All four specialists agreed on the following points without exception:

1. **Lead with "specialist agent team for Claude Code"** (or close variant). This phrase appears in CLAUDE.md, README.md, and architecture.md. It is the project's established self-description and places the repo in the reader's mental model within 2 seconds.

2. **Governance gates are the primary differentiator.** No competing repo (wshobson/agents, ruvnet/claude-flow, VoltAgent) leads with mandatory review before execution. This is the strongest positioning axis.

3. **Website field: leave blank.** The README is the landing page. A URL pointing back to the repo or a specific doc file adds no value and creates maintenance burden. When a dedicated docs site exists (YAGNI -- not now), add it then.

4. **Keep the description purely functional.** The repo name "despicable-agents" already carries the personality. The description should not lean into the Despicable Me theming. "Fun names, serious descriptions" (product-marketing-minion) matches "let the name carry personality, let the description carry information" (ux-strategy-minion).

5. **Include the exact agent count (27).** Cited in every canonical document. Signals maturity and scope. Creates a maintenance obligation when the roster changes, but precision builds trust and matches existing convention.

6. **`claude-code` is the most important topic.** Unanimous first pick. 6,003 repos, exact platform match, every comparable project uses it.

7. **Avoid `framework`, `autonomous-agents`, `automation`, `ai-framework`.** The project is not a framework (no SDK, no library). Agents are not autonomous (human approval gates). "Automation" implies autonomy the project deliberately avoids.

8. **Do not introduce new terminology.** The About section should echo language already established in canonical documents, not invent new framing (lucy's constraint, endorsed by all).

## Dissenting Views

### Description length: short vs. long

- **ux-strategy-minion** recommends a 106-character description: "Specialist agent team for Claude Code -- 27 domain experts with orchestration and governance gates." Rationale: first 100 characters must be self-sufficient because GitHub truncates in search results and sidebar. Everything essential fits in one non-truncated line.

- **product-marketing-minion** recommends a 299-character description: "27 specialist agents for Claude Code with phased orchestration and governance gates. Domain experts for security, testing, API design, infrastructure, and more -- each with strict boundaries. Five mandatory reviewers check every plan before code runs. Install once, use in any project." Rationale: the longer version earns more search keyword surface, lists concrete domains for pattern-matching, and makes the "five mandatory reviewers" claim -- the strongest trust signal.

- **Resolution**: Both are viable. The short version is the safer default because it fits entirely within GitHub's non-truncated display zone (~100-120 chars) and delivers the complete message in every context. The long version adds real value (domain list, reviewer count, install convenience) but the incremental information appears only on the repo page sidebar, not in search results. **Recommend the short version as primary, with the long version as an alternative if the owner wants maximum information density.**

### Topic count: 5-7 vs. 8 vs. 10

- **lucy** recommends 5-7 topics, prioritizing only verified-accurate terms. Conservative approach minimizes risk of aspirational or misleading tags.
- **product-marketing-minion** recommends 8 topics. Balanced between discovery and dilution.
- **seo-minion** recommends 10 topics across three tiers. Maximizes coverage of platform, domain, and ecosystem discovery channels.

- **Resolution**: 8 topics is the right balance. seo-minion's Tier 1 and Tier 2 topics are all verified-accurate (satisfying lucy's constraint). Two of the Tier 3 topics (`anthropic`, `developer-tools`) are also verified-accurate. The remaining two Tier 3 picks (`agent-teams`, `prompt-engineering`) are borderline -- `agent-teams` may not exist as an established topic yet, and `prompt-engineering` describes a secondary attribute. Dropping those two and keeping 8 topics satisfies all four specialists' reasoning.

### Whether to include `claude` as a topic

- **seo-minion** deliberately excludes `claude` (overlaps with `claude-code` and `anthropic`; at 6,927 repos it is large but undifferentiated).
- **ux-strategy-minion** includes `claude` at position 5 (broader ecosystem discovery).
- **product-marketing-minion** includes `claude` at position 4.

- **Resolution**: Include `claude`. At 6,927 repos it is the second-largest relevant ecosystem after `ai-agents`. The overlap concern is valid but the cost of including it is zero (it occupies one topic slot of 20 available). Developers browsing the `claude` topic page are exactly the target audience. seo-minion's own analysis shows every top comparable project includes either `claude` or `anthropic` or both.

### Whether to include `prompt-engineering`

- **seo-minion** includes it (Tier 2, position 7). Rationale: each agent is a crafted system prompt backed by RESEARCH.md files; developers interested in prompt design patterns would study this repo.
- **lucy** lists it as "Accurate" (verified against codebase).
- **product-marketing-minion** and **ux-strategy-minion** do not include it.

- **Resolution**: Exclude. While technically accurate, `prompt-engineering` as a topic would attract an audience looking for prompt templates and techniques, not an agent team. The project contains prompts but IS NOT a prompt engineering resource. Including it risks misaligned expectations. This follows lucy's principle: topics should reflect what the project IS, not what it contains.

## Supporting Evidence

### Product Marketing Analysis

product-marketing-minion provided competitive landscape analysis showing the three main competitors (wshobson/agents, ruvnet/claude-flow, VoltAgent/awesome-claude-code-subagents) all position on agent count and orchestration breadth. None lead with governance. This confirms governance gates as an uncontested positioning axis.

The "fun names, serious descriptions" principle is well-grounded: Terraform, Kubernetes, and Grafana all pair memorable/unusual names with purely functional descriptions. The pattern works because the name catches attention and the description converts it to understanding.

Three candidate descriptions were provided with detailed trade-off analysis. Candidate A (299 chars) is the richest. Candidate C introduces agent hierarchy vocabulary (Nefario, minion) which could reduce onboarding friction but risks initial confusion.

### SEO/Discovery Analysis

seo-minion provided the most detailed topic ecosystem research, with repository counts for every relevant topic. Key data points:
- `claude-code`: 6,003 repos (high relevance, primary discovery channel)
- `ai-agents`: 9,338 repos (broad but relevant)
- `claude-agents`: 38 repos (very niche, early presence opportunity)
- `agent-orchestration`: 184 repos (niche, precisely targeted)
- `llm`: 39,092 repos (too broad, excluded)

The competitive topic analysis revealed that all successful comparable repos include `claude-code` and at least one of `anthropic` or `claude`. The recommendation to lean niche over broad is sound for a project targeting Claude Code users specifically.

### UX Strategy Analysis

ux-strategy-minion grounded the description in cognitive science: the "satisficing" two-stage pattern (pattern match in <2s, then value assessment in 1-3s). This explains why leading with "specialist agent team for Claude Code" outperforms leading with the problem or the solution -- it enables instant categorization.

The 100-character truncation threshold analysis is practical and actionable. The recommended 106-character description fits almost entirely within the non-truncated zone, meaning the complete message survives across all GitHub display contexts.

The theming analysis ("net neutral to slightly positive") with the constraint that the description must NOT lean into the theming aligns perfectly with product-marketing-minion's "fun names, serious descriptions" principle.

### Governance/Consistency Analysis

lucy verified that the project's self-description is remarkably consistent across all canonical documents (CLAUDE.md, README.md, architecture.md). All three use "specialist agent team," all cite 27 agents, all mention Claude Code. This consistency makes the About description straightforward -- reuse existing language rather than inventing new framing.

The accuracy audit of potential topics is the most conservative and rigorous of the four contributions. lucy's "Accurate" / "Borderline" / "Avoid" classification provides a hard constraint that filters out aspirational or misleading topics. The four "Avoid" exclusions (`framework`, `autonomous-agents`, `automation`, `mcp`) are well-reasoned and endorsed by all other specialists.

## Risks and Caveats

1. **Agent count staleness.** The description will say "27 agents" and "27 domain experts." If agents are added or removed, the description becomes inaccurate. All four specialists flagged this. Mitigation: keep the exact number (consistent with README convention) and update it when the roster changes. The maintenance cost is low (one number in one field).

2. **Emerging topic instability.** `claude-agents` (38 repos) and `agent-orchestration` (184 repos) are small topics. They may never gain traction. Mitigation: the cost of including them is zero. If they grow, early presence pays off. If they stagnate, they can be swapped out. seo-minion recommends revisiting topics quarterly.

3. **GitHub character limit uncertainty.** The 350-character limit is based on available evidence but has changed historically. All recommended descriptions are well under 300 characters. The short option (106 chars) is immune to any reasonable limit change.

4. **Governance claim verification.** product-marketing-minion flagged that the description claims governance gates are mandatory. If a developer installs the tool and finds this is easily bypassed or not enforced, trust erodes. The claim is accurate (five mandatory reviewers are documented and enforced in the nefario skill), but worth verifying before publishing.

5. **Number comparison with competitors.** wshobson/agents advertises 112 agents; VoltAgent advertises 100+. "27 agents" may invite unfavorable quantity comparison. Mitigation: the description couples the number with "governance gates" and "domain experts" -- signaling quality over quantity. This is a feature, not a weakness, but some readers will skim past the differentiator and focus on the number.

## Next Steps

If the recommendation is adopted, implementation is a single GitHub UI or CLI operation:

1. **Set the description** using one of the two recommended options (see Conflict Resolutions for the final candidates).

2. **Set the topics** (in this order): `claude-code`, `ai-agents`, `agent-orchestration`, `claude`, `multi-agent`, `claude-agents`, `developer-tools`, `anthropic`.

3. **Leave the website field blank.**

4. **Verify** the description displays correctly in: (a) the repo sidebar, (b) GitHub search results for "claude code agents", (c) the organization/user profile if the repo is pinned.

This can be done via the GitHub UI (Settings > General > About section) or via the GitHub API / `gh` CLI:

```bash
gh repo edit --description "Specialist agent team for Claude Code -- 27 domain experts with orchestration and governance gates."
gh repo edit --add-topic claude-code --add-topic ai-agents --add-topic agent-orchestration --add-topic claude --add-topic multi-agent --add-topic claude-agents --add-topic developer-tools --add-topic anthropic
```

No branch, PR, or code changes are needed. The About section is repo metadata, not a tracked file.

## Conflict Resolutions

### Description length (primary conflict)

ux-strategy-minion and product-marketing-minion proposed descriptions of significantly different lengths (106 vs. 299 characters). Both are well-reasoned with different optimization targets.

**Resolution**: Recommend the short description as the primary choice, with the long description as an explicit alternative.

**Primary recommendation (106 chars):**
> Specialist agent team for Claude Code -- 27 domain experts with orchestration and governance gates.

**Alternative (299 chars):**
> 27 specialist agents for Claude Code with phased orchestration and governance gates. Domain experts for security, testing, API design, infrastructure, and more -- each with strict boundaries. Five mandatory reviewers check every plan before code runs. Install once, use in any project.

Rationale for preferring short: it survives truncation in all GitHub display contexts, matches the README's concise style, and the repo name + README already handle the longer pitch. The short version is complete -- it answers what (specialist agent team), where (Claude Code), how many (27), and why it is different (orchestration + governance gates). The long version adds valuable detail but that detail is available one click away in the README.

### Topic set composition (minor conflict)

Four different topic lists were proposed, ranging from 5-7 (lucy) to 10 (seo-minion). Specific disagreements on `claude`, `prompt-engineering`, `code-review`, `code-quality`, `ai-coding`, and `claude-skills`.

**Resolution**: 8 topics, selected by applying lucy's accuracy constraint to seo-minion's ecosystem data, then filtering through product-marketing-minion's discovery priorities:

| # | Topic | Source Agreement |
|---|-------|-----------------|
| 1 | `claude-code` | All four |
| 2 | `ai-agents` | All four |
| 3 | `agent-orchestration` | product-marketing, seo, ux-strategy |
| 4 | `claude` | product-marketing, ux-strategy (seo excluded it; adding back per resolution above) |
| 5 | `multi-agent` | product-marketing, seo, ux-strategy |
| 6 | `claude-agents` | seo (niche early-presence play; verified accurate by lucy) |
| 7 | `developer-tools` | product-marketing, seo, ux-strategy |
| 8 | `anthropic` | seo, ux-strategy, lucy |

Excluded from seo-minion's list: `claude-skills` (the project includes skills but IS NOT primarily a skills project), `prompt-engineering` (attracts wrong audience), `agent-teams` (may not exist as established topic yet). These can be reconsidered if the ecosystem evolves.
