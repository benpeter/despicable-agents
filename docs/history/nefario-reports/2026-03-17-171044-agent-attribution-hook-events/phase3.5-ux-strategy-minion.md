# UX Strategy Review: Agent Attribution via Hook Events

**Verdict: ADVISE**

---

## Summary

The plan is coherent and the core design decision (domain scopes + Agent trailer over raw agent names) is correct. The progressive disclosure principle is properly applied: domain label at scan level, full agent identity one level deeper in trailers. The conflict resolution in the synthesis accurately captures my earlier analysis.

One advisory concern around cognitive transparency at the commit checkpoint moment.

---

## ADVISE: Majority-wins scope selection is silent

**SCOPE**: Task 2 -- commit-point-check.sh, commit checkpoint stderr output

**CHANGE**: When a multi-agent session produces a commit, the majority-wins rule selects one agent's scope. The current checkpoint format shows the winner but not the losers:

```
Commit: "feat(frontend): implement auth header"

Agent: frontend-minion
Co-Authored-By: Claude <noreply@anthropic.com>
(Y/n)
```

If a developer later runs `git log --format='%(trailers:key=Agent)'` and sees only `frontend-minion` on a commit that also involved `security-minion` and `test-minion`, they will not know the attribution is partial. The trailer only records the primary agent.

**WHY**: This creates a hidden information loss. The developer's forensic job ("who produced this change?") is the job the Agent trailer is specifically designed to serve. Silently discarding minority agents from the trailer means the forensic record is incomplete without any visible signal that it is incomplete. This violates Nielsen Heuristic 1 (system status visibility) -- the system has made a consequential simplification decision, but gives no feedback that it did so.

This is distinct from the scope in the commit subject line, where majority-wins is clearly correct (one scope per commit is a hard format constraint). The trailer has no such constraint -- multiple Agent trailers are valid git trailer syntax.

**TASK**: The implementation team (devx-minion, Task 2) should consider one of two mitigations:

Option A -- Multiple Agent trailers (preferred if complexity is low):
```
Agent: frontend-minion
Agent: security-minion
Agent: test-minion
Co-Authored-By: Claude <noreply@anthropic.com>
```
The first Agent trailer is the primary (majority agent, determines scope). Additional trailers record all contributors. `git log --format='%(trailers:key=Agent)'` returns all values. This is the most complete forensic record and requires minimal extra logic (collect all unique agent_type values, emit primary first).

Option B -- Checkpoint transparency (minimal change):
Keep single Agent trailer but add a note to the checkpoint stderr when multiple agents contributed:
```
Commit: "feat(frontend): implement auth header"

Agent: frontend-minion (majority; also: security-minion, test-minion)
Co-Authored-By: Claude <noreply@anthropic.com>
(Y/n)
```
The parenthetical is human-readable context at commit time but does not appear in the git trailer itself. Less complete for forensic queries but visible to the committing developer.

Option C -- Accept the limitation (if both options add too much complexity):
Document in decisions.md that the Agent trailer records the primary agent only, not all contributors. This is a known limitation, not a bug. At least the limitation is explicit.

The choice is the implementation team's call on complexity vs. completeness. I flag it so the decision is made consciously rather than by omission.

---

## No other concerns

**Journey coherence**: The five deliverables form a coherent arc -- hook captures data, commit script surfaces it, tests validate it, docs explain it. The sequencing (Task 1 -> Task 2 -> Task 3+4 -> Task 5) respects dependencies and the approval gate at Task 2 is correctly placed given the blast radius of the commit format decision.

**Cognitive load for git log scanning**: The suffix-stripping heuristic (`${agent_type%-minion}`) is the right call. Clean domain labels (`frontend`, `security`, `oauth`) match existing mental models. Zero maintenance cost. No lookup table to drift.

**Backward compatibility**: TSV as a strict superset of bare paths is a well-chosen constraint. Mixed-format ledger handling is explicit and correct.

**Progressive disclosure**: Correctly applied. Domain scope at scan level satisfies jobs 1-3 (find bugs, understand changes, review PRs). Agent trailer satisfies job 4 (forensic audit) on demand.

**JTBD coverage**: All four developer jobs identified in earlier analysis are served by the final design. No gaps.
