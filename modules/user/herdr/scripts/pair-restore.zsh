# Self-healing for herdr panes that share one opencode session.
#
# herdr deduplicates native agent session restore: when two panes are anchored
# to the same session id, only the first one is relaunched with
# `opencode --session <id>` after a server restart; the other comes back as a
# bare shell and loses its anchor. This runs in every fresh pane shell inside
# herdr and, for the configured workspace pairs (parallel agents intentionally
# sharing one session), resumes the sibling pane's session and re-anchors this
# pane so future restores keep working.
#
# pairs are "workspaceA:workspaceB", one entry per shared session.

_herdr_pair_resume() {
  [[ -n "$HERDR_ENV" && -n "$HERDR_WORKSPACE_ID" && -n "$HERDR_PANE_ID" ]] || return
  [[ "$HERDR_PANE_ID" == "$HERDR_WORKSPACE_ID:p1" ]] || return

  local -a pairs=( "w14:wY" )
  local p a b sibling sess json
  for p in "${pairs[@]}"; do
    a="${p%%:*}"
    b="${p##*:}"
    sibling=""
    [[ "$HERDR_WORKSPACE_ID" == "$a" ]] && sibling="$b"
    [[ "$HERDR_WORKSPACE_ID" == "$b" ]] && sibling="$a"
    [[ -n "$sibling" ]] || continue

    # only act if this pane has no agent process yet (fresh restored shell)
    json="$("$HERDR_BIN_PATH" pane process-info --pane "$HERDR_PANE_ID" 2>/dev/null)"
    if [[ "$json" == *'"name":"zsh"'* || "$json" == *'"name":"bash"'* ]]; then
      sess=""
      for _ in 1 2 3 4 5; do
        json="$("$HERDR_BIN_PATH" pane process-info --pane "$sibling:p1" 2>/dev/null)"
        if [[ "$json" == *"opencode --session ses_"* ]]; then
          sess="${json/*opencode --session /}"
          sess="${sess%%\"*}"
          break
        fi
        sleep 1
      done
      if [[ -n "$sess" ]]; then
        # re-anchor this pane so the next shutdown/restore keeps working
        printf '{"id":"pair-restore","method":"pane.report_agent_session","params":{"pane_id":"%s","source":"herdr:opencode","agent":"opencode","seq":%d,"agent_session_id":"%s","session_start_source":"startup"}}\n' \
          "$HERDR_PANE_ID" "$(( $(date +%s) * 1000 ))" "$sess" |
          nc -U "$HERDR_SOCKET_PATH" >/dev/null 2>&1
        exec opencode --session "$sess"
      fi
    fi
  done
}

_herdr_pair_resume
unfunction _herdr_pair_resume
