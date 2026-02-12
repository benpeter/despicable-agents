VERDICT: APPROVE

FINDINGS:

## Summary

All requirements met. The implementation correctly adds prompt persistence at every agent invocation point, updates the scratch directory structure documentation, and maintains consistent naming conventions throughout.

## Detailed Verification

### 1. Prompt Write Instructions Before Agent Spawning

**VERIFIED**: Every phase that spawns agents now has explicit instructions to write the prompt to scratch BEFORE spawning.

- **Phase 1 (line 298-302)**: "Write the constructed prompt... to `$SCRATCH_DIR/{slug}/phase1-metaplan-prompt.md` before spawning. Sanitize the prompt content... Then spawn nefario with the same prompt inline."
- **Phase 2 (line 385-388)**: "**Before spawning each specialist**: Write the constructed prompt... to `$SCRATCH_DIR/{slug}/phase2-{agent-name}-prompt.md`. Apply secret sanitization before writing. Then spawn the specialist with the same prompt inline."
- **Phase 3 (line 449-451)**: "**Before spawning nefario for synthesis**: Write the constructed prompt to `$SCRATCH_DIR/{slug}/phase3-synthesis-prompt.md`. Apply secret sanitization before writing. Then spawn nefario with the same prompt inline."
- **Phase 3.5 (line 545-548)**: "**Before spawning each reviewer**: Write the constructed prompt to `$SCRATCH_DIR/{slug}/phase3.5-{reviewer-name}-prompt.md`. Apply secret sanitization before writing. Then spawn the reviewer with the same prompt inline."
- **Phase 4 (line 841-843)**: "**Before spawning each execution agent**: Write the constructed prompt to `$SCRATCH_DIR/{slug}/phase4-{agent-name}-prompt.md`. Apply secret sanitization before writing. Then spawn the agent with the same prompt inline."
- **Phase 5 (line 1042-1044)**: "**Before spawning each code reviewer**: Write the constructed prompt to `$SCRATCH_DIR/{slug}/phase5-{agent-name}-prompt.md`. Apply secret sanitization before writing. Then spawn the reviewer with the same prompt inline."
- **Phase 8 (line 1193-1195, 1201-1203)**: Two separate instructions for doc agents and product-marketing-minion, both following the same pattern.

### 2. Scratch Directory Structure

**VERIFIED**: Lines 223-249 document the complete structure including all `-prompt.md` files.

```
phase1-metaplan-prompt.md           # input prompt for Phase 1
phase2-{agent-name}-prompt.md       # input prompt for each specialist
phase3-synthesis-prompt.md          # input prompt for synthesis
phase3.5-{reviewer-name}-prompt.md  # input prompt for each reviewer
phase4-{agent-name}-prompt.md       # input prompt for execution agents
phase5-code-review-minion-prompt.md # input prompt for code reviewers
phase5-lucy-prompt.md
phase5-margo-prompt.md
phase8-{agent-name}-prompt.md       # input prompt for doc agents
```

Lines 251-254 explain: "Files ending in `-prompt.md` are agent input prompts written before invocation. Files without the suffix are agent outputs. Every agent invocation writes a `-prompt.md` file; not every invocation produces an output file..."

### 3. Advisory Format with Optional Prompt Field

**VERIFIED**: Lines 718-727 define the advisory format including the optional `Prompt:` field:

```
Details: $SCRATCH_DIR/{slug}/phase3.5-{reviewer}.md
Prompt: $SCRATCH_DIR/{slug}/phase3.5-{reviewer}-prompt.md
```

With clear guidance: "Include the `Prompt:` reference only when the advisory already includes a `Details:` line. For simple two-line advisories (CHANGE + WHY), omit the prompt reference."

### 4. TEMPLATE.md Prompt Files Under **Prompts** Header

**VERIFIED**: Lines 195-201 in TEMPLATE.md show prompt files grouped under a **Prompts** heading:

```markdown
**Prompts**
- [Phase 1: Meta-plan prompt](./companion-dir/phase1-metaplan-prompt.md)
- [Phase 2: {agent-name} prompt](./companion-dir/phase2-{agent-name}-prompt.md)
- [Phase 3: Synthesis prompt](./companion-dir/phase3-synthesis-prompt.md)
- [Phase 3.5: {agent-name} prompt](./companion-dir/phase3.5-{reviewer-name}-prompt.md)

- [Original Prompt](./companion-dir/prompt.md)
```

### 5. Secret Sanitization at Every Prompt Write

**VERIFIED**: Every prompt-write instruction includes sanitization:

- Phase 1 (line 299): "Sanitize the prompt content: remove patterns matching `sk-`, `key-`, `AKIA`, `ghp_`, `github_pat_`, `token:`, `bearer`, `password:`, `passwd:`, `BEGIN.*PRIVATE KEY`."
- Phases 2, 3, 3.5, 4, 5, 8 all include: "Apply secret sanitization before writing."
- Phase 1 also sanitizes the original prompt (line 321-322) before writing to `prompt.md` (line 324).

### 6. No Changes to Agent Delivery Mechanism

**VERIFIED**: The implementation only adds file writes. The agent spawning mechanism remains unchanged. Every instruction follows the pattern:
1. Write prompt to scratch file (with sanitization)
2. Spawn agent with the same prompt inline (existing mechanism)

### 7. Naming Conventions Consistency

**VERIFIED**: All naming is consistent:

- File naming: `phase{N}-{agent-name}-prompt.md` or `phase{N}-{step}-prompt.md`
- Phase 5 exceptions correctly named: `phase5-code-review-minion-prompt.md`, `phase5-lucy-prompt.md`, `phase5-margo-prompt.md`
- Phase 8 follows pattern: `phase8-{agent-name}-prompt.md`, `phase8-product-marketing-minion-prompt.md`
- TEMPLATE.md label convention (line 276-280) matches the file naming
- Scratch directory structure matches actual write instructions

## Code Quality Observations

### NIT: Consistency in Instruction Formatting

Lines 386-388, 450-451, 546-548, 842-843, 1043-1044, 1194-1195, 1202-1203 all use the pattern:

```
**Before spawning [X]**: Write the constructed prompt...
Apply secret sanitization before writing.
Then spawn [X] with the same prompt inline.
```

Line 299-302 (Phase 1) has slightly different wording but equivalent semantics. This is acceptable given Phase 1 has unique context about the prompt construction.

### NIT: Template Checklist Alignment

TEMPLATE.md checklist (line 328-329) correctly reflects the prompt.md write:
```
4. Sanitize verbatim prompt (redact secrets/tokens/keys)
4a. Write sanitized prompt to scratch directory as prompt.md
```

This aligns with SKILL.md line 324: "Write the **already-sanitized** original prompt to `$SCRATCH_DIR/{slug}/prompt.md`"

## Cross-Agent Integration

No issues. The changes are self-contained within the nefario orchestration workflow. The scratch files are referenced correctly in:
- Advisory format (optional Prompt: field)
- Working Files section format (TEMPLATE.md)
- Fallback logic for compacted summaries (line 1407-1411)

## Correctness

All instructions are correct and implementable:
- File paths are properly templated
- Sanitization patterns are comprehensive
- Conditional logic for Prompt: field inclusion is clear
- No race conditions (write happens before spawn, synchronous)

## Final Assessment

The implementation is complete, correct, and consistent. Every requirement from the review focus is satisfied.
