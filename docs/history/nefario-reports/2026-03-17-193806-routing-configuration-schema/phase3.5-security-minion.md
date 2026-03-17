## Verdict: ADVISE

The plan incorporates the core security recommendations well -- file size limits, path canonicalization, YAML anchor rejection, character allowlists on model IDs, and capability gating are all present. Four concerns remain:

- [security]: YAML anchor rejection via pre-parse grep for `&` and `*` will produce false positives on legitimate YAML string values containing those characters.
  SCOPE: `lib/load-routing-config.sh`, YAML anchor/alias rejection logic
  CHANGE: Instead of raw grep for `&` or `*`, use `yq` to detect actual anchor/alias nodes after parsing (e.g., check for `!!` tag or alias markers in yq's JSON output), or restrict the grep to YAML key positions only (beginning of unquoted tokens). At minimum, document that values containing literal `&` or `*` must be quoted, and test this edge case.
  WHY: A model ID like `o4-mini&preview` or a future harness name containing `*` would be falsely rejected. The current spec says "a pre-parse grep check is sufficient," but pre-parse means yq has not yet validated the structure, so distinguishing anchors from string content is unreliable. Low severity since current allowlisted values do not contain these characters, but the validation is formally incorrect.
  TASK: 1

- [security]: The `--project-config` and `--user-config` CLI flags bypass the path canonicalization and root-escape checks described in point 3 of the loader spec.
  SCOPE: `lib/load-routing-config.sh`, CLI argument handling
  CHANGE: Path canonicalization and root-escape validation must apply equally to override paths passed via `--project-config` and `--user-config`, not only to the default discovery paths. The Task 1 prompt specifies canonicalization for default paths but does not explicitly state that override paths receive the same treatment. Add a test case (Task 2) that passes a `--project-config` path containing `../` traversal and verifies rejection.
  WHY: The CLI flags exist for testability but also represent an input surface. If the loader is ever invoked programmatically (e.g., from the routing dispatch), a crafted path could read arbitrary YAML files outside the project or home directory. Path traversal via test flags is a classic CWE-22 pattern.
  TASK: 1, 2

- [security]: The shallow-per-section merge allows a user-level config to silently override project-level capability gating decisions without any visible warning.
  SCOPE: Merge semantics (conflict resolution #2), user-level override behavior
  CHANGE: When user-level config overrides a project-level `agents:` or `groups:` routing, the startup log (stderr) should explicitly list which project-level routings were overridden and by what. The current spec logs which files were loaded but not which sections were overridden. This is an observability concern, not a blocking design issue.
  WHY: A project may route `security-minion` to `claude-code` specifically because it requires WebSearch. A user override routing all agents to `aider` would pass capability gating (user wins) but silently break the project's intent. The override is by design, but silent overrides of security-relevant routing decisions should be visible in diagnostic output.
  TASK: 1, 3

- [security]: The `--agent-dir` flag points to a directory of AGENT.md files whose `tools:` frontmatter is trusted for capability gating decisions, but no integrity check exists on those files.
  SCOPE: Capability gating, AGENT.md trust boundary
  CHANGE: Document in Task 3 (routing-config.md) that the AGENT.md files are a trusted input to capability gating, and that modifying an agent's `tools:` field to remove a required tool will bypass the gating check. This is informational -- integrity enforcement (e.g., checksums) is not warranted for M1 -- but the trust assumption should be explicit in the spec.
  WHY: If an attacker or misconfigured deployment modifies an AGENT.md to remove `WebSearch` from its `tools:` list, the capability gating check would pass for a harness that does not support WebSearch. The agent would then fail at runtime. This is an accepted risk for M1 (single-user, local execution) but should be documented as a trust boundary.
  TASK: 3
