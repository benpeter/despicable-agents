## Domain Plan Contribution: margo

**Verdict: BLOCK -- Do not build DESPICABLE.md. The proposal fails every YAGNI test this project uses.**

### Recommendations

#### 1. There Is No Demonstrated Demand

The framework has exactly one consuming project: the despicable-agents repo itself. Zero external consuming projects exist. The "configuration needs" listed in the proposal (agent exclusion, domain spin, orchestration overrides) are hypothetical. Nobody has filed an issue saying "I need to configure despicable-agents per-project and CLAUDE.md is insufficient." This is a textbook YAGNI violation: building infrastructure for imaginary futures.

The justification test: "When will we need this?" Answer: "Maybe someday when other projects adopt the toolkit." That is the canonical YAGNI failure mode.

#### 2. The Overlay Precedent (Decision 27) Is Directly Applicable

Decision 27 removed ~2,900 lines of overlay infrastructure because it served exactly one agent. The reasoning was explicit: "do not build infrastructure for a pattern until 2+ agents exhibit the need." Replace "agents" with "consuming projects" and the same rule applies with even more force. The overlay mechanism at least had one real user (nefario). DESPICABLE.md has zero real users.

The project literally removed a configuration mechanism 3 days ago for being speculative. Proposing a new configuration mechanism immediately afterward would contradict the project's own freshly-established precedent.

#### 3. CLAUDE.md Already Handles This -- With Zero New Infrastructure

The current design already has a clear, documented answer for project-specific configuration. From `the-plan.md` line 12:

> "Project context belongs in the target project's CLAUDE.md."

From Decision 5 (User-Scope Memory):

> "Project-specific context belongs in the target project's CLAUDE.md, not in agent memory."

This is a settled design principle, not a gap. If a consuming project needs to tell despicable-agents something (exclude certain agents, prefer certain orchestration modes), a `## Despicable Agents` section in that project's CLAUDE.md accomplishes this with:

- Zero new files
- Zero discovery logic
- Zero precedence rules
- Zero documentation for a new file format
- Zero user education ("what is DESPICABLE.md and how does it relate to CLAUDE.md?")

Every agent already reads CLAUDE.md. Every user already knows CLAUDE.md exists. The marginal cost of a section in an existing file is near zero.

#### 4. Complexity Cost Analysis

**DESPICABLE.md approach** (new file):
- New file format to document and maintain (1 point)
- Discovery logic in nefario/agents to find and read DESPICABLE.md (1 point)
- Precedence rules: DESPICABLE.md vs CLAUDE.md vs DESPICABLE.local.md vs CLAUDE.local.md -- four files, what wins? (3 points)
- User education: when to put config in which file (1 point)
- Documentation updates across architecture docs, CLAUDE.md, the-plan.md (1 point)
- Total: ~7 complexity points for a feature with zero users

**CLAUDE.md section approach** (existing mechanism):
- Zero new infrastructure
- Zero new precedence rules
- Zero documentation changes (CLAUDE.md usage is already documented)
- Total: 0 complexity points

The delta is 7 points of accidental complexity for zero demonstrated benefit.

#### 5. The "Separation of Concerns" Argument Does Not Hold

The implicit argument is that despicable-agents config would "pollute" CLAUDE.md. But CLAUDE.md is already the designated place for all project-level instructions to Claude Code -- that includes instructions to agents, which are Claude Code agents. A `## Despicable Agents` section is not pollution; it is exactly the kind of content CLAUDE.md was designed for.

If CLAUDE.md becomes too large, the right response is to organize it better (headings, sections), not to fragment configuration across multiple files with different names and overlapping purposes.

#### 6. Decision 26 Already Solved Portability Without Config Files

Decision 26 explicitly rejected a configuration file (`.nefario.yml`) as YAGNI. The reasoning: "detection logic handles all known cases without user configuration." That decision was made 2 days ago. Nothing has changed since then to invalidate it.

### Proposed Tasks

**Task 1: Do nothing. Close the evaluation with a "not now" decision.**

- **What to do**: Record a decision (Decision 29) that DESPICABLE.md was evaluated and deferred. State the re-introduction trigger clearly: "Revisit when 2+ consuming projects demonstrate configuration needs that a `## Despicable Agents` section in CLAUDE.md cannot serve."
- **Deliverables**: One entry in `docs/decisions.md`
- **Dependencies**: None

**Task 2 (optional): Document the CLAUDE.md section convention**

- **What to do**: If there is genuine concern that future consuming projects will not know how to configure despicable-agents, add a 3-5 line section to the despicable-agents README or docs explaining: "To configure despicable-agents for your project, add a `## Despicable Agents` section to your project's CLAUDE.md."
- **Deliverables**: 3-5 lines in an existing doc file
- **Dependencies**: None

These two tasks are the entire scope. Any expansion beyond this is scope creep.

### Risks and Concerns

1. **Risk of building it anyway**: The primary risk is that the evaluation process itself creates momentum toward building something. "We evaluated it, we might as well build it" is a common trap. The evaluation should produce a clear "no" and stop.

2. **Risk of premature abstraction**: If DESPICABLE.md is built speculatively and the actual configuration needs of real consuming projects turn out to be different from what was imagined, the framework will either need to be reworked or will constrain how projects actually configure things. Building configuration infrastructure before understanding real usage patterns is premature abstraction.

3. **Risk of contradiction**: Building DESPICABLE.md immediately after removing the overlay mechanism (Decision 27) for the same YAGNI reasons would undermine the project's credibility on simplicity principles. It signals that the team does not actually follow its own rules.

### Additional Agents Needed

None. This evaluation does not require additional specialist input. The answer is straightforward application of principles the project has already established and recently reinforced.
