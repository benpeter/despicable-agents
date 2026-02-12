## Domain Plan Contribution: ux-strategy-minion

### Recommendations

#### 1. No Confirmation Needed -- Explicit Invocation Is Consent

The user types `/despicable-statusline` deliberately. This is not an ambient or automatic action. Asking "Are you sure?" before modifying settings adds friction to a flow where intent is already unambiguous. Applying Nielsen's heuristic of user control: the skill should act immediately, but make the action easily reversible (show the user what was done and how to undo it).

**No preview, no confirmation gate.** Act on invocation. Report the outcome.

This mirrors the existing skill patterns: `/despicable-prompter` produces output immediately on first response (Core Rule 1). `/session-review` writes documentation immediately. The established convention in this skill ecosystem is "invoke = execute."

#### 2. Outcome Communication: Two States, Two Messages

The skill has exactly two outcomes. Each needs a distinct, minimal message.

**Success (config modified):**
```
Status line updated.
  Added: nefario orchestration status
  Config: ~/.claude/settings.json

To revert, remove the nefario snippet from your statusLine command in settings.json.
```

**No-op (already configured):**
```
Status line already includes nefario status. No changes made.
```

Rationale:
- Success message confirms what changed (visibility heuristic), names the file touched (helps with mental model of where config lives), and provides a revert path (user control heuristic).
- No-op message is a single line. Don't over-explain when nothing happened. The user's mental model is "I wanted nefario status" and the answer is "you already have it." Done.
- Both messages avoid cluttering with technical details about the shell command. The user doesn't need to see the `jq` pipeline -- they need to know the job is done.

#### 3. Default StatusLine for Users Without One

This is the most consequential UX decision in the skill. The default must satisfy two constraints:

1. **Be genuinely useful** -- a user who had no statusline probably didn't know about the feature or didn't care enough to set one up. The default should demonstrate value without overwhelming.
2. **Be conservative** -- this skill's job is adding nefario status. Creating an opinionated "full-featured" statusline is scope creep that risks annoying users who would have chosen differently.

**Recommended default elements, in order:**

| Element | Rationale | Priority |
|---------|-----------|----------|
| `$dir` (current directory basename) | Orientation -- "where am I?" is the most fundamental question | Must-be (Kano) |
| `$model` (model display name) | Awareness -- model affects behavior and cost; users should always know | Must-be |
| `Context: N%` | Resource awareness -- prevents surprise compaction | Performance |
| `$ns` (nefario status) | The reason this skill exists | Performance |

This gives: `myproject | Sonnet | Context: 42% | META-PLAN: config skill...`

**Why these four and not more:**
- **Cost tracking**: Omitted. Users who want cost tracking will set it up themselves or use `/statusline`. Adding it to a default created by an unrelated skill overreaches.
- **Git branch**: Omitted. Useful but expensive (spawns subprocess) and not universal (not all projects use git). Users in git-heavy workflows will have configured this themselves.
- **Session ID**: Omitted. Internal plumbing, not user-facing value. The current config writes session ID to `/tmp/claude-session-id` as a side effect -- that's infrastructure, not status display.

The session ID side-effect write (`echo "$sid" > /tmp/claude-session-id`) IS needed for nefario to work (it reads this file). The default statusline must include this infrastructure silently even though it doesn't display the session ID. This is invisible computing done right -- the mechanism serves the user's goal (nefario works) without demanding attention.

#### 4. User Journey Map

The journey is short enough to describe linearly:

```
PHASE: Invocation
  Action: User types /despicable-statusline
  Mindset: "I want nefario phase info in my status bar"
  Emotion: Neutral (task-oriented)

PHASE: Execution (invisible, <1 second)
  Action: Skill reads settings.json, detects state, modifies or skips
  Mindset: N/A (user is not involved)
  Emotion: N/A

PHASE: Outcome
  Action: Skill reports what happened
  Mindset: "Did it work? Do I need to do anything else?"
  Emotion: Satisfied (if clear confirmation) / Confused (if verbose or ambiguous)

PHASE: Verification (optional, user-driven)
  Action: User continues working; sees status line on next Claude response
  Mindset: "Is it showing up?"
  Emotion: Satisfied (nefario status appears) / Confused (nothing visible yet because no orchestration is running)
```

**Critical moment**: The verification phase. After the skill runs, the nefario status element will be empty/invisible unless an orchestration is actively running. The user might think it didn't work. The success message should preempt this:

```
Status line updated.
  Added: nefario orchestration status
  Config: ~/.claude/settings.json

The nefario status appears during /nefario orchestration sessions.
Outside orchestration, it is hidden.
```

This one additional line eliminates the most likely source of post-action confusion.

#### 5. Idempotency Detection

The skill must detect whether the nefario snippet is already present. The detection should be based on the functional signature, not exact string matching. The nefario snippet's distinguishing feature is reading from `/tmp/nefario-status-$sid` (or equivalent). Check for the presence of `nefario-status` in the command string. This is robust against minor reformatting while being specific enough to avoid false positives.

Do NOT attempt to parse the shell command semantically. String containment check (`nefario-status` appears in the command value) is the right level of precision. Trying to be smarter adds complexity for zero user benefit.

#### 6. Preserving Existing Config: The Cardinal Rule

The user's current statusLine command is a carefully constructed shell one-liner. It already includes the nefario snippet (the user built it manually). For users who DON'T have it yet, the skill must append without rewriting.

**Approach**: Read the existing `command` string. If it contains the nefario-status pattern, no-op. If not, append the nefario snippet to the end of the existing command's output pipeline. The existing command structure varies (inline vs. script file), so the skill must handle both.

For script-file configs (`"command": "~/.claude/statusline.sh"`), the skill faces a harder problem: it needs to modify a separate file. Recommendation: **only modify inline commands**. For script-file configs, print instructions instead of modifying the user's script:

```
Your status line uses an external script: ~/.claude/statusline.sh

To add nefario status, append this to your script's output:

  f="/tmp/nefario-status-$sid"; [ -n "$sid" ] && [ -f "$f" ] && ns=$(cat "$f" 2>/dev/null) && [ -n "$ns" ] && result="$result | $ns"

(Where $sid is the session_id from the JSON input and $result is your output variable.)
```

This respects the user's ownership of their script while still being helpful. Modifying arbitrary user scripts is a boundary violation that risks breaking customizations.

### Proposed Tasks

#### Task 1: Implement the `/despicable-statusline` Skill

**What to do**: Create `SKILL.md` for the despicable-statusline skill following the established pattern (YAML frontmatter + system prompt). The skill should:

1. Read `~/.claude/settings.json`
2. Check for existing `statusLine` config
3. Branch on three states:
   - **State A**: No statusLine configured -> Create default with nefario snippet
   - **State B**: Inline statusLine without nefario snippet -> Append nefario snippet
   - **State C**: StatusLine already has nefario snippet -> No-op
   - **State D**: Script-file statusLine -> Print manual instructions
4. Output the appropriate outcome message

**Deliverables**: `SKILL.md` in the skill directory

**Dependencies**: None

#### Task 2: Define Default StatusLine Command

**What to do**: Write the default statusLine shell command for users who have none. Elements: dir, model, context%, session-id-write (silent), nefario-status. Follow the pattern established by the user's current config (inline jq-based parsing). Ensure the command:
- Reads stdin JSON correctly
- Handles null/missing fields gracefully (fallback defaults)
- Writes session ID to `/tmp/claude-session-id` (infrastructure, not displayed)
- Appends nefario status only when the file exists and is non-empty

**Deliverables**: Shell command string ready for embedding in settings.json

**Dependencies**: Task 1 (the SKILL.md references this command)

#### Task 3: Define Nefario Snippet for Append

**What to do**: Write the minimal shell snippet that can be appended to any existing inline statusLine command. This snippet must:
- Read the session ID (from the already-parsed JSON or from `/tmp/claude-session-id`)
- Check for `/tmp/nefario-status-$sid`
- If present and non-empty, append ` | $ns` to the output
- Be self-contained enough to append to diverse existing commands

**Deliverables**: Shell snippet string

**Dependencies**: Task 1

### Risks and Concerns

#### Risk 1: JSON Corruption (HIGH severity, LOW probability)

Writing to `settings.json` risks malforming the JSON if the skill uses string manipulation instead of proper JSON parsing. A corrupted settings.json breaks Claude Code entirely.

**Mitigation**: The skill's system prompt should instruct Claude to use the Edit tool (which handles JSON correctly) rather than Bash-level string manipulation. Alternatively, read with `jq`, modify, and write back -- but only if `jq` is available. A fallback that warns and stops is better than a fallback that corrupts.

#### Risk 2: Script-File Configs (MEDIUM severity, MEDIUM probability)

Users whose statusLine points to an external script file cannot be handled with the same append logic. Attempting to modify an arbitrary user script risks breaking their customizations.

**Mitigation**: Detect script-file configs and provide manual instructions instead. This is the right trade-off: cover the common case (inline commands) automatically, handle the edge case (script files) gracefully with guidance.

#### Risk 3: Session ID Dependency (MEDIUM severity, LOW probability)

The nefario snippet depends on `$sid` being available (extracted from the session JSON). If the user's existing statusLine doesn't extract `session_id`, the appended snippet won't work. The default handles this, but the append case for existing configs may not.

**Mitigation**: The append snippet should be self-contained -- it should extract session_id from the JSON input independently, not rely on variables from the existing command. This may require restructuring the snippet to re-read stdin (which is already consumed). Alternatively, the snippet can read from `/tmp/claude-session-id` (which the existing statusLine or nefario writes). The current user config already writes this file, so it's available. But other users' configs may not. The safest approach: the snippet reads from `/tmp/claude-session-id` AND the skill ensures that the session-id-write infrastructure is present in the statusLine.

#### Risk 4: Post-Invocation Confusion (LOW severity, HIGH probability)

After the skill runs successfully, the nefario status element is invisible (no orchestration running). Users may think the skill failed. This is a classic system status visibility problem.

**Mitigation**: The success message explicitly states that nefario status only appears during `/nefario` orchestration sessions. This preventive communication eliminates the confusion before it occurs.

#### Risk 5: Existing Inline Command Fragility (MEDIUM severity, MEDIUM probability)

Appending to an existing inline command assumes the command ends with an `echo "$result"` pattern or similar. If the user's command has a different structure (e.g., piping through `sed`, using `printf`, or having multiple echo statements for multi-line output), the append may produce incorrect output.

**Mitigation**: The skill should validate that the existing command contains a recognizable output pattern before appending. If the pattern is not recognized, fall back to providing manual instructions (same as the script-file case). Don't attempt to modify what you don't understand.

### Additional Agents Needed

None. The current team is sufficient. This is a configuration skill with straightforward shell scripting -- the devx-minion and shell-minion domains cover the implementation. UX strategy concerns are addressed in this contribution. No visual design, accessibility, or architecture review is needed for a skill that modifies a JSON config file and prints two possible messages.
