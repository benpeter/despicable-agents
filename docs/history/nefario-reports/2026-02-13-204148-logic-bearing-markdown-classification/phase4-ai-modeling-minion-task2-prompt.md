You are modifying `skills/nefario/SKILL.md` to fix the Phase 5 code review skip conditional. Currently, nefario skips Phase 5 for changes to AGENT.md, SKILL.md, and RESEARCH.md because they are classified as "docs" based on their .md extension. This is wrong -- these files contain system prompts, orchestration rules, and domain knowledge that directly governs agent behavior.

## What to do

### 1. Replace the Phase 5 skip conditional (line 1670) with classification boundary

Find this line in the Phase 5 section:
```
Skip if Phase 4 produced no code files (only docs/config). Note the skip.
```

Replace it with the following three-part structure (definition, classification table, operational rule):

```markdown
**File classification for phase-skipping**: Logic-bearing markdown files
are treated as code, not documentation. A file is logic-bearing if changing
it alters the runtime behavior of an LLM agent or orchestration workflow.

| File Pattern | Classification | Rationale |
|-------------|---------------|-----------|
| `AGENT.md` in agent/skill directories | Logic-bearing | System prompt -- controls agent behavior |
| `SKILL.md` in skill directories | Logic-bearing | Orchestration workflow -- controls phase logic |
| `RESEARCH.md` in agent directories | Logic-bearing | Domain knowledge backing system prompts |
| `CLAUDE.md` (any location) | Logic-bearing | Project instructions -- controls all agent behavior |
| `README.md`, `docs/*.md`, changelogs | Documentation-only | Informs humans; does not affect agent runtime |

Skip Phase 5 only if ALL files produced by Phase 4 are documentation-only.
If any file is logic-bearing or traditional code, run Phase 5. When
ambiguous, default to running review (false positive cost is one subagent
call; false negative cost is a deployed defect in agent behavior).

Classification labels (logic-bearing, documentation-only) are internal
vocabulary. User-facing output uses outcome language: "docs-only changes"
or "changes requiring review."
```

### 2. Update the matching conditional at lines 1647-1649

Find this text in the post-execution phase determination section:
```
- Phase 5 (Code Review): Skip if user selected "Skip review" or typed
  --skip-review or --skip-post. Also skip if Phase 4 produced no code
  files (existing conditional, unchanged).
```

Replace the last line with:
```
- Phase 5 (Code Review): Skip if user selected "Skip review" or typed
  --skip-review or --skip-post. Also skip if Phase 4 produced only
  documentation-only files (see Phase 5 file classification table).
```

### 3. Update the wrap-up verification summary format

Find the verification summary format examples at two locations in SKILL.md:

Location 1 (~line 1907-1908):
```
The "Skipped:" suffix tracks user-requested skips only. Phases skipped
by existing conditionals (e.g., "no code files") are not listed.
```

Replace with:
```
The "Skipped:" suffix tracks user-requested skips only. Phases skipped
by existing conditionals are not listed in the suffix, but a parenthetical
explanation is appended: e.g., "Verification: tests passed. (Code review:
not applicable -- docs-only changes)."
```

Location 2 (~line 2108-2109): Apply the same replacement.

## What NOT to do

- Do NOT add content-analysis heuristics (scanning for YAML frontmatter, prompt-like patterns). The classification is filename-primary, not content-based.
- Do NOT create a separate file or section for the classification. It lives inline at the Phase 5 skip conditional -- the exact point where the decision is made.
- Do NOT add a "File Classification" preamble section earlier in SKILL.md. Keep the definition at the point of application.
- Do NOT use classification labels in user-facing output examples. Use outcome language ("docs-only changes", "changes requiring review").

## File to modify

`/Users/ben/github/benpeter/2despicable/3/skills/nefario/SKILL.md`

## Context

- Phase 5 skip conditional: line 1670
- Post-execution phase determination: lines 1645-1655
- Wrap-up verification summary: lines 1901-1908 and lines 2101-2109
- The classification table has 5 rows covering the known file types in this project. It is illustrative, not exhaustive -- the definition sentence ("changing it alters runtime behavior") governs edge cases.

When you finish your task, mark it completed with TaskUpdate and send a message to the team lead with:
- File paths with change scope and line counts (e.g., "src/auth.ts (new OAuth flow, +142 lines)")
- 1-2 sentence summary of what was produced
