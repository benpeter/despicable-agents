**Outcome**: Agent input prompts are written to named files in the scratch directory before invocation, and agents receive a file reference rather than the full prompt inline. This serves two goals: users can trace any advisory back to the exact prompt that produced it (transparency), and prompts persist as durable artifacts that survive context compression and can be re-read by agents or the orchestrator later (context preservation).

**Success criteria**:
- Each agent invocation writes its input prompt to a file in scratch before the agent runs (e.g., `scratch/{phase}-{agent}-prompt.md`)
- Agents read their prompt from the file rather than receiving it entirely inline
- Agent output files in scratch are clearly paired with their input prompt files
- Advisory summaries presented to the user include a file path reference to the corresponding input prompt
- Existing orchestration behavior (phase flow, agent selection, synthesis) is unchanged

**Scope**:
- In: Prompt file creation and agent file-reference delivery for all phases that invoke agents, advisory formatting with prompt links
- Out: Changes to agent system prompts, changes to META-PLAN or SYNTHESIS content format, scratch dir cleanup/retention policy

**Constraints**:
- Must work within existing scratch directory conventions
