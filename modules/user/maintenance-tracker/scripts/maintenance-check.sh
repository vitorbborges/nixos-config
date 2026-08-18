#!/usr/bin/env bash
# maintenance-check -- escalating reminders for calendar-based hardware maintenance.
# Tiers (toasts only, firing more often the more overdue a task gets):
#   0-6 days overdue:   normal notification,   re-nag every 24h
#   7-20 days overdue:  normal notification,   re-nag every 6h
#   21+ days overdue:   critical (sticky) notification, re-nag every 2h
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

NOW_EPOCH=$(date +%s)
tier1=()
tier2=()
tier3=()
tier1_names=()
tier2_names=()
tier3_names=()

while IFS='|' read -r name description interval_days last_ref last_nagged; do
  last_epoch=$(date -u -d "$last_ref" +%s)
  days_since=$(( (NOW_EPOCH - last_epoch) / 86400 ))
  overdue=$(( days_since - interval_days ))

  if (( overdue < 0 )); then
    continue
  fi

  hours_since_nag=999999
  if [[ -n "$last_nagged" ]]; then
    nagged_epoch=$(date -u -d "$last_nagged" +%s)
    hours_since_nag=$(( (NOW_EPOCH - nagged_epoch) / 3600 ))
  fi

  entry="${name}: ${description} (${overdue}d overdue)"

  if (( overdue >= 21 )); then
    if (( hours_since_nag >= 2 )); then
      tier3+=("$entry")
      tier3_names+=("$name")
    fi
  elif (( overdue >= 7 )); then
    if (( hours_since_nag >= 6 )); then
      tier2+=("$entry")
      tier2_names+=("$name")
    fi
  else
    if (( hours_since_nag >= 24 )); then
      tier1+=("$entry")
      tier1_names+=("$name")
    fi
  fi
done < <(sqlite3 -separator '|' "$DB" "
  SELECT t.name, t.description, t.interval_days,
         COALESCE(MAX(c.completed_at), t.created_at),
         MAX(n.last_nagged_at)
  FROM tasks t
  LEFT JOIN completions c ON c.task_id = t.id
  LEFT JOIN nag_state n ON n.task_id = t.id
  GROUP BY t.id;
")

stamp_nagged() {
  local name esc_name
  for name in "$@"; do
    esc_name=${name//\'/\'\'}
    sqlite3 "$DB" "
      INSERT INTO nag_state (task_id, last_nagged_at)
      SELECT id, datetime('now') FROM tasks WHERE name = '$esc_name'
      ON CONFLICT(task_id) DO UPDATE SET last_nagged_at = datetime('now');
    "
  done
}

if (( ${#tier1[@]} > 0 )); then
  body=$(printf -- '- %s\n' "${tier1[@]}")
  notify-send -u normal -t 15000 -i appointment-soon "Maintenance due" "$body"
  stamp_nagged "${tier1_names[@]}"
fi

if (( ${#tier2[@]} > 0 )); then
  body=$(printf -- '- %s\n' "${tier2[@]}")
  notify-send -u normal -t 20000 -i appointment-soon "Maintenance overdue" "$body"
  stamp_nagged "${tier2_names[@]}"
fi

if (( ${#tier3[@]} > 0 )); then
  body=$(printf -- '- %s\n' "${tier3[@]}")
  notify-send -u critical -t 0 -i appointment-missed "Maintenance seriously overdue" "$body"
  stamp_nagged "${tier3_names[@]}"
fi

echo "Checked $(( ${#tier1[@]} + ${#tier2[@]} + ${#tier3[@]} )) overdue task(s) needing a nag this run."
