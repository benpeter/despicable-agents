# Domain Plan Contribution: ux-strategy-minion

## Recommendations

### Gate Inventory and Gap Analysis

I identified **8 distinct gate/decision points** in the nefario orchestration. For each, I analyzed: (a) what information the user needs, (b) what the current format provides, and (c) the gap.

---

#### Gate 1: Execution Plan Approval Gate

**When**: After Phase 3.5, before Phase 4.

**(a) What the user needs**:
- One-sentence summary of what the plan will accomplish
- The task list with deliverables, dependencies, and gate markers
- What changed due to architecture review (advisories as deltas)
- Risks and how they're mitigated
- The scratch directory path so they can drill into details
- Confidence that the plan matches their original intent

**(b) What the current format specifies**:
- Instant orientation line with goal summary + task/gate/advisory counts
- Compact task list (title, deliverable summary, dependencies, agent, gate markers)
- Advisories block with CHANGE/WHY format, domain-attributed
- Risks and conflict resolutions block
- Review summary (N APPROVE, N ADVISE, N BLOCK)
- Full plan reference path

**(c) Gap**: **Small**. This is the best-specified gate. Two minor gaps:
1. **No link to the original prompt**. The user approved a request, then planning happened across multiple phases. By the time this gate appears, the user may have lost track of what they originally asked for. Restating the original request (or a compressed version) would let them verify alignment without reconstructing from memory.
2. **Scratch directory path appears only in the FULL PLAN reference**. The user cannot easily explore other scratch artifacts (phase2 contributions, phase3.5 verdicts) from the gate output -- only the synthesis file is referenced. Adding a one-line "Working directory: $SCRATCH_DIR/{slug}/" would make the full context browsable.

**Severity**: Low. This gate already works well.

---

#### Gate 2: Mid-Execution Approval Gate (Decision Brief)

**When**: During Phase 4, at batch boundaries when a gated task completes.

**(a) What the user needs**:
- What was produced and why it matters
- What the key design choices were (and what was rejected)
- What depends on this decision (blast radius)
- Enough content summary to decide without opening the deliverable file
- Where to find the full deliverable if they want to inspect it
- What approving vs. rejecting means concretely

**(b) What the current format specifies**:
- APPROVAL GATE title
- Agent and blocked tasks
- DECISION: one-sentence summary
- RATIONALE: 3-5 bullets including rejected alternatives
- IMPACT: consequences of approving vs. rejecting
- DELIVERABLE: file path
- Confidence level

**(c) Gap**: **HIGH -- this is the highest-impact gap in the entire system.**

The DELIVERABLE field shows only a file path. The user must open and read an external file to understand what they're approving. This is the exact friction described in the issue: "users approve or reject blindly because the relevant information isn't surfaced alongside the decision point."

Specific problems:
1. **No deliverable summary**: The DECISION line describes the *decision*, but not the *content* of the deliverable. For example, a database schema gate might say "DECISION: Use PostgreSQL with normalized tables for user data" but the deliverable file contains the actual schema definition, migration plan, and field-level design choices. The user is approving the schema without seeing the schema.
2. **No key artifacts inline**: For file-producing tasks, the user doesn't know what files were created/modified, their sizes, or their relationship to the existing codebase.
3. **No diff awareness**: If this is a modification (not a greenfield creation), the user doesn't see what changed relative to what existed before.
4. **Confidence level lacks calibration context**: "MEDIUM" means "alternatives have merit" but doesn't tell the user *which part* of the deliverable has the most uncertainty -- where should they focus their attention?

**Severity**: High. This is the primary source of blind approvals.

---

#### Gate 3: Post-Execution Phase Selection (Follow-up after Approve)

**When**: Immediately after approving a mid-execution gate.

**(a) What the user needs**:
- What each post-execution phase will do *for this specific task*
- The cost/risk tradeoff of skipping each phase
- Which phases are even applicable (some may not apply to the deliverable just approved)

**(b) What the current format specifies**:
- Four options: "Run all", "Skip docs", "Skip tests", "Skip review"
- Options ordered by ascending risk
- Freeform flag alternatives

**(c) Gap**: **Medium**.
1. **Options are generic, not task-contextualized**. "Skip tests" means different things for a database schema task vs. a UI component task. The option descriptions don't reflect what would actually be tested, reviewed, or documented for this specific deliverable.
2. **No indication of applicability**. If the task produced no code (e.g., a strategy document), offering "Skip review" for code review is noise. The options should reflect what's actually relevant.
3. **Missing time/cost signal**. Users may skip phases because they fear time cost. A lightweight signal ("~2 min" or "3 agents") would help calibrate.

**Severity**: Medium. Users likely default to "Run all" or "--skip-post", making nuanced decisions rare. But the friction exists when they want to make an informed partial skip.

---

#### Gate 4: Reject Confirmation (Secondary gate after Reject)

**When**: After user selects "Reject" at a mid-execution gate.

**(a) What the user needs**:
- Which specific downstream tasks will be dropped
- What work will be wasted (already-completed upstream work)
- Whether there's a less drastic alternative

**(b) What the current format specifies**:
- Confirmation prompt: "Reject <task>? This will also drop: <list dependents>"
- Two options: "Confirm reject" / "Cancel"

**(c) Gap**: **Medium**.
1. **No description of dependent tasks**. The format says "<list dependents>" but doesn't specify whether these are just task titles or include enough context to understand the cascade. Task titles alone may be insufficient -- the user needs to understand what they're losing.
2. **No mention of completed work**. If upstream tasks already executed to produce inputs for this gate, that work is effectively wasted. The user should know the sunk cost.
3. **No alternative framing**. "Request changes" is the less drastic path, but the reject confirmation doesn't remind the user this option exists.

**Severity**: Medium. Rejection is rare, but when it happens, the consequences are high and the user needs full context.

---

#### Gate 5: Calibration Check

**When**: After 5 consecutive approvals without changes.

**(a) What the user needs**:
- Confirmation that the system noticed a pattern
- Whether the gates are actually adding value or just creating friction
- What "fewer gates next time" would concretely mean

**(b) What the current format specifies**:
- "5 consecutive approvals without changes. Gates well-calibrated?"
- Two options: "Gates are fine" / "Fewer gates next time"

**(c) Gap**: **Low**.
1. **No data on gate quality**. The prompt could briefly summarize what was gated (e.g., "Gates covered: schema design, API contract, auth model") so the user can evaluate whether those were *worth* gating. Without this, the user is answering based on feeling rather than evidence.
2. **"Fewer gates next time" is vague**. It doesn't specify what the system will do differently. Will it consolidate? Raise the threshold? The user is approving a process change without understanding its effect.

**Severity**: Low. This is a meta-gate that exists to prevent fatigue. It doesn't block work.

---

#### Gate 6: Code Review BLOCK Escalation (Post-Execution)

**When**: After 2 unsuccessful auto-fix attempts for a code review finding.

**(a) What the user needs**:
- What the specific code problem is
- Where it is (file and line range)
- What was tried to fix it and why it failed
- Whether this is a real problem or a false positive
- What the consequences of accepting it as-is are

**(b) What the current format specifies**:
- VERIFICATION ISSUE title
- Phase, Agent, Finding (one sentence), Producing agent, File path
- "Auto-fix attempts: 2 (unsuccessful)"
- Three options: "Accept as-is" / "Fix manually" / "Skip verification"

**(c) Gap**: **High**.
1. **No code context**. The format shows a file path but no code snippet. The user is asked to decide whether a code problem is acceptable without seeing the code. This is the same DELIVERABLE problem as Gate 2 but more acute because the user needs to evaluate a specific technical finding.
2. **No fix attempt history**. "2 (unsuccessful)" doesn't explain what was tried. Did the fix introduce a regression? Did it not compile? Was it the wrong approach? The user needs this to decide whether to accept as-is or try manually.
3. **No severity/risk framing**. Is this a crash-causing bug, a performance issue, a style nit that the reviewer over-classified? The one-sentence finding doesn't convey severity clearly enough for a go/no-go decision.
4. **"Skip verification" is extremely broad**. It skips *all remaining* code review and test checks, not just this finding. The user may not realize the blast radius.

**Severity**: High. The user is making a technical judgment call with insufficient information.

---

#### Gate 7: Security-Severity BLOCK Escalation (Pre-auto-fix)

**When**: During Phase 5 when a security-severity finding is detected, before auto-fix proceeds.

**(a) What the user needs**:
- What the security vulnerability is
- How exploitable it is (severity classification)
- What the auto-fix will do
- Whether manual review is warranted before proceeding

**(b) What the current format specifies**:
- "max 5 lines" escalation brief (no structured format defined)

**(c) Gap**: **High**.
1. **No structured format defined**. The SKILL.md says "SHOW: max 5-line escalation brief" but doesn't define what those 5 lines contain. This is the least specified gate in the system.
2. **No response options defined**. Unlike every other gate, there's no AskUserQuestion with structured options. The user sees an unstructured brief and... then what? The flow is ambiguous.
3. **No severity classification**. Security findings range from informational to critical. The user needs a severity indicator to calibrate their response.
4. **No proposed fix preview**. The auto-fix is about to proceed -- the user should know what the fix will do before it happens.

**Severity**: High. Security decisions should have the *most* context, not the least. This gate handles the highest-risk findings in the entire system and has the least defined format.

---

#### Gate 8: PR Creation Prompt

**When**: At wrap-up, after report is committed.

**(a) What the user needs**:
- What will be in the PR (summary of changes)
- The branch name
- Whether all verification passed
- Any outstanding items

**(b) What the current format specifies**:
- "Create PR for nefario/<slug>?"
- Two options: "Create PR" / "Skip PR"

**(c) Gap**: **Low-Medium**.
1. **No summary of what the PR contains**. The user is asked to create a PR without a preview of the PR title or body. They should see the PR title and a 2-3 line summary before deciding.
2. **No verification status**. If verification had issues (accepted-as-is BLOCKs, skipped phases), the user should be reminded before creating a public PR.
3. **Branch name not shown in the question**. It's in the description ("Push branch and open pull request") but the actual branch name isn't visible.

**Severity**: Low. PR creation is low-risk (it's easily amended or closed).

---

#### Gate 9: BLOCK Impasse Escalation (Phase 3.5, after 2 revision rounds)

**When**: When architecture review BLOCKs persist after 2 revision rounds.

**(a) What the user needs**:
- What each reviewer's position is
- Why the revision didn't resolve the disagreement
- What the tradeoffs are between the competing positions
- What their options are (override, restructure, abandon)

**(b) What the current format specifies**:
- "Present the impasse to the user with all reviewer positions and let the user decide how to proceed."
- No structured format defined.
- No AskUserQuestion options defined.

**(c) Gap**: **High**.
1. **No structured format**. The SKILL.md says to present the impasse but doesn't define how. This could result in a wall of text dumping all reviewer positions without structure.
2. **No decision options**. Unlike every other gate, no AskUserQuestion is specified. The user doesn't know what their options are -- override the blocker? Revise the plan themselves? Abandon?
3. **No synthesis of the disagreement**. Raw reviewer positions without nefario's analysis of why they conflict leaves the user to do the synthesis work themselves.

**Severity**: High. This is a rare but critical decision point where the planning system has exhausted its ability to resolve conflict. The user needs maximum context and clear options, but gets the least structured format.

---

### Priority-Ranked Improvement Recommendations

Based on the gap analysis, I recommend changes in this priority order:

#### Priority 1: Mid-Execution Decision Brief (Gate 2) -- Deliverable Summary

**Problem**: DELIVERABLE field shows only a file path. Users approve blind.

**Recommendation**: Add a DELIVERABLE SUMMARY section between IMPACT and DELIVERABLE that provides a 3-7 line structured summary of what the deliverable contains. This is NOT the full deliverable -- it's a scannable abstract.

The format should vary by deliverable type:
- **Schema/model**: Key entities, relationships, notable constraints
- **API contract**: Endpoints, methods, notable design choices
- **Strategy/architecture document**: Key recommendations, scope
- **Code**: Files created/modified with one-line descriptions, total lines changed

Example for a database schema gate:
```
DELIVERABLE SUMMARY:
  Tables: users, sessions, permissions (3 tables, 14 columns total)
  Key choices: UUID primary keys, soft deletes, created_at/updated_at on all tables
  Migration: Single migration file, reversible
  Omitted: Indexing strategy (deferred to performance testing phase)
```

The producing agent should generate this summary as part of its completion message. The summary template should be included in the agent's prompt (added during synthesis).

#### Priority 2: Security BLOCK Escalation (Gate 7) -- Define Structured Format

**Problem**: No structured format, no response options, highest-risk gate with least definition.

**Recommendation**: Define a structured format and AskUserQuestion:

```
SECURITY FINDING: <title>
Severity: CRITICAL | HIGH | MEDIUM
File: <path>:<line-range>
Finding: <one-sentence description>
Proposed fix: <one-sentence description of what auto-fix will do>

Options via AskUserQuestion:
  1. "Proceed with auto-fix" -- "Apply the proposed fix automatically." (recommended)
  2. "Review first" -- "Show the affected code before deciding."
  3. "Fix manually" -- "Pause orchestration. You fix the code, then resume."
  4. "Accept risk" -- "Proceed without fixing. Document as known risk."
```

#### Priority 3: Code Review BLOCK Escalation (Gate 6) -- Add Code Context

**Problem**: User makes technical judgment without seeing code or fix history.

**Recommendation**: Expand the escalation brief:

```
VERIFICATION ISSUE: <title>
Phase: Code Review | Agent: <reviewer> | Severity: <HIGH/MEDIUM/LOW>
Finding: <one-sentence description>
File: <path>:<line-range>

CODE CONTEXT:
  <3-5 relevant lines of code with the issue highlighted>

FIX HISTORY:
  Round 1: <what was attempted, why it didn't resolve>
  Round 2: <what was attempted, why it didn't resolve>

RISK IF ACCEPTED: <one sentence on what could go wrong>
```

Also: rename "Skip verification" to "Skip remaining checks" and add a parenthetical "(skips all remaining code review and test phases)" to make the blast radius explicit.

#### Priority 4: BLOCK Impasse Escalation (Gate 9) -- Define Structured Format

**Problem**: No structured format, no decision options for the most complex decision point.

**Recommendation**: Define a structured format:

```
PLAN IMPASSE: <one-sentence description of the disagreement>
Revision rounds: 2 of 2 exhausted

POSITIONS:
  [<reviewer-1>] BLOCK: <one-sentence position>
    Concern: <what they believe will go wrong>
  [<reviewer-2>] BLOCK: <one-sentence position>
    Concern: <what they believe will go wrong>
  [other reviewers]: <APPROVE/ADVISE summary>

CONFLICT ANALYSIS: <nefario's synthesis: why these positions are incompatible>

FULL CONTEXT: $SCRATCH_DIR/{slug}/phase3.5-{reviewer}.md

Options via AskUserQuestion:
  header: "Impasse"
  question: <the one-sentence disagreement>
  options:
    1. "Override blockers" -- "Accept the current plan despite unresolved concerns." (recommended only if majority APPROVE)
    2. "Revise plan manually" -- "Provide your own direction to resolve the conflict."
    3. "Restart planning" -- "Re-run synthesis with additional constraints."
    4. "Abandon" -- "Cancel this orchestration."
```

#### Priority 5: Post-Execution Phase Selection (Gate 3) -- Contextualize Options

**Problem**: Generic options don't reflect what's actually applicable or what each phase will do.

**Recommendation**: Add a one-line description of what each phase will concretely do for this deliverable, and suppress options that don't apply:

```
Post-exec options:
  1. "Run all" -- "Code review (3 reviewers) + tests (unit, lint) + docs (API reference)" (recommended)
  2. "Skip docs" -- "Skip API reference update."
  3. "Skip tests" -- "Skip unit tests and linting."
  4. "Skip review" -- "Skip code quality review by code-review-minion, lucy, margo."
```

If a phase doesn't apply (e.g., no code was produced, so code review is N/A), note it: "Code review: N/A (no code files produced)."

#### Priority 6: Execution Plan Approval Gate (Gate 1) -- Add Original Request Echo

**Problem**: User may have lost track of what they originally asked for.

**Recommendation**: Add a one-line original request echo before the task list:

```
EXECUTION PLAN: <goal summary>
REQUEST: "<truncated original prompt, max 80 chars>..."
Tasks: N | Gates: N | Advisories: N
```

This costs one line and enables instant alignment verification.

#### Priority 7: PR Creation (Gate 8) and Reject Confirmation (Gate 4)

**PR Creation**: Add the PR title and branch name to the question, plus verification status if any issues were accepted as-is.

**Reject Confirmation**: Expand dependent task descriptions beyond titles, mention "Request changes" as an alternative.

These are low-priority because PR creation is easily amended and rejection is rare.

---

## Proposed Tasks

### Task 1: Add DELIVERABLE SUMMARY to mid-execution gate format
- **What**: Modify the Decision Brief Format in SKILL.md to include a DELIVERABLE SUMMARY section. Define summary templates per deliverable type. Add instructions for producing agents to generate summaries in their completion messages.
- **Deliverables**: Updated SKILL.md gate format specification, updated agent prompt template with summary generation instructions.
- **Dependencies**: None.
- **Impact**: Addresses the highest-friction gap (Gate 2). Directly fulfills the issue's success criteria: "User can understand what they are approving/rejecting without opening additional files."

### Task 2: Define structured format for security BLOCK escalation
- **What**: Replace the unstructured "max 5 lines" specification with a structured format including severity, code context, proposed fix preview, and AskUserQuestion options.
- **Deliverables**: Updated SKILL.md with security escalation format specification.
- **Dependencies**: None.

### Task 3: Expand code review BLOCK escalation format
- **What**: Add CODE CONTEXT (3-5 lines), FIX HISTORY (round summaries), severity classification, and risk framing. Clarify "Skip verification" blast radius.
- **Deliverables**: Updated SKILL.md escalation format.
- **Dependencies**: None.

### Task 4: Define BLOCK impasse escalation format
- **What**: Create structured format with positions summary, conflict analysis, scratch file references, and AskUserQuestion options (override, revise manually, restart, abandon).
- **Deliverables**: Updated SKILL.md with impasse format specification.
- **Dependencies**: None.

### Task 5: Contextualize post-execution phase selection
- **What**: Update the follow-up AskUserQuestion after gate approval to include task-specific descriptions of what each phase will do, and suppress non-applicable options.
- **Deliverables**: Updated SKILL.md post-execution selection format.
- **Dependencies**: Task 1 (the post-execution selection follows the mid-execution gate, so the overall flow should be designed holistically).

### Task 6: Add original request echo and scratch directory to plan approval gate
- **What**: Add a REQUEST line echoing the truncated original prompt and a WORKING DIR line showing the scratch directory path to the execution plan approval gate format.
- **Deliverables**: Updated SKILL.md plan approval gate format.
- **Dependencies**: None.

### Task 7: Minor improvements to PR creation and reject confirmation gates
- **What**: Add PR title/branch/verification status to PR creation prompt. Expand reject confirmation with dependent task descriptions and "Request changes" reminder.
- **Deliverables**: Updated SKILL.md for both gate formats.
- **Dependencies**: None.

### Task 8: Update orchestration.md to reflect gate format changes
- **What**: Synchronize docs/orchestration.md Section 3 with the updated gate specifications in SKILL.md.
- **Deliverables**: Updated docs/orchestration.md.
- **Dependencies**: Tasks 1-7 (all format changes must be finalized first).

---

## Risks and Concerns

### Risk 1: Deliverable summaries add prompt complexity for producing agents
Adding a summary generation requirement to agent prompts increases their cognitive load. If summaries are poorly generated, the gate becomes misleading rather than helpful.
**Mitigation**: Provide clear summary templates per deliverable type. Keep summaries to 3-7 lines. Make the summary a "MUST include" in the agent's completion message format, not an optional addition.

### Risk 2: Increased gate verbosity could worsen approval fatigue
The current gates are lean. Adding DELIVERABLE SUMMARY, CODE CONTEXT, and FIX HISTORY increases the amount of text at each gate. If gates become walls of text, users will scan even less carefully.
**Mitigation**: Apply progressive disclosure. The DELIVERABLE SUMMARY is Layer 1.5 -- scannable, structured, and brief. The DELIVERABLE file path remains Layer 3 for deep dives. Total gate output should stay within 15-25 lines for mid-execution gates (currently ~10-12 lines, so adding 5-8 lines for the summary is acceptable).

### Risk 3: Security escalation format may be too rigid for diverse finding types
Security findings range from "hardcoded API key" (simple, clear fix) to "insufficient input validation across multiple entry points" (complex, ambiguous fix). A single format may not serve both well.
**Mitigation**: The proposed format is minimal (severity, finding, proposed fix). For complex findings, the "Review first" option lets the user drill in before deciding. The format accommodates both simple and complex cases through the detail in the finding sentence.

### Risk 4: Gate format changes are prompt-level, not code-level
All gates are defined in SKILL.md and AGENT.md as natural language instructions. There's no programmatic enforcement of the format. An LLM may deviate from the specified format, especially under context pressure.
**Mitigation**: This is an existing risk for all gate formats, not new. The structured AskUserQuestion calls provide programmatic anchoring for the decision options -- only the brief text above is at risk of drift. Keep format specifications concise and example-driven to maximize LLM compliance.

---

## Additional Agents Needed

- **devx-minion**: The gate formats are essentially developer-facing CLI interaction patterns. devx-minion's expertise in CLI design, error messages, and developer experience would complement the UX strategy perspective -- particularly for the code context presentation in Gate 6 and the structured option descriptions across all gates. However, this is a "nice to have" rather than essential, since the changes are primarily to specification text rather than interactive CLI code.

Otherwise: None. The current team is sufficient. The changes are specification-level (SKILL.md, AGENT.md, orchestration.md) and don't require additional domain specialists.
