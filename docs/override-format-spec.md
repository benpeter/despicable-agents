# Override Format Specification

[< Back to Architecture Overview](architecture.md)

## Overview

The directive-based override format provides fine-grained control over how hand-tuned customizations merge with generated agent content. Each override is expressed as a directive block with YAML metadata declaring what to target, what operation to perform, and why the override exists.

**Key properties:**
- Deterministically parseable without LLM interpretation
- Supports multiple operations (replace, append, prepend, insert-before, insert-after, frontmatter modification)
- Clear error handling for edge cases (missing targets, content injection, multiple directives on same target)
- Human-readable with explicit rationale for each override

This format replaces the current H2-heading-match section replacement mechanism documented in agent-anatomy.md, which is coarse-grained and fragile.

## File Structure

An override file consists of three parts:

```markdown
---
# Top-level YAML frontmatter (file metadata)
agent: <agent-name>
base-version: "<major>.<minor>"
last-reviewed: "YYYY-MM-DD"
---

# Preamble (optional human-readable notes)
These overrides document hand-tuned customizations...

<!-- DIRECTIVE: <operation>
target: <heading-path>
reason: <why this override exists>
-->
<content to be merged>
<!-- END DIRECTIVE -->

<!-- DIRECTIVE: <operation>
...
-->
```

### Top-Level Frontmatter

File metadata at the top of the override file, enclosed in `---` delimiters:

```yaml
---
agent: nefario                # Which agent these overrides apply to
base-version: "1.4"          # Spec version these overrides were written against
last-reviewed: "2026-02-09"  # When these overrides were last audited for relevance
---
```

| Field | Required | Purpose |
|-------|----------|---------|
| `agent` | yes | Agent name, must match the directory name |
| `base-version` | yes | Spec version from `the-plan.md` when overrides were created. Used to detect staleness. |
| `last-reviewed` | yes | Date of last human review. Prompts review after spec changes or after 90 days. |

### Preamble

Optional free-form Markdown between the frontmatter and first directive. Use for high-level context about the overrides file (what kinds of customizations, why they exist, migration notes). This content is ignored by the merge parser.

### Directive Blocks

Each directive is enclosed in HTML comment delimiters to prevent it from rendering as visible content. The directive itself is a YAML block plus content.

## Directive Syntax

### Delimiters

```markdown
<!-- DIRECTIVE: <operation>
<yaml-metadata>
-->
<content>
<!-- END DIRECTIVE -->
```

**Rules:**
- Opening delimiter: `<!-- DIRECTIVE: <operation>` where `<operation>` is one of the supported operations (see Operations Reference below)
- YAML metadata immediately follows the opening delimiter (no blank line)
- Content boundary: first line after `-->` starts the content block
- Closing delimiter: `<!-- END DIRECTIVE -->`
- Content cannot contain `<!-- END DIRECTIVE -->` as a literal string (would prematurely close the block). If content needs to include directive-like patterns (e.g., documentation about the override format), escape the closing delimiter by inserting a zero-width space: `<!-- END DIRECTIVE​ -->` (U+200B between E and space)

### YAML Metadata Fields

All directives have these required fields:

```yaml
target: <heading-path>
reason: <human-readable intent>
```

Optional fields:

```yaml
position: before | after   # For insert-before and insert-after operations
key: <frontmatter-key>     # For frontmatter-set and frontmatter-delete operations
```

| Field | Required for | Purpose |
|-------|--------------|---------|
| `target` | All operations except `frontmatter-*` | Heading path to locate the target section |
| `key` | `frontmatter-set`, `frontmatter-delete` | Frontmatter key to modify |
| `reason` | All operations | Why this override exists. Used for staleness review. |
| `position` | `insert-before`, `insert-after` | Clarifies insertion point relative to target (mostly for readability; operation name already specifies this) |

## Operations Reference

### replace

Replace the entire target section (from its heading to the next same-level heading) with the directive's content.

**When to use:** The generated section is wrong or incomplete, and you need to fully override it.

**Example:**

```markdown
<!-- DIRECTIVE: replace
target: ## Approval Gates
reason: Generated version lacks decision brief template, response handling, anti-fatigue rules
-->
## Approval Gates

Some deliverables require user review before downstream tasks should proceed.

### Gate Classification

Classify each potential gate on two dimensions: **reversibility** (how hard to
undo) and **blast radius** (how many downstream tasks depend on it).

(full replacement content continues...)
<!-- END DIRECTIVE -->
```

### append

Add content after the target section (before the next same-level heading).

**When to use:** The generated section is mostly correct but needs additional subsections or paragraphs at the end.

**Example:**

```markdown
<!-- DIRECTIVE: append
target: ## Output Standards
reason: Add Final Deliverables subsection for presenting completed work
-->

### Final Deliverables

When presenting completed work to the user:

- **Synthesis**: Unified narrative of what was accomplished
- **Verification Results**: Test results, checks passed/failed
- **Known Issues**: Anything incomplete or requiring follow-up
- **Handoff**: What the user needs to do next
<!-- END DIRECTIVE -->
```

### prepend

Add content at the beginning of the target section (immediately after the target heading).

**When to use:** The generated section needs an introductory paragraph or subsection before its existing content.

**Example:**

```markdown
<!-- DIRECTIVE: prepend
target: ## Architecture Review (Phase 3.5)
reason: Clarify that Phase 3.5 is never skipped by orchestrator
-->

**IMPORTANT:** Phase 3.5 Architecture Review is NEVER skipped by the orchestrator,
regardless of task type (documentation, config, single-file, etc.) or perceived
simplicity. ALWAYS reviewers are ALWAYS. The orchestrator does not have authority
to skip mandatory reviews — that authority belongs to the user, who can explicitly request it.

<!-- END DIRECTIVE -->
```

### insert-before

Insert a new section immediately before the target heading.

**When to use:** Need to add a section that logically precedes the target, and there's no better place to append or prepend.

**Example:**

```markdown
<!-- DIRECTIVE: insert-before
target: ## Working Patterns
reason: Add execution reporting section before working patterns
-->

## Execution Reporting

After plan execution completes, generate a wrap-up report documenting:
- What was accomplished
- What was deferred or skipped
- Blockers encountered and how they were resolved
- Lessons learned for future orchestrations

Reports are written to `nefario/reports/` with YAML frontmatter and indexed
in `nefario/reports/index.md`.

<!-- END DIRECTIVE -->
```

### insert-after

Insert a new section immediately after the target section (after its content, before the next same-level heading).

**When to use:** Need to add a section that logically follows the target.

**Example:**

```markdown
<!-- DIRECTIVE: insert-after
target: ## Cross-Cutting Concerns (Mandatory Checklist)
reason: Add gate budget tracking section after checklist
-->

## Gate Budget Management

Every plan must track approval gate count. Target: 3-5 gates per plan.
If synthesis produces more than 5 gates:
- Consolidate related gates
- Downgrade low-risk gates to non-blocking notifications
- Flag the budget violation in the delegation plan
<!-- END DIRECTIVE -->
```

### frontmatter-set

Set or override a YAML frontmatter key in the generated file.

**When to use:** Need to override a specific frontmatter value without touching the Markdown body.

**Example:**

```markdown
<!-- DIRECTIVE: frontmatter-set
key: x-plan-version
reason: Override spec version to signal custom enhancements
-->
"1.4"
<!-- END DIRECTIVE -->
```

Content block contains the YAML value only (no key). Multi-line values use YAML literal or folded block syntax:

```markdown
<!-- DIRECTIVE: frontmatter-set
key: description
reason: Add clarification about when to delegate to this agent
-->
>
  Multi-agent orchestrator specializing in task decomposition, delegation,
  and coordination. Use for complex projects requiring multiple specialist agents
  working together. Use proactively when a task spans multiple domains.
<!-- END DIRECTIVE -->
```

### frontmatter-delete

Remove a YAML frontmatter key from the generated file.

**When to use:** Generated frontmatter includes a key that should not be present (rare).

**Example:**

```markdown
<!-- DIRECTIVE: frontmatter-delete
key: tools
reason: Remove tools restriction to grant full tool access
-->
<!-- END DIRECTIVE -->
```

No content block (closing delimiter immediately follows opening delimiter and metadata).

## Target Resolution

### Heading Path Syntax

Targets use heading paths to handle nesting. A heading path consists of one or more heading selectors joined by ` > ` (space-greater-than-space).

**Heading selector:** `<hashes><space><heading-text>`

Examples:
- `## Approval Gates` — matches a level-2 heading with exact text "Approval Gates"
- `# Core Knowledge > ## Agent Team Roster` — matches the level-2 heading "Agent Team Roster" that is a child of the level-1 heading "Core Knowledge"
- `## Architecture Review (Phase 3.5) > ### Review Triggering Rules` — matches level-3 "Review Triggering Rules" under level-2 "Architecture Review (Phase 3.5)"

**Matching semantics:**

1. **Exact text match**: Heading text must match exactly (case-sensitive, whitespace-sensitive, punctuation-sensitive). `## Approval Gates` does not match `## Approval Gate` or `## approval gates`.

2. **Level enforcement**: The heading level (number of `#` characters) must match the selector. `## Approval Gates` does not match `# Approval Gates` or `### Approval Gates`.

3. **Nested path resolution**: For multi-segment paths like `# A > ## B`, the parser finds the first `# A` heading, then searches for `## B` within A's scope (from `# A` to the next `#` heading or EOF). If multiple `# A` sections exist, the parser uses the first match.

4. **Scope boundaries**: A section's scope is everything from its heading line to the line before the next same-or-higher-level heading (or EOF).

**Invalid paths** (parser must reject):

- Empty string
- No heading selector (e.g., just `Approval Gates` without `##`)
- Mismatched levels in path (e.g., `## A > # B` — child heading cannot be higher level than parent)

### Fenced Code Block Handling

Markdown headings inside fenced code blocks (` ``` ` or `~~~`) must NOT be matched as targets. The parser must track whether it is inside a code fence before testing heading patterns.

**Algorithm:**
1. Initialize `in_code_fence = false`
2. For each line:
   - If line starts with ` ``` ` or `~~~` (optionally followed by language identifier): toggle `in_code_fence`
   - If `in_code_fence == false` and line matches heading pattern: this is a real heading
   - Otherwise: skip (not a heading target)

### Target Not Found (Orphaned Directive)

If a directive's target heading does not exist in the generated file, the merge produces a WARNING and skips that directive.

**Warning format:**

```
WARNING: Orphaned directive in AGENT.overrides.md
  Operation: replace
  Target: ## Approval Gates > ### Gate Classification
  Reason: Generated version lacks decision brief template
  Line: 42

  This directive was not applied because the target heading was not found.
  Possible causes:
  - Target heading was removed or renamed in generated output
  - Heading path is incorrect (check spelling, punctuation, heading level)
  - Generated file structure changed (check AGENT.generated.md)
```

The merge continues processing remaining directives. Orphaned directives do not fail the build — they are reported for human review.

### Multiple Directives Targeting Same Section

When multiple directives target the same section, operations are applied in **document order** (top-to-bottom as they appear in the overrides file).

**Order-of-operations:**

1. All `replace` operations execute first (within their document-order group)
2. Then `prepend`, `append`, `insert-before`, `insert-after` (in document order)
3. Frontmatter operations execute independently of body operations

**Example scenario:**

```markdown
<!-- DIRECTIVE: replace
target: ## Approval Gates
-->
(new section content)
<!-- END DIRECTIVE -->

<!-- DIRECTIVE: append
target: ## Approval Gates
-->
(additional content)
<!-- END DIRECTIVE -->
```

Result: The section is replaced with new content, then the append adds additional content at the end. If you reverse the order (append first, replace second), the append is ignored because replace overwrites the entire section.

**Recommendation:** Avoid multiple directives on the same target when possible. If necessary, document the intended interaction in the `reason` field.

## Edge Cases and Error Handling

### Content Injection Prevention

Directive content must not be able to inject new directives or close parent directives prematurely.

**Security rule:** The closing delimiter `<!-- END DIRECTIVE -->` within content is treated as literal text only if it is escaped. Unescaped closing delimiters prematurely close the directive block, leaving remaining content unparsed.

**Mitigation:** If content needs to include `<!-- END DIRECTIVE -->` as literal text (e.g., documentation about the override format itself), escape it by inserting a zero-width space (U+200B) between `E` and space: `<!-- END DIRECTIVE​ -->`. The parser strips zero-width spaces before rendering content.

**Example:**

```markdown
<!-- DIRECTIVE: append
target: ## Examples
reason: Document how to escape closing delimiters
-->

If your override content needs to include the closing delimiter as literal text,
escape it with a zero-width space:

`<!-- END DIRECTIVE​ -->` (U+200B between E and space)
<!-- END DIRECTIVE -->
```

### Shell Injection and Value Sanitization

Directive metadata values (target paths, reasons, keys) must not be passed to shell commands without sanitization.

**Parser requirements:**

1. **Never use `eval`** or dynamic code execution on metadata values
2. **Quote all values** when passing to shell commands (use double quotes and escape `"`, `$`, `` ` ``, `\`, `!`)
3. **Validate keys** for frontmatter operations: allow only alphanumeric characters, hyphens, and underscores `[a-zA-Z0-9_-]+`
4. **Validate heading paths**: must match the pattern `(#+\s+[^\n>]+)(\s+>\s+(#+\s+[^\n>]+))*`

**Example (safe shell invocation):**

```bash
# WRONG: vulnerable to injection
target=$(grep "^target:" directive.yaml | cut -d: -f2-)
grep "$target" AGENT.generated.md

# RIGHT: quoted and sanitized
target=$(grep "^target:" directive.yaml | cut -d: -f2- | xargs)
grep -F -- "$target" AGENT.generated.md
```

Use `-F` (fixed strings) for grep to prevent regex injection. Use `--` to prevent target values starting with `-` from being interpreted as flags.

### Conflicting Operations

Some operation combinations on the same target are ambiguous:

- `replace` + `append` on same target: append is ignored (replace overwrites everything)
- `prepend` + `prepend` on same target: both execute in document order (first prepend is closest to heading, second prepend is before that)
- `insert-before` + `insert-before` same target: both execute in document order (results in two new sections before target)

**Parser behavior:** Execute all directives in document order. Emit NOTICE (not warning) if same target appears in multiple directives, listing the operations and document order.

### Empty Content Blocks

Some operations allow empty content:

- `replace` with empty content: removes the target section entirely
- `append`, `prepend`, `insert-before`, `insert-after` with empty content: no-op (parser emits NOTICE)
- `frontmatter-delete`: always empty content (expected)
- `frontmatter-set` with empty content: INVALID (parser emits ERROR and skips directive)

### Directives in Preamble vs. Content

Only directives appearing after the top-level frontmatter are processed. Directives within the preamble (before the first real directive block) are ignored. This allows documenting the directive format itself in the preamble.

### Malformed YAML in Directive Metadata

If directive metadata YAML is invalid:

1. Parser emits ERROR with line number and YAML error message
2. Directive is skipped
3. Merge continues with remaining directives
4. Exit code: non-zero if any errors occurred

## Test Matrix Appendix

This matrix maps test cases to the operations and edge cases they validate. Downstream implementation (Task 4) should ensure all cells are covered.

| Test Case | Operation | Edge Case | Expected Outcome |
|-----------|-----------|-----------|------------------|
| **Basic Operations** |
| Replace entire section | replace | none | Section fully replaced, adjacent sections untouched |
| Append to section | append | none | Content added at end of section, before next heading |
| Prepend to section | prepend | none | Content added immediately after target heading |
| Insert new section before target | insert-before | none | New section appears before target heading |
| Insert new section after target | insert-after | none | New section appears after target content |
| Set frontmatter key (new) | frontmatter-set | none | Key added to frontmatter |
| Set frontmatter key (override) | frontmatter-set | none | Existing key value replaced |
| Delete frontmatter key | frontmatter-delete | none | Key removed from frontmatter |
| **Heading Path Resolution** |
| Single-segment path | replace | none | Matches first occurrence of heading |
| Multi-segment nested path | replace | none | Matches heading within parent scope |
| Non-existent target (orphaned) | replace | target not found | WARNING emitted, directive skipped |
| Heading in fenced code block | replace | code fence | Heading inside code block not matched |
| Multiple sections with same heading text | replace | ambiguous target | Matches first occurrence |
| **Content Edge Cases** |
| Empty content (replace) | replace | empty content | Section removed entirely |
| Empty content (append) | append | empty content | NOTICE emitted, no-op |
| Content with closing delimiter | append | injection attempt | ERROR if unescaped, content if escaped |
| Content with YAML-like syntax | append | none | Content preserved as-is (not parsed) |
| Content with nested markdown headings | append | none | Headings in content are part of merged section |
| **Directive Metadata Edge Cases** |
| Malformed YAML in directive | replace | parse error | ERROR emitted, directive skipped |
| Missing required field (target) | replace | validation | ERROR emitted, directive skipped |
| Invalid frontmatter key name | frontmatter-set | validation | ERROR emitted, directive skipped |
| Target path with mismatched levels | replace | validation | ERROR emitted, directive skipped |
| **Multiple Directives** |
| Two replaces on same target | replace | conflict | Second replace overwrites first (both execute) |
| Replace then append on same target | replace, append | ordering | Replace executes, then append adds to replaced content |
| Two prepends on same target | prepend | ordering | Both execute in document order |
| Prepend and append on same target | prepend, append | none | Both execute, content sandwiches target section |
| **Security** |
| Shell injection in target path | replace | injection | Sanitized, no command execution |
| Shell injection in reason field | replace | injection | Sanitized, no command execution |
| Eval injection in key field | frontmatter-set | injection | Validated against safe pattern, rejected if unsafe |
| **File Structure** |
| No top-level frontmatter | N/A | validation | ERROR, file rejected |
| No directives (empty overrides file) | N/A | empty | No-op, copy generated file to AGENT.md |
| Directives in preamble | replace | ignored | Directives before first real directive are ignored |

**Coverage target:** 100% of operations, 100% of edge cases.

## Examples

### Example 1: Simple Section Replace

```markdown
---
agent: nefario
base-version: "1.4"
last-reviewed: "2026-02-09"
---

This override replaces the Approval Gates section with expanded content
including decision brief templates and response handling rules.

<!-- DIRECTIVE: replace
target: ## Approval Gates
reason: Generated version lacks decision brief template, response handling, anti-fatigue rules
-->
## Approval Gates

Some deliverables require user review before downstream tasks should proceed.

### Gate Classification

Classify each potential gate on two dimensions: **reversibility** (how hard to
undo) and **blast radius** (how many downstream tasks depend on it).

| | Low Blast Radius (0-1 dependents) | High Blast Radius (2+ dependents) |
|---|---|---|
| **Easy to Reverse** (config, additive code, docs) | NO GATE | OPTIONAL gate |
| **Hard to Reverse** (schema migration, API contract, architecture) | OPTIONAL gate | MUST gate |

(rest of section content...)
<!-- END DIRECTIVE -->
```

### Example 2: Multiple Operations on Different Sections

```markdown
---
agent: nefario
base-version: "1.4"
last-reviewed: "2026-02-09"
---

Multiple overrides covering approval gates, architecture review, and output standards.

<!-- DIRECTIVE: replace
target: ## Approval Gates
reason: Add decision brief template and response handling
-->
## Approval Gates

(full replacement content)
<!-- END DIRECTIVE -->

<!-- DIRECTIVE: prepend
target: ## Architecture Review (Phase 3.5)
reason: Clarify that Phase 3.5 is never skipped by orchestrator
-->

**IMPORTANT:** Phase 3.5 Architecture Review is NEVER skipped by the orchestrator.
ALWAYS reviewers are ALWAYS. Only the user can request skip.

<!-- END DIRECTIVE -->

<!-- DIRECTIVE: append
target: ## Output Standards
reason: Add Final Deliverables subsection for presenting completed work
-->

### Final Deliverables

When presenting completed work to the user:

- **Synthesis**: Unified narrative of what was accomplished
- **Verification Results**: Test results, checks passed/failed
- **Known Issues**: Anything incomplete or requiring follow-up
- **Handoff**: What the user needs to do next
<!-- END DIRECTIVE -->
```

### Example 3: Frontmatter Override with Nested Heading Path

```markdown
---
agent: security-minion
base-version: "1.0"
last-reviewed: "2026-02-09"
---

Override the spec version and enhance the threat modeling subsection.

<!-- DIRECTIVE: frontmatter-set
key: x-plan-version
reason: Override spec version to signal custom enhancements
-->
"1.1"
<!-- END DIRECTIVE -->

<!-- DIRECTIVE: replace
target: # Core Knowledge > ## Threat Modeling > ### STRIDE Framework
reason: Add detailed STRIDE category definitions and examples
-->
### STRIDE Framework

STRIDE is a threat classification model for identifying security threats:

- **Spoofing**: Attacker impersonates another user or system (e.g., stolen credentials)
- **Tampering**: Unauthorized modification of data (e.g., MITM attacks)
- **Repudiation**: User denies performing an action (e.g., no audit logs)
- **Information Disclosure**: Unauthorized access to data (e.g., directory traversal)
- **Denial of Service**: Degrading or preventing service availability (e.g., resource exhaustion)
- **Elevation of Privilege**: Attacker gains higher access level (e.g., privilege escalation bug)

Apply STRIDE to each component and data flow in the system.
<!-- END DIRECTIVE -->
```

## Migration from Current Format

The current override mechanism (documented in agent-anatomy.md) uses H2-heading-match section replacement. Migrating to the directive format:

1. **Identify overrides**: For each agent with customizations, identify which H2 sections are overridden.
2. **Convert to directives**: Wrap each overridden section in a `replace` directive with appropriate target path.
3. **Add metadata**: Create top-level frontmatter (agent, base-version, last-reviewed) and add `reason` to each directive.
4. **Validate**: Run the new merge script to ensure output matches current AGENT.md.
5. **Update docs**: Mark agent-anatomy.md section on merge rules as deprecated, link to this spec.

**Backward compatibility:** The new merge script should detect whether an overrides file uses the old format (plain Markdown with H2 sections) or new format (directives with delimiters). Support both during migration, emit deprecation warning for old format, auto-migrate if possible.

## Parser Implementation Notes

This spec is designed to be parseable by a simple script (shell, Node.js, Python). No markdown AST library is required, though one may optionally be used for robustness.

**Minimal implementation approach:**

1. Split file into top-level frontmatter, preamble, directives
2. Parse directives by scanning for `<!-- DIRECTIVE: <op>` and `<!-- END DIRECTIVE -->` delimiters
3. Extract YAML metadata between opening delimiter and `-->`
4. Extract content between `-->` and `<!-- END DIRECTIVE -->`
5. Apply directives in document order, respecting operation semantics
6. Track warnings (orphaned directives) and errors (malformed YAML, missing targets)

**Recommended libraries:**

- **Node.js**: `js-yaml` for YAML parsing, `remark` or `marked` for optional markdown AST
- **Python**: `pyyaml` for YAML parsing, `markdown` or `mistune` for optional markdown AST
- **Shell**: `grep`, `sed`, `awk` for directive extraction; `yq` for YAML parsing

The reference implementation (Task 3) will include a Node.js script (`scripts/merge-agent.js`) implementing this spec.
