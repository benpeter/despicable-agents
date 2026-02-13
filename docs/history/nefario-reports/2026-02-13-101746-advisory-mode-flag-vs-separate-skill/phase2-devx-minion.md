# Domain Plan Contribution: devx-minion

## Recommendations

### Strong recommendation: Flag on `/nefario`, not a separate skill

Advisory-only orchestration should be a flag (`--advisory`) on the existing `/nefario` skill, not a separate `/nefario-advisory` skill. The reasoning follows from CLI design principles, the existing skill architecture, and the principle of least surprise.

#### 1. Discoverability strongly favors a flag

A flag is discovered through the existing entry point. A developer who knows `/nefario` discovers `--advisory` through help text, argument hints, or documentation. A separate skill requires the developer to *already know it exists* to find it -- the classic discoverability dead end.

The `argument-hint` in SKILL.md frontmatter already serves as inline documentation: `"#<issue> | <task description>"`. Extending this to `"[--advisory] #<issue> | <task description>"` immediately signals the capability at invocation time.

With a separate skill, the user has to first know about `/nefario-advisory`, then wonder how it differs from `/nefario`, and then figure out which one to use. The decision cost is imposed on every invocation, not just the first.

#### 2. Cognitive load analysis: flag wins

**Flag model** (1 concept, 2 modes): "/nefario does orchestration. Sometimes I want it to just advise, not execute." The mental model of what nefario *is* doesn't change -- it's still the orchestrator. The flag modifies what it *does* with the result.

**Separate skill model** (2 concepts, 2 entry points): "There's /nefario for doing things and /nefario-advisory for thinking about things." The user must now maintain two mental models and decide between them. Worse, they'll wonder: "What else am I missing? Is there a /nefario-review too?"

The cognitive load difference is small but compounds. Every new skill is a permanent entry in the user's mental index. A flag is filed under the existing entry.

#### 3. Principle of least surprise: same input, different depth

The core invocation pattern doesn't change: `/nefario --advisory #87` or `/nefario --advisory Should we refactor the config system?`. The user provides the same kind of input (an issue or a task description). The orchestrator assembles the same kind of team. The phases proceed the same way through planning. The only difference is where the workflow stops and what it produces at the end.

This is exactly the pattern where a flag is appropriate: same input structure, same core workflow, different output behavior. Compare: `git log` vs `git log --oneline` -- same command, different depth of output. Not `git log` vs `git log-short`.

A separate skill would surprise users who expect the same input grammar. They'd have to learn: "Does /nefario-advisory support issue mode? Does it have the same argument parsing?" With a flag, the answer is always "yes, it's the same command."

#### 4. The `/despicable-prompter` precedent does NOT support a separate skill

`/despicable-prompter` is a separate skill because it serves a *fundamentally different purpose* with a *fundamentally different workflow*:

| Aspect | `/nefario` | `/despicable-prompter` |
|--------|-----------|----------------------|
| Purpose | Orchestrate specialist teams | Transform rough ideas into briefings |
| Workflow | 9-phase multi-agent process | Single-pass text transformation |
| Output | Code changes, PRs, reports | A `/nefario` command in a code block |
| Agents involved | Up to 27 specialists | None (solo transformation) |
| Duration | 10-60+ minutes | Seconds |

The relationship between `/nefario` and `/despicable-prompter` is *pipeline* -- one feeds into the other. They are different tools for different stages.

Advisory mode, by contrast, is the *same orchestration workflow* with a different terminal condition. It shares the same team assembly (Phase 1), the same specialist consultation (Phase 2), the same synthesis (Phase 3), and the same architecture review (Phase 3.5). It diverges only at Phase 4 (no execution) and produces a report instead of code. This is a mode, not a different tool.

#### 5. The flag changes WHEN nefario stops, not WHAT nefario is

The critical question is: "Does `--advisory` change the mental model of what `/nefario` does?"

No. Nefario is an orchestrator. Orchestration includes both *planning* and *executing*. Advisory mode exercises the planning capability without the executing capability. The mental model remains: "nefario coordinates specialists to analyze complex tasks." The flag says: "this time, just the analysis."

Compare: a general contractor who sometimes does site surveys without building anything. They're still a general contractor. They haven't become a different profession.

#### 6. Implementation simplicity favors a flag

The SKILL.md already has a phase structure that naturally supports early termination:

- Phases 1-3.5: Planning and review (shared by both modes)
- Phase 4-8: Execution and verification (skipped in advisory mode)

A flag adds a conditional branch at the Phase 3.5/Phase 4 boundary. A separate skill would duplicate 80%+ of SKILL.md content (all of Phases 1-3.5, argument parsing, issue fetch, scratch directory management, team approval gates, reviewer gates, compaction checkpoints) to diverge only at the end.

This duplication would be a maintenance burden. Every improvement to team assembly, specialist prompting, or synthesis would need to be applied in two places. The two skills would inevitably drift.

### Recommended flag design

**Flag name**: `--advisory`

**Why not alternatives**:
- `--dry-run`: Implies the output is disposable/preview. Advisory reports are substantive deliverables.
- `--plan-only`: Confuses with `MODE: PLAN` (which already exists as a simplified planning mode in the nefario AGENT.md).
- `--report`: Describes the output format, not the intent. All nefario runs produce reports.
- `--no-execute`: Negative framing. Tells the user what it *won't* do rather than what it *will* do. Violates positive framing principle.
- `--evaluate`: Close second choice, but "advisory" better conveys that the output is a team recommendation, not a solo evaluation.

**Argument parsing extension**:

```
Arguments: `[--advisory] #<issue> | <task description>`
```

The `--advisory` flag is position-independent but conventionally placed first:
- `/nefario --advisory #87`
- `/nefario --advisory Should we adopt the Agent SDK?`
- `/nefario #87 --advisory` (also valid)

**Frontmatter update**:

```yaml
argument-hint: "[--advisory] #<issue> | <task description>"
```

**Behavior changes when `--advisory` is active**:

1. **Phase announcements**: Replace execution-related language. "Phase 4: Execution" becomes "Phase 4: Report Generation" (or simply skip Phase 4 and proceed to report).

2. **Phase 4-8**: Replaced entirely with a report generation phase. No branch creation, no code changes, no commits, no PR.

3. **Execution Plan Approval Gate**: Repurposed as "Advisory Plan" gate. The task list shows analysis tasks rather than execution tasks. The user approves the advisory scope, not an execution plan.

4. **Output**: A structured advisory report written to the report directory (same path resolution as execution reports). The report consolidates specialist analyses, synthesis, and review verdicts into a decision document -- similar to the `sdk-evaluation-proposal.local.md` already produced manually in this project.

5. **Status line prefix**: `⚗︎ ADV` instead of `⚗︎ P<N>` to visually distinguish advisory sessions.

6. **Git**: No branch creation, no commits, no PR. The report is written to the working tree in the report directory. If the user wants to commit it, they do so manually.

7. **Communication protocol**: CONDENSE lines and phase markers are adapted but follow the same visual hierarchy. The output discipline is lighter (fewer phases = less to suppress).

## Proposed Tasks

1. **Extend argument parsing in SKILL.md** -- Add `--advisory` flag detection before issue/free-text parsing. Set a session-level `advisory-mode: true` context variable. Deliverable: updated Argument Parsing section. Dependencies: none.

2. **Add advisory workflow section to SKILL.md** -- Define what happens at the Phase 3.5/Phase 4 boundary when `--advisory` is active. Specify report generation steps, output format, and scratch directory additions. Deliverable: new "Advisory Mode" section in SKILL.md. Dependencies: Task 1.

3. **Define advisory report format** -- Specify the report structure for advisory-only runs. Should be a superset of the execution report format's planning sections, minus the execution/verification sections. Include: original prompt, team composition, specialist contributions (summaries + links), synthesis, review verdicts, final recommendation, dissenting positions. Deliverable: report template specification. Dependencies: Task 2.

4. **Update nefario AGENT.md** -- Add advisory awareness to the agent's core knowledge so it can respond to `MODE: ADVISORY-META-PLAN` or similar mode markers if the advisory flag needs to influence nefario's planning behavior (e.g., different planning questions that are analysis-focused rather than execution-focused). Dependencies: Task 1.

5. **Update Phase 1 meta-plan prompt** -- When `--advisory` is active, nefario should know the outcome is a report, not code. This may influence which specialists are selected (e.g., product-marketing-minion might be more relevant for advisory on a feature decision). Deliverable: advisory variant of the Phase 1 prompt template. Dependencies: Task 4.

## Risks and Concerns

1. **SKILL.md complexity growth**: The SKILL.md is already ~1200 lines. Adding advisory mode adds another conditional branch to an already-complex workflow. Mitigation: the advisory branch is simpler than execution (it removes phases rather than adding them), so the net complexity increase is modest. The advisory section can be self-contained, not interleaved with execution logic.

2. **Scope creep from advisory to execution**: Users may invoke `--advisory` and then say "actually, go ahead and implement it." The skill needs a clear response: "Advisory mode is read-only. To execute, re-run without `--advisory`." This is a firm boundary, not a prompt.

3. **Planning questions may differ**: In advisory mode, nefario should ask specialists different questions. Instead of "what tasks should be in the execution plan?" the question should be "what is your assessment of this question/decision?" The Phase 2 prompt template needs an advisory variant. This is the most subtle implementation detail.

4. **Report format needs design**: The execution report format (nefario-reports) is designed around execution outcomes. An advisory report is a different document type (closer to a decision proposal). The format needs thought -- it's not just "execution report minus the execution."

## Additional Agents Needed

- **ux-strategy-minion**: Should evaluate the advisory mode's interaction design -- specifically the modified gate presentations, the report-as-deliverable UX, and whether users will understand the advisory/execution distinction without confusion. (If already on the team, disregard.)

No other additional agents needed. The planning question is well-scoped to skill architecture and DX design.
