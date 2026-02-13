MODE: SYNTHESIS

You are synthesizing specialist planning contributions into a final execution plan.

## Original Task
Rewrite README to showcase what despicable-agents uniquely provides

**Outcome**: The README clearly communicates what despicable-agents gives you that simpler agent setups don't, so that someone evaluating the project understands its value proposition within 60 seconds of reading. Currently the README describes low-level structure without conveying the system's distinctive capabilities.

**Success criteria**:
- README contains a "What You Get" section before Examples that covers the structure draft below
- Examples section is updated to demonstrate capabilities that justify multi-agent orchestration (not things a single agent could do equally well)
- All existing README sections are reviewed and updated where they undersell or fail to differentiate the system
- No inaccuracies introduced — all claims match current codebase capabilities
- README remains scannable (bullet-based, no walls of text)

**Scope**:
- In: README.md — new "What You Get" section, updated Examples, review/update of all existing sections
- Out: CLAUDE.md, the-plan.md, agent AGENT.md files, docs/ directory

**Constraints**:
- The new section must follow this structure draft (fill gaps marked with `<gap/>`):
  - **Phased orchestration** — coordinates a team of agents through:
    - Meta-planning (task decomposition, team selection)
    - Planning with domain experts for solution approach and execution plan
    - Execution
    - Verification and post-execution tasks (e.g. documentation updates)
    - All phase results + planned execution gates presented for review / approval / adjustment
  - **Research-backed domain experts** — easily create specialists using a research system; comes pre-built with 29 agents
  - `<gap/>` — identify and fill with 1 or more top-level capabilities the system provides (e.g. governance/quality guardrails, extensibility, or similar)
  - **Goodies**:
    - Detailed execution report including all agent prompts and responses
    - `/despicable-prompter` skill to fast-forward from stream of consciousness to structured task description (inline or via GitHub issues)
    - `<gap/>` — identify and fill with 1-2 more concrete goodies worth highlighting

## Specialist Contributions

Read the following scratch files for full specialist contributions:
- /var/folders/3k/bfjvvz9s6dvdn_hvlhvr8lc00000gn/T//nefario-scratch-9dwM0U/rewrite-readme-showcase-value/phase2-product-marketing-minion.md
- /var/folders/3k/bfjvvz9s6dvdn_hvlhvr8lc00000gn/T//nefario-scratch-9dwM0U/rewrite-readme-showcase-value/phase2-ux-strategy-minion.md
- /var/folders/3k/bfjvvz9s6dvdn_hvlhvr8lc00000gn/T//nefario-scratch-9dwM0U/rewrite-readme-showcase-value/phase2-user-docs-minion.md
- /var/folders/3k/bfjvvz9s6dvdn_hvlhvr8lc00000gn/T//nefario-scratch-9dwM0U/rewrite-readme-showcase-value/phase2-lucy.md

## Key consensus across specialists:
- product-marketing-minion: Lead with problem not structure. Gap fills: governance gates, install-once-available-everywhere, status line integration. Merge Try It into Examples. 4 proposed tasks.
- ux-strategy-minion: 60-second target currently fails. Reorder for progressive disclosure: value statement, what you get, examples, install, how it works, agents, docs, limitations. Merge Examples and Try It.
- user-docs-minion: Most claims verified accurate. "Six mandatory reviewers" must be corrected to FIVE. Replace inventory language with outcome language. Keep honest technical tone.
- lucy: CRITICAL: "Six mandatory reviewers" is wrong — canonical sources say FIVE (security-minion, test-minion, software-docs-minion, lucy, margo). Governance capabilities severely undersold. Post-execution phases invisible. Missing: despicable-prompter, external skill discovery, cross-cutting checklist.

## External Skills Context
4 project-local skills discovered:
- despicable-lab (LEAF) — agent building tool, reference as goodie
- despicable-statusline (LEAF) — status line config, not relevant to execution
- despicable-prompter (LEAF) — task briefing, already in goodies list
- nefario (ORCHESTRATION) — the invoking skill itself
No external skills used in execution.

## Instructions
1. Review all specialist contributions
2. Resolve any conflicts between recommendations
3. Incorporate risks and concerns into the plan
4. Create the final execution plan in structured format
5. Ensure every task has a complete, self-contained prompt
6. If external skills were discovered, include them in the execution plan:
   - ORCHESTRATION skills: create DEFERRED macro-tasks
   - LEAF skills: list in the Available Skills section of relevant task prompts
   - Apply precedence rules when skills overlap with internal specialists
7. Write your complete delegation plan to `/var/folders/3k/bfjvvz9s6dvdn_hvlhvr8lc00000gn/T//nefario-scratch-9dwM0U/rewrite-readme-showcase-value/phase3-synthesis.md`