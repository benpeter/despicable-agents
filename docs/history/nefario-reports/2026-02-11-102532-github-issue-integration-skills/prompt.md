Add GitHub issue integration to /despicable-prompter and /nefario skills

**Outcome**: Both skills can accept `#<n>` as the first argument to pull task context from a GitHub issue, reducing copy-paste friction and keeping issue trackers as the source of truth for task descriptions. The prompter additionally writes its output back to the issue, closing the loop.

**Success criteria**:
- `/despicable-prompter #42` fetches issue #42, generates a brief from its body, updates the issue body with the brief (without `/nefario` prefix), and updates the issue title to the brief's first line
- `/nefario #42` fetches issue #42 and uses its body as the task prompt
- `/despicable-prompter #42 also consider caching` appends the trailing text to the issue body before processing
- `/nefario #42 skip phase 8` appends the trailing text to the issue description as the prompt
- Non-existent issue numbers produce a clear error message (not a stack trace or silent failure)
- `gh` CLI unavailability produces a clear error message

**Scope**:
- In: `skills/despicable-prompter/SKILL.md`, `skills/nefario/SKILL.md`
- Out: Changes to AGENT.md files, install.sh, docs, the-plan.md
