# Margo Review: External Skill Integration Plan

## Verdict: ADVISE

The plan is well-disciplined for its scope. The "prompt-level changes only, no new code, no new infrastructure" constraint is exactly right. The conflict resolutions (dropping keywords metadata, dropping classification confidence levels, keeping the maintainer section short) all went the correct direction -- each one chose the simpler path. The explicit anti-patterns ("Do NOT build a skill registry, catalog, or compatibility checker") show awareness of scope creep temptation.

Three non-blocking concerns:

### 1. Documentation is 60% of the task count -- consider combining Tasks 4 and 5

Tasks 4 (update using-nefario.md, ~50 lines) and 5 (cross-references in architecture.md, decisions.md, README.md, ~15 lines total) are trivially small edits. Together they are under 65 lines of additions across 4 files. Task 5 is blocked on Task 4 only because of cross-reference accuracy, but these are link URLs and one-line additions -- not content that requires deep reading of Task 4's output.

**Simpler alternative**: Merge Tasks 4 and 5 into a single "Update user docs and cross-references" task. This eliminates one batch, one agent spawn, and the artificial dependency chain. A single software-docs-minion or user-docs-minion task can handle all 4 files in one pass. The total additions are small enough that a single agent can hold the full context easily.

**Severity**: Low. Four batches instead of three is not a major cost, but it is unnecessary serialization for trivially small work.

### 2. Task 3 (docs/external-skills.md) target of 400-600 lines is generous for an MVP

The plan explicitly notes the risk of "feature creep toward skill framework" as HIGH likelihood. A 600-line architecture document for a feature that currently has zero users is a complexity magnet. It invites documenting edge cases that do not exist yet and creates a gravity well that attracts future scope expansion ("the doc says we support X, so we need to implement X").

**Simpler alternative**: Target 200-300 lines. The "How It Works" / "Discovery" / "Precedence" / "Deferral" sections can be 50-80 words each instead of 100-150. The Mermaid diagram is fine. The "For Skill Maintainers" section at 150 words is already the right size. Cut ruthlessly -- if the mechanism is truly simple (filesystem scan + content heuristic + approval gate override), the documentation should be proportionally simple.

**Severity**: Medium. Over-documentation creates implied commitments and makes the integration surface feel heavier than it is. This directly conflicts with the goal of "leads with zero-effort integration."

### 3. The `<external-skill>` content boundary markers add a novel concept

The plan introduces `<external-skill>` XML tags as content boundary markers to prevent orchestration-level injection from SKILL.md content. This parallels the existing `<github-issue>` pattern, which is good (reuse over invention). However, note that this is a prompt-level convention, not an enforcement mechanism. If the existing `<github-issue>` pattern has proven effective in practice, this is justified. If it has not been tested under adversarial conditions, both patterns are theater.

**Not blocking** because: (a) it parallels an existing convention, (b) the plan correctly identifies that "Claude Code's native permission model is the enforcement point," and (c) the plan accepts residual risk explicitly. Just flagging that adding new XML tag conventions to prompts has a small cognitive cost on every reader of AGENT.md, and that cost should not grow further (no more tag types without evidence that existing ones work).

---

## What the plan gets right (for the record)

- "Filesystem IS the registry" -- correct. No skill catalog, no manifest, no configuration file. YAGNI applied correctly.
- Dropping `keywords:` metadata -- correct. Description field is sufficient. Optional metadata that "everyone should add" is de facto mandatory.
- Single approval gate -- correct. The meta-plan proposed two MUST gates; synthesis collapsed them to one. Good.
- Classification as "judgment call by nefario, not a formal algorithm" -- correct. Weighted scoring systems for LLM prompt guidance are over-engineering.
- All changes are prompt text and documentation -- correct. No install.sh changes, no new scripts, no new tooling.
- Size caps (1200 words AGENT.md, 400 words SKILL.md) -- good discipline.

## Summary

The plan is proportional to the problem. My concerns are about trimming, not restructuring. The core design decisions (filesystem discovery, content-signal classification, three-tier precedence, deferral as opaque macro-task) are the simplest viable approach. The main risk is that the documentation tasks (3 of 5 tasks) expand the perceived surface area beyond what the prompt-level mechanism actually delivers.
