## Domain Plan Contribution: gru

### Ring Classification: HOLD

Do not introduce DESPICABLE.md / DESPICABLE.local.md at this time. The pattern
is counter to the emerging industry convergence on fewer config files, and
the problem it solves has lighter-weight alternatives that carry less
ecosystem risk. Re-evaluate in 6 months (August 2026) when AGENTS.md support
in Claude Code may change the entire config surface.

---

### Recommendations

#### 1. How Other Agent Frameworks Handle Project-Local Configuration

| Framework | Config Mechanism | File Type | Layered? |
|-----------|-----------------|-----------|----------|
| **LangGraph** | `langgraph.json` in project root | Dedicated JSON file | No (single file) |
| **CrewAI** | `config/agents.yaml` + `config/tasks.yaml` | Dedicated YAML files | No (convention dirs) |
| **AutoGen/AG2** | `OAI_CONFIG_LIST` env var or JSON file | Env + JSON | No |
| **OpenAI Agents SDK** | Programmatic (Python/TS code) | No config file | N/A |
| **AGENTS.md (Codex, Cursor, Jules, etc.)** | Markdown file(s) in repo | Platform-agnostic Markdown | Yes (directory tree) |
| **Claude Code** | `CLAUDE.md` / `CLAUDE.local.md` | Platform-specific Markdown | Yes (directory tree + global) |
| **Cursor** | `.cursor/rules/*.mdc` + AGENTS.md | Both dedicated and shared | Yes (glob + frontmatter) |

**Key finding**: The industry is consolidating, not fragmenting. AGENTS.md
(now under Linux Foundation / AAIF, adopted by 40,000+ repos) is emerging as
the single cross-platform config surface. Teams previously maintained 4-6
overlapping files (.cursorrules, CLAUDE.md, .gemini, copilot-instructions.md)
and the explicit purpose of AGENTS.md is to eliminate this duplication.
Introducing DESPICABLE.md would swim against this tide.

Frameworks that ship their own config files (LangGraph, CrewAI) do so because
they are **application frameworks** that need structured, machine-parsed
configuration (dependency graphs, agent definitions, task routing). They are
not guidance files for coding agents -- they are build manifests. This is the
crucial distinction: despicable-agents delivers guidance through system prompts
loaded by Claude Code, not through a separate runtime that parses config files.

#### 2. Is There an Emerging Convention for "Framework Config on Top of Platform Config"?

Yes, but the convention is **sections within the platform file, not separate
files**. Evidence:

- **AGENTS.md spec** explicitly supports freeform Markdown sections. The
  expected pattern is: add a section header for your framework's concerns.
  The spec says "use any headings you like."
- **Codex layering model**: `~/.codex/AGENTS.md` (global) -> repo root
  AGENTS.md -> subdirectory AGENTS.md, with closer files taking precedence.
  This is exactly how CLAUDE.md already works.
- **Cursor** evolved from a dedicated `.cursorrules` file to `.cursor/rules/`
  directory to now also supporting AGENTS.md. The trajectory is toward
  consolidation, not proliferation.
- **package.json precedent**: The JavaScript ecosystem tried both patterns
  (`.eslintrc` dedicated file vs. `"eslintConfig"` key in package.json). The
  dedicated file won for ESLint -- but ESLint is a complex tool with its own
  inheritance model, plugin system, and parser configuration. Simple guidance
  (like Prettier's few options) works fine as a section in package.json.

Despicable-agents config is closer to Prettier (a few behavioral preferences)
than ESLint (a complex plugin architecture). Section-in-host-file is the right
pattern for this complexity level.

#### 3. Risk Analysis: Custom Config Surface (DESPICABLE.md) vs. Platform Native (CLAUDE.md Sections)

**Risks of introducing DESPICABLE.md:**

| Risk | Severity | Detail |
|------|----------|--------|
| **Config fragmentation** | High | Users must now maintain 3 files (CLAUDE.md, CLAUDE.local.md, DESPICABLE.md) plus potentially AGENTS.md when Claude Code adds support. Each file must be understood, versioned, and kept coherent. |
| **Discovery failure** | High | Claude Code reads CLAUDE.md automatically. A DESPICABLE.md requires explicit reading logic -- either in every agent's system prompt (27 agents) or in SKILL.md (fragile if invoked outside nefario). If the file is not read, configuration is silently ignored. |
| **AGENTS.md collision** | Medium | Claude Code will likely adopt AGENTS.md support (71% prediction market probability in 2026). When it does, the layering model changes. DESPICABLE.md becomes a third-party config surface competing with two platform-native ones (CLAUDE.md + AGENTS.md). |
| **Maintenance burden** | Medium | The toolkit must document, validate, and handle missing/malformed DESPICABLE.md. This is new infrastructure that needs testing and error handling. YAGNI applies strongly. |
| **Ecosystem isolation** | Medium | Other tools and agents cannot read DESPICABLE.md. Configuration placed there is invisible to Cursor, Codex, or any non-despicable-agents tooling the project uses. CLAUDE.md content is visible to Claude Code always. |

**Risks of staying with CLAUDE.md sections:**

| Risk | Severity | Detail |
|------|----------|--------|
| **Namespace collision** | Low | Despicable-agents sections could conflict with other CLAUDE.md content. Mitigated by using clear section headers (e.g., `## Despicable Agents Configuration`). |
| **File bloat** | Low | Adding a section to CLAUDE.md increases its size. Mitigated by CLAUDE.md's @-import mechanism for referencing external files when sections grow large. |
| **Coupling perception** | Low | Users might feel despicable-agents "owns" part of their CLAUDE.md. Mitigated by clear documentation that the section is optional and user-controlled. |

The risk asymmetry is clear: DESPICABLE.md carries 5 medium-to-high risks;
CLAUDE.md sections carry 3 low risks.

#### 4. When Dedicated Files Win vs. When Sections Win

Based on the broader ecosystem pattern analysis:

**Dedicated file wins when:**
- The tool has its own parser/runtime that reads the file (ESLint, TypeScript, Docker)
- Configuration is complex enough to need its own schema/validation
- The file is consumed by CI/CD pipelines or build tools, not just editors
- Multiple inheritance or plugin systems are involved
- The config is machine-generated or machine-maintained

**Section-in-host-file wins when:**
- Configuration is human-authored guidance, not machine-parsed structure
- The amount of configuration is small (a few preferences, not a schema)
- The host file is already read automatically by the platform
- The config needs to be visible to multiple tools (not just one framework)
- Simplicity and discoverability matter more than separation of concerns

Despicable-agents configuration matches every criterion in the
"section-in-host-file" column.

#### 5. Recommended Alternative: Documented Section Convention

Instead of DESPICABLE.md, establish a **documented section convention** for
consuming projects:

```markdown
## Despicable Agents

<!-- Optional: project-specific despicable-agents configuration -->
<!-- See: https://github.com/benpeter/despicable-agents/docs/consuming-project-guide.md -->

### Agent Preferences
- Prefer security-minion review for all PRs touching auth/
- Skip sitespeed-minion (no web frontend in this project)

### Nefario Overrides
- Default mode: PLAN (always require approval before execution)
- Report directory: docs/reports/
```

This approach:
- Is automatically read by Claude Code (zero new infrastructure)
- Is visible to all Claude Code agents and skills (not just despicable-agents)
- Works today without any code changes
- Follows the AGENTS.md philosophy ("just Markdown, use any headings you like")
- Can be trivially migrated if AGENTS.md support arrives in Claude Code

For local/private overrides, users already have CLAUDE.local.md (gitignored).
A `## Despicable Agents` section there handles the DESPICABLE.local.md use case.

---

### Proposed Tasks

#### Task 1: Document the Section Convention

**What**: Create a "Consuming Project Guide" in `docs/` that documents the
recommended `## Despicable Agents` section convention for CLAUDE.md, with
examples of common configuration patterns.

**Deliverables**: `docs/consuming-project-guide.md` with section templates,
examples, and explanation of what is configurable.

**Dependencies**: None. This is documentation of the recommended approach.

#### Task 2: Validate Agent Discovery of CLAUDE.md Sections

**What**: Verify that nefario's meta-plan phase already reads CLAUDE.md
(it does, via Claude Code's automatic loading). Confirm that section-based
configuration is visible to spawned subagents. Document any gaps.

**Deliverables**: Test results confirming section visibility. If gaps exist,
minimal fixes to ensure CLAUDE.md sections flow through to agent context.

**Dependencies**: Task 1 (need to know what sections to test).

#### Task 3: Add AGENTS.md Migration Note

**What**: Add a brief note in the consuming project guide about future
AGENTS.md compatibility. When Claude Code adds AGENTS.md support, the same
section convention applies -- just move the section to AGENTS.md.

**Deliverables**: One paragraph in the consuming project guide.

**Dependencies**: Task 1.

---

### Risks and Concerns

1. **AGENTS.md convergence risk (6-12 month horizon)**: Claude Code is the
   last major holdout not supporting AGENTS.md (71% prediction market
   probability for 2026 adoption). Any config surface invented today should
   assume it may need to work alongside or migrate to AGENTS.md. A section
   convention migrates trivially. A dedicated file does not.

2. **Over-engineering risk**: The current external skill integration (Decision
   28) already works via filesystem scanning and CLAUDE.md precedence. Adding
   a new config file type creates infrastructure that must be maintained,
   documented, and tested -- for a problem that may not exist yet. Per the
   Helix Manifesto: YAGNI.

3. **Platform coupling risk**: Claude Code's automatic CLAUDE.md loading is
   the most reliable config delivery mechanism available. Any file that is
   NOT automatically loaded requires explicit `Read` tool calls, which means
   every agent must know about it. This is fragile and violates KISS.

4. **Cognitive overhead for consuming projects**: A new user evaluating
   despicable-agents now must learn about DESPICABLE.md in addition to
   CLAUDE.md, CLAUDE.local.md, and eventually AGENTS.md. Each additional
   file is a decision point ("where does this config go?") that adds friction.

---

### Additional Agents Needed

- **devx-minion**: Should evaluate the developer experience of the section
  convention vs. dedicated file from an onboarding and discoverability
  perspective. The DX of "add a section to your existing CLAUDE.md" vs.
  "create a new file" is a significant usability difference.

- **software-docs-minion**: Should draft the consuming project guide content
  if the section convention approach is adopted. The documentation of "how
  to configure despicable-agents in your project" is a docs deliverable.

No other specialists needed. This is primarily a convention/documentation
decision, not an implementation task.
