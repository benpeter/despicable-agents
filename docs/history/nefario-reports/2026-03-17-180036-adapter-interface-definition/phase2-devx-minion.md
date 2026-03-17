# Phase 2 Contribution: devx-minion -- Format Decision for Adapter Interface Types

## Question Addressed

What is the right format for defining `DelegationRequest` and `DelegationResult` types in a Markdown-native project? Options evaluated: (a) pure Markdown specification with field tables, (b) YAML schema definition, (c) TypeScript type definitions as a reference spec, (d) shell-level conventions.

---

## Domain Plan Contribution: devx-minion

### Recommendations

#### Format Decision: (a) Pure Markdown specification with field tables -- with one supplement

The recommendation is **option (a): pure Markdown field tables**, enhanced with a single YAML example block per type to show what a concrete request/result looks like on the wire.

**Why this format wins:**

1. **It matches the codebase's character.** Every contract in this project is already expressed as Markdown: AGENT.md frontmatter schemas are documented as field tables in `docs/agent-anatomy.md`, routing config is specified as YAML examples inside prose in the feasibility study, and the assembly mechanism in `assemble.sh` operates on Markdown sections. The project's native language for defining structured contracts is Markdown prose with tables. Adding a different formalism would be the first instance of its kind in the project.

2. **The consumers are humans and LLMs, not compilers.** The downstream consumers of this contract are adapter wrapper scripts (Issues 2.1, 3.2) written in shell, the orchestrator (nefario -- an LLM reading Markdown), and the routing config loader (Issue 1.2, also shell). None of these consumers parse a schema definition at runtime. The types are a human-readable contract that developers implement by reading the spec and writing shell code. Markdown tables are the highest-fidelity format for this consumption pattern.

3. **YAGNI eliminates the other options.**
   - **(b) YAML/JSON Schema**: Machine-readable schemas are valuable when tooling validates instances against them at runtime. Nothing in Milestones 1-4 does this. The routing config validation (Issue 1.2) is shell-based -- it will validate by checking field presence in a parsed YAML file, not by running a JSON Schema validator. A schema definition would be a second source of truth that nothing reads.
   - **(c) TypeScript type definitions**: The roadmap's "What NOT to Build" section explicitly says "No TypeScript orchestrator." TypeScript types would be orphaned -- not compiled, not imported, not type-checked. They would serve as documentation-with-syntax-highlighting, which Markdown field tables do more clearly with less cognitive overhead. The prior mcp-minion contribution used TypeScript interfaces as illustration, which is fine for a planning document, but should not be the canonical format in the deliverable.
   - **(d) Shell-level conventions**: Exit codes and env vars are part of the contract but are not a sufficient format for the full type definition. They cover DelegationResult's exit code and DelegationRequest's working directory, but not the richer fields (changed files list, summary, context files). Shell conventions document implementation mechanics, not semantic contracts.

4. **The precedent is already established.** Look at `docs/agent-anatomy.md` -- it defines the AGENT.md frontmatter schema as a YAML example block followed by a field table with columns for field name, required/optional, and purpose. This is exactly the pattern needed for DelegationRequest and DelegationResult. Using the same format creates consistency for adapter authors who already understand the project's documentation style.

#### Format Structure

Each type should be documented as:

1. **A one-paragraph purpose statement** (what this type represents, who produces it, who consumes it)
2. **A YAML example block** showing a realistic instance with all fields populated (not a schema -- a concrete example that someone could mentally diff against their implementation)
3. **A field table** with columns: Field, Required, Type, Description
4. **A notes section** covering semantics that the table cannot capture (e.g., "the summary field is populated differently by different adapters")

The YAML example serves the same role as the routing config examples in the feasibility study: it gives the reader an immediate mental model before they parse the field-by-field details. YAML rather than JSON because the project already uses YAML for structured data (frontmatter, routing config examples).

#### What "Type" means in this column

Since there is no type checker, the "Type" column in the field table uses plain English type descriptors that shell implementors can act on: `string`, `integer`, `boolean`, `list of strings`, `list of FileChange (see below)`, `map of string to string`. These are not programming language types -- they describe what the field contains so that a shell script can decide how to produce or parse it.

#### Where the spec lives

A new document at `docs/adapter-interface.md`, linked from `docs/architecture.md` (the hub document). This follows the project's existing hub-and-spoke documentation pattern. The document is the canonical contract that Issues 1.2, 1.3, 2.1, 3.2, and 4.1 implement against.

### Proposed Tasks

**Task 1: Write the adapter interface specification document**

- **What**: Create `docs/adapter-interface.md` containing:
  - `DelegationRequest` type: purpose, YAML example, field table, notes
  - `DelegationResult` type: purpose, YAML example, field table, notes
  - `FileChange` sub-type (for the changedFiles list): field table
  - Instruction file lifecycle section (write before, clean up after)
  - Pre-invocation git ref capture convention
  - A "Format Decision" section documenting why Markdown field tables were chosen (per the roadmap's "document the decision" requirement)
- **Deliverables**: `docs/adapter-interface.md`
- **Dependencies**: api-design-minion contribution (provides the field definitions this document formalizes)

**Task 2: Link from architecture hub**

- **What**: Add a link to `docs/adapter-interface.md` from `docs/architecture.md` in the appropriate section
- **Deliverables**: Updated `docs/architecture.md`
- **Dependencies**: Task 1

### Risks and Concerns

1. **Markdown tables cannot express nesting well.** If `DelegationResult.usage` is a nested object with its own fields (inputTokens, outputTokens, model, durationMs), a flat field table gets awkward. Mitigation: define `usage` as a separate sub-type table below the main table, the same way `FileChange` would be separated. This is how `docs/agent-anatomy.md` handles the frontmatter schema (flat table, no nesting needed). Keep nesting to one level maximum.

2. **Drift between spec and implementation.** With no type checker enforcing the contract, adapter wrappers could diverge from the spec over time. Mitigation: this is acceptable for two adapters (Codex, Aider). If adapter count grows beyond three, consider adding a shell-based validation function that checks field presence in a result file against the spec. For now, the roadmap's Issue 3.4 (Aider validation) explicitly includes an "interface health check" that catches this drift.

3. **The YAML example block could be mistaken for a schema.** Mitigation: label it clearly as "Example" (not "Schema" or "Definition") and include a note that the field table below is the normative reference.

### Additional Agents Needed

None. The current team (api-design-minion for field semantics, devx-minion for format, ai-modeling-minion for orchestrator consumption needs, ux-strategy-minion for naming clarity, software-docs-minion for documentation approach) covers all aspects of this issue. The format decision does not require infrastructure, security, or testing expertise.
