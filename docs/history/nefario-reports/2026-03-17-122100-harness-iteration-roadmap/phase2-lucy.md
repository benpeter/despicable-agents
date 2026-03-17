# Lucy: Alignment Review -- Harness Iteration + Codex Roadmap

## Original User Request (verbatim, numbered)

1. How would the user specify which things to delegate to codex and in the future others? How to specify which models THEY should use?
2. Per-delegation worktree isolation seems complicated but might be the only way. Alternative: concurrency awareness through delegation prompts. Concurrent claude agents have the same issue.
3. Quality parity is definitely with the user, but they should be able to say which models to use as is currently the case.
4. Aider result collection: if LLM diff summarization cost/latency is the only option, then that's what it is.
5. Create a sequence of issues and roadmap for Codex path, extensible for future tools. Goes in an md file.

## Question 1: Contradictions Between Feedback Items?

**Finding: No contradiction, but a configuration gap the report does not address.**

Feedback items 1 and 3 are complementary, not contradictory. Item 1 asks "how does the user specify routing and model selection?" Item 3 affirms that quality parity is the user's responsibility BUT that the user must retain model specification capability.

The report's current treatment creates the gap. Open Question 3 (line 268) frames model quality parity as "should the orchestrator track per-tool quality outcomes to inform future routing, or is this the user's responsibility?" The user answered: it is the user's responsibility, but the user needs a mechanism to specify models per delegation target. The report does not describe such a mechanism anywhere. The `model` field in AGENT.md frontmatter (line 108) is documented as having "No equivalent" in AGENTS.md, and the report says "runtime parameters... belong in the wrapper configuration" (line 116) without defining what wrapper configuration looks like.

**Action needed**: The revised report must answer item 1 concretely -- propose a configuration surface where the user specifies (a) which tasks route to which harness and (b) which model each harness should use. The current report stops at "routing decisions belong in configuration, not planning logic" (line 226) without defining the configuration. This is the main gap.

## Question 2: Does the "Codex-first roadmap" scope align with the report's recommendations?

**Finding: Aligned, but the roadmap must be scoped carefully.**

The report recommends Codex CLI first (line 217-218), which matches the user's directive (item 5). The report also recommends making the abstraction "extensible" -- "invisible to the orchestrator" (line 227) -- which matches "extensible for future tools."

**Risk: The roadmap must not pre-build abstractions for tools it does not yet support.** Per CLAUDE.md's YAGNI principle, the roadmap should implement Codex CLI delegation concretely. Extensibility should come from clean interfaces (the adapter boundary), not from pre-built adapters for Aider and Gemini CLI. The report's three-tool sequencing (lines 217-220) is a recommendation for future work, not a scope commitment for the roadmap.

**The roadmap IS a new artifact.** The user explicitly requested "a sequence of issues and roadmap... goes in an md file." This is a new `docs/` file, not a modification to the existing report. The report gets iterated with the 5 feedback items; the roadmap is a separate deliverable.

## Question 3: Quality Parity vs. Model Specification Tension

**Finding: No real tension once you read items 1 and 3 together.**

The user is saying two things that are consistent:
- "Quality parity is the user's responsibility" = the orchestrator should NOT try to auto-detect or auto-compensate for model quality differences. Do not build quality tracking, quality routing heuristics, or model benchmarking into the delegation layer.
- "They should be able to say which models to use" = the configuration surface must include model specification per harness/delegation, just as `model: opus` exists today in AGENT.md frontmatter.

The report's Open Question 3 can be resolved: remove the "should the orchestrator track per-tool quality outcomes" option. The answer is no. Replace with: "The user specifies model per harness. Quality assessment is the user's responsibility, not the orchestrator's."

The existing `model` field in AGENT.md frontmatter (line 40 of the-plan.md: `model: opus # or sonnet`) is the precedent. The new configuration must extend this to external harnesses -- e.g., "when routing to Codex, use o3" or "when routing to Aider, use claude-sonnet-4-20250514 via the provider."

## Question 4: "Not Changing Nefario" vs. "Nefario Phase 4 Integration"

**Finding: This is the sharpest scope boundary and needs explicit definition.**

The user said the roadmap scope is "Codex path, extensible for future tools." The user did NOT say "do not change nefario." But the planning question raises the right concern: where is the line?

Here is my assessment of where the line falls, based on the user's feedback and the report's recommendation that the abstraction be "invisible to the orchestrator":

**In scope for the roadmap:**
- A wrapper/adapter layer that sits BETWEEN nefario's Task tool invocation and the actual CLI subprocess. This is new code, not nefario changes.
- A configuration file or surface where the user specifies routing rules and model preferences. This is new infrastructure, not nefario changes.
- Modifications to how nefario's Phase 4 spawns tasks, IF those modifications are limited to: calling the wrapper instead of the Task tool directly for designated tasks. This is a minimal nefario change -- a routing decision, not a planning change.

**Out of scope for the roadmap:**
- Changes to nefario's Phase 1-3 planning logic (meta-plan, specialist planning, synthesis). Nefario should not need to know about external harnesses during planning.
- Changes to nefario's Phase 3.5 review process.
- Changes to the delegation table, agent specs, or AGENT.md format.
- Building nefario awareness of tool capabilities (e.g., "Aider cannot do Bash, so route Bash tasks to Claude Code"). This is a routing-layer concern, not a nefario concern.

**The integration point is narrow**: Phase 4, step 3 (SKILL.md line 1560-1575), where nefario spawns execution agents via the Task tool. The roadmap should define how this step conditionally routes to an external harness wrapper instead. This is a 10-line change to nefario's execution loop, not a fundamental restructuring.

**Recommendation**: The roadmap should explicitly state this boundary: "Nefario changes are limited to Phase 4 execution routing. Planning phases 1-3.5 are unchanged."

## Question on Worktree Isolation (Feedback Item 2)

The user partially resolved Open Question 2 from the report. They acknowledge per-delegation worktree isolation is complicated but may be necessary, and suggest an alternative: concurrency awareness through delegation prompts (telling each delegated agent which files it owns). The user also notes that concurrent Claude Code agents already have this same problem.

**Alignment assessment**: The report should update Open Question 2 to reflect this user input. The two approaches (worktree isolation vs. prompt-based file ownership) should be presented as the concrete alternatives, with the user's observation that this is a pre-existing problem (not harness-specific) noted. This prevents over-engineering a solution for external harnesses that is not solved for the current system either.

## Question on Aider Result Collection (Feedback Item 4)

The user resolved Open Question 5 from the report: if LLM diff summarization is the only viable approach for tools without structured output, accept the cost and latency. This is a decision, not an open question.

**Action**: Close Open Question 5 in the revised report. Move the LLM summarization approach from "one option" to "the approach" for tools without structured JSON output.

## Traceability: Feedback Items to Plan Elements

| Feedback Item | Report Section Needing Change | Roadmap Section Needed |
|---------------|-------------------------------|------------------------|
| 1. Routing + model specification | New section: Configuration Surface. Update Recommendations to define it. | Issue: Configuration schema design |
| 2. Worktree vs. concurrency prompts | Update Open Question 2 with user's input. | Issue: Concurrency strategy |
| 3. Quality parity = user's job, model spec = required | Close Open Question 3. Remove auto-tracking option. | Issue: Model specification in config |
| 4. LLM diff summarization accepted | Close Open Question 5. Update Aider feasibility assessment. | Issue: Result collection adapter (Codex first, Aider later) |
| 5. Codex-first roadmap in md file | N/A (roadmap is a separate artifact) | New file: docs/codex-roadmap.md (or similar) |

## CLAUDE.md Compliance Flags

- **YAGNI**: The roadmap MUST NOT pre-build adapters for Aider or Gemini CLI. Codex-only concrete implementation; others are future issues with "extensible" design.
- **KISS**: The configuration surface should be minimal. A single file (e.g., `.claude/harness-config.yml` or a section in CLAUDE.md) rather than a multi-file configuration system.
- **Lean and Mean**: The report's protocol comparison table (lines 142-151) compares 4 protocol options but the user has implicitly endorsed CLI subprocess (the pragmatic choice). The roadmap should not re-litigate A2A, MCP, or other protocol choices.
- **No PII / publishable**: Any configuration examples in the roadmap must use generic model names and provider references.

## Scope Creep Risks for the Roadmap

| Risk | Indicator | Mitigation |
|------|-----------|------------|
| Building a full adapter framework before Codex works | "Let's design the adapter interface for all tools first" | YAGNI. Build the Codex adapter. Extract the interface after Aider validates it. |
| Adding quality tracking / model benchmarking | "We should track which model works best for which task type" | User explicitly said quality parity is their responsibility. |
| Redesigning nefario's planning phases | "Nefario should consider tool capabilities during planning" | Out of scope. Routing is a Phase 4 execution concern. |
| Building a configuration UI | "Users need a way to visualize routing decisions" | Report already scoped out UX design (line 256). |
| Pre-building protocol support (A2A, ACP) | "Let's add A2A support so we're future-proof" | Report correctly says "monitor for 6 months." Zero adoption. |

## Verdict: ADVISE

The feedback items are internally consistent. No contradictions. The main gap is that the report does not yet define the configuration surface that feedback items 1 and 3 require. The nefario scope boundary needs explicit statement in the roadmap. Two open questions can be closed with user decisions (items 3 and 4). One open question gets refined with user input (item 2).

The plan can proceed with these adjustments:
1. The report revision must add a concrete Configuration Surface section answering "how does the user specify routing and models."
2. The roadmap must explicitly state the nefario change boundary: Phase 4 execution routing only.
3. Open Questions 3 and 5 should be closed as resolved by user direction.
4. The roadmap must resist YAGNI violations -- Codex adapter only, extract abstractions after second adapter validates them.
