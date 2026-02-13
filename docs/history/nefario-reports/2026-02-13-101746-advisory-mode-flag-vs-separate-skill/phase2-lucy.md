# Phase 2: Lucy -- Advisory Mode Alignment Review

## Planning Question

Does advisory mode change nefario's identity from "task orchestrator" to "team coordination tool"? How should advisory reports relate to existing execution reports? Should advisory output be committed or local? Does this align with or drift from the project's stated purpose?

## Analysis

### 1. Identity Drift Assessment

Nefario's identity in `the-plan.md` (spec-version 2.0) is:

> **Domain**: Task orchestration, multi-agent coordination, work decomposition

The remit list includes:
- "Decomposing complex tasks into specialist subtasks"
- "Synthesizing results from multiple minions into coherent output"
- "Detecting gaps where no minion covers a requirement"

**Finding**: Advisory mode does NOT change nefario's identity. Nefario already does team assembly, specialist consultation, and synthesis (Phases 1-3). Advisory mode is a *subset* of what nefario already does -- it runs Phases 1-3 and stops. The "task orchestrator" identity is preserved because advisory coordination IS orchestration. The key question is whether stopping before execution still counts as orchestration. It does: the current MODE: PLAN already produces an execution plan without executing it; advisory would produce an evaluation without an execution plan.

**Verdict**: No identity drift. Advisory mode is a natural third mode alongside META-PLAN/SYNTHESIS and PLAN.

### 2. Precedent: SDK Evaluation Was Advisory-Only, Done Ad Hoc

The file `sdk-evaluation-proposal.local.md` at the project root is direct evidence of advisory-only work already being performed. Four specialists (gru, lucy, ai-modeling-minion, ux-strategy-minion) were consulted and their analyses synthesized into a decision document. Key observations:

- The work was done **outside nefario's formal process** (ad-hoc agent spawning)
- Working files landed in `nefario/scratch/sdk-evaluation/` and `nefario/scratch/lucy-sdk-alignment-review.md` -- non-standard locations, not following scratch directory conventions
- Output was a `.local.md` file (gitignored), not committed to `docs/history/nefario-reports/`
- The document structure is organic, not following the execution report template
- The report was useful and well-structured despite the ad-hoc process

This proves the need exists. The user already wants this capability and has used it. The question is whether to formalize it.

### 3. Flag vs. Separate Skill -- Alignment Analysis

**Option A: Flag on nefario (e.g., `/nefario --advisory <question>`)**

Traceability to stated requirements:
- Nefario already owns Phases 1-3 (team assembly, specialist consultation, synthesis). Advisory mode reuses this exact machinery.
- The delegation table is in nefario's prompt. Advisory mode needs the delegation table.
- The specialist spawning infrastructure is in SKILL.md. Advisory mode needs specialist spawning.
- No new agent, no new tool, no new dependency.

Alignment with CLAUDE.md engineering philosophy:
- YAGNI: Adds one MODE, not a new skill directory, SKILL.md, install entry, or symlink.
- KISS: User already knows `/nefario`. `/nefario --advisory` is discoverable.
- Lean and Mean: Reuses existing code paths, adds a branch, not a parallel system.

**Option B: Separate skill (e.g., `/advisory`)**

Traceability to stated requirements:
- Would duplicate nefario's team assembly logic (delegation table, specialist spawning, synthesis).
- Needs its own SKILL.md, own scratch directory conventions, own report format.
- Creates a boundary question: when does advisory work go through `/advisory` vs. `/nefario`?

Alignment with CLAUDE.md engineering philosophy:
- Violates YAGNI: Builds a parallel orchestration system for a subset of existing orchestration.
- Violates KISS: Two commands for team coordination where one suffices.
- Violates Lean and Mean: More files, more symlinks, more to maintain.

**Verdict: Flag on nefario. A separate skill would be scope creep.**

### 4. Advisory Reports -- Location and Format

#### Same directory or different?

Existing execution reports go to `docs/history/nefario-reports/` with a canonical template (TEMPLATE.md, v3). The template is heavily execution-oriented: Phases 4-8 sections, Files Changed table, Approval Gates table, Verification table, Test Plan section.

An advisory report has none of these. Forcing advisory output into the execution template would produce a report that is 60% "Skipped" or "N/A" sections. This is noise, not structure.

**Options**:
1. Same directory, same template (with skipped sections) -- Consistent location, but noisy format
2. Same directory, advisory-specific template -- Consistent location, appropriate format
3. Different directory (e.g., `docs/history/nefario-advisories/`) -- Clean separation, but fragments report history
4. Same directory, different frontmatter `type` field -- The TEMPLATE.md already has `type: nefario-report`. Advisory could use `type: nefario-advisory`. Same directory, different template selected by type.

**Recommendation: Option 4 -- Same directory, different type, advisory template.**

Rationale:
- Single `docs/history/nefario-reports/` directory preserves chronological history of all nefario orchestrations. The `build-index.sh` script reads all reports from this directory; advisory reports would appear in the same timeline.
- The `type` frontmatter field distinguishes them. Filtering is trivial (grep frontmatter).
- Advisory template omits execution sections entirely, includes: Summary, Original Question, Team Consensus, Per-Agent Analysis, Key Findings, Recommendation, Dissenting Views (if any), Re-evaluation Triggers.
- Filename convention: same as execution reports (`YYYY-MM-DD-HHMMSS-slug.md`). The slug naturally differs because advisory tasks are questions, not action items.

#### Committed or local?

The SDK evaluation was `.local.md` (gitignored). But this was a choice made ad hoc, not a policy. The question is: are advisory reports valuable to commit?

Arguments for committing:
- Advisory reports document decisions and rationale. Decisions are project knowledge.
- The SDK evaluation report would have been MORE useful if committed -- future contributors could see why the SDK was rejected.
- Git history provides discovery. Local files are invisible to collaborators.
- The existing execution report convention commits reports. Consistency.

Arguments for local-only:
- Some advisory topics are exploratory ("should we...?") and may not warrant permanent record.
- Advisory reports may contain competitive analysis or technology assessments that age poorly.

**Recommendation: Committed by default, with a `--local` flag to keep output as `.local.md` when the user explicitly wants local-only.** This matches the execution report default (always committed) while respecting that some evaluations are ephemeral.

### 5. Phase Structure for Advisory Mode

Advisory mode should reuse Phases 1-3 and add a synthesis-specific instruction:

| Phase | Advisory Behavior |
|-------|-------------------|
| Phase 1 (Meta-Plan) | Same. Identify which specialists to consult. Team approval gate same as always. |
| Phase 2 (Specialist Planning) | Same. Specialist contributions. But the planning question framing shifts from "how should we build X" to "what is your assessment of X." |
| Phase 3 (Synthesis) | Different. Instead of producing an execution plan, nefario synthesizes an advisory report: team consensus, dissenting views, recommendation, re-evaluation triggers. |
| Phase 3.5 | Skip. No plan to review. |
| Phase 4-8 | Skip. No execution. |

The synthesis prompt for advisory mode needs a `MODE: ADVISORY-SYNTHESIS` or the existing `MODE: SYNTHESIS` with an advisory flag. The output format shifts from "execution plan with task prompts" to "evaluation report with recommendation."

### 6. Scope Creep Risk Assessment

The user asked a focused question: "flag or separate skill?" The answer should be equally focused.

**In scope** (directly traceable to the question):
- Decision: flag on nefario vs. separate skill
- Where advisory reports go
- Whether they are committed
- How advisory mode relates to existing modes

**Out of scope** (would be scope creep to include in an implementation plan):
- Designing the full advisory template (do when implementing)
- Modifying `build-index.sh` to handle advisory type (do when implementing)
- Adding advisory-specific sections to nefario's AGENT.md (do when implementing)
- Creating advisory-specific Phase 3 synthesis prompts (do when implementing)

The implementation work is a separate nefario orchestration. This advisory should produce a recommendation, not an implementation plan.

## Risks

1. **Mode proliferation**: Nefario currently has 3 modes (META-PLAN, SYNTHESIS, PLAN). Adding ADVISORY is a 4th. Risk is low -- each mode is clearly distinct and non-overlapping. But the next request should be scrutinized harder.

2. **Template divergence**: An advisory template alongside the execution template creates a maintenance surface. Both must evolve consistently (e.g., if frontmatter fields change). Mitigated by keeping the advisory template minimal.

3. **Phase 2 question framing**: Advisory mode needs specialists to evaluate/assess rather than plan/build. The planning question in Phase 1 must explicitly frame the ask as "evaluate and recommend" rather than "plan implementation." If this framing is wrong, specialists will produce implementation plans instead of evaluations (this is exactly what happened organically -- the SDK evaluation had to explicitly frame questions as evaluative).

## Dependencies

- Nefario AGENT.md needs a new mode section (MODE: ADVISORY or similar)
- SKILL.md needs advisory flow (Phases 1-3, skip 3.5-8, advisory synthesis prompt)
- Report TEMPLATE needs an advisory variant (or a second template file)
- `build-index.sh` may need to handle `type: nefario-advisory` frontmatter

## Recommendation

**Add a `--advisory` flag to `/nefario`.** It is a natural extension of existing orchestration, not a new capability. The flag instructs nefario to run Phases 1-3 in evaluation mode, produce an advisory report instead of an execution plan, and commit it to `docs/history/nefario-reports/` with `type: nefario-advisory` frontmatter. A separate skill would duplicate orchestration machinery and fragment the user experience without adding value.

## Additional Specialists

No additional specialists beyond those already in this planning session are needed for this decision. The question is about nefario's scope (orchestration architecture) and project conventions (report structure, commit policy) -- both squarely in the planning team's domain. Implementation, if approved, would be a standard nefario orchestration involving devx-minion (flag design), software-docs-minion (template), and the usual governance reviewers.
