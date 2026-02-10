#!/bin/sh
# Regenerate docs/history/nefario-reports/index.md from report file YAML frontmatter.
# POSIX-compatible. No external dependencies.

set -e

SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"

# Header
{
printf '# Nefario Orchestration Reports\n\n'
printf 'Reports from nefario orchestration runs, newest first.\n\n'
printf '| Date | Time | Task | Outcome | Agents |\n'
printf '|------|------|------|---------|--------|\n'
} > "$SCRIPT_DIR/index.md.tmp"

# Collect rows: emit sortable lines, then sort and format
for f in "$SCRIPT_DIR"/????-??-??-*-*.md; do
  [ -f "$f" ] || continue
  fname="$(basename "$f")"

  date="$(grep -m1 '^date:' "$f" | sed 's/^date:[[:space:]]*//' | sed 's/[" ]//g')"
  task="$(grep -m1 '^task:' "$f" | sed 's/^task:[[:space:]]*//' | sed 's/^"//;s/"$//')"
  outcome="$(grep -m1 '^outcome:' "$f" | sed 's/^outcome:[[:space:]]*//')"
  agents="$(grep -m1 '^agents-involved:' "$f" | sed 's/^agents-involved:[[:space:]]*//' | sed 's/[][]//g' | tr ',' '\n' | grep -c '[a-z]')" 2>/dev/null || agents=0

  # Determine time display: new-format (time:) or legacy (sequence:)
  time_val="$(grep -m1 '^time:' "$f" | sed 's/^time:[[:space:]]*//' | sed 's/[" ]//g')" 2>/dev/null || true
  seq_val="$(grep -m1 '^sequence:' "$f" | sed 's/^sequence:[[:space:]]*//')" 2>/dev/null || true

  if [ -n "$time_val" ]; then
    display_time="$(printf '%s' "$time_val" | sed 's/^\(..\):\(..\).*/\1:\2/')"
    sort_key="$time_val"
  elif [ -n "$seq_val" ]; then
    display_time="$seq_val"
    sort_key="$(printf '%06d' "$seq_val" 2>/dev/null || printf '%s' "$seq_val")"
  else
    display_time="?"
    sort_key="000000"
  fi

  # Derive slug from filename: strip date prefix and sequence/time prefix
  slug="$(printf '%s' "$fname" | sed 's/\.md$//;s/^[0-9]\{4\}-[0-9]\{2\}-[0-9]\{2\}-//' | sed 's/^[0-9]*-//')"

  # Validate required fields
  if [ -z "$date" ] || [ -z "$task" ] || [ -z "$outcome" ]; then
    printf 'Warning: skipping %s (missing required frontmatter)\n' "$fname" >&2
    continue
  fi

  printf '%s\t%s\t%s\t%s\t%s\t%s\t%s\n' "$date" "$sort_key" "$display_time" "$slug" "$fname" "$outcome" "$agents"
done | sort -t"$(printf '\t')" -k1,1r -k2,2r | while IFS="$(printf '\t')" read -r date _ display_time slug fname outcome agents; do
  printf '| %s | %s | [%s](%s) | %s | %s |\n' "$date" "$display_time" "$slug" "$fname" "$outcome" "$agents"
done >> "$SCRIPT_DIR/index.md.tmp"

mv "$SCRIPT_DIR/index.md.tmp" "$SCRIPT_DIR/index.md"
