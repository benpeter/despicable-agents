# Phase 3: Synthesis -- Agent Attribution via Hook Events

## Delegation Plan

**Team name**: agent-attribution
**Description**: Add agent_type/agent_id support to the PostToolUse hook and commit workflow, enabling per-agent commit scopes and git trailer attribution.

---

### Conflict Resolution

**Conflict 1: Ledger format -- TSV inline (devx-minion) vs. sidecar file (security-minion)**

Chosen: TSV inline (tab-separated columns in the existing ledger file)
Over: Separate metadata sidecar file
Why: The project philosophy (Helix Manifesto: KISS, lean and mean, minimize moving parts) strongly favors the simpler approach. TSV is a strict superset of the current format -- bare path lines remain valid single-column TSV. Security-minion's concern about preserving existing security properties is addressed by the fact that TSV lines are parsed identically when metadata is absent (IFS=$'\t' read assigns empty strings to extra variables). The sidecar approach introduces file synchronization complexity (two files to create, read, clean up, keep in sync) for no security gain beyond what regex validation already provides. Security-minion's regex validation recommendation (`^[a-zA-Z0-9_-]{1,64}$`) is adopted as the input guard, which eliminates the injection vectors that motivated the sidecar preference.

**Conflict 2: Scope attribution -- agent names in scope (ai-modeling-minion) vs. git trailers (ux-strategy-minion)**

Chosen: Hybrid approach -- domain scopes in commit message (content-centric) + Agent: trailer for attribution (producer-centric)
Over: Raw agent names as conventional commit scope
Why: ux-strategy-minion's analysis is persuasive: 27 agent names as scopes degrades daily git log scanning (jobs 1-3: find bugs, understand changes, review PRs) to optimize for a rare forensic job (job 4: audit who produced a change). The progressive disclosure principle applies: domain scope at the scan level, agent identity one level deeper in trailers. ai-modeling-minion's suffix-stripping rule (`${agent_type%-minion}`) is adopted for the domain scope derivation, since it produces clean domain labels (`frontend`, `security`, `oauth`) that match what developers already think about. ux-strategy-minion's full scope mapping table is captured in documentation but the implementation uses the simpler suffix-stripping heuristic (no maintenance when agents change). The `Agent:` git trailer carries the full agent name for forensic querying.

---

### Task 1: Update track-file-changes.sh to capture agent metadata
- **Agent**: devx-minion
- **Delegation type**: standard
- **Model**: sonnet
- **Mode**: bypassPermissions
- **Blocked by**: none
- **Approval gate**: no
- **Prompt**: |
    Update the PostToolUse hook at `.claude/hooks/track-file-changes.sh` to extract
    `agent_type` and `agent_id` from the hook event JSON and write them as
    tab-separated columns in the change ledger.

    ## Current State

    The hook currently:
    1. Reads JSON from stdin (PostToolUse event)
    2. Extracts `.tool_input.file_path` via jq
    3. Validates the path (rejects newlines)
    4. Appends the bare path to `/tmp/claude-change-ledger-<session_id>.txt`
    5. Deduplicates using `grep -qFx "$file_path"`

    ## What to Change

    1. **Extract agent metadata** after file_path extraction:
       ```bash
       local agent_type
       agent_type=$(json_field "$input" '.agent_type')
       local agent_id
       agent_id=$(json_field "$input" '.agent_id')
       ```

    2. **Validate agent_type and agent_id** -- apply regex validation to both:
       ```bash
       # Reject values that don't match safe identifier pattern
       if [[ -n "$agent_type" ]] && ! [[ "$agent_type" =~ ^[a-zA-Z0-9_-]{1,64}$ ]]; then
           agent_type=""
       fi
       if [[ -n "$agent_id" ]] && ! [[ "$agent_id" =~ ^[a-zA-Z0-9_-]{1,64}$ ]]; then
           agent_id=""
       fi
       ```
       This regex allows all current agent names (e.g., `frontend-minion`, `nefario`)
       and rejects newlines, tabs, shell metacharacters, and excessively long values.
       Failing open (clearing to empty) is correct -- agent_type is informational, not
       a security control.

    3. **Write TSV lines** -- when agent_type is present, write tab-separated;
       otherwise write bare path (backward compatible):
       ```bash
       if [[ -n "$agent_type" ]]; then
           local line="${file_path}\t${agent_type}"
           [[ -n "$agent_id" ]] && line+="\t${agent_id}"
           printf '%s\n' "$line"
       else
           echo "$file_path"
       fi
       ```
       Use `printf '%s\n'` for the TSV line to handle the `\t` correctly.
       Actually, use `printf '%s\t%s\t%s\n'` for explicit tab insertion:
       ```bash
       if [[ -n "$agent_type" ]]; then
           if [[ -n "$agent_id" ]]; then
               printf '%s\t%s\t%s\n' "$file_path" "$agent_type" "$agent_id" >> "$ledger"
           else
               printf '%s\t%s\n' "$file_path" "$agent_type" >> "$ledger"
           fi
       else
           echo "$file_path" >> "$ledger"
       fi
       ```

    4. **Update deduplication** -- change from per-path to per-tuple dedup.
       The same file from different agents should both be recorded. Replace:
       ```bash
       if ! grep -qFx "$file_path" "$ledger" 2>/dev/null; then
       ```
       With a check that accounts for agent_type. If agent_type is present,
       check for a line starting with `file_path\tagent_type`:
       ```bash
       local dedup_key="$file_path"
       if [[ -n "$agent_type" ]]; then
           # Check for exact match of path + agent_type (first two columns)
           if grep -qP "^$(printf '%s' "$file_path" | sed 's/[.[\*^$()+?{|\\]/\\&/g')\t$(printf '%s' "$agent_type" | sed 's/[.[\*^$()+?{|\\]/\\&/g')\t" "$ledger" 2>/dev/null; then
               exit 0
           fi
       else
           # Legacy: check bare path (exact full-line match, no tabs)
           if grep -qFx "$file_path" "$ledger" 2>/dev/null; then
               exit 0
           fi
       fi
       ```
       NOTE: The regex escaping above is complex. A simpler approach is to use
       grep -F with the constructed line prefix:
       ```bash
       if [[ -n "$agent_type" ]]; then
           local prefix
           prefix=$(printf '%s\t%s' "$file_path" "$agent_type")
           if grep -qF "$prefix" "$ledger" 2>/dev/null; then
               exit 0
           fi
       else
           if grep -qFx "$file_path" "$ledger" 2>/dev/null; then
               exit 0
           fi
       fi
       ```
       The `-F` flag treats the string literally (no regex), and the tab in the
       prefix ensures it matches the correct columns.

    5. **Harden ledger file creation** -- replace `touch` with explicit permissions:
       ```bash
       if [[ ! -f "$ledger" ]]; then
           install -m 0600 /dev/null "$ledger"
       fi
       ```
       This ensures 0600 regardless of umask. Apply this to the existing ledger
       creation, not just as a new-feature addition.

    6. **Update the file header comment** to document the new TSV format:
       ```
       # PostToolUse hook: Track file changes for commit workflow
       #
       # This hook runs after Write and Edit tool calls. It appends the modified
       # file's absolute path (with optional agent metadata) to a session-scoped
       # change ledger in TSV format:
       #
       #   <file_path>[\t<agent_type>[\t<agent_id>]]
       #
       # When agent_type/agent_id are absent from the hook input, only the bare
       # file path is written (backward compatible with the pre-attribution format).
       ```

    ## What NOT to Do

    - Do NOT create a separate metadata sidecar file. All data goes in the existing ledger.
    - Do NOT add an allowlist of known agent names. The regex validation is sufficient.
    - Do NOT use `agent_type` for any authorization or access control decision.
    - Do NOT change the exit code behavior. The hook must always exit 0.
    - Do NOT use JSON lines format or any format other than TSV.

    ## Deliverables

    Modified `.claude/hooks/track-file-changes.sh` with agent metadata extraction,
    validation, TSV writing, updated dedup, and hardened file creation.

    ## Context

    The `json_field` helper already exists in the script and handles `// empty`
    fallback. The ERR trap ensures the hook always exits 0 even on unexpected
    failures. The agent_type field comes from Claude Code 2.1.69+ hook events
    and is populated when the session uses `--agent` or when inside a subagent.
- **Deliverables**: Modified `.claude/hooks/track-file-changes.sh`
- **Success criteria**: Hook extracts agent_type/agent_id from JSON input, validates with regex, writes TSV lines to ledger, deduplicates on (path, agent_type) tuple, exits 0 in all cases including malformed input.

### Task 2: Update commit-point-check.sh to read TSV ledger and add Agent trailer
- **Agent**: devx-minion
- **Delegation type**: standard
- **Model**: sonnet
- **Mode**: bypassPermissions
- **Blocked by**: Task 1
- **Approval gate**: yes
- **Gate reason**: This task defines the commit message format (scope derivation + Agent trailer) that will appear in every future commit. The format decision has high blast radius (all downstream commits, documentation, SKILL.md instructions depend on it) and is hard to reverse (changing established commit conventions requires rewriting history or accepting inconsistency).
- **Gate rationale**: |
    Chosen: Domain scope via suffix-stripping + Agent: git trailer for attribution
    Over: (1) Raw agent names as scope, (2) No scope change + separate metadata file, (3) Full scope mapping table
    Why: Suffix-stripping produces clean domain labels (frontend, security, oauth) with zero maintenance. The Agent trailer provides forensic attribution without polluting git log --oneline. This balances daily scanability (domain scopes) with occasional auditability (trailers).
- **Prompt**: |
    Update the Stop hook at `.claude/hooks/commit-point-check.sh` to read the
    TSV-format ledger and produce commit checkpoints with domain scopes and
    Agent trailers.

    ## Current State

    The hook currently:
    1. Reads the ledger with `awk 'NF && !seen[$0]++'` for dedup
    2. Iterates with `while IFS= read -r filepath`
    3. Presents a commit checkpoint via stderr with format:
       ```
       Commit: "<type>: <summary>"
       Co-Authored-By: Claude <noreply@anthropic.com>
       ```

    ## What to Change

    ### 1. Parse TSV ledger lines

    Change the ledger read loop to handle TSV:
    ```bash
    while IFS=$'\t' read -r filepath agent_type agent_id || [[ -n "$filepath" ]]; do
    ```

    The awk dedup must also be updated. Currently it deduplicates on the entire
    line (`!seen[$0]++`). Change to deduplicate on the first column (file path)
    only, since for staging purposes each file should appear once:
    ```bash
    deduped=$(awk -F'\t' 'NF && !seen[$1]++' "$ledger")
    ```

    For scope derivation, we need to track which agent_type is associated with
    each file. Use a second pass or collect agent_type during the loop.

    ### 2. Collect agent attribution

    While iterating ledger entries, collect agent_type values:
    ```bash
    declare -A agent_counts
    local primary_agent=""
    ...
    # Inside the loop, after processing a changed file:
    if [[ -n "$agent_type" ]]; then
        agent_counts["$agent_type"]=$(( ${agent_counts["$agent_type"]:-0} + 1 ))
    fi
    ```

    After the loop, determine the primary agent (majority-wins):
    ```bash
    local max_count=0
    for agent in "${!agent_counts[@]}"; do
        if [[ ${agent_counts[$agent]} -gt $max_count ]]; then
            max_count=${agent_counts[$agent]}
            primary_agent="$agent"
        fi
    done
    ```

    ### 3. Derive domain scope from agent_type

    Use suffix-stripping to get the domain scope:
    ```bash
    local scope=""
    if [[ -n "$primary_agent" ]]; then
        scope="${primary_agent%-minion}"
    fi
    ```

    This transforms: `frontend-minion` -> `frontend`, `security-minion` -> `security`,
    `nefario` -> `nefario` (no suffix to strip), `gru` -> `gru`.

    ### 4. Update the commit checkpoint format

    Change the checkpoint message to include scope and Agent trailer:

    **When scope is available:**
    ```
    Commit: "<type>(<scope>): <summary>"

    Agent: <primary_agent>
    Co-Authored-By: Claude <noreply@anthropic.com>
    (Y/n)
    ```

    **When scope is not available (no agent metadata in ledger):**
    ```
    Commit: "<type>: <summary>"

    Co-Authored-By: Claude <noreply@anthropic.com>
    (Y/n)
    ```

    The `Agent:` trailer is a git trailer (same mechanism as Co-Authored-By).
    It carries the full agent name (e.g., `frontend-minion`) for forensic querying.
    Only include the Agent trailer when agent_type is available.

    Keep the `Co-Authored-By: Claude <noreply@anthropic.com>` trailer as-is.
    Do NOT change it to agent-specific attribution. The Co-Authored-By groups
    all AI work under one identity for `git shortlog -s` and GitHub contributor
    graphs.

    ### 5. Update the commit instructions

    In the stderr output, update the "Rules for the commit message" section:
    ```
    Rules for the commit message:
    - Use conventional commit types: feat, fix, docs, refactor, test, chore, style
    - Summary in imperative mood, lowercase, no period, max 72 chars
    - Infer the type and summary from the changed files and session context
    - When a scope is shown, include it in parentheses after the type
    - Include the Agent trailer in the commit body when shown
    ```

    ### 6. Update staging instructions

    In the "Stage ONLY these files" section, the file paths for staging must be
    extracted from column 1 of the TSV. Since the dedup already produces clean
    paths in `$filepath`, this should work as-is. Verify that `$filepath` does
    not contain tab characters from the TSV parsing.

    ## What NOT to Do

    - Do NOT put agent names in the Co-Authored-By trailer. Keep it as `Claude`.
    - Do NOT use a full scope mapping table. Suffix-stripping is sufficient.
    - Do NOT add multi-scope formats like `(frontend,security)`. Use majority-wins.
    - Do NOT change the exit code behavior (0 for allow, 2 for block).
    - Do NOT modify the nefario status file check, protected branch check,
      sensitive file filtering, or any other existing safety logic.

    ## Deliverables

    Modified `.claude/hooks/commit-point-check.sh` with TSV parsing, agent
    attribution collection, scope derivation, and updated checkpoint format.

    ## Context

    The hook is ~360 lines. The changes are concentrated in:
    - The ledger read loop (lines ~170-176)
    - The commit checkpoint message (lines ~312-351)

    The awk dedup and IFS-based parsing are the key format-sensitive lines.
    The rest of the hook (branch protection, sensitive file filtering, infinite
    loop protection) does not need changes.
- **Deliverables**: Modified `.claude/hooks/commit-point-check.sh`
- **Success criteria**: Hook reads TSV ledger lines correctly, derives domain scope from majority agent_type using suffix-stripping, presents commit checkpoint with scope and Agent trailer, handles mixed-format ledger (old bare paths + new TSV), preserves all existing safety behavior.

### Task 3: Create hook test script
- **Agent**: test-minion
- **Delegation type**: standard
- **Model**: sonnet
- **Mode**: bypassPermissions
- **Blocked by**: Task 1, Task 2
- **Approval gate**: no
- **Prompt**: |
    Create a self-contained bash test script at `.claude/hooks/test-hooks.sh` that
    validates the agent attribution changes to both hook scripts.

    ## Test Approach

    - Pure bash, no external test framework (project uses no test infrastructure)
    - Create an isolated temp directory per test run
    - Pipe crafted JSON payloads into each hook via stdin
    - Assert on file contents (ledger), exit codes, and stderr output
    - Clean up completely afterward
    - Use a pass/fail counter pattern

    ## Test Cases for track-file-changes.sh

    **Core agent metadata extraction:**

    | # | Test Case | Input | Expected |
    |---|-----------|-------|----------|
    | 1 | Both agent_type and agent_id present | JSON with agent_type="frontend-minion", agent_id="sub-abc123" | Ledger line: `path\tfrontend-minion\tsub-abc123` |
    | 2 | agent_type present, agent_id absent | JSON with agent_type="nefario" only | Ledger line: `path\tnefario` |
    | 3 | Neither field present | JSON with only file_path | Ledger line: bare `path` (no tabs) |
    | 4 | Fields are null | agent_type=null, agent_id=null | Same as absent |
    | 5 | Fields are empty strings | agent_type="", agent_id="" | Same as absent |

    **Validation tests:**

    | # | Test Case | Input | Expected |
    |---|-----------|-------|----------|
    | 6 | agent_type with shell metacharacters | agent_type="; rm -rf /" | agent_type cleared (bare path written) |
    | 7 | agent_type with newlines | agent_type="foo\nbar" | agent_type cleared |
    | 8 | agent_type exceeding 64 chars | agent_type=<65 char string> | agent_type cleared |
    | 9 | agent_type with spaces | agent_type="my agent" | agent_type cleared |

    **Deduplication tests:**

    | # | Test Case | Expected |
    |---|-----------|----------|
    | 10 | Same path, same agent -- written twice | One entry in ledger |
    | 11 | Same path, different agents | Two entries in ledger |
    | 12 | Same path, one with agent, one without | Two entries in ledger |

    **Regression tests (existing behavior preserved):**

    | # | Test Case | Expected |
    |---|-----------|----------|
    | 13 | file_path extraction works | Path in ledger |
    | 14 | Empty file_path | No entry, exit 0 |
    | 15 | Path with newlines rejected | No entry, exit 0 |
    | 16 | Hook always exits 0 | Even on jq parse failure |

    ## Test Cases for commit-point-check.sh

    Testing the Stop hook is more complex because it interacts with git.
    Focus on the ledger parsing and scope derivation logic. Mock git where
    needed by creating a temp git repo.

    **TSV parsing tests:**

    | # | Test Case | Expected |
    |---|-----------|----------|
    | 17 | TSV ledger with agent metadata | Scope in checkpoint message |
    | 18 | Mixed format (old bare paths + new TSV) | Handles both gracefully |
    | 19 | Legacy format only (no tabs) | Works as before (no scope) |

    **Scope derivation tests:**

    | # | Test Case | Expected |
    |---|-----------|----------|
    | 20 | Single agent_type | Scope = agent_type with -minion stripped |
    | 21 | Multiple agent_types, clear majority | Scope = majority agent |
    | 22 | All entries without agent_type | No scope in message |

    **Agent trailer test:**

    | # | Test Case | Expected |
    |---|-----------|----------|
    | 23 | Agent metadata present | Agent: trailer in checkpoint |

    ## Implementation Notes

    - The test script must be `chmod +x`
    - Use `set -euo pipefail` but catch expected failures explicitly
    - For commit-point-check.sh tests, create a temp git repo with:
      ```bash
      git init /tmp/test-repo && cd /tmp/test-repo
      git commit --allow-empty -m "initial"
      git checkout -b test-branch
      ```
    - Set CLAUDE_SESSION_ID to a test value to control ledger filenames
    - Clean up ALL temp files and directories in a trap
    - Print results as: `PASS: <test name>` or `FAIL: <test name> -- <reason>`
    - Exit with count of failures (0 = all pass)

    ## What NOT to Do

    - Do NOT use bats-core, shunit2, or any test framework
    - Do NOT add CI integration
    - Do NOT test git push, PR creation, or anything beyond the hook scripts
    - Do NOT test the nefario orchestration flow

    ## Deliverables

    `.claude/hooks/test-hooks.sh` -- executable test script

    ## Context

    The hooks are at `.claude/hooks/track-file-changes.sh` and
    `.claude/hooks/commit-point-check.sh`. Read them to understand the exact
    function signatures and flow before writing tests. The ERR trap in
    track-file-changes.sh means failures are silently swallowed -- the tests
    are the only safety net for catching extraction bugs.
- **Deliverables**: `.claude/hooks/test-hooks.sh`
- **Success criteria**: All 23 test cases pass. Script runs in <10 seconds. Zero external dependencies. Clean temp directory cleanup.

### Task 4: Update commit-workflow.md
- **Agent**: software-docs-minion
- **Delegation type**: standard
- **Model**: sonnet
- **Mode**: default
- **Blocked by**: Task 2
- **Approval gate**: no
- **Prompt**: |
    Update `docs/commit-workflow.md` to reflect the new agent attribution
    in the commit workflow. Two sections need changes: Section 5 (Commit
    Message Convention) and Section 6 (File Change Tracking).

    ## Section 5: Commit Message Convention

    ### Current format blocks

    **Single-agent sessions:**
    ```
    <type>: <summary>

    Co-Authored-By: Claude <noreply@anthropic.com>
    ```

    **Orchestrated sessions:**
    ```
    <type>(<scope>): <summary>

    Co-Authored-By: Claude <noreply@anthropic.com>
    ```

    ### New format blocks

    **Single-agent sessions (with --agent flag):**
    ```
    <type>(<scope>): <summary>

    Agent: <agent-name>
    Co-Authored-By: Claude <noreply@anthropic.com>
    ```

    **Single-agent sessions (without --agent flag):**
    ```
    <type>: <summary>

    Co-Authored-By: Claude <noreply@anthropic.com>
    ```

    **Orchestrated sessions:**
    ```
    <type>(<scope>): <summary>

    Agent: <primary-agent>
    Co-Authored-By: Claude <noreply@anthropic.com>
    ```

    ### Add a new subsection: Scope Derivation

    After the format blocks, add:

    ```markdown
    ### Scope Derivation

    In orchestrated sessions and single-agent sessions with `--agent`, the scope
    is derived from the `agent_type` field in hook events (available since Claude
    Code 2.1.69):

    1. Strip the `-minion` suffix: `frontend-minion` -> `frontend`
    2. Use the result as the conventional commit scope

    When a commit contains files from multiple agents, use the agent that authored
    the majority of files (majority-wins rule). When no agent metadata is available,
    omit the scope or use heuristic inference from the session context.

    The `Agent:` git trailer carries the full agent name (e.g., `frontend-minion`)
    for forensic attribution. This is distinct from the `Co-Authored-By` trailer,
    which remains `Claude <noreply@anthropic.com>` to keep all AI contributions
    grouped in `git shortlog` and GitHub contributor graphs.
    ```

    ## Section 6: File Change Tracking

    ### Ledger Interface

    Change from:
    > The ledger is a plain text file, one absolute file path per line.

    To:
    > The ledger is a TSV (tab-separated values) file. Each line contains an
    > absolute file path, optionally followed by agent metadata:
    >
    > ```
    > <file_path>[\t<agent_type>[\t<agent_id>]]
    > ```
    >
    > When `agent_type` and `agent_id` are absent from the hook input (main
    > session without `--agent`), only the bare file path is written. This makes
    > the new format a strict superset of the old format.

    ### PostToolUse Hook code example

    Update the simplified code example in Section 6 to show the TSV format:

    ```bash
    #!/usr/bin/env bash
    # PostToolUse hook: Track file changes with agent attribution
    # Writes TSV: file_path[\tagent_type[\tagent_id]]

    set -euo pipefail

    LEDGER="/tmp/claude-change-ledger-${CLAUDE_SESSION_ID}.txt"
    input=$(cat)
    file_path=$(echo "$input" | jq -r '.tool_input.file_path // empty' 2>/dev/null)
    agent_type=$(echo "$input" | jq -r '.agent_type // empty' 2>/dev/null)
    agent_id=$(echo "$input" | jq -r '.agent_id // empty' 2>/dev/null)

    if [[ -n "$file_path" ]]; then
        if [[ -n "$agent_type" ]]; then
            printf '%s\t%s\t%s\n' "$file_path" "$agent_type" "$agent_id" >> "$LEDGER"
        else
            echo "$file_path" >> "$LEDGER"
        fi
    fi

    exit 0
    ```

    ### Lifecycle table

    Update the PostToolUse rows in the Lifecycle table:
    - "PostToolUse (Write)" -> "Append file path and agent metadata (if available) to the ledger."
    - "PostToolUse (Edit)" -> "Append file path and agent metadata (if available) to the ledger."

    ## What NOT to Do

    - Do NOT change Sections 1-4, 7-10 unless a reference to the ledger format
      or commit message format is broken by the changes above.
    - Do NOT add a full scope mapping table with all 27 agents. The suffix-stripping
      rule is the specification.
    - Do NOT change the Co-Authored-By trailer. It stays as `Claude <noreply@anthropic.com>`.

    ## Deliverables

    Updated `docs/commit-workflow.md` Sections 5 and 6.

    ## Context

    Read the current file at `docs/commit-workflow.md` to see the exact text.
    The changes are limited to Sections 5 and 6. Section 5 is the commit message
    format. Section 6 is the ledger interface and PostToolUse hook.
- **Deliverables**: Updated `docs/commit-workflow.md`
- **Success criteria**: Sections 5 and 6 accurately describe the new TSV format, scope derivation, and Agent trailer. Existing content in other sections is unchanged unless directly referencing the modified formats.

### Task 5: Update SKILL.md auto-commit instructions and related docs
- **Agent**: software-docs-minion
- **Delegation type**: standard
- **Model**: sonnet
- **Mode**: default
- **Blocked by**: Task 4
- **Approval gate**: no
- **Prompt**: |
    Update the nefario orchestration skill and supporting documentation to
    reflect the new agent attribution in the commit workflow.

    ## Files to Update

    ### 1. skills/nefario/SKILL.md -- Auto-commit format

    In the Phase 4 auto-commit instructions (around lines 1790-1802), update:

    Current:
    ```
    4. Stage and commit (`git commit --quiet`) with conventional commit message:
       `<type>(<scope>): <summary>` with
       `Co-Authored-By: Claude <noreply@anthropic.com>`
    ```

    New:
    ```
    4. Stage and commit (`git commit --quiet`) with conventional commit message:
       `<type>(<scope>): <summary>` with trailers:
       `Agent: <agent-name>` (when agent metadata is available in the change ledger)
       `Co-Authored-By: Claude <noreply@anthropic.com>`
       The scope is derived from the agent_type in the change ledger by stripping
       the `-minion` suffix (e.g., `frontend-minion` -> `frontend`). When reading
       file paths from the ledger for staging, extract column 1 only (the ledger
       uses TSV format: `file_path[\tagent_type[\tagent_id]]`). When multiple
       agents contributed files, use the majority agent's scope.
    ```

    Also update any wrap-up auto-commit references to include the same format.

    ### 2. docs/commit-workflow-security.md -- Input validation

    Add a new subsection after Section 1 (or within it):

    ```markdown
    ### Input Validation for Agent Metadata

    The PostToolUse hook extracts `agent_type` and `agent_id` from the hook
    event JSON (added in Claude Code 2.1.69). These values are validated with
    regex: `^[a-zA-Z0-9_-]{1,64}$`. Values failing validation are silently
    discarded (the file path is still recorded).

    **`agent_type` is informational metadata, not a security control.** It must
    never be used for authorization decisions (e.g., "only security-minion can
    edit sensitive files"). The value is self-reported by the Claude Code runtime
    and is not cryptographically authenticated.

    The `agent_type` flows into commit message scopes and git trailers. The regex
    validation ensures it contains only safe characters (alphanumeric, hyphens,
    underscores), preventing shell injection and git trailer injection.
    ```

    ### 3. domains/software-dev/DOMAIN.md -- Commit Conventions

    Find the `Co-Authored-By` trailer specification (around line 389) and add
    the Agent trailer:

    ```markdown
    Agent: <agent-name>
    Co-Authored-By: Claude <noreply@anthropic.com>
    ```

    Note that the Agent trailer is optional (only present when agent metadata
    is available).

    ### 4. docs/deployment.md -- Hook description

    Update the track-file-changes.sh description from:
    > "Appends modified file paths to a session-scoped change ledger."

    To:
    > "Appends modified file paths (with optional agent metadata) to a session-scoped change ledger in TSV format."

    ### 5. docs/decisions.md -- New decision entry

    Add a new decision entry documenting the agent attribution format choice:

    ```markdown
    ### Decision NN: Agent attribution in commit messages

    **Context**: Claude Code 2.1.69 added `agent_type` and `agent_id` to hook
    events. We needed to decide how to surface this in commit attribution.

    **Decision**: Use domain-derived scopes (suffix-stripping) in the conventional
    commit scope position, and an `Agent:` git trailer for full agent identity.
    The `Co-Authored-By` trailer remains `Claude <noreply@anthropic.com>`.

    **Alternatives rejected**:
    - Agent names as commit scope (e.g., `feat(frontend-minion): ...`) -- degraded
      git log scanning with 27 long scope values.
    - Separate metadata sidecar file -- added synchronization complexity without
      security benefit.
    - Agent-specific Co-Authored-By -- fragmented `git shortlog` into 27 buckets.

    **Consequences**: The change ledger format changes from bare paths to TSV.
    Readers must handle both formats during transition.
    ```

    ## What NOT to Do

    - Do NOT modify the orchestration workflow logic or phase structure in SKILL.md
    - Do NOT change any other SKILL.md content beyond the auto-commit format references
    - Do NOT rewrite docs/commit-workflow-security.md -- only add the new subsection
    - Do NOT update docs/orchestration.md (it only references the ledger by link, no format details)
    - Verify the decision number -- read docs/decisions.md to find the current last decision number and increment by 1

    ## Deliverables

    Updated: `skills/nefario/SKILL.md`, `docs/commit-workflow-security.md`,
    `domains/software-dev/DOMAIN.md`, `docs/deployment.md`, `docs/decisions.md`

    ## Context

    Read each file before editing. The SKILL.md auto-commit instructions are
    around lines 1790-1802. The commit-workflow-security.md Section 1 covers
    input validation. The DOMAIN.md commit conventions section has the
    Co-Authored-By line.
- **Deliverables**: Updated SKILL.md, commit-workflow-security.md, DOMAIN.md, deployment.md, decisions.md
- **Success criteria**: All five files updated consistently. Agent trailer and TSV format documented. New decision entry added with correct numbering.

---

### Cross-Cutting Coverage

- **Testing**: Task 3 (test-minion creates hook test script). Phase 6 will run the tests post-execution.
- **Security**: security-minion's recommendations are incorporated into Task 1 (regex validation, file permission hardening) and Task 5 (security doc update). security-minion reviews in Phase 3.5.
- **Usability -- Strategy**: ux-strategy-minion's analysis drove the core design decision (domain scopes + trailers over agent scopes). Reviews in Phase 3.5.
- **Usability -- Design**: Not applicable. No UI components are produced. The commit message format is a CLI/text interface reviewed by ux-strategy-minion.
- **Documentation**: Tasks 4 and 5 (software-docs-minion updates all affected documentation). Phase 8 handles any remaining documentation.
- **Observability**: Not applicable. No runtime services, APIs, or background processes are created. The hooks are ephemeral shell scripts with no logging/metrics needs.

### Architecture Review Agents

- **Mandatory** (5): security-minion, test-minion, ux-strategy-minion, lucy, margo
- **Discretionary picks**:
  - None selected. The plan produces no UI components (excludes ux-design-minion, accessibility-minion), no web-facing runtime code (excludes sitespeed-minion), no runtime services needing coordinated observability (excludes observability-minion), and no end-user-facing changes (excludes user-docs-minion -- the changes affect developer-facing commit messages, documented by software-docs-minion).
- **Not selected**:
  - ux-design-minion: No UI components produced. Commit messages are text, not visual interfaces.
  - accessibility-minion: No web-facing HTML/UI produced.
  - sitespeed-minion: No web-facing runtime code produced.
  - observability-minion: No runtime services produced. Hooks are ephemeral scripts.
  - user-docs-minion: Changes affect developer commit workflow, not end-user experience. software-docs-minion covers all documentation.

### Decisions

- **Ledger format: TSV vs. sidecar**
  Chosen: TSV inline format (tab-separated columns in existing ledger file)
  Over: Separate metadata sidecar file (security-minion's preference)
  Why: KISS principle. TSV is a backward-compatible superset of the current format. Sidecar adds file synchronization complexity (two files to manage, race conditions) without security benefit beyond what regex validation provides.

- **Scope attribution: agent names vs. domain scopes**
  Chosen: Domain scopes via suffix-stripping in commit subject + Agent: trailer for full identity
  Over: Raw agent names in commit scope position (ai-modeling-minion's initial framing, opposed by ux-strategy-minion)
  Why: 27 agent names as scopes degrades git log scanning (Hick's Law, compound names, 10% character budget on noise). Progressive disclosure: domain at scan level, agent identity in trailer. Suffix-stripping is zero-maintenance.

- **Deduplication granularity**
  Chosen: Deduplicate on (file_path, agent_type) tuple in the PostToolUse hook; deduplicate on file_path only in the Stop hook
  Over: Deduplicate on file_path only everywhere (current behavior)
  Why: The PostToolUse hook records attribution history (same file from different agents = two entries). The Stop hook stages files for commit (each file once regardless of how many agents touched it). Different dedup rules for different consumers.

### Risks and Mitigations

1. **agent_type format stability (Medium)**: The field comes from Claude Code runtime and has no versioning guarantee. Suffix-stripping degrades gracefully -- if the suffix is absent, the full value becomes the scope. Regex validation prevents malformed values from breaking downstream consumers.

2. **Shell injection via agent_type (Medium)**: Mitigated by regex validation (`^[a-zA-Z0-9_-]{1,64}$`) that rejects all shell metacharacters, newlines, tabs. Failing open (clearing to empty) ensures the hook never blocks.

3. **ERR trap masking extraction failures (Medium)**: The ERR trap in track-file-changes.sh silently swallows all errors. A bug in agent_type extraction would produce bare-path entries with no visible error. Mitigated by test script (Task 3) which is the only safety net.

4. **Co-Authored-By specification drift (Low)**: The trailer is specified in 4 locations (commit-workflow.md, SKILL.md, DOMAIN.md, commit-point-check.sh). Task 5 updates all locations. Future drift risk remains but is a pre-existing concern, not introduced by this change.

5. **Mixed-format ledger during transition (Low)**: If hooks are upgraded mid-session, the ledger may contain both bare paths and TSV lines. Both readers (PostToolUse dedup and Stop hook parsing) handle this by treating bare paths as single-column TSV with empty metadata. No migration logic needed.

### Execution Order

```
Batch 1 (parallel: none -- sequential start):
  Task 1: track-file-changes.sh (devx-minion)

Batch 2 (blocked by Task 1):
  Task 2: commit-point-check.sh (devx-minion) [APPROVAL GATE]

-- Gate: Commit message format review --

Batch 3 (blocked by Task 2 gate):
  Task 3: test-hooks.sh (test-minion)
  Task 4: commit-workflow.md (software-docs-minion)

Batch 4 (blocked by Task 4):
  Task 5: SKILL.md + supporting docs (software-docs-minion)

Post-execution:
  Phase 5: Code review (code-review-minion, lucy, margo)
  Phase 6: Test execution (run test-hooks.sh)
  Phase 8: Documentation review
```

### External Skills

No external skills detected in project.

### Verification Steps

1. Run `.claude/hooks/test-hooks.sh` -- all 23 test cases pass.
2. Manual smoke test: start a Claude Code session with `--agent nefario`, make a file edit, verify the ledger contains TSV entries.
3. Verify the commit checkpoint message includes the domain scope and Agent trailer.
4. Verify bare-path ledger entries (from sessions without `--agent`) still work correctly.
5. Verify `git log --format='%(trailers:key=Agent)'` can extract agent attribution from commits.
6. Grep all updated docs for consistency: `Co-Authored-By` appears identically in all locations.
