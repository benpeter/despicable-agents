# Domain Plan Contribution: devx-minion

## Recommendations

### (1) Discovery Approach: Leverage Claude Code's Native Loading, Augment with a Scan Step

**Do not duplicate Claude Code's skill loading.** Claude Code already discovers skills from three directory tiers (`~/.claude/skills/`, `.claude/skills/`, `.skills/`) and injects their `name` + `description` into context at startup. Nefario's Phase 1 meta-plan agent already has access to all loaded skill metadata because it runs as a subagent within the same Claude Code session.

**Add an explicit scan step in the META-PLAN prompt.** The native loading gives nefario awareness of skills, but it does not automatically reason about them during planning. The fix is a lightweight addition to the Phase 1 META-PLAN prompt that instructs nefario to:

1. Read the project's CLAUDE.md for orchestration hints and conventions
2. Scan `.skills/` and `.claude/skills/` directories (if they exist) to enumerate available external skills by reading their SKILL.md frontmatter (`name`, `description`)
3. For each discovered skill, decide: does this skill's domain overlap with a despicable-agents specialist, or does it represent a domain the specialists do not cover?
4. Factor the results into specialist selection and delegation

This is a prompt-level change to nefario's META-PLAN mode, not a new mechanism. No code, no new tooling, no new config format. It works because Claude Code's filesystem tools are available to the meta-plan agent.

**Why not rely solely on Claude Code's loading?** Because Claude Code loads skill metadata passively (it appears in context), but nefario needs to actively reason about skills during delegation. The scan step makes reasoning explicit. Without it, nefario might notice skills but not systematically integrate them.

**Why not build a registry, manifest, or config?** Because it violates YAGNI. The filesystem is the registry. SKILL.md frontmatter is the manifest. Claude Code's directory convention is the config. Adding another layer creates a maintenance burden and a coupling point. If the ecosystem later needs more structured discovery, the agentskills.io spec already defines the format -- we should not invent a parallel one.

### (2) How Execution-Phase Subagents Invoke External Skills

During Phase 4 execution, subagents are spawned with detailed task prompts. For subagents to invoke external skills, the **synthesis phase must include skill paths in the task prompts**.

The mechanism is straightforward:

- **In Phase 3 (Synthesis)**, when nefario builds task prompts, it includes a section like:

  ```
  ## Available Skills
  The following project skills are available for this task. Read and follow
  their instructions when they are relevant to your work:
  - content-driven-development: ~/.skills/content-driven-development/SKILL.md
    (Apply CDD process for all EDS development tasks)
  - building-blocks: ~/.skills/building-blocks/SKILL.md
    (Guide for creating/modifying AEM Edge Delivery blocks)
  ```

- The subagent reads the SKILL.md when it determines the skill is relevant to its assigned work. This follows the agentskills.io progressive disclosure model: metadata at planning time, full instructions at execution time.

- **No special invocation API is needed.** The subagent uses the Read tool to load the SKILL.md, just as any Claude Code session would. The skill's instructions become part of the subagent's working context.

This approach works because:
- Subagents already have filesystem access
- Skills are designed to be read and followed by agents (that is their entire purpose)
- No coupling from the skill back to despicable-agents is required

### (3) Minimal SKILL.md Metadata for Routing (No New Fields Needed)

The existing agentskills.io SKILL.md frontmatter is sufficient for routing:

| Field | Routing Use |
|-------|-------------|
| `name` | Unique identifier for referencing in task prompts |
| `description` | Primary routing signal -- nefario matches task descriptions against skill descriptions |

**Do not add despicable-agents-specific metadata fields.** This would create coupling from external skills back to despicable-agents, violating the issue's explicit requirement.

**Routing heuristic for nefario's META-PLAN:** When a skill's description overlaps with a despicable-agents specialist's domain, nefario should note the overlap and apply precedence rules (see below). When a skill covers a domain no specialist handles, nefario should include it as a "skill-backed capability" in the plan.

**Precedence rules when skills and specialists overlap:**

1. **External skill wins for project-specific workflows.** If a project has a `content-driven-development` skill and nefario's `frontend-minion` would normally handle "build a block," the CDD skill's phased workflow takes precedence because it encodes project-specific conventions.

2. **Specialist wins for cross-cutting concerns.** Security-minion, test-minion, and governance reviewers (lucy, margo) always run regardless of external skills. These are additive, not replaceable.

3. **Specialist yields when the skill is more specific.** If `building-blocks` skill says "use this specific decoration pattern," that overrides frontend-minion's generic React patterns. The specialist provides the execution capability; the skill provides the domain knowledge.

4. **CLAUDE.md is the tiebreaker.** If a project's CLAUDE.md explicitly designates workflow preferences, that takes final precedence.

### (4) DX for Combining install.sh + gh upskill + /nefario

The user journey has three personas. The DX must work for all three without requiring any of them to change their workflow.

**Persona A: User with existing project + existing skills, adds despicable-agents**

```bash
# User already has skills from gh upskill
cd my-project
gh upskill adobe/aem-eds-skills --all   # installs to .skills/

# Later, user installs despicable-agents
cd ~/despicable-agents && ./install.sh   # installs agents + nefario skill to ~/.claude/

# User runs nefario in their project
cd my-project
/nefario 'build a new hero block'
# nefario discovers .skills/content-driven-development, factors into plan
```

This already works with the prompt-level changes. No config merging, no conflict resolution, no special setup.

**Persona B: User starting fresh, combines both**

```bash
# Start a new project
mkdir my-site && cd my-site && git init

# Install skills
gh upskill adobe/aem-eds-skills --all     # .skills/
cd ~/despicable-agents && ./install.sh      # ~/.claude/agents + skills

# Start working
cd my-site
/nefario 'set up a new EDS site with hero and carousel blocks'
```

Again, no special integration step. The directory conventions handle separation.

**Persona C: Skill author documenting integration surface**

The skill author's only responsibility is writing a good `description` in their SKILL.md frontmatter. This is already required by the agentskills.io spec. No additional metadata, no despicable-agents-specific conventions.

**Optionally**, a skill author can add a section to their SKILL.md like:

```markdown
## Orchestration Compatibility
This skill defines a phased workflow (Phase 1: Content Modeling, Phase 2:
Implementation, Phase 3: Testing). When used with an orchestrator, the
orchestrator should respect this phased structure rather than decomposing
the work independently.
```

This is a documentation convention, not a protocol. It is a hint to any orchestrator, not just nefario.

**What install.sh should NOT do:**
- Do not scan for or merge with `.skills/` or project-local skills
- Do not generate a combined manifest or registry
- Do not modify `CLAUDE.md` to reference external skills
- Do not create `.skills/` directories

**Why this simplicity works:** The three directory tiers (`~/.claude/skills/`, `.claude/skills/`, `.skills/`) already provide namespace separation. `install.sh` writes to `~/.claude/` (user scope). `gh upskill` writes to `.skills/` (project scope). They never touch each other's directories.

### Acceptance Test Scenario Analysis

The issue's acceptance test: "User installs despicable-agents, has CDD skill, runs `/nefario 'build a new block'`, nefario references CDD's phased workflow."

With the proposed changes:

1. Phase 1 (META-PLAN): Nefario scans `.skills/`, finds `content-driven-development` (description: "Apply a Content Driven Development process..."). Recognizes this overlaps with frontend-minion's domain but is more specific.
2. Phase 2 (Specialist Planning): Nefario still consults frontend-minion (for CSS/JS expertise) but includes the CDD skill reference in the planning question: "The project uses Content Driven Development (CDD) from `.skills/content-driven-development/`. Factor this workflow into your recommendations."
3. Phase 3 (Synthesis): Task prompts include the CDD skill path. The execution agent reads the CDD SKILL.md and follows its phased process (content modeling first, then implementation, then testing) rather than jumping straight to code.
4. Phase 3.5 (Review): Lucy checks intent alignment with the CDD workflow. Margo verifies the plan respects the skill's conventions without adding unnecessary layers.

## Proposed Tasks

### Task 1: Add external skill discovery to META-PLAN prompt

**What to do:** Modify the META-PLAN prompt in nefario's AGENT.md (and the corresponding section in `skills/nefario/SKILL.md`) to include an explicit step for discovering and reasoning about external skills.

**Deliverables:**
- Updated META-PLAN instructions with a skill discovery step
- Precedence rules documented inline in the META-PLAN prompt
- Updated SYNTHESIS instructions to include skill paths in task prompts

**Dependencies:** None (can start immediately)

### Task 2: Add "Available Skills" section to execution task prompt template

**What to do:** Modify the Phase 4 execution prompt template in `skills/nefario/SKILL.md` to include an "Available Skills" section when external skills are discovered. This section lists skill names, paths, and one-line descriptions for the executing subagent to reference.

**Deliverables:**
- Updated Phase 4 task prompt template with `## Available Skills` section
- Instructions for when to include the section (only when relevant skills exist)
- Example showing how a subagent prompt references an external skill

**Dependencies:** Task 1 (needs the discovery mechanism to populate the skills list)

### Task 3: Document the integration surface for both user perspectives

**What to do:** Write documentation covering:
1. "I'm a user combining despicable-agents with external skills" -- quickstart, what works automatically, precedence rules, troubleshooting
2. "I'm a skill author who wants my skills to work with orchestrators" -- what to put in SKILL.md description, optional orchestration hints, what NOT to do

**Deliverables:**
- `docs/external-skill-integration.md` covering both perspectives
- Updated `README.md` with a section on external skill support (brief, linking to the full doc)

**Dependencies:** Tasks 1 and 2 (documentation should describe the actual implementation)

### Task 4: Add skill-aware precedence logic to nefario's delegation table

**What to do:** Add a section to nefario's AGENT.md (in Core Knowledge) documenting how to handle overlaps between external skills and built-in specialists. This is not new code -- it is prompt-level guidance for nefario's reasoning.

**Deliverables:**
- Precedence rules section in nefario's AGENT.md
- Updated delegation table with a note about external skill overrides
- Examples of yield scenarios (specialist yields to more-specific skill)

**Dependencies:** Task 1 (needs the discovery mechanism to be defined first)

### Task 5: Validate with acceptance test scenario

**What to do:** Manually run the acceptance test: install despicable-agents alongside the CDD skill set, run `/nefario 'build a new block'`, and verify that:
- Phase 1 meta-plan references CDD
- Phase 3 synthesis includes CDD skill paths in task prompts
- Execution agent follows CDD's phased workflow
- No modifications were needed to the CDD skill

**Deliverables:**
- Test run execution report (nefario report format)
- Any adjustments needed based on test results

**Dependencies:** Tasks 1, 2, 4

## Risks and Concerns

### Risk 1: Skill description quality determines routing accuracy (MEDIUM)

Nefario routes based on the `description` field in SKILL.md frontmatter. If a skill has a vague description ("Helps with PDFs"), nefario may not recognize its relevance. This is not something despicable-agents can fix -- it is an inherent property of the agentskills.io format. The mitigation is to document the importance of good descriptions in the skill-author guidance (Task 3).

### Risk 2: Context budget pressure from many skills (MEDIUM)

If a project has 15+ skills (the `~/.skills/` directory already has 15 EDS skills), including all of them in execution prompts would consume significant context. The mitigation is to include only skills relevant to each specific task, not all discovered skills. The META-PLAN step should filter to task-relevant skills, and each execution prompt should include only the skills assigned to that specific task.

### Risk 3: Skill workflows may conflict with nefario's phased model (LOW)

CDD defines its own phases (Content Modeling -> Implementation -> Testing). Nefario also has phases. If nefario tries to decompose across its own phases while CDD expects sequential execution within a single agent, there is a mismatch. The mitigation: when a skill defines a phased workflow, nefario should treat the entire workflow as a single task assigned to one agent, not decompose it across multiple specialists. The precedence rules (Task 4) should make this explicit.

### Risk 4: install.sh and gh upskill writing to different directories may confuse users (LOW)

Users may wonder why some skills are in `~/.claude/skills/` and others in `.skills/`. This is by design (user-scope vs. project-scope), but it needs clear documentation. Task 3 addresses this. The error case to watch for: a user manually copies skills between directories and creates duplicates with different versions.

### Risk 5: No automated test for the integration (MEDIUM)

The acceptance test (Task 5) is manual. If future changes to nefario's META-PLAN prompt break skill discovery, there is no automated regression test. This is acceptable for v1 -- automated testing of prompt-level behavior is genuinely hard and not worth the complexity. A manual test checklist in the documentation suffices.

## Additional Agents Needed

- **lucy**: Should review the precedence rules to ensure they align with the project's intent-preservation principles. When nefario yields to an external skill, lucy needs to verify this does not cause goal drift. Lucy is already a mandatory Phase 3.5 reviewer, but her planning input on how precedence rules should work would be valuable in Phase 2.

- **ai-modeling-minion**: Should advise on context budget management when many skills are present. How to format the "Available Skills" section in task prompts to minimize token usage while preserving routing accuracy. This is a prompt engineering concern.

No other additional specialists needed beyond what nefario would normally consult. The changes are primarily to nefario's own prompt logic, not to external systems.
