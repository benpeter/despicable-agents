Replace --skip-post with granular skip flags in nefario skill

**Outcome**: The nefario skill offers fine-grained control over which post-execution phases to skip, so that users make conscious, individual decisions about skipping docs, tests, and code review instead of being nudged into skipping all post-execution work with a single coarse flag.

**Success criteria**:
- `--skip-post` is replaced by individual flags (e.g., `--skip-docs`, `--skip-tests`, `--skip-review`)
- Each flag independently controls its respective post-execution phase
- Running nefario without any skip flags executes all post-execution phases (current default behavior preserved)
- Multiple skip flags can be combined in a single invocation
- SKILL.md documents the new flags

**Scope**:
- In: nefario SKILL.md flag parsing and phase-gating logic
- Out: Post-execution phase implementations themselves, nefario planning phases, agent specs
