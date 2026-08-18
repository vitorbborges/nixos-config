nix-rebuild() {
  cd ~/nixos-config
  git add ~/nixos-config
  sudo nixos-rebuild switch --flake ~/nixos-config#desktop && \
    git commit -m "rebuild: $(date '+%Y-%m-%d %H:%M')"
}

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

# git-auto-fetch: silently fetch on every directory change into a git repo
_git_auto_fetch() {
  if git rev-parse --git-dir &>/dev/null 2>&1; then
    git fetch --all &>/dev/null &!
  fi
}
add-zsh-hook chpwd _git_auto_fetch
