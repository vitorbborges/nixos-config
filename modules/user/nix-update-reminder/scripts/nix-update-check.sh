STAMP="$HOME/.local/share/nix-update-last"
THRESHOLD=7

if [ ! -f "$STAMP" ]; then
  notify-send \
    --urgency=normal \
    --icon=system-software-update \
    'NixOS Update Reminder' \
    'No update recorded yet. Run nix-update to keep your system fresh!'
  exit 0
fi

LAST=$(cat "$STAMP")
NOW=$(date +%s)
DAYS=$(( (NOW - LAST) / 86400 ))

if [ "$DAYS" -ge "$THRESHOLD" ]; then
  notify-send \
    --urgency=normal \
    --icon=system-software-update \
    'NixOS Update Reminder' \
    "It's been ${DAYS} days since your last update. Run nix-update!"
fi
