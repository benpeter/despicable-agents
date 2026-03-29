## UX Strategy Review — Routing Configuration Schema

**Verdict: ADVISE**

The plan is well-structured from a user experience perspective. The core UX decisions are sound: zero-config path (silent, no dependencies), progressive disclosure from minimal to power-user config, recognition-based group IDs, category-batched error reporting, and user-level config under the existing `~/.claude/` hierarchy. These align with JTBD ("when I want to route some agents to Codex, I want a predictable config file, so I can control cost and model diversity without learning orchestrator internals") and respect cognitive load constraints.

Three advisory items:

- [usability]: The shallow-per-section merge for `groups:` preserves project-only keys while user keys override matching ones, but for `model-mapping:` user replaces the entire harness block. This inconsistency (key-level merge for groups/agents, block-level replace for model-mapping) will surprise users who build a mental model from the groups behavior and expect the same granularity everywhere.
  SCOPE: Merge semantics documentation in Task 1 prompt (line 80-84) and Task 3 doc spec
  CHANGE: Ensure the example config and documentation explicitly call out this asymmetry with a concrete before/after example showing what happens when a user defines `model-mapping: codex:` — that it replaces the entire codex block including tiers they did not mention. A single sentence like "Note: model-mapping replaces the entire harness entry, not individual tiers within it" in the YAML example comments and in the doc spec would prevent the most common misunderstanding.
  WHY: Inconsistent merge granularity across sections violates Nielsen's consistency heuristic. Users who correctly learn that `groups:` does key-level merge will assume `model-mapping:` does the same, leading to silent loss of tier mappings they intended to inherit. Making the asymmetry visible at the point of authoring is cheaper than debugging missing model mappings at runtime.
  TASK: Task 1 (example config comments), Task 3 (documentation)

- [usability]: The capability gating error message tells users what went wrong and suggests "route to a harness that supports these tools, or remove the agent-level override." This is good but stops short of the most actionable fix: naming which harnesses DO support the required tools.
  SCOPE: Error message format for capability gating in Task 1 prompt (lines 166-176)
  CHANGE: Add a line to the capability gating error showing which harness(es) would satisfy the requirement. For example: "Harnesses supporting WebSearch: claude-code". The data is already available (the capability registry is hardcoded) so this is a trivial addition.
  WHY: Users encountering this error must currently cross-reference the capability registry in their head or in documentation to find a valid harness. Showing the valid options in the error itself converts a recall task (which harness supports WebSearch?) into a recognition task. This is the same principle behind "unknown harness" errors listing valid harness names.
  TASK: Task 1

- [usability]: The `--resolve AGENT_NAME` subcommand is valuable for debugging but the plan does not specify what happens when the agent name is unknown. An unresolved agent should produce a clear error rather than silently falling through to the default.
  SCOPE: `--resolve` CLI behavior in Task 1 prompt (lines 134-139) and Task 2 test coverage
  CHANGE: Specify that `--resolve unknown-agent-name` exits with code 1 and an error message listing the valid agent roster (or at minimum stating the agent is unknown). Add a test case for this in Task 2.
  WHY: Silent fallthrough to default for a typo'd agent name ("fontend-minion" instead of "frontend-minion") would give the user a confident-looking but wrong answer, violating the error prevention heuristic. The loader already has the full agent roster for validation — applying it to `--resolve` is consistent behavior.
  TASK: Task 1, Task 2
