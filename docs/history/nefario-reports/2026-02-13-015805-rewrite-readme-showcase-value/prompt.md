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

use opus for all tasks