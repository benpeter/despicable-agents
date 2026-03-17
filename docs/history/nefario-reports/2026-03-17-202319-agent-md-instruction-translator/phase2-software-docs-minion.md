# Phase 2 Contribution: software-docs-minion

## Planning Question

> Does this translator need its own spec document (like docs/routing-config.md for #139), or is the adapter-interface.md coverage sufficient?

## Domain Plan Contribution: software-docs-minion

### Recommendations

**No separate spec document is needed. Extend the existing docs instead.**

The translator (#140) is different in kind from #138 and #139. Those two define shared contracts that multiple future issues implement against -- the adapter interface is consumed by every adapter, and the routing config is consumed by the orchestrator and the config loader. They earned their own spec documents because they are long-lived reference surfaces with field tables, resolution semantics, validation rules, and behavioral contracts.

The translator is a transformation function with a narrow contract: AGENT.md in, tool-native Markdown out, frontmatter stripped, Claude Code-specific instructions stripped. Its "spec" is effectively:

1. **What to strip**: Already documented in the roadmap acceptance criteria (frontmatter, TaskUpdate, SendMessage, scratch directory conventions).
2. **What formats to produce**: Already documented in the feasibility study's Instruction Format Translation table (`external-harness-integration.md`, lines 96-118).
3. **Where it fits in the delegation flow**: Already documented in `adapter-interface.md` via the `translated_instruction_path` field description (line 63).

A standalone `docs/instruction-translator.md` would duplicate content from these three locations and introduce a fourth place to keep in sync. That violates the single-source-of-truth principle.

**What IS missing**: The stripping rules -- the specific patterns that identify Claude Code-specific content in the Markdown body. The roadmap says "strip TaskUpdate, SendMessage, scratch directory conventions" but does not enumerate the exact patterns. This is implementation-level detail that belongs in code comments or a brief section in an existing doc, not a new document.

### Proposed Tasks

1. **Add a "Translator Rules" section to `adapter-interface.md`** (5-10 lines). This section sits after the `translated_instruction_path` field description and before the Behavioral Contract. It documents:
   - Frontmatter stripping: remove everything between `---` delimiters
   - Claude Code instruction stripping: the specific patterns/keywords removed from the Markdown body (TaskUpdate, SendMessage, scratch file path references, nefario-specific phase instructions)
   - Output format selection: AGENTS.md for Codex, CONVENTIONS.md for Aider (keyed on harness name from routing config)
   - No content rewriting beyond stripping -- the Markdown body passes through otherwise unchanged

2. **Add a `**Specification**:` link to the #140 roadmap entry** pointing to the new section in adapter-interface.md, using an anchor link (e.g., `[Translator Rules](adapter-interface.md#translator-rules)`). This matches the pattern used by #138 and #139.

3. **Add a row to the architecture.md Sub-Documents table** -- not needed; adapter-interface.md is already listed there, and the translator rules are a section within it, not a new document.

### Risks and Concerns

- **Stripping rules will evolve during implementation.** The exact set of Claude Code-specific patterns to strip is not fully enumerable until someone inspects real AGENT.md files. The doc section should be written as a minimal pattern list with a "this list may grow during Codex (#141) and Aider (#143) validation" stability note. Do not try to be exhaustive upfront.

- **CONVENTIONS.md format differences may be deeper than "append content."** The feasibility study's translation table shows all five AGENT.md sections mapping to "Appended content" for Aider's CONVENTIONS.md, which implies a simple concatenation. If Aider's CONVENTIONS.md has structural requirements (headers, ordering) beyond plain Markdown, this will need to be documented during Milestone 3, not now. Flag it as a known gap.

- **No risk of doc sprawl.** By placing translator rules inside adapter-interface.md, the documentation footprint stays at the current 4 external-harness docs (feasibility study, roadmap, adapter interface, routing config) rather than growing to 5. This is the right count for Milestone 1.

### Additional Agents Needed

None for the documentation aspect. The implementation work for #140 itself needs the agents identified in the broader planning, but documentation updates to adapter-interface.md and the roadmap are within software-docs-minion's scope or can be handled by whoever implements #140 (the doc changes are small enough to be part of the implementation PR).
