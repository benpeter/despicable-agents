## Domain Plan Contribution: lucy

### Recommendations

#### 1. Success Criteria Traceability

The six success criteria from the issue map to the planning consultations as follows:

| # | Success Criterion | Covered By | Coverage Status |
|---|-------------------|------------|-----------------|
| 1 | Inventory of LLM coding tools and context-injection mechanisms | gru (Consultation 2) | COVERED -- gru's planning question explicitly asks for CLI/API availability, context-injection mechanisms, result collection, maturity, and format openness per tool |
| 2 | Analysis of how AGENT.md knowledge maps to each tool's instruction format | ai-modeling-minion (Consultation 1, sub-question 3) | COVERED -- planning question asks about prompt/instruction format translation (AGENT.md -> .cursorrules, .aider.conf, etc.) |
| 3 | Feasibility assessment: delegation wrapper can start tool, inject knowledge, collect results | ai-modeling-minion (Consultation 1) + devx-minion (Consultation 3) + mcp-minion (Consultation 4) | COVERED -- split across three consultations covering abstraction layer, DX, and protocol. Risk: coverage is dispersed; synthesis must explicitly reunify these into a single feasibility verdict |
| 4 | Gap analysis: current Agent tool vs. wrapper capabilities | ai-modeling-minion (Consultation 1, sub-question 4) | PARTIALLY COVERED -- the planning question asks about "fundamental constraints" but does not explicitly frame it as a gap analysis comparing what the Task tool provides today versus what a wrapper can replicate. The term "gap analysis" does not appear in any planning question |
| 5 | Clear recommendation: feasible now / feasible with constraints / not yet feasible | Not explicitly assigned to any consultation | GAP -- no planning question asks a specialist to produce or structure the feasibility recommendation. The meta-plan's scope section lists it as in-scope but no consultation owns it. This must be assigned during synthesis (likely to the execution agent or nefario's synthesis phase) |
| 6 | Research written to a new doc under docs/ | software-docs-minion (Consultation 5) | COVERED -- planning question asks about placement, structure, and linking |

**Finding [TRACE-1]**: Success criterion 5 (the clear recommendation) has no owning consultation. The recommendation is the core deliverable -- it is the answer to the user's question. It must not emerge as an afterthought during execution. The synthesis should explicitly assign a task for formulating the recommendation, drawing on the feasibility evidence from consultations 1, 2, 3, and 4.

**Finding [TRACE-2]**: Success criterion 4 (gap analysis) is implicitly covered in the ai-modeling-minion question but not framed as a structured comparison. The planning question asks about "fundamental constraints of the current Claude Code delegation model" but does not ask for a side-by-side gap analysis (what Task tool provides vs. what a wrapper can replicate vs. what is lost). The synthesis should ensure the execution plan includes a task that produces an explicit gap table, not just a narrative discussion of constraints.

#### 2. Scope Drift Risk Assessment

I identify the following drift risks across the five domain consultations:

**[DRIFT-1] devx-minion consultation drifts toward design.** The planning question asks "what should the developer experience look like?" and requests specifics on invocation format, configuration format, and error experience. This is design work, not research. The issue asks for a research report, not a design doc. The devx-minion question should be reframed to ask "what DX dimensions should the research evaluate?" rather than "what should the DX look like?" The difference: the report should describe what a good wrapper DX would need to address, not prescribe how it should work.

**[DRIFT-2] ai-modeling-minion consultation asks "what abstraction layer would be needed?"** This is an architecture question, not a research question. The issue asks whether delegation is feasible, not how to architect the abstraction layer. The consultation should ask "what are the key abstractions that would need to exist?" as research findings, not "design the abstraction layer."

**[DRIFT-3] mcp-minion consultation asks "could MCP serve as the inter-agent communication layer?"** This is appropriately scoped as research. However, risk exists that the mcp-minion response will advocate for MCP as the solution rather than neutrally assessing it alongside alternatives. The synthesis should treat MCP, A2A, and CLI wrappers as equal candidates and let the evidence determine the recommendation.

**[DRIFT-4] Cross-cutting checklist includes security and UX sections.** The meta-plan instructs the execution agent to "include a security section in the report" and "note UX implications." This is appropriate scope (these are genuine research dimensions), but the phrasing risks inflating the report with sections that lack specialist backing. The execution instruction should clarify: brief subsections noting security and UX considerations with explicit "this area was not deeply analyzed" caveats, not full sections that simulate specialist depth.

**Overall drift assessment**: The planning questions collectively lean toward "how to build the wrapper" rather than "is building the wrapper feasible and what does the landscape look like?" This is a natural tendency when five domain specialists each optimize for their domain. The synthesis must actively correct this by framing all specialist input as evidence feeding the feasibility assessment, not as design inputs.

#### 3. Convention Compliance

The research report must respect these project conventions:

**Publishability (CLAUDE.md, Key Rules)**:
- "No PII, no proprietary data -- agents must remain publishable (Apache 2.0)"
- The report must not mention vendor-specific internal usage patterns, must not advocate for any tool as "the one we use," and must remain useful to any consumer of the despicable-agents framework
- Tool names (Cursor, Aider, Codex CLI) are fine -- they are public products. The research should describe their public APIs and documented instruction formats only

**English (CLAUDE.md, Key Rules)**:
- "All artifacts in English" -- the report must be written in English

**Engineering Philosophy (CLAUDE.md)**:
- YAGNI: The report should not propose building things that are not yet needed. It should assess feasibility without prescribing implementation
- KISS: The report should prefer the simplest viable integration path when assessing feasibility
- "More code, less blah, blah": This is a research deliverable, so extended prose is expected -- but the report should use tables and matrices over narrative where possible (tool comparison matrix, gap analysis table, recommendation matrix)

**Documentation Conventions (observed from docs/)**:
- Back-link to architecture.md at the top: `[< Back to Architecture Overview](architecture.md)`
- Integration into the sub-document table in architecture.md (Contributor / Architecture section)
- Mermaid for diagrams where spatial layout is not critical (per user's global CLAUDE.md)
- No Unicode box-drawing characters in ASCII diagrams (per user's global CLAUDE.md)

**Design Philosophy (docs/architecture.md)**:
- "Generic specialists -- Deep domain expertise without ties to any specific project" -- the research must assess tools generically, not for a specific project's delegation needs
- "Composable" -- the research should consider how external tool delegation fits into the composability model

#### 4. Scope Boundary Clarity

The meta-plan's scope section is well-defined:

**In scope**: Six items that map directly to the six success criteria. Good.

**Out of scope**: Five items that correctly exclude implementation. Good.

**Boundary risk**: The planning questions for devx-minion and ai-modeling-minion cross into "how to build it" territory (see DRIFT-1 and DRIFT-2 above). The out-of-scope list says "Building the actual delegation wrapper" but the planning questions ask for wrapper DX design and abstraction layer architecture. These are not implementation, but they are design -- which is also out of scope for a research report.

**Recommendation**: The synthesis should include an explicit instruction to the execution agent: "This is a research report. Assess feasibility and describe the landscape. Do not produce design specifications, API contracts, or architecture proposals. Where the research identifies that 'an abstraction layer would be needed,' describe what it would need to do, not how it should be structured."

### Proposed Tasks

**Task 1: Explicit gap analysis table**
- What: Produce a structured table comparing what the current Claude Code Task tool provides (prompt delivery, context injection, file access, result collection, error handling, progress reporting) against what each candidate external tool can replicate via its public interface
- Deliverable: Gap analysis table in the research report
- Dependencies: Requires input from gru (tool inventory) and ai-modeling-minion (current Task tool contract)
- Rationale: Addresses TRACE-2 finding. Without this table, criterion 4 is met only narratively

**Task 2: Feasibility recommendation formulation**
- What: Synthesize evidence from the tool inventory, format mapping analysis, gap analysis, and protocol assessment into a single recommendation with the three-tier verdict (feasible now / feasible with constraints / not yet feasible) applied per-tool or per-tool-category
- Deliverable: Recommendation section in the research report with clear verdict and supporting evidence citations
- Dependencies: All other research sections must be complete before this is written
- Rationale: Addresses TRACE-1 finding. This is the core deliverable and must be explicitly tasked, not left implicit

**Task 3: Convention compliance check on final report**
- What: Before committing, verify the research report has: back-link to architecture.md, English only, no PII/proprietary data, no tool advocacy, uses tables over narrative where possible, no Unicode box-drawing
- Deliverable: Clean report that passes convention check
- Dependencies: Report draft complete

**Task 4: Architecture.md integration**
- What: Add the new research doc to the sub-document table in `docs/architecture.md`
- Deliverable: Updated architecture.md with link to new doc
- Dependencies: Report filename and location finalized (from software-docs-minion input)

### Risks and Concerns

**Risk 1: Design document masquerading as research report** (HIGH)
Five domain specialists will each contribute "how to build it" insights. Without active framing correction, the synthesis will produce a design document, not a feasibility study. The execution agent must be instructed to maintain the research framing: "what exists, what maps, what gaps remain, is it feasible" -- not "here is how to build it."

**Risk 2: Tool advocacy undermining neutrality** (MEDIUM)
The gru consultation may produce strong adopt/hold recommendations that read as endorsements. The mcp-minion consultation may advocate for MCP as the protocol solution. The report must present these as assessed options, not as the project's chosen direction. Remedy: the recommendation section should use the three-tier verdict framework without prescribing a technology choice.

**Risk 3: Report bloat** (MEDIUM)
Six success criteria, five specialist contributions, two cross-cutting dimensions (security, UX) -- the report could easily become 3000+ words of narrative. The engineering philosophy says "more code, less blah, blah." While this is a prose deliverable, the report should prefer tables and matrices. A 1500-2000 word report with 3-4 tables is more aligned with project conventions than a 4000-word narrative.

**Risk 4: Stale tool data** (LOW)
LLM coding tools are evolving rapidly. The report will reflect the state as of March 2026. It should include a "last assessed" date and note that tool capabilities change frequently. This is standard for technology radar output.

**Risk 5: Publishability violation via CLAUDE.local.md leakage** (LOW but CRITICAL if triggered)
The project's CLAUDE.local.md contains technology preferences (Fastly, Coralogix, etc.) and an explicit "NEVER mention Adobe" constraint. The research report is publishable under Apache 2.0. The execution agent should not be influenced by CLAUDE.local.md preferences when writing the report. Since CLAUDE.local.md is automatically loaded for the session, the synthesis should explicitly instruct: "The research report must be vendor-neutral and not reflect any local technology biases."

### Additional Agents Needed

None. The current team of six (ai-modeling-minion, gru, devx-minion, mcp-minion, software-docs-minion, lucy) is appropriate for a research report. Adding more specialists would increase the risk of scope inflation without improving the research quality. The two excluded agents (security-minion, ux-strategy-minion) are correctly handled via cross-cutting notes rather than full consultations -- the research should note security and UX dimensions without specialist depth.
