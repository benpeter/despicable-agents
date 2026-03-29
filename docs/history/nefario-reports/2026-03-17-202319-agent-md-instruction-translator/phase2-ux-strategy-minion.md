## Domain Plan Contribution: ux-strategy-minion

### Recommendations

**Short answer: Yes, there are developer-experience concerns. No, they do not require heavy UX process.**

The translator is internal infrastructure with exactly two consumers (Codex adapter, Aider adapter), but "internal" does not mean "no users." The adapter developers are users. Applying Don Norman's principle: the people who call this translator need visibility into what happened and clear error feedback when something goes wrong. The simplicity bar is different from a consumer product, but the cognitive load principles still apply.

Three targeted DX recommendations:

1. **Fail loudly with context, not silently with garbage output.** The translator strips frontmatter and Claude Code-specific content. If the input AGENT.md is malformed (missing frontmatter delimiter, unparseable YAML), the translator should fail immediately with a message that names the problem and the file, not produce a half-translated file that causes a confusing downstream error in Codex or Aider. This is Nielsen's heuristic #9 (help users recognize, diagnose, and recover from errors) applied to developer tooling. The adapter author should never have to debug "why did Codex reject this instruction file?" when the real problem was bad AGENT.md input.

2. **Return structured output, not just a file path.** The adapter interface already defines `translated_instruction_path` as the translator's output. But the adapter also needs the extracted frontmatter fields (model tier, tools list, agent name) to construct the rest of the `DelegationRequest`. The translator should return these as a structured result alongside the file path -- not force the adapter to re-parse the AGENT.md separately. This is recognition over recall: the adapter should not need to know how to parse YAML frontmatter when the translator already did that work. One call, complete result.

3. **Make the "Claude Code-specific content" stripping rules visible.** The translator strips TaskUpdate, SendMessage, scratch directory conventions. These stripping rules are an implicit contract. If someone adds a new Claude Code-specific pattern to an AGENT.md later, it will pass through unstripped. Document the stripping rules as an explicit, enumerated list in a comment or constant at the top of the translator code. This is not a user-facing concern -- it is a maintainability concern that prevents future adapter developers from wondering "why is this Claude Code reference in my AGENTS.md output?"

**What does NOT need UX attention:**

- No progressive disclosure needed (two consumers, not a spectrum of novice-to-expert).
- No configuration surface (translator behavior is deterministic from input format + target format).
- No interactive choices (purely programmatic invocation).
- No journey mapping (single function call, not a multi-step flow).

This is a case where "keep it purely functional" is the right call, with the caveat that "purely functional" must include clear error paths and structured returns. A function with good error messages IS good UX for developer tools.

### Proposed Tasks

No standalone UX tasks. The recommendations above are implementation guidance for whoever builds the translator (likely devx-minion or a code-focused agent). They should be folded into the translator implementation task, not tracked separately.

If the synthesis plan includes a task for the translator, add these as acceptance criteria:

- Malformed AGENT.md input (missing `---` delimiters, invalid YAML) produces a clear error message naming the file and the parse failure, not a partial output file.
- Translator returns both the instruction file path AND the extracted frontmatter fields (at minimum: `name`, `model`, `tools`) as a structured result.
- Claude Code-specific stripping patterns are enumerated as a maintained list, not scattered regex.

### Risks and Concerns

**Low risk: Silent stripping failures.** If the translator strips Claude Code-specific content via regex or pattern matching, edge cases in AGENT.md content (e.g., a markdown section that happens to mention "TaskUpdate" in prose rather than as an instruction) could be incorrectly stripped. Recommend: strip only content that matches structural patterns (e.g., specific instruction blocks), not bare keyword mentions. This is an implementation detail, but getting it wrong produces confusing output for adapter developers who cannot easily tell what was stripped.

**Low risk: Format drift between AGENTS.md and CONVENTIONS.md.** The translator targets two output formats today. If the Aider CONVENTIONS.md format evolves differently from AGENTS.md, the translator's internal branching may grow silently. Not a UX concern per se, but a maintainability concern that affects the developer experience of extending the translator later.

### Additional Agents Needed

None. This is a purely functional internal component. The DX recommendations above are lightweight enough to be acceptance criteria on the implementation task. No design review, accessibility review, or documentation beyond inline code comments is warranted for an internal translator function.
