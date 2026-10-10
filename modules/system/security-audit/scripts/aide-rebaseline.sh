set +e

generation="${1:-}"
marker="/var/lib/aide/.last-generation"

if [ -z "$generation" ]; then
  generation="$(readlink -f /run/current-system 2>/dev/null)"
fi

if [ -f "$marker" ] && [ "$(cat "$marker" 2>/dev/null)" = "$generation" ]; then
  exit 0
fi

mkdir -p /var/lib/aide

{
  printf '===== %s (generation %s) =====\n' "$(date '+%Y-%m-%d %H:%M:%S')" "$generation"
  aide --check --config /etc/aide.conf 2>&1 || true
} >> /var/log/aide-rebaseline.log 2>&1

if aide --init --config /etc/aide.conf >> /var/log/aide-rebaseline.log 2>&1; then
  mv -f /var/lib/aide/aide.db.new.gz /var/lib/aide/aide.db.gz
  printf '%s\n' "$generation" > "$marker"
else
  printf 'rebaseline failed at %s\n' "$(date '+%Y-%m-%d %H:%M:%S')" >> /var/log/aide-rebaseline.log 2>&1
fi

exit 0
