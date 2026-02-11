# Domain Plan Contribution: ux-strategy-minion

## Recommendations

### Information Architecture: Snippet First, Explain After

The user's job is "I want to see what nefario is doing in my terminal status bar." Applying Krug's Law -- don't make me think -- the optimal information sequence is:

1. **Lead with the paste-able snippet.** The user's primary action is "paste this, get the result." A setup guide that explains context before the action forces users to read background material they don't need yet. This violates the satisficing principle: users take the first reasonable action, not the optimal one. If the snippet is at the top, they paste it and are done. If the explanation is at the top, they scan past it looking for "the thing to copy."

2. **Explain after, not before.** After the snippet, add a brief "What this does" section for users who want to understand. This is textbook progressive disclosure: the primary action (paste snippet) is immediately visible; secondary information (how it works) is available on demand via reading further.

3. **Do NOT gate the snippet behind prerequisites.** The only real prerequisite is `jq` being installed. Mention it in one line above the snippet, not as a separate section. Most developers already have `jq`.

### Session Isolation: Background Context, Not Feature Highlight

Session isolation (the `session_id`-based file path pattern) answers a question most users will never ask: "What happens if I run two Claude Code sessions simultaneously?" Presenting it as a feature highlight would violate Nielsen's "aesthetic and minimalist design" heuristic -- irrelevant information competes with relevant information.

**Recommendation**: Present session isolation as a brief parenthetical or a single sentence in the "What this does" section, not as a heading or callout. Something like: "The file path includes the session identifier, so multiple Claude Code sessions show their own nefario status independently."

Users who need to understand isolation (power users running parallel sessions) will read the explanation section. Users who don't (the majority) won't be slowed down by it.

### Level of "Why": Minimal

A 2-minute setup guide should contain approximately zero paragraphs of motivation. The user already knows WHY they want status line visibility -- they came to this page. The guide should:

- State what will appear in the status bar (one sentence)
- Show how to set it up (the snippet)
- Explain what the moving parts are (brief section for the curious)
- Note the cleanup behavior (sentinel file is temporary)

That's it. No design rationale, no architectural explanation of three-channel status propagation, no discussion of GitHub issue #16078.

### Critical Technical Finding: File Path Mismatch

During investigation, I identified a mismatch between the sentinel file path and the status line's available data:

- **SKILL.md writes to**: `/tmp/nefario-status-${slug}` where `slug` is derived from the task description (kebab-case)
- **Status line JSON provides**: `session_id` (a UUID like `abc123-def456...`)
- **These are different values.** A status line script cannot predict the sentinel file's name from the `session_id` alone.

The user's own `~/.claude/settings.json` status line reads `/tmp/nefario-status-${CLAUDE_SESSION_ID}`, which is the environment variable -- not the slug. **This means the current setup does not actually work** unless `CLAUDE_SESSION_ID` happens to be available as an environment variable in the status line command's execution context (which it appears to be, based on the inline `${}` shell expansion in the settings.json command string).

**This creates two possible guide approaches:**

1. **Use `$CLAUDE_SESSION_ID` environment variable** (as the user's own config does): `f="/tmp/nefario-status-${CLAUDE_SESSION_ID}"`. This works if the env var is available in the status line command's shell context, but the sentinel file is written using `${slug}`, so they won't match.

2. **Glob for any nefario-status file**: `ns=$(cat /tmp/nefario-status-* 2>/dev/null | head -1)`. This finds any sentinel file regardless of naming, but shows status from ANY nefario session on the machine, not just the current one.

**This is a blocker for writing an accurate guide.** The guide cannot provide a "paste this and it works" snippet without resolving the path mismatch. Either:
- The SKILL.md needs to change to write `/tmp/nefario-status-${CLAUDE_SESSION_ID}` (out of scope per the issue), or
- The guide must document the glob approach (works but loses session isolation), or
- We confirm that `$CLAUDE_SESSION_ID` is reliably available in the status line command's shell execution context AND the SKILL.md actually uses it somewhere I missed.

**Recommendation**: This must be resolved before writing the guide. The executing agent should verify the actual runtime behavior. If the env var approach works, the guide is straightforward. If not, the SKILL.md scope exclusion may need to be revisited.

### Document Structure

Based on the above analysis, the optimal guide structure:

```
# Nefario Status Line

See what nefario is working on in your Claude Code status bar.

## Setup

Requires: jq (most systems have it; `brew install jq` on macOS if not)

[paste-able snippet -- either settings.json addition or script file + settings pointer]

Restart Claude Code or send a message to see the status line.

## What You See

When nefario is running, the status bar shows: `Nefario: <task summary>`
When nefario is not running, nothing extra appears.

## How It Works

[2-3 sentences: nefario writes a sentinel file at orchestration start,
the status line script reads it, nefario cleans it up when done.
Session-scoped so parallel sessions show independent status.]
```

Total: ~20 lines of content. Under 2 minutes to read AND execute.

## Proposed Tasks

### Task 1: Resolve sentinel file path mismatch

**What to do**: Verify the runtime behavior. Specifically: when Claude Code runs a `statusLine` command, is the `CLAUDE_SESSION_ID` environment variable available in the shell context? And does the SKILL.md's `${slug}` sentinel file path align with what the status line script can discover? If there's a genuine mismatch, determine the correct approach (env var, glob, or SKILL.md amendment).

**Deliverables**: A confirmed working file path pattern for the status line snippet.

**Dependencies**: None. Must complete before Task 2.

### Task 2: Write the setup guide

**What to do**: Create `docs/status-line-setup.md` following the structure recommended above. Lead with the snippet, explain after.

**Deliverables**: A guide document under 30 lines of content (excluding code blocks) that a user can follow in under 2 minutes.

**Dependencies**: Task 1 (confirmed file path pattern).

### Task 3: Add a link from using-nefario.md

**What to do**: Add a single line to the "Tips for Success" section of `docs/using-nefario.md` pointing to the status line guide. Something like: "**Monitor orchestration progress.** See [Status Line Setup](status-line-setup.md) to show the active nefario task in your terminal status bar."

**Deliverables**: One line added to `docs/using-nefario.md`.

**Dependencies**: Task 2.

## Risks and Concerns

### Risk 1 (HIGH): Sentinel file path mismatch

As detailed above, the SKILL.md writes to `/tmp/nefario-status-${slug}` but the status line script has no native way to derive the slug. The `session_id` available in JSON input is a UUID, not a slug. If the `CLAUDE_SESSION_ID` environment variable is not available in the status line command's execution context, or if it doesn't match the slug, the guide cannot provide a working snippet. **This must be resolved first.**

### Risk 2 (MEDIUM): Users with existing status line configurations

Users who already have a custom `statusLine` in their `settings.json` need to MERGE the nefario snippet into their existing script, not replace it. The guide must present the nefario-specific logic as a composable fragment that can be added to any existing status line, not as a complete replacement. Presenting it as a replacement would break existing setups.

### Risk 3 (LOW): jq dependency

The recommended approach uses `jq` for JSON parsing. Most developer machines have it, but it's not guaranteed. The guide should mention the prerequisite in one line. This is low risk because the Claude Code status line documentation itself uses `jq` in all its examples -- users with custom status lines likely already have it.

### Risk 4 (LOW): Stale sentinel files after crashes

If nefario crashes, the sentinel file remains. The guide should mention this is harmless (cleared on reboot) in the "How It Works" section. Users don't need to worry about manual cleanup.

## Additional Agents Needed

**devx-minion** should be consulted to resolve the sentinel file path mismatch (Risk 1 above). The devx-minion designed the original sentinel file mechanism and understands the runtime environment -- specifically whether `CLAUDE_SESSION_ID` is available as an env var in the status line command's shell context, and whether the slug-based path was an intentional divergence from the session-ID-based commit marker pattern. This is a prerequisite for the guide being accurate.

If devx-minion is already planned for this task, no additional agents are needed beyond that. The writing itself is straightforward once the technical path is confirmed.
