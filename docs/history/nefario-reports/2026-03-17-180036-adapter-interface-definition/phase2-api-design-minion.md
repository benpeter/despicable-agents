## Domain Plan Contribution: api-design-minion

### Recommendations

#### (a) Model tier: enum, not string

Model tier should be a closed enum (`opus | sonnet`), not a freeform string. Reasons:

1. **It expresses intent, not identity.** The orchestrator does not know or care about provider-specific model names (`o3`, `claude-opus-4-6`, `gemini-2.5-pro`). It knows "this task needs high-quality reasoning" or "this task is cost-efficient." That is a two-value signal, not an open set.
2. **The mapping belongs elsewhere.** The routing config already has a `model-mapping` section that translates tiers to provider-specific IDs per harness. Putting provider IDs in `DelegationRequest` would duplicate that mapping and couple the orchestrator to adapter internals.
3. **Extensibility is safe.** If a third tier is needed later (e.g., `fast` for a low-latency model tier), adding a third enum value is an additive, non-breaking change. No existing adapter breaks because the new value flows through the same mapping mechanism.

The mcp-minion's prior proposal included both `model` (provider-specific string) and `qualityTier` (enum). That is one field too many. The synthesis plan consolidated to `model` (provider-specific) + `qualityTier` (high/standard). I recommend simplifying further: **one field, `modelTier`, with values `opus | sonnet`**. The adapter resolves this to a provider-specific ID via routing config. The orchestrator never names a model.

Rationale for keeping `opus`/`sonnet` as the enum values rather than `high`/`standard`: the codebase already uses `opus` and `sonnet` as the tier vocabulary (every AGENT.md frontmatter uses `model: opus` or `model: sonnet`). Introducing synonyms (`high`/`standard`) adds a translation step and terminology drift for zero benefit. Use the existing vocabulary.

#### (b) Changed files: include action metadata, not just paths

A bare list of file paths is insufficient. The orchestrator needs to know whether files were added, modified, deleted, or renamed. Reasons:

1. **The data is free.** `git diff --name-status` provides the action alongside the path at no extra cost. There is no reason to discard it.
2. **The orchestrator uses it.** Nefario's execution reports include file counts by type. The review gate needs to know whether new files appeared (possible scope creep) or files were deleted (risk of breakage). A flat path list forces the orchestrator to re-run `git diff` to get this information, which is wasteful and introduces a TOCTOU gap.
3. **Lines added/removed are cheap context.** `git diff --numstat` provides lines added/removed per file. This is useful for summary generation and report formatting.

Recommended `FileChange` shape:

```
path:          string  (relative to workingDirectory)
action:        "added" | "modified" | "deleted" | "renamed"
linesAdded:    number
linesRemoved:  number
```

This matches the mcp-minion's prior proposal and the synthesis plan. It is the right level of detail: enough for orchestrator decisions, not so much that it becomes a parsed diff format.

**What to exclude:** Do not include diff hunks, file contents, or binary flags. The `rawDiffRef` field (a path to the full diff output) covers the debugging use case. The `FileChange` array is a summary, not a complete diff.

#### (c) Exit code: single integer, with a separate status field for classification

Exit codes should remain a raw integer (matching Unix process exit conventions). Layer classification on top with a separate `status` enum. Reasons:

1. **Exit codes are tool-specific.** Codex, Aider, and future tools use different non-zero codes for different failure modes. Normalizing them into the adapter interface would require maintaining a per-tool exit code mapping that may not be documented upstream.
2. **The orchestrator cares about three states.** From the orchestrator's perspective, a delegation either completed, failed, or timed out. That is the `status` field: `"completed" | "failed" | "timeout"`.
3. **The adapter is the right place to classify.** Each adapter knows its tool's exit code semantics. The adapter sets `status` based on exit code and other signals (stderr content, timeout trigger). The orchestrator reads `status` and ignores `exitCode` for routing decisions but preserves `exitCode` for debugging and reports.

This is the same design the synthesis plan landed on. I endorse it as-is.

**Future hardening (M8, not now):** A `retryable` boolean on the result could signal whether the orchestrator should re-attempt the delegation. This is explicitly out of scope for M1-M4 and should not be added preemptively.

#### (d) Missing fields for cross-tool support

The roadmap spec is close to complete. Three fields are missing or under-specified:

**1. `agentName` (request) -- present in roadmap, keep it.** The roadmap lists "agent name" in `DelegationRequest`. This is needed for routing config resolution (agent > group > default). It should be the agent's canonical name (matching the `name` field in AGENT.md frontmatter, e.g., `frontend-minion`).

**2. `timeout` (request) -- add with a sensible default.** The synthesis plan includes it. The roadmap's Issue 1.1 does not mention it explicitly, but Issues 2.1 and 3.2 both reference configurable timeouts. This belongs in the shared type, not as an adapter-specific concern. A default of 30 minutes (1,800,000 ms) is reasonable given that coding tasks typically run 2-10 minutes but complex refactors can take longer.

**3. `rawDiffRef` (result) -- keep as optional path.** The roadmap spec says "raw diff reference." This should be an optional file path to the full unified diff output, written by the adapter for debugging purposes. The orchestrator does not process it, but it is invaluable for debugging failed delegations and for the review gate. It is optional because cleanup may remove it.

**4. `autoApprove` (request) -- omit from the shared type.** The mcp-minion proposed this field. I recommend against including it. Every feasible-now tool runs in full-auto mode for headless delegation -- there is no scenario where the orchestrator spawns an external tool and expects interactive approval. Making it a field suggests a choice that does not exist. If a future tool requires interactive approval, it cannot be a delegation target at all (the orchestrator has no mechanism to respond). This field is always `true` and therefore carries no information.

**5. `contextFiles` (request) -- add as optional.** Some tools support `--read` flags for additional context files beyond the instruction file. This is useful for Aider (which has `--read` for reference files the model can see but not edit). Not all adapters will use it, but the shared type should include it as an optional list of paths so adapters that support it can consume it uniformly.

**6. `environment` (request) -- omit for now.** The mcp-minion proposed a `Record<string, string>` for subprocess environment variables. This is premature. The orchestrator does not currently pass environment variables to subagents. Adding it to the type invites security concerns (API keys in delegation requests) without a concrete use case. If needed for Gemini CLI auth in M5, add it then.

#### Language and format decision

The codebase is pure Markdown and shell. There is no TypeScript, Python, or other language runtime. The types should be defined as a **Markdown design document** using fenced code blocks for type definitions.

Use TypeScript-style `interface` syntax in the code blocks for type definitions. Rationale:
- TypeScript interface syntax is the most widely understood way to express typed record structures in the web/CLI tooling ecosystem
- The mcp-minion's prior proposal already used this syntax, establishing precedent
- It is unambiguous: required vs. optional fields, union types, nested structures
- It is not a commitment to TypeScript implementation -- it is a specification notation

The document should live at `docs/adapter-interface.md` (consistent with the existing docs directory structure) and be linked from `docs/architecture.md`.

#### Envelope consistency

Both types should follow a consistent pattern:

- **Request:** All fields that the orchestrator populates. No adapter-internal fields. No harness-specific fields.
- **Result:** All fields that the orchestrator reads. Adapter-internal diagnostics go in optional fields (`stdout`, `stderr`, `rawDiffRef`). No harness-specific fields.
- **No wrapper envelope.** The types are not JSON API responses; they are function call contracts. No `{ data, meta }` wrapping. No error envelope -- errors are expressed via the `status` field on `DelegationResult`.

#### Naming

Use the names from the roadmap: `DelegationRequest` and `DelegationResult`. These are clear, consistent with the existing documentation, and already referenced by six roadmap issues. Do not rename them.

Field naming: Use `camelCase` for field names (matching the TypeScript interface notation and the synthesis plan). This is a spec notation choice, not a runtime constraint.

### Proposed Tasks

**Task 1: Write `docs/adapter-interface.md`**

Define `DelegationRequest`, `DelegationResult`, and `FileChange` types in a Markdown design document with TypeScript-style interface notation. Include:

- Complete type definitions with field-level documentation
- Design rationale for each field (why included, why this shape)
- Explicit "not included" section documenting fields that were considered and rejected (with reasons)
- Lifecycle notes: pre-invocation git ref capture, instruction file write/cleanup, result collection sequence
- Security notes from the prior security review (workingDirectory must be absolute canonicalized path, instruction file cleanup on crash)
- Link from `docs/architecture.md` to the new document

Deliverables:
- `docs/adapter-interface.md` (new file)
- Updated `docs/architecture.md` (add link in sub-documents table)

Dependencies: None (this is the root of the dependency chain).

**Task 2: Review against downstream consumers**

After writing the interface document, verify that every downstream issue (1.2, 1.3, 2.1, 2.2, 3.1, 3.2, 3.3) can be satisfied by the defined types without modification. This is a desk check, not implementation.

Deliverables:
- A section in `docs/adapter-interface.md` titled "Downstream Consumer Compatibility" listing each issue and confirming coverage or noting gaps.

Dependencies: Task 1.

### Risks and Concerns

**1. Premature abstraction risk.** The YAGNI constraint in the roadmap says "Do not design the interface in isolation before two implementations exist." Issue 1.1 explicitly asks for types before any adapter code. This tension is acknowledged in the roadmap (Issue 3.4 explicitly checks interface health after two adapters). The mitigation is to keep the type surface minimal and expect changes after Milestone 3. The interface document should state this explicitly: "This interface is expected to evolve based on Codex (M2) and Aider (M3) validation."

**2. TypeScript notation in a non-TypeScript codebase.** Using TypeScript `interface` syntax as a specification language in a pure Markdown/shell project could create a false expectation that implementation will be in TypeScript. The document should include a clear note: "TypeScript syntax is used as specification notation. Implementation language is determined by the adapter."

**3. `autoApprove` field debate.** The synthesis plan includes `autoApprove: boolean`. My recommendation is to omit it. If the synthesizer insists on including it, it should be documented as "always true for headless delegation; included for completeness." This avoids a field that is never false in practice.

**4. Model tier vocabulary drift.** Using `opus | sonnet` ties the enum to Anthropic's naming. If the team later wants vendor-neutral terminology (`high | standard`), that is a breaking change to the type. However, the entire codebase already uses these names (every AGENT.md says `model: opus` or `model: sonnet`), so the cost of renaming is project-wide regardless. Stay with `opus | sonnet`.

**5. `changedFiles` may be empty on failure.** If a tool crashes before making any changes, `changedFiles` is an empty array. This is correct behavior but the orchestrator must not treat empty `changedFiles` as "nothing happened" -- a tool may have partially written files that were then reverted. The status field (`failed` or `timeout`) is the authoritative signal for task success.

### Additional Agents Needed

None. The current planning team is sufficient for this task. The types are a contract definition informed by:
- API design principles (this contribution)
- Protocol/integration patterns (mcp-minion's prior contribution covers this)
- Security review (already completed in the prior planning cycle)

The downstream implementation tasks (Milestones 2-4) will need different specialists, but the type definition in Issue 1.1 does not require additional input.
