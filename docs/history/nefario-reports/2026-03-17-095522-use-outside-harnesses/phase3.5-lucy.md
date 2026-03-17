# Phase 3.5 Review -- lucy (Intent Alignment & Convention Compliance)

## Verdict: ADVISE

### Requirement Traceability

| # | Original Success Criterion | Plan Coverage | Status |
|---|---------------------------|---------------|--------|
| 1 | Inventory of LLM coding tools and context-injection mechanisms | Task 1 prompt: "Tool Inventory" section with per-tool profiles | COVERED |
| 2 | AGENT.md knowledge mapping to each tool's instruction format | Task 1 prompt: "Instruction Format Landscape" section with translation table | COVERED |
| 3 | Feasibility assessment: delegation wrapper start/inject/collect | Task 1 prompt: "Feasibility Assessment" section with three-tier verdicts | COVERED |
| 4 | Gap analysis: current Agent tool vs. wrapper replication | Task 1 prompt: "Gap Analysis" section, explicitly requires structured table | COVERED |
| 5 | Clear recommendation with rationale | Task 1 prompt: "Recommendations" section, ownership assigned to ai-modeling-minion | COVERED |
| 6 | Research written to new doc under docs/ | Task 1 deliverable: `docs/external-harness-integration.md` | COVERED |

All six success criteria map to plan elements. No stated requirements are missing.

### Scope Containment

| Plan Element | Traces To | Assessment |
|-------------|-----------|------------|
| Task 1: Write research report | Criteria 1-6 | ALIGNED |
| Task 2: Cross-links to existing docs | Implied by criterion 6 (integration into docs/) and project convention (hub-and-spoke docs) | ALIGNED -- minimal scope, justified by project structure |
| Report structure (10 sections) | Criteria 1-5 map to sections; remaining sections are framing (Problem Statement, Current Delegation Model, Protocol Landscape, Out of Scope, Open Questions) | ALIGNED -- framing sections are proportional |
| Protocol Landscape section | Original scope includes "inter-agent protocols" | ALIGNED |
| Approval gate on Task 1 | Not a deliverable; process control | ALIGNED -- justified by blast radius |
| Mermaid diagrams (2) | Not explicitly requested | See ADVISE-1 below |
| Technology radar rings per tool | Not explicitly requested | See ADVISE-2 below |

### Findings

- [ADVISE-1 / SCOPE]: Mermaid diagram constraint in Task 1 prompt
  SCOPE: Task 1 prompt, Constraints section -- "Include Mermaid diagrams for: (1) current delegation flow, (2) where an external harness adapter would conceptually sit"
  CHANGE: Make the diagrams optional ("Include Mermaid diagrams where they clarify flow, such as...") rather than mandatory. The second diagram ("where an external harness adapter would conceptually sit") risks drifting into architecture proposal territory, which the scope guard explicitly prohibits.
  WHY: The scope guard says "Do not produce implementation designs, architecture proposals." A diagram showing where an adapter "would conceptually sit" is a lightweight architecture proposal. Making it optional lets the author use judgment about whether it crosses the line. The first diagram (current delegation flow) is purely descriptive and fine.
  TASK: 1

- [ADVISE-2 / SCOPE]: Technology radar rings in Recommendations section
  SCOPE: Task 1 prompt, Report structure, Recommendations section -- "Technology radar rings (adopt/trial/assess/hold) per tool as delegation targets"
  CHANGE: Clarify that these rings assess delegation readiness specifically, not general tool quality. The current prompt text says this but only in the Risks table (Risk 5), not in the report structure description where the author will actually read it.
  WHY: Without the clarification co-located with the instruction, the author may produce general tool evaluations (which gru already owns) rather than delegation-fitness ratings. This is a minor phrasing fix, not a structural concern.
  TASK: 1

- [ADVISE-3 / CONVENTION]: Task 2 scope guard is copy-pasted and misapplied
  SCOPE: Task 2 prompt, SCOPE GUARD text -- "This is a research task. Do not produce implementation designs, architecture proposals, or code."
  CHANGE: Replace with a scope guard appropriate to Task 2's actual job: "This is a cross-linking task. Add minimal cross-references only. Do not add new content, restructure existing documents, or modify the research report."
  WHY: Task 2 is not a research task -- it adds cross-links. The copy-pasted scope guard from Task 1 is technically harmless but imprecise. Imprecise instructions in prompts create ambiguity about what the agent is actually guarding against. The "What NOT to do" section already covers this well; the scope guard should match.
  TASK: 2

### Items Verified (No Concerns)

- **Research vs. design framing**: Conflict Resolution 2 correctly addresses the drift risk. The scope guard in Task 1 is well-written and specific. The "do not produce" constraints list is comprehensive. Risk 1 mitigation is adequate.
- **Publishability**: PUBLISHABILITY GUARD in Task 1 is explicit and correct. CLAUDE.local.md biases are addressed in Risk 6. No vendor-specific language in the plan itself.
- **English**: All artifacts are in English. No concern.
- **Task decomposition (2 tasks, 1 gate)**: Appropriate. The consolidation from 3-5 proposed tasks down to 2 is well-justified and aligns with "more code, less blah, blah." The gate placement is correct -- Task 2 depends on Task 1's output.
- **Conflict resolutions**: All five are sound. Resolution 2 (research vs. design) is the most important and is well-handled. Resolution 3 (MCP positioning) correctly limits MCP to Layer 2. Resolution 4 (task granularity) correctly consolidates.
- **Cross-cutting coverage**: Correctly scoped for a documentation-only deliverable. No testing, no observability, no UX design -- all justified. Security acknowledged as out of scope in the report itself.
- **Architecture review agents**: Appropriate selection. software-docs-minion as discretionary pick is correct given the deliverable is a document.
- **Word count constraint (1500-2500)**: Proportional to the problem. Addresses Risk 4.
- **the-plan.md**: Not modified. Compliant.

### Summary

The plan is well-constructed and faithfully tracks the original request. All six success criteria are addressed with clear traceability. The two-task structure is appropriately lean. The three advisory items are minor phrasing improvements, not structural concerns. No blocking issues detected.
