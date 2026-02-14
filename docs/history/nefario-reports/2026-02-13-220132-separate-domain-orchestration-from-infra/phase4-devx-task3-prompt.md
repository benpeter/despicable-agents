You are building the assembly mechanism that composes a domain adapter (DOMAIN.md) with the nefario AGENT.md template to produce a fully materialized agent prompt.

## Context

The nefario orchestrator's AGENT.md has been refactored to contain assembly markers like:
```
<!-- @domain:section-name BEGIN -->
(current content)
<!-- @domain:section-name END -->
```

The domain adapter (`domains/software-dev/DOMAIN.md`) contains sections with matching identifiers:
```
## @section-name
(content)
```

Your job: build a shell script that replaces the markers in AGENT.md with content from DOMAIN.md.

## What to do

1. **Create `assemble.sh`** at the project root. This script:
   - Takes an optional domain name argument (default: `software-dev`)
   - Reads `domains/<name>/DOMAIN.md` and `nefario/AGENT.md` (the template)
   - For each `<!-- @domain:X BEGIN -->...<!-- @domain:X END -->` block in AGENT.md, replaces it with the corresponding `## @X` section content from DOMAIN.md
   - Writes the assembled result to `nefario/AGENT.md` (overwriting the template markers with actual content)
   - Reports which sections were assembled and any missing sections
   - Uses only bash, sed, and awk -- no external dependencies
   - Content sanitization: validate that DOMAIN.md content does not contain assembly marker patterns that could cause injection

2. **Update `install.sh`** to:
   - Run `assemble.sh` before creating symlinks (assemble first, then symlink the result)
   - Accept an optional `--domain <name>` flag (default: `software-dev`)
   - Print the active domain in the install summary
   - Net change: approximately 5-10 lines added

## IMPORTANT: No disassemble.sh

Do NOT create a disassemble.sh script. This was explicitly dropped during architecture review (3 reviewers agreed it is YAGNI).

## What to produce

- `assemble.sh` -- The assembly script (make executable)
- Updated `install.sh` -- With domain assembly integration
- Brief usage documentation as comments in each script

## What NOT to do

- Do not create disassemble.sh
- Do not use any language other than bash (no Python, no Node.js)
- Do not build a config parser, validator, or registry
- Do not modify DOMAIN.md or AGENT.md content -- only consume them
- Do not add npm/pip/cargo dependencies
- Do not handle SKILL.md assembly -- SKILL.md uses section markers for in-place replacement, not automated assembly

## Design constraints

- The assembly must be idempotent: running it twice produces the same result
- The script must fail clearly if a marker in AGENT.md has no corresponding section in DOMAIN.md
- The script must preserve all non-marker content in AGENT.md exactly
- YAML frontmatter in AGENT.md is preserved as-is (assembly only affects markdown body)
- Keep it simple: this is a text substitution script, not a template engine

## Key files to read

- `/var/folders/3k/bfjvvz9s6dvdn_hvlhvr8lc00000gn/T//nefario-scratch-dV7OFI/separate-domain-orchestration-from-infra/adapter-format.md` (format spec)
- `/Users/ben/github/benpeter/2despicable/3/nefario/AGENT.md` (with assembly markers)
- `/Users/ben/github/benpeter/2despicable/3/domains/software-dev/DOMAIN.md` (the adapter)
- `/Users/ben/github/benpeter/2despicable/3/install.sh` (to be updated)

When you finish your task, mark it completed with TaskUpdate and send a message to the team lead with:
- File paths with change scope and line counts
- 1-2 sentence summary of what was produced
