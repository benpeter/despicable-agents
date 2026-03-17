MODE: SYNTHESIS

You are synthesizing specialist planning contributions into a
final execution plan.

## Original Task
Milestone 1: Adapter Foundation

**Goal**: Define the `DelegationRequest` and `DelegationResult` types that all adapters implement.

## Scope
- `DelegationRequest`: agent name, task prompt (already stripped of Claude Code-specific instructions), instruction file path, working directory, model tier (`opus` | `sonnet`), required tools list
- `DelegationResult`: exit code, changed files (from git diff), stdout summary, stderr, raw diff reference
- No implementation — types and contracts only
- Language/format matches the surrounding codebase (document the decision; do not assume)

## Acceptance Criteria
- Types are defined and documented
- Interface is minimal — covers Codex and Aider use cases, nothing more
- No harness-specific fields in the shared types

## Specialist Contributions

Read the following scratch files for full specialist contributions:
- /var/folders/3k/bfjvvz9s6dvdn_hvlhvr8lc00000gn/T//nefario-scratch-6xYwvg/adapter-interface-definition/phase2-api-design-minion.md
- /var/folders/3k/bfjvvz9s6dvdn_hvlhvr8lc00000gn/T//nefario-scratch-6xYwvg/adapter-interface-definition/phase2-devx-minion.md
- /var/folders/3k/bfjvvz9s6dvdn_hvlhvr8lc00000gn/T//nefario-scratch-6xYwvg/adapter-interface-definition/phase2-ai-modeling-minion.md
- /var/folders/3k/bfjvvz9s6dvdn_hvlhvr8lc00000gn/T//nefario-scratch-6xYwvg/adapter-interface-definition/phase2-ux-strategy-minion.md
- /var/folders/3k/bfjvvz9s6dvdn_hvlhvr8lc00000gn/T//nefario-scratch-6xYwvg/adapter-interface-definition/phase2-software-docs-minion.md

## Key consensus across specialists:

### api-design-minion
- Closed enum for model tier; FileChange with action metadata; separate exitCode (raw int) from status enum (completed/failed/timeout); add timeout and contextFiles fields
- Define types in a new Markdown design document using TS interface notation as spec language
- 3 tasks: define DelegationRequest, define DelegationResult with FileChange sub-type, document format decision

### devx-minion
- Pure Markdown with field tables + YAML examples (option a); consistent with existing codebase patterns
- Reject TS notation (explicitly excluded by YAGNI), JSON Schema (no consumer), shell conventions (insufficient)
- 1 task: create docs/adapter-interface.md following hub-and-spoke pattern

### ai-modeling-minion
- 8 result fields (5 load-bearing: exitCode, changedFiles, summary, rationale, adapterError; 3 operational: stderr, rawDiffPath, durationMs)
- Distinguish adapter crash vs task failure via boolean, not rich taxonomy
- Keep prompt pure (no phase/gate metadata), use requires_rationale boolean on request
- 2 tasks from orchestrator perspective

### ux-strategy-minion
- Rename 4 fields for clarity: instruction_file_path→translated_instruction_path, stdout_summary→task_summary, raw_diff_reference→specify representation, required_tools→required_agent_tools
- Add duration_ms and success boolean to result
- Request/Result boundary is intuitive
- 3 tasks: normalize names, inline docs, cold-read validation

### software-docs-minion
- Self-documenting type definition document (no separate adapter guide per YAGNI)
- Follow existing docs/agent-anatomy.md pattern; YAML pseudo-definitions + field tables + examples
- Capture behavioral contract alongside types (cleanup, error propagation)
- 3 tasks: write docs/adapter-interface.md, link from architecture hub, cross-reference roadmap

## Conflicts to Resolve
1. **Format**: api-design-minion recommends TS interface notation as spec language. devx-minion explicitly recommends against TS, favoring pure Markdown tables + YAML examples. The roadmap says "No TypeScript orchestrator." Resolution needed.
2. **Status representation**: api-design-minion proposes a `status` enum (completed/failed/timeout) alongside raw exitCode. ai-modeling-minion proposes an `adapter_error` boolean alongside exitCode. ux-strategy-minion proposes a `success` boolean. Resolution needed — pick one.
3. **Fields to add beyond roadmap**: api-design-minion wants timeout + contextFiles. ai-modeling-minion wants rationale + adapterError + durationMs + requires_rationale. ux-strategy-minion wants duration_ms + success. Some are consensus (duration_ms), some may violate YAGNI. Resolution needed.

## External Skills Context
No external skills detected relevant to this task.

## Instructions
1. Review all specialist contributions (read the scratch files)
2. Resolve the three conflicts above
3. Incorporate risks and concerns into the plan
4. Create the final execution plan in structured format
5. Ensure every task has a complete, self-contained prompt
6. Write your complete delegation plan to /var/folders/3k/bfjvvz9s6dvdn_hvlhvr8lc00000gn/T//nefario-scratch-6xYwvg/adapter-interface-definition/phase3-synthesis.md
