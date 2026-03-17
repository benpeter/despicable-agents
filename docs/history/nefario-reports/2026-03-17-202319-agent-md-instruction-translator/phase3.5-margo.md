# Margo Review: AGENT.md Instruction Translator

## Verdict: ADVISE

The plan is proportional to Issue #140. Three tasks for a CLI script, its tests, and a docs update -- no scope inflation. Zero external dependencies. Boring technology (bash, awk, sed). No unnecessary abstraction layers. The complexity budget is low and justified.

Two non-blocking items worth watching:

### 1. Post-translation validation: size sanity check is speculative

**What**: Task 1 specifies a "size sanity" validation -- warn if output is <10% of input size.

**Why this is accidental complexity**: No known scenario produces a >90% reduction that is not already caught by the "non-empty output" check. The 10% threshold is arbitrary with no empirical basis. This adds a code path, a magic number, and a stderr message that will either never fire or fire as a false positive on a short agent file with large frontmatter.

**Simpler alternative**: Drop the size sanity check. Keep the non-empty output check (essential). If a future stripping bug causes dramatic shrinkage, the corpus smoke test (Task 2) will catch it by asserting heading presence. Revisit only if a real false-positive-free threshold emerges from production data.

**Severity**: Low. It is a few lines of bash and a stderr warning, not a blocking concern. But it is textbook YAGNI -- solving a problem that does not exist yet with an untested heuristic.

### 2. Prompt length: Task 1 prompt is very detailed (~170 lines)

**What**: The Task 1 delegation prompt is comprehensive to the point of prescribing specific awk one-liners and exact error message formatting.

**Why this matters**: Overly prescriptive prompts can be counterproductive -- they consume context window, reduce the agent's ability to make locally optimal implementation choices, and create a maintenance burden (the prompt becomes a second spec that can drift from the actual code). The devx-minion is a domain specialist; it does not need the awk state machine spelled out character by character.

**Simpler alternative**: No action required -- this is an observation, not a blocking concern. The prompt is detailed because the sed patterns and awk parsing have specific correctness requirements (false positives on "scratch", "Task", "CLAUDE.md"). That specificity is arguably essential complexity for a stripping tool where precision matters. Just be aware that if the agent deviates from the prescribed one-liners for good reason, that is acceptable.

### What looks good

- **3 tasks, 2 batches** -- minimal task count, clean dependency chain, no approval gates on low-risk additive work. Proportional.
- **Zero external dependencies** -- POSIX tools only. No yq, no jq for the translator itself. Correct.
- **Separate sed pattern file** -- maintainable, auditable, independently testable. Good separation without over-abstraction.
- **Corpus smoke test over all 27 agents** -- catches real-world edge cases that synthetic fixtures miss. Worth the extra test time.
- **Hybrid awk + sed stripping** -- section-level for whole-section removal, token-level for inline. Matches the actual content structure. Not over-engineered.
- **No preamble injection, no cross-model rewriting** -- correct YAGNI calls. Both are deferred to validation (#146) where empirical data can justify them.
- **Cross-cutting dismissals are justified** -- no security task (defensive coding embedded in Task 1), no UX task (internal infra with programmatic consumers), no observability task (CLI tool, not a service). Correct.

No blocking concerns. Proceed.
