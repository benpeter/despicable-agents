# Phase 2: devx-minion Planning Contribution

## Summary

The alembic symbol integration is straightforward from a terminal rendering perspective, but the details of *where* to use which variant matter for correct alignment and consistent developer experience. After hands-on testing of the Unicode encoding pipeline on macOS, here are concrete answers and integration recommendations.

## Answers to Planning Questions

### (a) Status file content (`/tmp/nefario-status-$SID`): Use the text variant (U+2697 U+FE0E)

**Recommendation**: Yes, the status file MUST include U+FE0E (text presentation selector).

**Rationale from testing**:

| Variant | Bytes | `wcwidth` (terminal columns) | Rendering |
|---------|-------|------------------------------|-----------|
| U+2697 bare | 3 bytes (`e2 9a 97`) | 1 column | Inconsistent -- terminal decides presentation |
| U+2697 U+FE0E (text) | 6 bytes (`e2 9a 97 ef b8 8e`) | 1 column | Forced monochrome/text glyph, 1 cell wide |
| U+2697 U+FE0F (emoji) | 6 bytes (`e2 9a 97 ef b8 8f`) | 2 columns | Forced color emoji glyph, 2 cells wide |

The status line pipeline works as follows:
1. Nefario `echo`s content to `/tmp/nefario-status-$SID`
2. The status line shell command `cat`s the file contents
3. The result is appended to `$result` via string concatenation
4. `echo "$result"` outputs the final status line
5. Claude Code renders this in the terminal status bar (monospace context)

Using the bare U+2697 (without any variation selector) is **risky** because terminal emulators vary in their default presentation for ambiguous-width symbols. Some terminals (especially iTerm2 with certain font configurations) may render a bare U+2697 as a 2-cell-wide emoji glyph while the text pipeline calculates it as 1 cell, causing misalignment. The text variant selector U+FE0E explicitly requests single-cell-width text presentation, which is the correct choice for a monospace status line.

### (b) Markdown phase announcements: Use the emoji variant (U+2697 U+FE0F, displayed as the alembic symbol with possible color)

**Recommendation**: Use the emoji presentation in markdown output (phase announcements, gate headers, user-facing messages rendered by Claude Code's markdown renderer).

**Rationale**: Claude Code renders markdown in a proportional-width rich text context, not a fixed-width terminal grid. In this context:

- The emoji presentation U+FE0F renders the full-color alembic glyph, which is more visually distinctive and scannable
- There are no alignment concerns because markdown is not monospace-columnar
- Phase announcements like `**--- Phase 1: Meta-Plan ---**` are "Orientation" weight in the visual hierarchy -- the emoji adds a recognizable anchor without requiring users to read text
- The text variant U+FE0E would render as a small, potentially invisible monochrome glyph in rich text, defeating the purpose of visual identity

This creates a clear two-context rule:
- **Monospace contexts** (status file, terminal output): `⚗︎` (U+2697 U+FE0E)
- **Rich text contexts** (markdown phase announcements, gate headers): `⚗️` (U+2697 U+FE0F)

### (c) Bash syntax for echoing U+2697 U+FE0E reliably

**Tested and confirmed working on macOS** (Terminal.app, zsh, bash):

**Option 1 -- Literal characters in the echo string (RECOMMENDED)**:
```sh
echo "⚗︎ P1 Meta-Plan | $summary" > /tmp/nefario-status-$SID
```

This works because:
- The SKILL.md file is UTF-8 encoded
- When Claude Code's LLM generates the `echo` command, it emits the literal UTF-8 bytes
- `echo` in both bash and zsh passes through UTF-8 bytes unmodified
- Verified: the output file contains the correct 6-byte sequence `e2 9a 97 ef b8 8e`

**Option 2 -- printf with Unicode escapes (FALLBACK)**:
```sh
printf '\xe2\x9a\x97\xef\xb8\x8e P1 Meta-Plan | %s\n' "$summary" > /tmp/nefario-status-$SID
```

or:
```sh
printf '\u2697\uFE0E P1 Meta-Plan | %s\n' "$summary" > /tmp/nefario-status-$SID
```

**Option 1 is strongly preferred** because:
- It is what the SKILL.md already uses for all status file writes (literal strings in `echo`)
- It matches the existing pattern -- no syntax change needed, just prepend the symbol
- `printf` with `\u` escapes works in bash 4.4+ and zsh but has edge cases in older bash versions (macOS ships bash 3.2 by default, though zsh is the default shell)
- Readability: the literal glyph in the SKILL.md source is self-documenting

**Risk note on bash 3.2**: macOS still ships `/bin/bash` as version 3.2, which does NOT support `\u` escapes in `printf`. However, this is not a practical risk because:
1. Claude Code uses `$SHELL` which is `zsh` by default on macOS since Catalina
2. The status line command runs via `sh -c` which is also zsh on modern macOS
3. The `echo` approach with literal UTF-8 works in ALL shell versions

## Integration Approach

### Status file writes (SKILL.md)

Every `echo` that writes to `/tmp/nefario-status-$SID` needs the text-variant alembic prefix. There are exactly these patterns to update:

| Current pattern | Updated pattern |
|----------------|-----------------|
| `echo "P1 Meta-Plan \| $summary"` | `echo "⚗︎ P1 Meta-Plan \| $summary"` |
| `echo "P2 Planning \| $summary"` | `echo "⚗︎ P2 Planning \| $summary"` |
| `echo "P3 Synthesis \| $summary"` | `echo "⚗︎ P3 Synthesis \| $summary"` |
| `echo "P3.5 Review \| $summary"` | `echo "⚗︎ P3.5 Review \| $summary"` |
| `echo "P4 Execution \| $summary"` | `echo "⚗︎ P4 Execution \| $summary"` |
| `echo "P4 Gate \| $task_title"` | `echo "⚗︎ P4 Gate \| $task_title"` |

The `chmod 600` line and `SID=...` line are unchanged.

**Length budget impact**: The alembic prefix adds `⚗︎ ` (symbol + space = 2 visible columns, 7 bytes). The existing status format is approximately `P1 Meta-Plan | <40-char summary>` = ~56 chars. Adding 2 visible columns makes it ~58 chars. This is well within typical terminal width. The SKILL.md notes a soft cap of ~62 chars for the nefario portion; verify this budget still holds with the prefix.

### Phase announcements (SKILL.md)

Update all phase announcement patterns from:
```
**--- Phase N: Name ---**
```
to:
```
**--- Phase N: Name ---**
```

Wait -- the task says "all nefario phase announcements and user-facing messages are prefixed." This means the format becomes:

```
**--- Phase 1: Meta-Plan ---**
```

The alembic emoji here uses the emoji variant U+FE0F since this is markdown rendered by Claude Code's rich text UI. However, including emojis in bold markdown headers has a subtlety: some markdown renderers may strip or misrender variation selectors inside bold markers. Test this in Claude Code's actual output rendering.

### Status line display (despicable-statusline SKILL.md)

The `despicable-statusline` skill's shell command does NOT need changes. It reads the status file via `cat` and appends it to `$result` as-is. The alembic prefix is part of the file content, so it flows through automatically. The final rendered status line will look like:

```
~/project | Claude Sonnet | Context: 42% | ⚗︎ P1 Meta-Plan | implement alembic prefix...
```

This is correct and requires zero changes to the statusline skill.

### AGENT.md

The nefario AGENT.md does not contain the specific `echo` patterns -- those live in SKILL.md. However, if AGENT.md references phase announcement formatting or any user-facing message templates, those should also get the alembic prefix. From my review, AGENT.md does not contain these patterns; it delegates to SKILL.md for operational details.

## Risks and Mitigations

| Risk | Likelihood | Impact | Mitigation |
|------|-----------|--------|------------|
| Variation selector stripped by text processing | Low | Medium -- reverts to ambiguous-width bare glyph | Test end-to-end in actual Claude Code session; the `echo`/`cat` pipeline preserves bytes faithfully (verified) |
| Claude Code's markdown renderer ignores U+FE0F in bold text | Low | Low -- symbol still renders, just might not be colored | Acceptable degradation; the symbol is still visible |
| Status line truncation cuts into alembic prefix | Low | Low -- worst case, just the symbol is cut | The 2-column addition is small; existing budget has room |
| Copy-paste from SKILL.md loses variation selectors | Medium | Medium -- subsequent edits produce bare glyph | Document the encoding explicitly in a comment near the echo patterns (e.g., `# ⚗︎ = U+2697 U+FE0E (text variant, 1 cell wide)`) |
| Font missing alembic glyph | Very Low | Medium -- renders as replacement character | All three target terminals (Terminal.app, VS Code, iTerm2) ship with fonts containing U+2697 in the default configuration |

## Additional Recommendations

1. **Add an inline comment to the first status file write** explaining the encoding choice. Future editors of SKILL.md will not know why there is a variation selector unless told. One line suffices:

   ```sh
   # Status prefix: ⚗︎ = U+2697 U+FE0E (text variant for monospace alignment)
   echo "⚗︎ P1 Meta-Plan | $summary" > /tmp/nefario-status-$SID
   ```

2. **Update the length budget documentation** in SKILL.md. The current note says the prefix is ~16 chars + pipe + 40 chars + ellipsis = ~62 chars. With the alembic prefix, it becomes ~18 chars visible (prefix is `⚗︎ ` = 2 columns, but the byte representation is 7 bytes). Adjust the comment to reflect the new math: `~18 prefix + 3 pipe + 40 summary + 3 ellipsis = ~64 chars max`.

3. **Do NOT modify the `despicable-statusline` SKILL.md**. It is a generic status line installer that should remain agnostic to the content of the nefario status file. The alembic is a nefario concern, not a statusline concern.

4. **Consider the cleanup path**. The existing cleanup commands (`rm -f /tmp/nefario-status-$SID`) are unaffected by the content change. No action needed.

## No Additional Specialists Needed

The planning question is fully within devx-minion's domain (CLI/terminal rendering, shell scripting, developer tool ergonomics). The ux-strategy-minion (already consulted) covers the "why this symbol" and visual identity aspects. No additional specialists are needed beyond what the meta-plan already includes.
