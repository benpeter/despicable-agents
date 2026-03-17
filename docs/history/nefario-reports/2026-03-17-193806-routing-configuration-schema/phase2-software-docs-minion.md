## Domain Plan Contribution: software-docs-minion

### Recommendations

**1. New standalone doc page: `docs/routing-config.md`**

The routing configuration spec should live in its own doc page, not as a section appended to an existing document. Rationale:

- **Audience differs from adjacent docs.** `adapter-interface.md` targets adapter implementors. `external-harness-integration.md` targets architectural evaluators. The routing config doc targets end users who configure routing for their projects. Mixing audiences in one doc forces readers to skip irrelevant sections.
- **The doc hub pattern is established.** `docs/architecture.md` links to sub-documents via the "Contributor / Architecture" table. Adding a row for `routing-config.md` follows the existing pattern exactly (see `adapter-interface.md`, `external-harness-roadmap.md`, etc. -- each gets its own page when the scope is self-contained).
- **Cross-reference surface.** The routing config will be referenced from at least three other documents (feasibility study's "Routing and Configuration" section, the roadmap's issue #139, and `using-nefario.md` once Phase 4 routing is live). A standalone page gives all three a single canonical link target.

**2. Follow the adapter-interface.md documentation pattern exactly**

The adapter interface doc established a clear, effective pattern: Markdown field tables with YAML examples. The routing config doc should mirror this:

- **Format Decision section** at the top, explaining why Markdown field tables over JSON Schema or TypeScript (same rationale applies: no TypeScript runtime, validation is in the config loader, field tables are human/LLM-readable).
- **Annotated YAML examples first, then field tables.** This is the order used in `adapter-interface.md` (example at line 39, field table at line 59). Examples-first is more effective for configuration docs because users skim the example to see if it matches their use case, then drill into the field table for precision. This is a progressive disclosure pattern -- task-oriented ("how do I route agent X to Codex?") before reference ("what are all the fields?").
- **Semantics Notes sections** after each field table for nuance that does not fit in a table cell (e.g., resolution order behavior, zero-config semantics, capability gating error format).
- **Fields Considered and Excluded section** to prevent re-litigation of deferred features (JSON Schema output, env var overrides, "did you mean?" suggestions -- all explicitly listed as YAGNI in the roadmap).

**3. Document the resolution algorithm explicitly**

The feasibility study mentions "agent > group > default > implicit claude-code" but does not define edge cases. The spec must cover:

- What happens when an agent appears in both `agents:` and its group is in `groups:` (agent wins -- but state it).
- What happens when `default:` is omitted (implicit `claude-code`).
- What happens when `default:` is set to a harness that has no `model-mapping:` entry (adapter applies sensible default per `adapter-interface.md` semantics notes).
- Whether `groups:` keys match agent-group names from the hierarchy (Protocol, Infrastructure, etc.) or are user-defined labels. This is an open design question the implementor must resolve; the doc should capture whichever decision is made.

**4. Include a validation errors section**

The roadmap specifies "hard error with actionable message on mismatch" for capability gating. The doc should include example error messages so implementors know the expected UX:

```
Error: Cannot route security-minion to aider.
  Required tool 'WebSearch' is not supported by aider.
  Either change the routing for security-minion in .nefario/routing.yml
  or remove WebSearch from security-minion's required tools.
```

This is not implementation -- it is specification of the error contract, which belongs in the doc.

**5. Navigation and cross-linking**

- Add back-link to `architecture.md` at the top (standard pattern: `[< Back to Architecture Overview](architecture.md)`).
- Add cross-links to `adapter-interface.md` (for `model_tier` and `required_agent_tools` field semantics) and `external-harness-roadmap.md` (for issue #139 context).
- Add a row to `architecture.md`'s "Contributor / Architecture" table: `[Routing Configuration](routing-config.md) | .nefario/routing.yml schema, resolution order, capability gating, zero-config behavior`.
- Update the feasibility study's "Routing and Configuration" section to link to the new spec: "For the full specification, see [Routing Configuration](routing-config.md)."

### Proposed Tasks

1. **Create `docs/routing-config.md`** -- New doc page following the adapter-interface.md pattern. Sections: navigation header, Format Decision, Minimal Example + Field Table (`default`), Full Example + Field Tables (`default`, `model-mapping`, `groups`, `agents`), Resolution Order (with algorithm description), Capability Gating (with error examples), Zero-Config Behavior, User-Level Override, Fields Considered and Excluded, Stability Note.

2. **Add entry to `docs/architecture.md`** -- One row in the "Contributor / Architecture" sub-documents table linking to the new page.

3. **Add cross-link from `docs/external-harness-integration.md`** -- In the "Routing and Configuration" section, add a link to the new spec doc (e.g., "For the full specification, see [Routing Configuration](routing-config.md).").

4. **Add cross-link from `docs/external-harness-roadmap.md`** -- Under issue #139, add a `**Specification**: [Routing Configuration](routing-config.md)` line, mirroring how #138 links to `adapter-interface.md`.

### Risks and Concerns

1. **Group name ambiguity.** The feasibility study uses `groups:` with keys like `code-writers` and `data-analysts`, but the architecture hierarchy uses different group names (Protocol & Integration, Infrastructure & Data, etc.). If these are meant to map to the hierarchy groups, the names must match. If they are user-defined labels, there must be a separate mapping from agents to groups. This is a design question that must be resolved before the doc can be finalized -- the doc author should not invent the answer. Flag for the implementor (likely backend-minion or devx-minion).

2. **User-level override semantics are underspecified.** The roadmap mentions "optional user-level override" but does not define the file location, merge semantics (replace vs. deep merge), or precedence with project-level config. The doc needs to either specify these or explicitly defer them. Recommendation: defer user-level override to a later issue with a note in the doc, since the roadmap's acceptance criteria do not mention user-level override validation.

3. **Doc timing relative to implementation.** The doc should be written design-first (before or alongside implementation), not after. If the config loader implementation makes design decisions not captured in the doc, the doc becomes inaccurate. The doc task and the implementation task should be assigned to the same agent or tightly coordinated.

### Additional Agents Needed

- **devx-minion**: Should review the config file location (`.nefario/routing.yml` vs. alternatives), the zero-config DX, and error message wording. This is a developer experience surface.
- **margo**: Should review the doc scope to ensure it stays minimal and does not over-specify implementation details that belong in the code. The doc should define the contract, not the implementation.
