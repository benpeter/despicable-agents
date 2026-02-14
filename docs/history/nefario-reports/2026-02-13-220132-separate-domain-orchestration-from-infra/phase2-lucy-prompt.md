You are contributing to the PLANNING phase of a multi-agent project.
You are NOT executing yet -- you are providing your domain expertise to help build a comprehensive plan.

## Project Task

Outcome: A user forking despicable-agents for a non-software domain (e.g., regulatory compliance validation, corpus linguistics) can identify and replace only the domain-specific parts -- agent roster, phase definitions, gate/approval semantics, coordination patterns -- without needing to understand or modify the domain-independent infrastructure (skill discovery, tool plumbing, team mechanics, report generation). This makes the system a reusable orchestration framework rather than a software-development-specific tool.

Success criteria:
- Clear boundary exists between domain-specific configuration (agents, phases, gates, coordination semantics) and domain-independent infrastructure (skill mechanics, subagent spawning, message delivery, report format)
- A hypothetical domain adapter can define its own phase sequence, gate criteria, and agent roster without editing infrastructure files
- Documentation explains what a domain adapter must provide vs. what the framework handles
- Existing software-development behavior is preserved -- current agents and orchestration work identically after the separation

Scope:
- In: nefario SKILL.md orchestration logic, phase/gate definitions, agent roster selection, approval semantics, documentation of the separation boundary
- Out: Actually building non-software-domain agent sets (IVDR, linguistics, etc.), changing the agent file format (AGENT.md structure), modifying Claude Code platform integration

Constraints:
- Do not narrow or dismiss this work as YAGNI. The separation is a deliberate architectural investment in reusability, not speculative feature-building.

## Your Planning Question

Governance (lucy/margo) is currently hardcoded as mandatory Phase 3.5 and Phase 5 reviewers. In a domain-adapted system, how should governance requirements be declared while preserving their unconditional nature? (a) Should governance agents remain universal and domain-agnostic, receiving domain context from the adapter, or should each domain define its own governance agents? (b) How do we ensure CLAUDE.md compliance checking works across domains with different convention structures? (c) Of the current six cross-cutting dimensions (Testing, Security, Usability-Strategy, Usability-Design, Documentation, Observability), which are universal and which are software-development-specific?

## Context

Read and analyze these files:
- /Users/ben/github/benpeter/2despicable/3/lucy/AGENT.md
- /Users/ben/github/benpeter/2despicable/3/margo/AGENT.md
- /Users/ben/github/benpeter/2despicable/3/nefario/AGENT.md
- /Users/ben/github/benpeter/2despicable/3/skills/nefario/SKILL.md (Phase 3.5 and Phase 5 sections)

## Instructions
1. Read relevant files to understand the current state
2. Apply your domain expertise to the planning question
3. Identify risks, dependencies, and requirements from your perspective
4. If you believe additional specialists should be involved that aren't already part of the planning, say so and explain why
5. Return your contribution in this format:

## Domain Plan Contribution: lucy

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

6. Write your complete contribution to /var/folders/3k/bfjvvz9s6dvdn_hvlhvr8lc00000gn/T//nefario-scratch-dV7OFI/separate-domain-orchestration-from-infra/phase2-lucy.md
