# Meta-Plan: AGENT.md Instruction Translator (#140)

## Task Summary

Build a shell script (`lib/translate-agent-md.sh`) that translates an AGENT.md file into a tool-native instruction file (AGENTS.md for Codex CLI, CONVENTIONS.md for Aider). The translator strips YAML frontmatter entirely, strips Claude Code-specific content (TaskUpdate, SendMessage, scratch directory conventions) from the Markdown body, and writes clean Markdown readable by the target tool. It is invoked per delegation call; output is a temporary file with restricted permissions (0600) cleaned up by the calling adapter.

This is a focused shell scripting task with well-defined inputs (AGENT.md files with known structure) and outputs (tool-native Markdown). The feasibility study and adapter interface spec already define the translation mapping.

---

## Planning Consultations

### Consultation 1: Shell Implementation Design

- **Agent**: devx-minion
- **Planning question**: Given the existing `lib/load-routing-config.sh` patterns (bash 3.2 compat, `set -euo pipefail`, structured error messages, `yq`/`jq` dependency checks), what should the CLI interface for `lib/translate-agent-md.sh` look like? Specifically: (a) argument parsing pattern (positional vs flags for AGENT.md path, target format, output path), (b) should frontmatter extraction reuse the awk-based approach from load-routing-config.sh or use yq for richer parsing, (c) how should the Claude Code-specific content stripping work (regex-based sed/awk, or section-aware Markdown parsing), and (d) what exit code conventions should it follow? Consider that this runs per-delegation-call (latency matters) and must work with the 27 existing AGENT.md files as test corpus.
- **Context to provide**: `lib/load-routing-config.sh` (implementation patterns, dependency handling), representative AGENT.md files (gru, software-docs-minion, test-minion, nefario), the instruction format translation table from docs/external-harness-integration.md lines 98-118, adapter-interface.md `translated_instruction_path` field semantics.
- **Why this agent**: devx-minion owns CLI design, argument conventions, error message quality, and developer ergonomics. The translator is a developer-facing CLI tool that must integrate cleanly with the existing lib/ pattern.

### Consultation 2: Security Surface of Instruction Translation

- **Agent**: security-minion
- **Planning question**: The translator reads AGENT.md (trusted, repo-controlled) and writes a temporary instruction file consumed by an external tool (Codex, Aider). What security concerns exist in this translation pipeline? Specifically: (a) the adapter-interface.md requires temp files with 0600 permissions in a session-scoped directory -- should the translator create the temp file or should the caller pass an output path? (b) Could a maliciously crafted AGENT.md inject instructions into the target tool via the translation output? (c) The stripping of Claude Code content uses pattern matching -- what happens if patterns partially match and leave fragments that change meaning? (d) Should the output be validated (e.g., no leftover frontmatter delimiters)?
- **Context to provide**: adapter-interface.md behavioral contract (temp file security, 0600 permissions, session-scoped directory), the stripping targets (TaskUpdate, SendMessage, scratch directory references), the fact that AGENT.md files are version-controlled in the same repo.
- **Why this agent**: security-minion evaluates attack surface and input sanitization. Even though AGENT.md is trusted today, the translator creates files consumed by third-party tools, and the stripping logic must not create instruction injection vectors.

### Consultation 3: Target Format Fidelity

- **Agent**: ai-modeling-minion
- **Planning question**: The translator converts AGENT.md system prompts to AGENTS.md (Codex) and CONVENTIONS.md (Aider) formats. The feasibility study says the five-section template translates cleanly, but: (a) AGENTS.md is described as "top-level heading + description" for Identity and "Markdown sections" for everything else -- is there any structural transformation needed beyond stripping frontmatter, or is the Markdown body passed through verbatim? (b) CONVENTIONS.md uses a "preamble section" for Identity -- does this require restructuring the content or just preserving the existing heading hierarchy? (c) The only AGENT.md that contains TaskUpdate/SendMessage references is nefario/AGENT.md -- should the translator handle patterns that don't currently exist in other agents (defensive stripping) or only strip what actually appears? (d) Are there any prompt engineering concerns about how instructions behave differently when consumed by non-Claude models (Codex uses OpenAI models)?
- **Context to provide**: The instruction format translation table, representative AGENT.md files, the AGENTS.md spec context from the feasibility study (AAIF/Linux Foundation), the fact that Codex will use o3/o4-mini models while Aider may use Claude models.
- **Why this agent**: ai-modeling-minion understands prompt engineering across model families and multi-agent instruction formats. The translation must preserve instruction fidelity when consumed by different models.

### Consultation 4: Test Strategy

- **Agent**: test-minion
- **Planning question**: The existing test pattern is `tests/test-routing-config.sh` -- a bash integration test with fixtures under `tests/fixtures/routing/`. For the translator: (a) should tests follow the same pattern (bash test script with fixtures)? (b) What fixtures are needed? The 27 real AGENT.md files serve as a natural test corpus -- should tests run against actual agent files or synthetic fixtures? (c) What assertions matter: no frontmatter in output, no Claude Code references, valid Markdown structure, correct output format per target? (d) Should there be a golden-file test pattern (expected output for a known input) to catch regressions? (e) How should the two output formats (AGENTS.md vs CONVENTIONS.md) be tested -- separate fixtures or parametric?
- **Context to provide**: `tests/test-routing-config.sh` (test pattern, assertion style, fixture organization), the 27 AGENT.md file list, acceptance criteria from the issue.
- **Why this agent**: test-minion designs test strategies and ensures the test approach matches the existing project patterns.

---

## Cross-Cutting Checklist

- **Testing**: Include test-minion for planning (Consultation 4 above). The translator produces executable shell code that needs integration tests following the existing `tests/test-routing-config.sh` pattern.
- **Security**: Include security-minion for planning (Consultation 2 above). The translator creates temp files consumed by external tools and processes content that becomes system-level instructions.
- **Usability -- Strategy**: ALWAYS include. Planning question for ux-strategy-minion: The translator is an internal component invoked programmatically by adapters, not directly by end users. The "user" is the adapter code. Given this, is there a UX strategy concern here, or can this be scoped as a pure internal API with no end-user journey impact? (Include as lightweight review rather than full consultation -- if ux-strategy-minion confirms no user journey impact, no execution task is needed.)
- **Usability -- Design**: Exclude. No user-facing interface; the translator is a shell script called by adapter code.
- **Documentation**: Include software-docs-minion as lightweight consultation. Planning question: Does the translator need its own documentation beyond inline comments and the existing adapter-interface.md reference to `translated_instruction_path`? The roadmap issue and adapter interface spec already describe what it does. Consider whether `docs/` needs an update or if the script's own header comment suffices.
- **Observability**: Exclude. The translator is a single-shot synchronous script (not a service). Error handling via exit codes and stderr is sufficient. No runtime metrics, logging, or tracing needed.

---

## Notable Exclusions

- **edge-minion**: CDN and edge compute are unrelated; this is a local file transformation script.
- **api-spec-minion**: No API surface is being created; the translator is a shell function, not a service endpoint.
- **frontend-minion**: No UI component; purely backend shell tooling.

---

## Anticipated Approval Gates

1. **CLI Interface Design** (from devx-minion consultation): The argument pattern, dependency choices, and error convention will constrain all downstream implementation. This is a MUST gate because the adapter code (#141, #143) will invoke this interface -- getting it wrong means rework across multiple issues. However, it is low blast radius (only the translator itself and its direct callers) and easy to reverse (it's a shell script interface, not a data schema). Classify as **OPTIONAL** -- gate only if the devx-minion consultation surfaces multiple viable approaches with meaningful trade-offs.

2. **Stripping Pattern Design** (from ai-modeling-minion + security-minion): Whether to strip defensively (patterns that could theoretically appear) vs. conservatively (only patterns that exist today) affects correctness and maintenance. Low blast radius, easy to reverse. **No gate** -- default to defensive stripping per security-minion input.

**Expected gate count: 0-1** (well under budget).

---

## Rationale

This task is a focused implementation with well-defined scope from the roadmap, adapter interface spec, and feasibility study. The four primary consultations cover the axes that matter:

- **devx-minion**: How the tool is built and invoked (CLI design, integration with existing patterns)
- **security-minion**: Whether the translation pipeline creates vulnerabilities
- **ai-modeling-minion**: Whether the output preserves instruction fidelity across model families
- **test-minion**: How to verify correctness

The task does not need infrastructure, database, API design, frontend, or observability specialists. It is a single shell script that transforms Markdown files.

---

## Scope

**In scope**:
- Shell script `lib/translate-agent-md.sh` implementing AGENT.md to AGENTS.md and CONVENTIONS.md translation
- Frontmatter stripping (all YAML frontmatter removed from output; frontmatter fields available to caller)
- Claude Code content stripping (TaskUpdate, SendMessage, scratch directory references removed from Markdown body)
- Output as temporary file with appropriate permissions
- Integration tests following existing `tests/test-routing-config.sh` pattern
- Works with all 27 existing AGENT.md files

**Out of scope**:
- Adapter invocation logic (that's #141 and #143)
- Routing config changes (already done in #139)
- Changes to AGENT.md format itself
- .cursorrules, GEMINI.md, or other format targets beyond AGENTS.md and CONVENTIONS.md
- Task prompt stripping (the adapter-interface.md states task_prompt is already stripped before the adapter is called; the translator handles AGENT.md body, not task prompts)

---

## External Skill Integration

No external skills detected in project that are relevant to this task. `despicable-lab` (agent rebuild) and `despicable-statusline` (status display) do not apply to shell script implementation.
