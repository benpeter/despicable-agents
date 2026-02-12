# Delegation Plan

**Team name**: prompt-files-to-scratch
**Description**: Write agent prompts to scratch files before invocation for transparency and context preservation. Side-effect persistence model: prompts written to scratch as durable artifacts, agents continue receiving prompts inline.

## Conflict Resolution: File-Reference Delivery vs. Side-Effect Writing

**Conflict**: devx-minion recommends changing agent delivery to file-reference (agents read their prompt from a file). ux-strategy-minion recommends keeping inline delivery and writing prompts to scratch as a side effect only.

**Resolution: Side-effect writing with selective persistence (ux-strategy-minion's approach, modified).**

Rationale:

1. **KISS/YAGNI alignment**: The project's engineering philosophy (CLAUDE.md) is explicit: "YAGNI -- don't build it until you need it" and "KISS -- simple beats elegant." Side-effect writing achieves both stated goals (transparency, context preservation) without introducing a new delivery mechanism, new failure modes (file-read failures, path mismatches), or additional latency (one extra Read call per agent invocation).

2. **Goal decomposition**: The two goals are independent and can be solved independently:
   - **Transparency** (trace advisories to prompts): Achieved by writing prompt files to scratch and including them in the companion directory at wrap-up. The `-prompt.md` naming convention (from devx-minion) makes input/output pairing discoverable by filename.
   - **Context preservation** (prompts survive compaction): Achieved by scratch persistence. The session needs results (summaries, verdicts, task lists) going forward, not prompts. If a prompt needs reconstruction after compaction, the scratch file provides recovery.

3. **Issue text interpretation**: The issue says "agents receive a file reference rather than the full prompt inline." This describes a mechanism, not a goal. The success criteria are: (a) prompts written to scratch before invocation, (b) clear input/output pairing, (c) advisories include prompt references, (d) existing behavior unchanged. Criteria (a), (b), (c) are fully met by side-effect writing. Criterion (d) is BETTER met by side-effect writing (zero behavior changes) than by file-reference delivery (changes every agent invocation pattern). The success criterion "Agents read their prompt from the file rather than receiving it entirely inline" is the one that literally requires file-reference delivery -- this will be flagged at the approval gate for the user to decide.

4. **Adopted from devx-minion**: The `-prompt` suffix naming convention, the input/output pairing scheme, the scratch directory structure update, and the optional `Prompt:` field in complex advisories. These are excellent convention design regardless of delivery mechanism.

5. **Selective persistence**: ux-strategy-minion recommends only persisting session-specific prompts (Phases 1-3), skipping templated reviewers (Phase 3.5, 5). However, this creates an inconsistency in the companion directory -- some phases have prompt files, others don't. For traceability completeness, **all phases that invoke agents get prompt files**. The marginal cost is small (a few extra Write calls for short prompts), and the benefit is a complete audit trail.

**What was rejected**:
- **File-reference delivery** (devx-minion): Over-engineers the solution by introducing a new protocol (write file -> pass reference -> agent reads file) when a simpler approach (write file -> pass inline as before) achieves the same goals. Adds failure surface (agent can't read file, path typo) without proportional benefit.
- **Selective persistence only** (ux-strategy-minion): Skipping Phase 3.5 and Phase 5 prompt files creates a gap in the audit trail. The marginal cost of writing these prompts is negligible compared to the consistency benefit.

---

### Task 1: Update SKILL.md scratch directory structure and add side-effect prompt writing
- **Agent**: devx-minion
- **Delegation type**: standard
- **Model**: sonnet
- **Mode**: default
- **Blocked by**: none
- **Approval gate**: yes
- **Gate reason**: Single-file change to SKILL.md (the orchestration engine). Hard to reverse if conventions are wrong -- all future orchestrations will follow these patterns. High blast radius: every nefario session is affected. MUST gate per the classification matrix. Additionally, the conflict resolution (side-effect vs. file-reference) is a judgment call where the user may prefer the issue's literal wording.
- **Prompt**: |
    You are updating the nefario orchestration skill (`skills/nefario/SKILL.md`)
    to persist agent input prompts as scratch files before invocation.

    ## Task

    Add side-effect prompt writing to the nefario orchestration workflow.
    Before each agent invocation across all phases, the orchestrator writes the
    constructed prompt to a named scratch file. Agents continue receiving their
    prompts inline (the delivery mechanism is unchanged). The scratch file is a
    durable artifact for transparency and context preservation.

    ## Design Decisions (already resolved -- implement these, do not re-litigate)

    1. **Side-effect model**: Write prompts to scratch as a side effect. Do NOT
       change how agents receive instructions. Agents still get their full prompt
       inline via the Task tool. The scratch file is a persistence artifact, not
       a delivery mechanism.

    2. **Naming convention**: `-prompt` suffix on existing base names.
       `phase2-{agent}-prompt.md` pairs with `phase2-{agent}.md`. The suffix
       keeps input and output files adjacent when sorted alphabetically.

    3. **All phases get prompt files**: Every phase that invokes an agent writes
       a prompt file. This includes Phases 1, 2, 3, 3.5, 4, 5, and 8 (when
       agents are spawned). No selective persistence -- consistency matters more
       than saving a few Write calls.

    4. **Advisory format**: Add an optional `Prompt:` field to complex advisories
       (those that already have a `Details:` line). Do NOT add it to simple
       two-line advisories.

    ## Working Directory

    /Users/ben/github/benpeter/2despicable/2

    ## Files to Modify

    1. **`skills/nefario/SKILL.md`** -- the only file. All changes are in this file.

    ## Specific Changes Required

    Read `skills/nefario/SKILL.md` carefully before making changes. Then apply
    these modifications:

    ### Change 1: Update Scratch Directory Structure (around line 224)

    Update the scratch directory tree listing to include `-prompt.md` files
    alongside existing output files. The new structure should show:

    ```
    $SCRATCH_DIR/{slug}/
      prompt.md                           # original user prompt (existing)
      phase1-metaplan-prompt.md           # NEW: input prompt for Phase 1
      phase1-metaplan.md                  # output from Phase 1 (existing)
      phase2-{agent}-prompt.md            # NEW: input prompt for each specialist
      phase2-{agent}.md                   # output from each specialist (existing)
      phase3-synthesis-prompt.md          # NEW: input prompt for synthesis
      phase3-synthesis.md                 # output from synthesis (existing)
      phase3.5-{agent}-prompt.md          # NEW: input prompt for each reviewer
      phase3.5-{agent}.md                 # output from reviewers (existing, BLOCK/ADVISE only)
      phase4-{agent}-prompt.md            # NEW: input prompt for execution agents
      phase5-{agent}-prompt.md            # NEW: input prompt for code reviewers
      phase5-{agent}.md                   # output from code reviewers (existing, BLOCK/ADVISE only)
      phase6-test-results.md             # (existing)
      phase7-deployment.md               # (existing, conditional)
      phase8-checklist.md                # (existing)
      phase8-{agent}-prompt.md           # NEW: input prompt for doc agents
      phase8-software-docs.md            # (existing, conditional)
      phase8-user-docs.md                # (existing, conditional)
      phase8-marketing-review.md         # (existing, conditional)
    ```

    Add a brief note after the tree explaining the naming convention:
    "Files ending in `-prompt.md` are agent input prompts (what the agent was told).
    Files without the suffix are agent outputs (what the agent produced). Every
    agent invocation writes a `-prompt.md` file; not every invocation produces an
    output file (e.g., Phase 3.5 APPROVE verdicts)."

    ### Change 2: Add prompt persistence instruction to Phase 1 (around line 309)

    In the Phase 1 section, BEFORE the `Task:` block that spawns nefario, add
    an instruction to write the prompt to scratch:

    "**Before spawning nefario**: Write the constructed prompt (the full content
    of the `prompt:` field below) to `$SCRATCH_DIR/{slug}/phase1-metaplan-prompt.md`.
    Then spawn nefario with the same prompt inline."

    The key point: write first, then pass inline. The agent still receives the
    full prompt via the Task tool's `prompt:` parameter. The file is a side effect.

    ### Change 3: Add prompt persistence instruction to Phase 2 (around line 366)

    In the Phase 2 section, BEFORE the `Task:` block, add a similar instruction:

    "**Before spawning each specialist**: Write the constructed prompt (with all
    template variables resolved -- the actual task description, the actual planning
    question, the actual context) to `$SCRATCH_DIR/{slug}/phase2-{agent}-prompt.md`.
    Then spawn the specialist with the same prompt inline."

    ### Change 4: Add prompt persistence instruction to Phase 3 (around line 424)

    Same pattern for synthesis:

    "**Before spawning nefario for synthesis**: Write the constructed prompt to
    `$SCRATCH_DIR/{slug}/phase3-synthesis-prompt.md`. Then spawn nefario with
    the same prompt inline."

    ### Change 5: Add prompt persistence instruction to Phase 3.5 (around line 516)

    Same pattern for reviewers:

    "**Before spawning each reviewer**: Write the constructed prompt to
    `$SCRATCH_DIR/{slug}/phase3.5-{agent}-prompt.md`. Then spawn the reviewer
    with the same prompt inline."

    ### Change 6: Add prompt persistence instruction to Phase 4 (around line 800)

    In the execution loop, step 3 (Spawn teammates), add:

    "**Before spawning each execution agent**: Write the constructed prompt to
    `$SCRATCH_DIR/{slug}/phase4-{agent}-prompt.md`. Then spawn the agent with
    the same prompt inline."

    ### Change 7: Add prompt persistence instruction to Phase 5 (around line 998)

    Same pattern for code reviewers:

    "**Before spawning each code reviewer**: Write the constructed prompt to
    `$SCRATCH_DIR/{slug}/phase5-{agent}-prompt.md`. Then spawn the reviewer
    with the same prompt inline."

    ### Change 8: Add prompt persistence instruction to Phase 8 (around line 1142)

    For sub-step 8a (parallel doc agents):

    "**Before spawning each documentation agent**: Write the constructed prompt to
    `$SCRATCH_DIR/{slug}/phase8-{agent}-prompt.md`. Then spawn the agent with
    the same prompt inline."

    For sub-step 8b (product-marketing-minion):

    Same pattern: write to `$SCRATCH_DIR/{slug}/phase8-product-marketing-minion-prompt.md`.

    ### Change 9: Update advisory format (around line 675)

    In the ADVISORIES format section, add the optional `Prompt:` field for
    complex advisories. The current format for complex advisories is:

    ```
    ADVISORIES:
      [<domain>] Task N: <task title>
        CHANGE: ...
        WHY: ...
        Details: $SCRATCH_DIR/{slug}/phase3.5-{reviewer}.md
    ```

    Add an optional `Prompt:` line AFTER `Details:`:

    ```
    ADVISORIES:
      [<domain>] Task N: <task title>
        CHANGE: ...
        WHY: ...
        Details: $SCRATCH_DIR/{slug}/phase3.5-{reviewer}.md
        Prompt: $SCRATCH_DIR/{slug}/phase3.5-{reviewer}-prompt.md
    ```

    Add a note: "Include the `Prompt:` reference only when the advisory already
    includes a `Details:` line. For simple two-line advisories (CHANGE + WHY),
    the prompt reference adds noise without value."

    ### Change 10: Update TEMPLATE.md Working Files section

    Read `docs/history/nefario-reports/TEMPLATE.md`. In the Working Files section
    of the skeleton (around line 184), add prompt file entries alongside existing
    output file entries. Group them clearly:

    ```
    Companion directory: [{YYYY-MM-DD}-{HHMMSS}-{slug}/](./{YYYY-MM-DD}-{HHMMSS}-{slug}/)

    **Outputs**
    - [Phase 1: Meta-plan](./companion-dir/phase1-metaplan.md)
    - [Phase 2: {agent-name}](./companion-dir/phase2-{agent-name}.md)
    - [Phase 3: Synthesis](./companion-dir/phase3-synthesis.md)
    - [Phase 3.5: {agent-name}](./companion-dir/phase3.5-{agent-name}.md)

    **Prompts**
    - [Phase 1: Meta-plan prompt](./companion-dir/phase1-metaplan-prompt.md)
    - [Phase 2: {agent-name} prompt](./companion-dir/phase2-{agent-name}-prompt.md)
    - [Phase 3: Synthesis prompt](./companion-dir/phase3-synthesis-prompt.md)
    - [Phase 3.5: {agent-name} prompt](./companion-dir/phase3.5-{agent-name}-prompt.md)

    - [Original Prompt](./companion-dir/prompt.md)
    ```

    Also update the Working Files notes in the Template Notes section (around
    line 263) to document the prompt file label convention: files ending in
    `-prompt.md` get " prompt" appended to their label (e.g., "Phase 2: devx-minion prompt").

    ## Boundaries

    - Do NOT change how agents receive their prompts (no file-reference delivery)
    - Do NOT change agent system prompts (AGENT.md files)
    - Do NOT change META-PLAN or SYNTHESIS content format
    - Do NOT change scratch directory cleanup/retention policy
    - Do NOT change the Inline Summary Template format
    - Do NOT add any new dependencies or tools
    - Do NOT modify `the-plan.md`
    - Keep changes minimal and precise. The instruction to write a prompt file
      before each agent invocation should be 2-3 lines max per phase.

    ## Success Criteria

    1. Every phase that spawns an agent has a "write prompt to scratch" instruction
       BEFORE the Task: block
    2. The scratch directory structure listing includes all `-prompt.md` files
    3. The advisory format includes the optional `Prompt:` field
    4. TEMPLATE.md Working Files section shows prompt files grouped separately
    5. No changes to agent delivery mechanism (prompts still passed inline)
    6. No changes to any other file besides SKILL.md and TEMPLATE.md

    When you finish your task, mark it completed with TaskUpdate and
    send a message to the team lead with:
    - File paths with change scope and line counts (e.g., "skills/nefario/SKILL.md (added prompt persistence instructions, +N lines)")
    - 1-2 sentence summary of what was produced
    This information populates the gate's DELIVERABLE section.
- **Deliverables**:
    - Updated `skills/nefario/SKILL.md` with prompt persistence instructions at every agent invocation point, updated scratch directory structure, updated advisory format
    - Updated `docs/history/nefario-reports/TEMPLATE.md` with prompt files in Working Files section
- **Success criteria**:
    - Every phase that spawns agents has a "write prompt to scratch" instruction before the Task: block
    - Scratch directory structure listing includes all `-prompt.md` files
    - Advisory format includes optional `Prompt:` field for complex advisories
    - TEMPLATE.md shows prompt files in Working Files
    - Zero changes to agent delivery mechanism

---

### Cross-Cutting Coverage

| Dimension | Coverage | Justification |
|-----------|----------|---------------|
| Testing | Not included | No executable code produced. Changes are to a markdown skill file (SKILL.md) and a report template (TEMPLATE.md). No runtime behavior to test. The change will be validated by the next orchestration session that uses it. |
| Security | Not included | No new attack surface. Prompt files are written to a chmod-700 temp directory (existing security model). No auth changes, no user input processing, no new dependencies. |
| Usability -- Strategy | Evaluated during planning (ux-strategy-minion was a Phase 2 consultant). Key finding: side-effect model reduces cognitive load vs. file-reference delivery. Adopted. |
| Usability -- Design | Not included | No user-facing interfaces produced. The change is internal to the orchestration skill. |
| Documentation | Included in Task 1 (TEMPLATE.md update). The documentation artifact itself is being modified as part of the primary task. |
| Observability | Not included | No runtime components. The scratch files themselves are the observability artifact for orchestration tracing. |

### Architecture Review Agents

- **Always**: security-minion, test-minion, ux-strategy-minion, software-docs-minion, lucy, margo
- **Conditional**: none triggered (no runtime components, no user-facing UI, no web-facing output)

### Conflict Resolutions

**File-reference delivery vs. side-effect writing**: Resolved in favor of side-effect writing (ux-strategy-minion's approach). devx-minion's file-reference delivery mechanism achieves the same goals but with higher complexity (new protocol, new failure modes, latency overhead). The project's KISS/YAGNI philosophy and the goal decomposition analysis support the simpler approach. devx-minion's naming convention and directory structure contributions are adopted in full.

**Selective vs. complete persistence**: ux-strategy-minion recommended persisting only session-specific prompts (Phases 1-3). Resolved in favor of complete persistence (all phases). Consistency outweighs the marginal cost of writing a few additional short prompts. Users browsing the companion directory should find a complete audit trail, not a partial one with implicit rules about which phases were "worth" persisting.

**Literal issue text vs. engineering philosophy**: The issue's success criteria include "Agents read their prompt from the file rather than receiving it entirely inline." The side-effect approach does not literally satisfy this criterion. This is flagged at the approval gate for the user to decide. If the user insists on file-reference delivery, the plan can be revised with devx-minion's hybrid approach (3-line inline preamble + file read).

### Risks and Mitigations

1. **Scratch file proliferation** (from devx-minion): Adding `-prompt.md` files roughly doubles the file count in companion directories. Mitigation: group prompt files separately in TEMPLATE.md Working Files section (Outputs vs. Prompts grouping).

2. **Issue text mismatch** (synthesis-identified): The side-effect approach does not literally match the issue's success criterion about agents reading from files. Mitigation: flag at approval gate. The user decides whether the literal criterion matters or the underlying goals (transparency, persistence) are sufficient.

3. **Single-file contention** (from devx-minion): All changes target SKILL.md. Mitigation: single task with single agent. No contention possible.

### Execution Order

```
Batch 1: Task 1 (devx-minion updates SKILL.md + TEMPLATE.md)
  GATE: Approval required (convention + conflict resolution decision)
```

Single-batch execution. One task, one gate.

### Verification Steps

1. After Task 1 completes, verify that `skills/nefario/SKILL.md` contains a "write prompt to scratch" instruction before every `Task:` block that spawns an agent
2. Verify the scratch directory structure listing includes all `-prompt.md` files
3. Verify the advisory format includes the optional `Prompt:` field
4. Verify `docs/history/nefario-reports/TEMPLATE.md` Working Files section includes prompt file entries
5. Verify no changes to agent delivery mechanism (search for "Read your" or "read from" patterns that would indicate file-reference delivery)
6. Run the next nefario orchestration session and confirm prompt files appear in the scratch directory
