# ── history hardening ─────────────────────────────────────────────
# A single NUL byte in a history line makes zsh refuse the whole file
# ("corrupt history file") in every shell that reads it. zsh never
# writes NULs itself — they come from outside the shell (session
# restore replaying terminal output, etc.). Strip them before zsh's
# first history read so one bad byte can't spam errors everywhere.
_hist_strip_nuls() {
  [[ -f $HISTFILE ]] || return
  if LC_ALL=C tr -cd '\0' < "$HISTFILE" | grep -qa .; then
    tr -d '\0' < "$HISTFILE" > "$HISTFILE.clean" && mv "$HISTFILE.clean" "$HISTFILE"
  fi
}
_hist_strip_nuls

# Reject history entries containing raw control characters (terminal
# output replayed into input by session restore/paste, etc.) so junk
# never reaches the history file.
_hist_reject_control() {
  [[ "$1" == *[$'\001'-$'\010'$'\013'$'\014'$'\016'-$'\037'$'\177']* ]] && return 1
  return 0
}
add-zsh-hook zshaddhistory _hist_reject_control

nix-update() (
  set -e
  cd ~/nixos-config
  nix flake update
  sudo nixos-rebuild switch --flake ~/nixos-config#desktop
  git add flake.lock
  git commit -m "chore: bump flake inputs"
  mkdir -p ~/.local/share
  date +%s > ~/.local/share/nix-update-last
)

# ── fzf-tab completions ──────────────────────────────────────────
zstyle ':completion:*' menu no
zstyle ':completion:*' list-colors "${(s.:.)LS_COLORS}"
zstyle ':fzf-tab:complete:cd:*'         fzf-preview 'eza --color=always $realpath'
zstyle ':fzf-tab:complete:__zoxide_z:*' fzf-preview 'eza --color=always $realpath'

# ── zsh-vi-mode re-bindings (Ctrl+R, history, sudo) ──────────────
# These run inside zvm_after_init_commands so they execute after
# vi-mode finishes its own init.
zvm_after_init_commands+=(
  __ZVM_FZF_SOURCE__

  'bindkey "^p" history-substring-search-backward'
  'bindkey "^n" history-substring-search-forward'
  # Esc Esc → prepend/strip sudo (replaces oh-my-zsh sudo plugin)
  'bindkey "^[^[" sudo-command-line'
)

# sudo plugin replacement: toggle sudo prefix on current command
sudo-command-line() {
  [[ -z $BUFFER ]] && zle up-history
  if [[ $BUFFER == sudo\ * ]]; then
    LBUFFER="${LBUFFER#sudo }"
  else
    LBUFFER="sudo $LBUFFER"
  fi
}
zle -N sudo-command-line

# Load optional API keys (file is not tracked by git)
[[ -f "$HOME/.config/secrets/api-keys.sh" ]] && source "$HOME/.config/secrets/api-keys.sh"

# Load gateway/provider secrets for interactive shells (env-file format, not
# tracked by git). Exports OPENCLAW_GATEWAY_TOKEN so CLI tools (dashboard,
# status, tui, gateway) can resolve the gateway SecretRef and authenticate.
# set -a / set +a exports the assignments sourced from this file.
if [[ -f "$HOME/.secrets/openclaw-gateway-token.env" ]]; then
  set -a
  source "$HOME/.secrets/openclaw-gateway-token.env"
  set +a
fi

# git-auto-fetch: silently fetch on every directory change into a git repo
_git_auto_fetch() {
  if git rev-parse --git-dir &>/dev/null 2>&1; then
    git fetch --all &>/dev/null &!
  fi
}
add-zsh-hook chpwd _git_auto_fetch
