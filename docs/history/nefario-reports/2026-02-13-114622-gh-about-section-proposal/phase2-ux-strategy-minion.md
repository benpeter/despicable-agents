# Domain Plan Contribution: ux-strategy-minion

## Recommendations

### 1. Lead with WHAT IT IS, not what it does or what problem it solves

The "should I care?" decision on GitHub is a two-stage satisficing process:

1. **Pattern matching (under 2 seconds):** "Is this thing in my category?" The developer scans for recognition cues -- does this relate to a tool I already use? If they can't place the project in a mental category within 2 seconds, they bounce.
2. **Value assessment (next 1-3 seconds):** "Does it offer something I don't already have?" Only after categorization do they evaluate differentiation.

Leading with the problem ("complex tasks get decomposed across domain experts") forces the reader to work backwards to figure out what this even is. That's germane load spent on comprehension rather than evaluation. Leading with what it does ("orchestrated multi-agent execution with governance") is better but still requires the reader to infer the category.

**Lead with what it IS: a specialist agent team for Claude Code.** This immediately places the project in the reader's mental model. "Claude Code" is the anchor. "Agent team" is the category. Everything else is secondary.

The current README first line gets this right: "Structured orchestration, domain specialists, and governance gates for Claude Code." That leads with the category (Claude Code tooling), then layers in the differentiators. The About description should follow the same pattern but compressed to the ~100-character sweet spot for scanability.

### 2. The Despicable Me theming: net neutral to slightly positive, but needs management

**Analysis of the theming's cognitive impact:**

- **Risk: confusion at first glance.** A developer searching for "claude code agents" who sees "despicable-agents" might briefly wonder if this is a joke project, a parody, or unserious. The name creates a 0.5-1 second comprehension tax.
- **Mitigant: the description resolves it immediately.** If the description clearly states what this is (agent team for Claude Code), the name becomes a memorable quirk rather than a barrier. The theming (Gru, Nefario, minions) actually helps recall -- "oh, the one with the Minions theme" is stickier than "claude-agent-framework-27."
- **Comparable pattern:** Developer tools with playful names succeed constantly (Homebrew, Bun, Deno, Fastify). The name is not the comprehension barrier -- the description is.
- **Key constraint:** The description MUST NOT lean into the theming. No "Deploy your minion army" or "Let Gru orchestrate your code." The description should be purely functional. Let the repo name carry the personality; let the description carry the information.

**Verdict:** The theming helps memorability and differentiation in a crowded space (there are now many "claude code agent" repos). It does not hurt comprehension IF the description is clear and functional. The About description is the place to be serious, not playful.

### 3. Information hierarchy for the description

GitHub About description constraint: ~350 characters max (varies by context), but only ~100-120 characters display without truncation in search results and the repo sidebar. The first ~100 characters are the only ones that matter for the satisficing decision.

**Recommended hierarchy (front-loaded for truncation):**

```
[What it IS] [Key differentiator] [Scope signal]
```

Specifically:
- **What it IS:** "Specialist agent team for Claude Code" -- places the project instantly
- **Key differentiator:** "with orchestration and governance" -- separates it from collections/lists of agents
- **Scope signal:** "27 agents, 2 skills" -- signals maturity and completeness

This maps to the JTBD: "When I'm using Claude Code and want structured multi-agent workflows, I want a pre-built team of domain specialists with orchestration, so I can decompose complex tasks without building the agent infrastructure myself."

### 4. Recommended description options (ranked)

**Option A (recommended, 106 chars):**
```
Specialist agent team for Claude Code -- 27 domain experts with orchestration and governance gates.
```
Why: Leads with category (agent team + Claude Code). Differentiates (domain experts, orchestration, governance). Scope signal (27). All within the non-truncated display zone.

**Option B (shorter, 89 chars):**
```
27 specialist agents for Claude Code with orchestrated multi-agent execution and governance.
```
Why: Number-first grabs attention. Clear category. Slightly less clear on the "team" concept.

**Option C (problem-forward, 109 chars):**
```
Orchestrated agent team for Claude Code -- domain specialists decompose complex tasks with governance gates.
```
Why: Leads with the differentiator (orchestration). Trades immediate categorization for immediate value proposition.

**I recommend Option A.** It front-loads categorization ("specialist agent team for Claude Code"), then immediately differentiates. The reader knows what this is in the first 40 characters, then learns why it's different in the next 60.

### 5. Topics (tags) recommendations

Topics serve two functions: discoverability (search/browse) and cognitive framing (quick category signals). Apply these principles:

- **Use established terms** that developers already search for
- **Don't duplicate** what's in the description
- **Mix category tags and technology tags** -- category for "what is this", technology for "does it work with my stack"

**Recommended topics (8-10, ordered by priority):**

1. `claude-code` -- primary ecosystem anchor
2. `ai-agents` -- category
3. `multi-agent` -- architecture pattern
4. `agent-orchestration` -- differentiating capability
5. `claude` -- broader ecosystem discovery
6. `developer-tools` -- general category
7. `code-review` -- specific capability users search for
8. `agent-teams` -- Claude Code feature name
9. `ai-coding` -- discovery term
10. `anthropic` -- ecosystem

Avoid: `despicable-me`, `minions` (confuses category), `awesome` (overused, diluted signal), overly specific agent names.

### 6. Website field

The About section has a website URL field. Two options:

- **Leave blank:** The README serves as the landing page. Adding a URL that points back to the repo itself is circular and adds noise.
- **Point to the docs:** If `docs/using-nefario.md` or similar is the most useful "next step" for an interested developer, link to it. But GitHub already renders the README below.

**Recommendation:** Leave blank unless there's a standalone docs site or a particularly compelling getting-started page. The README is the website for this project.

## Proposed Tasks

Since this is advisory-only, the deliverables are recommendations:

1. **Description text** -- final copy for the GitHub About description field (see Option A above)
2. **Topics list** -- ordered list of 8-10 topics for the About section
3. **Website field recommendation** -- blank or specific URL with rationale
4. **Theming guidance** -- brief note on when to lean into vs. away from the Despicable Me theming in different contexts (About = serious, README = personality is fine)

## Risks and Concerns

### Risk 1: Description truncation across contexts
GitHub displays the description differently in search results, repo page sidebar, organization page, and social embeds (Open Graph). The first ~100 characters must carry the full message independently. Anything after that is bonus context that may or may not display. All recommended options above are within this constraint.

### Risk 2: Competitive positioning in a crowded space
There are now multiple "claude code agent" repos (wshobson/agents with 112 agents, VoltAgent with 100+, ruvnet/claude-flow with 14k stars). The description needs to differentiate, not just categorize. The key differentiators for despicable-agents are: (a) governance gates, (b) structured orchestration phases, (c) research-backed agent boundaries. The description should signal at least one of these. "Governance gates" is the most unique -- the competition talks about "orchestration" and "multi-agent" but not governance.

### Risk 3: The theming polarizes
Some developers will find the Despicable Me theming charming and memorable. Others will read it as unserious or confusing (especially non-English speakers less familiar with the franchise). The About description is not the place to mitigate this -- the name is the name. But the description should be unambiguously professional and informative to counterbalance any skepticism the name creates.

### Risk 4: Number inflation arms race
"27 agents" is a meaningful scope signal today. But competitors advertise "100+" and "112" agents. If the number invites unfavorable comparison, consider whether to include it. Counter-argument: 27 purpose-built agents with governance is a different proposition than 100+ agents without it. The number plus "domain experts" signals quality over quantity.

## Additional Agents Needed

None. This is a contained UX strategy analysis. The final copy might benefit from product-marketing-minion reviewing the description for positioning and messaging effectiveness, but that is already part of the orchestration if needed.
