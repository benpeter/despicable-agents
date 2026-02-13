## Domain Plan Contribution: lucy

### Recommendations

#### 1. Description: Consistency Check Against Canonical Sources

The project describes itself with remarkable consistency across all canonical documents:

| Source | Self-Description |
|--------|-----------------|
| **CLAUDE.md** (line 1-4) | "Specialist agent team for Claude Code. 27 agents organized as Gru (boss), Nefario (orchestrator), Lucy and Margo (governance), and 23 domain-specialist minions." |
| **README.md** (line 6) | "Structured orchestration, domain specialists, and governance gates for Claude Code. Built on Agent Teams. 27 agents, 2 skills, available in every session after a one-time install." |
| **architecture.md** (line 3) | "despicable-agents is a specialist agent team for Claude Code: 27 agents organized into a four-tier hierarchy." |

The GitHub About description field allows roughly 350 characters. The description must be consistent with this established self-description. Key identity elements that MUST appear:

- "specialist agent team" (or close variant) -- this is the consistent phrase across all three sources
- "Claude Code" -- the platform dependency is stated in every description
- The agent count (27) -- cited in every canonical source
- Some indication of structure (orchestration, hierarchy, or governance)

The README opening line is the strongest candidate for the description because it was explicitly authored for external-facing context and captures the three pillars (orchestration, specialists, governance) concisely. The CLAUDE.md version names individual agents, which is too detailed for a one-line About. The architecture.md version is too generic.

**Recommendation**: Use the README opening line as the basis, possibly shortened. Do NOT introduce new framing, new terminology, or a tagline that does not appear in existing documents. The About section should echo, not reinterpret.

#### 2. Website Field

The project has no dedicated website. The only external link in the README is to Claude Code docs and the Helix Manifesto. The repo itself is the canonical location.

**Recommendation**: Leave the website field empty, or point it to the README anchor for install instructions if GitHub allows fragment URLs. Do not fabricate a website or point to an unrelated resource. An empty website field is better than a misleading one.

#### 3. Topics: Accuracy Audit

GitHub topics serve discoverability. They must reflect what the project IS today, not what it aspires to be. Based on my review of the codebase:

**Accurate topics (the project demonstrably IS these things):**

| Topic | Evidence |
|-------|----------|
| `claude-code` | Platform dependency stated in README line 6, CLAUDE.md, the-plan.md line 4 |
| `ai-agents` | The entire project is a set of AI agents |
| `agent-teams` | README line 6: "Built on Agent Teams"; the-plan.md line 6 |
| `multi-agent-orchestration` | Nefario's core function; nine-phase orchestration documented extensively |
| `prompt-engineering` | Every AGENT.md is a crafted system prompt; RESEARCH.md files back each one |
| `anthropic` | Claude Code is Anthropic's product; the agents use Claude models |

**Borderline topics (require justification):**

| Topic | Verdict | Reasoning |
|-------|---------|-----------|
| `llm` | ACCEPTABLE | The agents are LLM-powered, though this is indirect (via Claude Code) |
| `developer-tools` | ACCEPTABLE | The project functions as developer tooling (install once, use in every session) |
| `code-quality` | RISKY | Only some agents focus on code quality; the project is broader |
| `devops` | RISKY | Only iac-minion and edge-minion touch this; not the project's identity |
| `automation` | RISKY | The project coordinates human-in-the-loop workflows, not autonomous automation |

**Topics to AVOID (would be inaccurate or aspirational):**

| Topic | Why Not |
|-------|---------|
| `framework` | The project is not a framework -- it is a set of agent definitions |
| `ai-framework` | Same -- no framework, no SDK, no library |
| `autonomous-agents` | Agents require human approval gates; they are not autonomous |
| `chatbot` | These are not chatbots |
| `copilot` | This is not a copilot pattern |
| `mcp` | Only mcp-minion deals with MCP; it is not a project-level concern |
| `langchain` / `autogen` / other frameworks | Not used |

**Recommendation**: Use 5-7 topics. Prioritize specificity over reach. `claude-code` and `agent-teams` are the most distinctive and accurate. Generic topics like `ai` or `machine-learning` add noise without aiding discoverability for the actual target audience.

#### 4. Tone and Voice Consistency

The project's voice balances:
- **Technical precision**: Exact counts (27 agents, 7 groups, 23 minions), specific phase names, strict boundary definitions
- **Playful naming**: Despicable Me characters (Gru, Nefario, Lucy, Margo, minions) woven naturally into technical descriptions
- **No-nonsense engineering philosophy**: Helix Manifesto, YAGNI, KISS, "more code less blah blah"

The About section should maintain this balance. Specifically:

- DO use "despicable-agents" (lowercase, hyphenated) as the project name -- this is the consistent convention across all docs
- DO NOT explain the Despicable Me reference -- the existing docs never do, they just use the names naturally
- DO NOT use marketing language or superlatives -- the README avoids "powerful", "revolutionary", "cutting-edge" and the About should too
- DO NOT use emoji in the description text -- consistent with CLAUDE.md conventions (the README uses a badge with an emoji, but the prose does not)

#### 5. Contradiction Check Against Design Principles

The four design principles from the-plan.md (generic, publishable, composable, persistent learners) create specific constraints for the About section:

- **Generic**: The description must NOT position this as tied to any specific project or company. The README correctly says "available in every session" and "operates on any project."
- **Publishable**: The About section is itself a public artifact. No issue here as long as it contains no PII.
- **Composable**: If mentioned, composability should reference agent combination, not plugin architecture (there is no plugin system).
- **Persistent learners**: This is an implementation detail (`memory: user` in frontmatter). It should NOT appear in the About section -- it is too granular for a one-line description.

No contradictions detected between the proposed scope (description + website + topics) and the project's stated principles.

### Proposed Tasks

This is an advisory-only contribution. The deliverable is a set of constraints and recommendations, not implementation tasks. The agent responsible for the final About section proposal should:

1. **Draft the description** using the README opening line as the canonical source, shortened to fit GitHub's character limit. Do not invent new framing.
2. **Select 5-7 topics** from the "Accurate" list above, with at most one from the "Borderline/ACCEPTABLE" list.
3. **Leave the website field empty** unless a compelling, existing URL is identified.
4. **Verify the final text** contains no terminology absent from CLAUDE.md, README.md, or the-plan.md.

### Risks and Concerns

1. **Agent count staleness**: The description will hardcode "27 agents" and "2 skills". These numbers will become stale as agents are added or removed. Consider whether the description should use exact counts or a softer formulation ("27+" or omitting counts entirely). The README uses exact counts, so using them in the About is consistent -- but creates a maintenance burden. The agent count has been stable across all canonical docs, so this is low-risk today but worth noting.

2. **Topic drift over time**: GitHub topics are easy to set and forget. If the project adds or removes agent groups, topics should be revisited. No automated mechanism exists to flag this.

3. **Tone mismatch risk**: The About section is the first thing visitors see. If it adopts a different tone than the README (more marketing-heavy, more casual, more formal), it creates a jarring first impression. The safest approach is direct reuse of existing README language.

### Additional Agents Needed

None. This is a straightforward alignment and consistency review. The contributing agent (likely product-marketing-minion or ux-strategy-minion) has the domain expertise to draft the actual content. My role is to constrain the output to match established identity.
