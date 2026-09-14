set -euo pipefail

[ "$#" -gt 0 ] || exit 2

# Already running: a warm open goes through VS Code's extension-aware editor
# resolver, so custom editors (Table Viewer for xlsx) activate reliably.
if pgrep -x codium >/dev/null 2>&1; then
  exec codium "$@"
fi

# Cold start: opening a file in the very first window is racy — VS Code can
# resolve it before custom editors are registered and fall back to the binary
# text placeholder, which never re-resolves. Start an empty window, wait for
# the instance to accept IPC, then open the file warm.
codium --new-window >/dev/null 2>&1 &

for _ in $(seq 1 150); do
  codium --status >/dev/null 2>&1 && break
  sleep 0.2
done

sleep 1
exec codium "$@"
