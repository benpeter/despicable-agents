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
- Do not narrow or dismiss this work as YAGNI. The separation is a deliberate architectural investment in reusability, not speculative feature-building. The goal is making existing structure explicit and swappable, not adding new capabilities.

---
Additional context: use opus for all tasks, select ai-modeling, lucy, margo, devx as the roster and skip the roster verification step. for any questions that you'd ask me, let lucy lead instead of asking me. proceed through the process without asking me anything and pause only before creating the PR again. also don't interrupt to ask about compaction
