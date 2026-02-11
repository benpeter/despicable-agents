# Meta-Plan: Document Status Line Setup

## Task Analysis

The task is to create a short user-facing guide in `docs/` explaining how to
configure the Claude Code status line to show nefario orchestration status. This
is a pure documentation task -- no code changes, no infrastructure, no UI.

**Key implementation details to document** (gathered from codebase):
- SKILL.md writes a sentinel file at `/tmp/nefario-status-${CLAUDE_SESSION_ID}`
  during Phase 1 and cleans it up at wrap-up step 11
- The user's `~/.claude/settings.json` has a `statusLine` command that reads
  JSON from stdin, extracts workspace/model/context info, then checks for the
  sentinel file using `${CLAUDE_SESSION_ID}` env var
- Session isolation: each Claude Code session has its own `CLAUDE_SESSION_ID`,
  so multiple sessions each see only their own nefario status
- The sentinel file contains a truncated task summary (max 48 chars + "...")
- `chmod 600` restricts sentinel file access to the owning user

**Existing documentation surface**:
- `docs/using-nefario.md` -- user-facing guide, currently has no status line section
- `docs/deployment.md` -- covers settings.json for hooks but not statusLine
- `docs/architecture.md` -- links to sub-documents; would need a row if a new doc is created

**Scope boundaries**:
- IN: Step-by-step setup guide in `docs/`, explaining settings.json statusLine
  command and CLAUDE_SESSION_ID-based session isolation
- OUT: Customization options, modifying the status line implementation,
  changes to nefario SKILL.md

## Planning Consultations

### Consultation 1: User documentation structure and content

- **Agent**: user-docs-minion
- **Planning question**: Given the existing `docs/using-nefario.md` (a user
  workflow guide) and `docs/deployment.md` (installation and settings.json
  reference), where should the status line setup guide live? Should it be a new
  standalone doc (e.g., `docs/status-line-setup.md`), a new section appended to
  `docs/using-nefario.md`, or a new section in `docs/deployment.md`? Consider:
  the guide must be completable in under 2 minutes, covers a single `settings.json`
  field, and explains a session-scoped mechanism. What structure and headings
  would make this guide maximally scannable?
- **Context to provide**: `docs/using-nefario.md` (full file),
  `docs/deployment.md` (full file), `docs/architecture.md` (sub-documents table),
  the user's current `~/.claude/settings.json` statusLine command, and the
  SKILL.md sentinel file sections (lines 281-287, 1128-1131)
- **Why this agent**: user-docs-minion specializes in user guides, tutorials,
  and information architecture for end-user documentation. The primary challenge
  here is placement and structure, not content complexity.

## Cross-Cutting Checklist

- **Testing**: EXCLUDE. This task produces only a markdown documentation file.
  No executable code, no configuration changes, no infrastructure. There is
  nothing to test.
- **Security**: EXCLUDE. The guide documents an existing mechanism (sentinel
  file with chmod 600, session-scoped paths). It does not introduce new attack
  surface, handle auth, process user input, or manage secrets. The security
  properties of the sentinel file are already established.
- **Usability -- Strategy**: INCLUDE for planning. The guide itself is a user
  experience artifact. ux-strategy-minion should assess whether the guide's
  structure serves the user's job-to-be-done (quickly configuring status line
  visibility) with minimal cognitive load.

  **Planning question for ux-strategy-minion**: The user's job is "I want to
  see what nefario is doing in my terminal status bar." The guide must get them
  from zero to working in under 2 minutes. What is the optimal information
  sequence? Should the guide lead with a "paste this" snippet and explain after,
  or explain the mechanism first? How should session isolation be presented --
  as a feature highlight or as background context? What level of "why" is
  appropriate for a 2-minute setup guide?

- **Usability -- Design**: EXCLUDE. No user-facing interface is being produced.
  The deliverable is a markdown document, not UI.
- **Documentation**: INCLUDE -- user-docs-minion is already the primary
  consultant (Consultation 1 above). software-docs-minion is not needed because
  this is a user-facing setup guide, not an architectural or API surface change.
- **Observability**: EXCLUDE. No runtime components, services, or APIs are
  being created.

## Anticipated Approval Gates

**None.** This task produces a single documentation file. It is:
- Easy to reverse (additive markdown, no dependencies)
- Low blast radius (no downstream tasks depend on it)
- Clear best practice (document an existing feature)

Per the gate classification matrix, this is "Easy to Reverse + Low Blast Radius"
= NO GATE.

## Rationale

This is a straightforward documentation task with one primary question: where
and how to structure the guide. Two specialists add planning value:

1. **user-docs-minion** (primary) -- Determines optimal placement, structure,
   and content organization. This is the core planning question.
2. **ux-strategy-minion** (cross-cutting, mandatory) -- Validates that the
   guide's information architecture serves the user's actual job-to-be-done
   with minimal friction.

No other specialists are needed for planning. The content itself is well-defined
(the implementation is already complete in SKILL.md and settings.json), so the
planning challenge is purely about documentation craft, not domain expertise.

## Scope

**Overall goal**: Create a short, actionable guide that enables users to
configure their Claude Code status line to display nefario orchestration
status during active sessions.

**In scope**:
- A markdown guide in `docs/` with step-by-step instructions
- Explanation of the `settings.json` statusLine command
- Explanation of `CLAUDE_SESSION_ID`-based session isolation
- Any necessary cross-references from existing docs (architecture.md,
  using-nefario.md, deployment.md)

**Out of scope**:
- Status line customization options beyond the basic setup
- Modifications to the status line implementation (SKILL.md, settings.json)
- Changes to sentinel file behavior
- Other skills' status line integration
