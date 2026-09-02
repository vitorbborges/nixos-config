# Investment recipe reminder — fires notify-send only when connectivity is verified.
# NEVER fails: every exit path returns 0, so systemd never records a failure
# and nothing surfaces on the login screen.

set -uo pipefail

RECIPE="$1"   # recipe file name, e.g. passive_tr_sync.md
LABEL="$2"    # human-readable title, e.g. "Trade Republic Sync"
HINT="$3"     # optional extra guidance line (may be empty)

# --- Strict connectivity gate -----------------------------------------------
# Wait for NM's own connectivity check (settings.connectivity → nmcheck.gnome.org)
# to report "full". This is stricter than a bare curl: it validates the default
# route AND NM's captive-portal detection. Wifi coming up on resume is covered
# by the retry budget; if it never verifies, we stay silent.
STATE=""
for _ in $(seq 1 20); do
  STATE=$("@nmcli@" networking connectivity check 2>/dev/null || true)
  [ "$STATE" = "full" ] && break
  sleep 5
done

if [ "$STATE" != "full" ]; then
  # Silent skip: no notification, no journal output, exit 0 → no failure state.
  exit 0
fi

# --- Reminder ----------------------------------------------------------------
BODY="Recipe: recipes/$RECIPE
Run in @investmentsDir@: claude < recipes/$RECIPE"

if [ -n "$HINT" ]; then
  BODY="$BODY

Hint: $HINT"
fi

"@notifySend@" -a "Investments" -u normal "Investments: $LABEL" "$BODY" >/dev/null 2>&1 || true
exit 0
