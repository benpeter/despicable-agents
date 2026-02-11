Outcome: Users can combine despicable-agents orchestration with external domain skills (e.g., AEM/EDS skills, gh-upskill packages) without forking or modifying despicable-agents itself. The integration is loosely coupled — external skills keep their own patterns and conventions, despicable-agents discovers and delegates to them rather than absorbing them. This enables two usage modes: (1) a user drops despicable-agents into a project that already has its own skills/CLAUDE.md and gets orchestration benefits immediately, and (2) a maintainer of a skill ecosystem can document a lightweight integration surface without adopting despicable-agents conventions.

Success criteria:
- A user can run /nefario in a project with pre-existing external skills (e.g., AEM block-collection-and-party, content-driven-development) and nefario's specialists discover and leverage those skills during planning and execution
- External skills do not need to be restructured, renamed, or moved to work with despicable-agents
- Nefario's meta-plan phase can detect available project-local skills and CLAUDE.md context from the target project and factor them into specialist delegation
- Execution-phase agents can invoke external skills during their work, not just during planning
- A user starting a new project from scratch can combine despicable-agents + external skill sets (e.g., gh upskill adobe/helix-website + despicable-agents install) without conflicts
- The integration mechanism is documented from both perspectives: "I'm a user combining these" and "I'm offering skills that should work with orchestrators like this"
- No coupling direction from external skills back to despicable-agents — external skills remain independently usable
- Despicable-agents specialists can yield to external orchestration skills when appropriate (e.g., content-driven-development has its own phased workflow that shouldn't be overridden by nefario's phases). The design must define how nefario detects that an external skill has its own orchestration workflow and when to defer to it.
- Define precedence rules when external skills and despicable-agents specialists cover the same domain

Acceptance test scenario: User installs despicable-agents into a project with content-driven-development skill already present, runs /nefario 'build a new block', and nefario's meta-plan references CDD's phased workflow instead of overriding it with nefario's own phases.

Scope:
- In: Nefario's discovery/delegation logic, skill integration surface design, documentation for both user and maintainer perspectives, SKILL.md conventions for interop, execution-phase skill invocation
- Out: Building or modifying any external skills themselves, AEM/EDS domain knowledge in agents, changes to external skill formats (gh-upskill, claude-plugins.dev), MCP server integration (deferred — agents already access MCP tools natively; planning-aware routing is a future enhancement)

Constraints:
- Loose coupling — external skills must not be forced into despicable-agents patterns
- Must work with existing skill distribution mechanisms (gh-upskill, claude-plugins.dev catalog, manual install)
- Self-reference decoupling is resolved — agents no longer hardcode references to the despicable-agents repo

Given the complexity, use opus for all agents.
