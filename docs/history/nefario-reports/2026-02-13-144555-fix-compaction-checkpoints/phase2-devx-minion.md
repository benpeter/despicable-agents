# Domain Plan Contribution: devx-minion

## Recommendations

### 1. Do NOT use clipboard -- print a copyable code block instead

The clipboard approach (`pbcopy`) is the wrong tool here. Here is why:

**Cross-platform fragmentation is a maintenance burden for zero gain.** You need
`pbcopy` (macOS), `xclip -selection clipboard` or `xsel --clipboard` (Linux X11),
`wl-copy` (Linux Wayland), and `clip.exe` (WSL). Each has different availability,
different installation states, and different failure modes. The SKILL.md spec would
need platform detection logic, fallback chains, and error handling for a feature
that saves the user one select-and-copy action.

**Clipboard is invisible state.** After clipboard copy, the user has no way to
verify what was copied without pasting. If the copy failed silently, or if
something else overwrites the clipboard between copy and paste, the user pastes
garbage. Invisible state is bad DX.

**The terminal already has a clipboard: select-and-copy.** Every terminal emulator
supports selecting text and copying it. This is muscle memory for CLI users.
A well-formatted code block is faster to recognize, verify, and copy than an
invisible clipboard payload.

**Recommendation: print the `/compact` command in a fenced code block.** The
instruction becomes "Copy and paste the command below" instead of "Paste the
command from your clipboard." One fewer abstraction layer, zero platform
dependencies, no failure modes.

```
Paste and run:

    /compact focus="Preserve: current phase ..."

Type `continue` when ready.
```

The 4-space indented block (or fenced code block) is visually distinct in the
terminal, easy to triple-click-select on most terminals, and self-documenting.
The user can see exactly what they are about to run.

### 2. If clipboard is kept despite the above, use heredoc piping

If the decision is made to keep clipboard copy (overriding recommendation 1),
the escaping strategy must use a heredoc to avoid shell interpretation of the
focus string.

The focus string contains:
- Double quotes (the `focus="..."` wrapper)
- `$summary` (a literal string that must NOT be expanded by the shell)
- Colons, commas, parentheses (safe in most contexts but risky in edge cases)

The only safe approach is a **quoted heredoc** (`<<'EOF'`), which suppresses
all shell expansion:

```bash
cat <<'COMPACT_CMD' | pbcopy
/compact focus="Preserve: current phase (3.5 review next), synthesized execution plan, inline agent summaries, task list, approval gates, team name, branch name, $summary, scratch directory path. Discard: individual specialist contributions from Phase 2."
COMPACT_CMD
```

The single quotes around `'COMPACT_CMD'` are critical -- they prevent `$summary`
from being expanded as a shell variable. Without them, `$summary` becomes empty
string or whatever happens to be in the environment.

For platform detection, the minimal approach:

```bash
case "$(uname -s)" in
  Darwin) cat <<'EOF' | pbcopy
/compact focus="..."
EOF
    ;;
  Linux)
    if command -v xclip >/dev/null 2>&1; then
      cat <<'EOF' | xclip -selection clipboard
/compact focus="..."
EOF
    elif command -v xsel >/dev/null 2>&1; then
      cat <<'EOF' | xsel --clipboard
/compact focus="..."
EOF
    elif command -v wl-copy >/dev/null 2>&1; then
      cat <<'EOF' | wl-copy
/compact focus="..."
EOF
    fi
    ;;
  *) ;; # WSL detection would check /proc/version for Microsoft
esac
```

This is 20+ lines of shell in a SKILL.md spec file that is already long. The
benefit over "copy the text below" is negligible.

### 3. Failure handling: always print the command, clipboard is bonus

Regardless of which approach is chosen, the command text must ALWAYS be printed
to stdout. Clipboard copy (if used) is an enhancement, not the primary delivery
mechanism.

- If clipboard succeeds: print the command AND note it was copied.
- If clipboard fails or is unavailable: print the command with no mention of
  clipboard. Do not warn about clipboard failure -- it is noise. The user has
  the command in front of them.

This means the printed code block is the primary interface. Clipboard becomes a
progressive enhancement that the spec can add later (or via the programmatic
`/compact` in issue #88) without changing the core interaction.

### 4. Shell escaping: the focus string is static, not dynamic

A key simplification: the focus strings in both compaction checkpoints are
**hardcoded in the SKILL.md spec**. They are not generated dynamically from
user input. The only variable-like element is `$summary`, which is a literal
token (it tells `/compact` what to preserve), not a shell variable to expand.

This means:
- No runtime escaping logic is needed.
- The command string can be written verbatim in the spec.
- The spec author controls the content, so shell-hostile characters can be
  avoided at authoring time.

The one risk is future edits to the focus string that introduce backticks,
single quotes, or other shell metacharacters. A comment in the SKILL.md near
the focus strings would prevent this:

```
<!-- Focus strings are printed verbatim in terminal output.
     Avoid backticks, single quotes, and backslashes. -->
```

### 5. The visual hierarchy table needs updating

The current visual hierarchy (SKILL.md line 237) lists compaction checkpoints as
"Advisory" weight (blockquote). If the checkpoint becomes an AskUserQuestion gate,
it moves to "Decision" weight. The table entry must be updated or removed to
maintain accuracy.

## Proposed Tasks

### Task 1: Replace blockquote checkpoints with AskUserQuestion gates + printed command

**What**: In SKILL.md, replace both compaction checkpoint sections (post-Phase 3,
lines ~811-825; post-Phase 3.5, lines ~1194-1206) with:
- AskUserQuestion gate specification (header, question, options)
- "Compact" option handler that prints the `/compact` command in a code block
  (not clipboard)
- "Skip" option handler that prints continuation message
- Response handling for "continue" after compact

**Deliverable**: Updated SKILL.md with two new gate specifications.

**Dependencies**: Needs UX strategy input on gate structure (header convention,
option labels, recommended default). Must align with whatever ux-strategy-minion
recommends for the interaction flow.

### Task 2: Update visual hierarchy table

**What**: Update the visual hierarchy table (SKILL.md line ~237) to either:
- Remove the "Advisory" row for compaction checkpoints (if no other advisories
  remain), or
- Change the compaction checkpoint reference to "Decision" weight, or
- Keep "Advisory" as a weight class but remove compaction from its examples

**Deliverable**: Accurate visual hierarchy table.

**Dependencies**: Depends on Task 1 (need to know final gate format).

### Task 3: Add authoring guard comment near focus strings

**What**: Add a brief comment near each focus string warning future editors
not to introduce shell metacharacters (backticks, single quotes, backslashes)
since the string is printed verbatim in terminal output.

**Deliverable**: Two inline comments in SKILL.md.

**Dependencies**: None. Can be done as part of Task 1.

## Risks and Concerns

### Risk 1: `$summary` in the focus string looks like a shell variable

When the `/compact focus="..."` command is printed in terminal output, `$summary`
appears as a literal token. But if ANY code path ever pipes this string through
a shell without proper quoting, `$summary` will be expanded (likely to empty
string). The printed-code-block approach avoids this entirely since the
orchestrator emits it as text output, not as a Bash command. But if clipboard
copy is used via Bash tool, the heredoc MUST use single-quoted delimiter
(`<<'EOF'`).

**Mitigation**: Recommend the printed-code-block approach. If clipboard is kept,
the spec must mandate quoted heredoc syntax.

### Risk 2: Terminal code block selection varies

Triple-click to select a line works in most terminals, but code blocks spanning
multiple lines may require click-and-drag or terminal-specific selection
(e.g., rectangular select in iTerm2, block select in Windows Terminal). The
`/compact focus="..."` command is a single long line, so triple-click should
work. But if it wraps in a narrow terminal, the user might copy a partial
command.

**Mitigation**: Keep the command on a single line (no line breaks within it).
The indented code block format helps visual distinction. This is an acceptable
trade-off -- CLI users handle long lines routinely.

### Risk 3: Spec complexity for a transitional feature

Issue #88 tracks programmatic `/compact` support. When that lands, the entire
clipboard/paste dance becomes unnecessary. The current fix should be as simple
as possible to minimize throwaway work.

**Mitigation**: The printed-code-block approach is the simplest possible
implementation (just text output, no Bash tool calls, no platform detection).
It will be easy to replace with a programmatic call when #88 is resolved.

## Additional Agents Needed

None. The current team (ux-strategy-minion for interaction design, devx-minion
for CLI/DX concerns) covers the planning questions. The mandatory Phase 3.5
reviewers (security-minion, test-minion, ux-strategy-minion, lucy, margo) will
catch execution issues.
