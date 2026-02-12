# Phase 3.5 Review: ai-modeling-minion

**Verdict**: ADVISE

## Non-blocking warnings

### 1. Carrying the original meta-plan into the re-run prompt risks anchoring bias

Task 2 specifies that the re-run receives "the original meta-plan (from `$SCRATCH_DIR/{slug}/phase1-metaplan.md`)" as context alongside the constraint directive. This is a reasonable design choice -- it gives nefario grounding to preserve scope and formatting depth. However, there is a prompt engineering trade-off: the original meta-plan contains planning questions and rationale for the *old* team composition. A Claude model receiving both the original meta-plan and the constraint "produce output at the same depth and format" will tend to anchor on the original's framing, potentially under-weighting new agents' domain relevance or carrying forward stale planning questions for removed agents.

**Mitigation already present**: The constraint directive says "generate planning consultations for ALL agents in the revised team" and "re-evaluate the cross-cutting checklist against the new team." These are good countermeasures. The risk is low but worth noting -- if re-run outputs appear too similar to originals in practice, the fix would be to pass only the original's *structural template* (section headers, scope, format) without the content of individual consultation entries.

**No action needed now.** Monitor re-run output quality after deployment.

### 2. Context window budget for the re-run spawn is not accounted for

The re-run spawns nefario as a subagent with: the original task description, the full original meta-plan, the structured delta, and the constraint directive. A typical meta-plan for a 6-8 agent team is 2,000-4,000 tokens. The constraint directive adds ~200 tokens. The original task description varies but can be 500-2,000 tokens. Total re-run prompt: ~3,000-6,500 tokens input.

This is well within budget for a sonnet or opus spawn (200K context). The concern is not context window overflow but rather token cost: the re-run is effectively a full META-PLAN invocation at opus pricing ($5/MTok input, $25/MTok output), triggered by a user adjustment that might not warrant that expense.

**No action needed.** The 3+ change threshold is a reasonable heuristic to limit unnecessary re-runs. The cost per re-run (~$0.05-0.15) is acceptable for an opus orchestration session.

### 3. Constraint directive design is well-calibrated

The constraint directive in Task 2 is well-structured: 7 items, mix of positive instructions ("generate planning consultations for ALL agents") and boundary constraints ("do NOT change the fundamental scope"). This is the right approach for Claude 4.x models -- positive framing with explicit boundaries. The directive is neither too restrictive (it allows nefario to exercise judgment on cross-cutting checklist re-evaluation) nor too loose (scope and agent roster are locked).

One refinement worth considering: the directive says "preserve external skill integration decisions unless invalidated." The word "invalidated" is ambiguous -- invalidated by what? If team composition changes could invalidate a skill integration decision, specify the trigger (e.g., "unless the added/removed agents change which domains are covered"). This is minor.

### 4. Reviewer gate re-evaluation as in-session operation is the correct call

Task 3 specifies that the reviewer re-evaluation for substantial changes is an "in-session re-evaluation" rather than spawning nefario as a subagent. This is the right architectural choice for two reasons:

1. **Reviewer selection is lightweight reasoning.** It is matching 6 pool members against the delegation plan's domain signals. This does not require a separate context window or agent spawn. The calling nefario session already has the full delegation plan in context.

2. **Subagent spawn would be disproportionate.** A nefario META-PLAN spawn for reviewer re-evaluation would carry ~30 seconds of latency and ~$0.05-0.10 of opus cost for what is essentially a re-scoring of 6 candidates. The in-session approach is faster, cheaper, and simpler.

The risk is that the nefario session's context window may be large by the time Phase 3.5 reviewer adjustments happen (after Phase 1 + Phase 2 + Phase 3 + initial Phase 3.5 picks). But reviewer re-evaluation is a focused operation that does not require the model to synthesize across the full context -- it only needs the delegation plan and the discretionary pool roster. This is well within the model's capability even at high context utilization.

### 5. The "nefario ignoring constraint directive" risk is low but real

The concern about nefario ignoring constraints during re-run is a valid prompt engineering risk. However, the mitigation is already strong:

- The constraint directive is delivered as part of the META-PLAN spawn prompt, not as a system-level instruction that could be overshadowed.
- The re-run output goes through the Team Approval Gate again, so the user has a second opportunity to catch scope drift.
- The output file is separate (`phase1-metaplan-rerun.md`), enabling diff-based review if needed.

The main scenario where nefario could drift is if the team change implies a fundamentally different task interpretation (e.g., removing all frontend agents and adding all backend agents on a full-stack task). The constraint directive says "do NOT change the fundamental scope" but nefario might legitimately re-weight priorities within the scope. This is acceptable behavior, not a bug.

## Summary

The delegation plan is sound from a prompt engineering and multi-agent architecture perspective. The re-run prompt design is well-structured, the constraint directive is appropriately calibrated, and the reviewer gate in-session re-evaluation is the correct architectural choice. The warnings above are observational -- none require changes before execution.
