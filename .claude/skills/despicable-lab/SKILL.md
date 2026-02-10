---
name: despicable-lab
description: >
  Nefario's Laboratory -- rebuild agents whose specs have changed in
  the-plan.md. Use when you want to regenerate one or more agents, or check
  which agents are outdated and need rebuilding.
argument-hint: [agent-name ...] | --check | --all
---

# The Laboratory

You are Dr. Nefario's lab assistant. Your job is to build and rebuild agents
from the specs in `the-plan.md`.

## Argument Parsing

Arguments: `[agent-name ...] | --check | --all`

- **No arguments or `--check`**: Check all agents for outdated versions. Report
  a table of agent name, current version, spec version, and status. Do NOT
  rebuild unless asked.
- **Agent names** (e.g., `mcp-minion security-minion`): Regenerate only the
  named agents, even if they are already up-to-date.
- **`--all`**: Force-rebuild all 27 agents regardless of version.

## Version Check

```
For each agent directory in gru/, nefario/, lucy/, margo/, minions/*/:
  - Read AGENT.md frontmatter -> x-plan-version
  - Read the-plan.md spec -> spec-version (default "1.0" if not yet annotated)
  - If x-plan-version < spec-version or AGENT.md doesn't exist:
      -> mark for regeneration
  - Report: table of agent name, current version, spec version, status
```

After version check, also run **overlay drift detection**:

```bash
./validate-overlays.sh --summary
```

This checks whether agents with overrides (`x-fine-tuned: true`) have drifted from their expected merge state. If drift is detected, append the affected agents to the status report with **drift details**.

Example:
```
AGENT           VERSION    SPEC       STATUS
-------------------------------------------
nefario         1.4        1.4        ✓ up-to-date
gru             1.0        1.0        ✓ up-to-date
...
-------------------------------------------
DRIFT DETECTED: 1 agent

nefario: 10 issues
  - Run ./validate-overlays.sh nefario for details
  - Run /despicable-lab nefario to regenerate and re-merge
```

## File Locations

| Agent Type | Spec Location | Build Location |
|------------|---------------|----------------|
| gru | the-plan.md -> "The Boss" | `gru/AGENT.md` |
| nefario | the-plan.md -> "The Foreman" | `nefario/AGENT.md` |
| lucy | the-plan.md -> "Governance: Lucy" | `lucy/AGENT.md` |
| margo | the-plan.md -> "Governance: Margo" | `margo/AGENT.md` |
| *-minion | the-plan.md -> "Minions: *" | `minions/<name>/AGENT.md` |

## Regeneration Process

For each agent to regenerate, run a two-step pipeline. When multiple agents
need rebuilding, run all pipelines in parallel.

### Step 1 -- Research (model: sonnet)

1. Read the agent's spec from `the-plan.md` (the canonical source of truth).
2. Search the internet for best practices, established patterns, and prior art
   in the agent's domain. Focus on the areas listed in the spec's "Research
   focus" section.
3. Search past conversation history at `~/.claude/projects/` for relevant
   patterns. Extract only generic patterns, not project-specific data or PII.
4. If `RESEARCH.md` already exists, preserve still-relevant content and add new
   findings. If it doesn't exist, create it.
5. Write `RESEARCH.md` in the agent's subdirectory, organized by topic with
   sources cited.

### Step 2 -- Build (model: per agent spec)

1. Read `the-plan.md` for the agent's spec: frontmatter pattern, system prompt
   structure (Identity, Core Knowledge, Working Patterns, Output Standards,
   Boundaries).
2. Read the completed `RESEARCH.md`.
3. **For agents WITHOUT overrides** (no `AGENT.overrides.md`):
   - Write `AGENT.md` following the frontmatter pattern. The system prompt should
     encode the essential knowledge from RESEARCH.md -- dense, actionable,
     no fluff.
   - Set frontmatter values:
     - `model` to the value specified in the agent's **Model** field
     - `x-plan-version` to the current spec version
     - `x-build-date` to today's date
4. **For agents WITH overrides** (`AGENT.overrides.md` exists):
   - Write `AGENT.generated.md` (same as above, but to the `.generated.md` file)
   - **STOP** -- do NOT write `AGENT.md` directly
   - **Manual merge required**: The human user must manually merge
     `AGENT.generated.md` + `AGENT.overrides.md` → `AGENT.md`
   - Report: "Agent regenerated. Manual merge required (see docs/agent-anatomy.md)"

### Step 3 -- Cross-check

After all agents are built:
- Verify that "Does NOT do" sections create clean handoff points with
  neighboring agents
- Check that delegation table entries in `the-plan.md` match agent remits
- No overlapping responsibilities between agents

### Step 4 -- Report

For each regenerated agent, summarize:
- What changed in the spec since last build
- Key research findings that informed the new system prompt
- Any boundary adjustments made during cross-check

## Constraints

- Do NOT modify `the-plan.md` -- it is the source of truth, edited by humans
- Do NOT regenerate agents that are already up-to-date (unless explicitly asked
  or `--all` is used)
- Preserve existing `RESEARCH.md` content where still relevant
- All output in English
- No PII, no project-specific data -- agents must remain publishable
- Check `CLAUDE.local.md` for technology preferences that should inform research
  depth and emphasis
