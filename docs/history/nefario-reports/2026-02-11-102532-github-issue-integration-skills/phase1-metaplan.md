# Meta-Plan: Add GitHub Issue Integration to /despicable-prompter and /nefario Skills

## Task Summary

Both `/despicable-prompter` and `/nefario` skills need to accept `#<n>` as the first argument to fetch a GitHub issue and use its body as context. The prompter additionally writes its output back to the issue (updating body and title). Trailing text after the issue number is appended to the issue body before processing.

## Scope

- **In**: `skills/despicable-prompter/SKILL.md`, `skills/nefario/SKILL.md`
- **Out**: AGENT.md files, install.sh, docs, the-plan.md

## Analysis

This task involves modifying two SKILL.md files that define how Claude Code skills parse their arguments and execute. The changes are:

1. **Argument parsing**: Both skills need a new argument parsing section that detects `#<n>` as the first token, fetches the issue via `gh issue view`, and handles errors (missing `gh`, non-existent issue).
2. **Prompter write-back**: `/despicable-prompter` needs logic to update the issue body with the generated brief (minus the `/nefario` prefix) and update the title to the brief's first line.
3. **Trailing text handling**: Both skills need to handle optional trailing text after `#<n>`, appending it to the issue body before processing.
4. **Error handling**: Clear error messages for non-existent issues and missing `gh` CLI.

The task is scoped to two markdown files containing natural-language instructions (not code). The skills are "prompt-level" -- they instruct Claude Code how to behave, not executable code. This means the "implementation" is writing clear, unambiguous instructions in SKILL.md that Claude Code will follow.

## Planning Consultations

### Consultation 1: CLI Argument Parsing and Error UX

- **Agent**: devx-minion
- **Planning question**: The skills currently use free-text argument passing (`argument-hint: "<rough idea or task description>"`). We need to add structured argument parsing where `#<n>` as the first token triggers issue-fetch mode, with optional trailing text. How should the argument parsing section be structured in SKILL.md to handle: (a) `#42` alone, (b) `#42 also consider caching`, (c) plain text (current behavior), (d) empty input? What error message format and content should be used for `gh` CLI unavailability and non-existent issues, following CLI UX best practices?
- **Context to provide**: Both SKILL.md files, especially the existing argument parsing in despicable-lab's SKILL.md (lines 16-24) as a pattern, and the empty-input edge case in despicable-prompter (lines 139-153).
- **Why this agent**: devx-minion specializes in CLI design, argument parsing patterns, and error message clarity. The core design challenge here is how to cleanly layer structured argument parsing (`#<n>`) onto skills that currently expect free-text input, and how to provide good error UX.

### Consultation 2: GitHub API Integration Pattern

- **Agent**: iac-minion
- **Planning question**: The skills need to use `gh issue view` to fetch issue data and `gh issue edit` to write back. What is the most robust `gh` CLI invocation pattern for: (a) fetching issue title and body separately or together, (b) updating issue body and title, (c) detecting whether `gh` is installed and authenticated, (d) handling repo context (should we assume we're in a git repo with a remote, or detect it)? Consider failure modes: rate limiting, network errors, auth expiry. What format flags (`--json`, `--jq`, `--template`) produce the most reliable parseable output?
- **Context to provide**: The nefario SKILL.md already uses `gh pr create` (line 1025) so there is precedent for `gh` CLI usage. The git repo detection pattern (line 112-117) is also relevant.
- **Why this agent**: iac-minion covers GitHub Actions, CI/CD tooling, and infrastructure CLI patterns. The `gh` CLI integration is essentially an infrastructure concern -- reliable subprocess invocation, output parsing, error handling, and authentication detection.

## Cross-Cutting Checklist

- **Testing**: EXCLUDE. The deliverables are two SKILL.md files containing natural-language instructions, not executable code. There is no test infrastructure for SKILL.md content (it's prompt engineering, not software). Testing would happen manually by invoking the skills.

- **Security**: INCLUDE for planning. The `gh` CLI invocation pattern needs review: (a) the `#<n>` input could be injected with shell metacharacters (e.g., `#42; rm -rf /`), (b) issue bodies fetched from GitHub could contain prompt injection attempts, (c) the write-back to GitHub issues should not leak secrets from the orchestration context. Planning question below.

  - **Agent**: security-minion
  - **Planning question**: The skills will parse `#<n>` from user input and pass it to `gh issue view <n>`. What input validation is needed to prevent shell injection via the issue number? Additionally, issue bodies fetched from GitHub are untrusted content -- what prompt injection defenses should the SKILL.md instructions include when using issue body text as task descriptions? Finally, the prompter writes a generated brief back to the issue -- what sanitization is needed to prevent leaking session context (secrets, file paths, internal state) into the public GitHub issue?
  - **Context to provide**: Both SKILL.md files, the existing prompt injection defense in despicable-prompter (line 37), the existing secret scanning patterns in nefario SKILL.md (lines 1019-1023, 1156-1158).

- **Usability -- Strategy**: INCLUDE (always). The issue integration changes the user journey for both skills -- from "copy issue text, paste into skill" to "reference issue number directly". This is a workflow simplification that needs journey coherence review.

  - **Agent**: ux-strategy-minion
  - **Planning question**: The `#<n>` integration creates a new user journey: issue tracker -> skill invocation -> (optionally) issue update. For `/despicable-prompter`, the loop closes by writing back to the issue. For `/nefario`, it's one-directional (read only). (a) Is the write-back behavior (updating issue body AND title) the right default, or should it be opt-in? Users might not expect their issue to be modified. (b) Should the prompter's write-back include any visual marker in the issue body indicating it was auto-generated? (c) Is the trailing text append behavior intuitive ("append to issue body before processing") or would a different merge strategy be less surprising? (d) Should `/nefario` also write status back to the issue (e.g., a comment when orchestration starts)?
  - **Context to provide**: Both SKILL.md files, the success criteria from the task.

- **Usability -- Design**: EXCLUDE. No user-facing interfaces are being produced. These are CLI skill instructions.

- **Documentation**: INCLUDE (always). The `argument-hint` in both SKILL.md frontmatters needs updating, and the new behavior should be documented within the SKILL.md files themselves. Since the task scope excludes external docs, the documentation concern is about the self-documenting quality of the SKILL.md changes.

  - **Agent**: software-docs-minion
  - **Planning question**: Both skills gain a new invocation mode (`#<n>`). How should this be documented within the SKILL.md files? Should the `argument-hint` frontmatter be updated to show the new syntax (e.g., `"[#issue] <task description>"`)? Should examples be added showing the issue-integration flow? The task scope excludes external docs, but the SKILL.md files ARE the documentation for these skills.
  - **Context to provide**: Both SKILL.md files, the despicable-lab SKILL.md as a pattern for argument documentation.

- **Observability**: EXCLUDE. No runtime components, services, or APIs are being created. The skills are prompt-level instructions executed within Claude Code sessions.

## Anticipated Approval Gates

Given the scope (two SKILL.md files, no code, no schema, no API contracts), I anticipate **zero mandatory gates**. Here is the analysis:

| Deliverable | Reversibility | Blast Radius | Gate? |
|-------------|---------------|--------------|-------|
| SKILL.md argument parsing section | Easy (text edit) | Low (0 dependents within plan) | NO |
| SKILL.md write-back logic | Easy (text edit) | Low (0 dependents) | NO |
| Error message format | Easy (text edit) | Low (0 dependents) | NO |

All deliverables are easy to reverse (editing markdown instructions) and have no downstream dependents within the plan. The two SKILL.md files are independent of each other -- changes to one don't constrain changes to the other.

The **one judgment call** is the UX of the write-back behavior (should it be default or opt-in?). This could warrant a gate if the ux-strategy-minion raises it as ambiguous. But the task's success criteria are explicit ("updates the issue body with the brief... and updates the issue title"), so the user has already decided.

## Rationale

Three specialists are consulted for planning:

1. **devx-minion**: Core expertise -- argument parsing design, error message UX, CLI patterns. This is fundamentally a developer experience challenge: how to layer structured input (`#<n>`) onto free-text skills cleanly.

2. **iac-minion**: The `gh` CLI integration pattern needs infrastructure expertise -- reliable invocation, output parsing, failure mode handling, auth detection. This is not trivial prompt-level work; getting `gh` invocations right requires knowing the CLI's flags, output formats, and edge cases.

3. **security-minion** (cross-cutting): Shell injection via issue number, prompt injection via issue body, and secret leakage via write-back are all real risks that need defense patterns in the SKILL.md instructions.

4. **ux-strategy-minion** (cross-cutting, always): Journey coherence review. The write-back behavior and trailing-text merge strategy need usability assessment.

5. **software-docs-minion** (cross-cutting, always): The SKILL.md files are self-documenting -- they ARE the documentation for these skills. The new invocation mode needs to be clearly documented within them.

Agents NOT consulted:
- **ai-modeling-minion**: Not needed. The prompting patterns are straightforward instruction additions, not complex prompt engineering.
- **mcp-minion**: Not relevant. No MCP protocol work.
- **frontend-minion**: No UI.
- **test-minion**: No executable test targets. Manual testing only.
- **observability-minion**: No runtime components.
- **ux-design-minion / accessibility-minion**: No UI.
