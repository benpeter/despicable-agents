# Phase 1: Meta-Plan — /despicable-statusline Skill

## Task Summary

Create a `/despicable-statusline` skill that configures the Claude Code status
line to include nefario orchestration phase as the last element. The skill reads
the user's existing `~/.claude/settings.json` statusLine config, preserves
everything, and appends a nefario status snippet. Idempotent; creates a sensible
default if no statusLine exists. Follows existing extension patterns (claude-skills
repo, symlinked to `~/.claude/skills/`).

## Context Gathered

- **Existing skills pattern**: Skills live in `~/github/benpeter/claude-skills/`,
  symlinked to `~/.claude/skills/<name>`. Each skill has a `SKILL.md` with YAML
  frontmatter (`name`, `description`) and markdown instructions.
- **Current statusLine config** (`~/.claude/settings.json`): A shell command that
  pipes JSON input through `jq`, extracts dir/model/context/session_id, writes
  `$sid` to `/tmp/claude-session-id`, and conditionally reads
  `/tmp/nefario-status-$sid` to append `| $ns`.
- **Nefario status write mechanism**: The nefario SKILL.md (Phase 1) writes
  `echo "$summary" > /tmp/nefario-status-$SID` and cleans up at session end with
  `rm -f /tmp/nefario-status-$SID`. This is OUT OF SCOPE for changes.
- **Reference skills**: `obsidian-tasks`, `recap`, `despicable-prompter` -- all
  follow the same SKILL.md pattern with varying complexity.
- **The skill's core action**: Modify a JSON file (`settings.json`) with careful
  preservation of existing config. This is JSON manipulation via shell/jq within
  a Claude Code skill definition.

## Planning Consultations

### Consultation 1: Status Line Config Safety

- **Agent**: devx-minion
- **Planning question**: The skill needs to modify `~/.claude/settings.json`,
  which is a critical user config file. What is the safest approach for:
  (a) reading and parsing the existing `statusLine` command string,
  (b) detecting whether the nefario snippet is already present (idempotency),
  (c) appending the nefario snippet without breaking existing shell logic
  (the current value is a complex one-liner with semicolons, pipes, and
  conditionals), and (d) creating a sensible default statusLine for users
  who have none? Should the skill use `jq` for JSON manipulation, or is
  there a safer approach? What error handling is needed (backup, validation,
  rollback)?
- **Context to provide**: Current `~/.claude/settings.json` contents (especially
  the statusLine command), the SKILL.md pattern from existing skills, the
  nefario status file convention (`/tmp/nefario-status-$sid`).
- **Why this agent**: devx-minion specializes in CLI design, configuration files,
  and developer tooling. The core challenge is safe JSON config file manipulation
  with idempotency -- squarely in their domain.

### Consultation 2: UX Strategy Review

- **Agent**: ux-strategy-minion
- **Planning question**: The skill modifies a user's status line configuration.
  What is the right user journey for this? Should the skill show a preview of
  what will change before applying? Should it ask for confirmation, or is a
  no-confirmation approach acceptable given the skill is explicitly invoked?
  What should the default statusLine look like for users who have none -- what
  elements are most useful (dir, model, context%, nefario status)? How should
  the skill communicate success/failure?
- **Context to provide**: The current statusLine format, the SKILL.md invocation
  pattern (user explicitly runs `/despicable-statusline`), the fact that the
  skill modifies `~/.claude/settings.json`.
- **Why this agent**: Every plan needs journey coherence review. This skill
  changes user-visible configuration, and the interaction design (preview,
  confirmation, defaults) directly affects user trust.

## Cross-Cutting Checklist

- **Testing** (test-minion): EXCLUDE for planning. The deliverable is a single
  SKILL.md file -- a prompt, not executable code. There is no testable runtime
  artifact. The skill instructs Claude Code to run shell commands at invocation
  time, making automated testing impractical. Testing would be manual
  verification of the skill's behavior.
- **Security** (security-minion): EXCLUDE for planning. The skill modifies a
  local config file with no network surface, no auth, no user input beyond
  the explicit invocation. The file path is hardcoded (`~/.claude/settings.json`).
  The nefario snippet reads a file from `/tmp/` which is already the established
  pattern. Low attack surface. Standard advice (backup before modify, validate
  JSON) can be incorporated without specialist consultation.
- **Usability -- Strategy** (ux-strategy-minion): INCLUDE -- see Consultation 2
  above. The skill changes user-visible config; interaction design matters.
- **Usability -- Design** (ux-design-minion / accessibility-minion): EXCLUDE.
  No user-facing interface is produced. The skill outputs text to the CLI; no
  visual design or accessibility concerns apply.
- **Documentation** (software-docs-minion / user-docs-minion): EXCLUDE for
  planning. The SKILL.md IS the documentation (it contains the skill's
  description and instructions). No separate docs artifact is needed. The
  existing claude-skills README may need a line added, but that is a trivial
  post-execution concern, not a planning input.
- **Observability** (observability-minion / sitespeed-minion): EXCLUDE. No
  runtime component, service, or API is produced.

## Anticipated Approval Gates

**None anticipated.** This is a single-file deliverable (SKILL.md) that is:
- Easy to reverse (delete the file and symlink)
- Low blast radius (no downstream dependents)
- Clear best practice (follows established skill pattern)

The execution plan gate (standard approval before execution) is the only
gate needed.

## Rationale

This task is a focused developer tooling problem: create a skill definition
that safely modifies a JSON config file. Two specialists are consulted:

1. **devx-minion** -- the core technical challenge is config file manipulation
   with idempotency. This is their primary domain (configuration files, CLI
   design, developer experience).
2. **ux-strategy-minion** -- mandatory cross-cutting review. The skill changes
   user-visible config, and the interaction design (preview vs. silent apply,
   default elements, success messaging) needs coherence review.

Other specialists are excluded because the task has no network surface
(security), no runtime component (observability), no UI (ux-design,
accessibility), and produces a self-documenting artifact (documentation is
the deliverable itself).

## Scope

- **In scope**: SKILL.md file that modifies `~/.claude/settings.json` statusLine
  config; sensible defaults for users without existing statusLine; idempotency
  detection; symlink setup instructions.
- **Out of scope**: Changes to the `/tmp/nefario-status` write mechanism, changes
  to nefario's SKILL.md, statusline script styling, changes to the nefario
  agent or any other agent.

## External Skill Discovery

No project-local skills (`.claude/skills/`, `.skills/`) are relevant to this
task. The `/despicable-lab` skill exists in the project but is for agent
rebuilding, not config management.
