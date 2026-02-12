# Margo Review: Simplicity and YAGNI Assessment

## Verdict: ADVISE

The 3-task structure is justified and proportional. Task 1 (inline template) solves the root problem. Task 3 (delete TEMPLATE.md) is essential cleanup. The plan correctly avoids git hooks, CI automation, and complex infrastructure. One concern on Task 2.

### Concern 1: Post-Nefario Updates "Replace PR body" option (Task 2, non-blocking)

The 3-option structured choice (Append / Separate report only / Replace PR body) adds complexity for a marginal case. "Replace PR body" is the existing PR creation behavior -- if someone wants to replace the entire body, they can just not append and then manually update, or the next full nefario run on a new branch handles it. Three options where two suffice increases cognitive load on every invocation where an existing PR is detected.

**Simpler alternative**: Two options only -- "Append updates" and "Skip (report only)". If someone truly needs to replace the body, `gh pr edit <N> --body-file <report>` is a one-liner they already know. Document that one-liner in the "Skip" path output message.

This is non-blocking because the extra option does not add structural complexity to SKILL.md -- it is just one more branch in the wrap-up conditional. But it is accidental complexity: solving a problem the user can solve in one command.

### Concern 2: Task 1 prompt length (non-blocking, observation)

The Task 1 prompt is approximately 180 lines. This is the longest delegation prompt I have seen in this project. It is thorough and well-structured -- most of it is essential specification (section order, frontmatter schema, conditional rules). However, the "What NOT To Do" list (lines 199-209) and the duplicated section enumeration (lines 86-111 enumerate sections, then lines 107-111 re-enumerate the "actual top-level H2 sections in order") add ~20 lines of redundancy. Not a blocking issue, but the prompt could be tightened by removing the double enumeration.

### What looks good

- **Inlining the template in SKILL.md**: correct decision. Two files = drift. One file = single source of truth. This is the core fix and the plan gets it right.
- **Detection-and-nudge over auto-append**: correct. Auto-append is dangerous (same branch, different purpose). The nudge pattern respects user intent.
- **No git hooks, no CI, no complex automation**: the issue says "not a git hook or CI pipeline" and the plan honors that.
- **Task count (3) is proportional**: the problem has three clear units of work (write template, add update mechanism, clean up old file). No task inflation.
- **One approval gate**: appropriate. The template is the foundation; everything depends on it. One gate, not three.
- **Complexity budget**: zero new technologies, zero new dependencies, zero new services. All changes are markdown documentation in one existing file plus one file deletion. Budget spend is near zero.
