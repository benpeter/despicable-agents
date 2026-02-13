## Domain Plan Contribution: ux-strategy-minion

### Analysis of the Current Problem

The Communication Protocol's three-tier system (SHOW / NEVER SHOW / CONDENSE) made a classification error: it placed phase transition announcements in NEVER SHOW alongside genuinely useless output like agent spawning narration and task polling. Phase transitions serve a fundamentally different user need than those items.

The key distinction:
- **Agent spawning, task polling, completion acknowledgments** = implementation mechanics. The user does not need to know HOW the orchestrator works internally. Suppressing these is correct.
- **Phase transitions** = journey waypoints. The user needs to know WHERE they are in the process. Suppressing these destroyed orientation.

This is a textbook violation of Nielsen's heuristic #1 (Visibility of System Status): "The system should always keep users informed about what is going on, through appropriate feedback within reasonable time." A nine-phase orchestration that runs silently between gates leaves the user unable to answer the most basic question: "What is happening right now?"

### Recommendations

#### 1. Redesign the tier system from two-axis to three-axis

The current tiers conflate two independent dimensions: (a) whether information is useful and (b) how much space it should take. Replace the three tiers with a clearer framework organized by user need:

**ORIENTATION** (new tier -- always show, one line each):
- Phase transition markers
- Compaction checkpoint prompts (already shown, reclassify here)
- Heartbeat status lines (already exist for 60s+ silence)

**DECISION** (existing SHOW tier, renamed for clarity):
- All approval gates (team, reviewer, execution plan, mid-execution)
- Approval gate decision briefs
- PR creation prompt
- Final summary
- Warnings, errors, escalations

**SUPPRESS** (merge of NEVER SHOW and most of CONDENSE):
- Agent spawning/completion narration
- Prompt echoing
- Task polling
- Verbose git output
- Review verdicts (unless BLOCK)
- Post-execution phase internals

**CONDENSE** (keep, but narrow scope):
- Meta-plan result (already well-defined)
- Review summary when no BLOCK
- Post-execution start/result
- ADVISE notes folded into task prompts

The critical change: ORIENTATION gets its own tier because orientation and decisions serve different cognitive functions. Orientation is peripheral awareness ("I know where I am"). Decisions require focused attention ("I need to choose"). Lumping them into the same SHOW tier risks either over-formatting orientation lines (making them look like they demand attention) or under-formatting decisions (making them easy to miss).

#### 2. Phase announcement design: minimal, predictable, peripheral

Phase announcements should follow calm technology principles -- they inform without demanding focus. The user should be able to glance at a phase announcement and know where they are without stopping to read.

**Design constraints for phase announcements:**
- One line maximum. No multi-line frames, no horizontal rules, no whitespace blocks.
- Consistent pattern across all phases (same prefix, same structure).
- Include phase number and name (recognition over recall -- the user has seen the phase list in the execution plan gate).
- Include a brief status hint where useful (e.g., number of agents, what's being waited on).
- Do NOT include scratch paths, agent lists, or implementation details.

**Recommended pattern:**
```
--- Phase N: <Name> <optional brief context> ---
```

Examples:
```
--- Phase 1: Meta-Plan ---
--- Phase 2: Specialist Planning (4 agents) ---
--- Phase 3: Synthesis ---
--- Phase 3.5: Architecture Review (7 reviewers) ---
--- Phase 4: Execution (3 tasks, 1 gate) ---
--- Phase 5-8: Verification ---
```

Why this pattern works:
- The `---` delimiters create a visual break without being heavy. They are the lightest framing available in monospace text.
- Phase number provides instant orientation.
- Name provides recognition (matches the nine-phase overview the user saw at the execution plan gate).
- Optional parenthetical gives just enough context to set expectations ("4 agents" tells me I'll wait a bit; "1 gate" tells me I'll need to make a decision).
- One line means it never competes with approval gates for attention. It is clearly subordinate in the visual hierarchy.

**What NOT to do:**
- Do not use multi-line frames (`===`, `***`, box drawing). These elevate phase announcements to the same visual weight as approval gates, creating a false equivalence.
- Do not repeat the phase description from the plan. The name is enough.
- Do not include "Starting..." or "Entering..." verbs. They add words without information. The phase marker itself implies transition.

#### 3. Scratch path presentation: label-first, path-second

Current state: approval gates expose raw scratch paths like `$SCRATCH_DIR/{slug}/phase1-metaplan.md`. These paths are:
- Opaque (what is a "metaplan"? the user just approved a "team").
- Long (temp directories with random suffixes consume visual space).
- Inconsistent (some gates show them, the execution plan gate has a separate "FULL PLAN:" label, but the team gate just says "Full meta-plan:" inline).

**Principle: label describes the job, path is the implementation.**

Users do not want to "read phase1-metaplan.md" -- they want to "review the full team analysis" or "see the complete execution plan." The label should describe what the user gets, not what the file is called.

**Recommended pattern for all artifact references:**
```
<Meaningful label>: <path>
```

Specific labels (mapped to current raw references):

| Current reference | Recommended label |
|---|---|
| `Full meta-plan: $SCRATCH_DIR/.../phase1-metaplan.md` | `Team analysis: <path>` |
| `Full plan: $SCRATCH_DIR/.../phase3-synthesis.md` | `Full execution plan: <path>` (already good) |
| `Full context: $SCRATCH_DIR/.../phase3.5-{reviewer}.md` | `Review details: <path>` |
| `Details: $SCRATCH_DIR/.../phase3.5-{reviewer}.md` | `Advisory details: <path>` |
| `Working dir: $SCRATCH_DIR/{slug}/` | `Working files: <path>` |

**Path display strategy:**
- Always show the full resolved path. Do not truncate or abstract it. The user needs to be able to `cat` or `open` the path directly from their terminal. Abstraction (e.g., "see scratch files") creates an extra lookup step.
- Put the label first, path second. The user scans labels; the path is reference material for when they want to act.
- Keep artifact references at the bottom of gate blocks. They are supplementary information, not the decision point. Placing them above the decision options would invert the visual hierarchy.

#### 4. Gate visual hierarchy: three levels of urgency

The current system has approval gates at varying sizes (team gate: 8-12 lines, reviewer gate: 6-10 lines, execution plan: 25-40 lines, mid-execution: 12-18 lines) but no consistent visual language distinguishing gates from each other or from phase announcements.

**Establish three visual levels:**

1. **Phase marker** (1 line) -- orientation, peripheral awareness.
   `--- Phase N: Name ---`

2. **Informational line** (1 line) -- CONDENSE output, progress updates.
   `Planning: consulting devx-minion, security-minion, ... (pending approval) | Skills: 0 | Scratch: /path`

3. **Decision gate** (multi-line block) -- requires user action.
   Begins with `ALL-CAPS LABEL:` header on the first line (TEAM:, REVIEWERS:, EXECUTION PLAN:, APPROVAL GATE:). The all-caps label is the strongest visual signal available in monospace without relying on markdown rendering.

The user learns to scan for these three patterns:
- Dashes = "I know where I am" (glance and continue)
- Single line = "progress is happening" (glance and continue)
- ALL-CAPS BLOCK = "I need to decide something" (stop and read)

This three-level hierarchy maps directly to attention demands. Calm technology principle: the lightest signal for the lightest need.

#### 5. Post-execution phases: do not break the dark kitchen

Phases 5-8 currently follow the "dark kitchen" pattern (run silently, CONDENSE start/result). This is correct and should not be changed. These phases do not contain decision points for the user (unless a BLOCK is escalated), so phase announcements inside the dark kitchen would be noise.

However, the transition INTO the dark kitchen should be announced. The existing CONDENSE line `Verifying: code review, tests, documentation...` already serves this purpose. Reclassify it as an ORIENTATION item so its role is explicit.

#### 6. Move phase transitions from NEVER SHOW to ORIENTATION

This is the core change. Move "Phase transition announcements" from the NEVER SHOW list to the new ORIENTATION tier. Keep agent spawning, task polling, and completion acknowledgments in SUPPRESS.

**Specifically move:**
- "Phase transition announcements" -> ORIENTATION (with the one-line format defined above)

**Keep in SUPPRESS:**
- "Agent spawning narration"
- "Task status polling output"
- "Agent completion acknowledgments"
- "Echoing prompts being sent to subagents"
- "Post-execution phase transitions" (internal to dark kitchen)
- "Post-execution reviewer spawning and auto-fix iterations"

**Keep in CONDENSE (unchanged):**
- Meta-plan result
- Phase 1 re-run result
- Review verdicts (if no BLOCK)
- ADVISE notes
- Post-execution start and result

### Proposed Tasks

**Task 1: Restructure Communication Protocol tiers in SKILL.md**
- Replace the current SHOW / NEVER SHOW / CONDENSE three-tier system with ORIENTATION / DECISION / SUPPRESS / CONDENSE four-tier system.
- Move phase transition announcements to ORIENTATION.
- Define the one-line phase announcement format.
- Deliverables: Updated Communication Protocol section in SKILL.md.
- Dependencies: None (this is the foundational change).

**Task 2: Define phase announcement format and placement in SKILL.md**
- Add a phase announcement line immediately before each phase section's content (Phase 1, 2, 3, 3.5, 4, 5-8 entry).
- Specify the format: `--- Phase N: <Name> <optional context> ---`
- Specify what context is permitted in each phase's announcement (agent count, task count, gate count -- not paths or prompts).
- Deliverables: Phase announcement specifications added to each phase section.
- Dependencies: Task 1 (tier restructure defines where announcements fit).

**Task 3: Standardize artifact reference labels across all gates**
- Replace raw scratch path references with label-first, path-second format.
- Apply consistent labeling across team gate, reviewer gate, execution plan gate, mid-execution gates, and impasse escalation.
- Deliverables: Updated gate format blocks in SKILL.md.
- Dependencies: None (can run in parallel with Task 1 and 2).

**Task 4: Document the visual hierarchy convention**
- Add a brief "Visual Hierarchy" subsection to the Communication Protocol explaining the three attention levels (phase marker, informational line, decision gate) and their formatting patterns.
- This serves as a reference for anyone editing SKILL.md to maintain consistency.
- Deliverables: New subsection in Communication Protocol.
- Dependencies: Tasks 1 and 2 (references the patterns they define).

### Risks and Concerns

1. **Over-restoration risk**: The temptation is to add too much back. Phase announcements must stay at one line. If they grow to 2-3 lines with context, they start competing with CONDENSE lines and gates. Enforce the one-line constraint as a hard rule.

2. **Inconsistent adoption**: The SKILL.md is consumed by an LLM (the calling session). If the tier system is ambiguous or has edge cases, the model may misinterpret what to show. Keep the tier definitions crisp and provide explicit examples. The "NEVER SHOW" label was arguably more memorable than alternatives -- "SUPPRESS" needs to be equally unambiguous.

3. **Markdown rendering variance**: Claude Code renders markdown in a terminal. The `---` delimiter may render as a horizontal rule rather than literal text depending on context (markdown spec: three or more hyphens on a line = `<hr>`). This needs testing. If `---` renders as a full-width horizontal rule, it becomes heavier than intended. Alternative: use a different delimiter that does not have markdown semantics (e.g., `-- Phase N: Name --` with two dashes, or `[Phase N: Name]`).

4. **Regression in suppression**: Moving items between tiers risks accidentally promoting suppressed content. The diff should be audited to confirm that only phase transitions moved, and everything else stayed in place. A before/after mapping table would help reviewers verify.

5. **Label-path format adoption across future gates**: New gates added to SKILL.md in the future need to follow the label-first convention. Without a clear reference (Task 4), future editors may revert to raw paths. The Visual Hierarchy subsection mitigates this.

### Additional Agents Needed

None. The current team (ux-design-minion for visual patterns, devx-minion for file reference conventions, software-docs-minion and user-docs-minion for documentation, product-marketing-minion for positioning) covers all necessary perspectives. The UX strategy contribution here provides the information architecture framework that the design and devx agents will implement within.
