# Meta-Plan: Logic-Bearing Markdown Classification

## Problem Analysis

Nefario's orchestration has two related defects that stem from treating all `.md` files as documentation:

### Defect 1: Phase-skipping (Phase 5 code review)

**Location**: `skills/nefario/SKILL.md`, line 1670

The Phase 5 conditional reads: "Skip if Phase 4 produced no code files (only docs/config)."

This means when an orchestration session modifies only AGENT.md files (system prompts), SKILL.md files (orchestration rules), or RESEARCH.md files (domain knowledge backing prompts), Phase 5 code review is skipped entirely. These files contain substantive logic -- they ARE the codebase for an LLM agent system. Skipping code review for them silently drops quality gates.

The same heuristic implicitly affects Phase 6 (test execution) since the "no code files" classification propagates through the conditional chain at lines 1647-1655.

### Defect 2: Team assembly (Phase 1 meta-plan)

**Location**: `nefario/AGENT.md`, delegation table and task decomposition logic

The delegation table correctly maps "LLM prompt design" and "Multi-agent architecture" to ai-modeling-minion. However, there is no guidance telling nefario to recognize that modifying AGENT.md, SKILL.md, or similar files constitutes prompt engineering / multi-agent architecture work. The classification relies on implicit pattern matching by the LLM, which fails when the task description frames the work in terms of file changes rather than domain concepts.

The fix needs to make the mapping explicit: when a task involves modifying agent system prompts or orchestration logic (regardless of file extension), ai-modeling-minion is a relevant specialist.

### Affected Files

| File | What needs to change |
|------|---------------------|
| `skills/nefario/SKILL.md` | Phase 5 skip conditional (line 1670); potentially Phase 6 conditional (line 1648-1649); add file classification definitions |
| `nefario/AGENT.md` | Delegation table guidance; task decomposition principles; possibly cross-cutting concerns checklist |

## Planning Consultations

### Consultation 1: Prompt Engineering & Multi-Agent Architecture

- **Agent**: ai-modeling-minion
- **Model**: opus
- **Planning question**: This project defines its agent system through markdown files (AGENT.md = system prompts, SKILL.md = orchestration rules, RESEARCH.md = domain knowledge). The orchestrator currently misclassifies these as "docs" during phase-skipping and team assembly. From your perspective as a prompt engineering and multi-agent architecture specialist:
  1. What criteria distinguish "logic-bearing markdown" (system prompts, orchestration rules, agent definitions) from "documentation markdown" (README, user guides, changelogs)?
  2. Should the classification be based on file naming conventions (AGENT.md, SKILL.md), directory location (agent directories), content heuristics (presence of structured sections like "Identity", "Working Patterns"), or a combination?
  3. When the orchestrator decides which specialists to consult for a task, what signals should trigger ai-modeling-minion inclusion beyond the current delegation table entries?
  4. Are there edge cases where a file could be both (e.g., RESEARCH.md that informs a prompt but is also human-readable documentation)?
- **Context to provide**: `nefario/AGENT.md` (delegation table, task decomposition principles), `skills/nefario/SKILL.md` lines 1640-1670 (phase-skip conditionals), `minions/ai-modeling-minion/AGENT.md` (to understand the agent's own scope)
- **Why this agent**: ai-modeling-minion is the domain expert for prompt engineering and multi-agent architecture -- exactly the domain that is being misclassified. They understand what makes a system prompt different from documentation and can define the classification boundary with domain authority.

### Consultation 2: Orchestration Logic & Phase Conditionals

- **Agent**: devx-minion
- **Model**: opus
- **Planning question**: The nefario SKILL.md Phase 5 conditional says "Skip if Phase 4 produced no code files (only docs/config)." This needs to be refined to distinguish logic-bearing markdown from documentation markdown. From a developer experience perspective:
  1. How should the file classification be expressed in SKILL.md -- as a positive list (these extensions/patterns ARE code), a negative list (these ARE docs), or a heuristic rule?
  2. Where in SKILL.md should the classification definition live -- inline at the Phase 5 conditional, as a shared definition referenced by multiple phases, or as a separate section?
  3. The classification affects Phase 5 (code review) and indirectly Phase 6 (test execution). Should both phases share a single "is this code?" function, or should they have independent criteria?
  4. How should the change be documented so future contributors understand the boundary between logic-bearing and documentation-only markdown?
- **Context to provide**: `skills/nefario/SKILL.md` lines 1638-1670 (post-execution phase conditionals), the full Phase 5 section, the Phase 6 section
- **Why this agent**: devx-minion specializes in configuration file design, error messages, and developer onboarding -- they can ensure the classification is expressed clearly, documented well, and maintainable for future contributors.

## Cross-Cutting Checklist

- **Testing** (test-minion): EXCLUDE from planning. The changes are to orchestration rule definitions in markdown files, not executable code with testable behavior. There are no unit tests for SKILL.md or AGENT.md content. The success criteria are verifiable through manual review of the classification logic. Test-minion would not have actionable input for planning.

- **Security** (security-minion): EXCLUDE from planning. The changes do not introduce attack surface, handle authentication, process user input, or manage secrets. The file classification change is an internal orchestration decision boundary. Security-minion would not have actionable input for planning.

- **Usability -- Strategy** (ux-strategy-minion): INCLUDE -- see below.

- **Usability -- Design** (ux-design-minion, accessibility-minion): EXCLUDE from planning. No user-facing interfaces are being created or modified. The changes are to orchestration internals.

- **Documentation** (software-docs-minion): INCLUDE -- see below.

- **Observability** (observability-minion, sitespeed-minion): EXCLUDE from planning. No runtime components, services, or APIs are being created. The changes are to static orchestration definitions.

### Consultation 3: Journey Coherence

- **Agent**: ux-strategy-minion
- **Model**: opus
- **Planning question**: The nefario orchestration has a user-facing journey where the user sees which phases run and which are skipped. The current misclassification causes phases to be silently skipped when they should run (e.g., code review is skipped for system prompt changes). From a user journey coherence perspective:
  1. When Phase 5 is skipped because the orchestrator classified files as "docs-only," the user sees nothing -- the skip is silent. Is this the right behavior for a correctly-classified docs-only change, or should the user see a brief note about what was skipped and why?
  2. The classification boundary ("this is code" vs "this is docs") is currently invisible to the user. Should any part of the classification be surfaced (e.g., in the execution plan approval gate or the wrap-up summary)?
  3. From a cognitive load perspective, is there a risk that making the classification more nuanced (logic-bearing markdown vs documentation markdown) adds confusion for users who just want to know "will my changes get reviewed?"
- **Context to provide**: `skills/nefario/SKILL.md` lines 1638-1670 (phase-skip conditionals), communication protocol section (CONDENSE lines for post-execution phases)
- **Why this agent**: ux-strategy-minion evaluates journey coherence and cognitive load. The fix changes when phases are skipped, which affects the user's mental model of what the orchestrator does with their changes.

### Consultation 4: Documentation of the Classification Boundary

- **Agent**: software-docs-minion
- **Model**: opus
- **Planning question**: The fix introduces a classification boundary: "logic-bearing markdown" vs "documentation-only markdown." This distinction needs to be documented so future contributors (both human and AI agents) understand it. From a documentation architecture perspective:
  1. Where should the canonical definition of this boundary live -- in SKILL.md (where the phase conditionals reference it), in AGENT.md (where the delegation table lives), in both, or in a separate document?
  2. Should the classification include worked examples (e.g., "AGENT.md in an agent directory = logic-bearing; README.md = documentation-only")?
  3. Is there existing project documentation (docs/architecture.md, the-plan.md) that should reference or be updated to reflect this distinction?
  4. The issue's success criteria include "the distinction is clear and documented so future contributors understand the boundary." What documentation format best achieves this for a project where the primary consumers are AI agents reading these files as system prompts?
- **Context to provide**: `docs/architecture.md`, `the-plan.md` structure, `CLAUDE.md` (project conventions)
- **Why this agent**: software-docs-minion specializes in architecture documentation and ensuring that design decisions are captured where future contributors (human or AI) will find them.

## Anticipated Approval Gates

1. **File classification definition** (MUST gate): The definition of "logic-bearing markdown" vs "documentation-only markdown" is a hard-to-reverse architectural decision that affects Phase 5 skip behavior, Phase 1 team assembly, and potentially future orchestration logic. Multiple valid approaches exist (filename-based, directory-based, content-based, hybrid). This gate has high blast radius (affects all downstream orchestration behavior) and is hard to reverse once agents internalize the pattern.

No other gates anticipated. The actual file edits to SKILL.md and AGENT.md are low blast radius and easy to reverse -- they follow directly from the approved classification definition.

## Rationale

Four specialists are consulted because this task sits at the intersection of four domains:

- **ai-modeling-minion**: The misclassified domain. Only a prompt engineering specialist can authoritatively define what distinguishes a system prompt from documentation. This is the core planning question.
- **devx-minion**: The implementation surface. The classification needs to be expressed as clear, maintainable rules in SKILL.md. DevX expertise ensures the rules are unambiguous and well-structured.
- **ux-strategy-minion**: The user impact. Phase-skipping behavior affects what the user sees during orchestration. The fix changes this behavior, and journey coherence review ensures the change is intuitive.
- **software-docs-minion**: The knowledge capture. The classification boundary must be documented so it persists. Docs expertise ensures it is placed where future consumers will find it.

Agents NOT consulted:
- **lucy / margo**: Governance reviewers triggered in Phase 3.5, not Phase 1 planning. They review the finished plan, not the planning inputs.
- **code-review-minion**: Would review the actual code changes in Phase 5, not the planning.
- All other minions: No domain overlap with this task.

## Scope

**In scope**:
- Define the classification boundary between logic-bearing markdown and documentation-only markdown
- Fix Phase 5 skip conditional in `skills/nefario/SKILL.md` to recognize logic-bearing markdown as "code"
- Fix Phase 1 team assembly logic in `nefario/AGENT.md` to include ai-modeling-minion when tasks involve logic-bearing markdown
- Document the classification boundary where future contributors will find it
- Verify the fix does not interfere with genuinely documentation-only changes still being classified correctly

**Out of scope**:
- Other phase-skipping logic beyond the docs/code classification
- Changes to agent prompt content (AGENT.md system prompts for individual agents)
- Changes to the-plan.md (canonical spec, human-edited only)
- Changes to Phase 6 skip logic beyond ensuring consistency with Phase 5
- Unrelated orchestration changes

## External Skill Integration

### Discovered Skills

| Skill | Location | Classification | Domain | Recommendation |
|-------|----------|---------------|--------|----------------|
| despicable-lab | `.claude/skills/despicable-lab/SKILL.md` | LEAF | Agent rebuilding from spec | Not relevant -- this task modifies orchestration rules (SKILL.md, AGENT.md) directly, not agent specs in the-plan.md. despicable-lab rebuilds agents from specs; it does not modify the orchestrator. |
| despicable-statusline | `.claude/skills/despicable-statusline/SKILL.md` | LEAF | Claude Code status line config | Not relevant -- status line configuration is unrelated to file classification or phase-skipping logic. |

### Precedence Decisions

No precedence conflicts. Neither discovered skill overlaps with the specialists selected for this task.
