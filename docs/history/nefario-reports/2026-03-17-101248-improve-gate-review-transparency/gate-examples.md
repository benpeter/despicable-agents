# Nefario Gate Examples -- Extracted from Real Sessions

Extracted from 3 real nefario orchestration sessions (March 2026):
1. **TSA Error Logging** (`#72`) -- 2-task, narrow scope
2. **RFC 3161 Timestamps** (`#41`) -- 6-task, large scope
3. **Load-Settle Strategy** (`#67`) -- 1-task, narrow scope

**Critical finding**: All three sessions used the directive `skip all approval gates`.
No AskUserQuestion calls were made in any session. All gates were auto-approved
by nefario based on the user directive. This means we have zero examples of what
the user actually sees at a gate -- only examples of what nefario says when
skipping them.

---

## 1. Gate Types Defined in SKILL.md (Prescribed Format)

### 1.1 Team Approval Gate (P1 Team)

**Prescribed format** (from SKILL.md):

```
────────────────────────────────────────────────────
TEAM: <1-sentence task summary>
Specialists: N selected | N considered, not selected

  SELECTED:
    devx-minion          Workflow integration, SKILL.md structure
    ux-strategy-minion   Approval gate interaction design
    lucy                 Governance alignment for new gate

  ALSO AVAILABLE (not selected):
    ai-modeling-minion, margo, software-docs-minion, security-minion, ...

Details: [meta-plan]($SCRATCH_DIR/{slug}/phase1-metaplan.md)
────────────────────────────────────────────────────
```

**AskUserQuestion structure**:
- `header`: "P1 Team"
- `question`: "<1-sentence task summary>"
- `options` (3, `multiSelect: false`):
  1. label: "Approve team", description: "Consult these N specialists and proceed to planning." (recommended)
  2. label: "Adjust team", description: "Add or remove specialists before planning begins."
  3. label: "Reject", description: "Abandon this orchestration."

**What actually happened (all 3 sessions)**: Gate was auto-approved.

Verbatim from TSA session:
```
Planning: consulting observability-minion, test-minion (2 specialists) | Skills: 0 discovered | Scratch: /var/folders/.../tsa-error-logging/

Team auto-approved per directive (skip all gates, defer to gru/lucy).
```

Verbatim from RFC3161 session:
```
Planning: consulting security-minion, api-design-minion, iac-minion, margo, frontend-minion, test-minion, ux-strategy-minion, software-docs-minion (auto-approved) | Skills: 0 discovered | Scratch: /var/folders/.../rfc3161-timestamps/
```

Verbatim from load-settle session:
```
Planning: consulting debugger-minion, test-minion (2 specialists) | Skills: 0 discovered | Scratch: /var/folders/.../load-settle-strategy/

Team auto-approved per gate-skip directive (2 specialists for narrow scope).
```

**Information available**: specialist names, count, scratch path.
**Information missing at gate**: no rationale per specialist, no "ALSO AVAILABLE" list, no SELECTED block formatting.

---

### 1.2 Reviewer Approval Gate (P3.5 Review)

**Prescribed format** (from SKILL.md):

```
────────────────────────────────────────────────────
REVIEWERS: <1-sentence plan summary>
Mandatory: security, test, ux-strategy, lucy, margo (always review)

  DISCRETIONARY (nefario recommends):
    <agent-name>       <rationale, max 60 chars, reference tasks>
    <agent-name>       <rationale, max 60 chars, reference tasks>

  NOT SELECTED from pool:
    <remaining pool members, comma-separated>

Details: [plan]($SCRATCH_DIR/{slug}/phase3-synthesis.md)
────────────────────────────────────────────────────
```

**AskUserQuestion structure**:
- `header`: "P3.5 Review"
- `question`: "<1-sentence plan summary>"
- `options` (3, `multiSelect: false`):
  1. label: "Approve reviewers", description: "5 mandatory + N discretionary reviewers proceed to review." (recommended)
  2. label: "Adjust reviewers", description: "Add or remove discretionary reviewers before review begins."
  3. label: "Skip review", description: "Skip architecture review. The Execution Plan Approval Gate still applies."

**What actually happened**: Auto-approved with CONDENSE note in all sessions.

Verbatim from TSA session:
```
Auto-approving reviewers per directive (5 mandatory, no discretionary). Spawning reviewers in parallel, deferring decisions to lucy and margo.
```

Verbatim from RFC3161 session:
```
Reviewers: 5 mandatory, no additional reviewers needed
```

Verbatim from load-settle session:
```
Reviewers: 5 mandatory, no additional reviewers needed. Auto-approved per gate-skip directive.
```

**Information available**: mandatory count, discretionary count.
**Information missing at gate**: no discretionary pool evaluation shown, no rationale per reviewer.

---

### 1.3 Execution Plan Approval Gate (P3.5 Plan)

**Prescribed format** (from SKILL.md):

```
────────────────────────────────────────────────────
EXECUTION PLAN: <1-sentence goal summary>
REQUEST: "<truncated original prompt, max 80 chars>..."
Tasks: N | Gates: N | Advisories incorporated: N
Working dir: [{slug}/]($SCRATCH_DIR/{slug}/)

TASKS:
  1. <Task title>                                    [agent-name, model]
     Produces: <deliverable summary>
     Depends on: none

  2. <Task title>                                    [agent-name, model]
     Produces: <deliverable summary>
     Depends on: Task 1
     GATE: Approval required before Tasks 3, 4 proceed

ADVISORIES:
  [<domain>] <artifact or concept> (Task N)
    CHANGE: <one sentence, in domain terms>
    WHY: <one sentence, self-contained rationale>

RISKS:
  - <risk description> -- Mitigation: <what the plan does about it>

CONFLICTS RESOLVED:
  - <what was contested>: Resolved in favor of <approach> because <rationale>

REVIEW: N APPROVE, N ADVISE, N BLOCK

Details: [plan]($SCRATCH_DIR/{slug}/phase3-synthesis.md)
────────────────────────────────────────────────────
```

**AskUserQuestion structure**:
- `header`: "P3.5 Plan"
- `question`: "<the orientation line goal summary>"
- `options` (3, `multiSelect: false`):
  1. label: "Approve", description: "Accept plan and begin execution." (recommended)
  2. label: "Request changes", description: "Revise the plan before execution."
  3. label: "Reject", description: "Abandon this plan entirely."

**What actually happened**: Auto-approved. The review summary was shown but no structured gate.

Verbatim from TSA session:
```
Skipping compaction checkpoint per directive. Auto-approving execution plan per directive.
```
(No task list, no advisories block, no risks block shown to user.)

Verbatim from RFC3161 session:
```
Review: 3 APPROVE, 2 ADVISE, 0 BLOCK

ADVISE notes incorporated into task prompts:
- **security-minion**: (1) HTTPS default URL, (2) DER INTEGER sign-extension for nonce, (3) soften UI verification claim text, (4) skip tolerance confirmation in code review
- **test-minion**: (1-6) All test gap items folded into Phase 6 scope
- **lucy**: (1) Evolution log prompt.md already created, (2) verify vitest.config binding need, (3) gates auto-approved per user directive
- **margo**: (1) Task 4 kept separate for clarity but noted as potentially minimal, (2-3) noted
```
(Review verdict summary shown. ADVISE notes listed by agent. But NO task list, no EXECUTION PLAN block, no risks/conflicts block.)

Verbatim from load-settle session:
```
Review: 4 APPROVE, 1 ADVISE (security-minion: add post-settle limitExceeded re-check). Lucy's two advisories are procedural reminders for evolution log -- will address at wrap-up.

I'll incorporate security-minion's ADVISE (add second `limitExceeded` check after settle delay) into the task prompt. Skipping compaction checkpoint and execution plan gate per directive.
```
(Inline review summary. Security advisory explained. But NO structured gate presentation.)

---

### 1.4 Mid-Execution Gate (P4 Gate)

**Prescribed format** (from SKILL.md):

A decision brief is presented before each gate, then:

**AskUserQuestion structure**:
- `header`: "P4 Gate"
- `question`: "Task N: <task title>" followed by " -- " and the DECISION line from the brief
- `options` (4, `multiSelect: false`):
  1. label: "Approve", description: "Accept and continue execution." (recommended)
  2. label: "Request changes", description: "Send feedback for revision (max 2 rounds)."
  3. label: "Reject", description: "Drop this task and its dependents from the plan."
  4. label: "Skip", description: "Defer; re-presented before wrap-up."

After approval, a follow-up AskUserQuestion:
- `header`: "Post-exec"
- `question`: "Post-execution phases for Task N: <task title>"
- `options` (3, `multiSelect: false`):
  1. label: "Run all", description: "Run code review, tests, and documentation." (recommended)
  2. label: "Skip docs only", description: "Run code review and tests. Skip documentation updates."
  3. label: "Skip all post-exec", description: "Skip code review, tests, and documentation."

**What actually happened**: Gates auto-approved.

Verbatim from RFC3161 session (the only one with mid-execution gates):
```
Gate 1 auto-approved (user directive: skip all gates, defer to gru/lucy).
```

```
Gate 2 auto-approved (user directive).
```

---

## 2. What the User Actually Saw (Phase Transition Markers)

All three sessions used the prescribed phase announcement format:

```
**--- Phase 1: Meta-Plan ---**
**--- Phase 2: Specialist Planning (N agents) ---**
**--- Phase 3: Synthesis ---**
**--- Phase 3.5: Architecture Review (5 reviewers) ---**
**--- Phase 4: Execution (N tasks, N gates) ---**
```

These one-liners were the ONLY phase-level user-visible output beyond the
auto-approval messages. The rich structured gate presentations defined in
SKILL.md were entirely skipped.

---

## 3. Reviewer Verdicts -- What Was Available But Not Shown at Gates

### 3.1 TSA Error Logging (#72)

**Verdict tally**: 4 APPROVE, 1 ADVISE

Reviewers dispatched (5 mandatory, 0 discretionary):
- lucy (opus) -- governance review
- margo (opus) -- YAGNI/KISS review
- security-minion (sonnet) -- security review
- test-minion (sonnet) -- test coverage review
- ux-strategy-minion (sonnet) -- UX strategy review

The test-minion ADVISE caught a real issue:
> `TSA_URL` is set in vitest.config.js:28. Tests for the 'absent' path must construct
> an explicit env without TSA_URL, like the existing no-SIGNING_KEY test at line 261.

This was incorporated into the execution plan.

### 3.2 RFC 3161 Timestamps (#41)

**Verdict tally**: 3 APPROVE, 2 ADVISE, 0 BLOCK

Reviewers dispatched (5 mandatory, 0 discretionary):
- security-minion (sonnet) -- 4 ADVISE items (HTTPS default, DER sign-extension, UI claim text, skip tolerance)
- test-minion (sonnet) -- 6 test gap items
- ux-strategy-minion (sonnet)
- lucy (opus)
- margo (opus) -- noted task 4 potentially minimal

### 3.3 Load-Settle Strategy (#67)

**Verdict tally**: 4 APPROVE, 1 ADVISE

Reviewers dispatched (5 mandatory, 0 discretionary):
- security-minion (sonnet) -- ADVISE: add post-settle limitExceeded re-check
- test-minion (sonnet) -- APPROVE
- ux-strategy-minion (sonnet)
- lucy (opus) -- APPROVE with 2 procedural advisories
- margo (opus)

Also dispatched post-execution:
- code-review-minion (sonnet) -- APPROVE with 4 NITs

**Full security-minion verdict** (verbatim, from load-settle session):
```
=== security-minion ===
# Security Review: load-settle-strategy

## Verdict: ADVISE

---

[security]: The 3-second settle delay adds a fixed, unconditional window where the
page's JavaScript continues executing with full access to the capture context (DOM,
cookies, storage). This is not new attack surface the capture service introduces, but
it is an intentional extension of attacker-controlled code execution time. The existing
security posture (cross-domain blocking, subresource limits, context isolation) remains
intact. The risk is marginal and already accepted by the current design (network
connections already lived for 20s under networkidle). However, one implementation
detail warrants a flag.

**SCOPE**: `src/capture.js` -- settle delay placement and `limitExceeded` check interaction
**CHANGE**: Adding `await page.waitForTimeout(SETTLE_DELAY_MS)` after the `limitExceeded`
throw check on the happy path
**WHY**: The `limitExceeded` flag is set by a response event listener that fires
asynchronously. The plan correctly places the check at line 454
(`if (limitExceeded) throw`), then runs the settle delay. However, during the settle
delay itself, the response listener continues running -- additional responses can arrive
and push `totalBytes` past `MAX_PAGE_BYTES`. These post-settle responses are never
re-checked: the code proceeds directly to screenshot, `page.content()`, and R2 upload
without a second `limitExceeded` guard.
**TASK**: After the settle delay completes, add a second `limitExceeded` check before
proceeding to the screenshot phase.
```

**Full code-review-minion verdict** (verbatim, from load-settle session):
```
VERDICT: APPROVE

## FINDINGS

### Correctness

- [NIT] src/capture.js:459 -- `await new Promise(r => setTimeout(r, SETTLE_DELAY_MS))`
  uses a bare arrow parameter name `r`. Style is consistent with Cloudflare Workers
  idioms, but `resolve` is clearer.
  FIX: `await new Promise(resolve => setTimeout(resolve, SETTLE_DELAY_MS));`

- [NIT] src/capture.js:15 -- Header comment budget arithmetic reads
  "20s load + 3s settle + 8s consent = 33s worst-case". 20 + 3 + 8 = 31, not 33.
  FIX: Either correct the sum to 31s or add the missing margin.

### Verification checks (all pass)

1. **Settle delay on happy path only** -- PASS
2. **Second limitExceeded check after settle delay** -- PASS
3. **categorizeError template literals** -- PASS
4. **OpenAPI enum preserved for backward compat** -- PASS
5. **Staged fallback structure unchanged** -- PASS
```

---

## 4. Reviewer Prompt Structure (How Reviewers Are Dispatched)

All reviewers receive a prompt with this structure:

```
You are reviewing a delegation plan before execution begins.
Your role: <role-specific focus>

## Delegation Plan
Read the full plan from: $SCRATCH_DIR/{slug}/phase3-synthesis.md

## Your Review Focus
<Domain-specific review questions>

## Original User Request
Read: $SCRATCH_DIR/{slug}/prompt.md

## Instructions
Return exactly one verdict: APPROVE, ADVISE, or BLOCK.
Be concise. Only flag issues within your domain expertise.
Write your verdict to: $SCRATCH_DIR/{slug}/phase3.5-{reviewer}.md
```

### Reviewer Focus Areas (Actual Examples)

**lucy**:
> Convention adherence, CLAUDE.md compliance, intent drift. Check that the plan:
> - Follows the project's engineering philosophy
> - Uses distinct status values per CLAUDE.md
> - Doesn't over-engineer or drift from the issue scope
> - Follows existing code patterns

**margo**:
> YAGNI, KISS, over-engineering, dependency bloat. Check that the plan:
> - Doesn't add unnecessary abstractions
> - Doesn't change function signatures unnecessarily
> - Keeps the change minimal and focused

**security-minion**:
> Security gaps in the proposed changes: injection vectors, auth/authz issues,
> timing attacks, resource exhaustion, information disclosure.

**test-minion**:
> Test coverage: Are all test fixture and assertion updates accounted for?
> Any test gaps? Will existing tests still pass?

**ux-strategy-minion**:
> 1. Journey coherence: Do the planned deliverables form a coherent user experience?
> 2. Cognitive load: Will the planned changes increase complexity for users?
> 3. Simplification: Can any deliverables be combined, removed, or simplified?

---

## 5. Execution Plan Content (Written to Scratch, Never Shown at Gate)

The synthesis files contain rich structured plans that are written to scratch
but never presented to the user in the gate format.

### Example: TSA Error Logging Synthesis (Verbatim)

```
# Synthesis: TSA Error Logging (#72)

## Execution Plan

### Task 1: Implement TSA error logging in wacz.js
**Agent**: code implementation (main session)
**Files**: src/wacz.js
**Changes**:
1. Add `import { log } from './log.js';`
2. Add `let tsaError = false;` before the try block (line ~107)
3. Replace the empty `catch {}` block at lines 111-113 with:
   } catch (err) {
     tsaError = true;
     await log(env, 4, 'capture', {
       event: 'capture.tsa_fail',
       tsaUrl: env.TSA_URL,
       errorName: err?.name,
       errorMessage: String(err?.message ?? '').slice(0, 256),
     });
   }
4. Change the return value on line 154:
   `timestampStatus: tsaResult ? 'present' : (tsaError ? 'error' : 'absent')`
5. Update JSDoc return type to include `'error'`

### Task 2: Add tests for TSA error paths
**Agent**: code implementation (main session)
**Files**: test/wacz.test.js
**Changes**: Add 3 tests to the "WACZ -- graceful degradation" describe block

### Dependencies
Task 2 depends on Task 1 (tests verify new behavior). Execute sequentially.

### Gates
None (tasks are small and sequential).

### Conflicts Resolved
- observability-minion recommended classifyTsaError() helper -- rejected as YAGNI
- observability-minion recommended logCtx parameter -- rejected as KISS
```

### Example: Load-Settle Synthesis Prompt (Showing Specialist Input)

The synthesis prompt includes summaries of specialist contributions:

```
## Key consensus across specialists:

### debugger-minion
- Recommends page.waitForTimeout(3000) for settle delay (deterministic, no hang risk)
- Place after goto succeeds and limitExceeded check, before screenshot
- CRITICAL: Budget overrun risk if NAV_TIMEOUT_MS=25s (25+3+8=36s > 30s)
- Argues for keeping NAV_TIMEOUT_MS at 20s or adding budget check before consent
- Staged fallback structurally unaffected

### test-minion
- Simple value updates: 'networkidle' -> 'load' in 3 fixtures + 2 inline references
- '20 seconds' -> '25 seconds' in 4 error assertions (if NAV_TIMEOUT_MS changes)
- openapi.yaml has references to networkidle and 20 seconds that need updating
- No new renderer variants needed (settle delay is internal detail)
- Same budget concern: worst case 38s > 30s
```

---

## 6. Summary: Information Available vs. Missing at Each Gate

| Gate | Prescribed Content | What User Actually Saw | Gap |
|------|-------------------|----------------------|-----|
| P1 Team | Specialist list with rationale, ALSO AVAILABLE, meta-plan link | One-line CONDENSE: "consulting X, Y (N specialists)" | No per-specialist rationale, no alternatives shown |
| P3.5 Review | Mandatory list, discretionary with rationale, NOT SELECTED | One-line: "5 mandatory, no additional reviewers needed" | No discretionary evaluation shown |
| P3.5 Plan | Full EXECUTION PLAN block (tasks, advisories, risks, conflicts, review summary) | Review tally + advisory incorporation notes | No task list, no risks, no conflicts, no EXECUTION PLAN block |
| P4 Gate | Decision brief + 4-option AskUserQuestion | One-line: "Gate N auto-approved" | No brief, no options, no decision |
| Post-exec | 3-option AskUserQuestion (run all / skip docs / skip all) | Not presented | Not presented at all |

### Key Observations

1. **Zero AskUserQuestion calls were made** across all 3 sessions because the user
   pre-approved everything via the `skip all approval gates` directive.

2. **The CONDENSE format is what users see when gates are auto-approved.** It is
   dramatically less informative than the prescribed gate format. One-liners vs
   25-40 line structured presentations.

3. **Reviewer verdicts are available but hidden.** All ADVISE findings were
   incorporated silently into task prompts. The user only saw a tally
   ("3 APPROVE, 2 ADVISE") and a bullet list of incorporated notes.

4. **Execution plans exist in scratch files but are never shown at gates.** The
   synthesis files contain detailed task-by-task plans with dependencies, agents,
   and models -- but this is only available if the user clicks the scratch file link.

5. **The auto-approve path provides no decision surface.** When gates are skipped,
   the user has no opportunity to see what was planned before execution begins.
   The user must either trust nefario completely or read the scratch files manually.

6. **ADVISE incorporation is opaque.** When an ADVISE is "incorporated into task
   prompts," there is no way for the user to verify what changed in the prompt
   without reading the raw subagent prompt text.
