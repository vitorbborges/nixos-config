dir="$HOME/.local/share/sysdiag"
mkdir -p "$dir"
stamp=$(date '+%Y-%m-%dT%H:%M:%S')
printf '\n=== Snapshot %s ===\n' "$stamp" >> "$dir/snapshots.log"
"$SYSDIAG_BIN" --notify >> "$dir/snapshots.log" 2>&1 || true
