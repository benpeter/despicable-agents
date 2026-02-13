# Domain Plan Contribution: product-marketing-minion

## Recommendations

### Description Analysis

The GitHub About description is the most compressed positioning artifact a repo has. It appears in search results, topic listings, user profiles (pinned repos), and the repo sidebar. Developers scanning GitHub make stay-or-leave decisions based on this line alone. Every word must earn its place.

**Constraints:**
- GitHub enforces a 350-character hard limit on repository descriptions.
- The description renders as a single paragraph -- no line breaks, no formatting.
- It appears alongside the repo name, so "despicable-agents" is already visible context. The description should not repeat the repo name.
- On search result pages, descriptions are often truncated around 150-170 characters, so front-load the most important information.

**Competitive landscape for positioning context:**
- `ruvnet/claude-flow`: "The leading agent orchestration platform for Claude. Deploy intelligent multi-agent swarms, coordinate autonomous workflows..." -- overclaims ("Ranked #1"), buzzword-heavy ("enterprise-grade," "swarm intelligence"), developer-repellent marketing language.
- `VoltAgent/awesome-claude-code-subagents`: "A collection of 100+ specialized Claude Code subagents covering a wide range of development use cases" -- factual but generic. Reads as a list, not a system.
- `wshobson/agents`: "Intelligent automation and multi-agent orchestration for Claude Code" -- concise but undifferentiated. Could describe any multi-agent setup.

**What makes despicable-agents genuinely different (unique attributes mapped to value):**
1. **Governance gates before execution** -- No other Claude Code agent framework mandates five reviewers before code runs. This is the strongest differentiator because it addresses the core fear developers have with AI agents: "it will break things."
2. **Phased orchestration with approval gates** -- Nine structured phases vs. "just send it." Developers stay in control.
3. **Research-backed specialist boundaries** -- Not just a collection of agents. Each has strict "does NOT do" sections preventing overlap and hallucinated delegation.
4. **Install once, use everywhere** -- Symlink-based deployment means agents are available in every Claude Code session. No per-project configuration.

**Target persona for the description:**
A developer already using Claude Code who wants to scale beyond single-agent interactions. They have encountered the limitations of generalist prompting for complex tasks (security review, multi-domain feature work) and are looking for structure. They are not looking for a new platform -- they want to enhance what they already use. They value control over autonomy.

### Candidate Descriptions

**Candidate A -- Lead with structure and governance (recommended)**

> 27 specialist agents for Claude Code with phased orchestration and governance gates. Domain experts for security, testing, API design, infrastructure, and more -- each with strict boundaries. Five mandatory reviewers check every plan before code runs. Install once, use in any project.

Character count: 299

Trade-offs:
- (+) Front-loads the number "27" which signals scale and completeness
- (+) "Governance gates" is the key differentiator, appears early
- (+) "Before code runs" directly addresses the AI-agent trust problem
- (+) "Install once, use in any project" is a concrete convenience benefit
- (+) Lists real domain examples so developers can pattern-match to their needs
- (-) Does not mention the Despicable Me theming -- purely functional
- (-) Dense. A lot to parse in one line.

**Candidate B -- Lead with the job-to-be-done**

> Structured orchestration for Claude Code: 27 research-backed agents decompose complex tasks, route to domain specialists, and run governance gates before any code executes. Security, testing, API design, docs, and 19 more domains. One install, every project.

Character count: 286

Trade-offs:
- (+) Opens with "Structured orchestration for Claude Code" -- scannable, immediately categorizes the repo
- (+) "Research-backed" hints at depth without overclaiming
- (+) "Before any code executes" is the trust hook
- (+) "One install, every project" is punchy
- (-) "Decompose complex tasks, route to domain specialists" is process description rather than outcome
- (-) Still no personality from the theme

**Candidate C -- Functional with a light thematic nod**

> 27 specialist agents for Claude Code. Nefario orchestrates across domains, governance gates catch problems before code runs, and each minion has strict boundaries backed by domain research. Security, testing, APIs, infrastructure, docs, and more. Install once, use everywhere.

Character count: 289

Trade-offs:
- (+) "Nefario" and "minion" are organic references to the theme without being forced -- they are literally the agent names
- (+) "Governance gates catch problems before code runs" is benefit-oriented, not feature-oriented
- (+) Using the actual role names (Nefario, minion) helps developers understand the agent hierarchy from the description alone
- (-) Readers unfamiliar with the theming may find "Nefario" and "minion" confusing without context
- (-) Slightly less keyword-dense for search

### Recommendation: Candidate A

Candidate A is the strongest for GitHub discovery. Here is why:

1. **Front-loading matters.** On truncated search results, "27 specialist agents for Claude Code with phased orchestration and governance gates" is what survives. That is the complete positioning in one clause.

2. **Governance is the real differentiator.** The competitive landscape is full of "multi-agent orchestration" claims. Nobody else is leading with mandatory review before execution. This addresses the most important developer concern with AI agent systems: trust and control.

3. **Skipping the theme is correct for the description.** The Despicable Me naming is a discovery hook that works in the README, repo name, and docs -- contexts where there is room to explain it. In a 300-character description competing for attention in search results, clarity beats cleverness. The repo name "despicable-agents" already signals the theme. The description should explain what it does, not reinforce the brand.

4. **Candidate C is a viable alternative** if the team values surfacing the agent hierarchy vocabulary (Nefario, minion) early. It has a legitimate argument: developers who install the tool will interact with these names immediately, so introducing them in the description reduces onboarding friction. If the team prefers C, the risk of initial confusion is low given that "minion" is widely understood as "specialist worker."

### Website URL

**Recommendation: Leave blank or point to the README.**

Options analyzed:

| Option | Verdict | Rationale |
|--------|---------|-----------|
| Blank | Acceptable | The README is already the landing page. A website link adds nothing if it just links back to the same page the user is already on. |
| `https://github.com/benpeter/despicable-agents#readme` | Marginal | Anchors to the README from search results, but GitHub already surfaces the README on the repo page. Adds a link that goes nowhere new. |
| `https://github.com/benpeter/despicable-agents/blob/main/docs/using-nefario.md` | Considered | Would surface the "Using Nefario" guide for faster time-to-value. But the URL is ugly and non-obvious in sidebar display. |
| Dedicated docs site (future) | Best long-term | If the project grows, a `despicable-agents.dev` or GitHub Pages site would be the ideal website link. But building this is not warranted yet (YAGNI). |

**Verdict: Leave blank for now.** When a dedicated documentation site exists, add it. Until then, the README is the landing page and GitHub already displays it.

### Topics (Tags)

GitHub topics drive discoverability. They appear in search, topic pages, and "Explore" recommendations. Choose topics that match what the target developer would search for.

**Recommended topics (ordered by priority):**

1. `claude-code` -- Primary platform. Developers searching for Claude Code extensions will find this.
2. `ai-agents` -- Broad category for multi-agent systems. High traffic.
3. `agent-orchestration` -- Specific to the orchestration value prop.
4. `claude` -- Broader Anthropic ecosystem discovery.
5. `multi-agent` -- Alternative search term for the same concept.
6. `developer-tools` -- General category for tooling repos.
7. `code-review` -- One of the concrete capabilities, and a high-intent search term.
8. `claude-code-agents` -- Emerging compound topic specific to this ecosystem.

**Topics to avoid:**
- `awesome` or `awesome-list` -- This is not a curated list, it is a framework.
- `llm` or `large-language-models` -- Too broad, will attract users who are not Claude Code users.
- `ai` -- Too generic, low signal-to-noise.
- `devops`, `security`, `testing` -- These are agent domains, not the repo's purpose.

**Recommended set (8 topics):**
`claude-code`, `ai-agents`, `agent-orchestration`, `claude`, `multi-agent`, `developer-tools`, `claude-code-agents`, `code-quality`

(GitHub allows up to 20 topics, but fewer high-quality topics are better than many diluted ones. These 8 cover the primary discovery paths.)

### Tone Guidance

The question of technical vs. playful tone deserves explicit analysis:

**The repo name is already doing the playful work.** "despicable-agents" is an immediate signal that this project has personality. Agent names like "gru," "nefario," "lucy," "margo," and "minion" reinforce it everywhere in the documentation. Adding playfulness to the description (e.g., "Deploy your minion army...") would be redundant and risks undermining the credibility of the governance and quality claims -- the very things that differentiate this project.

**The description should be the credibility anchor.** The playful naming catches attention. The functional description converts that attention into understanding. This is the classic "interesting name, serious tool" pattern used effectively by projects like Terraform (planet-shaping name, infrastructure automation tool), Kubernetes (Greek for "helmsman," container orchestration platform), and Grafana (portmanteau name, serious monitoring tool).

**Rule: Fun names, serious descriptions.**

## Proposed Tasks

This is an advisory contribution. The deliverables are the analysis and recommendations above, specifically:

1. Three candidate descriptions with trade-off analysis and a clear recommendation (Candidate A)
2. Website URL strategy with options matrix (recommend: leave blank)
3. Topic tag set with rationale (8 topics recommended)
4. Tone guidance with reasoning ("fun names, serious descriptions")

No implementation tasks are needed from this domain -- the About section is configured via GitHub UI or API, not via code artifacts.

## Risks and Concerns

1. **Character count uncertainty.** GitHub's description limit appears to be 350 characters based on available evidence, but this has changed over time. All three candidates are under 300 characters. If the limit is lower than expected, Candidate B (286 chars) or a trimmed version of A would still work. The first clause of each candidate ("27 specialist agents for Claude Code with phased orchestration and governance gates" at 89 characters) functions as a standalone description if severe truncation is needed.

2. **Topic volatility.** The `claude-code` and `claude-code-agents` topics are emerging and may not yet have significant search volume on GitHub. This is actually an advantage for early positioning -- being one of the first well-described repos in a growing topic is better than being the 10,000th repo tagged `ai`. Monitor topic adoption quarterly.

3. **Description staleness.** If the agent count changes (adds or removes agents), the description becomes inaccurate. "27" is specific and credible now, but requires maintenance. Alternative: "25+" is future-proof but less precise. Recommendation: keep the exact number and update it when the roster changes. Precision builds trust.

4. **Governance claim verification.** The description claims "five mandatory reviewers check every plan." A developer who installs the tool and finds this is not enforced (or is skippable) will lose trust immediately. Ensure the README and orchestration behavior match this claim exactly before publishing it as the description.

5. **Competitive description drift.** The competitor descriptions analyzed above will change. The positioning recommendation is durable because it is based on a genuine architectural differentiator (governance gates), not a temporary gap. But revisit if a competitor adopts similar governance patterns.

## Additional Agents Needed

None. The GitHub About section is a pure positioning artifact within product-marketing-minion's domain. The description, website, and topics decisions are messaging and discoverability questions, not technical or design questions.
