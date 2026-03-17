## Domain Plan Contribution: software-docs-minion

### Recommendations

**The type definition document should be self-documenting. No separate adapter authoring guide.**

Here is my reasoning:

1. **The codebase is Markdown and shell scripts.** There are no TypeScript interfaces, no JSON Schema files, no formal type system. "Types" in this context means a Markdown document that describes the contract. The document *is* the documentation -- there is no separate artifact to document.

2. **YAGNI applies directly.** The roadmap explicitly states: "Build only the Codex adapter concretely in Milestone 2. Extract the shared adapter interface after Aider (Milestone 3) validates the abstraction." With only two adapters in scope and no third-party adapter authors, a separate "adapter authoring guide" is premature. The audience is the project contributors building the Codex and Aider adapters, not external plugin authors.

3. **Self-documenting format means inline field documentation.** Each field in `DelegationRequest` and `DelegationResult` should have its semantics, optionality, constraints, and an example value documented directly alongside the field definition. This is the pattern used throughout the project -- see `docs/agent-anatomy.md` which documents the frontmatter schema as a YAML block followed by a field-purpose table. The type definitions should follow the same pattern.

4. **A concrete example per type completes the documentation.** After the field table, include one complete example for each type showing a realistic Codex delegation. This serves as both a specification test and an implementation reference. Adapter authors (the project's own contributors) can pattern-match from the example rather than interpreting abstract field descriptions.

5. **The document should live in `docs/` and link from `docs/architecture.md`.** It is an architecture sub-document, like `agent-anatomy.md` or `external-harness-integration.md`. The architecture hub already has a "Contributor / Architecture" table where it belongs.

**Recommended document structure:**

```
docs/adapter-interface.md
├── Back-link to architecture.md + external-harness-roadmap.md
├── Purpose (1-2 sentences: what these types are and who implements them)
├── DelegationRequest
│   ├── Field table (name, type hint, required/optional, description)
│   ├── Semantics notes (anything not obvious from the table)
│   └── Complete example (YAML or fenced code block)
├── DelegationResult
│   ├── Field table
│   ├── Semantics notes (success vs failure, what "exit_code" means)
│   └── Complete example (success case + failure case)
├── Adapter Contract (behavioral expectations)
│   ├── Lifecycle: what an adapter must do (translate, invoke, collect, clean up)
│   ├── Error handling: what adapters must guarantee (cleanup on failure, exit code propagation)
│   └── What adapters must NOT do (modify planning, change prompts beyond tool-specific translation)
└── Link to routing config (cross-reference to Issue 1.2 once it exists)
```

**On format choice:** The types should be documented using YAML-like pseudo-definitions inside fenced code blocks, not as prose. This matches the project convention (AGENT.md frontmatter is YAML; routing config examples in the feasibility study are YAML). It also avoids introducing a type system dependency (TypeScript, JSON Schema) that does not exist in the codebase.

**Do not use JSON Schema.** The roadmap's "What NOT to Build" section explicitly excludes "JSON Schema output" from Issue 1.2. Defining types in JSON Schema would create a format mismatch with the rest of the project and imply a machine-validation infrastructure that is not being built.

### Proposed Tasks

**Task 1: Write `docs/adapter-interface.md`**

- **What**: Create the type definition document following the structure above. Define `DelegationRequest` and `DelegationResult` with field tables, semantic notes, and complete examples. Include the adapter behavioral contract (lifecycle, error handling, boundaries).
- **Deliverable**: `docs/adapter-interface.md` -- single self-documenting file.
- **Dependencies**: None. This is Issue 1.1. But the author should reference the field lists in the roadmap (Issue 1.1 scope) and the gap analysis in `docs/external-harness-integration.md` to ensure all interface points are covered.
- **Acceptance check**: Every field listed in Issue 1.1's scope section (`agent name`, `task prompt`, `instruction file path`, `working directory`, `model tier`, `required tools list`, `exit code`, `changed files`, `stdout summary`, `stderr`, `raw diff reference`) appears in the document with type hint, optionality, and description.

**Task 2: Add entry to `docs/architecture.md` hub**

- **What**: Add a row to the "Contributor / Architecture" table in `docs/architecture.md` linking to the new document.
- **Deliverable**: One-line edit to `docs/architecture.md`.
- **Dependencies**: Task 1.
- **Format**: `| [Adapter Interface](adapter-interface.md) | DelegationRequest/DelegationResult type definitions, adapter behavioral contract |`

**Task 3: Cross-reference from roadmap**

- **What**: In `docs/external-harness-roadmap.md`, Issue 1.1 section, add a note that the type definitions live in `docs/adapter-interface.md`. This prevents the roadmap from becoming stale as the source of truth for field definitions.
- **Deliverable**: One-line addition to Issue 1.1 in the roadmap.
- **Dependencies**: Task 1.

### Risks and Concerns

1. **Over-specification risk.** The document might define types too precisely before two implementations validate them. Mitigation: keep the document explicitly minimal, note that it covers "Codex and Aider use cases, nothing more" (echoing Issue 1.1's acceptance criteria), and include a "this interface may change after Milestone 3 validation" note. Do not add fields speculatively.

2. **Format precedent risk.** Choosing YAML pseudo-definitions sets a convention for how types are expressed in this Markdown-and-shell codebase. If later milestones introduce actual code (shell functions, a Python script), the Markdown types may drift from implementation. Mitigation: keep the Markdown document as the single source of truth and note that implementations must match it. If code is introduced later, the Markdown definitions should be updated alongside -- same as how `agent-anatomy.md` documents the frontmatter schema that `install.sh` processes.

3. **Missing behavioral contract.** The roadmap Issue 1.1 says "types and contracts only" but its scope section lists only data fields. The behavioral expectations (cleanup on failure, what adapters must not modify, error propagation rules) are implicit in Issues 2.1 and 3.2 but not captured in the type definition scope. These should be part of the type definition document because they are part of the contract, not just the Codex or Aider implementation. The author should extract these from the acceptance criteria of Issues 2.1, 2.2, 3.2, and 3.3.

4. **Example data realism.** Examples should use realistic agent names, prompts, and file paths from the actual despicable-agents project, not placeholder data. This makes the examples directly useful for implementation. Risk is that examples become stale if agent names change -- acceptable since agent names are stable.

### Additional Agents Needed

None. The type definition document is a documentation task informed by the existing roadmap and feasibility study. The content has already been designed by whatever planning produced the roadmap -- this task is capturing it in a self-documenting reference format. No additional specialist input is needed beyond what is already in the planning context.
