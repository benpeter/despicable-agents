# Domain Plan Contribution: ai-modeling-minion

## Recommendations

### 1. Classification Boundary: What Makes Markdown "Logic-Bearing"

The core insight is this: in an LLM agent system, the system prompt IS the code. An AGENT.md file is not documentation about an agent -- it is the executable specification that determines agent behavior at runtime. Changing a word in a system prompt can change behavior as dramatically as changing a line of Python. The same applies to SKILL.md files, which are orchestration programs expressed in natural language.

The classification should be grounded in a functional test: **does changing this file alter the runtime behavior of an LLM agent or orchestration workflow?** If yes, it is logic-bearing. If it only informs human readers, it is documentation.

Applying this test to the project's file types:

| File | Classification | Reasoning |
|------|---------------|-----------|
| `AGENT.md` (in agent directories) | Logic-bearing | These files ARE system prompts. They contain YAML frontmatter (model selection, tool grants) and the complete behavioral specification that is injected into the LLM context window. Changing them changes agent behavior. |
| `SKILL.md` (in skill directories) | Logic-bearing | These define orchestration workflows, phase logic, communication protocols, and conditional branching. They are programs written in structured natural language. |
| `RESEARCH.md` (in agent directories) | Logic-bearing | These contain domain knowledge that directly informs the adjacent AGENT.md system prompt. Changes to research files typically indicate that the corresponding prompt should be updated, and review should verify prompt-research consistency. |
| `README.md` | Documentation | Informs human readers about the project. Does not affect agent behavior. |
| `CLAUDE.md` | Logic-bearing | Project instructions that Claude Code reads and follows. Changing these changes agent behavior across all agents in the project. |
| `the-plan.md` | Logic-bearing | Canonical spec that agent definitions are built from. (Protected file -- cannot be modified, but should be classified correctly for the rare case where the human owner modifies it.) |
| `docs/*.md` | Documentation | Architecture docs, design docs, guides. Inform humans and AI planning, but do not execute as agent instructions. |
| Changelog, license, contributing guides | Documentation | Standard project documentation. |

### 2. Classification Mechanism: Layered, Filename-Primary

I recommend a **two-layer classification** that prioritizes filename conventions (deterministic, fast) with directory context as tiebreaker:

**Layer 1 -- Filename match (covers 95% of cases):**
- `AGENT.md` -- always logic-bearing
- `SKILL.md` -- always logic-bearing
- `RESEARCH.md` -- always logic-bearing
- `CLAUDE.md` -- always logic-bearing
- `the-plan.md` -- always logic-bearing

**Layer 2 -- Directory context (for files not matching Layer 1):**
- Files inside agent directories (`gru/`, `nefario/`, `lucy/`, `margo/`, `minions/*/`) that are not in the Layer 1 list -- default to logic-bearing unless clearly auxiliary (e.g., a test fixture or generated output).
- Files inside `skills/*/` directories -- default to logic-bearing.
- Files inside `docs/` -- default to documentation.
- Files in project root not matching Layer 1 -- default to documentation.

**Why not content heuristics?** Content analysis (looking for "Identity" sections, YAML frontmatter, structured headings) is fragile, adds prompt complexity, and creates a moving target as the project evolves. The filename convention is already strongly established in this project and is trivially extensible. An LLM reading a system prompt instruction like "AGENT.md, SKILL.md, RESEARCH.md, and CLAUDE.md are logic-bearing files" will apply this consistently. Asking it to "check whether the file contains structured sections like Identity or Working Patterns" invites inconsistent edge-case judgment.

**Why filename + directory, not filename alone?** Pure filename matching has one failure mode: a file named `AGENT.md` outside an agent directory (unlikely but possible). The directory layer catches this. More importantly, it provides a default classification for new file types that someone adds inside an agent directory -- if you put `PROMPTS.md` inside `minions/ai-modeling-minion/`, the directory context tells nefario it is probably logic-bearing even though it is not in the explicit list.

**Extensibility:** When new logic-bearing file types emerge, add them to the Layer 1 list. This is a one-line change in the system prompt. The directory heuristic provides a safety net during the gap between a new file type being introduced and the list being updated.

### 3. Delegation Table and Team Assembly Fix

The delegation table in `nefario/AGENT.md` currently has these ai-modeling-minion entries:

| Task Type | Primary | Supporting |
|-----------|---------|------------|
| LLM prompt design | ai-modeling-minion | mcp-minion |
| Multi-agent architecture | ai-modeling-minion | mcp-minion |
| LLM cost optimization | ai-modeling-minion | iac-minion |

The gap: there is no row that maps "modifying agent definition files" or "modifying orchestration rules" to ai-modeling-minion. When a task is framed as "fix the Phase 5 conditional in SKILL.md" rather than "redesign the multi-agent architecture," nefario does not match it to the delegation table because the task description uses file-change language rather than domain-concept language.

**Recommended additions to the delegation table:**

| Task Type | Primary | Supporting |
|-----------|---------|------------|
| Agent system prompt design/modification | ai-modeling-minion | lucy |
| Orchestration rule changes (SKILL.md) | ai-modeling-minion | ux-strategy-minion |
| Agent definition changes (AGENT.md) | ai-modeling-minion | lucy |

**Recommended addition to the Task Decomposition Principles section:**

Add a principle that explicitly maps file types to domains. Something like:

> **File-Domain Awareness**: When analyzing which domains a task involves, consider the semantic nature of the files being modified, not just their extension. Agent definition files (AGENT.md), orchestration rules (SKILL.md), domain research backing prompts (RESEARCH.md), and project agent instructions (CLAUDE.md) are prompt engineering and multi-agent architecture artifacts, even though they use the `.md` extension. Changes to these files should be routed through ai-modeling-minion. Conversely, README.md, docs/*.md, and similar files are documentation artifacts routed through software-docs-minion or user-docs-minion.

This principle serves two purposes:
1. It provides explicit guidance for the "analyze the task against the delegation table" step in META-PLAN mode
2. It future-proofs against the underlying failure mode: nefario treating file extension as a proxy for domain

### 4. Phase 5 Skip Conditional Fix

The current line reads:

> Skip if Phase 4 produced no code files (only docs/config). Note the skip.

This needs to be rewritten to use the classification boundary. Recommended replacement:

> Skip if Phase 4 produced only documentation files (README, docs/, changelogs, license files). Do NOT skip for logic-bearing files: AGENT.md, SKILL.md, RESEARCH.md, CLAUDE.md, the-plan.md, or any file inside an agent or skill directory. These files contain system prompts, orchestration rules, or domain knowledge that directly governs agent behavior -- they require code review.

The replacement does three things:
1. Inverts the default: instead of "skip unless code," it says "run unless pure documentation"
2. Names the specific file types that are logic-bearing (deterministic, no judgment required)
3. Explains WHY these files need review (helps the LLM generalize to unlisted edge cases)

The same classification should be applied consistently to the Phase 5 conditional at lines 1648-1649 ("Also skip if Phase 4 produced no code files") to avoid the two conditionals diverging.

### 5. Edge Cases: Default to Logic-Bearing (Conservative)

For the specific question of RESEARCH.md: yes, it is both documentation (human-readable domain knowledge) and logic-bearing (directly informs the adjacent system prompt). The conservative classification is correct here. The cost of an unnecessary code review is one subagent call (~30 seconds). The cost of skipping review on a file that subtly changes agent behavior is a deployed defect. The asymmetry strongly favors defaulting to "logic-bearing."

The general rule: **when a file could be either, classify it as logic-bearing.** This is the same principle as "when in doubt, include the security review" -- the cost of a false positive (unnecessary review) is far lower than the cost of a false negative (missed defect in agent behavior).

One genuine documentation-only edge case worth noting: if someone creates a `CHANGELOG.md` inside an agent directory to track that agent's version history, the directory heuristic would classify it as logic-bearing. This is an acceptable false positive -- it happens rarely, and the code reviewer can APPROVE instantly. The alternative (adding content heuristics to distinguish it) would add complexity disproportionate to the problem.

## Proposed Tasks

### Task 1: Define and document the classification boundary

**What**: Write the canonical definition of "logic-bearing markdown" vs "documentation-only markdown" as a new subsection in `nefario/AGENT.md`, in or adjacent to the Task Decomposition Principles section. This definition is the single source of truth referenced by both the Phase 5 conditional and the team assembly logic.

**Deliverables**: New subsection in `nefario/AGENT.md` containing the two-layer classification (filename list + directory context), the defaulting rule (ambiguous = logic-bearing), and 3-4 worked examples.

**Dependencies**: None. This is the foundational definition that other tasks reference.

### Task 2: Add delegation table entries for agent definition work

**What**: Add three rows to the delegation table in `nefario/AGENT.md` mapping agent/orchestration file modifications to ai-modeling-minion. Add a "File-Domain Awareness" principle to the Task Decomposition Principles section.

**Deliverables**: Updated delegation table and task decomposition principles in `nefario/AGENT.md`.

**Dependencies**: Task 1 (references the classification boundary definition).

### Task 3: Fix the Phase 5 skip conditional

**What**: Rewrite the Phase 5 skip conditional in `skills/nefario/SKILL.md` line 1670 to use the classification boundary. Replace "no code files (only docs/config)" with a conditional that names logic-bearing file types and defaults to running review. Apply the same fix to the summary conditional at lines 1648-1649 for consistency.

**Deliverables**: Updated Phase 5 skip logic in `skills/nefario/SKILL.md`.

**Dependencies**: Task 1 (references the classification boundary definition).

### Task 4: Verify documentation placement

**What**: Ensure the classification boundary definition is discoverable by future contributors. If the definition lives in `nefario/AGENT.md` (Task 1), add a brief cross-reference in `skills/nefario/SKILL.md` near the Phase 5 conditional pointing to the canonical definition. This prevents someone editing SKILL.md from needing to discover the definition independently.

**Deliverables**: Cross-reference comment or note in `skills/nefario/SKILL.md`. Optionally, a note in `docs/architecture.md` if software-docs-minion recommends it.

**Dependencies**: Tasks 1 and 3.

## Risks and Concerns

### Risk 1: Over-classification (false positives)

If the classification is too aggressive, every markdown change triggers code review, even trivial README typo fixes. This adds latency and cost for no value. **Mitigation**: The proposed classification is filename-primary, which is precise. README.md, docs/*.md, and root-level non-matching files are explicitly documentation-only. False positives are limited to rare edge cases (e.g., CHANGELOG.md inside an agent directory).

### Risk 2: Classification divergence between AGENT.md and SKILL.md

If the classification is defined in one place but referenced in two (delegation table and phase-skip conditional), future editors may update one without the other. **Mitigation**: Define the boundary once in `nefario/AGENT.md` and reference it by name from `skills/nefario/SKILL.md`. Task 4 addresses this explicitly.

### Risk 3: Prompt length inflation

Adding classification definitions, worked examples, and delegation table rows to AGENT.md and SKILL.md increases prompt token count. These files are already long system prompts. **Mitigation**: Keep the definition concise (target 150-200 tokens). Use the filename list as the primary mechanism (compact), not prose descriptions. The worked examples can be 3-4 one-liners, not paragraphs.

### Risk 4: the-plan.md drift

The delegation table in `nefario/AGENT.md` should match what is in `the-plan.md`. Adding delegation table rows to AGENT.md without updating the-plan.md creates divergence. However, the-plan.md is human-edited only. **Mitigation**: Flag the new delegation table rows as a recommendation for the human owner to add to the-plan.md. Do not modify the-plan.md directly. Track this as a follow-up item.

### Risk 5: RESEARCH.md classification as logic-bearing may surprise

Some contributors may expect RESEARCH.md to be freely editable documentation. Classifying it as logic-bearing means changes trigger code review, which could feel heavy for what seems like background research. **Mitigation**: The classification is correct from a prompt engineering perspective -- research files directly inform system prompts. However, the documentation should explain why (the prompt-research coupling) so contributors understand the intent rather than experiencing it as bureaucratic overhead.

## Additional Agents Needed

None. The current team (ai-modeling-minion, lucy, ux-strategy-minion, software-docs-minion) covers the necessary domains:

- **ai-modeling-minion** (this contribution): Classification boundary definition and prompt engineering domain expertise
- **lucy**: Intent alignment, convention compliance, proportionality check
- **ux-strategy-minion**: User journey impact of phase-skip behavior changes
- **software-docs-minion**: Documentation placement and format for the boundary definition

The meta-plan's exclusion of devx-minion is sound -- the structural concern (how to express the conditional in SKILL.md) is narrow enough to resolve during synthesis from the other contributions. Similarly, code-review-minion is not needed for planning since the Phase 5 review logic is a classification question (my domain) rather than a review methodology question (theirs).
