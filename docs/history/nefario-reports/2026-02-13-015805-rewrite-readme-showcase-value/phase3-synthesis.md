## Delegation Plan

**Team name**: rewrite-readme-showcase-value
**Description**: Rewrite README.md to showcase despicable-agents' unique value proposition, with accurate claims and scannable progressive-disclosure structure.

### Conflict Resolutions

1. **"Six mandatory reviewers" vs. five**: lucy flagged this as a factual error confirmed against four canonical sources. product-marketing-minion's draft perpetuated the error. Resolution: FIVE mandatory reviewers is canonical. All task prompts use this number.

2. **Agent count precision**: product-marketing-minion flagged tension between "27 agents" and "29 agents." Resolution: 27 agents + 2 skills. The README should say "27 agents and 2 skills" consistently, not "29 agents" or "29 components."

3. **"Vibe-coded" badge**: product-marketing-minion recommends reconsidering the badge; ux-strategy-minion says keep it as a social hook. Resolution: keep the badge (GitHub discovery value), do not repeat the self-deprecating framing in the limitations section. The badge is a personality signal; the text establishes substance.

4. **Examples/Try It duplication**: all four specialists agree these should be merged. Resolution: merge into a single Examples section.

5. **Section ordering**: ux-strategy-minion and product-marketing-minion agree on progressive disclosure ordering. user-docs-minion concurs. Resolution: adopt the proposed order (value statement, what you get, examples, install, how it works, agents, docs, limitations, contributing, license).

6. **"Explores Agent Teams" framing**: ux-strategy-minion flags this as undermining confidence ("positions as experiment, not tool"). user-docs-minion agrees. Resolution: remove or reframe. The project works and is used in production; present it as a working tool.

7. **Governance depth vs. scannability**: lucy wants more governance detail surfaced; user-docs-minion warns against README length creep. Resolution: use progressive disclosure -- brief governance bullets in "What You Get" and "How It Works," link to using-nefario.md and orchestration.md for depth. Target 120-150 lines for the full README.

### Task 1: Rewrite README.md

- **Agent**: product-marketing-minion
- **Delegation type**: standard
- **Model**: sonnet
- **Mode**: default
- **Blocked by**: none
- **Approval gate**: yes
- **Gate reason**: This is the sole deliverable of the entire plan -- the complete rewritten README.md. It is hard to reverse (establishes the project's public positioning) and all downstream verification depends on it. MUST gate.
- **Prompt**: |
    You are rewriting the README.md for the despicable-agents project. This is a Claude Code agent team with 27 specialist agents and 2 skills.

    ## Your Task

    Rewrite `/Users/ben/github/benpeter/2despicable/2/README.md` to clearly communicate what despicable-agents gives you that simpler agent setups don't. A first-time evaluator should understand the value proposition within 60 seconds of reading.

    ## Current README

    Read `/Users/ben/github/benpeter/2despicable/2/README.md` for the current content.

    ## Section Structure (in this order)

    1. **Title + badge** -- keep the vibe-coded badge as-is
    2. **Opening paragraph** -- lead with what the user GETS, not what the project IS. One sentence, value-first. Remove the "This project explores" experimental framing. Keep the Agent Teams link but reframe as "Built on Agent Teams" not "explores Agent Teams."
    3. **What You Get** -- new section with these four top-level bullets:
       - **Phased orchestration** -- coordinates agents through structured phases: meta-planning (reads codebase, decomposes task, selects specialists), specialist planning (domain experts contribute in parallel), synthesis (consolidates into execution plan with dependencies and gates), architecture review (five mandatory reviewers examine the plan before code runs), execution (agents work in parallel with approval gates at high-impact decisions), post-execution verification (code review, test execution, documentation updates). All phase results presented for user review, approval, or adjustment.
       - **Research-backed domain experts** -- 27 agents built from a two-step pipeline: domain research distilled into dense, actionable system prompts. Not generic instructions. Each agent has strict "Does NOT do" boundaries so delegation is unambiguous and nothing falls through cracks.
       - **Built-in governance and quality gates** -- every plan is reviewed by five mandatory reviewers before execution: security, testing, documentation impact, intent alignment (lucy), simplicity (margo). Reviewers can BLOCK plans, forcing revision before code runs. After execution, a second round of code review and test execution verifies the output. The user approves at every key decision point.
       - **Goodies**:
         - Detailed execution report for every orchestration -- all agent prompts, responses, decisions, and verification results, committed to your repo
         - `/despicable-prompter` skill to go from rough idea to structured task brief -- accepts inline text or `#42` to pull from a GitHub issue
         - Install once, available everywhere -- `./install.sh` symlinks to `~/.claude/`, all 27 agents work in any project. Nefario auto-discovers project-local skills and integrates them into plans.
         - `/despicable-lab` skill to check which agents are outdated and rebuild them from updated specs -- version-tracked agent maintenance

    4. **Examples** -- merge current Examples and Try It into one section. Structure:
       - Brief intro: "Single-domain work goes to the specialist directly. Multi-domain work goes to `/nefario`."
       - Show 2 single-specialist examples (keep @security-minion and @debugger-minion, they demonstrate breadth)
       - Show 1 orchestrated example with a brief explanation of what happens (the plan-review-execute-verify flow). Use the MCP server example: `/nefario Build an MCP server with OAuth authentication, security review, tests, and user docs` followed by a 3-4 line explanation of what nefario does (selects specialists, synthesizes plan, governance reviews, parallel execution, automated verification).
       - Show the GitHub issue example: `/nefario #42` with a one-line explanation
       - Remove the "Try It" section entirely
    5. **Install** -- keep current content, it's already good. Keep the "Using on Other Projects" subsection.
    6. **How It Works** -- rewrite to show the user-experience flow, not the org chart. Structure as a brief workflow:
       - You describe the task (or point at a GitHub issue)
       - Nefario reads your codebase, selects relevant specialists, and consults them for domain input
       - A plan is synthesized and reviewed: five mandatory reviewers (security, testing, docs, intent alignment, simplicity) check for problems before any code runs. Reviewers can block execution.
       - Agents execute in parallel. Approval gates pause at high-impact decisions for your review.
       - After execution: automated code review (three parallel reviewers), test execution with baseline comparison, and conditional documentation updates.
       - Keep character name introductions but always pair with functional role: "Gru (technology direction), Nefario (orchestration), Lucy (intent alignment), Margo (simplicity enforcement), 23 domain minions"
       - Link to using-nefario.md for the full guide
    7. **Agents** -- keep current content (one-line intro + collapsible roster table + link to catalog). No changes needed.
    8. **Documentation** -- keep current content, no changes needed.
    9. **Current Limitations** -- keep all four bullets but reframe the "mostly vibe-coded" bullet. Change the bullet header to something like "AI-assisted prompt authoring" and keep the explanation: "The research is real and the architecture is deliberate; prompt prose was generated with AI assistance and refined iteratively." Do not use "vibe-coded" as a limitation header -- the badge handles that tone.
    10. **Contributing** -- keep current content, no changes needed.
    11. **License** -- keep current content, no changes needed.

    ## Critical Accuracy Requirements

    These facts MUST be correct in the rewritten README:
    - FIVE mandatory reviewers (not six): security-minion, test-minion, software-docs-minion, lucy, margo
    - 27 agents + 2 skills (not 29 agents)
    - 4 named roles + 23 minions across 7 domain groups
    - Nine-phase process (Phases 1-8, with 3.5 making nine)
    - `/despicable-prompter` accepts inline text or `#<issue-number>` to pull from GitHub issues
    - Nefario auto-discovers project-local skills from `.skills/` and `.claude/skills/`
    - `./install.sh` symlinks to `~/.claude/` (not copies)
    - The Web Resource Ledger link is: https://github.com/benpeter/web-resource-ledger

    ## Verification files

    If you need to verify any claim, read these files:
    - `/Users/ben/github/benpeter/2despicable/2/docs/orchestration.md` -- phase details, reviewer counts
    - `/Users/ben/github/benpeter/2despicable/2/docs/using-nefario.md` -- user-facing orchestration guide
    - `/Users/ben/github/benpeter/2despicable/2/docs/agent-catalog.md` -- agent roster verification
    - `/Users/ben/github/benpeter/2despicable/2/skills/despicable-prompter/SKILL.md` -- prompter skill details
    - `/Users/ben/github/benpeter/2despicable/2/.claude/skills/despicable-lab/SKILL.md` -- lab skill details

    ## Style and Tone

    - Bullet-based and scannable -- no walls of text
    - Honest technical tone -- no marketing buzzwords, no "AI-powered" or "revolutionary"
    - Lead with outcomes, not mechanisms -- "plans are reviewed before execution" not "we have a governance module"
    - Keep the Despicable Me personality (character names, playful tone) but always pair names with functional roles
    - Do not over-promise. Use structural claims ("five reviewers examine every plan") not guarantees ("your code will be secure")
    - Target 120-150 lines total

    ## What NOT to Do

    - Do not modify any file other than README.md
    - Do not add new badges or shields beyond the existing vibe-coded badge
    - Do not add screenshots or images
    - Do not add a table of contents (the README is short enough without one)
    - Do not use HTML beyond the existing `<details>` block for the agent roster
    - Do not introduce claims that cannot be verified against the codebase files listed above
- **Deliverables**: Rewritten `/Users/ben/github/benpeter/2despicable/2/README.md`
- **Success criteria**: README passes the 60-second scan test (value proposition clear within first 15 seconds; "What You Get" section present before Examples; no factual inaccuracies; all claims verifiable; 120-150 lines; bullet-based and scannable)

### Cross-Cutting Coverage

- **Testing**: Not applicable -- this task produces documentation only (README.md), no executable output.
- **Security**: Not applicable -- no attack surface, no auth, no user input handling. The README references security features but does not create them.
- **Usability -- Strategy**: Covered. ux-strategy-minion contributed the progressive disclosure framework and 60-second scan analysis that directly shaped Task 1's section ordering and content structure.
- **Usability -- Design**: Not applicable -- README.md is markdown text, not a UI component. No visual hierarchy, interaction patterns, or WCAG compliance issues.
- **Documentation**: This IS the documentation task. software-docs-minion's Phase 3.5 review will verify consistency with docs/architecture.md, docs/using-nefario.md, and docs/agent-catalog.md.
- **Observability**: Not applicable -- no runtime components produced.

### Architecture Review Agents

- **Mandatory** (5): security-minion, test-minion, software-docs-minion, lucy, margo
- **Discretionary picks**: none -- the plan produces only a markdown file (README.md) with no user-facing UI, no runtime components, no web-facing output, and no workflow changes. No discretionary reviewer's domain signal is triggered.
- **Not selected**: ux-strategy-minion, ux-design-minion, accessibility-minion, sitespeed-minion, observability-minion, user-docs-minion

### Risks and Mitigations

1. **Inaccuracy propagation** (raised by all four specialists): The "six mandatory reviewers" error exists in the current README and some historical reports. Mitigation: Task 1 prompt explicitly states the correct number (five) with the specific reviewer names. Phase 3.5 lucy review will verify all claims against canonical sources.

2. **Over-promising** (raised by product-marketing-minion, user-docs-minion, lucy): Pressure to "showcase value" can lead to claims exceeding actual capabilities. Mitigation: Task 1 prompt mandates structural claims over guarantees and lists specific verification files. The approval gate catches overpromising before merge.

3. **Losing personality** (raised by ux-strategy-minion): Over-professionalizing could strip the Despicable Me charm. Mitigation: Task 1 prompt explicitly says to keep character names and playful tone, just pair names with functional roles.

4. **README length creep** (raised by user-docs-minion): Adding "What You Get" could push the README past a scannable length. Mitigation: Task 1 prompt sets a 120-150 line target and removes the duplicate "Try It" section, which frees ~20 lines.

5. **Broken anchor links** (raised by product-marketing-minion): Removing/renaming sections could break internal or external links. Mitigation: Phase 3.5 software-docs-minion review will check cross-references in docs/ files. The `#try-it` anchor is the main risk -- no other docs reference it based on the current codebase.

### Execution Order

```
Batch 1: Task 1 (product-marketing-minion writes README)
  │
  ▼
APPROVAL GATE: Rewritten README
  │
  ▼
Phase 3.5: Architecture Review (5 mandatory reviewers)
  │
  ▼
Phase 5-8: Post-execution phases (as applicable)
```

Single-task plan with one gate. No parallelism needed.

### Verification Steps

1. **Accuracy**: Every factual claim in the rewritten README is verified against canonical sources (the-plan.md, orchestration.md, using-nefario.md, agent-catalog.md, SKILL.md files). Lucy's Phase 3.5 review covers this.
2. **Scannability**: README is 120-150 lines, bullet-based, with progressive disclosure (collapsed sections, doc links for depth).
3. **60-second test**: A first-time reader understands the value proposition (why this over simpler setups) within the first 15 seconds of scanning, and understands the full differentiation within 60 seconds.
4. **No regressions**: All existing links (docs/, external) still work. The agent roster table is preserved. Install instructions unchanged.
5. **Section completeness**: "What You Get" section exists before Examples. All four top-level capabilities covered (orchestration, domain experts, governance, goodies). Examples demonstrate multi-agent value.
