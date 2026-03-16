You are designing the domain adapter format for despicable-agents and extracting the current software-development configuration as the first (default) adapter.

## Context

The audit in `/var/folders/3k/bfjvvz9s6dvdn_hvlhvr8lc00000gn/T//nefario-scratch-dV7OFI/separate-domain-orchestration-from-infra/audit-classification.md` identifies which content in SKILL.md and AGENT.md is domain-specific. Your job is to define the format for a domain adapter file and then extract the current software-dev content into that format.

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
8. **Phase types, not phase numbers**: The engine handles `planning`, `consultation`, `review`, `execution`, and `verification` phase types. The adapter composes from these.
9. **Named conditions, not inline predicates**: Phase conditions use a small vocabulary of observable facts.

## What to do

1. **Design the DOMAIN.md format.** Write the format specification as a section in the file itself (self-documenting). The YAML frontmatter carries: name, description, version, phase sequence (structured), governance constraints. The markdown body carries: agent roster, delegation table, cross-cutting checklist, gate classification heuristics (with domain-specific examples), reviewer configuration, model selection rules, artifact classification, and any domain-specific conventions (commit format, branch naming, secret patterns).

2. **Extract the software-dev adapter.** Take the domain-specific content identified in the audit and express it as `domains/software-dev/DOMAIN.md`. This must contain ALL content that a non-software domain would replace. After extraction, what remains in AGENT.md and SKILL.md should be domain-independent.

3. **Create the AGENT.md template.** Modify `nefario/AGENT.md` to replace inline domain-specific content with assembly markers (e.g., `<!-- @domain:roster -->`, `<!-- @domain:delegation-table -->`, etc.). The markers indicate where domain adapter content is inserted during assembly. Between markers, include a brief comment explaining what the adapter provides for that section.

4. **Annotate SKILL.md.** Add `<!-- DOMAIN-SPECIFIC: description -->` and `<!-- INFRASTRUCTURE -->` section markers to SKILL.md at the boundaries identified by the audit. Do NOT extract SKILL.md content into the adapter -- SKILL.md's domain-specific content is more tightly woven with infrastructure mechanics. Section markers are sufficient for SKILL.md; the forker replaces those sections in-place.

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

## What to produce

- `domains/software-dev/DOMAIN.md` -- The extracted software-development domain adapter
- `nefario/AGENT.md` -- Updated with assembly markers replacing inline domain content
- `skills/nefario/SKILL.md` -- Annotated with domain/infrastructure section markers
- Write a format specification document to `/var/folders/3k/bfjvvz9s6dvdn_hvlhvr8lc00000gn/T//nefario-scratch-dV7OFI/separate-domain-orchestration-from-infra/adapter-format.md`

## What NOT to do

- Do not build an assembly script yet (Task 3 handles that)
- Do not write the user-facing documentation (Task 4 handles that)
- Do not create multiple files per adapter (single DOMAIN.md per domain)
- Do not add runtime config loading, validation, or plugin lifecycle
- Do not change any infrastructure mechanics in SKILL.md -- only add markers
- Do not modify lucy's or margo's AGENT.md files
- Do not create example non-software adapters (out of scope)

## Key files to read

- `/var/folders/3k/bfjvvz9s6dvdn_hvlhvr8lc00000gn/T//nefario-scratch-dV7OFI/separate-domain-orchestration-from-infra/audit-classification.md` (Task 1 output)
- `/Users/ben/github/benpeter/2despicable/3/nefario/AGENT.md`
- `/Users/ben/github/benpeter/2despicable/3/skills/nefario/SKILL.md`

When you finish your task, mark it completed with TaskUpdate and send a message to the team lead with:
- File paths with change scope and line counts (e.g., "src/auth.ts (new OAuth flow, +142 lines)")
- 1-2 sentence summary of what was produced
This information populates the gate's DELIVERABLE section.
