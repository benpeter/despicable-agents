## Delegation Plan

**Team name**: domain-separation
**Description**: Separate domain-specific orchestration configuration from domain-independent infrastructure in nefario SKILL.md and AGENT.md, enabling reuse for non-software domains.

### Conflict Resolution: Margo's Minimalism vs. Structured Extraction

The central tension is between margo's "section markers + documentation only" and ai-modeling-minion/devx-minion's "schema + directory + tooling" approach. Both positions have merit. Here is the resolution:

**Resolution: Extract to a single sibling file (margo's Option 2), not a directory tree.**

Rationale:
1. The task explicitly says "do not dismiss as YAGNI" -- section markers alone do not create a clear, replaceable boundary. A forker would still need to understand which scattered markers to find across a 2328-line file. This fails the task's success criteria: "a hypothetical domain adapter can define its own phase sequence, gate criteria, and agent roster without editing infrastructure files."
2. However, devx-minion's multi-file directory (`agents.md`, `phases.md`, `gates.md`, `governance.md`, `review.md`) splits one coherent configuration across six files. This is over-decomposition for a configuration that will be read as a unit by the LLM prompt. Margo is right that this adds complexity beyond what is needed.
3. The middle path: extract the five domain-specific data structures (margo's contract) into a **single file** (`domains/software-dev/DOMAIN.md`) with clear sections. The file uses markdown with YAML frontmatter (devx-minion's format recommendation), keeping everything in one place while creating a clean replacement boundary. SKILL.md and AGENT.md reference this file.
4. ai-modeling-minion's critical insight about prompt assembly is adopted: at install time (not runtime), the domain adapter content is assembled into the nefario AGENT.md so the model sees one coherent prompt. This avoids the prompt coherence fragmentation risk while maintaining source-level separation.
5. No config loader, no registry, no validation runtime, no plugin lifecycle (margo's constraints honored). The `/despicable-lab` extension for validation (devx-minion's proposal) is deferred -- it is useful but not required for the separation to work. If it proves needed later, it can be added as a follow-up.

**What we reject:**
- Pure section markers with no file extraction (insufficient for "without editing infrastructure files" criterion)
- Six-file directory structure per adapter (over-decomposition)
- YAML-only configuration format (loses the prose heuristics that are essential for gate classification, cross-cutting judgment)
- Runtime config loading (adds infrastructure for zero users)
- Validation tooling in this iteration (can follow if needed)

### Task 1: Audit SKILL.md and AGENT.md for domain-specific content

- **Agent**: ai-modeling-minion
- **Delegation type**: standard
- **Model**: opus
- **Mode**: default
- **Blocked by**: none
- **Approval gate**: no
- **Prompt**: |
    You are auditing the nefario orchestration files to classify every section as INFRASTRUCTURE (domain-independent) or DOMAIN-SPECIFIC (would change for a non-software domain). This classification drives a refactoring that will extract domain-specific content into a replaceable adapter file.

    ## What to do

    Read these two files completely:
    1. `skills/nefario/SKILL.md` (2328 lines) -- the orchestration workflow
    2. `nefario/AGENT.md` (869 lines) -- the orchestrator's system prompt

    For each major section (H2, H3, or logical block), classify it:
    - **INFRASTRUCTURE**: Domain-independent mechanics that work the same regardless of domain (subagent spawning, scratch file management, status line, compaction, report generation, gate interaction mechanics, communication protocol, AskUserQuestion flows, content boundary markers, external skill discovery)
    - **DOMAIN-SPECIFIC**: Content that a non-software domain would replace (agent roster, delegation table, cross-cutting dimensions, mandatory/discretionary reviewers, phase-specific agent names, artifact classification, model selection rules mentioning specific agents, gate classification examples, commit/branch/PR conventions, secret sanitization patterns, post-execution phase definitions naming specific agents)
    - **MIXED**: Infrastructure mechanism with embedded domain-specific parameters. For these, identify the exact seam: what is the mechanism (infrastructure) and what are the parameters (domain-specific).

    Pay special attention to:
    - Phase announcements in SKILL.md that name specific phases (the numbering is domain-specific)
    - Reviewer prompt templates that reference software concepts
    - Conditional logic tied to "code" vs "docs" file classification
    - The dark-kitchen pattern (infrastructure) vs. which phases use it (domain-specific)
    - Gate interaction mechanics (infrastructure) vs. gate classification examples (domain-specific)
    - Secret sanitization: the mechanism is infrastructure, the regex patterns are domain-specific

    ## What to produce

    Write a classification document to `$SCRATCH_DIR/domain-separation/audit-classification.md` with this structure:

    ```
    # Domain/Infrastructure Classification

    ## SKILL.md

    ### Section: <name> (lines N-M)
    Classification: INFRASTRUCTURE | DOMAIN-SPECIFIC | MIXED
    Rationale: <why>
    [If MIXED] Infrastructure part: <what>
    [If MIXED] Domain-specific part: <what>
    [If MIXED] Extraction approach: <how to separate>

    ## AGENT.md

    ### Section: <name> (lines N-M)
    ...

    ## Summary

    Total domain-specific sections: N
    Total infrastructure sections: N
    Total mixed sections: N
    Estimated domain-specific content volume: ~N lines
    ```

    ## What NOT to do

    - Do not modify any files. This is a read-only audit.
    - Do not propose solutions or schemas. That is Task 2's job.
    - Do not assess whether the separation is a good idea. That decision is made.
    - Do not skip the SKILL.md analysis -- it is the larger and more complex file.

    ## Context

    The goal is to enable a user forking despicable-agents for a non-software domain (e.g., regulatory compliance, corpus linguistics) to replace only domain-specific parts. The audit identifies what those parts are. The current system has 26 software-development specialist agents, a 9-phase workflow, and software-specific post-execution verification (code review, test execution, deployment, documentation).

    Key files to read:
    - `/Users/ben/github/benpeter/2despicable/3/skills/nefario/SKILL.md`
    - `/Users/ben/github/benpeter/2despicable/3/nefario/AGENT.md`
- **Deliverables**: `$SCRATCH_DIR/domain-separation/audit-classification.md`
- **Success criteria**: Every section of both files is classified. Mixed sections have clear seam identification. The summary provides a quantitative picture of how much content is domain-specific.

### Task 2: Design the domain adapter format and extract the software-dev adapter

- **Agent**: ai-modeling-minion
- **Delegation type**: standard
- **Model**: opus
- **Mode**: default
- **Blocked by**: Task 1
- **Approval gate**: yes
- **Gate reason**: The adapter format is the central architectural decision. It defines the contract between infrastructure and domain configuration. All downstream tasks depend on it. Hard to reverse once extraction begins.
- **Prompt**: |
    You are designing the domain adapter format for despicable-agents and extracting the current software-development configuration as the first (default) adapter.

    ## Context

    The audit in `$SCRATCH_DIR/domain-separation/audit-classification.md` identifies which content in SKILL.md and AGENT.md is domain-specific. Your job is to define the format for a domain adapter file and then extract the current software-dev content into that format.

    ## Design Constraints (from team consensus)

    1. **Single file per domain**: The adapter is ONE markdown file (`domains/software-dev/DOMAIN.md`) with YAML frontmatter for structured fields and markdown body for prose heuristics. NOT a directory of multiple files.
    2. **No config loader or registry**: The adapter file is read by a build/assembly step that produces the final AGENT.md. No runtime indirection.
    3. **Markdown with YAML frontmatter**: Matches the project's existing conventions (AGENT.md, SKILL.md use this pattern).
    4. **Five core data structures** (minimum adapter contract):
       - Agent roster (names, descriptions, groups, delegation table)
       - Phase sequence (ordered phases with types, conditions, skip rules)
       - Cross-cutting checklist (mandatory dimensions with inclusion rules)
       - Gate semantics (classification matrix examples, domain-specific "hard to reverse" examples)
       - Reviewer configuration (mandatory reviewers, discretionary pool with domain signals)
    5. **Assembly model**: At install time, `DOMAIN.md` content is composed into the nefario AGENT.md template to produce a fully materialized prompt. The model sees one coherent document, not a reference to external config.
    6. **Governance is universal**: lucy and margo are framework-level, always present. The adapter can ADD governance reviewers but cannot remove lucy or margo. The adapter provides review focus hints that extend (not replace) their default review scope.
    7. **Cross-cutting dimensions are adapter-supplied**: The six current dimensions (testing, security, usability-strategy, usability-design, documentation, observability) are software-dev-specific. The adapter declares its own. The framework enforces the pattern (include by default, exclude with justification) but not the specific dimensions.
    8. **Phase types, not phase numbers**: The engine handles `planning`, `consultation`, `review`, `execution`, and `verification` phase types. The adapter composes from these. No "Phase 3.5" in the adapter -- that is a software-dev label.
    9. **Named conditions, not inline predicates**: Phase conditions use a small vocabulary of observable facts (artifact-type exists, user flag set, agent verdict received). The adapter maps domain concepts to these primitives.

    ## What to do

    1. **Design the DOMAIN.md format.** Write the format specification as a section in the file itself (self-documenting). The YAML frontmatter carries: name, description, version, phase sequence (structured), governance constraints. The markdown body carries: agent roster, delegation table, cross-cutting checklist, gate classification heuristics (with domain-specific examples), reviewer configuration, model selection rules, artifact classification, and any domain-specific conventions (commit format, branch naming, secret patterns).

    2. **Extract the software-dev adapter.** Take the domain-specific content identified in the audit and express it as `domains/software-dev/DOMAIN.md`. This must contain ALL content that a non-software domain would replace. After extraction, what remains in AGENT.md and SKILL.md should be domain-independent.

    3. **Create the AGENT.md template.** Modify `nefario/AGENT.md` to replace inline domain-specific content with assembly markers (e.g., `<!-- @domain:roster -->`, `<!-- @domain:delegation-table -->`, etc.). The markers indicate where domain adapter content is inserted during assembly. Between markers, include a brief comment explaining what the adapter provides for that section.

    4. **Annotate SKILL.md.** Add `<!-- DOMAIN-SPECIFIC: description -->` and `<!-- INFRASTRUCTURE -->` section markers to SKILL.md at the boundaries identified by the audit. Do NOT extract SKILL.md content into the adapter -- SKILL.md's domain-specific content is more tightly woven with infrastructure mechanics. Section markers are sufficient for SKILL.md; the forker replaces those sections in-place.

    ## What to produce

    - `domains/software-dev/DOMAIN.md` -- The extracted software-development domain adapter
    - `nefario/AGENT.md` -- Updated with assembly markers replacing inline domain content
    - `skills/nefario/SKILL.md` -- Annotated with domain/infrastructure section markers
    - `$SCRATCH_DIR/domain-separation/adapter-format.md` -- Format specification document explaining the adapter contract, what each section provides, and assembly mechanics

    ## What NOT to do

    - Do not build an assembly script yet (Task 3 handles that)
    - Do not write the user-facing documentation (Task 4 handles that)
    - Do not create multiple files per adapter (single DOMAIN.md per domain)
    - Do not add runtime config loading, validation, or plugin lifecycle
    - Do not change any infrastructure mechanics in SKILL.md -- only add markers
    - Do not modify lucy's or margo's AGENT.md files
    - Do not create example non-software adapters (out of scope)

    ## Key files to read

    - `$SCRATCH_DIR/domain-separation/audit-classification.md` (Task 1 output)
    - `/Users/ben/github/benpeter/2despicable/3/nefario/AGENT.md`
    - `/Users/ben/github/benpeter/2despicable/3/skills/nefario/SKILL.md`

    ## Prompt Assembly Note

    The assembly markers in AGENT.md should be simple HTML comments that a shell script can find-and-replace. Pattern:
    ```
    <!-- @domain:section-name BEGIN -->
    (placeholder text explaining what goes here)
    <!-- @domain:section-name END -->
    ```
    The assembly script replaces everything between BEGIN and END (inclusive of the markers) with the corresponding section from DOMAIN.md. The DOMAIN.md sections use matching identifiers:
    ```
    ## @roster
    (agent roster content)

    ## @delegation-table
    (delegation table content)
    ```
- **Deliverables**: `domains/software-dev/DOMAIN.md`, updated `nefario/AGENT.md`, annotated `skills/nefario/SKILL.md`, `$SCRATCH_DIR/domain-separation/adapter-format.md`
- **Success criteria**: (1) DOMAIN.md contains all five data structures from margo's contract. (2) AGENT.md has assembly markers, no inline domain-specific agent names/tables. (3) SKILL.md has section markers at every domain/infrastructure boundary. (4) The format spec is clear enough that a reader could create a new adapter without additional guidance.

### Task 3: Build the prompt assembly script and update install.sh

- **Agent**: devx-minion
- **Delegation type**: standard
- **Model**: opus
- **Mode**: default
- **Blocked by**: Task 2
- **Approval gate**: no
- **Prompt**: |
    You are building the assembly mechanism that composes a domain adapter (DOMAIN.md) with the nefario AGENT.md template to produce a fully materialized agent prompt.

    ## Context

    The nefario orchestrator's AGENT.md has been refactored (Task 2) to contain assembly markers like:
    ```
    <!-- @domain:section-name BEGIN -->
    (placeholder)
    <!-- @domain:section-name END -->
    ```

    The domain adapter (`domains/software-dev/DOMAIN.md`) contains sections with matching identifiers:
    ```
    ## @roster
    (content)
    ```

    Your job: build a shell script that replaces the markers in AGENT.md with content from DOMAIN.md, producing a complete agent prompt.

    ## What to do

    1. **Create `assemble.sh`** at the project root. This script:
       - Takes an optional domain name argument (default: `software-dev`)
       - Reads `domains/<name>/DOMAIN.md` and `nefario/AGENT.md` (the template)
       - For each `<!-- @domain:X BEGIN -->...<!-- @domain:X END -->` block in AGENT.md, replaces it with the corresponding `## @X` section content from DOMAIN.md
       - Writes the assembled result to `nefario/AGENT.md` (overwriting the template markers with actual content)
       - Reports which sections were assembled and any missing sections
       - Uses only bash, sed, and awk -- no external dependencies

    2. **Update `install.sh`** to:
       - Run `assemble.sh` before creating symlinks (assemble first, then symlink the result)
       - Accept an optional `--domain <name>` flag (default: `software-dev`)
       - Print the active domain in the install summary
       - Net change: approximately 5-10 lines added

    3. **Create `disassemble.sh`** (reverse operation): Given an assembled AGENT.md and the domain adapter, restore the template markers. This is a maintenance tool for when someone edits the assembled AGENT.md and needs to propagate changes back.

    ## What to produce

    - `assemble.sh` -- The assembly script
    - `disassemble.sh` -- The reverse operation
    - Updated `install.sh` -- With domain assembly integration
    - Brief usage documentation as comments in each script

    ## What NOT to do

    - Do not use any language other than bash (no Python, no Node.js)
    - Do not build a config parser, validator, or registry
    - Do not modify DOMAIN.md, AGENT.md content, or SKILL.md -- only consume them
    - Do not add npm/pip/cargo dependencies
    - Do not handle SKILL.md assembly -- SKILL.md uses section markers for in-place replacement, not automated assembly

    ## Design constraints

    - The assembly must be idempotent: running it twice produces the same result
    - The script must fail clearly if a marker in AGENT.md has no corresponding section in DOMAIN.md (missing section error, not silent omission)
    - The script must preserve all non-marker content in AGENT.md exactly
    - YAML frontmatter in AGENT.md is preserved as-is (assembly only affects markdown body)
    - Keep it simple: this is a text substitution script, not a template engine

    ## Key files to read

    - `$SCRATCH_DIR/domain-separation/adapter-format.md` (format specification from Task 2)
    - `/Users/ben/github/benpeter/2despicable/3/nefario/AGENT.md` (with assembly markers)
    - `/Users/ben/github/benpeter/2despicable/3/domains/software-dev/DOMAIN.md` (the adapter)
    - `/Users/ben/github/benpeter/2despicable/3/install.sh` (to be updated)
- **Deliverables**: `assemble.sh`, `disassemble.sh`, updated `install.sh`
- **Success criteria**: (1) `./assemble.sh` produces an AGENT.md identical to the current (pre-refactor) AGENT.md. (2) `./assemble.sh && ./install.sh` works end-to-end. (3) `./disassemble.sh` restores the template. (4) Scripts are idempotent.

### Task 4: Write domain adaptation documentation

- **Agent**: software-docs-minion
- **Delegation type**: standard
- **Model**: opus
- **Mode**: default
- **Blocked by**: Task 2, Task 3
- **Approval gate**: no
- **Prompt**: |
    You are writing the documentation that explains how to create a domain adapter for despicable-agents. The audience is someone forking the project for a non-software domain (e.g., regulatory compliance validation, corpus linguistics) who has no deep knowledge of the framework internals.

    ## What to do

    Create `docs/domain-adaptation.md` with the following structure:

    ### 1. Overview (2-3 paragraphs)
    What despicable-agents is, what domain adaptation means, what the adapter controls vs. what the framework handles. Use the "you define WHAT agents you have and HOW they coordinate; the framework handles the mechanics of spawning, messaging, reporting" framing.

    ### 2. What the Framework Provides (explicit list)
    List every infrastructure capability the adapter author gets for free:
    - Subagent spawning and lifecycle management
    - Scratch directory and file management
    - Status line and session tracking
    - Compaction checkpoints
    - Gate interaction mechanics (presentation, response handling, anti-fatigue)
    - Communication protocol (SHOW/NEVER SHOW/CONDENSE)
    - External skill discovery and classification
    - Report generation
    - Branch/PR creation mechanics (when applicable)
    - Content boundary markers

    ### 3. What the Adapter Must Provide (the contract)
    For each of the five data structures, explain:
    - What it is and why the framework needs it
    - The format (reference the DOMAIN.md sections)
    - A side-by-side showing the software-dev value and what a hypothetical regulatory compliance adapter might provide (brief, illustrative -- not a full adapter)

    The five data structures:
    1. Agent roster and delegation table
    2. Phase sequence
    3. Cross-cutting checklist
    4. Gate classification heuristics
    5. Reviewer configuration (mandatory + discretionary)

    ### 4. How to Create a New Adapter (step-by-step walkthrough)
    1. Fork the repository
    2. Copy `domains/software-dev/` to `domains/your-domain/`
    3. Edit DOMAIN.md -- replace each section
    4. Build your agents (create AGENT.md files for your specialist agents)
    5. Run `./assemble.sh your-domain` to produce the assembled AGENT.md
    6. Run `./install.sh --domain your-domain` to deploy
    7. Test with `/nefario --advisory <representative task>` to verify

    ### 5. What You Do NOT Need to Change
    Explicitly list what should NOT be modified: SKILL.md infrastructure sections, the communication protocol, scratch management, report generation template structure. Explain WHY (these are domain-independent mechanics).

    ### 6. Governance Constraints
    Explain that lucy and margo are always present, what review focus hints are, and how to extend (but not replace) mandatory governance. Reference lucy's contribution about governance universality.

    ## What to produce

    - `docs/domain-adaptation.md`

    ## What NOT to do

    - Do not create a full non-software adapter (out of scope)
    - Do not duplicate the DOMAIN.md format spec (reference it)
    - Do not explain framework internals beyond what the adapter author needs
    - Do not write a reference specification (that is the format spec from Task 2)

    ## Key files to read

    - `/Users/ben/github/benpeter/2despicable/3/domains/software-dev/DOMAIN.md` (the reference adapter)
    - `$SCRATCH_DIR/domain-separation/adapter-format.md` (the format specification)
    - `/Users/ben/github/benpeter/2despicable/3/docs/architecture.md` (existing architecture docs, for style consistency)
    - `/Users/ben/github/benpeter/2despicable/3/assemble.sh` (assembly tooling)
    - `/Users/ben/github/benpeter/2despicable/3/install.sh` (installation process)
- **Deliverables**: `docs/domain-adaptation.md`
- **Success criteria**: A reader unfamiliar with the framework internals can follow the walkthrough to create a new adapter. The contract is complete (all five data structures documented). The boundary between "your problem" and "framework handles it" is explicit.

### Task 5: Verify behavioral equivalence

- **Agent**: ai-modeling-minion
- **Delegation type**: standard
- **Model**: opus
- **Mode**: default
- **Blocked by**: Task 3
- **Approval gate**: no
- **Prompt**: |
    You are verifying that the refactored system (nefario AGENT.md assembled from template + software-dev domain adapter) produces functionally identical behavior to the original monolithic AGENT.md.

    ## What to do

    1. **Run the assembly**: Execute `./assemble.sh software-dev` to produce the assembled AGENT.md.

    2. **Diff the assembled output against the original**: The original AGENT.md content (before refactoring) should be preserved in git history. Compare the assembled output against the last commit's AGENT.md. Differences should be limited to:
       - Assembly marker artifacts (comments) -- these should NOT be present in assembled output
       - Whitespace normalization (acceptable)
       - No semantic content differences (unacceptable)

    3. **Check SKILL.md section markers**: Verify that the `<!-- DOMAIN-SPECIFIC -->` and `<!-- INFRASTRUCTURE -->` markers in SKILL.md are HTML comments only and do not alter the file's behavior when consumed by the LLM (they should be treated as invisible by the model).

    4. **Verify the adapter contract completeness**: Check that every domain-specific section identified in the audit (Task 1) is either:
       - Extracted into DOMAIN.md (for AGENT.md content), or
       - Marked with section markers (for SKILL.md content)
       Nothing domain-specific should remain unmarked/unextracted.

    5. **Verify governance invariants**: Confirm that:
       - lucy and margo appear in the assembled AGENT.md's mandatory reviewer list
       - The cross-cutting checklist in the assembled output matches the original
       - The gate classification examples in the assembled output match the original

    6. **Run install.sh**: Execute `./install.sh` and verify that the symlinks are created correctly and point to the assembled AGENT.md.

    ## What to produce

    Write a verification report to `$SCRATCH_DIR/domain-separation/verification-report.md`:

    ```
    # Behavioral Equivalence Verification

    ## Assembly Output Diff
    - Lines changed: N
    - Semantic differences: [none | list]

    ## SKILL.md Markers
    - Total markers added: N
    - All are HTML comments: yes/no
    - Behavioral impact: none/[describe]

    ## Adapter Completeness
    - Audit items extracted/marked: N/N
    - Missing items: [none | list]

    ## Governance Invariants
    - lucy in mandatory reviewers: yes/no
    - margo in mandatory reviewers: yes/no
    - Cross-cutting checklist preserved: yes/no
    - Gate examples preserved: yes/no

    ## Install Verification
    - install.sh exit code: 0/N
    - Symlinks created: N
    - AGENT.md symlink target correct: yes/no

    ## Verdict: PASS / FAIL
    [If FAIL, list each failure with remediation]
    ```

    ## What NOT to do

    - Do not modify any files to make the verification pass. Report failures; Task 2 or Task 3 authors fix them.
    - Do not test non-software-dev adapters (out of scope).
    - Do not run actual orchestration sessions (we are verifying static equivalence, not runtime behavior).

    ## Key files

    - `/Users/ben/github/benpeter/2despicable/3/nefario/AGENT.md` (assembled)
    - `/Users/ben/github/benpeter/2despicable/3/domains/software-dev/DOMAIN.md`
    - `/Users/ben/github/benpeter/2despicable/3/skills/nefario/SKILL.md`
    - `/Users/ben/github/benpeter/2despicable/3/assemble.sh`
    - `/Users/ben/github/benpeter/2despicable/3/install.sh`
    - `$SCRATCH_DIR/domain-separation/audit-classification.md` (Task 1 output)
- **Deliverables**: `$SCRATCH_DIR/domain-separation/verification-report.md`
- **Success criteria**: Verdict is PASS. The assembled AGENT.md is semantically identical to the original. All domain-specific content is accounted for.

### Cross-Cutting Coverage

- **Testing**: Covered by Task 5 (behavioral equivalence verification). No executable code is produced that needs unit tests -- the assembly script is verified through diff comparison. Phase 6 post-execution will additionally run any existing tests.
- **Security**: Not applicable. This task does not create attack surface, handle authentication, process user input, or manage secrets. The secret sanitization patterns are *classified* (domain-specific) but not changed. Excluded with justification: the work is a documentation and refactoring exercise on configuration files.
- **Usability -- Strategy**: Covered implicitly by the adapter format design (Task 2) and documentation (Task 4). The "user" here is the domain adapter author, and their journey is the central design concern. ux-strategy-minion is not included as a separate execution task because the adapter author experience is directly designed by ai-modeling-minion (format) and software-docs-minion (documentation) who are the domain experts for this specific "user." Phase 3.5 review will include ux-strategy-minion's assessment.
- **Usability -- Design**: Not applicable. No user-facing interfaces are produced. The outputs are markdown files and shell scripts consumed by developers. Excluded with justification: no visual, interaction, or accessibility design surface.
- **Documentation**: Covered by Task 4 (software-docs-minion writes the domain adaptation guide). Phase 8 post-execution documentation will also run.
- **Observability**: Not applicable. No runtime services, APIs, or background processes are created. The assembly script runs at install time, not in production. Excluded with justification: no runtime component to observe.

### Architecture Review Agents

- **Mandatory** (5): security-minion, test-minion, ux-strategy-minion, lucy, margo
- **Discretionary picks**:
  - user-docs-minion: Task 4 produces documentation that changes how adapter authors interact with the framework; user-docs should review the tutorial quality and information architecture.
- **Not selected**: ux-design-minion, accessibility-minion, sitespeed-minion, observability-minion

### Conflict Resolutions

1. **Margo (section markers only) vs. ai-modeling-minion/devx-minion (structured extraction)**:
   Resolved in favor of a middle path: single-file extraction for AGENT.md content (satisfies the "without editing infrastructure files" criterion from the task), section markers for SKILL.md content (SKILL.md's domain-specific content is too tightly interwoven with infrastructure for clean extraction). See detailed resolution at the top of this plan.

2. **Devx-minion (multi-file adapter directory) vs. margo (minimize files)**:
   Resolved in margo's direction: single DOMAIN.md file per adapter. The multi-file split (agents.md, phases.md, gates.md, governance.md, review.md) adds navigational overhead without proportional benefit. The adapter is one coherent configuration document.

3. **Lucy (cross-cutting dimensions are all domain-specific) vs. ai-modeling-minion (some structural enforcement)**:
   Both positions adopted: the *specific dimensions and agents* are adapter-supplied (lucy's classification), but the framework enforces structural constraints on the adapter -- at least one cross-cutting dimension declared, governance reviewers always include lucy and margo (ai-modeling-minion's minimum-reviewer-slot enforcement).

4. **Devx-minion (validation tooling in this iteration) vs. margo (no tooling)**:
   Resolved in margo's direction for this iteration. Validation tooling (`/despicable-lab --check-domain`) is valuable but is not required for the separation to work. The first adapter author will fork and edit; they can validate by running `./assemble.sh && /nefario --advisory <test task>`. Validation tooling can be a follow-up if demand materializes.

5. **ai-modeling-minion (prompt assembly at invocation time) vs. devx-minion (install time)**:
   Resolved as install-time assembly. Invocation-time assembly would require the skill to read and compose files on every run, adding latency and complexity. Install-time assembly produces a static AGENT.md that works with the existing symlink deployment model.

### Risks and Mitigations

1. **Behavioral regression during extraction (HIGH)** -- The assembled AGENT.md must be semantically identical to the original. Task 5 is dedicated to verifying this. Mitigation: git history preserves the original; diff comparison catches any divergence.

2. **Prompt coherence fragmentation (HIGH)** -- The adapter content must be inline in the final prompt, not referenced as external config. Mitigation: install-time assembly ensures the model sees one coherent document. The separation exists in source only.

3. **SKILL.md marker accuracy (MEDIUM)** -- Misclassifying domain-specific content as infrastructure (or vice versa) means forkers miss things or change things they should not. Mitigation: Task 1 is a dedicated audit; Task 5 cross-references the audit against the actual markers.

4. **Adapter schema stability (MEDIUM)** -- The DOMAIN.md format becomes a contract. Changes are breaking for any existing adapter. Mitigation: conservative design (fewer, more general sections), version field in frontmatter from day one.

5. **Assembly script fragility (LOW-MEDIUM)** -- The sed/awk-based assembly could break on edge cases (special characters in adapter content, mismatched markers). Mitigation: Task 5 verification catches these. The assembly is simple text substitution on markdown, which is well-suited to line-oriented tools.

6. **Over-abstraction pressure in future iterations (LOW)** -- Once the adapter format exists, there will be pressure to add config loading, validation, runtime indirection. Mitigation: documentation explicitly states the design philosophy (margo's principle: "make the existing implicit boundaries into explicit sections; do not build a loading mechanism"). The assembly script is the only mechanism.

### Execution Order

```
Batch 1: Task 1 (audit) -- no dependencies
   |
Batch 2: Task 2 (adapter format + extraction) -- depends on Task 1
   |                                              [APPROVAL GATE]
   |
Batch 3: Task 3 (assembly script) + Task 4 (documentation) -- both depend on Task 2, parallel
   |
Batch 4: Task 5 (verification) -- depends on Task 3
```

Gate position: After Task 2 (adapter format design), before Tasks 3 and 4. This is the MUST gate -- the adapter format is hard to reverse and all downstream tasks depend on it.

### Verification Steps

After all tasks complete:
1. `./assemble.sh software-dev` produces an AGENT.md semantically identical to the pre-refactor version (Task 5 confirms)
2. `./install.sh` works with the assembled output (Task 5 confirms)
3. `docs/domain-adaptation.md` exists and covers all five adapter contract elements (Task 4 deliverable)
4. `domains/software-dev/DOMAIN.md` exists and contains the extracted domain configuration (Task 2 deliverable)
5. `skills/nefario/SKILL.md` has section markers at domain/infrastructure boundaries (Task 2 deliverable)
6. No behavioral change in existing orchestration (the separation is invisible to end users)
