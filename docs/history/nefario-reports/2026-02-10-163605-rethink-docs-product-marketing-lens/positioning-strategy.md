# Positioning Strategy: despicable-agents

Source of truth for all documentation messaging. All README copy, doc intros,
and user-facing descriptions derive from this document.

---

## 1. Core Value Proposition

**The struggle**: Complex development tasks span security, API design, testing,
infrastructure, and documentation. A single AI session handles each dimension
at surface level. The developer either accepts shallow output or manually
coordinates separate prompts and stitches results together.

**One-sentence value proposition**:

> despicable-agents gives Claude Code a team of domain specialists, an
> orchestrator that coordinates them, and a governance layer that reviews every
> plan before execution.

**UX validation test**: Show the one-sentence value proposition to a developer
unfamiliar with the project. They should be able to answer "what does this do
and why would I use it?" within 10 seconds. If they cannot, the sentence is
failing.

**Job types addressed**:

| Job type | What it sounds like |
|----------|-------------------|
| Functional | "Get this multi-domain task done correctly the first time" |
| Emotional | "Confidence that security, testing, and docs are not forgotten" |
| Social | "Running a rigorous, professional development operation" |

---

## 2. Supporting Messages

Each message is a self-contained fact about this project. No comparative claims.
Each is verifiable by reading the codebase.

### Message 1: Strict specialist boundaries with deterministic routing

Every agent has a "Does NOT do" section naming handoff targets. Nefario's
delegation table maps each task type to exactly one primary agent. Security
advice comes from a security specialist with a dense, security-focused knowledge
base -- not from a generalist that also does frontend.

**Proof points**:
- 27 agents across 7 domain groups
- Delegation table with 40+ task-type-to-agent mappings (`nefario/AGENT.md`)
- "Does NOT do" section in every agent prompt (`minions/*/AGENT.md`)
- Decision 2 in `docs/decisions.md`: strict non-overlapping boundaries

### Message 2: Nine-phase orchestration from planning through post-execution verification

Complex tasks are not split and dispatched. Specialists contribute to the plan
in parallel, conflicts are resolved in synthesis, cross-cutting concerns are
verified, and post-execution phases run code review, tests, and documentation
updates automatically.

**Proof points**:
- Nine documented phases (`docs/orchestration.md`)
- Parallel specialist consultation in Phase 2
- Synthesis resolves inter-specialist conflicts in Phase 3
- Post-execution: code review (Phase 5), test execution (Phase 6), deployment
  (Phase 7), documentation (Phase 8)
- "Dark kitchen" pattern: post-execution runs silently, surfaces only failures

### Message 3: Governance reviews every plan before execution

Two governance agents -- Lucy (intent alignment, convention enforcement) and
Margo (simplicity, YAGNI) -- review every plan alongside security, testing,
UX, and documentation reviewers. Plans that drift from what you asked for are
caught. Over-engineering is flagged. This review is mandatory, not optional.

**Proof points**:
- 6 mandatory reviewers in Phase 3.5 Architecture Review
- APPROVE / ADVISE / BLOCK verdict system with 2-round resolution cap
- Decision 10 in `docs/decisions.md`: architecture review rationale
- Decision 15: Phase 3.5 is non-skippable (only user can override)

### Message 4: Install once, use everywhere

Agents are generic domain specialists with no ties to any specific project.
One `./install.sh` symlinks all 27 agents to `~/.claude/agents/` so they are
available in every Claude Code session. Project context belongs in the
project's CLAUDE.md, not in agent prompts.

**Proof points**:
- Symlink deployment (`install.sh`, Decision 7)
- `memory: user` scope, not project-scoped (Decision 5)
- Apache 2.0 license, no PII, no proprietary data
- Edits are immediately live without redeployment

### Message 5: Readable, auditable, forkable

Every agent is a single Markdown file with YAML frontmatter and a readable
system prompt. RESEARCH.md files show the domain research backing each prompt.
The design decisions log documents every architectural tradeoff with rejected
alternatives and rationale. No black-box orchestration.

**Proof points**:
- AGENT.md files: YAML frontmatter + system prompt (`{agent}/AGENT.md`)
- RESEARCH.md files: domain research per agent (`{agent}/RESEARCH.md`)
- 25 documented design decisions with alternatives (`docs/decisions.md`)
- `the-plan.md` as canonical spec, human-edited

---

## 3. Messaging Hierarchy for README

Sections are ordered by adoption-first logic: value before mechanism, examples
before explanation, try-it before architecture.

### Section order and content rules

| # | Section | Purpose | Lines | Content rule |
|---|---------|---------|-------|-------------|
| 1 | Title + badge + value prop | Positioning in 10 seconds | 3-5 | One sentence from Section 1 above. Badge stays. |
| 2 | Examples showing value | "What can I do with this?" | 12-18 | Outcome-focused examples. Lead with the problem being solved ("Need to review auth?" not "@security-minion review this"). Show single-agent and orchestrated examples. /nefario is the climax. |
| 3 | Install | Remove friction | 5-7 | Two commands. One-line prerequisite (Claude Code). Uninstall note. |
| 4 | Try it | Bridge to first use | 10-15 | One single-agent example, one /nefario example. Show what happens after you type. Outcome-focused: what do you get back? |
| 5 | How it works | Mental model | 5-8 | Four tiers in scannable form. Governance as benefit, not as tier to learn. Link to docs/using-nefario.md. |
| 6 | Agents | Reference lookup | 8-12 | Compact group summary outside `<details>`. Full roster inside collapsible. Agent names link to docs/agent-catalog.md. |
| 7 | Limitations | Trust through honesty | 4-6 | From Section 5 below. Brief, factual. |
| 8 | Documentation | Onward paths | 6-8 | Two subsections: "Using" (using-nefario, agent-catalog) and "Contributing" (architecture, decisions). |
| 9 | Contributing | Community norms | 3-5 | English, Apache 2.0, boundaries, the-plan.md as source of truth. |
| 10 | License | Legal | 1-2 | Apache 2.0 link. |

**Total target**: 100-130 lines.

### Key principles for README content

- **Teaser + link**: README states briefly, docs explain fully. The authoritative
  version lives in docs/. README points to it.
- **No inline roster**: The 27-agent table goes inside a collapsible `<details>`
  element or links to docs/agent-catalog.md. Most readers do not need the full
  list on first visit.
- **Examples are outcome-focused**: "Need to validate your auth flow?" then the
  command, then what you get back. Not command-first.
- **Governance is a benefit**: "Every plan is reviewed for intent alignment and
  over-engineering before execution" -- not "there are two governance agents in
  Tier 2b."

---

## 4. Tone Guide for OSS Documentation

Write like a senior engineer describing their team's architecture to another
senior engineer. Specific, factual, slightly proud of the engineering, willing
to state tradeoffs.

### Do

- **State specific, verifiable facts.** "6 mandatory reviewers check every plan
  before execution." Verifiable by reading `nefario/AGENT.md`.
- **Show, don't tell.** A code example block proves value without claiming it.
  Prefer concrete invocations over descriptions of capability.
- **Use the project's vernacular.** The Despicable Me naming (Gru, Nefario,
  minions, Lucy, Margo) is distinctive and memorable. Use it naturally.
- **Let architecture speak.** The nine-phase process, governance layer, and 25
  documented design decisions are strong on their own. State them plainly.
- **Acknowledge tradeoffs.** "Orchestration adds planning overhead. For single-
  domain tasks, call the specialist directly." Honesty builds credibility.
- **Use precise terminology.** "Specialists" over "AI agents." "Orchestrator"
  over "coordinator." "Governance" over "quality layer." "Nine-phase process"
  over "pipeline."

### Do not

- **No superlatives.** Never: "best," "most powerful," "comprehensive,"
  "revolutionary," "game-changing," "next-generation."
- **No marketing adjectives without proof.** "Blazingly fast orchestration" with
  no benchmarks is worse than saying nothing.
- **No comparative claims against competitors.** "Unlike other agent
  collections..." goes stale and sounds defensive. Position on what this project
  IS.
- **No urgency or hype language.** No "revolutionary," "cutting-edge," or
  "unlock the power of."
- **No inflated scale.** "27 agents" is enough. Not "massive specialist team" or
  "army of experts."
- **No unverifiable claims.** If a reader cannot verify it by reading the
  codebase within 60 seconds, remove it or add proof.
- **No consumer marketing tactics.** No countdown timers, urgency language,
  social proof numbers without context, or "limited time" anything.

### Verification rule

For every sentence in user-facing documentation, ask: "Can a developer verify
this claim by reading the codebase?" If not, either add a proof point (file
path, decision number, code reference) or remove the claim.

---

## 5. Current Limitations (State Transparently)

These belong in the README as a brief, honest section. Stating limitations
builds trust with developers who will discover them anyway.

1. **Claude Code dependency.** Agents require [Claude Code](https://docs.anthropic.com/en/docs/claude-code)
   as the runtime. They are AGENT.md files consumed by Claude Code's agent
   loading mechanism, not standalone tools.

2. **No subagent nesting.** Claude Code does not allow subagents to spawn other
   subagents. The orchestration works around this, but it means agents cannot
   delegate to each other during execution -- only the main session dispatches.

3. **Context window pressure on large orchestrations.** Complex tasks with many
   specialists can approach context limits. The project uses scratch files and
   compaction checkpoints to manage this, but very large plans may require manual
   compaction. (Decision 21 in `docs/decisions.md`.)

4. **97% vibe-coded.** The agents were built with AI assistance. The research is
   real, the architecture is deliberate, but the prose in system prompts was
   generated and refined, not hand-written from scratch. The badge says it
   upfront.

---

## Usage Notes

This document is a process artifact for the documentation rewrite. It is
referenced by all downstream tasks (README, using-nefario.md, agent-catalog.md,
Phase 8 spec). Keep it lean and operational. Update it when the project's
positioning changes (new differentiators, new limitations, shifted competitive
landscape).
