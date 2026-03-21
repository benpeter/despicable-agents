# Lucy Review: Simplify Path References in Nefario Skill

## Verdict: ADVISE

The plan is well-aligned with the user's request and appropriately scoped. Three findings require attention before execution.

---

## Requirements Traceability

| Requirement (from prompt) | Plan Element | Status |
|---|---|---|
| Audit SKILL.md for path references replaceable with `${CLAUDE_SKILL_DIR}` | Tasks 1 + 2 identify 4 references (3 TEMPLATE.md, 1 commit-workflow.md) | COVERED |
| Simplify path resolution, reduce fragility under symlink | Moving TEMPLATE.md into skill dir + using `${CLAUDE_SKILL_DIR}` | COVERED |
| Reduce runtime path detection logic | Not addressed in plan | SEE FINDING 3 |

---

## Findings

### Finding 1: Missing updates to docs/orchestration.md (SCOPE)

**CHANGE**: The plan moves `TEMPLATE.md` from `docs/history/nefario-reports/` to `skills/nefario/` but only updates references in `skills/nefario/SKILL.md`.

**PROBLEM**: `docs/orchestration.md` line 565 contains:
> `The canonical report template is defined in docs/history/nefario-reports/TEMPLATE.md.`

This reference will become stale after the move. This is not scope creep -- it is a direct consequence of the file move that the plan proposes.

**FIX**: Add updating `docs/orchestration.md` line 565 to Task 1's deliverables. The new path would be `skills/nefario/TEMPLATE.md`.

**SEVERITY**: Medium. Stale documentation reference in a key architecture doc.

---

### Finding 2: commit-workflow.md link uses `${CLAUDE_SKILL_DIR}/../../` which resolves through the symlink (DRIFT)

**CHANGE**: Task 2 replaces the broken relative link `../../../docs/commit-workflow.md` with `${CLAUDE_SKILL_DIR}/../../docs/commit-workflow.md`.

**PROBLEM**: The plan's own Risks section (item 1) correctly identifies that if `${CLAUDE_SKILL_DIR}` resolves to the symlink path (`~/.claude/skills/nefario`), then `../../docs/commit-workflow.md` resolves to `~/.claude/docs/commit-workflow.md`, which does not exist. The plan proposes "Mitigation: test after implementation" -- but this is a predictable failure mode, not something to discover post-hoc.

The user's request says "simplify path references" and "reduce fragility when the skill is symlinked." Introducing a path that has a known failure mode under symlink resolution is contrary to that stated intent.

**FIX**: The plan should decide up front how to handle `commit-workflow.md`. Options:
1. Copy `docs/commit-workflow.md` into the skill directory (same pattern as TEMPLATE.md -- self-containment).
2. Use a plain prose reference ("follows conventional commit format per the project's commit-workflow.md") instead of a link that cannot resolve portably.
3. Verify `${CLAUDE_SKILL_DIR}` resolution behavior before finalizing the approach (a 10-second test: add `${CLAUDE_SKILL_DIR}` to a test SKILL.md and check what it expands to).

Option 3 should happen first regardless -- it determines whether option 1 or 2 is needed.

**SEVERITY**: Medium. The plan acknowledges the risk but defers resolution to post-implementation, which is the wrong time to discover it.

---

### Finding 3: Prompt mentions "runtime path detection logic" but plan does not address it (TRACE)

**CHANGE**: The user's prompt says: "The nefario skill uses detection logic and relative paths to locate co-located files."

**PROBLEM**: The plan addresses the 4 path references but does not audit for or simplify any "detection logic" (e.g., scripted path resolution). If there is no such logic, the plan should state that explicitly. If there is, it should be in scope per the user's request.

**FIX**: Task 1 or Task 2 should include a statement confirming whether any runtime path detection logic exists in SKILL.md beyond the 4 identified references, and if so, whether it should be simplified. This may be as simple as "Audit confirmed: no runtime detection logic exists; all path references are the 4 identified strings."

**SEVERITY**: Low. Likely there is no such logic and this is just prompt phrasing, but the traceability gap should be closed explicitly.

---

## Convention Compliance

- **CLAUDE.md "Do NOT modify the-plan.md"**: Plan does not touch `the-plan.md`. COMPLIANT.
- **English artifacts**: All deliverables in English. COMPLIANT.
- **Engineering Philosophy (KISS, Lean and Mean)**: Moving TEMPLATE.md into the skill directory for self-containment is aligned with these principles. COMPLIANT.
- **Session Output Discipline**: Plan uses devx-minion with bypassPermissions. COMPLIANT for orchestrated session.
- **Git conventions**: Plan uses `git mv` for the file move. COMPLIANT.

## Scope Assessment

The plan is well-scoped overall. Moving TEMPLATE.md into the skill directory is a reasonable consequence of the simplification request -- it eliminates a cross-directory reference entirely rather than just rewriting it, which is the simpler outcome. Task 3 (memory update) is appropriate housekeeping. No scope creep detected.
