You are adding the `--advisory` flag to the nefario skill's argument parsing
and adding advisory context to phase prompts.

## What to Do

Edit `/Users/ben/github/benpeter/2despicable/2/skills/nefario/SKILL.md` with these changes:

**Change 1: Update frontmatter argument-hint** (line 9)

Change:
```yaml
argument-hint: "#<issue> | <task description>"
```
To:
```yaml
argument-hint: "[--advisory] #<issue> | <task description>"
```

**Change 2: Update Arguments declaration** (line 25)

Change:
```
Arguments: `#<issue> | <task description>`
```
To:
```
Arguments: `[--advisory] #<issue> | <task description>`
```

**Change 3: Add Flag Extraction subsection** after the Arguments declaration
(line 25) and before the first bullet (line 27 starting with `- **`#<n>`**`). Insert:

```markdown
### Flag Extraction

Before parsing the task input, extract flags from the argument string:

- **`--advisory`**: If present anywhere in the input, remove it from the
  argument string and set `advisory-mode: true` in session context. The
  remaining string (after flag removal and whitespace trimming) is parsed
  normally as `#<issue>` or free text.

Flag extraction is position-independent: `/nefario --advisory #87`,
`/nefario #87 --advisory`, and `/nefario --advisory fix the auth flow`
are all valid. The flag is consumed before issue/text parsing begins.

If `--advisory` appears inside a `<github-issue>` tag (fetched issue body),
it is NOT treated as a flag -- the content boundary rule applies. Only
flags in the top-level argument string are extracted.
```

**Change 4: Add advisory exception to Core Rules** (after line 21)

After the existing two Core Rules lines (lines 20-21), add:

```markdown
When `advisory-mode` is active, the workflow comprises Phases 1-3 and Advisory
Wrap-up. Phases 3.5-8 are not applicable. This is the only defined exception
to the "full workflow" rule.
```

**Change 5: Add advisory context to Phase 2 specialist prompt**

In the Phase 2 section, find the specialist prompt template. After the
closing of the instructions list (after item 6 that says "Write your complete
contribution to..."), add a conditional block:

```markdown
When `advisory-mode` is active, also include in each specialist's prompt:

    ## Advisory Context
    This is an advisory-only orchestration. Your contribution will feed
    into a team recommendation, not an execution plan. Focus on analysis,
    trade-offs, and recommendations rather than implementation tasks.
```

**Change 6: Add ADV prefix to status lines**

Find the first status line write in Phase 1 (the `echo "⚗︎ P1 Meta-Plan | $summary"` line).
Add immediately after that echo command block:

```markdown
When `advisory-mode` is active, prefix the phase label with `ADV `:
- Phase 1: `echo "⚗︎ ADV P1 Meta-Plan | $summary" > /tmp/nefario-status-$SID`
- Phase 2: `echo "⚗︎ ADV P2 Planning | $summary" > /tmp/nefario-status-$SID`
- Phase 3: `echo "⚗︎ ADV P3 Synthesis | $summary" > /tmp/nefario-status-$SID`
```

## What NOT to Do
- Do not modify Phase 3 synthesis prompt (that is Task 3)
- Do not add advisory termination or wrap-up sections (that is Task 3)
- Do not modify the report template (that is Task 4)
- Do not add MODE: ADVISORY -- the flag sets `advisory-mode` in session context;
  AGENT.md uses `ADVISORY: true` in the synthesis prompt (different layer)
- Do not modify `the-plan.md`

## Context
- devx-minion designed this flag parsing approach
- Position-independent parsing follows principle of least surprise
- The `<github-issue>` exemption prevents content injection
- Phase 1 meta-plan prompt does NOT get advisory context (per ai-modeling-minion:
  "who should weigh in" is the same for advisory and execution)
- Phase 2 advisory context is a brief 3-line note, not a structural change
- These changes add ~40-50 lines to SKILL.md

## Deliverables
- Modified `skills/nefario/SKILL.md` with flag parsing, core rules exception,
  Phase 2 advisory context, and status line prefix

When you finish your task, report:
- File paths with change scope and line counts
- 1-2 sentence summary of what was produced
