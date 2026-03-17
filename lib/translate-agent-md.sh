#!/usr/bin/env bash
# tva
# translate-agent-md.sh -- AGENT.md instruction translator
# Converts AGENT.md files (YAML frontmatter + Claude Code-specific content) into
# tool-native instruction files for external harnesses (Codex CLI, Aider).
#
# Exit codes:
#   0 -- success (translated file written, frontmatter JSON on stdout)
#   1 -- validation/processing error (file not found, malformed frontmatter, write failure)
#   2 -- usage error (missing required flags, unknown flags, invalid --format)
#
# Usage:
#   translate-agent-md.sh --agent-md PATH --format FORMAT --output PATH
#
# Options:
#   --agent-md PATH     Path to the source AGENT.md file
#   --format FORMAT     Target format: "agents-md" or "conventions-md"
#   --output PATH       Output file path (caller-provided, typically in a session temp dir)

set -euo pipefail

# ---------------------------------------------------------------------------
# Constants
# ---------------------------------------------------------------------------

VALID_FORMATS="agents-md conventions-md"

# ---------------------------------------------------------------------------
# Argument parsing
# ---------------------------------------------------------------------------

ARG_AGENT_MD=""
ARG_FORMAT=""
ARG_OUTPUT=""

while [ $# -gt 0 ]; do
  case "$1" in
    --agent-md)
      [ $# -lt 2 ] && { echo "Error: --agent-md requires a value" >&2; exit 2; }
      ARG_AGENT_MD="$2"
      shift 2
      ;;
    --format)
      [ $# -lt 2 ] && { echo "Error: --format requires a value" >&2; exit 2; }
      ARG_FORMAT="$2"
      shift 2
      ;;
    --output)
      [ $# -lt 2 ] && { echo "Error: --output requires a value" >&2; exit 2; }
      ARG_OUTPUT="$2"
      shift 2
      ;;
    --help|-h)
      cat >&2 <<'EOF'
translate-agent-md.sh -- AGENT.md instruction translator

Usage:
  translate-agent-md.sh --agent-md PATH --format FORMAT --output PATH

Required:
  --agent-md PATH     Path to the source AGENT.md file
  --format FORMAT     Target format: "agents-md" or "conventions-md"
  --output PATH       Output file path (caller-provided, typically in a session temp dir)

Exit codes:
  0  Success -- translated file written, frontmatter JSON on stdout
  1  Validation/processing error (file not found, malformed frontmatter, write failure)
  2  Usage error (missing required flags, unknown flags, invalid --format)

Examples:
  translate-agent-md.sh \
    --agent-md ./gru/AGENT.md \
    --format agents-md \
    --output /tmp/session-abc/gru.AGENTS.md

  translate-agent-md.sh \
    --agent-md ./minions/devx-minion/AGENT.md \
    --format conventions-md \
    --output /tmp/session-abc/devx-minion.CONVENTIONS.md
EOF
      exit 0
      ;;
    *)
      echo "Error: Unknown argument: $1" >&2
      echo "" >&2
      echo "Usage: translate-agent-md.sh --agent-md PATH --format FORMAT --output PATH" >&2
      exit 2
      ;;
  esac
done

# Validate required arguments
missing_args=""
if [ -z "$ARG_AGENT_MD" ]; then
  missing_args="${missing_args}  --agent-md is required\n"
fi
if [ -z "$ARG_FORMAT" ]; then
  missing_args="${missing_args}  --format is required\n"
fi
if [ -z "$ARG_OUTPUT" ]; then
  missing_args="${missing_args}  --output is required\n"
fi

if [ -n "$missing_args" ]; then
  echo "Error: Missing required arguments" >&2
  echo "" >&2
  printf "%b" "$missing_args" >&2
  echo "" >&2
  echo "Usage: translate-agent-md.sh --agent-md PATH --format FORMAT --output PATH" >&2
  exit 2
fi

# Validate --format
valid_format=0
for f in $VALID_FORMATS; do
  if [ "$ARG_FORMAT" = "$f" ]; then
    valid_format=1
    break
  fi
done
if [ "$valid_format" -eq 0 ]; then
  echo "Error: Invalid --format value: $ARG_FORMAT" >&2
  echo "" >&2
  echo "  got: $ARG_FORMAT" >&2
  echo "  valid: agents-md, conventions-md" >&2
  echo "" >&2
  echo "Use --format agents-md for Codex CLI (AGENTS.md) or --format conventions-md for Aider (CONVENTIONS.md)." >&2
  exit 2
fi

# ---------------------------------------------------------------------------
# Locate the sed patterns file relative to this script
# ---------------------------------------------------------------------------

SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
SED_PATTERNS_FILE="${SCRIPT_DIR}/claude-code-patterns.sed"

if [ ! -f "$SED_PATTERNS_FILE" ]; then
  echo "Error: Sed patterns file not found" >&2
  echo "" >&2
  echo "  expected: $SED_PATTERNS_FILE" >&2
  echo "" >&2
  echo "Ensure claude-code-patterns.sed exists in the same directory as translate-agent-md.sh." >&2
  exit 1
fi

# ---------------------------------------------------------------------------
# Validate source file
# ---------------------------------------------------------------------------

if [ ! -e "$ARG_AGENT_MD" ]; then
  echo "Error: Source AGENT.md file not found" >&2
  echo "" >&2
  echo "  path: $ARG_AGENT_MD" >&2
  echo "" >&2
  echo "Check the path and try again." >&2
  exit 1
fi

if [ ! -f "$ARG_AGENT_MD" ]; then
  echo "Error: Source AGENT.md path is not a regular file" >&2
  echo "" >&2
  echo "  path: $ARG_AGENT_MD" >&2
  echo "" >&2
  echo "Provide a path to an AGENT.md file, not a directory." >&2
  exit 1
fi

if [ ! -r "$ARG_AGENT_MD" ]; then
  echo "Error: Source AGENT.md file is not readable" >&2
  echo "" >&2
  echo "  path: $ARG_AGENT_MD" >&2
  echo "" >&2
  echo "Check file permissions." >&2
  exit 1
fi

# Reject binary content (null bytes only -- UTF-8 multi-byte chars are valid)
# Use tr/cmp for portability (grep -P is GNU-only, not available on macOS)
if ! LC_ALL=C tr -d '\0' < "$ARG_AGENT_MD" | cmp -s - "$ARG_AGENT_MD"; then
  echo "Error: Source file contains null bytes" >&2
  echo "" >&2
  echo "  path: $ARG_AGENT_MD" >&2
  echo "" >&2
  echo "AGENT.md must be a plain text file." >&2
  exit 1
fi

# ---------------------------------------------------------------------------
# Validate output path (parent directory must exist)
# ---------------------------------------------------------------------------

output_dir="$(dirname "$ARG_OUTPUT")"
if [ ! -d "$output_dir" ]; then
  echo "Error: Output directory does not exist" >&2
  echo "" >&2
  echo "  path: $ARG_OUTPUT" >&2
  echo "  directory: $output_dir" >&2
  echo "" >&2
  echo "Create the output directory before calling translate-agent-md.sh, or use a different output path." >&2
  exit 1
fi

# ---------------------------------------------------------------------------
# Frontmatter extraction (awk)
# ---------------------------------------------------------------------------
# Parse the YAML frontmatter block (first ---...--- at start of file).
# Extract: name, model, tools, description (with > folded scalar support).
# Emits key=value pairs on stdout, one per line, with keys prefixed by FM_.

extract_frontmatter() {
  local file="$1"
  awk '
    BEGIN {
      in_front = 0
      found_open = 0
      found_close = 0
      in_desc_fold = 0
      name_val = ""
      model_val = ""
      tools_val = ""
      desc_lines = ""
      desc_val = ""
    }

    # Line 1 must be "---" for frontmatter to exist
    NR == 1 {
      if ($0 == "---") {
        in_front = 1
        found_open = 1
        next
      } else {
        # No frontmatter: signal caller with special marker and exit
        print "NO_FRONTMATTER"
        exit 0
      }
    }

    in_front && /^---$/ {
      found_close = 1
      in_front = 0
      next
    }

    in_front {
      # End any description fold on non-indented non-empty line
      if (in_desc_fold) {
        if (/^[[:space:]]/ || /^[[:space:]]*$/) {
          # Continuation or blank line: append to desc_lines (trim leading spaces)
          line = $0
          gsub(/^[[:space:]]+/, "", line)
          if (line != "") {
            if (desc_lines == "") {
              desc_lines = line
            } else {
              desc_lines = desc_lines " " line
            }
          }
          next
        } else {
          # Non-indented line: fold is done, fall through to normal parsing
          in_desc_fold = 0
          desc_val = desc_lines
        }
      }

      if (/^name:[[:space:]]/) {
        val = $0
        gsub(/^name:[[:space:]]*/, "", val)
        name_val = val
      } else if (/^model:[[:space:]]/) {
        val = $0
        gsub(/^model:[[:space:]]*/, "", val)
        model_val = val
      } else if (/^tools:[[:space:]]/) {
        val = $0
        gsub(/^tools:[[:space:]]*/, "", val)
        tools_val = val
      } else if (/^description:[[:space:]]*>$/ || /^description:[[:space:]]+>$/) {
        # Folded scalar: next indented lines are the value
        in_desc_fold = 1
        desc_lines = ""
      } else if (/^description:[[:space:]]/) {
        # Inline description value
        val = $0
        gsub(/^description:[[:space:]]*/, "", val)
        desc_val = val
      }
      next
    }

    # Past frontmatter: stop reading
    !in_front && found_close {
      exit 0
    }

    END {
      if (found_open && !found_close) {
        print "FRONTMATTER_UNCLOSED"
        exit 0
      }
      # Flush any pending fold
      if (in_desc_fold && desc_lines != "") {
        desc_val = desc_lines
      }
      print "FM_name=" name_val
      print "FM_model=" model_val
      print "FM_tools=" tools_val
      print "FM_description=" desc_val
    }
  ' "$file"
}

# ---------------------------------------------------------------------------
# JSON escape helper (printf-based, no jq)
# ---------------------------------------------------------------------------

json_escape() {
  local raw="$1"
  # Escape backslash first, then double-quote, then control chars
  local escaped
  escaped="$(printf '%s' "$raw" | sed \
    -e 's/\\/\\\\/g' \
    -e 's/"/\\"/g' \
    -e 's/'"$(printf '\t')"'/\\t/g' \
  )"
  printf '%s' "$escaped"
}

# ---------------------------------------------------------------------------
# Parse frontmatter
# ---------------------------------------------------------------------------

fm_output="$(extract_frontmatter "$ARG_AGENT_MD")"

# Handle special cases
if [ "$fm_output" = "NO_FRONTMATTER" ]; then
  HAS_FRONTMATTER=0
  FM_name=""
  FM_model=""
  FM_tools=""
  FM_description=""
elif printf '%s\n' "$fm_output" | grep -q "^FRONTMATTER_UNCLOSED$"; then
  echo "Error: Malformed frontmatter in AGENT.md" >&2
  echo "" >&2
  echo "  in: $ARG_AGENT_MD" >&2
  echo "" >&2
  echo "The file starts with '---' but no closing '---' was found." >&2
  echo "Add a closing '---' line to end the frontmatter block." >&2
  exit 1
else
  HAS_FRONTMATTER=1
  # Extract individual fields from awk output
  FM_name=""
  FM_model=""
  FM_tools=""
  FM_description=""

  while IFS= read -r line; do
    case "$line" in
      FM_name=*)      FM_name="${line#FM_name=}" ;;
      FM_model=*)     FM_model="${line#FM_model=}" ;;
      FM_tools=*)     FM_tools="${line#FM_tools=}" ;;
      FM_description=*) FM_description="${line#FM_description=}" ;;
    esac
  done <<EOF
$fm_output
EOF
fi

# ---------------------------------------------------------------------------
# Build frontmatter JSON (printf-based, no jq)
# ---------------------------------------------------------------------------

build_frontmatter_json() {
  local name="$1"
  local model="$2"
  local tools="$3"
  local description="$4"

  local fields=""
  local sep=""

  if [ -n "$name" ]; then
    esc="$(json_escape "$name")"
    fields="${fields}${sep}\"name\":\"${esc}\""
    sep=","
  fi
  if [ -n "$model" ]; then
    esc="$(json_escape "$model")"
    fields="${fields}${sep}\"model\":\"${esc}\""
    sep=","
  fi
  if [ -n "$tools" ]; then
    esc="$(json_escape "$tools")"
    fields="${fields}${sep}\"tools\":\"${esc}\""
    sep=","
  fi
  if [ -n "$description" ]; then
    esc="$(json_escape "$description")"
    fields="${fields}${sep}\"description\":\"${esc}\""
    sep=","
  fi

  printf '{%s}\n' "$fields"
}

# ---------------------------------------------------------------------------
# Body extraction (awk): strip frontmatter, then apply section-level removal
# ---------------------------------------------------------------------------
# Stage 1a: Strip the YAML frontmatter block from the body.
# Stage 1b: Remove the "## Main Agent Mode" section and everything until the
#           next ## heading or end of file.

extract_body() {
  local file="$1"
  local has_fm="$2"

  awk -v has_fm="$has_fm" '
    BEGIN {
      in_front = 0
      past_front = 0
      skip_main_agent = 0
    }

    NR == 1 {
      if (has_fm == "1" && $0 == "---") {
        in_front = 1
        next
      }
      # No frontmatter: pass through from line 1
      past_front = 1
    }

    in_front && /^---$/ {
      in_front = 0
      past_front = 1
      next
    }

    in_front {
      next
    }

    past_front {
      # Section-level removal: ## Main Agent Mode (and variants like "## Main Agent Mode (Fallback)")
      if (/^## Main Agent Mode/) {
        skip_main_agent = 1
        next
      }

      # End of skipped section: next ## heading
      if (skip_main_agent && /^## /) {
        skip_main_agent = 0
        # Fall through to print this heading
      }

      if (skip_main_agent) {
        next
      }

      # Paragraph-level removal: skip until next blank line when a line
      # triggers a known multi-line Claude Code runtime reference.
      # Trigger: "If you find yourself with the Task tool available"
      if (/If you find yourself with the Task tool available/) {
        skip_until_blank = 1
        next
      }

      if (skip_until_blank) {
        if (/^[[:space:]]*$/) {
          skip_until_blank = 0
          print
        }
        next
      }

      print
    }
  ' "$file"
}

# ---------------------------------------------------------------------------
# Apply sed pattern stripping (stage 2)
# ---------------------------------------------------------------------------

apply_sed_patterns() {
  sed -f "$SED_PATTERNS_FILE"
}

# ---------------------------------------------------------------------------
# Post-translation validation
# ---------------------------------------------------------------------------

validate_output() {
  local content="$1"
  local source_path="$2"

  # Check non-empty
  local trimmed
  trimmed="$(printf '%s' "$content" | tr -d '[:space:]')"
  if [ -z "$trimmed" ]; then
    echo "Error: Translation produced empty output" >&2
    echo "" >&2
    echo "  source: $source_path" >&2
    echo "" >&2
    echo "The AGENT.md body is empty after stripping frontmatter and Claude Code-specific content." >&2
    exit 1
  fi

  # Check no residual frontmatter (first 3 lines must not start with ---)
  local line1 line2 line3
  line1="$(printf '%s\n' "$content" | sed -n '1p')"
  line2="$(printf '%s\n' "$content" | sed -n '2p')"
  line3="$(printf '%s\n' "$content" | sed -n '3p')"
  if [ "$line1" = "---" ] || [ "$line2" = "---" ] || [ "$line3" = "---" ]; then
    echo "Error: Translated output contains residual frontmatter" >&2
    echo "" >&2
    echo "  source: $source_path" >&2
    echo "" >&2
    echo "The output starts with '---' in the first 3 lines. Check the frontmatter stripping logic." >&2
    exit 1
  fi

  # Check no null bytes (UTF-8 multi-byte chars are valid)
  # Use tr/cmp for portability (grep -P is GNU-only)
  local content_file
  content_file="$(mktemp "${TMPDIR:-/tmp}/translate-validate-XXXXXX")"
  printf '%s' "$content" > "$content_file"
  local has_null=false
  if ! LC_ALL=C tr -d '\0' < "$content_file" | cmp -s - "$content_file"; then
    has_null=true
  fi
  rm -f "$content_file"
  if $has_null; then
    echo "Error: Translated output contains null bytes" >&2
    echo "" >&2
    echo "  source: $source_path" >&2
    echo "" >&2
    echo "AGENT.md must be a plain text file." >&2
    exit 1
  fi
}

# ---------------------------------------------------------------------------
# Main translation pipeline
# ---------------------------------------------------------------------------

# Step 1: Extract and strip body (frontmatter + Main Agent Mode section)
raw_body="$(extract_body "$ARG_AGENT_MD" "$HAS_FRONTMATTER")"

# Step 2: Apply sed pattern stripping
translated_body="$(printf '%s\n' "$raw_body" | apply_sed_patterns)"

# Step 3: Apply format-specific prefix
source_basename="$(basename "$ARG_AGENT_MD")"
case "$ARG_FORMAT" in
  agents-md)
    final_content="$translated_body"
    ;;
  conventions-md)
    final_content="<!-- Translated from: ${source_basename} -->
${translated_body}"
    ;;
esac

# Step 4: Post-translation validation
validate_output "$final_content" "$ARG_AGENT_MD"

# Step 5: Write output with restricted permissions
(
  umask 077
  printf '%s\n' "$final_content" > "$ARG_OUTPUT"
) || {
  echo "Error: Failed to write output file" >&2
  echo "" >&2
  echo "  path: $ARG_OUTPUT" >&2
  echo "" >&2
  echo "Check that the output directory exists and is writable." >&2
  exit 1
}

# Step 6: Emit frontmatter JSON to stdout
if [ "$HAS_FRONTMATTER" -eq 0 ]; then
  printf '{}\n'
else
  build_frontmatter_json "$FM_name" "$FM_model" "$FM_tools" "$FM_description"
fi
