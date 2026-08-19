#!/usr/bin/env bash
# Watchdog for opencode-web: stops the service when no browser tab is
# connected to port 4096. A closed tab closes all its TCP connections
# (including the WebSocket), so zero established connections ⇒ idle.
IDLE_CHECKS=3      # 3 consecutive zero-connection checks before stopping
CHECK_INTERVAL=10  # seconds between checks

idle=0
while true; do
  sleep "$CHECK_INTERVAL"
  conns=$(ss -Htn state established '( sport = :4096 )' 2>/dev/null | wc -l)
  if [ "$conns" -eq 0 ]; then
    idle=$((idle + 1))
  else
    idle=0
  fi
  if [ "$idle" -ge "$IDLE_CHECKS" ]; then
    systemctl --user stop opencode-web
    exit 0
  fi
done
