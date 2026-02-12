# Phase 1: Meta-Plan -- Prompt Files to Scratch

## Summary

Write agent input prompts to named files in the scratch directory before invocation. Agents receive a file reference instead of the full prompt inline. This provides transparency (users trace advisories to exact prompts) and context preservation (prompts survive compaction and can be re-read).

## Planning Consultations

### Consultation 1: Developer Experience Design for Prompt File Delivery

- **Agent**: devx-minion
- **Planning question**: The current SKILL.md has five distinct agent invocation patterns (Phase 1 nefario, Phase 2 specialists, Phase 3 nefario synthesis, Phase 3.5 reviewers, Phase 4 execution agents, Phase 5 code reviewers). Each pattern currently embeds the prompt inline in a `prompt:` field of the Task tool call. How should we restructure these to write the prompt to a file first and then deliver a file-reference prompt instead? Specifically:
  1. What naming convention for prompt files? The scratch dir already has output files like `phase2-{agent}.md` -- should input prompt files use a `-prompt` suffix (e.g., `phase2-{agent}-prompt.md`) or a separate subdirectory?
  2. What is the minimal "file-reference prompt" that tells an agent to read its full instructions from a file? Should it include any inline context (task summary, role statement) or be purely a file reference?
  3. How do we pair input prompt files with output files so the relationship is obvious? Same base name with different suffixes? Adjacent naming?
  4. How does this affect the advisory format in the execution plan approval gate? Currently advisories reference `$SCRATCH_DIR/{slug}/phase3.5-{reviewer}.md` -- should they also reference the input prompt that produced the advisory?
- **Context to provide**: Current SKILL.md invocation patterns (lines 312-349, 365-408, 419-461, 516-538, 800-810, 999-1029). Current scratch directory structure convention (lines 224-240). Advisory format (lines 668-692).
- **Why this agent**: devx-minion specializes in CLI design, developer onboarding, and configuration files. The prompt file pattern is fundamentally a developer experience decision -- how agents discover and read their instructions, how humans trace outputs back to inputs. devx-minion will design the naming convention, the file-reference delivery mechanism, and the pairing scheme.

### Consultation 2: Simplicity and Scope Guard

- **Agent**: ux-strategy-minion
- **Planning question**: This task adds a new layer of indirection (write file, reference file, read file) to every agent invocation. From a cognitive load and journey coherence perspective:
  1. Does the file-reference pattern add unnecessary complexity for agent invocations where the prompt is short (e.g., Phase 3.5 reviewers, which have ~15-line prompts)? Should there be a threshold below which prompts remain inline?
  2. The transparency goal (users trace advisories to prompts) assumes users will actually follow file references. Is there a simpler way to achieve this transparency without the full file-reference pattern?
  3. The context preservation goal (prompts survive compaction) is the more concrete benefit. Is the file-reference delivery pattern necessary for this, or could prompts be written to scratch files as a side effect without changing how agents receive their instructions?
- **Context to provide**: The task's two stated goals (transparency and context preservation). Current scratch file convention. Current advisory format with file references.
- **Why this agent**: ux-strategy-minion evaluates WHAT is built and WHY, ensuring features serve real user jobs-to-be-done. This task has two goals that may not require the same solution. ux-strategy-minion will challenge whether the proposed mechanism (file-reference delivery) is the simplest way to achieve both goals, or whether the goals can be separated.

### Cross-Cutting Checklist

- **Testing**: Exclude from planning. This task modifies a SKILL.md file (LLM-interpreted instructions), not executable code. There is no test infrastructure for SKILL.md behavior -- it is validated by Phase 3.5 architecture review and Phase 5 code review (lucy and margo). Including test-minion for planning would yield no actionable input.
- **Security**: Exclude from planning. The change writes agent prompts (which are already constructed in memory) to scratch files (which already exist in the same temp directory). No new attack surface, no new secrets handling, no new input processing. security-minion will review at Phase 3.5 as mandatory reviewer.
- **Usability -- Strategy**: INCLUDED as Consultation 2. Planning question: Does the file-reference indirection add justified value for both stated goals, or can the goals be achieved more simply?
- **Usability -- Design**: Exclude from planning. No user-facing interfaces are produced. The change affects file naming conventions and advisory text formatting, not visual design.
- **Documentation**: Exclude from planning. software-docs-minion will review the plan at Phase 3.5. Documentation updates (if any) to docs/orchestration.md or similar are execution-phase work, not planning-phase work. The task scope explicitly excludes changes to META-PLAN or SYNTHESIS content format, so the documentation surface is minimal.
- **Observability**: Exclude from planning. No runtime components, services, or APIs are produced.

### Anticipated Approval Gates

**Zero gates recommended.** Rationale:

All changes are to a single file (`skills/nefario/SKILL.md`) and possibly satellite files (`nefario/AGENT.overrides.md`, `docs/orchestration.md`). These are:
- Easy to reverse (text edits to instruction files)
- Low blast radius (no downstream tasks depend on the prompt file format as an API contract)
- Clear best practice (the naming convention is an internal decision with no external consumers)

The existing Phase 3.5 architecture review (mandatory: security-minion, test-minion, ux-strategy-minion, software-docs-minion, lucy, margo) provides sufficient validation. No mid-execution approval gate is needed.

### Rationale

Two specialists are consulted:

1. **devx-minion** is the primary planner because this is fundamentally a developer experience design problem -- how agents receive instructions, how humans trace outputs, how files are named and paired. The naming convention, file-reference mechanism, and pairing scheme are all devx-minion's core domain.

2. **ux-strategy-minion** serves as the simplification auditor. The task proposes a specific mechanism (file-reference delivery) for two goals (transparency and context preservation). These goals may be achievable more simply. ux-strategy-minion will evaluate whether the proposed approach is the minimum effective solution or whether it introduces unnecessary indirection.

No other specialists add planning value here:
- This is not a protocol/API change (no api-design-minion, mcp-minion)
- This is not infrastructure (no iac-minion)
- This is not a UI change (no frontend-minion, ux-design-minion, accessibility-minion)
- This is not a data model change (no data-minion)
- Cross-cutting reviewers (security, testing, docs, governance) will participate at Phase 3.5, not planning

### Scope

**In scope**:
- Prompt file creation convention: naming, location within scratch directory, content format
- Agent file-reference delivery: how each invocation pattern changes to reference the file
- Input/output pairing: how prompt files relate to output files
- Advisory formatting: adding prompt file references to advisory summaries
- All phases that invoke agents: Phase 1, 2, 3, 3.5, 4, 5

**Out of scope** (per task constraints):
- Changes to agent system prompts (AGENT.md files)
- Changes to META-PLAN or SYNTHESIS content format
- Scratch directory cleanup/retention policy
- Existing orchestration behavior (phase flow, agent selection, synthesis)

### External Skill Integration

#### Discovered Skills

| Skill | Location | Classification | Domain | Recommendation |
|-------|----------|---------------|--------|----------------|
| despicable-lab | .claude/skills/despicable-lab/ | LEAF | Agent rebuilding from specs | Not relevant -- task does not modify agent specs or AGENT.md files |
| despicable-statusline | .claude/skills/despicable-statusline/ | LEAF | Status line configuration | Not relevant -- task does not affect status line |
| despicable-prompter | skills/despicable-prompter/ | LEAF | Briefing coach for /nefario | Not relevant -- task does not affect how users formulate task descriptions |
| nefario | skills/nefario/ | ORCHESTRATION | Orchestration workflow | This IS the file being modified -- not an external skill to incorporate, but the target artifact |

#### Precedence Decisions

No precedence conflicts. All discovered skills operate in domains unrelated to this task. The nefario skill is the modification target, not an external resource to invoke.
