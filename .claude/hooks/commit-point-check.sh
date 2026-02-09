#!/usr/bin/env bash
#
# Stop hook: Commit checkpoint for uncommitted session changes
#
# This hook runs when Claude finishes responding. It reads the session-scoped
# change ledger (written by track-file-changes.sh PostToolUse hook), checks
# for uncommitted changes, and presents a commit checkpoint via stderr if
# any exist.
#
# Exit codes:
#   0 - Allow Claude to stop normally (no uncommitted changes, or deferred)
#   2 - Block Claude's stop; stderr contains commit checkpoint instructions

set -euo pipefail

# --- Constants ---

readonly SENSITIVE_PATTERNS_FILE=".claude/hooks/sensitive-patterns.txt"
readonly MAX_DISPLAY_FILES=10

# --- Helpers ---

# Read JSON input from stdin
read_input() {
    local input
    input=$(cat)
    echo "$input"
}

# Extract field from JSON
json_field() {
    local json="$1"
    local field="$2"
    echo "$json" | jq -r ".$field // empty" 2>/dev/null || echo ""
}

# Get the session ID from input JSON or env var
get_session_id() {
    local input="$1"
    local sid
    sid=$(json_field "$input" "session_id")
    if [[ -z "$sid" ]]; then
        sid="${CLAUDE_SESSION_ID:-default}"
    fi
    echo "$sid"
}

# Get the current branch name. Returns empty string on detached HEAD or non-git dir.
get_current_branch() {
    git symbolic-ref --short HEAD 2>/dev/null || echo ""
}

# Check if we are inside a git working tree
is_git_repo() {
    git rev-parse --is-inside-work-tree >/dev/null 2>&1
}

# Check if a branch name is a protected branch (main or master)
is_protected_branch() {
    local branch="$1"
    [[ "$branch" == "main" || "$branch" == "master" ]]
}

# Check if a file matches any sensitive pattern.
# Returns 0 (true) if file is sensitive, 1 if safe.
is_sensitive_file() {
    local filepath="$1"
    local basename
    basename=$(basename "$filepath")

    # Read patterns, skip comments and blank lines
    while IFS= read -r pattern || [[ -n "$pattern" ]]; do
        # Skip comments and blank lines
        [[ -z "$pattern" || "$pattern" == \#* ]] && continue

        # Match against the basename using bash glob
        # shellcheck disable=SC2254
        if [[ "$basename" == $pattern ]]; then
            return 0  # Sensitive
        fi

        # Also match against the full relative path for path-based patterns
        # shellcheck disable=SC2254
        if [[ "$filepath" == *$pattern* ]]; then
            return 0  # Sensitive
        fi
    done < "$SENSITIVE_PATTERNS_FILE"

    return 1  # Not sensitive
}

# Count diff lines for a file (additions + deletions)
count_diff_lines() {
    local filepath="$1"
    git diff --numstat -- "$filepath" 2>/dev/null | awk '{print $1 + $2}' || echo "0"
}

# --- Main ---

main() {
    # Read input JSON
    local input
    input=$(read_input)

    # --- Infinite loop protection ---
    local stop_hook_active
    stop_hook_active=$(json_field "$input" "stop_hook_active")
    if [[ "$stop_hook_active" == "true" ]]; then
        exit 0
    fi

    # --- Not a git repo? Exit silently ---
    if ! is_git_repo; then
        exit 0
    fi

    # --- Session ID and ledger path ---
    local session_id
    session_id=$(get_session_id "$input")
    local ledger="/tmp/claude-change-ledger-${session_id}.txt"
    local defer_marker="/tmp/claude-commit-defer-${session_id}.txt"
    local declined_marker="/tmp/claude-commit-declined-${session_id}"

    # --- No ledger or empty ledger? Nothing to commit ---
    if [[ ! -f "$ledger" ]] || [[ ! -s "$ledger" ]]; then
        exit 0
    fi

    # --- Check if user previously declined the commit ---
    if [[ -f "$declined_marker" ]]; then
        exit 0
    fi

    # --- Check defer-all state ---
    if [[ -f "$defer_marker" ]]; then
        exit 0
    fi

    # --- Sensitive patterns file must be readable (fail-closed) ---
    if [[ ! -r "$SENSITIVE_PATTERNS_FILE" ]]; then
        cat >&2 <<'EOF'
**Commit checkpoint skipped.**

The sensitive file patterns file (.claude/hooks/sensitive-patterns.txt) could not be read.
For safety, no files will be staged. Please check the file exists and is readable,
then commit your changes manually.
EOF
        exit 0
    fi

    # --- Get current branch ---
    local branch
    branch=$(get_current_branch)

    # --- Read ledger, deduplicate, and filter ---
    local -a ledger_files=()
    local -a sensitive_files=()
    local -a changed_files=()
    local total_diff_lines=0
    local all_markdown=true

    # Read and deduplicate ledger entries
    local -A seen_paths
    while IFS= read -r filepath || [[ -n "$filepath" ]]; do
        [[ -z "$filepath" ]] && continue
        [[ -n "${seen_paths[$filepath]+x}" ]] && continue
        seen_paths[$filepath]=1
        ledger_files+=("$filepath")
    done < "$ledger"

    # No files after dedup
    if [[ ${#ledger_files[@]} -eq 0 ]]; then
        exit 0
    fi

    # Filter: sensitive files, existence, actual git changes
    for filepath in "${ledger_files[@]}"; do
        # Skip files that no longer exist
        if [[ ! -e "$filepath" ]]; then
            continue
        fi

        # Check sensitive patterns
        if is_sensitive_file "$filepath"; then
            sensitive_files+=("$filepath")
            continue
        fi

        # Check if file has actual uncommitted changes (staged or unstaged)
        if git diff --quiet -- "$filepath" 2>/dev/null && git diff --cached --quiet -- "$filepath" 2>/dev/null; then
            # Also check for untracked files
            local status_output
            status_output=$(git status --porcelain -- "$filepath" 2>/dev/null)
            if [[ -z "$status_output" ]]; then
                continue  # No changes
            fi
        fi

        changed_files+=("$filepath")

        # Track if all files are markdown (for auto-defer)
        if [[ "$filepath" != *.md ]]; then
            all_markdown=false
        fi

        # Count diff lines
        local diff_count
        diff_count=$(count_diff_lines "$filepath")
        total_diff_lines=$((total_diff_lines + diff_count))
    done

    # --- Warn about sensitive files ---
    local sensitive_warning=""
    if [[ ${#sensitive_files[@]} -gt 0 ]]; then
        sensitive_warning="WARNING: Skipped sensitive file(s) (not staged):"
        for sf in "${sensitive_files[@]}"; do
            sensitive_warning+=$'\n'"  - $(basename "$sf")"
        done
        sensitive_warning+=$'\n'"To include them, stage and commit manually."
    fi

    # --- All changes were sensitive? ---
    if [[ ${#changed_files[@]} -eq 0 ]]; then
        if [[ ${#sensitive_files[@]} -gt 0 ]]; then
            cat >&2 <<EOF
**Commit checkpoint skipped.**

All changed files matched sensitive patterns and were excluded.

${sensitive_warning}
EOF
        fi
        # Either no changes or all sensitive -- allow stop
        exit 0
    fi

    # --- Auto-defer for trivial changes ---
    # Only .md files changed AND total diff < 5 lines
    if [[ "$all_markdown" == "true" ]] && [[ "$total_diff_lines" -lt 5 ]]; then
        exit 0
    fi

    # --- Branch protection check ---
    local branch_warning=""
    if [[ -z "$branch" ]]; then
        branch_warning="WARNING: Repository is in detached HEAD state. Commit will be on the detached HEAD. Consider creating a branch first."
    elif is_protected_branch "$branch"; then
        branch_warning="WARNING: You are on the '${branch}' branch. Do NOT commit directly to ${branch}. Please create a feature branch first:

  git checkout -b agent/<name>/<slug>

Then retry the commit."
    fi

    # If on a protected branch, block with warning but do not present a commit checkpoint
    if [[ -n "$branch" ]] && is_protected_branch "$branch"; then
        cat >&2 <<EOF
**Commit checkpoint blocked.**

${branch_warning}

The following files have uncommitted changes from this session:
$(printf '  - %s\n' "${changed_files[@]}")

${sensitive_warning}

Please create a feature branch before committing. Suggest the user run:
  git checkout -b <branch-name>
EOF
        exit 2
    fi

    # --- Build file list for display ---
    local file_list=""
    local file_count=${#changed_files[@]}
    local display_count=$file_count
    if [[ $file_count -gt $MAX_DISPLAY_FILES ]]; then
        display_count=$((MAX_DISPLAY_FILES - 1))
    fi

    for ((i = 0; i < display_count; i++)); do
        file_list+="  - ${changed_files[$i]}"$'\n'
    done

    if [[ $file_count -gt $MAX_DISPLAY_FILES ]]; then
        local remaining=$((file_count - display_count))
        file_list+="  + ${remaining} more"$'\n'
    fi

    # --- Build PR suggestion ---
    local pr_suggestion=""
    if [[ -n "$branch" ]] && ! is_protected_branch "$branch"; then
        pr_suggestion="

After the commit, offer to create a pull request:
  PR: \"<descriptive title>\" (Y/n)

If the user approves, run:
  git push -u origin ${branch}
  gh pr create --title \"<title>\" --body \"<body>\"

If gh CLI is not available, suggest: git push -u origin ${branch}"
    fi

    # --- Present commit checkpoint via stderr ---
    cat >&2 <<EOF
**Uncommitted changes detected.** Present a commit checkpoint to the user.

Use this exact format:

\`\`\`
Commit: "<type>: <summary>"

${file_list}
Co-Authored-By: Claude <noreply@anthropic.com>
(Y/n)
\`\`\`

Rules for the commit message:
- Use conventional commit types: feat, fix, docs, refactor, test, chore, style
- Summary in imperative mood, lowercase, no period, max 72 chars
- Infer the type and summary from the changed files and session context

${sensitive_warning:+${sensitive_warning}

}${branch_warning:+${branch_warning}

}Stage ONLY these files (never use git add -A or git add .):
$(printf '  git add "%s"\n' "${changed_files[@]}")

If the user responds "Y" or presses Enter:
1. Stage the files listed above
2. Commit with the message and Co-Authored-By trailer
3. After committing, clear the ledger: > "${ledger}"

If the user responds "n":
1. Do NOT commit
2. Create a marker so this prompt is not repeated: touch "${declined_marker}"
3. Inform the user their changes remain uncommitted

If the user responds "defer-all":
1. Do NOT commit now
2. Create a defer marker: echo "deferred" > "${defer_marker}"
3. Inform the user all commits are deferred until wrap-up${pr_suggestion}
EOF

    exit 2  # Block Claude's stop; stderr instructions will be fed to Claude
}

# Run main function
main
