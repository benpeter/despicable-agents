## Domain Plan Contribution: ai-modeling-minion

### Recommendations

**Advisory mode is architecturally a mode, not a structurally different process.** After analyzing the nine-phase architecture, the existing MODE system, and the precedent set by `sdk-evaluation-proposal.local.md`, my assessment is that advisory orchestration is "Phases 1-3 with a different synthesis output format, no Phase 3.5, and no Phases 4-8." This maps cleanly to a new `MODE: ADVISORY` within nefario's existing mode-based dispatch, not a separate skill.

Here is the phase-by-phase analysis:

**Phase 1 (Meta-Plan): Applies identically.** Advisory mode still needs nefario to analyze the question, consult the delegation table, and select which specialists to consult. The meta-plan structure is unchanged -- the output is "which specialists should weigh in on this question" regardless of whether the outcome is code changes or a recommendation report. The Team Approval Gate applies unchanged.

**Phase 2 (Specialist Planning): Applies identically.** Specialists contribute their domain expertise to the question. The prompt structure is the same: "Apply your domain expertise to the planning question." The output format (Recommendations, Proposed Tasks, Risks, Additional Agents) applies -- except "Proposed Tasks" shifts from "tasks to execute" to "considerations/findings for the report." This is a semantic shift, not a structural one, and does not require prompt changes because the specialist prompt already says "specific tasks that should be in the execution plan" and advisory specialists would naturally interpret this as "specific items for the advisory report." The current orchestration we are in right now is itself an example of this working.

**Phase 3 (Synthesis): Applies with a different output target.** This is the key divergence point. In normal mode, synthesis produces an execution plan with task prompts, agent assignments, dependencies, and gates. In advisory mode, synthesis produces a structured recommendation report -- the team's consensus, areas of agreement and disagreement, the recommendation, and supporting rationale. The SYNTHESIS mode prompt would need a conditional: "If advisory mode, produce an advisory report instead of an execution plan."

**Phase 3.5 (Architecture Review): Does not apply.** Architecture review exists to catch security gaps, test coverage holes, YAGNI violations, and intent drift in an *execution plan* before code runs. In advisory mode, there is no execution plan and no code will run. The review targets (security surface, test strategy, over-engineering) are meaningless for a recommendation document. Forcing Phase 3.5 on advisory output would produce nonsensical reviews -- margo cannot assess YAGNI on a recommendation, security-minion cannot audit attack surface that does not exist.

However, there is a legitimate question: should the advisory report itself be reviewed for quality? I argue no, because:
1. The synthesis already incorporates specialist perspectives (including conflicting ones).
2. The user reads and evaluates the advisory report directly -- it is not executed blindly.
3. Adding review to advisory mode starts rebuilding the full execution pipeline for a fundamentally different use case.

**Phases 4-8: Do not apply.** There is no execution, no code to review, no tests to run, no deployment, and no documentation to update. The advisory report IS the deliverable.

**Report generation: Partially applies, with modifications.** The existing report infrastructure (companion directory, scratch files, TEMPLATE.md) provides useful structure. Advisory reports should use a simplified version of the existing template -- frontmatter with `mode: advisory`, Summary, Original Prompt, Key Findings/Recommendations (replacing Key Design Decisions), Phase narrative (Phases 1-3 only), Agent Contributions, and Working Files. No Execution, Verification, or Test Plan sections.

### Summary: Phase Applicability

| Phase | Normal/Plan Mode | Advisory Mode | Rationale |
|-------|-----------------|---------------|-----------|
| 1 - Meta-Plan | Yes | Yes | Same specialist selection process |
| 2 - Specialist Planning | Yes | Yes | Same domain expertise contribution |
| 3 - Synthesis | Yes (execution plan) | Yes (advisory report) | Different output format, same consolidation logic |
| 3.5 - Architecture Review | Yes | **No** | No execution plan to review |
| 4 - Execution | Yes | **No** | No code changes |
| 5 - Code Review | Conditional | **No** | No code produced |
| 6 - Test Execution | Conditional | **No** | No tests to run |
| 7 - Deployment | Conditional | **No** | No deployment |
| 8 - Documentation | Conditional | **No** | Report IS the documentation |

### Why MODE: ADVISORY, not a separate skill

**Shared infrastructure.** Advisory mode reuses Phase 1 (meta-plan with delegation table), Phase 2 (specialist spawning and contribution collection), and Phase 3 (synthesis with conflict resolution). This is roughly 60-70% of the orchestration logic. A separate skill would duplicate all of this, creating two divergent copies of the same specialist consultation pipeline.

**Precedent within the existing design.** MODE: PLAN already exists as a simplified alternative that skips Phase 2 and Phase 3.5. MODE: ADVISORY is the same pattern: a mode that modifies the phase pipeline. The architectural precedent is "modes control which phases run," not "different phase sets require different skills."

**Clean conditional logic.** The branching point is simple and localized:
- After Phase 3, if advisory mode: generate advisory report, skip to wrap-up.
- After Phase 3, if normal mode: proceed to Phase 3.5 and execution.

This is a single conditional at one point in the SKILL.md flow, not dispersed branching throughout the document.

**Shared report infrastructure.** Advisory reports can use the same `docs/history/nefario-reports/` directory, the same companion directory pattern, the same scratch file structure. Only the report template needs a conditional section set.

### Specific implementation shape (for synthesis prompt)

The SYNTHESIS mode in nefario's AGENT.md would need a conditional output section. When the synthesis prompt includes an `ADVISORY: true` directive:

Instead of producing:
- Execution plan with task prompts, agent assignments, dependencies, gates

Produce:
- **Executive Summary**: 2-3 sentence answer to the question
- **Team Consensus**: Areas of agreement across specialists
- **Dissenting Views**: Where specialists disagreed, with reasoning from both sides
- **Recommendation**: The team's recommendation with confidence level (HIGH/MEDIUM/LOW)
- **Supporting Evidence**: Key findings organized by domain
- **Risks and Caveats**: What could invalidate the recommendation
- **Next Steps**: If the recommendation is adopted, what the implementation path looks like (this naturally feeds into a follow-up `/nefario` execution orchestration)

This format is more useful than an execution plan because it preserves the deliberation -- the user sees not just the conclusion but the reasoning and disagreements.

### Interaction with existing modes

| Mode | When Used | Phase Pipeline |
|------|-----------|---------------|
| META-PLAN | Default (Phase 1 always) | Phase 1 only |
| SYNTHESIS | Default (Phase 3 always) | Phase 3 only |
| PLAN | User-explicit shortcut | Phase 1+3 combined, skip 2 and 3.5 |
| **ADVISORY** | User-explicit flag | Phases 1-3, skip 3.5-8, advisory report output |

ADVISORY does not conflict with PLAN. They are orthogonal: PLAN controls specialist consultation depth, ADVISORY controls the output target. In theory they could combine (PLAN + ADVISORY = nefario produces an advisory report without consulting specialists), but this edge case is not worth designing for initially -- start with full advisory (Phases 1-3) and add shortcuts later if needed.

### SKILL.md complexity impact

The SKILL.md changes are localized:

1. **Argument parsing**: Add `--advisory` flag recognition (3-5 lines).
2. **Phase 3 synthesis prompt**: Add a conditional block for advisory output format (~20 lines).
3. **After Phase 3**: Add a branch: "If advisory mode, skip to advisory wrap-up" (~5 lines).
4. **Advisory wrap-up**: Simplified wrap-up that generates the advisory report, commits, optionally creates PR (~30-40 lines).
5. **Report template**: Add `mode: advisory` conditional sections (~20 lines in TEMPLATE.md).

Total SKILL.md growth: approximately 60-70 lines. This is modest relative to the 1200-line current size, and it is concentrated in two locations (post-Phase 3 branch and advisory wrap-up), not dispersed.

A separate skill, by contrast, would need to duplicate the entire Phase 1-3 pipeline (~400+ lines of SKILL.md) plus add its own wrap-up, argument parsing, and path resolution -- likely 500+ lines in a new file.

### Risks and Concerns

1. **Scope creep in synthesis output.** The advisory synthesis prompt needs careful design to produce a recommendation report rather than an execution plan. If the prompt is vague, nefario may produce a hybrid that is neither a clear recommendation nor a usable execution plan. Mitigation: the ADVISORY directive in the synthesis prompt must be explicit about the output format and include a negative constraint ("Do NOT produce task prompts or agent assignments").

2. **Report format divergence.** Advisory reports and execution reports share a template but have very different section sets. If both use TEMPLATE.md with conditionals, the template becomes harder to read. Mitigation: consider a separate ADVISORY-TEMPLATE.md, referenced from the same TEMPLATE.md location. This is a minor complexity increase but avoids conditional sprawl in one file.

3. **User confusion about when to use advisory mode.** Users might not know when to use `--advisory` vs. just running `/nefario evaluate X and write a report`. The line between "advisory orchestration" and "execution orchestration that happens to produce a report" is not always clear. Mitigation: clear documentation of the difference, and nefario could detect advisory-like prompts and suggest the flag (soft, not mandatory).

4. **The "Phase 3.5 for advisory" debate.** Some team members may argue advisory reports should still get governance review (lucy for intent alignment, margo for simplicity). My position: the advisory report is presented to the user for evaluation, not executed. Review adds latency without value -- the user IS the reviewer. If this becomes contentious, it could be offered as an optional `--with-review` flag on advisory mode.

### Additional Agents Needed

None. The four-agent team (devx-minion for interface design, ai-modeling-minion for architecture, margo for YAGNI assessment, lucy for convention alignment) covers the key dimensions. The question is self-contained within orchestration design -- it does not touch security, testing, frontend, data, or other domains.
