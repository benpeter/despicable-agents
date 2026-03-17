## Milestone 1: Adapter Foundation

**Goal**: Translate an AGENT.md file to a tool-native instruction file (AGENTS.md or CONVENTIONS.md), stripping frontmatter and Claude Code-specific content.

## Scope

- Strip YAML frontmatter entirely; pass frontmatter fields as adapter runtime config (not written to instruction file)
- Strip Claude Code-specific task instructions (TaskUpdate, SendMessage, scratch directory conventions) from the Markdown body
- Write tool-native file: AGENTS.md format for Codex CLI; CONVENTIONS.md format for Aider
- Translator is invoked per delegation call; output is a temporary file cleaned up after the harness exits

## Dependencies

- Depends on #138 (Adapter Interface Definition) — translator produces instruction files consumed by adapters

## Acceptance Criteria

- Output file contains no YAML frontmatter
- Output file contains no TaskUpdate, SendMessage, or scratch file references
- Output is valid Markdown readable by the target tool

---
*From External Harness Roadmap §1.3*
