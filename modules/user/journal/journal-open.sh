#!/usr/bin/env bash
# journal-open [YYYY-MM-DD]
#
# Prints the path to the given day's daily note, creating it from the
# dynamic template if it does not exist yet. On first creation, incomplete
# tasks from the most recently modified previous daily note are carried
# over: the old file's `- [ ]` lines are rewritten to
# `- [>] ... (forwarded to [[<day>]])` and appear in the new file as
# `- [ ] ... (from [[<prev-day>]])`.
#
# Env overrides: NOTES_DIR (default ~/Notes).

set -euo pipefail

# English weekday/month names in titles regardless of system locale
export LC_ALL=C

NOTES_DIR="${NOTES_DIR:-$HOME/Notes}"
DAILY_DIR="${NOTES_DIR}/06 - Daily"

if (($# > 0)); then
  day="$1"
  if ! date -d "$day" > /dev/null 2>&1; then
    echo "journal-open: invalid date '$day'" >&2
    exit 1
  fi
else
  day="$(date +%F)"
fi

file="${DAILY_DIR}/${day}.md"
mkdir -p "$DAILY_DIR"

if [[ ! -f "$file" ]]; then
  prev=""
  for f in "$DAILY_DIR"/*.md; do
    [[ -f "$f" ]] || continue
    [[ "$f" == "$file" ]] && continue
    if [[ -z "$prev" || "$f" -nt "$prev" ]]; then
      prev="$f"
    fi
  done

  carry=()
  if [[ -n "$prev" ]]; then
    prev_day="$(basename "$prev" .md)"
    mapfile -t lines < "$prev"
    for i in "${!lines[@]}"; do
      line="${lines[i]}"
      if [[ "$line" =~ ^([[:space:]]*)-[[:space:]]*\[[[:space:]]*\][[:space:]]*(.*)$ ]]; then
        indent="${BASH_REMATCH[1]}"
        rest="${BASH_REMATCH[2]}"
        carry+=("${indent}- [ ] ${rest} (from [[${prev_day}]])")
        lines[i]="${indent}- [>] ${rest} (forwarded to [[${day}]])"
      fi
    done
    if ((${#carry[@]} > 0)); then
      printf '%s\n' "${lines[@]}" > "$prev"
    fi
  fi

  weekday="$(date -d "$day" '+%A')"
  longdate="$(date -d "$day" '+%A, %B %d, %Y')"

  {
    printf -- '---\ndate: %s\nday: %s\ntags: [daily]\n---\n\n' "$day" "$weekday"
    printf '# %s\n\n' "$longdate"
    if ((${#carry[@]} > 0)); then
      printf '## Carry-over\n\n'
      printf '%s\n' "${carry[@]}"
      printf '\n'
    fi
    printf '## AM\n- **State:** \n- **Focus:** \n- **Priority:** \n\n'
    printf '## PM\n- **Highlight:** \n- **Lesson:** \n- **Tomorrow:** \n'
  } > "$file"
fi

printf '%s\n' "$file"
