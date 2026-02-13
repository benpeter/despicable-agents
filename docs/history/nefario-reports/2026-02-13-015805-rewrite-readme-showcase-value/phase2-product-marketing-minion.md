## Domain Plan Contribution: product-marketing-minion

### Positioning Analysis

#### What the current README gets wrong

The current README describes structure ("27 agents organized as Gru, Nefario, Lucy, Margo, and 23 minions") without answering the question a reader actually has: **"Why would I use this instead of just asking Claude Code to do the thing?"**

That is the competitive alternative. Not other agent frameworks. The alternative is a single Claude Code session with no agents installed. The README must defeat that alternative in 60 seconds.

#### The core differentiation (strongest value proposition)

The single strongest value proposition is this: **despicable-agents gives Claude Code a structured process that catches problems before they become code.**

The underlying job-to-be-done is not "coordinate multiple agents." Nobody wakes up wanting that. The job is: "Ship a complex feature without missing security holes, test gaps, documentation debt, or over-engineering -- and without having to remember to check for all of that yourself."

A single Claude Code session can write an OAuth integration. But it will not spontaneously consult a security specialist about token storage, have a simplicity enforcer flag over-engineering, or produce a documentation impact checklist before writing a line of code. The user would have to prompt for each of those things manually -- and they would have to know to ask.

despicable-agents replaces "I hope I remembered everything" with "the system checks for everything."

Three things make this system genuinely different from simpler setups:

1. **Phased orchestration with mandatory review gates** -- not just "ask multiple agents," but a structured pipeline where planning happens before execution, governance reviews every plan, and the user approves before code runs. This is the difference between "ask an LLM to do a thing" and "have a process that decomposes, reviews, executes, and verifies."

2. **Research-backed domain experts with strict boundaries** -- each specialist's system prompt is distilled from real domain research (RESEARCH.md), not generic instructions. Strict "Does NOT do" boundaries mean delegation is unambiguous. The security-minion gives you actual threat modeling methodology, not "be secure."

3. **Governance that catches drift and over-engineering** -- Lucy (intent alignment) and Margo (simplicity/YAGNI) review every plan before execution. Six mandatory reviewers across security, testing, documentation, intent, and simplicity. This is not optional polish -- it is built into the pipeline.

#### Gap fills

**Gap 1 (top-level capability): Built-in governance and quality gates**

This is the third pillar alongside orchestration and domain expertise. The system enforces quality structurally:
- Six mandatory reviewers check every plan (security, testing, documentation impact, intent alignment, simplicity, code conventions)
- Discretionary reviewers activate based on plan content (accessibility for web UI, observability for runtime components, UX for workflow changes)
- Code review after execution (code-review-minion + lucy + margo)
- Test execution with baseline comparison
- All reviewers can BLOCK, forcing revision before execution proceeds
- Two-round revision cap with structured escalation to the user

This is not "we also do quality" -- it is the structural difference between "an LLM did a thing" and "an LLM did a thing that was reviewed before and after execution."

**Gap 2 (goodie): `/despicable-lab` for agent maintenance**

The `/despicable-lab` skill lets you check which agents are outdated and rebuild them from updated specs. Version-tracked agents with a research-then-build pipeline. Not a one-shot generation -- a maintainable system.

**Gap 3 (goodie): Install once, use everywhere**

`./install.sh` symlinks agents globally. After install, every Claude Code session in any project gets access to all 27 specialists and both skills. No per-project configuration. Nefario auto-discovers project-local skills and weaves them into plans alongside built-in specialists.

### Recommendations

#### 1. Lead with the problem, not the solution

The current opening line says what the system IS. It should say what it DOES FOR YOU.

**Current**: "A team of domain specialists, an orchestrator that coordinates them, and a governance layer that reviews every plan before execution -- for Claude Code."

**Recommended**: Something closer to: "Multi-agent orchestration for Claude Code. Decomposes complex tasks across domain specialists, reviews every plan for security and over-engineering before execution, and verifies the output."

The key shift: lead with the orchestration outcome (plans get reviewed before execution), not the structural components (we have specialists and an orchestrator).

#### 2. "What You Get" section -- proposed content

```markdown
## What You Get

- **Phased orchestration** -- coordinates a team of agents through structured phases:
  - Meta-planning: reads your codebase, decomposes the task, selects the right specialists
  - Planning: domain experts contribute recommendations, risks, and proposed tasks in parallel
  - Synthesis: consolidates specialist input into a single execution plan with dependencies and approval gates
  - Review: mandatory reviewers (security, testing, docs, intent alignment, simplicity) examine the plan before any code runs
  - Execution: agents run in parallel where possible, with approval gates at high-impact decision points
  - Verification: code review, test execution, and documentation updates after execution completes
  - All phase results and planned execution gates presented for your review, approval, or adjustment

- **Research-backed domain experts** -- 29 agents (4 named roles + 23 specialists + 2 skills), each built from a two-step pipeline: domain research distilled into a dense, actionable system prompt. Not generic instructions -- real expertise. The `/despicable-lab` skill rebuilds agents when specs change, with version tracking.

- **Built-in governance** -- every plan is reviewed by six mandatory reviewers before execution. Lucy checks intent alignment (did the plan drift from what you asked for?). Margo enforces simplicity (is this over-engineered?). Security, testing, and documentation reviewers catch gaps. Reviewers can BLOCK plans, forcing revision before code runs. After execution, code review and test execution verify the output.

- **Goodies**:
  - Detailed execution report for every orchestration -- includes all agent prompts, responses, decisions, and verification results. Committed to your repo as a permanent record.
  - `/despicable-prompter` skill to go from rough idea to structured task brief. Accepts inline text or `#42` to pull from a GitHub issue and write the brief back.
  - Install once, available everywhere. `./install.sh` symlinks to `~/.claude/`. All 29 agents work in any project, any Claude Code session. Nefario auto-discovers project-local skills and integrates them into plans.
  - Status line integration -- optional live status bar showing the current nefario task during orchestration.
```

#### 3. Examples should demonstrate multi-agent value

The current examples show `@security-minion` and `@debugger-minion` -- those are single-agent calls that do not justify multi-agent orchestration. They belong in a "Direct specialist" section but should not be the primary examples.

**Recommended examples that justify orchestration:**

The `/nefario` examples should show tasks where the orchestration structure matters:

```markdown
## Examples

For single-domain work, call the specialist directly:

```
@security-minion Review this auth flow for vulnerabilities
@debugger-minion This function leaks memory under load -- find the root cause
```

For work spanning multiple domains, `/nefario` plans across specialists:

```
/nefario Build an MCP server with OAuth authentication, security review, tests, and user docs
```

What happens: nefario reads your codebase, selects mcp-minion + oauth-minion + test-minion + user-docs-minion for planning. Each contributes domain-specific recommendations. Nefario synthesizes a plan. Security-minion and margo review it for vulnerabilities and over-engineering. You approve. Agents execute in parallel. Code review + tests run automatically. Result: a reviewed, tested MCP server with docs -- not just generated code.

```
/nefario #42
```

Point nefario at a GitHub issue. It fetches the issue, plans, executes, and opens a PR with `Resolves #42`.
```

These examples show the structural value: planning before execution, multi-specialist review, automated verification. A single Claude Code session cannot replicate that workflow.

#### 4. Sections that undersell or need updating

**"How It Works" section**: Currently buries the key differentiator. "Nine-phase process" is mentioned but not explained. The fact that six mandatory reviewers check every plan -- the single most important quality signal -- is a throwaway line. This section should foreground the review/governance structure.

**"Try It" section**: Duplicates the Examples section. Recommend removing it or merging into Examples. Having two sections that both say "here is how you use it" dilutes the message and adds scroll distance before the reader reaches substantive content.

**"Current Limitations" section**: "mostly vibe-coded" as a limitation is honest but undersells the system. The research pipeline and deliberate architecture are real. Recommend reframing: "The architecture and research are deliberate; prompt prose was generated with AI assistance and refined iteratively" -- which is what it already says, but the "mostly vibe-coded" bullet header contradicts it.

**Opening badge**: "98% Vibe Coded" as the first visual element sets a tone that conflicts with "this is a serious tool with a deliberate architecture." The badge is charming for GitHub discovery but undermines the credibility signal the README needs to establish in the first 10 seconds.

**"Agents" section**: The full roster table is good as a reference (expandable detail) but should not appear before "What You Get." Structure should be: positioning statement > what you get > examples > install > how it works > agent roster > docs > limitations.

### Proposed Tasks

#### Task 1: Write the "What You Get" section

**What**: Create a new "What You Get" section positioned after the opening paragraph and before Examples. Fill both `<gap/>` placeholders as described above. Content must be bullet-based and scannable -- no prose paragraphs.

**Deliverables**: New section in README.md with four top-level bullets (phased orchestration, research-backed experts, built-in governance, goodies).

**Dependencies**: None. This is the anchor task.

#### Task 2: Rewrite Examples section

**What**: Restructure examples to lead with the multi-agent orchestration use case (justifies the system's existence) and include the single-agent examples as secondary. Show what the orchestration process does, not just the invocation syntax.

**Deliverables**: Updated Examples section in README.md.

**Dependencies**: Task 1 (section ordering context).

#### Task 3: Review and update remaining sections

**What**: Apply the following changes across the rest of the README:
- Merge or remove "Try It" section (duplicates Examples)
- Strengthen "How It Works" to foreground governance and review gates
- Reframe "mostly vibe-coded" limitation to avoid self-undermining
- Move agent roster below "What You Get" and Examples
- Consider whether the opening paragraph needs sharpening (lead with outcome, not components)

**Deliverables**: Updated README.md with all sections reviewed for differentiation.

**Dependencies**: Tasks 1 and 2.

#### Task 4: Accuracy verification

**What**: Cross-check every factual claim in the new README against the actual codebase. Verify: agent count, phase count, reviewer count, skill names, install behavior, GitHub issue integration behavior, status line feature. Remove or flag any claim that cannot be verified against current code.

**Deliverables**: Verified README.md with no inaccuracies.

**Dependencies**: Task 3.

### Risks and Concerns

1. **Overpromising on orchestration quality**. The README should not imply that governance review guarantees bug-free output. The system catches more than a single session would, but it is still LLM-generated code reviewed by LLM agents. Every claim must be structurally true ("six reviewers examine every plan") without implying guarantees ("your code will be secure").

2. **Agent count precision**. The README currently says "27 agents" but the structure draft says "29 agents." Clarification needed: 27 is the agent count (4 named roles + 23 minions). The 2 skills (nefario skill, despicable-prompter skill) are skills, not agents. The README should be precise: "27 agents and 2 skills" or "29 components" -- but not mix the numbers.

3. **Examples vs. reality gap**. The multi-agent example ("Build an MCP server with OAuth...") needs to accurately reflect what nefario actually does. Do not show output that nefario does not produce. The walkthrough should match the actual phase flow documented in `skills/nefario/SKILL.md` and `docs/using-nefario.md`.

4. **Section ordering changes may affect link anchors**. If external sites or documentation link to `#try-it` or `#examples`, removing or renaming sections breaks those links. Check for internal cross-references in docs/ before restructuring.

5. **The "vibe-coded" badge tension**. The badge is a GitHub social signal (nets stars, communicates community membership). Removing it may reduce discoverability. But it contradicts the positioning of "deliberate architecture with research-backed agents." Recommend keeping the badge but ensuring the opening text immediately establishes credibility. The badge is a hook; the text must deliver substance.

### Additional Agents Needed

**software-docs-minion** should verify that the proposed README changes do not conflict with content in `docs/architecture.md`, `docs/using-nefario.md`, or `docs/agent-catalog.md`. The README references these docs and must stay consistent.

**lucy** should review the final README for intent alignment -- does it accurately represent what the system does, without drift toward marketing claims that the system cannot back up?

No other specialists needed beyond what the planning team already includes.
