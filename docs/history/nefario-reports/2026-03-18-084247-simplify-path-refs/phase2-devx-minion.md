# Phase 2: DevX Minion -- Path Reference Audit for `${CLAUDE_SKILL_DIR}`

## Executive Summary

`skills/nefario/SKILL.md` contains four categories of path references. Only one
is a clear candidate for `${CLAUDE_SKILL_DIR}` replacement. One is actively
broken and should be fixed regardless. Two categories must remain cwd-relative
by design. I also evaluate whether TEMPLATE.md should be moved into the skill
directory and recommend against it.

---

## Path Reference Inventory

### 1. Line 1795: Relative markdown link to `commit-workflow.md`

**Current reference:**
```
`<type>(<scope>): <summary>` with trailers per [commit-workflow.md](../../../docs/commit-workflow.md):
```

**Problem:** The `../../../` relative path is wrong from both locations:
- From real path (`skills/nefario/SKILL.md`): resolves to
  `<repo>/../../docs/commit-workflow.md` = `/Users/ben/github/benpeter/docs/commit-workflow.md` (does not exist)
- From symlink path (`~/.claude/skills/nefario/SKILL.md`): resolves to
  `/Users/ben/docs/commit-workflow.md` (does not exist)
- Correct relative from real path would be `../../docs/commit-workflow.md` (two levels, not three)

**Recommended replacement:**
```
`<type>(<scope>): <summary>` with trailers per [commit-workflow.md](${CLAUDE_SKILL_DIR}/../../docs/commit-workflow.md):
```

**Why `${CLAUDE_SKILL_DIR}` and not just fix the relative depth:** A plain relative
link in SKILL.md is resolved relative to wherever Claude thinks the file is. When
the skill is loaded from `~/.claude/skills/nefario/` (the symlink), a relative
path has no way to reach the repo's `docs/` directory. `${CLAUDE_SKILL_DIR}` is
documented to resolve to the directory containing `SKILL.md`, and since
`~/.claude/skills/nefario` is a symlink to the repo's `skills/nefario/`, the
variable should resolve to the repo path. From there, `../../docs/commit-workflow.md`
correctly reaches the target.

**Symlink resolution implication:** This depends on whether `${CLAUDE_SKILL_DIR}`
follows the symlink or returns the symlink path. If it returns
`~/.claude/skills/nefario/`, then `../../docs/commit-workflow.md` resolves to
`~/.claude/docs/commit-workflow.md` (wrong). If it follows the symlink to
`/Users/ben/github/benpeter/despicable-agents/skills/nefario/`, the path works.

**Risk mitigation:** Before implementing, verify the actual resolved value with a
quick test:
```
echo ${CLAUDE_SKILL_DIR}
```
in a SKILL.md that uses the variable. If it does NOT follow symlinks, we need an
alternative approach (see Alternatives section below).

**Verdict: REPLACE, but verify symlink behavior first.**

---

### 2. Lines 288-290: Report directory detection (cwd-relative)

**Current reference:**
```
Detection order (first match wins):
1. `docs/nefario-reports/` relative to cwd (if exists)
2. `docs/history/nefario-reports/` relative to cwd (if exists)
3. Default: create `docs/history/nefario-reports/` relative to cwd
```

**Should NOT be changed.** This is intentionally cwd-relative because nefario
writes execution reports into the *consuming project's* directory structure, not
into the skill's own directory. When nefario orchestrates work on project X, the
reports go into project X's `docs/` tree. The skill directory
(`~/.claude/skills/nefario/`) is the wrong location for output.

**Verdict: DO NOT REPLACE.**

---

### 3. Lines 2375, 2446: TEMPLATE.md prose references

**Current references:**

Line 2375:
```
The canonical report template is defined in
`docs/history/nefario-reports/TEMPLATE.md`. Read and follow this template
```

Line 2446:
```
— follow the canonical template defined in `docs/history/nefario-reports/TEMPLATE.md`
```

**These are cwd-relative read instructions**, telling the orchestrator to read the
template from the consuming project's directory. Currently, the template lives in
the despicable-agents repo at `docs/history/nefario-reports/TEMPLATE.md`. When
nefario runs in this repo, cwd-relative works. But when nefario runs in a
different project that does not have this template file, the reference fails silently
(the template simply is not found, and nefario must generate reports without it).

**Two options:**

**Option A: Move TEMPLATE.md into the skill directory (recommended path analyzed below)**
- Replace with `${CLAUDE_SKILL_DIR}/TEMPLATE.md`
- Template always available regardless of cwd

**Option B: Keep cwd-relative with fallback to skill dir**
- Primary: `docs/history/nefario-reports/TEMPLATE.md` (cwd-relative)
- Fallback: `${CLAUDE_SKILL_DIR}/TEMPLATE.md` (if the skill bundles a copy)
- More resilient but introduces a copy-sync problem

**Verdict: REPLACE -- see TEMPLATE.md relocation analysis below.**

---

### 4. Line 946: `TEMPLATE.md` shorthand reference

**Current reference:**
```
Follow the advisory-mode conditional rules in `TEMPLATE.md`:
```

This is a prose reference in the advisory wrap-up section. It assumes the reader
(the orchestrating LLM) already has the template in context from the earlier
full-path reference. It is a shorthand, not a path instruction.

**Verdict: NO CHANGE NEEDED (but should be consistent with whatever the full
references become). If TEMPLATE.md moves into the skill dir, this shorthand
still works because the LLM will have read the template by this point.**

---

## Should TEMPLATE.md Move Into the Skill Directory?

### Analysis

**Arguments for moving:**
1. `${CLAUDE_SKILL_DIR}/TEMPLATE.md` is a clean, always-resolvable path
2. The template is a skill resource -- it defines the report format that the skill
   produces. It belongs with the skill, not with the output directory.
3. Eliminates the silent failure when nefario runs in a project without the template
4. Follows the Claude Code skill pattern: supporting files live alongside SKILL.md
   (the official docs show `my-skill/template.md` as a standard pattern)
5. The template at `docs/history/nefario-reports/TEMPLATE.md` is referenced from
   SKILL.md via `Read` tool calls. If it is co-located, those reads are simpler.

**Arguments against moving:**
1. The template is currently tracked in `docs/history/nefario-reports/` alongside
   the reports it governs. There is a conceptual affinity: template + instances.
2. Moving it creates a disconnect: reports live in `docs/` but their template lives
   in `skills/nefario/`.
3. Other tooling or documentation may reference the current path.
4. The report directory detection logic (lines 288-290) already establishes a
   cwd-relative pattern for report infrastructure.

**Recommendation: Move a copy, keep the original as a symlink.**

Move the canonical `TEMPLATE.md` into `skills/nefario/TEMPLATE.md` and replace the
original at `docs/history/nefario-reports/TEMPLATE.md` with a symlink pointing back.
This gives us:
- `${CLAUDE_SKILL_DIR}/TEMPLATE.md` always resolves (skill is self-contained)
- `docs/history/nefario-reports/TEMPLATE.md` still works for anyone browsing the
  report directory (symlink resolves transparently)
- No breakage for other references

Alternatively, the simpler approach: just move it. The `docs/history/nefario-reports/`
path only appears in SKILL.md itself (which we are updating) and in the memory
file (which is informational). No external tooling references it.

**Final recommendation: Move TEMPLATE.md into skill directory. No symlink needed --
just update the two prose references in SKILL.md.**

---

## Proposed Changes Summary

| Line(s) | Current | Proposed | Rationale |
|----------|---------|----------|-----------|
| 1795 | `[commit-workflow.md](../../../docs/commit-workflow.md)` | `[commit-workflow.md](${CLAUDE_SKILL_DIR}/../../docs/commit-workflow.md)` | Fix broken relative link; use stable anchor |
| 2375 | `docs/history/nefario-reports/TEMPLATE.md` | `${CLAUDE_SKILL_DIR}/TEMPLATE.md` | Self-contained skill; always resolvable |
| 2446 | `docs/history/nefario-reports/TEMPLATE.md` | `${CLAUDE_SKILL_DIR}/TEMPLATE.md` | Same as above |
| 946 | `TEMPLATE.md` (shorthand) | No change | Shorthand reference, not a path instruction |
| 288-290 | `docs/nefario-reports/` and `docs/history/nefario-reports/` relative to cwd | No change | Output paths must be cwd-relative by design |

**File move:** `docs/history/nefario-reports/TEMPLATE.md` -> `skills/nefario/TEMPLATE.md`

---

## Risks and Dependencies

### Risk 1: `${CLAUDE_SKILL_DIR}` symlink resolution behavior (HIGH)

The entire approach depends on whether `${CLAUDE_SKILL_DIR}` resolves symlinks.
- If it resolves: `${CLAUDE_SKILL_DIR}` = `/Users/ben/github/benpeter/despicable-agents/skills/nefario/`
  and `${CLAUDE_SKILL_DIR}/../../docs/commit-workflow.md` works.
- If it does NOT resolve: `${CLAUDE_SKILL_DIR}` = `/Users/ben/.claude/skills/nefario/`
  and `../../docs/commit-workflow.md` goes to `~/.claude/docs/commit-workflow.md` (broken).

**Mitigation:** Test `${CLAUDE_SKILL_DIR}` resolution in a minimal skill before
implementing. If it does not follow symlinks, the commit-workflow.md reference
should instead be handled by inlining the relevant trailer format directly in
SKILL.md (it is only a few lines of content), or by copying commit-workflow.md
into the skill directory as well.

Note: for TEMPLATE.md, symlink resolution does not matter if we move the file
into the skill directory -- `${CLAUDE_SKILL_DIR}/TEMPLATE.md` works either way
because the file is co-located with SKILL.md.

### Risk 2: TEMPLATE.md move breaks report directory browsing (LOW)

Anyone navigating to `docs/history/nefario-reports/` will no longer find
TEMPLATE.md there. This is low risk because the template is consumed by the
orchestrator (via SKILL.md instructions), not by humans browsing the directory.

### Risk 3: install.sh symlink scope (LOW)

Verify that `install.sh` symlinks the entire `skills/nefario/` directory (not
just SKILL.md). If it symlinks the directory, TEMPLATE.md will be available
alongside SKILL.md automatically. If it only symlinks SKILL.md, we need to
adjust the install script.

### Risk 4: Variable expansion context (MEDIUM)

`${CLAUDE_SKILL_DIR}` is documented as a string substitution that happens when
Claude Code reads SKILL.md. Verify it expands in all contexts where the path
appears:
- Inside markdown link targets: `[text](${CLAUDE_SKILL_DIR}/...)` -- likely works
- Inside backtick-quoted prose: `` `${CLAUDE_SKILL_DIR}/TEMPLATE.md` `` -- likely works
- The variable is NOT a shell variable; it is expanded by Claude Code's skill
  loader before the content reaches the LLM

---

## Alternative Approaches

### Alternative A: Inline commit-workflow.md content

Instead of linking to `docs/commit-workflow.md`, extract the ~10 lines about
trailer format and inline them directly in SKILL.md at line 1795. This eliminates
the path reference entirely.

**Pro:** No path resolution concerns. Self-contained.
**Con:** Content duplication. If commit-workflow.md is updated, SKILL.md drifts.

### Alternative B: Copy both files into skill directory

Copy both `TEMPLATE.md` and `commit-workflow.md` into `skills/nefario/`. All
references become `${CLAUDE_SKILL_DIR}/filename.md`.

**Pro:** Fully self-contained skill. No symlink resolution concerns.
**Con:** Content duplication for commit-workflow.md (which is shared repo documentation).

### Alternative C: Use `!` command injection to resolve paths at runtime

Replace static paths with dynamic resolution:
```
The commit workflow is documented in: !`readlink -f ${CLAUDE_SKILL_DIR}/../../docs/commit-workflow.md`
```

**Pro:** Resolves symlinks dynamically.
**Con:** Adds runtime shell execution. Fragile. Overkill for this use case.

---

## Implementation Checklist

1. [ ] Verify `${CLAUDE_SKILL_DIR}` symlink resolution behavior
2. [ ] Verify `install.sh` symlinks the directory (not just SKILL.md)
3. [ ] Move `docs/history/nefario-reports/TEMPLATE.md` to `skills/nefario/TEMPLATE.md`
4. [ ] Update SKILL.md line 2375: replace cwd-relative template path with `${CLAUDE_SKILL_DIR}/TEMPLATE.md`
5. [ ] Update SKILL.md line 2446: same replacement
6. [ ] Update SKILL.md line 1795: replace `../../../docs/commit-workflow.md` with `${CLAUDE_SKILL_DIR}/../../docs/commit-workflow.md`
7. [ ] If symlink resolution test fails: fall back to Alternative A (inline commit trailer format) for the line 1795 reference
8. [ ] Update agent memory / MEMORY.md if TEMPLATE.md path changes
