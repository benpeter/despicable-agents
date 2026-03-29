## Domain Plan Contribution: ai-modeling-minion

### Recommendations

#### (a) AGENTS.md: Markdown body passthrough is sufficient, with one structural adjustment

AGENTS.md is "just standard Markdown" per the AAIF specification. There is no required schema, no YAML frontmatter, no mandatory sections. The spec says: "Use any headings you like; the agent simply parses the text you provide." This means the AGENT.md body -- once frontmatter is stripped -- is already valid AGENTS.md content.

**No structural transformation is needed for the five content sections** (Identity, Core Knowledge, Working Patterns, Output Standards, Boundaries). They translate as Markdown sections directly.

**One adjustment is warranted**: the Identity section should become the top-level heading. The translation table says Identity maps to "Top-level heading + description." In AGENT.md files, the Identity section already uses a top-level heading (e.g., `# Identity`, `# Frontend Minion`, `# Security Minion`). Some agents use `# Identity` as the heading while others use their role name. Both work for AGENTS.md since the `description` frontmatter field (which would provide the preamble in CLAUDE.md) is stripped. No heading rewrite is needed -- the existing heading hierarchy works as-is.

**Domain markers (`<!-- @domain:...-->`) should be stripped.** These HTML comments are build system metadata used by the overlay pipeline. They carry no instruction content and would confuse external models. There are 28 of these markers across nefario/AGENT.md. Strip all HTML comments matching `<!-- @domain:` as they provide build pipeline information, not agent instructions. (Aligns with security-minion's R4 recommendation.)

**Bottom line**: For AGENTS.md, the translator is: strip frontmatter + strip Claude Code content + strip `@domain:` markers = done. No content restructuring.

#### (b) CONVENTIONS.md: No content restructuring required

Aider's CONVENTIONS.md is intentionally unstructured -- it is plain Markdown containing coding guidelines. There is no formal specification, no required sections, and no structural expectations beyond "markdown file with guidelines." Aider loads it via `--read CONVENTIONS.md` and includes the full content in the LLM context as-is.

The translation table says Identity maps to a "Preamble section" for CONVENTIONS.md, but this does not imply a restructuring requirement. The existing Identity heading and content in AGENT.md already serves this purpose. No rewriting needed.

The only CONVENTIONS.md-specific consideration is that Aider's convention files are typically short and directive ("Prefer httpx over requests. Use types everywhere possible."). The AGENT.md files are significantly longer and more structured. This is not a format incompatibility -- Aider handles long convention files -- but it does mean the full AGENT.md body will consume substantial context window in Aider. This is an operational concern, not a translator concern. The translator should not truncate or summarize.

**Bottom line**: For CONVENTIONS.md, the same pipeline works. The output format difference between AGENTS.md and CONVENTIONS.md is negligible in practice. Both are plain Markdown. The devx-minion's recommendation to add a `<!-- Translated from: ... -->` source comment for CONVENTIONS.md is a reasonable provenance marker but optional.

#### (c) Defensive stripping is the correct approach

The meta-plan asks whether stripping should be defensive (handle patterns that could theoretically appear) or conservative (only patterns that exist today). **Defensive is correct**, for three reasons:

1. **AGENT.md files evolve.** The 27 agents are rebuilt from `the-plan.md` spec, and the spec is actively iterated. New Claude Code-specific patterns could appear in any rebuild. A conservative stripper that only handles today's patterns would silently pass new patterns through, producing instruction files that reference tools the target harness does not have.

2. **The cost of defensive stripping is low.** Adding patterns for `Task`, `TaskCreate`, `TaskUpdate`, `TaskList`, `SendMessage`, `TeamCreate`, `TeamUpdate`, and `AskUserQuestion` to a pattern list costs nothing at runtime and prevents future leakage. These are all Claude Code platform primitives that have no meaning in Codex or Aider.

3. **False positives are manageable.** The concern with defensive stripping is accidentally removing content that happens to contain a pattern word in a non-Claude-Code context. For example, "Task" is a common English word. The mitigation (which devx-minion and security-minion both converge on) is to strip by structural context, not bare keywords. Strip `TaskUpdate` (PascalCase compound, unambiguous), not `task` (common word). Strip `(TaskUpdate)` and `(SendMessage)` (parenthetical tool references), not bare mentions of "sending a message."

**Pattern categories for defensive stripping**:

| Category | Patterns | Context |
|----------|----------|---------|
| Claude Code tool primitives | `TaskUpdate`, `TaskList`, `SendMessage`, `TeamCreate`, `TeamUpdate`, `AskUserQuestion` | Always PascalCase; unambiguous |
| Task tool invocation | `Task tool`, `spawned subagent`, `claude --agent` | Phrases unique to Claude Code |
| Scratch directory | `nefario-scratch-*`, `scratch directory conventions` | Session artifact references |
| Nefario skill references | `/nefario` skill, `via the /nefario skill` | Internal orchestration references |
| Overlay/build markers | `<!-- @domain:...-->` | Build pipeline metadata |
| Claude Code-specific sections | `## Main Agent Mode` (heading to next heading) | Entire section is Claude Code-only |

For the "Main Agent Mode (Fallback)" section in nefario/AGENT.md (lines 882-889): this is entirely about Claude Code's agent teams API and should be removed as a whole section. The awk heading-bounded removal approach proposed by devx-minion is correct.

#### (d) Cross-model instruction fidelity: real concerns and practical mitigations

This is the most substantive prompt engineering question. When AGENT.md content designed for Claude models is consumed by OpenAI o3/o4-mini (via Codex) or by other models (via Aider), instruction fidelity may degrade in specific ways. Here is the analysis:

**1. XML tags require no special handling**

The AGENT.md files in this project do not use XML tags (`<instructions>`, `<context>`, `<examples>`, `<output_format>`). Claude is fine-tuned to pay attention to XML tags as structural markers, but the despicable-agents AGENT.md files use standard Markdown headings instead. This is fortunate -- Markdown headings are universally understood across all model families. No translation needed.

If XML tags were present, they would need attention: OpenAI's o-series models do not have special training on XML-delimited prompt sections the way Claude does. They would parse them as literal text, which usually works but loses the structural signaling. Since the AGENT.md files already use Markdown, this is a non-issue.

**2. Behavioral instruction tone differences**

Claude 4.x models follow instructions literally and respond well to explicit, declarative instructions. The AGENT.md files use this style: "You ALWAYS follow the full process unless the user explicitly asked not to." "You NEVER skip any gates or approval steps."

OpenAI o3/o4-mini are reasoning models with internal chain-of-thought. Key behavioral differences:

- **o3/o4-mini do not need to be told to reason.** They already produce internal CoT. Instructions like "analyze carefully" or "think step by step" can actually hurt o-series performance by inducing redundant reasoning. The AGENT.md files do not use these patterns -- they are directive, not reasoning-prompting -- so this is not a translation concern.
- **o3 has documented lazy behavior.** Rare instances where o3 states it "does not have enough time" or gives terse answers. AGENT.md instructions with high detail (like nefario's delegation table and cross-cutting checklist) may trigger this. No translator mitigation is feasible -- this is a model behavioral property. The user should be aware when routing complex orchestration tasks to o3 that output completeness may vary.
- **o4-mini has weaker instruction following on complex constraints.** When an AGENT.md has many interlocking rules (nefario's approval gates, cascading dependencies, anti-fatigue rules), o4-mini may not track all constraints simultaneously. For specialist minions with simpler instruction sets (gru, frontend-minion, test-minion), o4-mini should perform adequately.

**Recommendation**: The translator does NOT need to rewrite instructions for different models. The AGENT.md content is model-agnostic Markdown. Instruction fidelity differences are inherent to model capability, not instruction format. The routing config's `model-mapping` section is the correct lever: users map `opus -> o3` (not `o4-mini`) for agents with complex instruction sets, and `sonnet -> o4-mini` for simpler specialists. This is a routing decision, not a translation decision.

**3. The Boundaries / "Does NOT do" pattern works cross-model**

The Boundaries sections use a delegation pattern: "Does NOT do X -- delegate to Y." This pattern works across model families because it states both what to avoid and what the alternative is. Models that are weaker at following negative constraints can still follow the positive delegation instruction. No translation concern.

**4. Markdown heading hierarchy is the universal structural format**

All major models (Claude, GPT, Gemini, open-weight) process Markdown headings as structural markers. The AGENT.md heading hierarchy (`# Identity`, `## Core Knowledge`, `### Subsection`) translates without loss to any model. This is the primary reason no structural transformation is needed.

**5. Content density may be an issue for smaller models**

Some AGENT.md files are large. nefario/AGENT.md is 950+ lines. frontend-minion/AGENT.md is 560+ lines. When these are loaded as AGENTS.md in Codex, they consume a significant portion of the context window alongside the task prompt, the working directory context, and any files the model reads.

For o4-mini (128K context), this is manageable. For Aider with smaller-context models, the full AGENT.md body may be too large. This is not a translator concern -- the translator should not truncate. But it is a routing concern that the documentation should note: agents with very large AGENT.md files (nefario, frontend-minion, security-minion) work best with models that have large context windows.

**6. Preamble injection for model orientation (optional, recommended for future milestone)**

There is one translation that COULD improve cross-model fidelity but should NOT be implemented in the current milestone: a brief preamble line that orients the consuming model. Example:

```
# [Agent Name]
[Agent description from frontmatter]

---
[rest of AGENT.md body]
```

This would convert the `name` and `description` frontmatter fields into visible Markdown at the top of the output, replacing the implicit identity conveyed by the Claude Code agent loading mechanism. Currently, when Claude Code loads an agent, the `name` and `description` from frontmatter are presented in the agent selection UI and initial context. An external tool loading an AGENTS.md file does not have this implicit identity channel.

**Recommendation**: Do NOT implement this in the current translator. The AGENT.md Identity section already provides this information in the body content. Adding a preamble risks duplication. But flag this as a potential enhancement for the Codex validation milestone (#146): if validation reveals that external models perform better with an explicit name/description preamble, add it then.

### Proposed Tasks

**Task AM1: Define the complete stripping pattern list** (input to translator implementation)

Create a declarative stripping manifest that categorizes every Claude Code-specific pattern by type (section removal, line removal, token removal with context cleanup). This manifest is the specification the sed/awk implementation works from. Include:

- Section removals: `## Main Agent Mode` heading-bounded
- HTML comment removals: `<!-- @domain:...-->`
- Tool primitive tokens: `TaskUpdate`, `TaskList`, `SendMessage`, `TeamCreate`, `TeamUpdate`, `AskUserQuestion` (PascalCase only)
- Phrase removals: `via the Task tool`, `via the /nefario skill`, `running as main agent via \`claude --agent ...\``
- Scratch reference removals: `nefario-scratch-*`, `scratch directory conventions`
- Context cleanup rules: empty parentheses, dangling commas, double spaces

This should be created as a documented data structure (the sed pattern file proposed by devx-minion works, but with comments documenting why each pattern exists).

**Task AM2: Validate instruction fidelity across all 27 AGENT.md files** (part of test task)

For each of the 27 AGENT.md files, verify that the translated output:
- Retains all Core Knowledge, Working Patterns, Output Standards, and Boundaries content
- Has no residual Claude Code-specific references
- Has valid Markdown heading hierarchy (no orphaned subsections from section removal)
- Has no grammatically broken sentences from token stripping (specifically check nefario)

This is a test design recommendation, not a standalone task -- it should be folded into the test-minion's test strategy as a "translation completeness" test suite.

**Task AM3: Document cross-model instruction caveats in adapter-interface.md** (part of docs task)

Add a short "Cross-Model Instruction Notes" section (5-8 lines) to adapter-interface.md documenting:
- AGENT.md instructions are model-agnostic Markdown; no rewriting is performed per model
- Large AGENT.md files (500+ lines) consume significant context; route to models with large context windows
- Complex multi-constraint agents (nefario) may see reduced instruction adherence on smaller models; prefer higher-tier models via `model-mapping`
- Preamble injection (name/description from frontmatter into visible Markdown) is deferred to validation findings

### Risks and Concerns

| Risk | Severity | Description | Mitigation |
|------|----------|-------------|------------|
| Token stripping leaves broken prose | Medium | Removing `TaskUpdate` from "assign tasks (TaskUpdate)" leaves "assign tasks ()" which a non-Claude model may misinterpret as an instruction to "assign tasks with empty parameters" | Context cleanup patterns (empty parens, dangling commas). Test specifically against nefario/AGENT.md lines 887-889. |
| o3 lazy behavior on complex agent prompts | Low-Medium | o3 may give abbreviated responses when processing a 950-line nefario AGENTS.md + long task prompt | Not a translator concern. Document as a routing caveat: nefario should generally stay on Claude Code, not route to Codex. |
| o4-mini drops constraints from dense instruction sets | Medium | Agents with many interlocking rules (approval gates, cross-cutting checklists) may see partial adherence on o4-mini | Route complex orchestration agents to `opus` tier (o3), not `sonnet` tier (o4-mini). This is already the default: nefario's frontmatter says `model: opus`. |
| AGENTS.md spec evolves beyond "just Markdown" | Low | AAIF could add required sections, metadata, or structural requirements | Translator is a thin layer; adaptation cost is low. Monitor AAIF spec cadence. |
| Aider convention file length affects caching | Low | Aider caches convention files for prompt caching efficiency. Very large convention files may reduce cache effectiveness if they change frequently. | AGENT.md files are stable (change only on rebuild). Cache benefit should hold. Not a translator concern. |
| Preamble injection deferred too long | Low | External models may underperform without the frontmatter name/description visible in the instruction text | Track during Codex validation (#146). If 2+ of 5 test tasks show identity confusion, implement preamble injection before Aider validation (#147). |

### Additional Agents Needed

None beyond those already planned. The cross-model instruction fidelity analysis is complete and does not require additional specialist input. The recommendations integrate cleanly with devx-minion's implementation design and security-minion's stripping approach.

One coordination note: **devx-minion and security-minion disagree on stripping granularity.** devx-minion recommends token-level sed with context cleanup. security-minion recommends section-level removal to avoid broken prose. Both have merit. The synthesis should resolve this by using a hybrid: section-level removal for sections that are entirely Claude Code-specific (Main Agent Mode), and token-level removal with context cleanup for inline references in otherwise-valuable content. This is what both contributions actually converge toward when read carefully -- the disagreement is in emphasis, not in approach.
