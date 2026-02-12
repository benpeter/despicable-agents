# Domain Plan Contribution: ux-strategy-minion

## Recommendations

### Answer to Question 1: Should short prompts remain inline?

**Yes, absolutely.** The indirection of write-file-then-reference adds three interaction steps (construct prompt, write to file, reference file path) to every agent invocation. For short prompts like Phase 3.5 reviewers (10-20 lines), this indirection costs more cognitive overhead to trace than it saves. The overhead-to-content ratio is inverted: the scaffolding to persist and reference a 15-line prompt is disproportionate to the prompt itself.

Apply progressive disclosure logic: the majority of prompts (Phase 3.5 reviewers, Phase 5 code reviewers) are short, templated, and structurally identical across sessions. They do not benefit from file-based persistence because they carry almost no session-specific information worth tracing. The session-specific content is the *output* (the verdict), which is already written to scratch files.

**Recommendation**: Only persist prompts to scratch when they contain substantial session-specific content -- specifically the Phase 2 specialist prompts and Phase 3 synthesis prompt, which embed the user's task description, nefario's planning questions, and cross-agent context. Phase 3.5 and Phase 5 reviewer prompts should remain inline.

**Threshold heuristic**: If more than half the prompt's content is templated (identical across sessions), keep it inline. If more than half is session-specific (task description, agent summaries, file lists), persist it.

### Answer to Question 2: Simpler transparency alternatives

**Yes, there is a simpler approach.** The two stated goals (transparency and context preservation) can be decomposed and solved independently, which is simpler than coupling them into a single file-reference mechanism.

**Transparency** (trace advisories back to exact prompts): The companion directory already copies scratch files to the report directory at wrap-up. Adding *input* prompts alongside *output* files in scratch achieves transparency as a side effect of the existing persistence mechanism. Users can trace post-hoc: "What prompt produced this phase2-margo.md output?" by looking at the corresponding input file. No change to how agents receive instructions is needed.

**Context preservation** (prompts survive compaction): The Inline Summary Template (lines 242-263 in SKILL.md) already solves this for agent outputs. Prompts themselves do not need to survive compaction in session context because they are not consumed again later. The session needs the *results* of phases (summaries, verdicts, task lists), not the prompts that produced them. If a prompt needs to be reconstructed after compaction (e.g., for a revision round), the scratch file provides recovery.

This decomposition means: write prompts to scratch as a side effect (goal 2 solved), keep them in companion directories at wrap-up (goal 1 solved), and do not change how agents receive instructions at all.

### Answer to Question 3: Side-effect writing without changing delivery

**Yes, and this is the recommended approach.** Write the constructed prompt to scratch *after* constructing it but *before* (or simultaneously with) passing it to the Task tool inline. This is a pure side effect -- the agent invocation is unchanged, but the prompt is now persisted.

The pattern:

1. Orchestrator constructs the prompt (current behavior, unchanged)
2. Orchestrator writes prompt to `$SCRATCH_DIR/{slug}/phase2-{agent}-prompt.md` (new side effect)
3. Orchestrator passes the prompt inline to the Task tool (current behavior, unchanged)
4. At wrap-up, the companion directory copy captures both input and output files

This achieves both goals with zero change to the agent delivery mechanism. Agents receive instructions exactly as they do today. The only new work is a Write call per agent invocation -- cheap, fast, and non-blocking.

### Cognitive Load Analysis

The proposed change (full file-reference delivery) introduces three cognitive load increases:

1. **For the orchestrator**: Must manage file creation timing, path references, and ensure agents can access files. This is new failure surface (what if the agent can't read the file? what if the path is wrong?).

2. **For agents**: Must perform an additional Read call before they can begin work. This adds latency and a potential failure point to every agent invocation. Agents currently receive everything they need in one shot -- the prompt parameter. Adding a "first, read your instructions from this file" step breaks the direct-delivery pattern.

3. **For the user tracing back**: The current companion directory structure shows outputs. Adding input prompts alongside outputs (with a clear naming convention like `*-prompt.md` vs `*.md`) is scannable. But if agents receive instructions by file reference, the user must follow a chain: report -> companion directory -> prompt file -> (where did that file reference end up?). Side-effect writing keeps the chain simple: report -> companion directory -> prompt file (this is what the agent was told).

### YAGNI/KISS Assessment

The project's own philosophy (CLAUDE.md lines 37-42) is explicit: YAGNI, KISS, Lean and Mean. The full file-reference delivery mechanism is over-engineering for a problem that has a simpler solution. The side-effect approach:

- **Zero new protocol**: Agents receive prompts exactly as before
- **Zero new failure modes**: File reference resolution, read failures, path mismatches -- none of these can occur
- **Minimal new code**: One Write call per agent invocation, using an already-established scratch directory
- **Leverages existing infrastructure**: Companion directory copy at wrap-up already handles persistence

## Proposed Tasks

### Task 1: Add input prompt persistence as side effect

**What**: Before each agent invocation in Phases 1-3 and 5, write the constructed prompt to a named scratch file. Use the naming convention `{phase}-{agent}-prompt.md` to distinguish input prompts from output files (which are `{phase}-{agent}.md`).

**Deliverables**:
- Updated SKILL.md with side-effect write instructions at each agent invocation point
- Updated scratch directory structure documentation to include `*-prompt.md` files

**Dependencies**: None

**Scope guidance**: Only persist prompts that contain session-specific content (Phase 1 metaplan prompt, Phase 2 specialist prompts, Phase 3 synthesis prompt). Phase 3.5 and Phase 5 reviewer prompts are templated and do not need persistence -- they add bulk without traceability value.

### Task 2: Update companion directory documentation

**What**: Document that companion directories now contain both input prompts and output files. Update the scratch directory structure listing in SKILL.md to show the new `*-prompt.md` files.

**Deliverables**:
- Updated scratch directory structure in SKILL.md
- Clear naming convention documented

**Dependencies**: Task 1

## Risks and Concerns

### Risk 1: Scope creep toward full file-reference delivery

The side-effect approach may be seen as an interim step toward eventually making agents read prompts from files. If the system works well with side-effect persistence (and it will), there is no reason to add the indirection layer later. The side-effect approach should be treated as the final solution, not a stepping stone.

### Risk 2: Scratch file proliferation

Adding `*-prompt.md` files roughly doubles the file count in the companion directory. For a typical orchestration with 5 Phase 2 agents + 6 Phase 3.5 reviewers + 3 Phase 5 reviewers + synthesis + metaplan, the scratch directory currently has ~15 files. Adding input prompts for the valuable subset (Phase 1-3) adds ~7 more. This is manageable. Adding prompts for all phases would add ~14, which starts to feel cluttered. The selective approach (only session-specific prompts) keeps this under control.

### Risk 3: Naming confusion between input and output files

Users browsing the companion directory need to quickly distinguish "what was the agent told" from "what did the agent produce." The `*-prompt.md` suffix convention handles this, but only if applied consistently. If some phases use the convention and others don't, it creates inconsistency. Document the rule clearly: files ending in `-prompt.md` are inputs; files without the suffix are outputs.

## Additional Agents Needed

**margo** -- should review the proposal to validate YAGNI alignment. The side-effect approach is the KISS-compliant path, but margo should confirm that even this minimal addition passes the "do we need it now?" test. The question for margo: Is the traceability problem (can't trace advisories back to prompts) actually causing pain today, or is this anticipatory?

**devx-minion** -- should evaluate the developer experience of browsing companion directories with the new file naming convention. The doubled file count and the input/output distinction need to be intuitive for someone scanning a directory listing for the first time.
