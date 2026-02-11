# Agent Anatomy

[< Back to Architecture Overview](architecture.md)

Each agent in despicable-agents consists of two primary files: a deployable agent file (`AGENT.md`) and a research backing file (`RESEARCH.md`).

## AGENT.md Structure

The deployable agent file has two parts: YAML frontmatter and a Markdown system prompt body.

### Frontmatter Schema

```yaml
---
name: <agent-name>
description: >
  <2-4 sentence description. First sentence = what the agent IS.
  Remaining sentences = when to delegate to it. Include "Use proactively"
  where appropriate.>
model: opus | sonnet
memory: user
x-plan-version: "<major>.<minor>"
x-build-date: "YYYY-MM-DD"
---
```

| Field | Required | Purpose |
|-------|----------|---------|
| `name` | yes | Agent identifier, matches directory name |
| `description` | yes | Used by Claude Code to decide when to delegate to this agent |
| `model` | yes | `opus` for strategic/deep reasoning, `sonnet` for execution/cost-efficiency |
| `memory` | yes | Always `user` -- enables persistent learning across conversations |
| `x-plan-version` | yes | Spec version this build is based on (from `the-plan.md`) |
| `x-build-date` | yes | Date this AGENT.md was last generated |
| `tools` | no | Restricts available tools (strict allowlist). Omit to grant full access. Most agents omit this field |

### System Prompt Structure

The Markdown body below the frontmatter follows a five-section template.

**Identity** -- One paragraph stating who the agent is and their core mission. Sets the agent's perspective and primary goal.

**Core Knowledge** -- Deep domain expertise organized by topic. The densest section, encoding essential knowledge distilled from RESEARCH.md. Uses subsections with descriptive headers.

**Working Patterns** -- How the agent approaches tasks. Decision trees, common workflows, task-oriented structure answering "when asked to X, do Y."

**Output Standards** -- What good output looks like for this agent. Format specifications, quality criteria, structural expectations.

**Boundaries** -- What this agent does NOT do, with explicit delegation targets. Clear handoff triggers to other specialists. Collaboration patterns with supporting agents.

The five sections appear in order. Some agents add domain-specific sections between Identity and Core Knowledge (for example, nefario has an "Invocation Modes" section), but the five listed above are the universal scaffold.

## RESEARCH.md Structure

The research backing file contains comprehensive domain research organized by topic. It is not deployed to Claude Code -- it serves as the knowledge base from which the system prompt is distilled.

**Content**: Best practices, established patterns, prior art, framework comparisons, tool evaluations, common pitfalls, benchmark data, RFC specifications, API design patterns, industry standards. The focus is actionable knowledge, not academic overviews.

**Sources**: Internet research (WebSearch/WebFetch), official documentation, past conversation history mined for generic patterns, open-source agent prompts examined for structural patterns, and domain-specific research areas listed in `the-plan.md`.

**Organization**: Topic-based sections with citations. Pragmatic, production-oriented perspective. The goal is to provide enough depth that the Build step can distill a dense, accurate system prompt without inventing information.
