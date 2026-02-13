MODE: META-PLAN

You are creating a meta-plan — a plan for who should help plan.

## Task
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

## Working Directory
/Users/ben/github/benpeter/2despicable/2

## External Skill Discovery
Before analyzing the task, scan for project-local skills. If skills are discovered, include an "External Skill Integration" section in your meta-plan (see your Core Knowledge for the output format).

## Instructions
1. Read relevant files to understand the codebase context
2. Discover external skills:
   a. Scan .claude/skills/ and .skills/ in the working directory for SKILL.md files
   b. Read frontmatter (name, description) for each discovered skill
   c. For skills whose description matches the task domain, classify as ORCHESTRATION or LEAF (see External Skill Integration in your Core Knowledge)
   d. Check the project's CLAUDE.md for explicit skill preferences
   e. Include discovered skills in your meta-plan output
3. Analyze the task against your delegation table
4. Identify which specialists should be CONSULTED FOR PLANNING (not execution — planning). These are agents whose domain expertise is needed to create a good plan.
5. For each specialist, write a specific planning question that draws on their unique expertise.
6. Return the meta-plan in the structured format.
7. Write your complete meta-plan to `/var/folders/3k/bfjvvz9s6dvdn_hvlhvr8lc00000gn/T//nefario-scratch-9dwM0U/rewrite-readme-showcase-value/phase1-metaplan.md`