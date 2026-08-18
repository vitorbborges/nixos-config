#!/usr/bin/env bash
# maint -- calendar-based hardware maintenance tracker (K6604JI)
# Usage: maint [status|done <task-name> [notes]|list]
set -euo pipefail

DB="${HOME}/.local/share/maintenance-tracker/maintenance.db"
mkdir -p "$(dirname "$DB")"

sqlite3 "$DB" <<'SQL'
CREATE TABLE IF NOT EXISTS tasks (
  id INTEGER PRIMARY KEY,
  name TEXT NOT NULL UNIQUE,
  category TEXT NOT NULL,
  interval_days INTEGER NOT NULL,
  description TEXT NOT NULL,
  created_at TEXT NOT NULL DEFAULT (datetime('now'))
);

CREATE TABLE IF NOT EXISTS completions (
  id INTEGER PRIMARY KEY,
  task_id INTEGER NOT NULL REFERENCES tasks(id),
  completed_at TEXT NOT NULL DEFAULT (datetime('now')),
  notes TEXT
);

CREATE TABLE IF NOT EXISTS nag_state (
  task_id INTEGER PRIMARY KEY REFERENCES tasks(id),
  last_nagged_at TEXT
);

INSERT OR IGNORE INTO tasks (name, category, interval_days, description) VALUES
  ('palm-rest-wipe',           'cleaning', 10,  'Wipe palm rest/trackpad -- skin oil buildup'),
  ('screen-clean',             'cleaning', 30,  'Clean OLED screen -- microfiber + electronics cleaner only'),
  ('keyboard-deep-clean',      'cleaning', 30,  'Keyboard compressed air + 99% IPA pass'),
  ('chassis-vent-dust',        'cleaning', 30,  'Exterior chassis/vent dust-out'),
  ('internal-dust-removal',    'internal', 270, 'Open chassis, clean fans/heatsink internally'),
  ('thermal-paste-replacement','internal', 913, 'Full repaste -- see internal-maintenance.md'),
  ('bios-firmware-check',      'software', 75,  'fwupdmgr refresh && fwupdmgr get-updates'),
  ('baseline-report-review',   'software', 180, 'Review sysdiag --history + save a fresh inxi -Fxxxz snapshot');
SQL

cmd="status"
if [[ $# -gt 0 ]]; then
  cmd="$1"
  shift
fi

case "$cmd" in
  status)
    printf '%-28s %-10s %10s   %s\n' "TASK" "CATEGORY" "DUE" "LAST ACTION"
    printf '%-28s %-10s %10s   %s\n' "----" "--------" "---" "-----------"
    sqlite3 -separator '|' "$DB" "
      SELECT t.name, t.category, t.interval_days,
             COALESCE(MAX(c.completed_at), t.created_at)
      FROM tasks t LEFT JOIN completions c ON c.task_id = t.id
      GROUP BY t.id ORDER BY t.category, t.name;
    " | while IFS='|' read -r name category interval last_ref; do
      days_since=$(( ( $(date +%s) - $(date -u -d "$last_ref" +%s) ) / 86400 ))
      due_in=$(( interval - days_since ))
      if (( due_in < 0 )); then
        due_label="OVERDUE ${due_in#-}d"
      else
        due_label="in ${due_in}d"
      fi
      printf '%-28s %-10s %10s   %s\n' "$name" "$category" "$due_label" "$last_ref"
    done
    ;;
  done)
    if [[ $# -lt 1 ]]; then
      echo "Usage: maint done <task-name> [notes]" >&2
      exit 1
    fi
    name="$1"
    notes="${2:-}"
    esc_name=${name//\'/\'\'}
    esc_notes=${notes//\'/\'\'}
    rowid=$(sqlite3 "$DB" "SELECT id FROM tasks WHERE name = '$esc_name';")
    if [[ -z "$rowid" ]]; then
      echo "Unknown task: $name (run 'maint list' to see valid names)" >&2
      exit 1
    fi
    sqlite3 "$DB" "INSERT INTO completions (task_id, notes) VALUES ($rowid, '$esc_notes');"
    sqlite3 "$DB" "DELETE FROM nag_state WHERE task_id = $rowid;"
    echo "Marked '$name' done."
    ;;
  list)
    sqlite3 -header -column "$DB" "SELECT name, category, interval_days, description FROM tasks ORDER BY category, name;"
    ;;
  *)
    echo "Usage: maint {status|done <task-name> [notes]|list}" >&2
    exit 1
    ;;
esac
