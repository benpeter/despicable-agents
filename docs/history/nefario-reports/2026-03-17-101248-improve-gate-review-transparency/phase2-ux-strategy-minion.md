# UX Strategy Advisory: Gate Review Transparency

## Executive Summary

All four gate types share the same root UX problem: they present **conclusions without reasoning**. The user is asked to approve/reject a decision but is given only the decision's label, not the argumentation that produced it. This violates Nielsen's "help users recognize, diagnose, and recover" heuristic and, more fundamentally, makes the gate a rubber-stamp ceremony rather than a genuine decision point.

The quality target (WRL decisions.md) demonstrates what self-contained decisions look like: **Decision / Alternatives considered / Rationale**, each in 3-8 lines. Every gate should reach that bar — adapted for the constraints of each gate type.

---

## Diagnosis: Why Gates Fail as Decision Points

### The Core Cognitive Problem

A gate asks the user: "Do you approve?" To answer meaningfully, the user needs:

1. **What** was decided (currently shown at all gates)
2. **What else** was considered (missing at Team, Execution Plan, Reviewer gates; spec'd but untested at Mid-execution)
3. **Why this over that** (missing everywhere except Mid-execution spec)

Without items 2 and 3, the user is choosing between "trust the system" and "go read the scratch file." That is not a real decision — it is a trust exercise. The friction log from production sessions confirms this: the user had to add agents at the Team gate because they couldn't tell why margo was excluded, and couldn't evaluate CONFLICTS RESOLVED at the Execution Plan gate without opening the synthesis file.

### Gate-by-Gate Friction Analysis

| Gate | What user sees | What user needs to decide | Information gap |
|------|---------------|--------------------------|-----------------|
| **Team** | WHO + one-liner WHY-selected | Are the right agents included? Are exclusions intentional? | No exclusion rationale. No visibility into what questions will be asked. |
| **Reviewer** | WHO + one-liner rationale | Are the right reviewers included? | Same as Team but smaller pool. Currently auto-skipped when no discretionary picks — fine. |
| **Execution Plan** | Tasks + advisories + one-liner conflicts | Is the plan sound? Are trade-offs reasonable? | Conflicts are opaque. Advisories show WHAT but not WHAT-WAS-REJECTED. |
| **Mid-execution** | Spec has RATIONALE + rejected alternatives | Is this deliverable correct? Should blocked tasks proceed? | Untested. Spec format is closest to target but may be insufficient in practice. |

---

## Recommendations by Gate Type

### 1. Team Approval Gate

**Current problem**: The SELECTED block shows "agent-name + one-line rationale (why chosen)" and the ALSO AVAILABLE block is a flat comma list. The user cannot tell why any agent was excluded. The meta-plan link exists but progressive disclosure fails when the *primary* display doesn't contain enough to make the decision without the secondary.

**Recommendation: Add top-N exclusion rationales**

Keep the current SELECTED format (it works — one-liner per agent is sufficient for inclusions). Add a small NOTABLE EXCLUSIONS block for agents that were actively considered and rejected, distinct from agents that are simply irrelevant.

Proposed format change (additions in the ALSO AVAILABLE area):

```
  SELECTED:
    security-minion         Auth module security, key lifecycle, migration gap analysis
    api-design-minion       Admin API contract design (3 endpoints), 403 response conventions
    ...

  NOT SELECTED (notable):
    margo                   YAGNI review deferred — scope is additive, not refactoring
    frontend-minion         No UI changes in this task

  Also available: ai-modeling-minion, accessibility-minion, sitespeed-minion, ...
```

**Key principles**:
- Show at most 3 notable exclusions. These are agents where a reasonable user might wonder "why not?" — governance agents (lucy, margo), security-minion for security-adjacent tasks, etc.
- The exclusion rationale is one line, same format as inclusion rationale.
- The flat comma list remains for truly irrelevant agents.
- This adds 2-4 lines to the gate (from 8-12 to 10-14). Still well under the Execution Plan gate's weight.

**Line budget impact**: +2-4 lines. Acceptable — the Team gate is currently the lightest gate and has room.

**What NOT to add**: Planning questions should not appear at this gate. They are implementation detail — the user cares about team composition, not the prompts nefario will send. Keep them in the meta-plan scratch file.

---

### 2. Reviewer Approval Gate

**Current problem**: Thin — shows mandatory as a flat list and discretionary with one-liner rationales. The decision space is small (5-member pool) and the gate auto-skips when no discretionary reviewers are selected, which is the common case.

**Recommendation: Minimal changes — this gate is appropriately thin**

The Reviewer gate has the smallest decision space of any gate (add/remove from a 5-member pool). The user's decision is binary per reviewer: include or don't. The one-liner rationale ("Task 3 adds CLI flags affecting user workflow") is sufficient because:

- The pool is fixed and small (5 members)
- The user already approved the execution plan — they know the tasks
- The rationale references specific tasks, which the user just reviewed

**One change**: For the NOT SELECTED pool members, add a one-line exclusion rationale, same as the Team gate:

```
  NOT SELECTED:
    ux-design-minion       No UI components in plan
    accessibility-minion   No web-facing HTML produced
    sitespeed-minion       No browser-facing runtime code
```

This replaces the flat comma list and costs 1-3 extra lines. Worth it because the pool is only 5 members — showing all of them with rationales is cheap and eliminates "why wasn't X included?" questions entirely.

**Line budget impact**: +1-3 lines (from 6-10 to 7-13). Still lightweight.

---

### 3. Execution Plan Approval Gate

**Current problem**: This is the most critical gate and the one with the largest information gap. Two specific sub-problems:

**3a. CONFLICTS RESOLVED are opaque one-liners**

Current format:
```
CONFLICTS RESOLVED:
  - Revoked key visibility: exclude by default, ?include=revoked opt-in (api-design-minion)
```

This tells you WHAT was decided but not WHAT WAS THE ALTERNATIVE or WHY. The WRL decisions.md format is the quality target. Apply it.

**Recommendation: Adopt a Decision/Over/Why micro-format for conflicts**

```
DECISIONS:
  Revoked key visibility
    Chosen: exclude by default, ?include=revoked opt-in
    Over: always-visible with status field (security-minion), soft-delete only (data-minion)
    Why: opt-in aligns with API minimalism; security-minion's status-field approach leaks internal state

  Name uniqueness
    Chosen: not enforced for MVP
    Over: unique-per-tenant constraint (api-design-minion)
    Why: enforcement blocks key rotation workflows; revisit post-MVP if collision reports emerge
```

**Key principles**:
- Rename from "CONFLICTS RESOLVED" to "DECISIONS" — not every decision is a conflict; some are trade-off resolutions or scope choices. "DECISIONS" is a more accurate and less alarming label.
- Three lines per decision: Chosen / Over / Why. This is the WRL decisions.md pattern compressed to its minimum viable form.
- "Over" names the rejected alternative(s) and attributes them (which agent or domain argued for them). This is the critical missing piece.
- "Why" is one sentence of rationale, self-contained.
- Maximum 5 decisions shown inline. Beyond 5, show top 3 + "and N more in [plan](link)."
- Each decision is 3-4 lines. Five decisions = 15-20 lines. This is significant but these are the most decision-relevant lines in the entire gate.

**3b. ADVISORIES lack rejected alternatives**

Current format:
```
ADVISORIES:
  [security] Misconfiguration guard approach (Task 1)
    CHANGE: Use binding-presence check (!env.KV && !env.CAPTURE_API_KEY) not KV content scan
    WHY: Content-scan hits KV on every failed auth; false 503 on fresh deploy with empty KV
```

This is close to self-contained but missing the rejected alternative explicitly. The CHANGE line implies it ("not KV content scan") but buries it in a dependent clause.

**Recommendation: Add an explicit OVER line to advisories when an alternative was rejected**

```
ADVISORIES:
  [security] Misconfiguration guard approach (Task 1)
    CHANGE: Use binding-presence check for missing auth configuration
    OVER: KV content scan on every request (original plan)
    WHY: Content-scan hits KV on every failed auth; false 503 on fresh deploy with empty KV
```

Not every advisory rejects an alternative — some are purely additive ("add try/catch around KV.get()"). For additive advisories, OVER is omitted and the current 2-line format (CHANGE + WHY) is sufficient. The rule: **if the advisory changed an existing plan decision, show what it changed FROM**.

**Line budget impact**: DECISIONS replaces CONFLICTS RESOLVED. Net change depends on conflict count. For the production example (6 conflicts): current = 6 lines, proposed = ~20 lines. For advisories with OVER lines: +1 line per advisory that rejects an alternative (maybe 3-4 of 6). Total gate growth: roughly +15-20 lines, pushing the gate from 25-40 to 40-55 lines.

**This is acceptable.** The current 25-40 target was set when conflicts were one-liners. The purpose of the gate is decision-making, and decisions require context. A 50-line gate with self-contained decisions is more useful than a 30-line gate that forces the user to open the scratch file. The line budget should be updated to 35-55.

**What NOT to change**: The TASKS section format is fine. Task titles, deliverables, dependencies, and gate markers give the user what they need to understand the execution shape. The RISKS section format is also adequate — risks are informational, not decision points.

---

### 4. Mid-Execution Approval Gate

**Current problem**: The spec is the richest of all gates, with RATIONALE bullet points including "Rejected: alternative and why." However, it has **never been observed in production**. This means we are designing from theory, not evidence.

**Assessment of the current spec format**:

```
RATIONALE:
- <key point 1>
- <key point 2>
- Rejected: <alternative and why>
```

This is structurally close to the WRL pattern but has two weaknesses:

1. **"Rejected" is buried in a bullet list.** The user scanning the gate might miss it. In the WRL format, "Alternatives considered" is a top-level field — it demands attention.

2. **The DELIVERABLE section focuses on files, not the decision.** When a mid-execution gate fires, the user's question is "should this work proceed to dependent tasks?" — which is a decision about approach correctness, not file inventory. The file list is secondary.

**Recommendation: Restructure mid-execution gates around the decision, not the deliverable**

```
`────────────────────────────────────────────────────`
⚗️ `APPROVAL GATE: <Task title>`
`Agent:` <who produced this> | `Blocked tasks:` <what's waiting>

`DECISION:` <one-sentence summary of the approach taken>

`APPROACH:`
  Chosen: <what was implemented>
  Over: <what was considered but rejected, and why>

`DELIVERABLE:`
  <file path 1> (<change scope>, +N/-M lines)
  <file path 2> (<change scope>, +N/-M lines)
  Summary: <1-2 sentences describing what was produced>

`Confidence:` HIGH | MEDIUM | LOW
`Details:` [task-prompt]($SCRATCH_DIR/{slug}/phase4-{agent}-prompt.md)
`────────────────────────────────────────────────────`
```

**Key changes from current spec**:
- Replace the bullet-list RATIONALE with a structured APPROACH block (Chosen/Over pattern, matching the Execution Plan gate's DECISIONS format).
- Move IMPACT into the DECISION line (it was redundant — the decision summary IS the impact).
- Keep DELIVERABLE but position it after APPROACH. The approach justification is the decision-relevant content; the file list is evidence.
- Remove the standalone IMPACT line — fold it into the AskUserQuestion description instead: "Approve: accept this approach and unblock Tasks N, M."

**Line budget**: Current spec targets 12-18 lines. The restructured format fits within the same budget (the RATIONALE bullets become APPROACH Chosen/Over which is roughly the same line count, and IMPACT is removed as a standalone section).

---

## Cross-Cutting Design Principles

### 1. The Chosen/Over/Why Pattern as a Universal Micro-Format

All four gates benefit from the same micro-format for expressing decisions:

```
<Decision label>
  Chosen: <what was selected>
  Over: <what was rejected> (<who argued for it>)
  Why: <rationale>
```

This pattern is:
- **Self-contained**: A reader seeing only this block can understand the decision without context
- **Scannable**: Three labeled lines, each answering a distinct question
- **Attributable**: "Over" includes who proposed the rejected alternative, which builds trust ("the system heard security-minion's concern and made a reasoned choice")
- **Compact**: 3-4 lines per decision

Apply it everywhere decisions are presented: Team gate exclusions (abbreviated to one-line), Execution Plan DECISIONS and ADVISORIES, Mid-execution APPROACH blocks.

### 2. Progressive Disclosure Still Works — But the Primary Layer Must Be Sufficient

The current gates rely on progressive disclosure (compact gate + scratch file link for details). This is correct in principle but fails in practice because the primary layer doesn't contain enough information to make the decision. The fix is not to eliminate progressive disclosure — it is to raise the floor of the primary layer.

**Rule of thumb**: The gate presentation must contain enough information that a user who NEVER clicks the Details link can still make a well-informed approve/reject decision. The Details link is for curiosity and audit trails, not for decision-making.

### 3. Line Budgets Should Reflect Decision Complexity, Not Arbitrary Caps

Current line budgets:
- Team: 8-12
- Reviewer: 6-10
- Execution Plan: 25-40
- Mid-execution: 12-18

These should be updated to reflect the added decision content:
- Team: 10-16 (added notable exclusions)
- Reviewer: 7-13 (added exclusion rationales for full pool)
- Execution Plan: 35-55 (DECISIONS block replaces one-liner conflicts)
- Mid-execution: 12-18 (restructured but same budget — APPROACH replaces RATIONALE)

The Execution Plan gate grows the most because it carries the most decisions. This is correct — it IS the most important gate.

### 4. Naming Matters: "DECISIONS" Not "CONFLICTS RESOLVED"

"CONFLICTS RESOLVED" implies adversarial agents and suggests something went wrong. Many decisions are not conflicts — they are trade-off resolutions, scope choices, or design preferences. "DECISIONS" is neutral and accurate. It also primes the user to evaluate the reasoning rather than worry about process dysfunction.

---

## Risks and Dependencies

### Risk 1: Line Budget Growth Causes Scanning Fatigue

The Execution Plan gate grows from ~30 to ~45 lines. At 45 lines, the gate may exceed one terminal screen, forcing scrolling. Scrolling through a gate is qualitatively different from seeing it all at once — it breaks the Gestalt of the decision.

**Mitigation**: The DECISIONS block is the variable-length section. Cap at 5 inline decisions (currently spec'd). Beyond 5, the plan has too many contested decisions and should trigger a "plan complexity" warning. Also: decisions are scannable because the Chosen/Over/Why format has strong visual rhythm — the labeled lines create a predictable pattern that supports rapid scanning even across multiple decisions.

### Risk 2: Nefario Context Window Pressure

Every line added to gate presentations consumes context window in the nefario orchestration session. The gates are already in a context-hungry workflow (meta-plan + specialist consultations + synthesis + reviews + execution).

**Mitigation**: The growth is modest (~15-20 lines per Execution Plan gate, ~4 lines per Team gate). These are one-time presentations, not recurring. The DECISIONS content is actually more useful to preserve in context than the one-liner conflicts it replaces, because it supports better compaction summaries ("decided X over Y because Z" compresses better than "resolved: X" which loses information).

### Risk 3: Mid-Execution Gate Format Is Untested

The restructured mid-execution gate has never been observed in production (same as the current spec). Any format change is theoretical.

**Mitigation**: Accept this. The restructuring aligns mid-execution gates with the same Chosen/Over pattern used at other gates, which reduces cognitive switching cost. When mid-execution gates do appear in production, the consistent format will be immediately familiar. Gather feedback from the first session that hits a mid-execution gate and iterate.

### Risk 4: Attribution in "Over" Lines May Be Inaccurate

The "Over" line attributes rejected alternatives to specific agents. If nefario misattributes (says "security-minion" when it was "api-design-minion"), this erodes trust.

**Mitigation**: Attribution is optional — "Over: always-visible with status field" is still useful without "(security-minion)". Make attribution best-effort: include it when the synthesis clearly records who proposed the alternative; omit it when unclear. Never fabricate attribution.

---

## Implementation Guidance

### Priority Order

1. **Execution Plan gate DECISIONS block** — highest impact, addresses the user's primary frustration (opaque conflict resolutions), and sets the pattern for all other gates
2. **Team gate notable exclusions** — second highest impact, addresses the "why wasn't margo included?" class of questions
3. **Mid-execution gate APPROACH restructure** — align with the Chosen/Over pattern for consistency
4. **Reviewer gate exclusion rationales** — lowest priority, smallest decision space, often auto-skipped

### What Changes in SKILL.md

- Team Approval Gate presentation format: add NOT SELECTED (notable) block, update line budget to 10-16
- Execution Plan Approval Gate: rename CONFLICTS RESOLVED to DECISIONS, define Chosen/Over/Why micro-format, add OVER line to advisories, update line budget to 35-55
- Mid-execution gate: replace RATIONALE bullets with APPROACH (Chosen/Over), remove standalone IMPACT, keep line budget at 12-18
- Reviewer Approval Gate: replace flat comma NOT SELECTED with per-member exclusion rationales, update line budget to 7-13

### What Does NOT Change

- AskUserQuestion structure (headers, options, multiSelect) — untouched
- Gate sequencing and flow control — untouched
- Adjustment/re-run workflows — untouched
- Details links to scratch files — untouched (still the progressive disclosure escape hatch)
- RISKS section format — untouched (risks are informational, not decision points)
- REVIEW summary line — untouched
- TASKS section format — untouched

---

## Summary: The Self-Containment Test

Every gate presentation should pass this test:

> **Can a user who reads ONLY the gate output (never clicks Details) make a well-informed approve/reject/adjust decision?**

Today, only the Mid-execution gate spec (untested) comes close. The Team gate fails on exclusions. The Reviewer gate fails on exclusions (minor). The Execution Plan gate fails on conflicts and some advisories.

After these changes, all four gates should pass. The user sees what was decided, what was rejected, and why — at every decision point in the orchestration.
