Evaluate DESPICABLE.md as project-local configuration for the framework

**Outcome**: The team reaches a well-reasoned decision on whether consuming projects should have dedicated DESPICABLE.md and DESPICABLE.local.md files for framework-specific configuration, so that project instructions for despicable-agents stay separated from general CLAUDE.md concerns without requiring users to modify files owned by other tools.

**Success criteria**:
- Clear recommendation (adopt, defer, or reject) with rationale
- Precedence rules documented if adopted (DESPICABLE.md vs CLAUDE.md conflicts)
- At least gru, lucy, margo, and devx-minion consulted
- YAGNI analysis: real demand vs speculative need
- Alternative approaches evaluated (e.g., a `## Despicable Agents` section in CLAUDE.md)

**Scope**:
- In: File naming convention, .md vs .local.md split, interaction with existing CLAUDE.md/CLAUDE.local.md, discoverability for adopters, what configuration options these files would support (agent exclusion, domain spin, orchestration overrides)
- Out: Implementation of file parsing, changes to agent runtime, changes to nefario orchestration code

**Constraints**:
- Consultation only -- produce a decision document, not code
- Must include input from gru, lucy, margo, and devx-minion at minimum
