## Domain Plan Contribution: security-minion

### Recommendations

**1. User-level config MUST override project-level for security (config trust hierarchy).**

The `.nefario/routing.yml` in a cloned repository is untrusted input -- it is controlled by whoever authored the repo. A malicious or compromised repository could ship a `routing.yml` that redirects agent tasks to a harness the user did not intend, or maps model tiers to unexpected provider-specific models. The trust model must be:

- **User-level config** (e.g., `~/.config/nefario/routing.yml` or `~/.nefario/routing.yml`) is the security boundary. It represents the user's explicit intent.
- **Project-level config** (`.nefario/routing.yml`) provides defaults and convenience. It is loaded first, then overridden (not merged) by user-level config on a per-field basis.
- **Zero-config implicit default** (`claude-code` for everything) is the failsafe when neither file exists.

Resolution order must be: user-level > project-level > implicit default. This mirrors the pattern used by git config (`~/.gitconfig` vs `.git/config`), npm (`.npmrc` hierarchy), and the adapter interface's own `working_directory` validation philosophy (trust boundaries enforced at load time, not deferred to runtime).

Critically: the `default` harness field from project-level config must be overridable by the user. A project that sets `default: codex` should not force all users to route through Codex without opt-in.

**2. Harness names must be a closed, hardcoded allowlist -- never arbitrary binary paths.**

The feasibility study already establishes this: harness names are a closed set (`claude-code`, `codex`, `aider`). The config loader must validate all harness name values against this hardcoded allowlist. Reject any value not in the set with a clear error. This is the single most important security control in the config surface because it prevents the config from becoming an arbitrary command execution vector.

Never allow:
- Absolute or relative paths as harness values (e.g., `default: /usr/local/bin/evil-tool`)
- Shell metacharacters in any config value
- Harness name strings that could be interpreted as paths or commands by downstream consumers

The allowlist should be defined once (in the config loader source) and referenced by capability gating, adapter dispatch, and validation logic. When a new harness is added (e.g., Gemini CLI in M5), the allowlist is updated in one place as a code change, not a config change.

**3. YAML parser must be hardened against entity expansion attacks.**

YAML supports anchors/aliases (`&anchor` / `*anchor`) and, depending on the parser, may support entity expansion that enables billion-laughs-style denial of service (CVE-2013-0156 pattern). The config loader must:

- **Use a safe YAML parser** that does not resolve arbitrary tags or construct language-specific objects. In Python, use `yaml.safe_load()`, never `yaml.load()`. In JavaScript/Node, `js-yaml` with `safeLoad` (or the default in modern versions). In shell, `yq` is acceptable for this simple schema.
- **Reject YAML with custom tags** (e.g., `!!python/object`, `!!js/function`). The routing config schema uses only scalars, mappings, and sequences. Any document containing custom tags is malformed and must be rejected.
- **Limit document size** to a reasonable bound (e.g., 64KB). The routing config is a handful of lines; a multi-megabyte YAML file is either an attack or an error.
- **Limit anchor recursion depth** or disable aliases entirely if the parser supports it. The routing config has no legitimate use case for YAML anchors.

**4. Config path validation must mirror the adapter's `working_directory` validation.**

The adapter behavioral contract requires `working_directory` to be canonicalized and validated against an allowlisted root. The same discipline must apply to the config loader's own file resolution:

- Canonicalize the project-level config path: resolve `${project_root}/.nefario/routing.yml` using `realpath` or equivalent. If the resolved path escapes the project root (e.g., via symlink), reject it. This prevents a symlinked `.nefario/` directory from pointing to an attacker-controlled location.
- Canonicalize the user-level config path similarly, resolving against `$HOME`.
- Do not follow symlinks for the `.nefario/` directory itself. The config file may be a symlink (for shared config), but the `.nefario/` directory within the project must be a real directory under the project root.

**5. Config values must not flow into shell commands unsanitized.**

The routing config contains string values (harness names, model IDs) that will eventually be passed to adapter invocation logic. Even though harness names are allowlisted, model mapping values (e.g., `opus: o3`, `sonnet: claude-sonnet-4-6`) are user-provided strings that will become CLI arguments. The config loader must:

- Validate model mapping values against a character allowlist: `[a-zA-Z0-9._-]` only. Model IDs across all providers (OpenAI, Anthropic, Google) use only these characters. Reject values containing spaces, shell metacharacters, or any character outside this set.
- The adapter invocation layer must use argument vector APIs (already required by the behavioral contract), so these values should never reach a shell. But defense in depth means validating at the config layer too.
- Agent names and group names in the config must be validated against the same character pattern used by AGENT.md `name` frontmatter fields.

**6. Log and warn when project-level config is loaded from a cloned repo.**

On first load of a project-level `.nefario/routing.yml`, emit a visible warning to the user:

```
[nefario] Loading routing config from .nefario/routing.yml
[nefario] This file is part of the project (may be authored by others).
[nefario] Override with ~/.config/nefario/routing.yml if needed.
```

This is analogous to the warning Git shows when a repo-level hook exists. It makes the trust boundary visible without blocking workflow.

### Proposed Tasks

**Task S1: Define config trust hierarchy in the schema specification.**
Add a "Trust Model" section to the routing config schema document that specifies: (a) user-level overrides project-level, (b) harness name allowlist is hardcoded, (c) zero-config defaults to claude-code. This is a documentation task within the schema definition, not a separate document.

**Task S2: Implement safe YAML loading with input constraints.**
The config loader implementation must: use a safe YAML parser (no custom tags, no unsafe deserialization), enforce a 64KB file size limit, reject documents containing custom YAML tags, and optionally disable YAML anchor resolution (if the parser supports it). These are validation checks at the top of the config loading function, not a separate module.

**Task S3: Implement value validation for all config fields.**
After YAML parsing, validate every field value:
- `default`, group values, and agent values: must be in the harness allowlist (`claude-code`, `codex`, `aider`).
- Model mapping keys: must be in the tier enum (`opus`, `sonnet`).
- Model mapping values: must match `[a-zA-Z0-9._-]+`.
- Agent names and group names: must match the naming pattern used in AGENT.md frontmatter.
- No field may contain null bytes, control characters, or strings exceeding 256 characters.

**Task S4: Implement config path canonicalization.**
Before reading either config file, canonicalize the path and verify it resolves within the expected root (project root for project-level, `$HOME` for user-level). Reject symlinked `.nefario/` directories that escape the project root.

### Risks and Concerns

**RISK: Malicious `routing.yml` in a cloned repository (HIGH likelihood, MEDIUM impact).**
This is the primary threat. Any public or shared repository can include a `.nefario/routing.yml` that routes tasks to a non-default harness. If the user has Codex CLI or Aider installed and configured with API keys, a malicious config could silently route tasks through those tools, potentially:
- Consuming the user's API quota on a provider they did not choose
- Routing sensitive task prompts (containing system prompt content) through a provider the user did not consent to
- Exploiting provider-specific vulnerabilities or data retention policies the user is not aware of

The impact is not code execution (harness names are a closed set), but unauthorized use of credentials and unintended data flow. **Mitigation**: User-level override + visible warning on project-level config load + harness name allowlist.

**RISK: YAML deserialization attacks (LOW likelihood, HIGH impact).**
If the YAML parser supports unsafe deserialization (Python `yaml.load()`, Ruby `YAML.load()`), a malicious routing.yml can achieve arbitrary code execution. The routing config file is small and simple, making this easy to overlook during implementation. **Mitigation**: Mandate safe parser APIs in the implementation specification. This is a one-line difference in code but a critical-severity difference in security posture.

**RISK: Model mapping as a social engineering vector (MEDIUM likelihood, LOW impact).**
A project-level config could map `opus` to a cheap/weak model (e.g., `opus: gpt-3.5-turbo`) to degrade task quality, or map it to an expensive model to drain API quota. This is not a traditional vulnerability but a trust violation. **Mitigation**: The user-level override mechanism handles this. Additionally, the config loader should log the resolved model mapping at load time so the user can see what models are selected.

**RISK: Config path symlink escape (LOW likelihood, MEDIUM impact).**
A repository could include a `.nefario` symlink pointing to `../../other-project/.nefario/`, causing the orchestrator to load config from an unexpected location. **Mitigation**: Canonicalize and validate the config path against the project root before reading.

**CONCERN: Merge semantics between user-level and project-level config.**
The override semantics must be clearly defined. Options: (a) user-level replaces project-level entirely if present, (b) user-level overrides specific fields (deep merge). Option (a) is simpler and more secure -- if the user provides a config, it is the complete truth. Option (b) risks a confused merge where the user thinks they have overridden a dangerous setting but a nested field still comes from the project. **Recommendation**: Use full replacement (option a). If the user wants to inherit most of the project config, they copy it to user-level and modify. Simplicity is security.

### Additional Agents Needed

- **devx-minion**: Should review the user-level config location convention (`~/.config/nefario/` vs `~/.nefario/`) for consistency with existing tool conventions and XDG Base Directory compliance.
- **software-docs-minion**: The trust model and validation rules must be documented in the schema specification, not just in code comments. The doc should clearly explain what a project-level config can and cannot do.
- **test-minion**: Must cover adversarial config inputs: YAML bombs, custom tags, shell metacharacters in model mapping values, symlinked `.nefario/` directories, and the override semantics between user-level and project-level configs.
