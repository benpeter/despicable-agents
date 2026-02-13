#!/usr/bin/env bash

# assemble.sh — Compose a domain adapter (DOMAIN.md) with the nefario AGENT.md template
#
# Replaces assembly markers in nefario/AGENT.md with content from
# domains/<name>/DOMAIN.md. The result is a fully materialized agent prompt
# that the model sees as one coherent document.
#
# Usage:
#   ./assemble.sh                  # assemble with default domain (software-dev)
#   ./assemble.sh <domain-name>    # assemble with named domain
#
# Assembly markers in AGENT.md look like:
#   <!-- @domain:section-id BEGIN -->
#   (existing placeholder content)
#   <!-- @domain:section-id END -->
#
# Matching DOMAIN.md sections use H2 headings. The section-id maps to the
# heading via kebab-case normalization (e.g., "agent-roster" matches "## Agent Roster").
#
# Idempotent: running twice produces the same result.

set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
DOMAIN="${1:-software-dev}"
DOMAIN_FILE="${SCRIPT_DIR}/domains/${DOMAIN}/DOMAIN.md"
AGENT_FILE="${SCRIPT_DIR}/nefario/AGENT.md"

# Color output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[0;33m'
RESET='\033[0m'

# --- Validation ---

if [[ ! -f "$DOMAIN_FILE" ]]; then
  echo -e "${RED}Error: domain adapter not found: ${DOMAIN_FILE}${RESET}" >&2
  exit 1
fi

if [[ ! -f "$AGENT_FILE" ]]; then
  echo -e "${RED}Error: agent template not found: ${AGENT_FILE}${RESET}" >&2
  exit 1
fi

# Content injection guard: reject DOMAIN.md if it contains assembly markers.
# This prevents marker-in-marker injection that could corrupt the template.
if grep -qE '<!-- @domain:[a-z0-9-]+ (BEGIN|END) -->' "$DOMAIN_FILE"; then
  echo -e "${RED}Error: DOMAIN.md contains assembly marker patterns. This is not allowed.${RESET}" >&2
  grep -nE '<!-- @domain:[a-z0-9-]+ (BEGIN|END) -->' "$DOMAIN_FILE" >&2
  exit 1
fi

# --- Step 1: Extract H2 sections from DOMAIN.md into temp files ---
#
# Each section is written to $sections_dir/<kebab-case-id>.
# Skips YAML frontmatter, then captures content between H2 headings.

sections_dir=$(mktemp -d)
export SECTIONS_DIR="$sections_dir"
trap 'rm -rf "$sections_dir"' EXIT

awk '
BEGIN { fm_count = 0; fm_done = 0; cur_key = ""; outdir = ENVIRON["SECTIONS_DIR"] }

# Skip YAML frontmatter
!fm_done && $0 == "---" { fm_count++; if (fm_count == 2) fm_done = 1; next }
!fm_done && fm_count >= 1 { next }

# H2 heading (## but not ### or deeper)
/^## [^#]/ {
  if (cur_key != "") close(outdir "/" cur_key)

  heading = substr($0, 4)
  key = tolower(heading)
  gsub(/[^a-z0-9]/, "-", key)
  gsub(/-+/, "-", key)
  sub(/^-/, "", key)
  sub(/-$/, "", key)

  cur_key = key
  next
}

# Accumulate section content
cur_key != "" { print $0 > (outdir "/" cur_key) }
' "$DOMAIN_FILE"

# --- Step 2: Assemble AGENT.md ---
#
# For each BEGIN/END marker block, replace content with the matching section
# file from step 1. Markers are preserved for idempotency. Missing sections
# preserve existing content and report a warning.

tmpfile=$(mktemp)
trap 'rm -rf "$sections_dir" "$tmpfile"' EXIT

awk '
BEGIN {
  outdir = ENVIRON["SECTIONS_DIR"]; in_marker = 0; replaced = 0

  # Marker-to-section aliases: when marker id differs from DOMAIN.md heading kebab-case.
  # Format: alias[marker-id] = domain-section-id
  alias["gate-examples"] = "gate-classification-examples"
  alias["architecture-review-tables"] = "architecture-review"
  alias["post-execution-phases"] = "post-execution-pipeline"
}

# BEGIN marker
/^<!-- @domain:[a-z0-9-]+ BEGIN -->/ {
  id = $0
  sub(/^<!-- @domain:/, "", id)
  sub(/ BEGIN -->.*/, "", id)

  in_marker = 1
  print $0

  # Resolve alias if one exists
  lookup = (id in alias) ? alias[id] : id

  secfile = outdir "/" lookup
  cmd = "test -f \"" secfile "\" && echo 1 || echo 0"
  cmd | getline exists
  close(cmd)

  if (exists + 0) {
    while ((getline secline < secfile) > 0) {
      print secline
    }
    close(secfile)
    replaced = 1
    assembled++
    assembled_list = assembled_list "  [ok] " id " -> " lookup "\n"
  } else {
    replaced = 0
    missing++
    missing_list = missing_list "  [missing] " id "\n"
  }
  next
}

# END marker
/^<!-- @domain:[a-z0-9-]+ END -->/ {
  in_marker = 0
  print $0
  next
}

# Inside marker block
in_marker {
  if (!replaced) print $0
  next
}

# Outside markers: pass through
{ print $0 }

END {
  printf "  Sections assembled: %d\n", assembled > "/dev/stderr"
  if (assembled > 0) printf "%s", assembled_list > "/dev/stderr"
  if (missing > 0) {
    printf "  Missing sections (content preserved):\n" > "/dev/stderr"
    printf "%s", missing_list > "/dev/stderr"
    printf "  %d marker(s) had no matching section in DOMAIN.md\n", missing > "/dev/stderr"
  }
}
' "$AGENT_FILE" > "$tmpfile"

awk_exit=$?

cp "$tmpfile" "$AGENT_FILE"

echo -e "${GREEN}Assembly complete: ${DOMAIN} -> nefario/AGENT.md${RESET}"

exit $awk_exit
