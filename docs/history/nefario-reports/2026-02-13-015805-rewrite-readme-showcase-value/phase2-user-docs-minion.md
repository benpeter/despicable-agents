## Domain Plan Contribution: user-docs-minion

### Accuracy Audit: Current README vs. Codebase

**Verified as accurate:**

- "27 agents and 2 skills" -- Confirmed. 27 AGENT.md files exist (gru, nefario, lucy, margo, 23 minions). 2 SKILL.md files exist (nefario, despicable-prompter).
- "4 named roles (Gru, Nefario, Lucy, Margo) and 23 minions across 7 domain groups" -- Confirmed. Agent catalog and directory structure match.
- "Nine-phase process" -- Confirmed against using-nefario.md (Phases 1-8, with 3.5 making nine total).
- "Six mandatory reviewers" -- Partially verifiable. using-nefario.md says "security and testing reviews are mandatory; others trigger based on plan scope." The README claim "six mandatory reviewers" needs verification against the nefario skill or orchestration docs. If only security and testing are truly mandatory and the other four are conditional, "six mandatory reviewers" is inaccurate. Recommend verifying against orchestration.md.
- Install/uninstall mechanism -- Confirmed. install.sh creates symlinks to `~/.claude/agents/` and `~/.claude/skills/`. Uninstall removes symlinks. Matches README claims.
- `/despicable-prompter` -- Confirmed. SKILL.md exists with the described functionality (transforms rough ideas into structured briefings, supports `#<issue>` syntax).
- Agent Teams feature link and February 5, 2026 date -- Verifiable claim about an Anthropic feature. The link and date should be confirmed by someone with access to verify the URL is still live.
- Web Resource Ledger reference project link -- External link, should be verified.
- Agent table in the expandable section -- Confirmed. All 27 agents listed with correct groups and focus areas matching agent-catalog.md.

**Potential inaccuracy requiring verification:**

- "Six mandatory reviewers check every plan." The using-nefario.md Phase 3.5 description says: "Security and testing reviews are mandatory; others trigger based on plan scope." This suggests only 2 reviewers are truly mandatory, with up to 4 more conditional. If the README says "six mandatory," it may overstate the guaranteed review coverage. This needs cross-referencing with the actual nefario SKILL.md or orchestration.md.

### Recommendations

#### 1. Lead with the problem, not the feature list

The current README opens with a factual description: "A team of domain specialists, an orchestrator that coordinates them, and a governance layer..." This describes what the project IS. A reader evaluating the project needs to know what problem it SOLVES within the first sentence. The opening should answer: "Why would I want this instead of just using Claude Code directly?"

Suggested structure for the first 60 seconds of reading:
1. **One-sentence value proposition** -- what you get (the outcome, not the mechanism)
2. **Three-line "what makes this different"** -- the unique capabilities, not the inventory
3. **Examples** -- concrete before/after showing value (current examples section is strong)
4. **Install** -- two commands, already good

#### 2. Replace inventory language with outcome language

Current: "4 named roles (Gru, Nefario, Lucy, Margo) and 23 minions across 7 domain groups."
This is inventory. A reader does not care about the count. They care about what the count enables.

Better: "23 domain specialists covering security, APIs, infrastructure, frontend, testing, observability, docs, and more -- each with strict boundaries so nothing falls through the cracks."

Current: "Nine-phase process -- from planning through execution to post-execution verification."
Better: "Plans are reviewed for intent drift and over-engineering before any code runs. After execution, code review, tests, and docs happen automatically."

#### 3. Make the "How It Works" section show the value chain, not the org chart

Current How It Works describes the hierarchy (Gru sets direction, Nefario orchestrates, Lucy and Margo review, 23 minions execute). This is organizational structure. Readers care about the workflow -- what happens to THEIR task after they type a command.

Recommend a compressed 4-step flow:
1. You describe the task
2. Relevant specialists are consulted for domain input
3. A plan is synthesized and reviewed (intent alignment + simplicity check) before execution
4. Code runs in parallel, then gets code review, tests, and docs automatically

This is the same information but organized around the user's experience, not the system's internals.

#### 4. Clarify the "six mandatory reviewers" claim

As noted in the accuracy audit, the using-nefario.md docs indicate only security and testing reviews are always mandatory. The README should either say "up to six reviewers" or specify "mandatory security and testing review, plus conditional reviews for..." to avoid setting incorrect expectations.

#### 5. Keep the agent table but deprioritize it

The collapsible agent table is a good use of progressive disclosure -- it is available for reference without cluttering the main flow. Keep it. But the README currently gives it a full H2 section ("Agents") that draws attention. Consider making the agents section briefer -- one sentence pointing to the catalog, plus the collapsible table. The table is reference material, not the value proposition.

#### 6. The Examples section is the strongest part -- keep it prominent

The current examples section is well-structured: single-agent for simple tasks, `/nefario` for multi-domain, `#42` for issue-to-PR flow. This is the most concrete and compelling content in the README. It should stay near the top and possibly become more prominent. Consider making it the FIRST substantive section after the one-liner, before the install instructions.

#### 7. Current Limitations section is honest and valuable -- keep it

The limitations section builds trust. "Mostly vibe-coded," "no subagent nesting," "context window pressure" are honest disclosures. Keep this section intact. Consider a minor rewrite from passive descriptions to active guidance: "Context window pressure" could become "Complex orchestrations with many specialists can approach context limits. Nefario uses scratch files and checkpoints to manage this, but very large plans may need manual intervention."

#### 8. Calibrate what belongs in README vs. linked docs

**Belongs in README (60-second scan):**
- Value proposition (one sentence)
- What makes this different (three bullets max)
- Examples showing real usage (current section)
- Install (two commands)
- Quick orientation to agent types (one paragraph, not a table)
- Link to deeper docs
- Limitations
- License

**Belongs in linked docs (not README):**
- Full agent roster table -- link to agent-catalog.md (currently progressive-disclosed with `<details>`, which is acceptable)
- Phase-by-phase orchestration explanation -- link to using-nefario.md
- Governance review details -- link to using-nefario.md
- External skill integration -- link to external-skills.md
- Status line configuration -- link to using-nefario.md (currently only in using-nefario.md, correctly)
- Architecture and design decisions -- link to architecture.md and decisions.md (currently linked, correct)

The current README is already well-calibrated here. The `<details>` block for the agent table and the documentation links section are good information architecture. No major restructuring needed for README vs. linked docs.

### Proposed Tasks

#### Task 1: Rewrite opening paragraph for value-first framing

**What to do:** Replace the current opening paragraph with a problem-oriented value proposition. Lead with what the user gets (domain-expert planning and governance on every task), not what the project contains (a team of agents).

**Deliverable:** New opening section (value prop + "what makes this different" bullets).

**Dependencies:** product-marketing-minion contribution for positioning language. The user-docs perspective ensures the language is concrete and user-oriented rather than abstract marketing copy.

#### Task 2: Rewrite "How It Works" as user-experience flow

**What to do:** Replace the current org-chart description with a 4-step workflow description organized around the user's task lifecycle. Keep it to 4-5 lines max.

**Deliverable:** Rewritten "How It Works" section.

**Dependencies:** None. Content already exists in using-nefario.md; this is a reframing exercise.

#### Task 3: Verify and correct "six mandatory reviewers" claim

**What to do:** Cross-reference the claim against the actual nefario skill and orchestration.md. Rewrite to accurately reflect which reviews are mandatory vs. conditional.

**Deliverable:** Corrected sentence with accurate review coverage description.

**Dependencies:** Requires reading nefario SKILL.md and/or orchestration.md. This is a factual verification task.

#### Task 4: Convert inventory language to outcome language throughout

**What to do:** Audit every sentence for "this project HAS X" phrasing and convert to "this project DOES X for you" phrasing. Target: the Agents section intro, the How It Works section, and the opening.

**Deliverable:** Line edits across the README.

**Dependencies:** Depends on Tasks 1 and 2 being complete first (those are the biggest rewrites; this is a polish pass).

#### Task 5: Final accuracy review

**What to do:** After all edits are complete, re-read the full README and verify every factual claim against the codebase. Check links. Confirm counts. Verify feature descriptions.

**Deliverable:** Sign-off that no inaccuracies were introduced.

**Dependencies:** All other tasks complete.

### Risks and Concerns

1. **Overpromising in the value proposition.** The biggest risk in a README rewrite is making the project sound more capable than it is. Every claim must be grounded in what the codebase actually does today. "Plans are reviewed for intent drift" is accurate. "AI-powered quality assurance" would be vague and overselling.

2. **"Six mandatory reviewers" may already be inaccurate.** If this claim is wrong in the current README, it needs correction, not perpetuation. The rewrite must fix it, not just carry it forward.

3. **Losing the honest, technical tone.** The current README has a direct, no-nonsense voice that matches the CLAUDE.md engineering philosophy ("More code, less blah, blah"). A rewrite that introduces marketing-speak or buzzwords would clash with the project's identity. The rewrite should be more compelling, not more promotional.

4. **The Agent Teams link may become stale.** The README references a specific Anthropic blog post and documentation URL. If the feature evolves or the URL changes, the README breaks. Consider linking to the general Claude Code docs page rather than a specific announcement.

5. **README length creep.** The current README is 144 lines, which is within a reasonable range. The rewrite should not make it longer. The goal is to replace content, not add content. Target 120-140 lines.

### Additional Agents Needed

**product-marketing-minion** should contribute to the value proposition language. The opening section needs positioning expertise -- "what makes this different" framing is a product marketing task. user-docs-minion can ensure the language is concrete and user-oriented, but the strategic positioning angle ("why this over simpler alternatives") is product-marketing-minion's domain.

If product-marketing-minion is already part of the planning team, no additional agents are needed. If not, they should be included specifically for Task 1 (the opening value proposition).
