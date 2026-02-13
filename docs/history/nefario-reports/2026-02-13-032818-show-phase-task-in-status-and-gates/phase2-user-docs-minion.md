# Domain Plan Contribution: user-docs-minion

## Recommendations

### 1. Status Line section needs targeted updates, not a rewrite

The Status Line section in `docs/using-nefario.md` (lines 166-217) needs three specific changes. The section structure is sound; only the content descriptions of *what* the status line shows and *how* the status file is written need updating.

**a) "What It Shows" subsection (lines 188-193):**
Currently says "the task summary" and shows this example:

```
~/my-project | Claude Opus 4 | Context: 12% | Build MCP server with OAuth...
```

This must change to show **phase + task**. The example should become something like:

```
~/my-project | Claude Opus 4 | Context: 12% | Phase 3: Build MCP server with OAuth...
```

The prose should say the status bar shows the current orchestration phase and task summary, and that it updates at each phase boundary. One sentence is enough: "When nefario is orchestrating, the status bar appends the current phase and task summary after the standard info."

**b) "How It Works" subsection (lines 195-197):**
Currently says nefario "writes a one-line task summary to `/tmp/nefario-status-<session-id>`." This should change to "writes the current phase and a one-line task summary" and note that the file is updated at each phase transition (not just written once at the start). This is a factual change reflecting the new behavior -- the mechanism (shell command reads file, appends contents) stays the same.

**c) Manual configuration example (lines 199-217):**
No changes needed. The shell command reads whatever is in the file and appends it. The command itself is unchanged. The SKILL.md for despicable-statusline also needs no changes -- it writes the nefario snippet, not the content. This is the correct answer to the planning question about the manual configuration: it remains as-is.

### 2. "What Happens" section needs a new note about gate context

The Phase descriptions in "What Happens: The Nine Phases" (lines 98-120) should be updated to mention that approval gates include phase context in their headers. This is best done as a single sentence added to the introductory paragraph (line 100) rather than modifying each phase description. Something like:

> Nefario follows a structured process: plan with specialists, review the plan, execute, then verify the results. Here is what you experience at each phase. The status line and all approval prompts include the current phase, so you always know where you are in the process.

This is a light touch -- one added sentence. The individual phase descriptions do not need per-phase edits because the gate header format is a SKILL.md concern, not a user guide concern. Users do not need to know the exact header format; they need to know they will always see their current phase.

### 3. Do NOT document the gate header format in the user guide

The specific gate `header` values (e.g., changing `"Gate"` to `"Phase 4 > Gate"`) are implementation details belonging in SKILL.md. The user guide should describe the *experience* ("you always know which phase you are in") not the *mechanism* ("the AskUserQuestion header field contains..."). This follows the principle of writing for the user's task, not the system's structure.

### 4. Despicable-statusline SKILL.md needs no changes

The statusline skill writes the *snippet that reads the file*. The snippet does not parse the file contents -- it does `cat "$f"` and appends whatever is there. Since the change is in what nefario writes *to* the file (adding phase prefix), the statusline mechanism is unaffected. The SKILL.md description line ("show nefario orchestration phase") already happens to be accurate for the new behavior. No update needed.

## Proposed Tasks

### Task 1: Update "What It Shows" in using-nefario.md

**What to do:** Replace the current description and example in the "What It Shows" subsection to reflect that the status line now shows phase + task summary. Update the example status bar output to include a phase prefix.

**Deliverables:** Updated `docs/using-nefario.md` lines 188-193.

**Dependencies:** Depends on the SKILL.md changes being finalized (so the description matches the implementation). Should be done after the nefario SKILL.md status-file-writing changes are committed, or in the same PR with awareness of the final format.

### Task 2: Update "How It Works" in using-nefario.md

**What to do:** Change the sentence about what nefario writes to the status file. Currently says "one-line task summary." Change to "the current phase and task summary" and note the file is updated at each phase boundary.

**Deliverables:** Updated `docs/using-nefario.md` lines 195-197.

**Dependencies:** Same as Task 1. Can be combined into a single edit pass.

### Task 3: Add phase awareness note to "What Happens" introduction

**What to do:** Add one sentence to the introductory paragraph of the "What Happens: The Nine Phases" section (line 100) noting that the status line and approval prompts always show the current phase for orientation.

**Deliverables:** Updated `docs/using-nefario.md` line 100.

**Dependencies:** None. This is a statement about user experience that does not depend on implementation details.

### Practical note: Tasks 1-3 are a single small edit

All three tasks touch the same file (`docs/using-nefario.md`) and amount to roughly 5 changed lines. They should be executed as a single task assigned to one agent to avoid merge conflicts and unnecessary coordination overhead.

## Risks and Concerns

### Risk 1: Status line example becomes stale if phase format changes

The example in "What It Shows" will show a specific format (e.g., `Phase 3: Build MCP server...`). If the phase prefix format changes later (e.g., `[P3]` or `Synthesis: Build MCP server...`), the example becomes misleading. **Mitigation:** Use a representative but not overly specific example. Consider wording like "the current phase and task summary" in prose, with the example as illustration rather than specification.

### Risk 2: Overly detailed documentation of gate headers

There is a temptation to document every gate header change (Team becomes "Phase 1 > Team", Plan becomes "Phase 3 > Plan", etc.). This would bloat the user guide with implementation details and create a maintenance burden. **Mitigation:** Document the *experience* ("gates always show which phase you are in"), not the implementation. Keep the SKILL.md as the single source of truth for gate header formats.

### Risk 3: Discrepancy between "What Happens" phase descriptions and actual gate behavior

The phase descriptions in lines 98-120 say things like "You see a brief status marker when this phase begins." If the gate headers now also carry phase context, a user might wonder about the relationship between the status marker (phase announcement banner) and the gate header (phase context in the prompt). **Mitigation:** The added sentence in the introduction handles this at the right level of abstraction. Do not try to explain the distinction between phase banners and gate headers in the user guide.

## Additional Agents Needed

None. The documentation changes are straightforward edits to a single file (`docs/using-nefario.md`). The despicable-statusline SKILL.md needs no changes. This is squarely within user-docs-minion scope. The nefario SKILL.md changes (the actual implementation of writing phase + task to the status file, and updating gate headers) are owned by whoever handles the orchestration logic -- that is already covered in the plan.
