## Domain Plan Contribution: seo-minion

### Recommendations

#### 1. GitHub Topic Ecosystem Analysis

I researched the size and activity of every relevant GitHub topic ecosystem. Here is the landscape as of February 2026:

| Topic | Repository Count | Signal Quality | Notes |
|-------|-----------------|----------------|-------|
| `llm` | 39,092 | Very broad, low signal | Catch-all; every LLM-adjacent project uses it |
| `ai-agents` | 9,338 | Broad but relevant | Active community, strong discovery channel |
| `claude` | 6,927 | Moderate, Claude-specific | Large ecosystem; high relevance for this project |
| `claude-code` | 6,003 | High relevance | Exact platform match; the core discovery term |
| `agentic-ai` | 5,469 | Broad, trending | Fast-growing in 2025-2026; trendy but noisy |
| `anthropic` | 2,782 | Moderate | Vendor-specific; relevant audience |
| `multi-agent-systems` | 1,895 | Academic leaning | Used by research-oriented repos; somewhat relevant |
| `multi-agent` | 1,452 | Moderate | Broader than `multi-agent-systems`; overlaps |
| `claude-skills` | 615 | High relevance | Exact feature match; growing ecosystem |
| `agent-orchestration` | 184 | Niche, high precision | Small but perfectly targeted audience |
| `claude-agents` | 38 | Very niche | Emerging topic; low traffic but exact match |
| `claude-extensions` | 11 | Too small | Negligible discovery value |

#### 2. Competitive Topic Analysis

I examined what topics the most successful comparable repos use.

**wshobson/agents** (28.5k stars -- Claude Code multi-agent orchestration):
`automation`, `orchestration`, `workflows`, `agents`, `anthropic`, `claude-code`, `subagents`, `claude-skills`

**ruvnet/claude-flow** (14k stars -- agent orchestration platform):
Topics emphasize `ai-agents`, `multi-agent-systems`, `agent-orchestration`, `claude`

**everything-claude-code** (45.3k stars -- Claude Code config collection):
`productivity`, `mcp`, `developer-tools`, `ai-agents`, `claude`, `llm`, `anthropic`

**crewAI** (44.1k stars -- multi-agent framework):
Uses broad AI and orchestration terms

**Common patterns across successful repos:**
- They all include `claude-code` (platform anchor)
- They all include at least one of `anthropic` or `claude` (vendor signal)
- They mix 2-3 broad topics (`ai-agents`, `llm`) with 2-3 specific ones (`claude-skills`, `agent-orchestration`)
- None exceed 12 topics; most use 6-10

#### 3. Proposed Topic List (Tiered)

I recommend **10 topics**, organized into three tiers by strategic function.

**Tier 1: Platform Identity (must-have, exact match for target audience)**

| # | Topic | Rationale |
|---|-------|-----------|
| 1 | `claude-code` | The platform this project runs on. 6,003 repos. Primary discovery channel for anyone searching for Claude Code extensions. Every comparable project uses this. |
| 2 | `claude-agents` | Exact descriptor for what this project is. Only 38 repos -- low traffic but the term is emerging and this project should establish presence early. As the ecosystem grows, early entrants rank higher. |
| 3 | `claude-skills` | The project includes deployable skills (nefario, despicable-prompter). 615 repos. Active, growing community. Matches how Anthropic's own documentation describes the extension mechanism. |

**Tier 2: Domain Descriptors (high-relevance terms that describe what the project does)**

| # | Topic | Rationale |
|---|-------|-----------|
| 4 | `agent-orchestration` | Nefario's core function. 184 repos -- niche but precisely the audience who would want this. Developers searching this term are looking for exactly what despicable-agents provides. |
| 5 | `multi-agent` | Broad descriptor for the project's architecture. 1,452 repos. Bridges between the Claude-specific and general AI agent communities. More discoverable than `multi-agent-systems` (which skews academic) or `multi-agent-orchestration` (which has very few repos). |
| 6 | `ai-agents` | The broadest relevant term. 9,338 repos. Provides exposure to the general AI agent community. Every top competitor uses this topic. Omitting it sacrifices significant discovery surface. |
| 7 | `prompt-engineering` | Each agent is a carefully crafted system prompt backed by domain research. This topic brings in developers interested in prompt design patterns, which is a real use case for studying this repo. |

**Tier 3: Ecosystem Anchors (vendor/platform association for browsing discovery)**

| # | Topic | Rationale |
|---|-------|-----------|
| 8 | `anthropic` | Vendor association. 2,782 repos. Developers browsing "what tools exist in the Anthropic ecosystem" will find this. Every comparable project includes this. |
| 9 | `agent-teams` | Matches the Claude Code feature this project builds on ("Built on Agent Teams" -- README line 6). This may be a very small or nonexistent topic today, but it is the official Anthropic terminology. Establishing presence on this term is forward-looking. |
| 10 | `developer-tools` | Functional category. Signals that this is a practical tool, not a research project or demo. Helps developers scanning topic lists understand what kind of repo this is. |

#### 4. Topics Deliberately Excluded (with reasoning)

| Topic | Why Excluded |
|-------|-------------|
| `llm` | Too broad (39k repos). Adds noise, not signal. The audience finding repos via `llm` is not specifically looking for Claude Code agent teams. The Claude-specific topics serve discovery better. |
| `claude` | Overlaps heavily with `claude-code` and `anthropic`. At 6,927 repos it is large but undifferentiated. Adding it alongside `claude-code`, `claude-agents`, and `claude-skills` creates redundancy. If topic count must be reduced below 10, adding `claude` back in place of a Tier 2 or 3 topic is reasonable. |
| `agentic-ai` | Trending buzzword (5,469 repos). The project does not describe itself using this term in any canonical document. Per Lucy's consistency guidance, topics should reflect established terminology. |
| `automation` | Risky per Lucy's analysis -- the project coordinates human-in-the-loop workflows, not autonomous automation. Using this topic could attract the wrong audience and set incorrect expectations. |
| `framework` / `ai-framework` | The project is NOT a framework. It is a set of deployable agents and skills. Tagging it as a framework is inaccurate and would create confusion when developers expect an SDK or library. |
| `mcp` | Only one agent (mcp-minion) deals with MCP. This is not a project-level concern. |
| `multi-agent-systems` | Skews academic (1,895 repos dominated by research papers and simulation frameworks). `multi-agent` captures the same intent with a broader audience. |
| `claude-extensions` | Only 11 repos. Negligible discovery value. Not worth spending a topic slot on. |

#### 5. Topic Count Rationale

GitHub allows a maximum of 20 topics per repository. However, research and competitive analysis show:

- **Most effective repos use 6-12 topics.** Beyond 12, the marginal discovery value per additional topic drops sharply while visual clutter increases (topics render as a tag cloud on the repo page).
- **10 topics** is the sweet spot for this project: enough to cover all three tiers (platform, domain, ecosystem) without dilution.
- **Poorly annotated projects with only 1-3 topics are measurably less discoverable** than well-annotated ones. But overloading with 15-20 generic topics signals spam behavior and reduces credibility.

The 10-topic recommendation leaves room to add 1-2 more if the project evolves (e.g., if a `governance` or `code-review` topic becomes relevant as those features mature).

#### 6. Discovery Strategy Beyond Topics

Topics are the primary mechanism, but two adjacent factors affect GitHub discoverability:

**Description as search text**: GitHub's search indexes the About description. Keywords in the description that do NOT appear in topics still contribute to search ranking. The description should therefore contain complementary terms (e.g., "governance gates" or "domain specialists") that would be too niche for topics but are meaningful search queries.

**README first paragraph**: GitHub search also indexes the README. The current README opening is well-optimized -- it contains "structured orchestration", "domain specialists", "governance gates", "Claude Code", "Agent Teams", and "27 agents" within the first two lines. No changes needed there.

### Proposed Tasks

1. **Set 10 GitHub topics** in the order listed above (Tier 1 first, then Tier 2, then Tier 3). The order does not affect discoverability but communicates priority to anyone reviewing the repo settings.

2. **Ensure the About description contains keywords complementary to the topics** -- specifically terms like "governance", "domain specialists", "orchestration", and "specialist agents" that serve as secondary search signals without needing their own topic slots.

3. **Revisit topics when agent count or scope changes** -- if agents are added or removed, or if the project adds significant new capabilities (e.g., an MCP server, a web UI), topics should be updated to match.

### Risks and Concerns

1. **Emerging topic instability**: `claude-agents` (38 repos) and `agent-teams` (possibly new) are very small topics. There is a risk they never gain traction and provide zero discovery value. Mitigation: the cost of including them is zero (they occupy topic slots but do not harm discovery). If they grow, this project benefits from being an early presence. If they stagnate, they can be swapped out later.

2. **Topic ecosystem fragmentation**: The Claude Code ecosystem has multiple overlapping topics (`claude`, `claude-code`, `claude-agents`, `claude-skills`, `claude-ai`, `anthropic-claude`, `anthropic`). There is no canonical topic hierarchy. This fragmentation means discovery is scattered across many small pools rather than concentrated in one large one. The proposed list addresses this by covering the three largest pools (`claude-code`, `claude-skills`, `anthropic`) while also claiming presence in the most precise niche (`claude-agents`).

3. **"agent-teams" topic may not exist yet**: If GitHub does not have an established `agent-teams` topic, creating it from a single repo provides no discovery value until others adopt it. However, if Anthropic promotes this term in their documentation (which they currently do), adoption should follow. If it does not exist after 3-6 months, replace with `claude` as a fallback.

4. **Broad vs. niche balance risk**: The list leans toward niche precision over broad reach. This is intentional -- the project serves a specific audience (Claude Code users who want agent teams). Broad topics like `ai` or `llm` would bring traffic but not the right traffic. However, if the repo owner wants maximum star count over maximum qualified traffic, adding `llm` and `claude` back would increase raw exposure.

5. **Topic maintenance is manual**: Unlike structured data on a website, GitHub topics have no automated validation or staleness detection. If the project scope changes (e.g., drops orchestration or adds framework-like features), outdated topics will persist until manually updated.

### Additional Agents Needed

None. The topic strategy is complete within the SEO domain. Lucy's contribution already provides the accuracy constraints I need (topics must reflect what the project IS, not what it aspires to be). The product-marketing and UX-strategy contributions will inform the description text, which complements topics for search but is not a topic selection concern.
