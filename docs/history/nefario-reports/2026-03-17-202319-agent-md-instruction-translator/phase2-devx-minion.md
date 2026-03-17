## Domain Plan Contribution: devx-minion

### Recommendations

#### (a) CLI Interface: Flag-Based, Consistent with load-routing-config.sh

The translator should follow the exact same CLI conventions established by `lib/load-routing-config.sh`:

```
lib/translate-agent-md.sh [OPTIONS]

Required (one of):
  --agent-md PATH         Path to the source AGENT.md file

Required:
  --format FORMAT         Target format: "agents-md" or "conventions-md"
  --output PATH           Output file path (the translated_instruction_path)

Optional:
  --agent-dir PATH        Root dir for AGENT.md discovery (default: repo root)
```

**Why flags, not positional args.** The existing `load-routing-config.sh` uses exclusively `--long-flag VALUE` pairs with no positional arguments. This is the right call for several reasons:

1. **Self-documenting invocations.** When the adapter calls this script, the command reads as prose: `--agent-md gru/AGENT.md --format agents-md --output /tmp/session/gru.AGENTS.md`. Positional args like `translate-agent-md.sh gru/AGENT.md agents-md /tmp/out.md` are ambiguous at a glance -- is the second arg the format or the output path?

2. **Scriptability.** Flags compose cleanly when the adapter builds the command programmatically. No need to track argument positions.

3. **Extensibility.** Future flags (e.g., `--strip-pattern` for custom content stripping) slot in without breaking existing callers.

4. **No `--help` flag needed in the arg parser.** Following the existing pattern: unknown args print usage to stderr and exit 2. The script header comment serves as the help text (consistent with `load-routing-config.sh`).

The format enum should use lowercase-hyphenated identifiers (`agents-md`, `conventions-md`) rather than filenames (`AGENTS.md`) to avoid shell quoting issues and stay consistent with the `claude-code`/`codex`/`aider` naming in routing config.

**Output goes to a specified path, not stdout.** Unlike `load-routing-config.sh` (which emits JSON to stdout for piping), the translator writes a file. The adapter needs a file path to pass to `codex exec --agents-file` or `aider --read`. Writing to stdout and redirecting adds shell plumbing the adapter must manage; a `--output` flag keeps the interface declarative.

**Frontmatter fields should be emitted as JSON to stdout** for the caller to consume programmatically (e.g., the adapter may need `model` or `tools` values). This mirrors how `load-routing-config.sh` emits JSON to stdout. Stderr is for diagnostics.

Stdout JSON shape:

```json
{"name": "gru", "model": "opus", "tools": "Read, Glob, Grep, WebSearch, WebFetch, Write, Edit"}
```

This way the adapter can do: `frontmatter=$(lib/translate-agent-md.sh --agent-md ... --format agents-md --output ...)` and parse with jq.

#### (b) Frontmatter Extraction: awk, Not yq

**Use awk for frontmatter extraction.** The existing codebase already has the pattern for this -- `load-routing-config.sh` lines 232-234 and 292-311 extract frontmatter fields using awk, not yq. Specifically:

```bash
awk '/^---$/{if(in_front){exit}else{in_front=1;next}} in_front && /^name:/{gsub(/^name:[[:space:]]*/,""); print; exit}' "$agent_file"
```

The reasons to stay with awk:

1. **No additional dependency for the simple case.** Frontmatter in AGENT.md files uses flat key-value YAML (no nesting, no anchors, no multi-line values beyond `description` which uses `>` folded style). awk handles this reliably.

2. **yq is only needed for complex YAML.** The routing config uses yq because it has nested structures, anchors, and requires JSON conversion. AGENT.md frontmatter is 5-7 flat fields.

3. **Consistency with existing patterns.** The codebase already established "awk for frontmatter, yq for config files." Introducing yq here would break that convention without adding value.

4. **Reduced dependency surface.** The translator should work even if yq is not installed -- it has no need for it.

The awk extraction should handle the `description` field's multi-line `>` folded block by collecting continuation lines (lines starting with whitespace after the `description:` line). However, for the stdout JSON output, the description can be flattened to a single line.

**Frontmatter stripping** (removing the `---`-delimited block from output) is a separate awk pass: print everything after the closing `---`. This is simple, reliable, and handles edge cases (the body can itself contain `---` horizontal rules -- the awk state machine exits after the second `---` delimiter).

Concrete approach:

```bash
# Strip frontmatter: print everything after the closing ---
awk '/^---$/{if(in_front){in_front=0;next}else{in_front=1;next}} !in_front{print}' "$agent_md"
```

#### (c) Claude Code Content Stripping: Targeted sed/awk, Not Section-Aware

After studying the actual AGENT.md files in the repo, Claude Code-specific content appears in three forms:

1. **Inline tool references** -- mentions of `TaskUpdate`, `SendMessage`, `TaskList`, `TeamCreate` in sentences (e.g., nefario/AGENT.md line 888: "assign tasks (TaskUpdate), coordinate via messages (SendMessage)")
2. **Scratch directory conventions** -- references to `nefario-scratch` temp directories
3. **Claude Code invocation patterns** -- phrases like "Task tool", "spawned subagent", "running as main agent via `claude --agent`"

The key insight: **these are NOT cleanly delimited sections.** They appear as phrases within paragraphs, parenthetical asides, and sentences mixed with non-Claude-specific content. A "section-aware" approach (strip entire ## sections) would remove too much valuable content.

**Recommended approach: line-level sed with a curated pattern list.**

Create a file `lib/claude-code-patterns.sed` containing the sed substitution commands:

```sed
# Strip Claude Code-specific tool references (parenthetical)
s/(TaskUpdate)//g
s/(SendMessage)//g
s/(TaskList)//g
s/(TeamCreate)//g

# Strip inline mentions
s/TaskUpdate[, ]*//g
s/SendMessage[, ]*//g

# Strip scratch directory references
s|nefario-scratch-[A-Za-z0-9]*||g
s/scratch directory conventions//g

# Strip Claude Code invocation references
s/via the Task tool//g
s/running as main agent via `claude --agent [a-z-]*`//g
```

Then the translator applies: `sed -f lib/claude-code-patterns.sed`

**Why this approach over alternatives:**

- **Regex sed** is the right tool for string-level substitutions. These are literal string patterns, not structural transformations.
- **Section-aware stripping** (e.g., removing everything under `## Main Agent Mode`) is too aggressive for most agents. Only nefario has Claude Code-specific sections, and even there, the sections contain mixed content.
- **A curated pattern file** is maintainable. When new Claude Code-specific patterns appear, add a line to the sed file. No logic changes needed.
- **The pattern file is testable.** The test can run the patterns against known inputs and verify the output.

**Important caveat**: The sed patterns should be conservative. Removing "TaskUpdate" from a sentence like "assign tasks (TaskUpdate)" may leave grammatically awkward residue ("assign tasks ()"). The patterns should clean up surrounding punctuation:

```sed
# Clean up empty parentheses left after stripping
s/([[:space:]]*)//g
# Clean up trailing/leading commas in lists
s/, ,/,/g
s/^, //
s/, $//
```

For nefario specifically, the "Main Agent Mode (Fallback)" section (lines 882-889) is entirely Claude Code-specific. This is the one case where section-level removal is warranted. Handle it as a special case: if the translator encounters a `## Main Agent Mode` heading, skip until the next `##` heading or end of file. This can be done in awk:

```bash
# Skip "Main Agent Mode" section entirely
awk '/^## Main Agent Mode/{skip=1;next} /^## /{skip=0} !skip{print}'
```

Chain the two: awk section-skipper first, then sed pattern substitutions.

#### (d) Exit Codes: Match Existing Convention

Follow the exact exit code convention from `load-routing-config.sh`:

| Exit Code | Meaning |
|-----------|---------|
| 0 | Success -- translated file written, frontmatter JSON on stdout |
| 1 | Validation/processing error (input file not found, malformed frontmatter, write failure) |
| 2 | Usage error (missing required flags, unknown flags, invalid --format value) |

This matches the established convention: 0 = success, 1 = operational error, 2 = user misuse. No additional codes needed.

**Error messages must follow the existing pattern.** The `load-routing-config.sh` error messages are exemplary -- they include:

1. What went wrong: `"Error: YAML syntax error"`
2. Where: `"  in: $file"`
3. How to fix: `"Add a 'default' field specifying the harness..."`

The translator should follow the same three-part structure:

```
Error: Source AGENT.md file not found

  path: /path/to/missing/AGENT.md

Check the --agent-md path and try again.
```

```
Error: Unknown format 'foo'

  --format must be one of: agents-md, conventions-md

Example: lib/translate-agent-md.sh --agent-md gru/AGENT.md --format agents-md --output /tmp/gru.AGENTS.md
```

#### Additional Design Recommendations

**Format-specific output differences.** Based on the translation table in `external-harness-integration.md`:

- **agents-md**: Output is clean Markdown with the Identity section as a top-level heading, all other sections appended. No special formatting beyond what the AGENT.md body already contains.
- **conventions-md**: Aider's CONVENTIONS.md is also plain Markdown but uses a "preamble" framing. The translator should prepend a brief header comment identifying the source agent (as a Markdown comment `<!-- Translated from: gru/AGENT.md -->`) and then the body content.

Both formats are structurally identical for the body content. The difference is minimal. A simple if/else on format that adjusts the header is sufficient. Do not over-engineer format-specific rendering pipelines.

**File permissions.** The adapter behavioral contract (adapter-interface.md) requires translated instruction files be created with mode 0600. The translator should create the output file with `umask 077` or explicit `chmod 0600` after writing. This is the translator's responsibility since it is the component that creates the file.

**Idempotency.** Running the translator twice with the same inputs should produce identical output. No timestamps, no random content. This enables testing via diff.

**No dependency on yq or jq.** The translator should have zero external dependencies beyond standard POSIX tools (awk, sed, cat, printf). The stdout JSON can be constructed with printf -- the frontmatter is simple enough that jq is overkill. This keeps the translator lightweight and fast.

### Proposed Tasks

1. **Create `lib/translate-agent-md.sh`** -- Main script with argument parsing, frontmatter extraction (awk), content stripping (sed patterns + awk section-skip), format-specific output writing, and frontmatter JSON on stdout.

2. **Create `lib/claude-code-patterns.sed`** -- Curated sed pattern file for Claude Code-specific content stripping. Start conservative; expand based on test coverage across all 27 AGENT.md files.

3. **Create `tests/test-translate-agent-md.sh`** -- Integration tests following the same structure as `tests/test-routing-config.sh`. Test cases:
   - Frontmatter is fully stripped from output
   - Frontmatter JSON on stdout contains all expected fields
   - Claude Code-specific patterns are removed (TaskUpdate, SendMessage, scratch dir)
   - agents-md format produces valid Markdown
   - conventions-md format produces valid Markdown
   - Missing --agent-md exits 1 with actionable error
   - Unknown --format exits 2 with actionable error
   - Output file has 0600 permissions
   - Idempotency: running twice produces identical output
   - Representative AGENT.md files: test with gru (simple), nefario (Claude Code-heavy), frontend-minion (typical minion)

4. **Create `tests/fixtures/translate/`** -- Test fixtures with a minimal AGENT.md and expected output files for each format.

### Risks and Concerns

1. **Sed pattern maintenance.** The curated pattern list is a maintenance surface. If AGENT.md files introduce new Claude Code-specific references, the patterns must be updated. Mitigated by: the test suite running against all 27 actual AGENT.md files and asserting no residual Claude Code patterns in output.

2. **Content stripping is lossy.** Removing tool references from sentences can leave awkward text. The nefario AGENT.md line 888 ("assign tasks (TaskUpdate), coordinate via messages (SendMessage)") becomes "assign tasks , coordinate via messages " after naive stripping. The cleanup patterns must handle this gracefully. This is the highest-risk area and needs careful testing.

3. **Multi-line description field in frontmatter.** The `description` field uses YAML `>` (folded block scalar), which spans multiple lines with indentation. The awk extraction must handle this correctly -- collecting continuation lines until a non-indented line is found. The existing awk patterns in `load-routing-config.sh` only extract `name:` (single-line), so this is new ground.

4. **Body containing `---` horizontal rules.** AGENT.md files use `---` as Markdown horizontal rules within the body (e.g., gru/AGENT.md lines 27, 213, 258, 274). The frontmatter stripper must correctly identify only the opening/closing frontmatter delimiters (lines 1 and the first subsequent `---`), not body rules. The awk state machine approach handles this correctly since it tracks `in_front` state.

5. **nefario is a special case.** It has the most Claude Code-specific content (Main Agent Mode section, Task tool references, TeamCreate/SendMessage/TaskUpdate throughout). The translator should handle nefario correctly without special-casing the agent name -- the pattern-based approach handles this generically. But nefario should be a mandatory test fixture.

### Additional Agents Needed

None beyond those already planned. The translator is a self-contained shell script within the existing `lib/` pattern. It does not cross into other agent domains.

If test-minion is involved in the broader plan, they should review the test fixture design and assertion patterns. The test structure follows the established `tests/test-routing-config.sh` pattern, so this is minimal risk.
