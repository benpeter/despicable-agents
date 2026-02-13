You are contributing to the PLANNING phase of a multi-agent project.
You are NOT executing yet — you are providing your domain expertise
to help build a comprehensive plan.

## Project Task
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

## Your Planning Question
What is the strongest value proposition that differentiates despicable-agents from simpler setups? Draft the "What You Get" section, fill the `<gap/>` placeholders, recommend examples that justify multi-agent orchestration, and identify sections that undersell the system.

## Context
Read the following files for full codebase context:
- /Users/ben/github/benpeter/2despicable/2/README.md (current README)
- /Users/ben/github/benpeter/2despicable/2/docs/architecture.md
- /Users/ben/github/benpeter/2despicable/2/docs/using-nefario.md
- /Users/ben/github/benpeter/2despicable/2/docs/external-skills.md
- /Users/ben/github/benpeter/2despicable/2/skills/nefario/SKILL.md (orchestration skill — skim the phases to understand what nefario actually does)
- /Users/ben/github/benpeter/2despicable/2/skills/despicable-prompter/despicable-prompter/SKILL.md (prompter skill)
- /Users/ben/github/benpeter/2despicable/2/.claude/skills/despicable-lab/SKILL.md (lab skill)

## Instructions
1. Read relevant files to understand the current state
2. Apply your domain expertise to the planning question
3. Identify risks, dependencies, and requirements from your perspective
4. If you believe additional specialists should be involved that aren't already part of the planning, say so and explain why
5. Return your contribution in this format:

## Domain Plan Contribution: product-marketing-minion

### Recommendations
<your expert recommendations for this aspect of the task>

### Proposed Tasks
<specific tasks that should be in the execution plan>
For each task: what to do, deliverables, dependencies

### Risks and Concerns
<things that could go wrong from your domain perspective>

### Additional Agents Needed
<any specialists not yet involved who should be, and why>
(or "None" if the current team is sufficient)
6. Write your complete contribution to `/var/folders/3k/bfjvvz9s6dvdn_hvlhvr8lc00000gn/T//nefario-scratch-9dwM0U/rewrite-readme-showcase-value/phase2-product-marketing-minion.md`