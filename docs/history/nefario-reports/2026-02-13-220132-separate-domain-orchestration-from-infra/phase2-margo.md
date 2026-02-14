## Domain Plan Contribution: margo

### Recommendations

#### (a) Minimum Viable Adapter Contract

After reading the full 2328-line SKILL.md, the AGENT.md (870 lines), and the
orchestration docs, I can identify a surprisingly small surface that is truly
domain-specific. The minimum viable adapter contract should contain exactly
these five elements:

1. **Agent roster** -- the list of agents with names, descriptions, and
   groupings (currently the "Agent Team Roster" and "Delegation Table" in
   `nefario/AGENT.md`, lines 59-199). This is a flat data structure: agent
   name, description, group, and a routing table mapping task types to
   primary/supporting agents.

2. **Phase sequence** -- the ordered list of phases with names, conditions,
   and skip rules (currently the "Overview" section in SKILL.md, lines
   140-156). Today this is the fixed 1/2/3/3.5/4/5/6/7/8 sequence. A
   domain adapter declares its own sequence.

3. **Cross-cutting checklist** -- the six mandatory dimensions with their
   inclusion rules (currently in AGENT.md, lines 271-288). A regulatory
   domain would have different cross-cutting concerns (e.g., "audit trail"
   instead of "observability").

4. **Gate semantics** -- the classification matrix and gate types. The
   current reversibility/blast-radius matrix (AGENT.md, lines 293-310) is
   actually domain-neutral in structure but the examples are software-specific
   ("schema migration", "API contract"). The adapter provides domain-specific
   examples and thresholds.

5. **Mandatory reviewers** -- the list of always-included reviewers and the
   discretionary pool with domain signals (SKILL.md, lines 946-964).

Everything else -- scratch directory management, subagent spawning mechanics,
AskUserQuestion interaction patterns, compaction checkpoints, status file
management, secret sanitization, report generation, PR creation, the
communication protocol, inline summary templates, CONDENSE patterns -- is
domain-independent infrastructure.

That is the contract. Five data structures. No behavioral interfaces, no
abstract classes, no plugin lifecycle hooks.

#### (b) The Line Between "Explicit and Swappable" vs. "Plugin Framework"

The line is here: **make the existing implicit boundaries into explicit
sections in the document; do not build a loading mechanism**.

Today, SKILL.md is a single monolithic document where domain-specific content
(agent roster references, software-specific phase definitions, commit message
conventions) is woven into infrastructure content (spawning mechanics, gate
interaction flows, status file management). The separation work should:

- **DO**: Extract the five domain-specific data structures into clearly marked
  sections (or a separate file) that a fork can find and replace. Add comments
  or section headers marking the boundary: "DOMAIN-SPECIFIC: Replace this
  section for your domain" vs. "INFRASTRUCTURE: Do not modify for domain
  adaptation."

- **DO**: Write documentation explaining what each domain-specific section
  provides and what the infrastructure expects from it (the contract).

- **DO NOT**: Build a config file format, a YAML schema, a loader, a registry,
  a validation system, or any runtime indirection. There is one user of this
  system today (software development). Adding indirection for hypothetical
  second and third users adds complexity before the second use case exists.
  The second user (IVDR, linguistics, whatever) will fork and search-replace.
  That is fine. That is the simplest thing that works.

- **DO NOT**: Create an `adapters/` directory structure, a base-adapter
  interface, or any inheritance/composition mechanism. The first non-software
  adapter does not exist yet. When it does, the explicit section boundaries
  will make forking trivial. If a third adapter appears, then extract a shared
  base -- not before.

The test: after this work, can a person with no knowledge of the internals
find and replace the domain-specific parts by reading the documentation? If
yes, the separation is sufficient. Building more than that is building a
plugin framework for zero plugins.

#### (c) Decomposing the 2328-line SKILL.md Without Complex Indirection

I see three approaches, in order of ascending complexity:

**Option 1 (Recommended): Section markers, no file split.** Add clear
`<!-- DOMAIN-SPECIFIC -->` and `<!-- INFRASTRUCTURE -->` comment markers
throughout SKILL.md. A domain adapter searches for `DOMAIN-SPECIFIC` markers
and replaces those sections. The file stays monolithic. Pros: zero structural
change, zero risk of breaking behavior, easy to verify completeness. Cons:
the file is still 2328 lines.

**Option 2 (Acceptable): Extract domain config into a sibling file.** Create
`skills/nefario/DOMAIN.md` containing the five domain-specific data structures
(roster, phases, checklist, gate semantics, reviewers). SKILL.md references it
with instructions like "Read domain configuration from DOMAIN.md." A domain
adapter replaces DOMAIN.md and leaves SKILL.md untouched. Pros: clean
separation, single file to replace. Cons: introduces one level of indirection;
SKILL.md now depends on DOMAIN.md's format; any mismatch between what SKILL.md
expects and what DOMAIN.md provides is a silent failure.

**Option 3 (Reject): Split SKILL.md into multiple files by phase.** Create
`skill-phase1.md`, `skill-phase2.md`, etc. Cons: introduces a loading
sequence, scatters context across files, makes the orchestration harder to
understand as a whole, and solves a readability problem (file length) with an
architecture problem (file splitting). The 2328 lines are not a problem --
they are a feature. Everything is in one place. A domain adapter can use
find-and-replace.

I recommend Option 1 as the primary approach, with Option 2 as an acceptable
alternative if the team finds section markers insufficient.

#### (d) Handling "Mostly Infrastructure With Domain Parameters"

This is the subtlest question. Here are the specific cases I found in SKILL.md
and how to handle each:

| Element | Infrastructure or Domain? | Recommendation |
|---------|--------------------------|----------------|
| Execution loop (batch-gated, topological sort) | Infrastructure | Leave as-is. Every domain needs task ordering. |
| Commit message format (`<type>(<scope>): <summary>`) | Domain convention | Mark as domain-specific. A regulatory domain might use issue-tracker IDs instead. |
| Branch naming (`nefario/<slug>`) | Mostly infrastructure | The `nefario/` prefix is branding, the slug mechanism is infrastructure. Mark the prefix as domain-customizable. |
| PR creation and `gh` integration | Domain convention | Mark as domain-specific. Not every domain produces PRs. Some produce audit documents. |
| Phase 5 code review (code-review-minion, lucy, margo) | Domain-specific | The code-review concept is domain-specific. The dark-kitchen pattern and 2-round-cap mechanism are infrastructure. |
| Phase 6 test discovery and execution | Domain-specific | The test infrastructure detection (package.json, vitest, etc.) is entirely software-domain. |
| Phase 7 deployment | Domain-specific | Entirely software-domain. |
| Phase 8 documentation checklist | Mixed | The outcome-action table (lines 1919-1931) is domain-specific. The checklist mechanism is infrastructure. |
| Secret sanitization patterns | Mostly infrastructure | The specific patterns (sk-, AKIA, ghp_) are software/cloud domain. Other domains have different sensitive data patterns. Mark the pattern list as domain-configurable. |
| File classification for Phase 5 skip logic | Domain-specific | The table on lines 1761-1768 (AGENT.md = logic-bearing, README = docs-only) is entirely specific to this system. |
| Status file management | Infrastructure | Leave as-is. |
| Compaction checkpoints | Infrastructure | Leave as-is. |
| Report template | Mixed | The template structure is infrastructure. The section names and conditional rules have domain-specific elements. |

The pattern: do not try to parameterize these. Instead, mark them as domain-specific
sections. The domain adapter replaces the section wholesale. Trying to extract
"commit message format" as a configurable parameter leads to a configuration
schema, a validation layer, and a default-value mechanism -- three new pieces
of infrastructure for one string template.

### Proposed Tasks

**Task 1: Audit SKILL.md for domain-specific content**
- Walk through all 2328 lines of `skills/nefario/SKILL.md`
- Tag every section as INFRASTRUCTURE or DOMAIN-SPECIFIC
- For mixed sections, identify the exact boundary
- Deliverable: annotated SKILL.md with section markers (or a companion
  document mapping line ranges to classification)

**Task 2: Audit AGENT.md for domain-specific content**
- Same exercise for `nefario/AGENT.md` (870 lines)
- The agent roster, delegation table, cross-cutting checklist, and model
  selection rules are domain-specific
- The invocation modes, conflict resolution, and output standards are
  infrastructure
- Deliverable: annotated AGENT.md with section markers

**Task 3: Write the domain adapter documentation**
- Document the adapter contract: what a domain adapter must provide (the five
  data structures listed above)
- Document what the infrastructure provides (everything else)
- Include a "How to fork for a new domain" walkthrough
- Do NOT create a configuration schema, loader, or validator
- Deliverable: `docs/domain-adaptation.md`

**Task 4: Add section markers to SKILL.md and AGENT.md**
- Insert `<!-- DOMAIN-SPECIFIC: <description> -->` and
  `<!-- INFRASTRUCTURE -->` comment markers at the identified boundaries
- Verify that the existing software-development behavior is preserved
  (markers are comments, not behavioral changes)
- Deliverable: updated `skills/nefario/SKILL.md` and `nefario/AGENT.md`

**Task 5: Verify preservation of existing behavior**
- Run an existing orchestration after the changes to confirm no behavioral
  regression
- Verify that all phase transitions, gates, and post-execution flows work
  identically
- Deliverable: test report confirming no regression

### Risks and Concerns

1. **Over-engineering risk (HIGH):** The most likely failure mode is building
   a configuration/plugin layer that serves zero current users. The constraint
   says "do not dismiss as YAGNI" but the issue description also says the goal
   is that a forker "can identify and replace only the domain-specific parts."
   That goal is achievable with section markers and documentation alone. Any
   proposal involving a loader, registry, schema validator, or runtime
   indirection should be challenged.

2. **Complexity creep in the adapter contract:** The temptation will be to
   define a formal contract with required fields, optional fields, validation
   rules, and default values. Resist this. The contract is five prose sections
   in a markdown document. A forker reads the documentation, finds the
   sections, replaces them. Formalization beyond that is premature.

3. **SKILL.md decomposition breaking the single-source-of-truth property:**
   Today, SKILL.md is self-contained. Everything the orchestrator needs is in
   one file. If we split it into SKILL.md + DOMAIN.md + adapter-contract.md,
   we create a consistency problem: changes to SKILL.md might not be reflected
   in the domain contract documentation. Keep the number of files that need to
   stay in sync to the absolute minimum.

4. **Misclassifying domain-specific as infrastructure (or vice versa):**
   The gate interaction patterns (AskUserQuestion flows) look infrastructure
   but contain domain-specific labels ("P1 Team", "P3.5 Review"). The secret
   sanitization patterns look infrastructure but the specific regex patterns
   are cloud/software-specific. Getting these classifications wrong means a
   forker either misses things they need to change or changes things they
   should not. The audit task (Task 1) must be thorough.

5. **Scope creep into "building the second adapter":** The issue explicitly
   says "Out: Actually building non-software-domain agent sets." If any task
   starts defining what an IVDR or linguistics adapter would look like, that
   is scope creep. The deliverable is the boundary documentation and markers,
   not the adapters.

6. **File length is not a bug:** 2328 lines in one file is not a problem to
   solve. It is a design choice (single source of truth, no indirection, easy
   to search). If the decomposition conversation drifts toward "SKILL.md is
   too long, let's split it," that is a different issue from domain separation
   and should not be conflated with this work.

### Additional Agents Needed

None beyond the current team. This is fundamentally a documentation and
annotation exercise. The tasks involve:
- Reading and classifying existing content (audit)
- Writing documentation (adapter guide)
- Adding comment markers (minimal code change)
- Verification (manual testing)

No new domain expertise is required. The ai-modeling-minion is well-positioned
for the SKILL.md/AGENT.md audit work since these are prompt engineering
artifacts. The software-docs-minion handles the adapter documentation. Adding
more agents would be scope creep.
