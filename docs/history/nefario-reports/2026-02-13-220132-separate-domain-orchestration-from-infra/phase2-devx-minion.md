# Domain Plan Contribution: devx-minion

## Recommendations

### (a) File Format for the Domain Adapter

**Recommendation: Markdown with YAML frontmatter in a directory structure.**

The adapter should follow the project's existing conventions. The entire codebase uses markdown with YAML frontmatter (AGENT.md, SKILL.md, CLAUDE.md). Introducing YAML-only or TOML files would create a cognitive split where the adapter author must learn a different format than everything else in the system. Markdown also allows inline documentation alongside configuration, which matters for a file that adapter authors will read closely.

Proposed adapter structure:

```
domains/
  software-dev/            # The default adapter (current behavior extracted)
    DOMAIN.md              # Primary adapter declaration
    agents.md              # Agent roster, delegation table, groups
    phases.md              # Phase sequence, conditional triggers, post-execution semantics
    gates.md               # Gate classification rules, approval semantics
    governance.md          # Mandatory/discretionary reviewers, cross-cutting checklist
    review.md              # Architecture review triggering rules, verdict format
  ivdr/                    # Example: hypothetical regulatory compliance adapter
    DOMAIN.md
    agents.md
    phases.md
    ...
```

**Why a directory, not a single file**: The current SKILL.md is 2328 lines because it conflates infrastructure mechanics with domain configuration. Forcing all domain config into a single file recreates the same problem. A directory mirrors the existing agent structure (each agent has its own directory with AGENT.md and RESEARCH.md). Multiple files let the adapter author focus on one concern at a time -- a regulatory compliance author working on phase definitions should not need to scroll past the agent roster.

**Why not pure YAML**: YAML is appropriate for declarative configuration that tools consume. But much of the domain configuration is semi-structured: the delegation table has conditional logic ("when a task spans multiple domains"), gate classification uses a 2x2 matrix with prose heuristics ("hard to reverse AND has downstream dependents"), and the cross-cutting checklist has judgment-based inclusion criteria. Markdown allows mixing structured YAML frontmatter (machine-parseable fields) with prose sections (human-judgment rules). This matches the nature of the content.

**DOMAIN.md frontmatter** (minimum viable schema):

```yaml
---
name: software-dev
description: >
  Software development orchestration with 23 specialist agents,
  9-phase workflow, and code/test/docs post-execution verification.
version: "1.0"
default: true          # At most one adapter is marked default
phases:                # Phase sequence declaration
  - id: meta-plan
    type: planning     # planning | review | execution | verification
    required: true
  - id: specialist-planning
    type: planning
    required: true
  - id: synthesis
    type: planning
    required: true
  - id: architecture-review
    type: review
    required: true     # Can be skipped by user (gate offers "Skip review")
  - id: execution
    type: execution
    required: true
  - id: code-review
    type: verification
    required: false
    condition: "produced-code"    # Named trigger condition
  - id: test-execution
    type: verification
    required: false
    condition: "tests-exist"
  - id: deployment
    type: verification
    required: false
    condition: "user-requested"
  - id: documentation
    type: verification
    required: false
    condition: "docs-checklist-has-items"
---
```

The YAML frontmatter carries the structured, machine-readable parts. Everything below the frontmatter is the prose specification for how each phase operates within this domain. The framework reads the frontmatter to know the phase sequence and types; the prose sections feed into prompt composition for the orchestrating agent.

**Adapter selection**: Determined by directory presence and `default: true` flag. A project sets its adapter in CLAUDE.md: `domain-adapter: ivdr`. If unset, the adapter marked `default: true` is used. If no default exists and no CLAUDE.md preference, the framework falls back to `software-dev` (hardcoded fallback, matches current behavior).

### (b) Documentation for Adapter Authors

**Three documents are needed, in this priority order:**

1. **Annotated example adapter (the `software-dev` extraction)** -- This is the most important document. The existing software-dev configuration, extracted as the default adapter, IS the documentation. An adapter author reads it, understands what each section does by seeing a working example, and creates their own by modifying the example. This is the "copy and edit" onboarding path, which has the shortest time-to-first-success.

   This should be the `domains/software-dev/` directory itself, with inline comments explaining each section's purpose and what the framework does with it. The adapter IS the documentation -- no separate "reference spec" needed initially.

2. **Getting-started tutorial** (docs/creating-adapters.md) -- A focused walkthrough: fork the repo, copy `domains/software-dev/` to `domains/my-domain/`, edit each file, run the validator, test the result. Estimated completion: under 30 minutes for someone who understands their own domain.

   Structure:
   - **What you are building** (2 paragraphs: what adapters are, what they control)
   - **Prerequisites** (fork, Claude Code installed, domain expertise)
   - **Step 1: Copy the default adapter** (one command)
   - **Step 2: Define your agents** (edit agents.md -- roster, groups, delegation table)
   - **Step 3: Define your phases** (edit phases.md -- which phases your domain needs)
   - **Step 4: Define your gates** (edit gates.md -- what decisions need human review)
   - **Step 5: Define governance** (edit governance.md -- mandatory reviewers, cross-cutting concerns)
   - **Step 6: Validate** (run the validator)
   - **Step 7: Test with a dry run** (`/nefario --advisory <test task>`)
   - **What the framework handles** (explicit list of things you do NOT need to define)

3. **Reference spec** (docs/adapter-spec.md) -- Required fields, optional fields, types, constraints. This is the lookup document, not the learning document. Only needed after the adapter author has seen the example and tutorial. Can be generated from the DOMAIN.md schema.

**What documentation is NOT needed initially**: A deep architecture guide explaining the framework internals. The adapter boundary should be opaque -- the adapter author should not need to understand scratch file management, compaction checkpoints, or status line mechanics. If the adapter interface requires understanding infrastructure internals, the abstraction is leaking.

### (c) Adapter Validation

**Recommendation: A `/despicable-lab --check-domain [name]` subcommand.**

This follows the existing validation pattern. `/despicable-lab --check` validates agents against the-plan.md. A domain variant validates the adapter against the framework's expectations.

Validation checks (in order, fail-fast):

**Structural checks** (fast, no agent spawning):
1. DOMAIN.md exists and has valid frontmatter (name, description, version, phases)
2. All referenced files exist (agents.md, phases.md, gates.md, governance.md, review.md)
3. Phase sequence is valid: at least one `planning` phase, at least one `execution` phase
4. No duplicate phase IDs
5. Agent roster is non-empty and agent names are unique
6. Every agent in the delegation table exists in the roster
7. Every agent in governance.md (mandatory/discretionary reviewers) exists in the roster
8. Gate classification rules reference valid phase IDs
9. No circular dependencies in phase ordering

**Semantic checks** (deeper, may spawn a validator agent):
10. Every delegation table entry has a primary agent assigned
11. Cross-cutting dimensions have at least one agent responsible (or explicit exclusion)
12. Mandatory reviewers are a subset of the agent roster
13. Discretionary reviewer pool is a subset of the agent roster
14. Phase conditions reference recognized trigger types
15. Gate budget heuristics are internally consistent

**Cross-reference check** (compares adapter against installed agents):
16. Every agent in the roster has a corresponding AGENT.md installed (or a warning that it needs to be built)
17. Delegation table entries match agent boundaries (warning if a task routes to an agent whose "Does NOT do" section covers that task type)

Output format (matching despicable-lab's existing style):

```
DOMAIN: software-dev (v1.0)
AGENTS:   27 declared, 27 installed    OK
PHASES:   9 declared (5 required, 4 conditional)    OK
GATES:    Classification rules reference valid phases    OK
GOVERNANCE: 5 mandatory, 5 discretionary pool    OK
REVIEW:   Triggering rules reference valid agents    OK

WARNINGS:
  agents.md:42 -- debugger-minion listed as supporting for "Reverse engineering"
                   but debugger-minion AGENT.md does not list reverse engineering
                   in its capabilities (check boundary alignment)

STATUS: VALID (1 warning)
```

For a misconfigured adapter:

```
DOMAIN: ivdr (v0.1)
AGENTS:   12 declared, 8 installed    WARN (4 missing)
PHASES:   6 declared (4 required, 2 conditional)    OK
GATES:    FAIL -- gates.md references phase "code-review" which is not in phases.md
GOVERNANCE: FAIL -- mandatory reviewer "clinical-safety-minion" not in agent roster

ERRORS:
  gates.md:18 -- Phase reference "code-review" not found in phases.md
                  Available phases: intake, specialist-planning, synthesis,
                  execution, regulatory-review, documentation
                  Did you mean: "regulatory-review"?
  governance.md:5 -- Agent "clinical-safety-minion" not in agent roster (agents.md)
                     Did you mean: "clinical-safety" (closest match in roster)?

WARNINGS:
  agents.md -- 4 agents declared but not installed:
    clinical-safety, regulatory-affairs, biocompat-reviewer, risk-analyst
    Run: ./install.sh to create symlinks after building AGENT.md files

STATUS: INVALID (2 errors, 1 warning)
```

### (d) Error Messages for Misconfigured Adapters

Error messages should follow the three-component pattern: what went wrong, how to fix it, and where to learn more.

**Categories and specific messages:**

**Missing required files:**
```
Error: Domain adapter "ivdr" is missing required file: phases.md

  Expected: domains/ivdr/phases.md
  Present:  DOMAIN.md, agents.md, gates.md, governance.md

  phases.md defines the phase sequence for your domain. Copy from the
  default adapter and modify:
    cp domains/software-dev/phases.md domains/ivdr/phases.md

  Reference: docs/creating-adapters.md#step-3-define-your-phases
```

**Invalid frontmatter:**
```
Error: DOMAIN.md frontmatter missing required field: "phases"

  File: domains/ivdr/DOMAIN.md
  Required fields: name, description, version, phases
  Present fields: name, description, version

  The "phases" field declares the phase sequence. Example:
    phases:
      - id: intake
        type: planning
        required: true
      - id: execution
        type: execution
        required: true

  Reference: docs/adapter-spec.md#domain-md-frontmatter
```

**Phase reference errors:**
```
Error: Gate references unknown phase "code-review"

  File: domains/ivdr/gates.md, line 18
  Referenced phase: "code-review"
  Available phases: intake, specialist-planning, synthesis, execution,
                    regulatory-review, documentation

  Did you mean: "regulatory-review"?

  Gates can only reference phases declared in domains/ivdr/phases.md.
  Either add "code-review" to your phase sequence or update the gate
  to reference an existing phase.

  Reference: docs/adapter-spec.md#gate-phase-references
```

**Agent roster mismatches:**
```
Error: Mandatory reviewer "clinical-safety-minion" not found in agent roster

  File: domains/ivdr/governance.md, line 5
  Agent: "clinical-safety-minion"
  Closest match in roster: "clinical-safety" (agents.md, line 12)

  All mandatory and discretionary reviewers must be agents declared
  in agents.md. Update governance.md to use the correct agent name,
  or add the agent to your roster.

  Reference: docs/adapter-spec.md#governance-reviewer-requirements
```

**Missing phase types (structural):**
```
Error: Phase sequence must include at least one "execution" phase

  File: domains/ivdr/DOMAIN.md
  Declared phases: intake (planning), specialist-planning (planning),
                   synthesis (planning), regulatory-review (review)

  An execution phase is required -- this is where agents perform work
  on the target project. Add a phase with type "execution":
    - id: execution
      type: execution
      required: true

  Reference: docs/adapter-spec.md#phase-type-requirements
```

**Runtime errors (adapter loads but fails during orchestration):**
```
Error: Phase "regulatory-review" condition "regulatory-submission-exists"
       is not a recognized trigger type

  Recognized triggers: produced-code, tests-exist, user-requested,
                       docs-checklist-has-items, always, never

  Custom triggers are not yet supported. Use "always" to make the
  phase unconditional, or "user-requested" to let the user opt in.

  Workaround: Use "always" and have the reviewing agent check the
  condition within its prompt.

  Reference: docs/adapter-spec.md#phase-conditions
```

**Key design principles for these errors:**
- Cite the specific file, line, and field name -- adapter authors work in their editor, not the framework's internals
- Show "did you mean?" for name mismatches (Levenshtein distance)
- Show the list of valid values when a reference is invalid
- Every error includes a concrete fix (copy command, YAML snippet, or edit instruction)
- Every error links to the relevant docs section
- Warnings (non-fatal) are clearly distinguished from errors (fatal)
- Validation output is grep-friendly: `Error:` prefix for errors, `Warning:` prefix for warnings

### (e) How install.sh Needs to Change

**Recommendation: Minimal changes. Adapter selection is a runtime concern, not an install concern.**

Current `install.sh` creates symlinks from agent AGENT.md files and skill directories to `~/.claude/agents/` and `~/.claude/skills/`. This mechanism is domain-independent -- it does not care whether the agents are software-dev specialists or regulatory compliance analysts. The symlink targets are determined by directory structure, not by domain configuration.

**What stays the same:**
- Symlinking agents from `gru/`, `nefario/`, `lucy/`, `margo/`, `minions/*/` to `~/.claude/agents/`
- Symlinking skills from `skills/*/` to `~/.claude/skills/`
- The install/uninstall pattern
- The safety check (verify symlink target before removal)

**What changes:**

1. **Domain directory awareness**: install.sh should copy (not symlink) the active domain adapter to a known location where the framework can find it at runtime. The domain adapter directory is configuration, not an agent -- it does not get symlinked to `~/.claude/agents/`.

   ```bash
   # Install active domain adapter
   DOMAIN_DIR="${HOME}/.claude/domain"
   ACTIVE_DOMAIN="${1:-software-dev}"  # Default to software-dev

   if [[ -d "${SCRIPT_DIR}/domains/${ACTIVE_DOMAIN}" ]]; then
     rm -rf "$DOMAIN_DIR"
     cp -r "${SCRIPT_DIR}/domains/${ACTIVE_DOMAIN}" "$DOMAIN_DIR"
     print_msg "$COLOR_GREEN" "  Domain adapter: ${ACTIVE_DOMAIN}"
   fi
   ```

   Actually, on reflection, a symlink is better than a copy (stays in sync with repo changes):
   ```bash
   ln -sf "${SCRIPT_DIR}/domains/${ACTIVE_DOMAIN}" "$DOMAIN_DIR"
   ```

2. **Agent installation becomes adapter-driven**: Instead of hardcoding `gru/`, `nefario/`, `lucy/`, `margo/`, `minions/*/`, install.sh reads the agent roster from the active adapter's `agents.md` to determine which agents to install. This way, a regulatory compliance adapter that defines 12 agents only installs those 12.

   However, this introduces coupling between install.sh and the adapter format. A simpler approach: install.sh continues to install ALL agents it finds in the standard directories (current behavior). The domain adapter only affects which agents nefario considers at runtime. Agents that exist but are not in the active adapter's roster are installed but ignored by nefario.

   **Recommendation: Keep install.sh dumb. Install everything, let the adapter control runtime routing.** This is simpler and avoids making install.sh a parser for the adapter format. A forker who adds 12 regulatory compliance agents to `minions/` and removes the 23 software-dev agents gets the right behavior without any install.sh changes.

3. **Usage hint update**: install.sh should print a note about the active domain adapter:
   ```
   Installed 15 agents and 2 skills successfully.
   Active domain: ivdr (domains/ivdr/)
   ```

**Net change to install.sh: approximately 5-10 lines.** The domain symlink creation and a usage hint. The core mechanism does not change.

## Proposed Tasks

### Task 1: Define the Domain Adapter Contract (DOMAIN.md schema)

**What to do**: Design and document the DOMAIN.md frontmatter schema and the adapter directory structure. Define required vs. optional files, required vs. optional fields, and the type system for phase declarations, gate classifications, and governance rules.

**Deliverables**:
- `docs/adapter-spec.md` -- Reference specification for the adapter contract
- `domains/software-dev/DOMAIN.md` -- The default adapter with annotated frontmatter

**Dependencies**: None (this is the foundational task)

### Task 2: Extract Domain-Specific Content from nefario AGENT.md

**What to do**: Move the agent roster, delegation table, cross-cutting concern checklist, gate classification heuristics, and architecture review rules from `nefario/AGENT.md` into the `domains/software-dev/` adapter directory (agents.md, gates.md, governance.md, review.md). Replace the inline content in AGENT.md with a loading mechanism that reads from the active adapter.

**Deliverables**:
- `domains/software-dev/agents.md` -- Agent roster + delegation table
- `domains/software-dev/gates.md` -- Gate classification rules
- `domains/software-dev/governance.md` -- Mandatory/discretionary reviewers, cross-cutting checklist
- `domains/software-dev/review.md` -- Architecture review triggering rules
- Updated `nefario/AGENT.md` with adapter-loading references

**Dependencies**: Task 1 (needs the contract definition)

### Task 3: Extract Phase Definitions from SKILL.md

**What to do**: Separate the phase sequence, phase conditions, and phase-specific domain semantics (e.g., "Phase 5 runs code-review-minion, lucy, margo" is domain-specific; "Phase 5 spawns reviewers in parallel" is infrastructure) from `skills/nefario/SKILL.md` into `domains/software-dev/phases.md`. The SKILL.md retains the infrastructure mechanics; the phases.md carries the domain-specific parameters.

**Deliverables**:
- `domains/software-dev/phases.md` -- Phase sequence with domain-specific semantics
- Annotated SKILL.md showing the separation boundary (which sections are infrastructure, which are domain-parameterized)

**Dependencies**: Task 1 (needs the contract definition)

### Task 4: Write the Getting-Started Tutorial

**What to do**: Create `docs/creating-adapters.md` with the 7-step walkthrough described above. Include a hypothetical non-software-dev example (e.g., a simplified regulatory compliance adapter) alongside the software-dev default to illustrate what changes between domains.

**Deliverables**:
- `docs/creating-adapters.md`

**Dependencies**: Tasks 1, 2, 3 (needs the adapter contract and extracted default adapter to reference)

### Task 5: Implement Adapter Validation

**What to do**: Extend `/despicable-lab` (or create a new `/despicable-domain-check` skill) that runs structural, semantic, and cross-reference validation on a domain adapter directory. Implement the error messages designed above.

**Deliverables**:
- Validation skill or despicable-lab extension
- Error message implementations

**Dependencies**: Task 1 (needs the contract to validate against), Tasks 2-3 (needs the default adapter to test against)

### Task 6: Update install.sh

**What to do**: Add domain adapter symlink creation and usage hints to install.sh. Minimal changes per the recommendation above.

**Deliverables**:
- Updated `install.sh`

**Dependencies**: Task 1 (needs to know the adapter location convention)

## Risks and Concerns

### Risk 1: Adapter Format is Too Complex for the Value Delivered

The current system works well for software development. If the adapter format requires a forker to understand a complex schema, fill in many fields, and run multiple validation steps before getting a working result, the cost of domain adaptation may exceed the value. The adapter format must be simpler than "read the full 2328-line SKILL.md and modify it directly" -- otherwise it adds abstraction without reducing effort.

**Mitigation**: The annotated default adapter IS the documentation. A forker copies and edits -- they do not start from scratch. The validator catches mistakes early. The tutorial provides a guided path.

### Risk 2: Separation Creates Two Places to Look

Today, everything about nefario's behavior is in SKILL.md and AGENT.md. After separation, an adapter author needs to check SKILL.md (infrastructure), AGENT.md (orchestrator prompt), AND the adapter directory. If the separation boundary is unclear, people will not know which file to edit.

**Mitigation**: Clear naming and directory conventions. Everything in `domains/` is adapter-author territory. Everything in `skills/nefario/` is framework-maintainer territory. The tutorial makes this explicit. Error messages cite the correct file to edit.

### Risk 3: Default Adapter Bit-Rot

The software-dev adapter is extracted from SKILL.md/AGENT.md today, but future changes might be made to SKILL.md without updating the adapter, or vice versa. This creates a synchronization burden.

**Mitigation**: The adapter IS the source of truth for domain-specific configuration. SKILL.md reads from the adapter at runtime. There is no second copy to synchronize. However, this means infrastructure changes that affect adapter semantics must be coordinated -- this is the standard framework/plugin versioning problem.

### Risk 4: Validation Cannot Catch Semantic Errors

Structural validation (file exists, required fields present, phase IDs unique) is straightforward. But the most common adapter errors will be semantic: a gate classification that does not make sense for the domain, a cross-cutting checklist that misses an important dimension, or a delegation table with overlapping agent boundaries. These require domain judgment that automated validation cannot provide.

**Mitigation**: The `--advisory` mode provides a low-cost test path. An adapter author runs `/nefario --advisory <representative task>` to see whether the meta-plan, specialist selection, and synthesis produce sensible results for their domain. This is a functional test that exercises the full adapter without making code changes.

### Risk 5: install.sh Becoming a Configuration Parser

If install.sh starts reading adapter files to determine which agents to install, it becomes coupled to the adapter format and needs to parse markdown/YAML. This is fragile.

**Mitigation**: Keep install.sh dumb. It installs everything it finds. The adapter controls runtime routing only. A forker who removes software-dev agents and adds their own agents gets correct install behavior without modifying install.sh.

## Additional Agents Needed

**software-docs-minion** should be involved in execution (not planning). The documentation deliverables (adapter-spec.md, creating-adapters.md, annotated default adapter) are substantial and benefit from software-docs-minion's expertise in architecture documentation, C4 diagrams, and README structure. These documents are not typical code documentation -- they are interface specifications and tutorials that need careful information architecture.

No other agents beyond the current planning team are needed.
