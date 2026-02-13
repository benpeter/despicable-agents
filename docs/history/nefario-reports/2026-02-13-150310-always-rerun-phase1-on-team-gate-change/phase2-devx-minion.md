## Domain Plan Contribution: devx-minion

### Recommendations

**Context**: The current SKILL.md has a shared "adjustment classification" definition (lines 524-532) that defines minor (1-2 changes) vs. substantial (3+ changes) paths. Both the Team Approval Gate (lines 460-609) and the Reviewer Approval Gate (lines 1002-1043) reference this classification. The issue scope explicitly limits changes to the Team Approval Gate and excludes the Phase 3.5 reviewer adjustment gate.

This creates a design tension: the adjustment classification definition is shared infrastructure used by both gates. Since we are only changing the Team Approval Gate behavior, we need to either (a) split the shared definition so each gate has its own, or (b) rewrite the shared definition to express two different policies. I recommend option (a) -- eliminate the shared definition, inline the Team gate's simpler policy directly into its section, and leave the Reviewer gate with its own self-contained classification. This is cleaner because the two gates now have genuinely different adjustment semantics.

**(a) Rewriting the adjustment classification (lines 524-532)**

Remove the entire shared "Adjustment classification" block (lines 524-537). Replace it with a simpler paragraph inside the "Adjust team" response handling section that says:

> When a user adjusts team composition, count total agent changes (additions + removals). A replacement (swap agent X for agent Y) counts as 2 changes (1 removal + 1 addition).
>
> If the adjustment results in 0 net changes, treat as a no-op: re-present the gate unchanged with a note "No changes detected." A no-op does not count as an adjustment round.
>
> Any non-zero change triggers a full Phase 1 re-run.

The Reviewer gate (lines 1009-1011) currently says "Classify the adjustment per the adjustment classification definition." This back-reference will break when the shared definition is removed. The Reviewer gate needs its own inline classification definition preserving the minor/substantial distinction for its own use. This is in-scope because the issue says "AGENT.md references to minor/substantial paths are removed or updated" -- the same principle applies to cross-references within SKILL.md that would break.

**(b) Re-run cap rule (lines 544-546)**

The current cap rule reads: "Cap at 1 re-run per gate. If a second substantial adjustment occurs at the same gate, use the lightweight path with a note in the CONDENSE line: 'Using lightweight path (re-run cap reached).'"

With the minor/substantial distinction removed, the fallback to "lightweight path" no longer exists as a concept for the Team gate. The re-run cap still serves a valid purpose (preventing infinite re-run loops), but its fallback behavior needs rethinking.

Two options:

1. **Keep the 1 re-run cap, but the fallback is "apply changes directly"** -- meaning a second adjustment at the Team gate does NOT trigger a re-run; instead, nefario generates planning questions for added agents inline (the old minor-path behavior, now unnamed). The CONDENSE note becomes: "Re-run cap reached; changes applied directly."

2. **Remove the re-run cap entirely** since the 2-round adjustment cap already bounds total adjustments. With at most 2 adjustment rounds, you get at most 2 re-runs. This is bounded and predictable.

I recommend option 2. The 2-round adjustment cap already provides the bound. Having two separate caps (1 re-run + 2 rounds) creates confusing interaction states where the user has adjustment rounds remaining but can't get a proper re-run. Since the whole point of this change is that partial updates produce stale questions, falling back to the lightweight path on the second adjustment defeats the purpose. Two re-runs (worst case) is acceptable cost for coherent planning.

If the team prefers to keep the re-run cap for token budget reasons, option 1 works but should be clearly documented as a degraded mode.

**(c) CONDENSE line on line 191**

Line 191 currently reads:
```
- After Phase 1 re-run (substantial team adjustment): "Planning: refreshed for team change (+N, -M) | consulting <agents> (pending approval)"
```

Remove the "(substantial team adjustment)" qualifier. The new line:
```
- After Phase 1 re-run (team adjustment): "Planning: refreshed for team change (+N, -M) | consulting <agents> (pending approval)"
```

This is a minimal change. The CONDENSE line format itself is already correct -- it just drops the word "substantial."

**Additional change: docs/orchestration.md line 79 and 385**

Line 79 contains: "Adjustment classification follows the same magnitude-based branching as the Team Approval Gate: minor changes apply directly, while substantial changes trigger an in-session re-evaluation..."

This sentence needs updating for the Team gate description (line 385) and the Reviewer gate description (line 79). Line 385 should drop the minor/substantial language for the Team gate. Line 79 describes the Reviewer gate and is out of scope per the issue, but it currently references the Team gate's classification by analogy ("follows the same magnitude-based branching as the Team Approval Gate"). After this change, the analogy breaks. This sentence should be rewritten to describe the Reviewer gate's own classification without referencing the Team gate.

**Rules block (lines 539-549)**

Lines 540-541 ("Classification is internal. Never surface the threshold number or classification label to the user.") should be removed for the Team gate since there is no longer a classification. The "no override mechanism" rule (lines 547-549) should be preserved but reworded: the user controls composition, the system always re-runs. The re-run round counting rule (lines 542-543) is preserved as-is.

### Proposed Tasks

**Task 1: Rewrite Team Approval Gate adjustment handling in SKILL.md**
- Remove the shared "Adjustment classification" block (lines 524-537)
- Collapse steps 3-4b into a single flow: validate changes -> count changes -> 0 = no-op -> non-zero = full Phase 1 re-run
- Inline the change-counting definition (what counts as a change, replacement = 2 changes, 0 = no-op) directly in the "Adjust team" section
- Remove the re-run cap rule (or rewrite per team preference) and rely on the 2-round adjustment cap
- Remove lines 540-541 (internal classification rule) since there is no classification
- Preserve the constraint directive for the re-run prompt (lines 578-587) unchanged
- Preserve the re-run file paths and delta summary format unchanged
- Update the rules block to reflect the simplified flow
- Deliverable: Updated SKILL.md Team Approval Gate section
- Dependencies: None

**Task 2: Inline Reviewer gate classification**
- The Reviewer gate (lines 1009-1011, 1013-1033) currently back-references "the adjustment classification definition." Since that shared definition is being removed in Task 1, the Reviewer gate needs its own inline definition preserving its minor/substantial behavior.
- Move the relevant parts of the old shared definition (threshold, replacement counting, 0-change no-op, rules) into the Reviewer gate section as a self-contained block
- Deliverable: Updated SKILL.md Reviewer Approval Gate section with self-contained classification
- Dependencies: Task 1 (shared definition removal)

**Task 3: Update CONDENSE line and orchestration docs**
- Update SKILL.md line 191: remove "(substantial team adjustment)" qualifier
- Update docs/orchestration.md line 385: remove minor/substantial language for Team gate
- Update docs/orchestration.md line 79: rewrite to describe Reviewer gate classification without referencing Team gate by analogy
- Deliverable: Updated CONDENSE line in SKILL.md, updated orchestration.md
- Dependencies: Task 1 (to know the final Team gate semantics)

### Risks and Concerns

1. **Reviewer gate back-reference breakage**. The Reviewer gate references the shared adjustment classification definition. If Task 1 removes it without Task 2 inlining a replacement, the Reviewer gate's behavior becomes undefined. These two tasks must be sequenced or done atomically. The issue scope says "Out: Phase 3.5 reviewer adjustment gate" but the shared definition removal creates an unavoidable dependency. Task 2 is a mechanical move (copy the definition into the Reviewer section), not a behavioral change to the Reviewer gate.

2. **Re-run cap removal increases token cost**. Removing the 1 re-run cap means a user who makes 2 adjustment rounds gets 2 full Phase 1 re-runs. This doubles the worst-case token spend for adjustments. The ai-modeling-minion should weigh in on whether this is acceptable. If not, the fallback-to-inline approach (option 1 in my analysis) preserves the cap.

3. **History docs become confusing**. The `docs/history/nefario-reports/2026-02-12-180836-rerun-on-roster-changes/` directory extensively documents the minor/substantial design decision. After this change, someone reading that history will find a rationale for a design that no longer exists. This is acceptable (history docs capture decisions at a point in time), but worth noting. No action needed -- history should not be rewritten.

4. **The "lightweight path" CONDENSE note**. Line 546 has a specific CONDENSE format for the lightweight fallback: "Using lightweight path (re-run cap reached)." If we remove the re-run cap, this goes away cleanly. If we keep the cap with option 1, this note needs rewording since "lightweight path" is no longer a named concept.

### Additional Agents Needed

None. The current team is sufficient. The scope is narrowly defined to SKILL.md text changes and orchestration doc updates. No code, no AGENT.md changes (confirmed via grep -- no AGENT.md files reference minor/substantial), no testing infrastructure changes. If the re-run cap question needs a token-cost analysis, ai-modeling-minion should be consulted, but the issue framing suggests the decision to always re-run is already made.
