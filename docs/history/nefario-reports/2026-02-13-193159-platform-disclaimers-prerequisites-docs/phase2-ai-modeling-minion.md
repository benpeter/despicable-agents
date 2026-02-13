## Domain Plan Contribution: ai-modeling-minion

### Recommendations

I reviewed the "Quick Setup via Claude Code" prompt from the phase 3 synthesis
(`docs/history/nefario-reports/2026-02-13-142612-cross-platform-compatibility-check/phase3-synthesis.md`,
lines 243-249). The prompt reads:

```
> Check if these tools are installed and install any that are missing:
> - git 2.20+
> - jq 1.6+
> - bash 4.0+ (on macOS, the system bash is 3.2 -- needs brew install bash)
> - gh CLI (optional, for PR creation)
> Then run ./install.sh in this repo to deploy the agents.
```

Here is my assessment across the four questions asked.

---

**1. Is the prompt specific enough for Claude Code to execute reliably?**

Yes, with one important caveat. Claude Code (powered by Opus 4.6 or Sonnet 4.5)
is a capable coding agent that already knows how to:
- Detect the current OS (`uname -s`, `/etc/os-release`)
- Choose the right package manager (Homebrew on macOS, apt/dnf on Linux)
- Run version checks (`bash --version`, `jq --version`, `git --version`)
- Interpret "4.0+" as a minimum version comparison

The prompt does not need to spell out how to do any of this -- Claude Code handles
it natively. The parenthetical "(on macOS, the system bash is 3.2 -- needs brew
install bash)" is the single most important line because it prevents the
model from incorrectly concluding "bash is already installed" when `/bin/bash`
reports 3.2. Without this hint, Claude Code would check `bash --version`, see
version 3.2, and might or might not realize that the system bash is insufficient.
The parenthetical makes the check unambiguous. Good.

The prompt does NOT need to specify `#!/usr/bin/env bash` resolution or `$PATH`
ordering. Claude Code will handle the Homebrew bash installation, and if the user
has a standard Homebrew setup, `env bash` will resolve correctly. If something
is wrong with PATH ordering, Claude Code will diagnose it at runtime when
`bash --version` still reports 3.2 after install.

**Verdict**: Specific enough. No changes needed for execution reliability.

---

**2. Does the prompt handle edge cases?**

Three edge cases to consider:

- **Tool installed but too old**: The prompt says "git 2.20+", "jq 1.6+",
  "bash 4.0+". Claude Code will naturally run `--version` checks and compare
  against these minimums. If a version is too old, it will attempt to upgrade.
  This is standard Claude Code behavior when version constraints are stated.
  No explicit fallback instructions needed.

- **Unsupported platform**: If pasted on Windows (native cmd or PowerShell,
  not WSL), Claude Code will detect Windows and will not find `brew` or `apt`.
  The prompt does not address this. However, this is acceptable because:
  (a) the surrounding documentation text says "Already have Claude Code?" and
  the prerequisites page itself says "Windows: Not currently supported", and
  (b) Claude Code is smart enough to say "this project requires macOS or Linux"
  if it cannot find a viable package manager.

- **Homebrew not installed on macOS**: If the user has macOS but no Homebrew,
  Claude Code will attempt to install Homebrew first. This is fine -- it is
  standard Claude Code behavior and Homebrew's install script is well-known.
  No explicit mention needed in the prompt.

**Verdict**: Edge cases are adequately handled by Claude Code's native
capabilities combined with the surrounding documentation context. No changes
needed.

---

**3. Is the prompt too long or too short?**

The prompt is 5 lines. This is the right length for a copy-paste use case:

- Short enough to be pasted without scrolling or editing
- Long enough to be unambiguous about what to check and install
- The "optional" annotation on `gh` prevents Claude Code from treating it as
  a hard requirement
- The final line ("Then run ./install.sh") chains the next action naturally

If anything, the prompt is slightly under-specified on one point: it says
"install any that are missing" but does not say "upgrade any that are too old."
Claude Code will likely do this anyway because the version constraints are
stated, but making it explicit would cost only 3 words and remove ambiguity.

**Recommended micro-edit**: Change "install any that are missing" to "install
or upgrade any that are missing or too old." This makes the version check
behavior explicit rather than inferred.

**Verdict**: Right length. One minor wording improvement suggested above.

---

**4. Blockquote vs. fenced code block?**

The prompt is currently rendered as a blockquote (lines prefixed with `>`).
This is the wrong choice for a copy-paste target. Reasons:

- **Blockquotes are not designed for copying.** In GitHub-rendered markdown,
  blockquotes render with a left border bar. Select-all-copy in most browsers
  picks up the rendered text including the ">" prefixes in some contexts, or
  strips them inconsistently. The user experience is unpredictable.

- **Fenced code blocks are copy-friendly.** GitHub renders fenced code blocks
  with a "copy" button (clipboard icon in the top-right corner of the block).
  One click, clean copy, no prefix artifacts. This is the standard UX for
  "paste this command/text."

- **The prompt is not a quote, it is an instruction to paste.** Semantically,
  blockquote markup means "this is attributed text from another source." A
  fenced code block (or a plain code fence without language tag) means "this is
  text you should use verbatim." The latter matches the intent.

**Recommendation**: Change from blockquote to a fenced code block with no
language tag (plain text). This gives the user a copy button on GitHub and
clean select-copy behavior in all renderers.

Before:
```markdown
> Check if these tools are installed and install any that are missing:
> - git 2.20+
> ...
```

After:
````markdown
```
Check if these tools are installed and install or upgrade any that are
missing or too old:
- git 2.20+
- jq 1.6+
- bash 4.0+ (on macOS, the system bash is 3.2 -- needs brew install bash)
- gh CLI (optional, for PR creation)
Then run ./install.sh in this repo to deploy the agents.
```
````

**Verdict**: Use a fenced code block, not a blockquote.

---

### Proposed Tasks

**Task 1: Revise the Claude Code setup prompt wording**

- What: In the prompt text destined for `docs/prerequisites.md` under "Quick
  Setup via Claude Code", change "install any that are missing" to "install or
  upgrade any that are missing or too old."
- Deliverable: Updated prompt text in the copy that software-docs-minion will
  integrate.
- Dependencies: None. This is a wording change within the advisory copy.

**Task 2: Change prompt format from blockquote to fenced code block**

- What: In the copy destined for `docs/prerequisites.md`, change the prompt
  from blockquote (`>` prefix) to a fenced code block (triple backticks, no
  language tag). This applies to the prompt in `docs/prerequisites.md` AND any
  README reference that reproduces the prompt.
- Deliverable: Updated markdown formatting in the copy.
- Dependencies: None.

Both tasks are minor edits (under 10 words changed, formatting change) and can
be applied by whichever agent writes the final `docs/prerequisites.md` file.
They do not require a separate execution step.

### Risks and Concerns

1. **Low risk: Homebrew installation on locked-down macOS.** Some corporate
   macOS machines block Homebrew installation. Claude Code will hit this and
   report the error. The user will need to contact IT. This is not something
   the prompt can solve -- it is an environment constraint. No action needed,
   but the prerequisites page already covers manual install commands as a
   fallback for users who cannot or prefer not to use the Claude Code prompt.

2. **Low risk: Prompt drift.** If the tool version requirements change (e.g.,
   bash 5+ becomes required, or jq is replaced with something else), the
   prompt in `docs/prerequisites.md` must be updated alongside the tool table.
   Since both live on the same page, the proximity makes drift unlikely. No
   additional action needed.

3. **No risk from the prompt engineering perspective on model capability.**
   The prompt is well within Claude Code's standard operating envelope.
   Detecting a platform, checking tool versions, and running package manager
   commands are routine operations for Claude Code. There is no prompt
   engineering risk of hallucination, misinterpretation, or unintended behavior.

### Additional Agents Needed

None. The current team (software-docs-minion for writing the docs, devx-minion
for developer experience review) is sufficient. The prompt engineering
assessment is complete and the two proposed changes are minor enough to be
incorporated by the docs author without further specialist review.
