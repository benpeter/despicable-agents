## Domain Plan Contribution: ux-strategy-minion

### Recommendations

#### (a) Field naming clarity -- Is the naming self-explanatory without context?

The field names are mostly strong, but several have naming-to-meaning mismatches that will cause adapter authors to guess wrong on first read.

**DelegationRequest -- field-by-field assessment:**

| Field | Verdict | Notes |
|-------|---------|-------|
| `agent_name` | Clear | Unambiguous. Adapter authors know what agent is in this project. |
| `task_prompt` | Clear | "Prompt" is well-understood. The parenthetical "(already stripped of Claude Code-specific instructions)" in the roadmap is important context that belongs in the type's inline documentation, not just the roadmap. Without it, an adapter author might wonder whether they need to strip instructions themselves. |
| `instruction_file_path` | Ambiguous | This is the *translated* instruction file (AGENTS.md or CONVENTIONS.md), not the source AGENT.md. The name suggests "path to the instruction file" but does not communicate that the orchestrator has already produced a tool-native file. Rename to `translated_instruction_path` or add a doc comment that makes this explicit. Otherwise adapter authors will try to read an AGENT.md and translate it themselves, duplicating Issue 1.3's responsibility. |
| `working_directory` | Clear | Standard concept, universally understood. |
| `model_tier` | Good | The `opus \| sonnet` union type is clear. The word "tier" correctly signals "quality intent, not specific model ID." This is the strongest naming choice in the interface -- it communicates the abstraction level. |
| `required_tools` | Slightly ambiguous | "Required tools" could mean tools the adapter must provide to the AI (the intended meaning) or tools the adapter itself needs installed. Rename to `required_agent_tools` or document as "tools the spawned agent needs available during execution (e.g., Bash, WebSearch)." This is the field used for capability gating (Issue 1.2), so misunderstanding it leads to silent routing failures. |

**DelegationResult -- field-by-field assessment:**

| Field | Verdict | Notes |
|-------|---------|-------|
| `exit_code` | Clear | Universal convention. Zero is success. |
| `changed_files` | Clear | The "(from git diff)" parenthetical is good context. Should be documented as a list of relative file paths from the working directory. |
| `stdout_summary` | Problematic | This name conflates two things: "stdout" (the raw output stream of the subprocess) and "summary" (a semantic digest of what happened). For Codex, this might be parsed from actual stdout. For Aider, this is LLM-generated from git diff (Issue 3.1). The name implies it came from stdout when it may not have. Rename to `task_summary` -- it describes what the field *means* (a human-readable summary of what the task accomplished), not where the data *came from* (which varies by adapter). |
| `stderr` | Clear | Standard convention. Raw error output. |
| `raw_diff_reference` | Ambiguous | "Reference" is vague. Is this a file path? A git ref? A URL? An inline diff string? "Reference" could mean any of these. Clarify to `diff_path` (if it is a file path to a saved diff), `diff_ref` (if it is a git ref like `HEAD~1..HEAD`), or `raw_diff` (if it is the diff content itself). The roadmap says "raw diff reference" without specifying the representation, which will lead to inconsistent adapter implementations. |

#### (b) Is the Request/Result boundary intuitive?

Yes, the boundary is well-drawn. The mental model is clean: the orchestrator provides everything the adapter needs to invoke a tool (Request), and the adapter returns everything the orchestrator needs to assess the outcome (Result). This maps to a familiar command-pattern / RPC contract.

Two observations on boundary integrity:

1. **The Request correctly owns "what to do" and the Result correctly owns "what happened."** There is no leakage of orchestrator-internal state into the Result, and no adapter-specific configuration in the Request. This is good.

2. **Missing field on the Result side: `duration_seconds` (or `elapsed_ms`).** The orchestrator currently has no way to know how long an external invocation took. For Milestone 4.2 (Progress Monitoring) and future M8 (Hardening -- cost tracking), execution duration is a basic signal. It costs nothing to include now and avoids a breaking interface change later. This is a must-be feature in Kano terms: its absence will be felt as soon as anyone tries to report on execution performance, and its presence is unremarkable.

3. **Missing field on the Result side: `success` boolean (or equivalent).** The roadmap says "non-zero exit code results in a DelegationResult that the orchestrator can distinguish from success" (Issue 2.2 acceptance criteria). Currently, the only way to determine success is interpreting `exit_code`. But different tools use different exit codes (Aider might return 1 for "no changes needed," which is not a failure). A derived `success` boolean lets the adapter normalize tool-specific exit semantics so the orchestrator does not need per-tool exit code knowledge. This maintains the principle that "nefario remains unaware of which tool executes each task." Without it, the orchestrator leaks adapter-specific interpretation logic.

#### (c) Fields where name suggests one thing but description implies another

Two clear cases:

1. **`instruction_file_path`**: Name suggests any instruction file. Roadmap means the already-translated, tool-native instruction file produced by Issue 1.3. This is the highest-risk naming issue because getting it wrong causes adapter authors to duplicate the translation step or pass the wrong file.

2. **`stdout_summary`**: Name suggests parsed stdout. Roadmap description includes LLM-generated summaries (Issue 3.1) that never touched stdout. The name encodes an implementation detail (Codex's approach) as if it were a universal property.

A third, minor case:

3. **`raw_diff_reference`**: "Raw" suggests unprocessed content, but "reference" suggests a pointer to content stored elsewhere. These are in tension -- is the field raw content or a reference to content?

### Proposed Tasks

**Task 1: Normalize field names before type definition is finalized**

- Rename `instruction_file_path` to `translated_instruction_path`
- Rename `stdout_summary` to `task_summary`
- Rename `raw_diff_reference` to a concrete representation name (`diff_path`, `diff_ref`, or `raw_diff`) once the representation decision is made
- Rename `required_tools` to `required_agent_tools`
- Add `duration_ms` to DelegationResult
- Add `success` boolean to DelegationResult (adapter normalizes exit code semantics)
- Deliverable: Updated field list with rationale for each rename
- Dependencies: Must complete before any adapter implementation begins (before Issues 2.1, 3.2)

**Task 2: Write inline documentation for every field**

- Each field needs a one-line description that answers: "What does this contain, and who is responsible for producing it?"
- For `translated_instruction_path`: document that the orchestrator (via Issue 1.3) produces this file; the adapter should pass it to the tool and clean it up after invocation
- For `task_summary`: document that this is a human-readable summary regardless of source -- may come from parsed tool output (Codex) or LLM-generated summarization (Aider)
- For `required_agent_tools`: document that this lists tool capabilities the AI agent needs (Bash, WebSearch, etc.), used for capability gating
- For `model_tier`: document that this is a quality-intent signal, not a model ID -- adapters resolve it via routing config's model-mapping
- Deliverable: Documented type definitions (format matches codebase convention per Issue 1.1 scope)
- Dependencies: Task 1 (names finalized first)

**Task 3: Validate naming with the "cold read" test**

- Have someone unfamiliar with the project read the type definitions and describe what each field means in their own words
- Compare their interpretation to the intended meaning
- Any divergence reveals a naming problem
- This can be done informally (ask a teammate) or via a brief review in the PR
- Deliverable: Validation notes (informal, not a formal doc)
- Dependencies: Task 2

### Risks and Concerns

1. **`stdout_summary` name bakes in a Codex-centric mental model.** The roadmap was written with Codex as the first adapter, and the naming reflects Codex's structured output approach. When Aider adapter authors encounter `stdout_summary`, they will be confused because Aider's summary comes from an LLM summarization service, not stdout. This creates unnecessary cognitive load for every non-Codex adapter author -- the second most important user of this interface. Fix this now; renaming later is a breaking change.

2. **`raw_diff_reference` ambiguity will cause inconsistent implementations.** If Adapter A stores a file path and Adapter B stores a git ref, the orchestrator cannot consume the field generically. The whole point of the shared type is interoperability. Pin the representation before the second adapter ships.

3. **No `success` field forces orchestrator to know adapter exit code semantics.** This violates the roadmap's own principle: "nefario remains unaware of which tool executes each task." Without a normalized success signal, the orchestrator must maintain a per-tool mapping of "which exit codes mean success." This is exactly the kind of harness-specific knowledge the abstraction is supposed to hide.

4. **Low risk: over-engineering the type.** The roadmap's YAGNI constraint is sound -- keep the interface minimal. My recommendations add two small fields (`duration_ms`, `success`) and rename four. This is refinement, not expansion. I am not proposing new capabilities, just clearer communication of existing ones.

### Additional Agents Needed

**software-docs-minion** should review the inline documentation for the type definitions (Task 2). The primary consumers of these docs are adapter authors -- developers who need to implement the contract correctly from documentation alone. The docs-minion can ensure the field descriptions are precise, unambiguous, and follow a consistent format. This is a lightweight review, not a major documentation effort.

No other additional agents needed. The current team is sufficient for the type definition work itself.
