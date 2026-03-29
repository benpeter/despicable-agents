## Delegation Plan

**Team name**: agent-md-translator
**Description**: Implement `lib/translate-agent-md.sh` -- a shell script that translates AGENT.md files to tool-native instruction files (AGENTS.md for Codex, CONVENTIONS.md for Aider), stripping YAML frontmatter and Claude Code-specific content. Includes tests, sed pattern file, and a docs update to adapter-interface.md.

### Task 1: Create `lib/translate-agent-md.sh` and `lib/claude-code-patterns.sed`
- **Agent**: devx-minion
- **Delegation type**: standard
- **Model**: sonnet
- **Mode**: bypassPermissions
- **Blocked by**: none
- **Approval gate**: no
- **Prompt**: |
    ## Task: Implement the AGENT.md Instruction Translator

    Create two files:
    1. `lib/translate-agent-md.sh` -- Main translator script
    2. `lib/claude-code-patterns.sed` -- Curated sed pattern file for Claude Code content stripping

    ### Working Directory
    `/Users/ben/github/benpeter/despicable-agents/.claude/worktrees/external-harness`

    ### Context
    This is Issue #140 of the external harness integration roadmap. The translator converts AGENT.md files (which have YAML frontmatter and Claude Code-specific content) into tool-native instruction files that Codex CLI (AGENTS.md) and Aider (CONVENTIONS.md) can consume. It is called by the adapter layer during delegation -- the adapter provides the output path and the translator writes to it.

    The existing codebase has `lib/load-routing-config.sh` as the reference for CLI conventions, error handling, and awk patterns. Follow its patterns exactly.

    ### CLI Interface

    ```
    lib/translate-agent-md.sh [OPTIONS]

    Required:
      --agent-md PATH         Path to the source AGENT.md file
      --format FORMAT         Target format: "agents-md" or "conventions-md"
      --output PATH           Output file path (caller-provided, typically in a session temp dir)

    Exit codes:
      0  Success -- translated file written, frontmatter JSON on stdout
      1  Validation/processing error (file not found, malformed frontmatter, write failure)
      2  Usage error (missing required flags, unknown flags, invalid --format)
    ```

    ### Stdout: Frontmatter JSON

    On success, emit a single JSON object to stdout containing extracted frontmatter fields. Construct with printf -- no jq dependency.

    ```json
    {"name": "gru", "model": "opus", "tools": "Read, Glob, Grep, WebSearch, WebFetch, Write, Edit"}
    ```

    Fields to extract: `name`, `model`, `tools`, `description` (flattened to single line if multi-line `>` folded scalar). If a field is missing from frontmatter, omit it from JSON (do not emit null).

    ### Frontmatter Stripping (awk)

    Use awk to strip the YAML frontmatter block. The frontmatter is the first `---`-delimited block at the start of the file (line 1 must be `---`, content until the next standalone `---`). This is a structural parse, not a global regex.

    **Critical**: AGENT.md files use `---` as Markdown horizontal rules in the body. The awk state machine must only match the opening/closing frontmatter delimiters, not body rules. Pattern:

    ```bash
    awk '/^---$/{if(in_front){in_front=0;next}else{in_front=1;next}} !in_front{print}'
    ```

    **Validation**: If the file starts with `---` but no closing `---` is found, fail with exit 1 and an actionable error message. Fail-closed, not fail-open.

    **Frontmatter extraction**: Use separate awk passes to extract individual fields (name, model, tools, description). For `description:` with `>` folded scalar, collect continuation lines (lines starting with whitespace after the `description:` line) until a non-indented line. Flatten to single line for JSON output. Reference: `load-routing-config.sh` lines 292-311 for the existing awk frontmatter pattern.

    ### Claude Code Content Stripping (hybrid: awk section-skip + sed patterns)

    Two-stage pipeline:

    **Stage 1: awk section-level removal.** Remove entire sections that are exclusively Claude Code content:
    - `## Main Agent Mode` -- skip from this heading until the next `## ` heading or end of file

    ```bash
    awk '/^## Main Agent Mode/{skip=1;next} /^## /{skip=0} !skip{print}'
    ```

    **Stage 2: sed pattern substitutions.** Apply `lib/claude-code-patterns.sed` for inline content stripping. The sed file must contain:

    **Tool primitive tokens** (PascalCase, unambiguous):
    - `TaskUpdate`, `TaskList`, `TaskCreate`, `SendMessage`, `TeamCreate`, `TeamUpdate`, `AskUserQuestion`
    - Strip these when they appear in parenthetical references like `(TaskUpdate)`, inline mentions, and comma-separated lists

    **Phrase removals**:
    - `via the Task tool`
    - `via the /nefario skill`
    - Patterns matching `running as main agent via \`claude --agent ...\``
    - `(not a spawned subagent)` and similar subagent references
    - `scratch directory conventions`

    **Scratch directory references**:
    - `nefario-scratch-[A-Za-z0-9]*` patterns

    **Build system markers**:
    - All `<!-- @domain:...-->` HTML comments (both BEGIN and END markers)
    - Pattern: `<!-- @domain:[a-z-]+ (BEGIN|END) -->`

    **Context cleanup** (run after pattern stripping):
    - Empty parentheses: `( )` or `()`
    - Dangling commas in lists: `, ,` -> `,`; leading/trailing commas
    - Double/triple spaces -> single space
    - Lines that become empty or whitespace-only after stripping (leave blank lines; do not collapse document structure)

    ### Output Format Differences

    Both formats produce clean Markdown. The differences are minimal:

    - **agents-md**: Clean Markdown body. No additions beyond the stripped AGENT.md body.
    - **conventions-md**: Same clean Markdown body, with a provenance comment prepended: `<!-- Translated from: {relative_path_of_source} -->`

    Do NOT add any additional instructions, headers, or content beyond what is in the original AGENT.md body. The translator strips content; it never adds content.

    ### File Permissions

    Create the output file with `umask 077` set before writing, so it is created with mode 0600. Do NOT create the file first then chmod -- avoid the TOCTOU race.

    ### Idempotency

    Running the translator twice with identical inputs must produce identical output. No timestamps, no random content.

    ### Error Messages

    Follow the three-part pattern from `load-routing-config.sh`:
    1. What went wrong
    2. Where (file path, argument)
    3. How to fix

    Example:
    ```
    Error: Source AGENT.md file not found

      path: /path/to/missing/AGENT.md

    Check the --agent-md path and try again.
    ```

    ### Post-Translation Validation

    Before writing the final output, validate:
    1. **No residual frontmatter**: output must not start with `---` in the first 3 lines
    2. **Non-empty output**: if stripping produced an empty file, fail with exit 1
    3. **Size sanity**: if output is less than 10% of input size, emit a warning to stderr (do not hard-fail)
    4. **No null bytes**: reject binary content

    ### Dependencies

    Zero external dependencies beyond POSIX tools (bash, awk, sed, cat, printf). No yq, no jq.

    ### Files to Create

    1. **`lib/translate-agent-md.sh`** -- Main script (~200-300 lines). Make executable.
    2. **`lib/claude-code-patterns.sed`** -- Sed pattern file. Each pattern must have a comment explaining why it exists.

    ### Files to Read (for context)
    - `lib/load-routing-config.sh` -- reference for CLI conventions, awk patterns, error messages
    - `nefario/AGENT.md` -- the most complex agent, contains all stripping targets (Main Agent Mode section, @domain markers, TaskUpdate/SendMessage references)
    - `gru/AGENT.md` -- simple agent, for sanity-checking that stripping does not remove valuable content
    - `docs/adapter-interface.md` -- the interface this translator implements (see `translated_instruction_path`)

    ### What NOT to Do
    - Do not use yq or jq
    - Do not create temp files inside the translator -- the caller provides the output path
    - Do not add content to the output beyond what is in the AGENT.md body (no preamble injection, no model-specific rewrites)
    - Do not hard-code agent names for special-casing -- use generic patterns
    - Do not strip the word "scratch" in isolation -- only `nefario-scratch` and `scratch directory` patterns
    - Do not strip `CLAUDE.md` mentions -- those are domain knowledge in agents like lucy, not Claude Code platform references
    - Do not strip `Task` as a bare word -- it is a common English word. Only strip `Task tool` as a phrase and PascalCase tool names like `TaskUpdate`
- **Deliverables**: `lib/translate-agent-md.sh`, `lib/claude-code-patterns.sed`
- **Success criteria**: Script runs against `nefario/AGENT.md` and `gru/AGENT.md` producing valid output with no frontmatter, no `TaskUpdate`/`SendMessage`/`TeamCreate` references, no `@domain:` markers, and no `## Main Agent Mode` section. Frontmatter JSON emitted to stdout. Exit code 0. Output file has 0600 permissions.

### Task 2: Create test fixtures and test script
- **Agent**: test-minion
- **Delegation type**: standard
- **Model**: sonnet
- **Mode**: bypassPermissions
- **Blocked by**: Task 1
- **Approval gate**: no
- **Prompt**: |
    ## Task: Create tests for the AGENT.md Instruction Translator

    Create test fixtures and a test script for `lib/translate-agent-md.sh` following the exact conventions established by `tests/test-routing-config.sh`.

    ### Working Directory
    `/Users/ben/github/benpeter/despicable-agents/.claude/worktrees/external-harness`

    ### Context
    The translator (`lib/translate-agent-md.sh`) converts AGENT.md files to tool-native instruction files (AGENTS.md for Codex, CONVENTIONS.md for Aider). It:
    - Strips YAML frontmatter and emits frontmatter fields as JSON to stdout
    - Strips Claude Code-specific content (via awk section removal + sed patterns from `lib/claude-code-patterns.sed`)
    - Writes the translated Markdown to a caller-provided `--output` path
    - Accepts `--agent-md PATH --format agents-md|conventions-md --output PATH`
    - Exit codes: 0 = success, 1 = validation error, 2 = usage error

    ### Files to Read First
    - `tests/test-routing-config.sh` -- the reference test script. Follow its structure exactly: `set -euo pipefail`, `pass()`/`fail()` helpers, `run_loader` wrapper pattern, temp dir lifecycle via `trap cleanup EXIT`, summary counters.
    - `lib/translate-agent-md.sh` -- the implementation you are testing
    - `lib/claude-code-patterns.sed` -- the stripping patterns
    - `nefario/AGENT.md` -- the most complex real AGENT.md (contains all stripping targets)
    - `lucy/AGENT.md` -- contains extensive `CLAUDE.md` mentions that must NOT be stripped (they are domain knowledge)

    ### Files to Create

    #### 1. Test Fixtures (`tests/fixtures/translator/`)

    **Synthetic fixtures:**

    `minimal.md` -- A clean, minimal AGENT.md with standard frontmatter and all five sections (Identity, Core Knowledge, Working Patterns, Output Standards, Boundaries). ~30 lines. No Claude Code-specific content. This is the happy-path canary.

    ```
    ---
    name: test-agent
    description: >
      A minimal test agent for translator validation.
    tools: Read, Write, Edit
    model: sonnet
    ---

    # Identity

    You are test-agent, a minimal specialist.

    ## Core Knowledge

    Test domain knowledge here.

    ## Working Patterns

    Test working patterns here.

    ## Output Standards

    Test output standards here.

    ## Boundaries

    ### What You Do
    - Test tasks

    ### What You Do NOT Do
    - Production tasks
    ```

    `with-claude-refs.md` -- An AGENT.md containing Claude Code-specific content that must be stripped. Include:
    - Parenthetical tool refs: `(TaskUpdate)`, `(SendMessage)`
    - Inline tool names: `TaskUpdate`, `TeamCreate`, `TaskList`
    - A sentence like: `assign tasks (TaskUpdate), coordinate via messages (SendMessage), and synthesize results.`
    - A `## Main Agent Mode` section (3-4 lines, should be entirely removed)
    - `<!-- @domain:test-section BEGIN -->` and `<!-- @domain:test-section END -->` markers
    - A `nefario-scratch-abc123` reference
    - A `scratch directory conventions` phrase
    - A `via the Task tool` phrase
    - Also include legitimate content that must NOT be stripped: `CLAUDE.md` mentions, the word "scratch" in "building from scratch", the word "Task" standalone

    `frontmatter-only.md` -- Just YAML frontmatter, empty body. Edge case (should fail: empty output after stripping).

    `no-frontmatter.md` -- Markdown body with no YAML frontmatter at all. Edge case (should handle gracefully -- either pass through body or error cleanly, depending on implementation).

    `multiline-description.md` -- Frontmatter using `>` folded scalar for description (common in real agents). Verify correct extraction.

    **Golden files:**

    `golden-minimal.agents-md.md` -- Expected AGENTS.md output from `minimal.md` (the body without frontmatter).

    `golden-minimal.conventions-md.md` -- Expected CONVENTIONS.md output from `minimal.md` (same body, with `<!-- Translated from: ... -->` comment prepended).

    `golden-with-claude-refs.agents-md.md` -- Expected AGENTS.md output from `with-claude-refs.md` (stripped of all Claude Code content, but preserving legitimate content).

    #### 2. Test Script (`tests/test-translator.sh`)

    Structure mirrors `test-routing-config.sh` exactly:

    **Setup block:**
    ```bash
    SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
    REPO_ROOT="$(cd "$SCRIPT_DIR/.." && pwd)"
    TRANSLATOR="$REPO_ROOT/lib/translate-agent-md.sh"
    FIXTURES="$SCRIPT_DIR/fixtures/translator"
    REAL_AGENT_DIR="$REPO_ROOT"
    ```

    **Runner helper** (`run_translator`):
    - Captures stdout (frontmatter JSON) into `$OUT`
    - Captures stderr into `$ERR`
    - Captures exit code into `$RC`
    - Reads the output file content into `$TRANSLATED` (if the output file exists)

    **Test groups (~25 assertions organized in ~8 groups):**

    1. **Happy-path tests** (~4 tests):
       - Translate `minimal.md` to agents-md format: exits 0, output non-empty, no `---` at start, at least one `#` heading
       - Translate `minimal.md` to conventions-md format: same checks + verify provenance comment present
       - Parametric loop for both formats on shared assertions

    2. **Frontmatter stripping tests** (~3 tests):
       - Output from `minimal.md` does not contain `---` as frontmatter delimiter
       - Output does not contain `name:`, `model:`, `tools:` YAML fields
       - Body content (section headings, prose) is preserved

    3. **Frontmatter JSON extraction tests** (~3 tests):
       - stdout JSON from `minimal.md` contains `"name": "test-agent"`
       - stdout JSON contains `"model": "sonnet"`
       - stdout JSON contains `"tools": "Read, Write, Edit"`
       - `multiline-description.md` frontmatter extracts description as single line

    4. **Claude Code stripping tests** (~6 tests):
       - Output from `with-claude-refs.md` does NOT contain: `TaskUpdate`, `SendMessage`, `TeamCreate`, `TaskList`, `nefario-scratch`, `scratch directory conventions`, `<!-- @domain:`, `## Main Agent Mode`
       - Output from `with-claude-refs.md` DOES contain: `CLAUDE.md`, `building from scratch`, standalone `Task` references that are NOT `TaskUpdate`/`TaskList`/`TaskCreate`/etc.

    5. **Golden-file regression tests** (~3 tests):
       - `diff -u golden-minimal.agents-md.md actual` -- fail with diff on mismatch
       - `diff -u golden-minimal.conventions-md.md actual`
       - `diff -u golden-with-claude-refs.agents-md.md actual`

    6. **Edge-case tests** (~3 tests):
       - `frontmatter-only.md` -- should fail (empty output after stripping)
       - `no-frontmatter.md` -- defined behavior (pass through or error with message)
       - File permissions: output file has mode 0600

    7. **Error/usage tests** (~3 tests):
       - Non-existent input file: exits 1, stderr contains "not found"
       - Missing required arguments: exits 2, stderr shows usage info
       - Invalid --format value: exits 2, stderr names valid formats

    8. **Corpus smoke test** (~1 test, 27 iterations):
       - Loop over all `*/AGENT.md` files under `$REAL_AGENT_DIR`
       - For each: translate to agents-md and conventions-md
       - Assert: exits 0, output non-empty, output does not start with `---`, output contains at least one `#` heading
       - Assert: output does NOT contain `TaskUpdate`, `SendMessage`, `TeamCreate`, or `<!-- @domain:` patterns
       - This catches real-world edge cases synthetic fixtures miss

    **IMPORTANT**: When checking for Claude Code-specific patterns in the corpus test, use narrow patterns:
    - Grep for `TaskUpdate`, not `Task` (common English word)
    - Grep for `nefario-scratch`, not `scratch` (appears legitimately in security-minion "scratch for Go" and frontend-minion "building from scratch")
    - Grep for `SendMessage` (PascalCase), not "send message" or "sending a message"
    - Do NOT grep for `CLAUDE.md` -- it is legitimate domain knowledge in lucy and other governance agents

    **Summary block:**
    Print pass/fail counts, exit with failure count (matching test-routing-config.sh pattern).

    ### What NOT to Do
    - Do not add any test framework dependency (no bats, no shunit2) -- use the bare bash pattern from test-routing-config.sh
    - Do not create golden files for all 27 agents -- only for minimal and with-claude-refs fixtures
    - Do not auto-update golden files -- they must be manually regenerated
    - Do not grep for `Task` as a bare word in stripping assertions -- only PascalCase compound names
    - Do not grep for `scratch` as a bare word -- only `nefario-scratch` and `scratch directory`
- **Deliverables**: `tests/test-translator.sh`, `tests/fixtures/translator/` directory with ~10 fixture/golden files
- **Success criteria**: `bash tests/test-translator.sh` runs to completion, all tests pass (or fail with clear diagnostic when translator has an issue), no temp files left after run, test count ~25.

### Task 3: Update documentation
- **Agent**: software-docs-minion
- **Delegation type**: standard
- **Model**: sonnet
- **Mode**: bypassPermissions
- **Blocked by**: Task 1
- **Approval gate**: no
- **Prompt**: |
    ## Task: Add Translator Rules section to adapter-interface.md and update roadmap

    Make two small documentation updates to reflect the completed AGENT.md translator implementation.

    ### Working Directory
    `/Users/ben/github/benpeter/despicable-agents/.claude/worktrees/external-harness`

    ### Changes to Make

    #### 1. Add "Translator Rules" section to `docs/adapter-interface.md`

    Insert a new section after the "Adapter Behavioral Contract" section (before "Fields Considered and Excluded"). This section documents the translation rules that `lib/translate-agent-md.sh` implements. Keep it concise (10-15 lines).

    Content for the section:

    ```markdown
    ## Translator Rules

    The AGENT.md translator (`lib/translate-agent-md.sh`, Issue #140) converts agent instruction files to tool-native formats. The adapter receives the translated file path in `translated_instruction_path` and does not perform translation itself.

    **Frontmatter stripping**: The `---`-delimited YAML frontmatter block is removed entirely. Frontmatter fields (`name`, `model`, `tools`, `description`) are extracted and emitted as JSON to stdout for adapter runtime use.

    **Claude Code instruction stripping**: The following patterns are removed from the Markdown body:
    - Claude Code tool primitives: `TaskUpdate`, `TaskList`, `TaskCreate`, `SendMessage`, `TeamCreate`, `TeamUpdate`, `AskUserQuestion`
    - Claude Code invocation phrases: `via the Task tool`, `via the /nefario skill`, `claude --agent` references
    - Scratch directory references: `nefario-scratch-*` paths, `scratch directory conventions`
    - Build system markers: `<!-- @domain:... -->` HTML comments
    - Claude Code-specific sections: `## Main Agent Mode` (removed entirely)

    **Output format**: AGENTS.md for Codex (`--format agents-md`), CONVENTIONS.md for Aider (`--format conventions-md`). Both produce clean Markdown. The body content passes through unchanged beyond the stripping rules above.

    **Cross-model notes**: AGENT.md instructions use model-agnostic Markdown (headings, not XML tags). No per-model rewriting is performed. Large agent instruction files (500+ lines) consume significant context; route to models with large context windows via `model-mapping`. Complex multi-constraint agents may see reduced instruction adherence on smaller models; prefer higher-tier models via the routing config.

    This stripping rule set may grow during Codex (#141) and Aider (#143) validation.
    ```

    #### 2. Add specification link to `docs/external-harness-roadmap.md`

    In the `#140: AGENT.md Instruction Translator` section, add a **Specification** line after the acceptance criteria, matching the pattern used by #138 and #139:

    ```markdown
    **Specification**: [Translator Rules](adapter-interface.md#translator-rules)
    ```

    ### Files to Read
    - `docs/adapter-interface.md` -- to understand the existing structure and find the right insertion point
    - `docs/external-harness-roadmap.md` -- to find the #140 entry and add the spec link

    ### What NOT to Do
    - Do not create a new standalone document (the translator rules belong inside adapter-interface.md)
    - Do not modify any other sections of adapter-interface.md
    - Do not modify the acceptance criteria or scope of #140 in the roadmap
    - Do not add entries to architecture.md (adapter-interface.md is already listed there)
- **Deliverables**: Updated `docs/adapter-interface.md` (new Translator Rules section), updated `docs/external-harness-roadmap.md` (spec link added)
- **Success criteria**: The Translator Rules section exists in adapter-interface.md with correct content. The #140 roadmap entry has a Specification link. No other content was modified.

### Cross-Cutting Coverage
- **Testing**: Covered by Task 2 (test-minion creates comprehensive test suite with ~25 assertions, synthetic fixtures, golden files, and 27-file corpus smoke test)
- **Security**: Addressed in Task 1 prompt -- secure file creation with umask 077, no content injection, @domain marker stripping, fail-closed on malformed input, output validation. No standalone security task needed: the security concerns are defensive coding practices embedded in the implementation requirements, not a separate security surface.
- **Usability -- Strategy**: Addressed in Task 1 prompt -- fail-loud error messages with three-part structure (what/where/how-to-fix), structured JSON output on stdout for adapter consumption, stripping rules documented in a maintained sed file. No standalone UX task needed: this is internal infrastructure with two programmatic consumers.
- **Usability -- Design**: Not applicable. No user-facing interface.
- **Documentation**: Covered by Task 3 (software-docs-minion adds Translator Rules section to adapter-interface.md)
- **Observability**: Not applicable. This is a CLI tool invoked per-delegation, not a runtime service. Stderr diagnostics and exit codes provide sufficient observability.

### Architecture Review Agents
- **Mandatory** (5): security-minion, test-minion, ux-strategy-minion, lucy, margo
- **Discretionary picks**:
  - None selected. Rationale below.
- **Not selected**:
  - ux-design-minion: No user-facing UI components in this plan
  - accessibility-minion: No web-facing HTML/UI produced
  - sitespeed-minion: No web-facing runtime code produced
  - observability-minion: Single CLI tool, no coordinated runtime services
  - user-docs-minion: Internal infrastructure tool, no end-user documentation impact

### Decisions

- **Stripping granularity: hybrid section + token approach**
  Chosen: Section-level removal for entirely Claude Code sections (`## Main Agent Mode`), token-level sed with context cleanup for inline references in mixed content
  Over: Pure section-level removal (security-minion's initial emphasis) which would lose valuable content from sections containing both Claude Code and general content
  Why: ai-modeling-minion's analysis confirms only `## Main Agent Mode` is entirely Claude Code-specific. All other references are inline within valuable prose. Both devx-minion and security-minion converge on this hybrid when read carefully -- the disagreement was in emphasis, not approach.

- **No preamble injection for name/description**
  Chosen: Pass body through without adding frontmatter fields as visible Markdown
  Over: Prepending agent name and description from frontmatter as a Markdown heading (ai-modeling-minion's optional recommendation)
  Why: Identity section already provides this information in the body. Adding a preamble risks duplication. Deferred to Codex validation (#146) where the need can be validated empirically.

- **No cross-model instruction rewriting**
  Chosen: Output model-agnostic Markdown, identical for all target tools
  Over: Per-model instruction adaptation (e.g., removing reasoning prompts for o-series, adjusting tone for different model families)
  Why: ai-modeling-minion's analysis confirms AGENT.md files use model-agnostic Markdown (headings, not XML tags; directive tone, not reasoning-prompting). Instruction fidelity differences are model capability, not format. Routing config's `model-mapping` is the correct lever.

- **sed pattern file over inline regex**
  Chosen: Separate `lib/claude-code-patterns.sed` file with documented patterns
  Over: Inline sed expressions in the main script
  Why: Testable independently, maintainable (add a line when new patterns emerge), auditable (each pattern has a comment), consistent with devx-minion and ai-modeling-minion recommendations.

### Risks and Mitigations

| Risk | Severity | Mitigation |
|------|----------|------------|
| Token stripping leaves grammatically broken prose (e.g., "assign tasks ()" after removing "(TaskUpdate)") | Medium | Context cleanup patterns in sed file: empty parens, dangling commas, double spaces. Corpus smoke test catches regressions across all 27 agents. |
| `---` horizontal rules in body accidentally stripped as frontmatter | High | Structural awk parse: only strip first `---`-to-`---` block at file start. State machine tracks `in_front` flag. Validated by corpus test against all agents. |
| False positive stripping of "scratch" in legitimate content | Medium | Narrow patterns only: `nefario-scratch` and `scratch directory conventions`. Never bare `scratch`. Test specifically with security-minion AGENT.md ("scratch for Go") and fixture containing "building from scratch". |
| False positive stripping of `CLAUDE.md` mentions | Medium | `CLAUDE.md` is NOT stripped -- it is domain knowledge in governance agents. Test specifically with lucy/AGENT.md to verify preservation. |
| Sed pattern list goes stale as AGENT.md files evolve | Low | Corpus smoke test runs all 27 real agents through translator, asserting no residual Claude Code patterns. New patterns caught at test time. |
| Multi-line `description:` field in frontmatter parsed incorrectly | Low | Dedicated test case with `>` folded scalar. awk extraction collects continuation lines until non-indented line. |

### Execution Order

```
Batch 1 (parallel: none -- single task):
  Task 1: Create lib/translate-agent-md.sh + lib/claude-code-patterns.sed

Batch 2 (parallel):
  Task 2: Create tests (blocked by Task 1)
  Task 3: Update documentation (blocked by Task 1)
```

No approval gates. All tasks are additive (new files + small doc updates), easy to reverse, and have low blast radius (0-1 dependents within this plan).

### External Skills

No external skills detected in project.

### Verification Steps

After all tasks complete:
1. Run `bash tests/test-translator.sh` -- all ~25 assertions should pass
2. Manually verify `lib/translate-agent-md.sh --agent-md nefario/AGENT.md --format agents-md --output /tmp/test-nefario.md` produces clean output with no frontmatter, no `TaskUpdate`/`SendMessage`, no `@domain:` markers, no `## Main Agent Mode` section
3. Verify stdout JSON contains `{"name": "nefario", ...}`
4. Verify output file has 0600 permissions
5. Verify `docs/adapter-interface.md` contains the new Translator Rules section
6. Verify `docs/external-harness-roadmap.md` #140 entry has a Specification link
