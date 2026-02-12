## Domain Plan Contribution: devx-minion

### Recommendations

#### 1. Naming Convention: `-prompt` Suffix on Existing Base Names

Use the `-prompt` suffix on the existing base name convention. This is the simplest
scheme that achieves clear input/output pairing without introducing a subdirectory
or a new naming axis.

**Current output files** (unchanged):
```
phase1-metaplan.md
phase2-{agent}.md
phase3-synthesis.md
phase3.5-{agent}.md
phase4-{agent}.md          (new -- see note below)
phase5-{agent}.md
```

**New input prompt files**:
```
phase1-metaplan-prompt.md
phase2-{agent}-prompt.md
phase3-synthesis-prompt.md
phase3.5-{agent}-prompt.md
phase4-{agent}-prompt.md
phase5-{agent}-prompt.md
```

**Why `-prompt` suffix instead of a subdirectory:**
- A `prompts/` subdirectory breaks the chronological scan pattern. When debugging
  an orchestration, you `ls` the scratch dir and see everything in phase order.
  A subdirectory hides half the story behind an extra `cd`.
- The `-prompt` suffix keeps input and output files adjacent when sorted
  alphabetically: `phase2-devx-minion-prompt.md` appears directly before
  `phase2-devx-minion.md`. This is the natural reading order (input, then output).
- The suffix is grep-friendly: `ls *-prompt.md` lists all inputs;
  `ls *.md | grep -v prompt` lists all outputs. No subdirectory traversal needed.

**Why NOT a `-input`/`-output` pair:**
- Adding `-output` to every existing file is a breaking change to the companion
  directory convention. Existing reports link to `phase2-{agent}.md` in their
  Working Files section. Renaming these would orphan all existing companion
  directory links.
- The output files are already established. Adding the new `-prompt` suffix for
  inputs is strictly additive.

**Note on Phase 4 output files**: The current scratch convention does not define
output files for Phase 4 execution agents (the plan's `phase4-{agent}.md`).
This is a gap worth considering during synthesis, but it is not strictly required
for the prompt-to-scratch change. If Phase 4 agents do not write output to
scratch, then `phase4-{agent}-prompt.md` stands alone without a paired output.
This is fine -- the prompt file still serves both transparency and context
preservation goals.

#### 2. Minimal File-Reference Prompt: Hybrid Approach

The prompt delivered to an agent should be a short inline preamble plus a file
reference. Not a pure file reference, and not the full prompt. The preamble
provides enough context for the agent to understand its role without reading
the file first, while the file reference is the canonical source of detailed
instructions.

**Recommended template for the inline prompt:**
```
You are {role-statement}.

Read your full instructions from: {file-path}

After completing your work, write your output to: {output-file-path}
```

**Why include a role statement inline:**
- The agent's system prompt (AGENT.md) already defines its general identity, but
  each invocation has a specific role within the orchestration (e.g., "contributing
  to the PLANNING phase" vs. "reviewing code produced during execution"). This
  one-sentence framing reduces the agent's orientation time.
- If the file read fails (disk error, path typo), the agent at least knows what
  it was supposed to do and can report the failure meaningfully instead of
  producing a generic "I don't have instructions" response.

**Why NOT include more inline context (task summary, planning question):**
- Duplicating content between the inline prompt and the file creates a maintenance
  hazard. If the orchestrator updates one and not the other, the agent receives
  conflicting instructions.
- The purpose of writing to file first is that the file IS the canonical prompt.
  The inline portion is a bootstrap pointer, not a fallback copy.

**Why NOT a pure file reference (just "Read: {path}"):**
- An agent receiving only a file path has zero context if the read fails.
- Some agent frameworks may not prioritize file reads at the start of execution.
  The role statement ensures the agent is primed for its task before it reads.

**Concrete examples per phase:**

Phase 1 (nefario meta-plan):
```
MODE: META-PLAN

You are creating a meta-plan for this orchestration.

Read your full instructions from: $SCRATCH_DIR/{slug}/phase1-metaplan-prompt.md

Write your meta-plan to: $SCRATCH_DIR/{slug}/phase1-metaplan.md
```

Phase 2 (specialist planning):
```
You are contributing to the PLANNING phase of a multi-agent project.

Read your full instructions from: $SCRATCH_DIR/{slug}/phase2-{your-name}-prompt.md

Write your contribution to: $SCRATCH_DIR/{slug}/phase2-{your-name}.md
```

Phase 3.5 (reviewer):
```
You are reviewing a delegation plan before execution begins.

Read your full instructions from: $SCRATCH_DIR/{slug}/phase3.5-{your-name}-prompt.md

Write your verdict to: $SCRATCH_DIR/{slug}/phase3.5-{your-name}.md
```

Phase 5 (code reviewer):
```
You are reviewing code produced during an orchestrated execution.

Read your full instructions from: $SCRATCH_DIR/{slug}/phase5-{your-name}-prompt.md

Write your findings to: $SCRATCH_DIR/{slug}/phase5-{your-name}.md
```

#### 3. Input/Output Pairing Scheme

The pairing is implicit through the base name convention:

| Input (prompt) | Output (result) |
|---|---|
| `phase2-devx-minion-prompt.md` | `phase2-devx-minion.md` |
| `phase3.5-security-minion-prompt.md` | `phase3.5-security-minion.md` |
| `phase5-lucy-prompt.md` | `phase5-lucy.md` |

**Rules:**
1. Every `-prompt.md` file has at most one corresponding output file (same base
   name without `-prompt`).
2. Not every prompt file requires a corresponding output file. Phase 3.5 APPROVE
   verdicts currently do not generate scratch files; their prompt files would
   exist without an output counterpart. This is acceptable -- the prompt file
   documents that the agent was invoked even when it produced no notable output.
3. Every output file should have a corresponding prompt file. This is the new
   invariant that this change introduces.

**No explicit manifest needed.** The pairing is discoverable by filename.
A manifest (e.g., a JSON file mapping inputs to outputs) would be over-engineering
for a convention that is already self-documenting through naming. The Working Files
section in the report template already enumerates the companion directory contents.

#### 4. Advisory Format Changes

Currently, advisories reference output files:
```
ADVISORIES:
  [security] Task 3: Implement auth flow
    CHANGE: Added input validation on redirect_uri
    WHY: Open redirect vulnerability
```

And for complex advisories:
```
    Details: $SCRATCH_DIR/{slug}/phase3.5-security-minion.md
```

**Recommended addition**: Add a `PROMPT:` field when the advisory references
a details file. This creates a two-link trace: the advisory text tells you
what changed and why; the details file gives the full review; the prompt file
shows exactly what the reviewer was asked.

```
ADVISORIES:
  [security] Task 3: Implement auth flow
    CHANGE: Added input validation on redirect_uri
    WHY: Open redirect vulnerability
    Details: $SCRATCH_DIR/{slug}/phase3.5-security-minion.md
    Prompt: $SCRATCH_DIR/{slug}/phase3.5-security-minion-prompt.md
```

**When to include the PROMPT reference:**
- Only when the advisory already includes a `Details:` line (complex advisories
  exceeding 3 lines).
- Do NOT add PROMPT to every advisory. For simple two-line advisories (CHANGE +
  WHY), the prompt reference adds noise without value -- the advisory is
  self-contained.

**Why this is sufficient for transparency:**
- The companion directory (copied at wrap-up) preserves all prompt files alongside
  output files. Users inspecting a past orchestration can always find the prompt
  files by convention, even without an explicit reference in the advisory.
- The explicit PROMPT reference in complex advisories is a convenience shortcut
  for the most common trace scenario: "why did the reviewer say this?"

#### 5. Scratch Directory Structure Update

The updated convention becomes:

```
$SCRATCH_DIR/{slug}/
  prompt.md                           # original user prompt (existing)
  phase1-metaplan-prompt.md           # NEW: input to Phase 1 nefario
  phase1-metaplan.md                  # output from Phase 1 nefario (existing)
  phase2-{agent}-prompt.md            # NEW: input to each specialist
  phase2-{agent}.md                   # output from each specialist (existing)
  phase3-synthesis-prompt.md          # NEW: input to Phase 3 nefario
  phase3-synthesis.md                 # output from Phase 3 nefario (existing)
  phase3.5-{agent}-prompt.md          # NEW: input to each reviewer
  phase3.5-{agent}.md                 # output from each reviewer (existing, BLOCK/ADVISE only)
  phase4-{agent}-prompt.md            # NEW: input to each execution agent
  phase5-{agent}-prompt.md            # NEW: input to each code reviewer
  phase5-{agent}.md                   # output from each code reviewer (existing)
  phase6-test-results.md              # (existing)
  phase7-deployment.md                # (existing, conditional)
  phase8-checklist.md                 # (existing)
  phase8-software-docs.md             # (existing, conditional)
  phase8-user-docs.md                 # (existing, conditional)
  phase8-marketing-review.md          # (existing, conditional)
```

#### 6. Write-Then-Reference Workflow Pattern

The orchestrator's workflow for each agent invocation changes from:

**Current (inline)**:
1. Construct prompt in memory
2. Pass prompt inline to Task tool
3. Agent executes
4. Write output to scratch file

**Proposed (write-then-reference)**:
1. Construct prompt in memory
2. Write prompt to scratch file (`{phase}-{agent}-prompt.md`)
3. Pass short file-reference prompt to Task tool
4. Agent reads full prompt from file
5. Agent writes output to scratch file

This adds one Write tool call per agent invocation. For a typical orchestration
with ~10-12 agent invocations across all phases, this adds ~10-12 file writes.
The overhead is negligible (each write is <1KB) and the benefit is substantial:
every prompt is now a durable, traceable artifact.

### Proposed Tasks

#### Task 1: Update SKILL.md Scratch Directory Convention

**What**: Update the "Scratch Directory Structure" section (around line 224) to
document the new `-prompt.md` file naming convention.

**Deliverables**: Updated scratch directory tree in SKILL.md showing all new
`-prompt.md` files alongside existing output files.

**Dependencies**: None (this is documentation of the convention that subsequent
tasks implement).

#### Task 2: Update Phase 1 Invocation Pattern

**What**: Modify the Phase 1 section to: (a) write the meta-plan prompt to
`phase1-metaplan-prompt.md` before spawning nefario, (b) change the Task tool
prompt to the short file-reference format.

**Deliverables**: Updated Phase 1 section in SKILL.md.

**Dependencies**: Task 1 (convention must be defined first).

#### Task 3: Update Phase 2 Invocation Pattern

**What**: Modify the Phase 2 section to: (a) write each specialist's prompt to
`phase2-{agent}-prompt.md` before spawning, (b) change the Task tool prompt to
the short file-reference format.

**Deliverables**: Updated Phase 2 section in SKILL.md.

**Dependencies**: Task 1.

#### Task 4: Update Phase 3, 3.5, 4, and 5 Invocation Patterns

**What**: Apply the same write-then-reference pattern to remaining phases.
These can be done in a single task because the pattern is identical -- only the
phase number, agent name, and role statement vary.

**Deliverables**: Updated Phase 3, 3.5, 4, and 5 sections in SKILL.md.

**Dependencies**: Task 1.

#### Task 5: Update Advisory Format and Working Files Template

**What**: (a) Add the optional `Prompt:` field to the advisory format spec.
(b) Update the Working Files section in the report template (TEMPLATE.md) to
reflect that companion directories now contain `-prompt.md` files.
(c) Update the inline summary template to note the existence of the prompt file.

**Deliverables**: Updated advisory format in SKILL.md, updated TEMPLATE.md.

**Dependencies**: Tasks 2-4 (the prompt file paths referenced in advisories must
be established first).

**Note**: Tasks 2, 3, and 4 are independent of each other and can run in parallel.
Task 5 depends on all of them completing. All tasks modify the same file
(SKILL.md), so the synthesis should assign them to a single agent or serialize
them to avoid merge conflicts.

### Risks and Concerns

1. **Single-file contention**: All tasks modify `skills/nefario/SKILL.md`. If
   assigned to separate parallel agents, they will produce conflicting edits.
   Mitigation: assign all tasks to a single agent, or serialize tasks 2-4
   (they are logically independent but physically contending).

2. **Agent file-read failure**: If an agent fails to read its prompt file (path
   typo, permission issue), it receives only the short bootstrap prompt and
   cannot execute its task. Mitigation: the role statement in the bootstrap
   prompt provides enough context for the agent to report the failure
   specifically ("I could not read my instructions from {path}") rather than
   producing garbage. The orchestrator should treat a missing output file
   (agent did not write to its expected output path) as a signal that the
   invocation failed.

3. **Prompt file bloat in companion directories**: A typical orchestration now
   produces ~10-12 additional files (one per agent invocation). This roughly
   doubles the file count in companion directories. Impact: the Working Files
   section becomes longer. Mitigation: group prompt files separately in the
   Working Files listing (e.g., a "Prompts" subsection within the collapsible
   details).

4. **Context window cost of file reads**: Each agent now performs one additional
   file read at the start of its execution. For Phase 3.5 reviewers with short
   prompts (~15 lines), the file read overhead (tool call + response) may exceed
   the inline prompt token count. This is a real but small cost, and the
   traceability benefit outweighs it.

### Additional Agents Needed

None. The meta-plan correctly identifies devx-minion for convention design and
ux-strategy-minion for simplicity audit. The implementation is a single-file
edit (SKILL.md + TEMPLATE.md), so no additional coding specialists are needed
for planning.
