You are contributing to the PLANNING phase of a multi-agent project.
You are NOT executing yet — you are providing your domain expertise
to help build a comprehensive plan.

## Project Task
check if we are fine on all platforms and if not, what it would take to be safe on windows, macOS, linux
we should think about adding documentation disclaimers that this is mac-only until we have that fixed (if the answer is "not yet")
also think about documenting all command line tools that are expected to be available
in the report, include prompts for
- the docs disclaimer for platform specificity for now
- documentation on required command line tools and how to install them ("ask claude code to do it for you, just paste the list")
- achieving cross-platform stability

## Your Planning Question
The hook scripts and SKILL.md use `mktemp -d` with `chmod 700` for scratch directories and `/tmp/` for session state files. If we make these cross-platform:
(a) Are there security implications of using `$TMPDIR` on Windows (less restrictive permissions model)?
(b) The current `chmod 600`/`chmod 700` calls are security controls -- what replaces them on Windows/NTFS?
(c) The `sensitive-patterns.txt` fail-closed design -- does it remain safe if `grep` behavior differs across platforms?
(d) Any concerns with the symlink-to-junction migration path on Windows?

## Context
Read these files from the working directory /Users/ben/github/benpeter/despicable-agents:
- `.claude/hooks/commit-point-check.sh` (especially the security-relevant sections: sensitive file filtering, fail-closed pattern, tmp file paths)
- `.claude/hooks/track-file-changes.sh` (path injection validation)
- `.claude/hooks/sensitive-patterns.txt`
- `skills/nefario/SKILL.md` (scratch directory creation section, search for "mktemp" and "chmod")

## Advisory Context
This is an advisory-only orchestration. Your contribution will feed
into a team recommendation, not an execution plan. Focus on analysis,
trade-offs, and recommendations rather than implementation tasks.

## Instructions
1. Read relevant files to understand the current state
2. Apply your domain expertise to the planning question
3. Identify risks, dependencies, and requirements from your perspective
4. If you believe additional specialists should be involved that
   aren't already part of the planning, say so and explain why
5. Return your contribution in this format:

## Domain Plan Contribution: security-minion

### Recommendations
<your expert recommendations for this aspect of the task>

### Proposed Tasks
<specific tasks that should be in the execution plan>
For each task: what to do, deliverables, dependencies

### Risks and Concerns
<things that could go wrong from your domain perspective>

### Additional Agents Needed
<any specialists not yet involved who should be, and why>
(or "None" if the current team is sufficient)

6. Write your complete contribution to `/var/folders/3k/bfjvvz9s6dvdn_hvlhvr8lc00000gn/T//nefario-scratch-W2FlrM/cross-platform-compatibility-check/phase2-security-minion.md`
