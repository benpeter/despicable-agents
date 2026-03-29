## UX Strategy Review -- AGENT.md Instruction Translator

**Verdict: APPROVE**

### Error Reporting Quality

The three-part error pattern (what / where / how-to-fix) from `load-routing-config.sh` is carried forward correctly. Exit code split (1 = validation, 2 = usage) matches the established convention and gives callers structured signals without parsing stderr. The requirement that malformed frontmatter fail-closed rather than silently passing through garbage is the right call -- fail-loud beats fail-open for a build-time tool.

One refinement worth noting: the size-sanity warning (output < 10% of input) correctly does not hard-fail. A warning to stderr is proportionate -- it surfaces a potential problem without blocking legitimate edge cases.

### Integration Coherence with Routing Config Loader

The plan correctly positions the translator as a pure content transformation step that runs before the adapter receives a `DelegationRequest`. The interface boundary is clean: translator writes a file path and emits frontmatter JSON to stdout; the adapter consumes the path via `translated_instruction_path` and never re-translates. This matches the adapter-interface.md contract exactly.

The JSON-on-stdout pattern (printf, no jq) is consistent with the routing config loader's POSIX-only approach. The frontmatter fields extracted (name, model, tools, description) align with what the adapter layer actually needs for routing and capability gating.

### Adapter Developer Experience

From an adapter author's perspective, the cognitive load is low:

1. **Single integration point**: call the translator, get a file path and metadata JSON. No multi-step ceremony.
2. **Predictable outputs**: format enum has exactly two values; output differences between them are minimal and clearly documented. Adapter authors do not need to reason about content transformations.
3. **No hidden coupling**: the translator strips content but never adds content. Adapter authors can trust that the output is a strict subset of the input body. This is the right constraint -- it prevents the translator from becoming a hidden behavior layer.

The "What NOT to Do" list in the Task 1 prompt is unusually well-calibrated. The false-positive prevention rules (don't strip bare "scratch", bare "Task", or "CLAUDE.md") directly address the most likely adapter-author confusion: "why is legitimate content missing from the translated file?"

### Minor Observations (Non-Blocking)

- The corpus smoke test (27 agents, both formats) is the strongest quality signal in this plan. It catches real-world edge cases that synthetic fixtures cannot anticipate. Good inclusion.
- The decision to defer preamble injection (name/description as Markdown heading) to Codex validation is correct per progressive disclosure -- add complexity only when empirical evidence demands it.

No blocking issues. The developer journey from "I have an AGENT.md" to "I have a clean instruction file with metadata" is one function call with clear contracts on both sides.
