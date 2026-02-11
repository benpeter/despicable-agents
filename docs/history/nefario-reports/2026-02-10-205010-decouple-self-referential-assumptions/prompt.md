Decouple despicable-agents from self-referential assumptions so it works as a general-purpose toolkit

**Outcome**: Despicable-agents cleanly separates "tooling that operates on any project" from "this project's own structure," so that users can apply the agent team to
evolve external projects or create new ones from scratch — without reports, git operations, skill context, or other behaviors defaulting to the despicable-agents repo.
The project can still use its own tooling on itself, but that is an explicit mode rather than the implicit default.

**Success criteria**:
- Full audit of self-referential touchpoints completed and documented (reports, git, skills, CLAUDE.md references, path assumptions, etc.)
- Each touchpoint resolved with a clear "target project vs. tooling project" delineation
- Nefario execution reports write to the target project (not despicable-agents) when operating on an external project
- Git operations (commits, branches, PRs) apply to the target project's repo by default
- `/despicable-prompter` reads context from the target project, not despicable-agents
- Running nefario against a brand-new empty directory works (greenfield use case)
- Running nefario against despicable-agents itself still works (self-evolution use case)
- No behavioral regressions for the self-evolution path

**Scope**:
- In: All agent/skill files that contain project-specific assumptions, report generation paths, git operation context, skill context resolution, CLAUDE.md references,
install.sh, SKILL.md
- Out: Agent system prompts (domain knowledge content), RESEARCH.md files, the-plan.md

**Constraints**:
- `/despicable-prompter` should become a global skill rather than project-local if that resolves its context issue
- Must support both modes: operating on self and operating on external projects
