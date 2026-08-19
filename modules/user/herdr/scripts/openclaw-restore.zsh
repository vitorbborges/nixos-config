# Auto-launch openclaw tui in designated herdr workspaces after restore.
#
# Mirrors pair-restore.zsh: runs in every fresh pane shell inside herdr
# (HERDR_ENV=1) and claims the pane for the OpenClaw TUI when the workspace is
# on the allowlist (HERDR_OPENCLAW_WORKSPACES, space-separated labels).
#
# Each workspace gets its own gateway session keyed by its label, so every
# herdr pane keeps an independent OpenClaw session that survives reboots:
#   openclaw tui --session <sanitized-label>
#
# Before launching, this registers the pane with herdr as a live OpenClaw
# agent (source custom:openclaw) and persists a session->pane map at
# ~/.openclaw/herdr-panes.json so the gateway "herdr-status" hook can later
# flip working/idle state on message activity.
#
# herdr restores recognized agents (opencode, ...) natively, so this only
# fires in panes that came back as a bare shell — i.e. workspaces that are
# not running a herdr-known agent. Stop/release any agent in the pane once
# for the hook to claim it on the next restore.

_HERDR_OC_PANES="$HOME/.openclaw/herdr-panes.json"
# Prefer the in-pane bin path; fall back to an absolute PATH resolution so the
# gateway hook (which may lack herdr on its PATH) gets a real binary path.
_HERDR_OC_BIN="${HERDR_BIN_PATH:-$(command -v herdr 2>/dev/null || printf herdr)}"

# Register this pane as a live OpenClaw agent and persist the session->pane map.
_herdr_openclaw_register() {
  local label="$1" sk="$2" pane="$3"
  [[ -n "$label" && -n "$sk" && -n "$pane" ]] || return

  mkdir -p "$HOME/.openclaw"
  [[ -f "$_HERDR_OC_PANES" ]] || printf '{}' > "$_HERDR_OC_PANES"

  local tmp="$HOME/.openclaw/herdr-panes.json.tmp"
  jq --arg k "$sk" \
     --arg label "$label" \
     --arg pane "$pane" \
     --arg bin "$_HERDR_OC_BIN" \
     --arg socket "${HERDR_SOCKET_PATH:-$HOME/.config/herdr/herdr.sock}" \
     '.[$k] = { label: $label, pane_id: $pane, bin: $bin, socket: $socket, reported: "idle" }' \
     "$_HERDR_OC_PANES" > "$tmp" && mv "$tmp" "$_HERDR_OC_PANES"

  # tell herdr this pane is a live custom agent (idle at launch)
  "$_HERDR_OC_BIN" pane report-agent --source custom:openclaw --agent "openclaw" \
    --state idle --agent-session-id "$sk" "$pane" >/dev/null 2>&1 || true
}

_herdr_openclaw_resume() {
  [[ -n "$HERDR_ENV" && -n "$HERDR_WORKSPACE_ID" && -n "$HERDR_PANE_ID" ]] || return
  [[ -n "$HERDR_OPENCLAW_WORKSPACES" ]] || return
  [[ "$HERDR_PANE_ID" == "$HERDR_WORKSPACE_ID:p1" ]] || return

  # only act if this pane is a fresh restored shell (no process yet)
  local json
  json="$("$HERDR_OC_BIN" pane process-info --pane "$HERDR_PANE_ID" 2>/dev/null)"
  [[ "$json" == *'"name":"zsh"'* || "$json" == *'"name":"bash"'* ]] || return

  # resolve this workspace's label, then match it against the allowlist
  local ws_json label ws
  ws_json="$("$HERDR_OC_BIN" workspace list 2>/dev/null)"
  label="$(printf '%s' "$ws_json" | jq -r --arg wid "$HERDR_WORKSPACE_ID" \
    '.result.workspaces[] | select(.workspace_id==$wid) | .label' 2>/dev/null)"
  [[ -n "$label" ]] || return
  for ws in ${=HERDR_OPENCLAW_WORKSPACES}; do
    [[ "$ws" == "$label" ]] || continue
    # session key per workspace: labels are stable, sanitize to a key
    local session_key
    session_key="$(printf '%s' "$label" | tr '[:upper:] ' '[:lower:]-')"
    _herdr_openclaw_register "$label" "$session_key" "$HERDR_PANE_ID"
    exec openclaw tui --session "$session_key"
    return
  done
}

_herdr_openclaw_resume
unfunction _herdr_openclaw_resume _herdr_openclaw_register
