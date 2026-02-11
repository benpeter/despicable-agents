VERDICT: ADVISE

## Reasoning Chain

### 1. Problem Identification

The problem is well-scoped: nefario operates on external projects that may ship their own Claude Code skills. Without integration, nefario ignores these skills and routes work only to built-in specialists, missing project-specific automation that already exists.

This is a real requirement -- not speculative. Projects already ship skills in `.claude/skills/` (this project does it for nefario and despicable-prompter). The feature is prompt-level changes for a prompt-level system.

### 2. Proportionality Assessment

**Complexity budget tally:**

| Item | Cost | Justified? |
|------|------|------------|
| New prompt section in AGENT.md | 3 (abstraction layer) | Yes -- core mechanism |
| New prompt additions in SKILL.md | 1 (additive) | Yes -- execution wiring |
| New architecture doc (157 lines) | 1 | See findings |
| User-facing docs addition (28 lines) | 0 | Appropriate |
| Decision log entry | 0 | Appropriate |
| Architecture.md + README updates | 0 | Appropriate |

Total: ~5 points. Proportional for a cross-cutting orchestration concern.

**No new technologies.** No new dependencies. No executable code. All changes are prompt text and documentation -- the same medium as the rest of the project. This is the right approach.

### 3. YAGNI Assessment

Core mechanism passes the YAGNI test -- "When will we need this?" Answer: "Now -- the toolkit is designed to operate on external projects that already have skills."

However, I flag two areas of speculative detail:

**Finding 1 (ADVISE): Precedence rules are over-specified for zero usage data.**

The three-tier precedence system (CLAUDE.md > project-local > specificity) in `nefario/AGENT.md` lines 218-224 and `docs/external-skills.md` lines 53-65 is a reasonable design, but it is specified with a level of certainty that has no empirical backing. Zero real-world precedence conflicts have occurred. The "specificity over generality" tier in particular requires judgment calls that may not match actual user expectations.

The approval gate escape hatch (line 224: "present the choice at the execution plan approval gate") is the right fallback, and in practice this will likely be the mechanism used for all early conflicts. The three tiers may prove correct, but they are effectively dead code until real conflicts arise.

Not blocking because: (a) the text is 7 lines in AGENT.md and a short section in docs, (b) the cost of having wrong heuristics here is low since the approval gate catches misroutes, and (c) removing them would leave no guidance at all, which is worse.

Simpler alternative: state only tiers 1 and 2 (CLAUDE.md explicit > project-local > global), and defer the specificity-vs-generality heuristic until a real conflict demonstrates the need. Add a single sentence: "When precedence is unclear, present the choice at the approval gate."

**Finding 2 (ADVISE): `docs/external-skills.md` is over-documented for a prompt-level mechanism.**

At 157 lines with a Mermaid diagram, a "For Skill Maintainers" section, and a "Known Limitations" section, this document is more substantial than the feature warrants at launch. The feature has zero users. The full mechanism is already documented in `nefario/AGENT.md` (the source of truth for the agent) and `skills/nefario/SKILL.md` (the source of truth for the skill).

The "For Skill Maintainers" section (lines 100-135) is the most speculative part -- it addresses external skill authors who want to optimize for nefario compatibility. At launch, no such authors exist. The "Tier 0: Works Automatically" section correctly states that no changes are needed, making Tier 1 and "What NOT to Do" guidance for imaginary future users.

Not blocking because: (a) the document is well-written and internally consistent, (b) having it is not harmful, and (c) the user-facing section in `using-nefario.md` (28 lines) is appropriately brief.

Simpler alternative: merge the essential content (How It Works, Discovery, Precedence, Deferral) into the existing `orchestration.md` as a subsection. Drop the Mermaid diagram, "For Skill Maintainers", and "Known Limitations" until external authors emerge. This would reduce from 157 lines to ~40-50 lines. Keep the user-facing section in `using-nefario.md` as-is.

### 4. Scope Alignment

**No scope creep detected.** The task was "external skill integration for nefario" and all changes serve that goal. No adjacent features were added. The documentation spread (7 files) is slightly wide but each change is small and targeted.

The content boundary note in SKILL.md (lines 98-100) leveraging the existing `<external-skill>` tag pattern is a clean, minimal addition that reuses infrastructure already defined in AGENT.md.

### 5. KISS Assessment

The classification heuristic (ORCHESTRATION vs. LEAF based on content signals) is appropriately simple -- a judgment call with a safe default (LEAF). No metadata coupling to external skills. No new infrastructure.

The deferral pattern (DEFERRED macro-task that runs in main session context) avoids the complexity of trying to decompose external workflows, which is the right call. "Don't try to orchestrate what someone else already orchestrated" is sound.

### 6. What Works Well

- Zero-coupling design: external skills need no despicable-agents-specific metadata
- Filesystem IS the registry (correctly rejected a manifest/registry approach in Decision 28)
- Safe defaults: unknown classification defaults to LEAF; ambiguous precedence surfaces at approval gate
- Content boundaries via `<external-skill>` tags prevent instruction leakage
- Decision 28 is concise and well-reasoned

## Summary

| # | Severity | File | Description |
|---|----------|------|-------------|
| 1 | ADVISE | `nefario/AGENT.md:218-224`, `docs/external-skills.md:53-65` | Precedence tier 3 (specificity over generality) is speculative. Consider deferring until real conflicts occur. |
| 2 | ADVISE | `docs/external-skills.md` | Standalone 157-line doc is premature for a zero-user feature. Consider consolidating into `orchestration.md` subsection. |

Both advisories are non-blocking. The core mechanism is sound, proportional, and avoids the major YAGNI/KISS pitfalls (no new infrastructure, no metadata coupling, no framework). The documentation volume is the only area where accidental complexity has crept in -- and it is documentation, not code, so the maintenance cost is low.
