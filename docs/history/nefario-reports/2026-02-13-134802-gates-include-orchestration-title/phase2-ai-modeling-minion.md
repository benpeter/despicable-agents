## Domain Plan Contribution: ai-modeling-minion

### Recommendations

#### 1. Use a centralized convention section, not 12 per-gate edits

The SKILL.md is an LLM-executable spec. LLMs follow instructions more reliably
when a rule is stated once as a universal constraint rather than repeated
inline at each call site. A single "AskUserQuestion Convention" section near
the top (after Communication Protocol, before Phase 1) establishes the rule
once, and each gate's spec remains unchanged except where the question text
itself needs restructuring (the post-exec gate and P4 Calibrate gate,
which currently lack any contextual reference).

Why centralized wins over per-gate:
- **DRY**: One definition instead of 12 repetitions. The SKILL.md is already
  ~2000 lines; adding a prefix rule to each gate bloats it further.
- **LLM reliability**: A centralized rule is applied as a "meta-instruction"
  that governs all AskUserQuestion calls. This is the same pattern as the
  `header` max-12-char rule on line 503 -- stated once, applied everywhere.
  The LLM doesn't need to remember 12 local annotations; it applies one
  global rule.
- **Maintenance**: When the convention changes (e.g., different delimiter,
  different variable), one edit instead of twelve.

The risk of a centralized rule is that the LLM "forgets" it by the time it
reaches late-phase gates (P5, PR, Existing PR). This is mitigated by:
- Placing the rule in the same section as the existing `header` max rule
  (the AskUserQuestion note on line 503), which the LLM already follows
  reliably for all gates.
- The rule is concise (2-3 sentences). Short rules have higher adherence.
- A reinforcement line in the compaction checkpoint focus strings ensures
  the convention survives context compaction.

#### 2. Use `$summary` as the run identifier, not `$slug`

The `$summary` variable is already established in Phase 1 (line 389-391),
retained in session context, and used throughout for status files. It is
natural language (up to 40 characters), which is more recognizable at a glance
than the kebab-case `$slug`.

Arguments against `$slug`:
- Slugs are technical identifiers optimized for branch names, not human
  scanning. "gates-include-orchestration-title" is harder to parse at a
  glance than "Include run title in all gates".
- The user already sees `$summary` in the status line. Matching the gate
  identifier to the status line creates consistency across the two places
  the user encounters run identity.

Arguments against a new variable (e.g., `$run_title`):
- Adds a new concept to the spec for zero semantic gain. `$summary` already
  IS the run title. Adding `$run_title` as an alias creates confusion about
  which to use and when they diverge.
- The LLM must track one more variable in session context through compaction
  boundaries.

Recommendation: Use `$summary` directly. The convention should refer to it
by the name already established in the spec.

#### 3. Use a prefix pattern with a consistent delimiter

Format: `[$summary] <gate-specific question>`

Why prefix over suffix:
- The run title is the disambiguator. In parallel sessions, the user's first
  cognitive task is "which run is this?" The prefix answers that before
  they read the question content.
- Terminal prompts are left-aligned. The prefix is always visible even if the
  question wraps.
- Consistent with how the status line works: `P4 Execution | $summary`
  puts the identifier on the same line as the phase context.

Why square brackets:
- Visually distinct delimiter that doesn't conflict with any existing
  question content (no current gate uses square brackets).
- Universally understood as "contextual label" in terminal/CLI conventions.
- More reliable for LLM generation than pipes (`|`) which could be confused
  with the status file pipe delimiter, or parens which appear in option
  descriptions.

Why not a pipe delimiter (matching status line):
- The `question` field is rendered as a user-facing prompt, not a status
  line. The status line convention `Phase | Summary` is an internal format.
  Gate questions are natural language. `[Run Title]` prefix reads as a
  contextual label; `Run Title | question` reads as two separate fields,
  which is confusing in the longer question strings.

#### 4. Convention specification text

Add this immediately after the existing AskUserQuestion note on line 503-504:

```markdown
> **Run-title convention**: Every AskUserQuestion `question` field must begin
> with `[$summary]` followed by a space. This ensures the user can identify
> which orchestration run a gate belongs to, even when the status line is
> hidden. The `$summary` value is established in Phase 1 (max 40 characters).
> Gates that already include task-level context (e.g., P4 Gate's
> "Task N: <task title>") prepend the run title before the existing content.
```

This is 5 lines. It references the existing `$summary` variable, places itself
next to the existing `header` constraint, and provides a concrete example of
how it interacts with already-complex question strings.

#### 5. Per-gate adjustments needed (minimal)

Most gates need zero spec changes beyond the centralized rule. The LLM will
apply the prefix convention to whatever the current `question` spec says.
However, two gates need their spec text updated because their current
`question` values have no contextual content at all:

1. **Post-exec gate** (line 1477): Change from
   `"Post-execution phases for this task?"` to
   `"[$summary] Task N: <task title> -- post-execution phases?"`
   This gate currently has ZERO context. The convention adds the run title,
   but this gate also needs the task title since it follows a P4 Gate and
   the user needs to know which task's post-execution is being configured.

2. **P4 Calibrate gate** (line 1541): Change from
   `"5 consecutive approvals without changes. Gates well-calibrated?"` to
   have the `[$summary]` prefix applied. The existing text is self-describing
   enough; the prefix is sufficient.

All other gates have sufficient question text that the centralized prefix
rule is unambiguous to apply.

#### 6. Compaction survival

Add `$summary` to the compaction checkpoint focus strings. The Phase 3
compaction focus string (line 811) should include `$summary` in its preserve
list. The Phase 3.5 compaction focus string (if it exists) similarly.

This is critical: if `$summary` is compacted away, the LLM will either
hallucinate a value or omit the prefix entirely. Both are worse than the
current state.

Check: `$summary` is already implicitly preserved because it's used in
status file writes throughout, but making it explicit in the compaction
focus string is cheap insurance.

#### 7. Reinforcement via the status file pattern

The status file writes already use `$summary` at every phase transition:
```sh
echo "P4 Execution | $summary" > /tmp/nefario-status-$SID
```

This means the LLM encounters `$summary` repeatedly as it progresses
through phases. The AskUserQuestion convention piggybacks on this existing
reinforcement -- every time the LLM writes a status file, it is reminded
of `$summary`, and the next gate call site will naturally include it.

This is not a coincidence to exploit; it is a genuine prompt engineering
advantage of reusing `$summary` over introducing a new variable.

### Proposed Tasks

#### Task 1: Add centralized AskUserQuestion run-title convention

**What**: Add a run-title convention note to SKILL.md immediately after the
existing AskUserQuestion note block (lines 501-504). The note specifies that
every `question` field must begin with `[$summary] `.

**Deliverable**: Updated SKILL.md with the convention note (5 lines added).

**Dependencies**: None. This is the foundational change.

#### Task 2: Update the two context-deficient gate specs

**What**: Update the `question` spec for the Post-exec gate and P4 Calibrate
gate to show the `[$summary]` prefix explicitly, because their current specs
have no contextual content that would make the prefix application obvious.

- Post-exec (line 1477): `"[$summary] Task N: <task title> -- post-execution phases?"`
- P4 Calibrate (line 1541): `"[$summary] 5 consecutive approvals without changes. Gates well-calibrated?"`

For completeness, also add the prefix to the Existing PR gate (line 2061)
since its current question is a full literal string that the LLM would
reproduce verbatim rather than prepending to.

**Deliverable**: Three `question` field updates in SKILL.md.

**Dependencies**: Task 1 (convention must be defined before applying it).

#### Task 3: Add `$summary` to compaction checkpoint focus strings

**What**: Ensure `$summary` appears in the preserve list of both compaction
checkpoint focus strings (Phase 3 at line 811, Phase 3.5 at approximately
line 1196).

**Deliverable**: Two compaction focus string updates in SKILL.md.

**Dependencies**: None. Can run in parallel with Task 1.

### Risks and Concerns

1. **Question length in P4 Gate**: The P4 Gate question is already
   `"Task N: <task title> -- DECISION"`. Adding `[$summary] ` prefix
   could make it quite long: `"[Include run title in all gates...] Task 3:
   Update post-exec gate -- Add task-level context to post-execution
   prompt"`. This could wrap awkwardly in narrow terminals. Mitigation:
   `$summary` is capped at 40 chars, and the total is bounded. The devx
   and ux-strategy agents should weigh in on whether this is acceptable
   or whether the P4 Gate specifically should use `$slug` (shorter) instead.

2. **LLM drift in late phases**: Despite the centralized rule, the LLM may
   forget the convention after compaction or in very long sessions. The
   compaction focus string addition (Task 3) mitigates this. There is no
   further enforcement mechanism available within the SKILL.md spec pattern
   -- the spec is instructions, not code. Acceptance criterion: the
   convention is followed in >90% of gates across sessions.

3. **Literal-string gates may not get the prefix**: Some gates specify the
   question as a full literal string (e.g., PR gate: `"Create PR for
   nefario/<slug>?"`). The LLM may reproduce the literal verbatim without
   prepending `[$summary]`. Task 2 addresses the worst cases. For the PR
   gate, the slug provides partial run identity, and the centralized rule
   should cover it. But if testing shows the PR gate is missed, its spec
   should be updated to show the prefix explicitly, same as the post-exec gate.

4. **No runtime enforcement**: The AskUserQuestion tool has no server-side
   validation that `question` starts with `[$summary]`. If the LLM omits it,
   the gate renders without it, and the user has no run context. This is
   inherent to the system -- SKILL.md is a prompt, not a schema. The
   mitigation is prompt engineering (centralized rule + compaction survival +
   reinforcement via status file pattern), not enforcement.

### Additional Agents Needed

None. The devx-minion and ux-strategy-minion (already consulted) cover the
two judgment calls (convention format and information hierarchy). The prompt
engineering analysis in this contribution completes the LLM-reliability
dimension, which is the ai-modeling-minion's domain.
