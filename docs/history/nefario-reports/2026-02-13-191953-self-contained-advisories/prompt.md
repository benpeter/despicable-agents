**Outcome**: Any advisory produced during nefario orchestration (across all phases, not just Phase 3.5) can be understood by a reader who sees only the advisory text. Currently, advisories reference invisible context — task numbers, plan step details, internal decisions — that only make sense inside the agent conversation that produced them. After this change, each advisory carries enough context that a user reading the synthesis, execution report, or task list can evaluate it without opening the originating agent session.

**Success criteria**:
- Each advisory names the concrete artifact, file, or concept it concerns (not "step 1" or "the approach")
- CHANGE descriptions state what they propose in domain terms, not by referencing plan-internal numbering or structure
- WHY descriptions explain the risk or rationale using information present in the advisory itself
- A user seeing only the advisory block can answer: "what part of the system does this affect, what is suggested, and why"
- The verdict format (ADVISE, and potentially APPROVE/BLOCK) is updated if needed to support this

**Scope**:
- In: Advisory format and instructions across all phases and agents that produce advisories; verdict format definition in nefario and reviewer agent prompts
- Out: Verdict routing mechanics, phase sequencing, report template layout

---
Additional context: use opus for all agents
