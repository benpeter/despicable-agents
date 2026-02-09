# Nefario Overrides

These overrides document hand-tuned additions to nefario/AGENT.md that go beyond
what /lab generates from the-plan.md spec. When rebuilding nefario, these
overrides must be re-applied to AGENT.generated.md to produce the final AGENT.md.

## Frontmatter

- Added `x-fine-tuned: true` to signal overlay system is active

## Section: Approval Gates

### Added: Decision Brief Format

The generated version mentions decision briefs only in passing ("Present each
gate as a decision brief with a one-sentence summary..."). The hand-tuned
version adds the full progressive-disclosure decision brief template as a
fenced code block with all fields:

- APPROVAL GATE title, Agent, Blocked tasks header
- Layer 1: DECISION (one-sentence, 5-second scan)
- Layer 2: RATIONALE (3-5 bullets, must include rejected alternative)
- IMPACT (consequences of approving vs. rejecting)
- DELIVERABLE (file path for Layer 3 deep dive)
- Confidence indicator (HIGH / MEDIUM / LOW)
- Reply options line

Also adds a "Field definitions" block explaining each field's purpose and
semantics (e.g., what confidence levels mean in objective terms: number of
viable alternatives, reversibility, downstream dependents).

### Added: Response Handling

Full subsection documenting the four user responses and their consequences:

- **approve**: Gate clears, downstream tasks unblocked
- **request changes**: Producing agent revises; capped at 2 iterations; after 2 rounds presents current state with summary of requested/changed/unresolved; user decides approve-as-is, reject, or take over
- **reject**: Before executing, present downstream impact ("Rejecting this will also drop Task X, Task Y..."); after confirmation, remove rejected task and all dependents from plan
- **skip**: Gate deferred; execution continues with non-dependent tasks; skipped gate re-presented at wrap-up; tasks still blocked at wrap-up remain incomplete and flagged in final report

### Added: Anti-Fatigue Rules

Full subsection with four specific anti-fatigue mechanisms:

- **Gate budget**: Target 3-5 gates per plan; if synthesis produces more than 5, consolidate related gates or downgrade low-risk gates to non-blocking notifications; flag if budget exceeded
- **Confidence indicator**: Every gate includes HIGH/MEDIUM/LOW based on objective signals (number of viable alternatives, reversibility, downstream dependents); helps users allocate attention
- **Rejected alternatives mandatory**: Every gate rationale must include at least one rejected alternative; primary anti-rubber-stamping measure forcing user to consider if they would have chosen differently
- **Calibration check**: After 5 consecutive approvals without changes, present calibration prompt asking if gates are well-calibrated or should be reduced

### Added: Cascading Gates

Full subsection with three ordering rules:

- **Dependency order mandatory**: Never present a gate that depends on an unapproved prior gate
- **Parallel independent gates**: Present sequentially, ordered by confidence ascending (LOW first, MEDIUM, HIGH) so hardest decisions get freshest attention
- **Maximum 3 levels**: If more than 3 levels of sequential gate dependencies, restructure plan or consolidate gates

### Added: Gate vs. Notification

Full subsection distinguishing blocking gates from non-blocking notifications.
Notifications are for outputs that are important to see but do not need approval:
completed milestones, ADVISE verdicts from architecture review, intermediate
informational outputs.

## Section: Architecture Review (Phase 3.5)

### Added: Non-Skippable Constraint

Phase 3.5 Architecture Review is NEVER skipped by the orchestrator, regardless of task type (documentation, config, single-file, etc.) or perceived simplicity. ALWAYS reviewers are ALWAYS. The orchestrator does not have authority to skip mandatory reviews — that authority belongs to the user, who can explicitly request it.

### Added: Review Triggering Rationale

The generated version has just a Reviewer/Trigger table. The hand-tuned version
adds a "Rationale" column to the triggering rules table, explaining WHY each
reviewer is always/conditionally included (e.g., "Security violations in a plan
are invisible until exploited. Mandatory review is the only reliable mitigation.").

### Added: Detailed Verdict Formats

The generated version describes the three verdicts in a single paragraph. The
hand-tuned version adds full format templates for each verdict type:

- **APPROVE**: Simple description (no concerns, plan adequately addresses domain)
- **ADVISE**: Fenced code block template with `VERDICT: ADVISE`, `WARNINGS` list where each warning has `[domain]: <description>` and `RECOMMENDATION: <suggested change>`
- **BLOCK**: Fenced code block template with `VERDICT: BLOCK`, `ISSUE`, `RISK`, `SUGGESTION` fields; plus detailed resolution process (5 steps: block sent to nefario, nefario revises, re-submit to blocking reviewer only, cap at 2 rounds, escalate to user if still blocked)

### Added: ARCHITECTURE.md Template

The generated version mentions the concept of ARCHITECTURE.md generation
without the full template. The hand-tuned version adds:

- Triggering heuristic (if plan introduces/modifies components that future plans would need to understand)
- Note on minimum viable template (Components + Constraints + Key Decisions + Cross-Cutting)
- Full fenced markdown template with sections: System Summary, Components (table), Data Flow (Mermaid placeholder), Key Decisions (table with Choice/Alternatives Rejected/Rationale), Constraints, Cross-Cutting Concerns (table), Open Questions
- Commentary on why the Key Decisions table is particularly important (captures why choices were made, prevents relitigating settled decisions)

## Section: Working Patterns

### Enhanced: MODE descriptions

The generated version's mode descriptions are procedural lists. The hand-tuned
version matches but is structurally identical here -- the main enhancements are
in the subsections documented above (approval gates, architecture review) which
live under Working Patterns in the AGENT.md structure.

No material MODE description differences beyond what is captured in other override sections.

## Section: Conflict Resolution

### Enhanced: Three-pattern breakdown

The generated version has a single paragraph on conflict resolution. The
hand-tuned version breaks this into three named patterns:

- **Resource Contention**: File owner makes final edits; other agents provide input as comments or separate docs
- **Goal Misalignment**: When agents optimize for different metrics, use project priorities; involve user when priorities unclear
- **Hierarchical Authority**: Orchestrator has final decision-making authority; review both positions and make the call

## Section: Output Standards

### Added: Final Deliverables subsection

The generated version covers Delegation Plans and Status Reports. The hand-tuned
version adds a "Final Deliverables" subsection for presenting completed work:

- **Synthesis**: Unified narrative of what was accomplished
- **Verification Results**: Test results, checks passed/failed
- **Known Issues**: Anything incomplete or requiring follow-up
- **Handoff**: What the user needs to do next
