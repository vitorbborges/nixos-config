{ pkgs, ... }:

{
  programs.zsh = {
    enable = true;
    enableCompletion = true;
    autosuggestion.enable = true;
    syntaxHighlighting.enable = true;

    shellAliases = {
      ls    = "eza --icons --git --group-directories-first -l -T -L=1";
      cat   = "bat";
      mamba = "micromamba";
      man   = "tldr";
    };

    history = {
      size          = 10000;
      path          = "$HOME/.zsh_history";
      ignoreDups    = true;
      ignoreAllDups = true;
      ignoreSpace   = true;
      share         = true;
    };

    plugins = [
      {
        name = "zsh-vi-mode";
        src  = pkgs.zsh-vi-mode;
        file = "share/zsh-vi-mode/zsh-vi-mode.plugin.zsh";
      }
      {
        name = "zsh-nix-shell";
        src  = pkgs.zsh-nix-shell;
        file = "share/zsh-nix-shell/nix-shell.plugin.zsh";
      }
      {
        name = "fzf-tab";
        src  = pkgs.zsh-fzf-tab;
        file = "share/fzf-tab/fzf-tab.plugin.zsh";
      }
      {
        name = "zsh-history-substring-search";
        src  = pkgs.zsh-history-substring-search;
        file = "share/zsh-history-substring-search/zsh-history-substring-search.zsh";
      }
    ];

    initContent = ''
      # ── fzf-tab completions ──────────────────────────────────────────
      zstyle ':completion:*' menu no
      zstyle ':completion:*' list-colors "''${(s.:.)LS_COLORS}"
      zstyle ':fzf-tab:complete:cd:*'         fzf-preview 'eza --color=always $realpath'
      zstyle ':fzf-tab:complete:__zoxide_z:*' fzf-preview 'eza --color=always $realpath'

      # ── zsh-vi-mode overwrites Ctrl+R; restore fzf + history bindings
      # after vi-mode finishes its own init (zvm_after_init_commands runs
      # just before the first prompt, after the full .zshrc is sourced).
      zvm_after_init_commands+=(
        'source ${pkgs.fzf}/share/fzf/key-bindings.zsh'
        'bindkey "^p" history-substring-search-backward'
        'bindkey "^n" history-substring-search-forward'
        # Esc Esc → prepend/strip sudo (replaces oh-my-zsh sudo plugin)
        'bindkey "^[^[" sudo-command-line'
      )

      # sudo plugin replacement: toggle sudo prefix on current command
      sudo-command-line() {
        [[ -z $BUFFER ]] && zle up-history
        if [[ $BUFFER == sudo\ * ]]; then
          LBUFFER="''${LBUFFER#sudo }"
        else
          LBUFFER="sudo $LBUFFER"
        fi
      }
      zle -N sudo-command-line

      # git-auto-fetch: silently fetch on every directory change into a git repo
      _git_auto_fetch() {
        if git rev-parse --git-dir &>/dev/null 2>&1; then
          git fetch --all &>/dev/null &!
        fi
      }
      add-zsh-hook chpwd _git_auto_fetch
    '';
  };

  # enableZshIntegration sources completion.zsh (needed for ** expansion and
  # fzf-tab); key-bindings.zsh is re-sourced via zvm_after_init_commands above
  # so Ctrl+R always uses fzf, never bck-i-search or atuin.
  programs.fzf = {
    enable = true;
    enableZshIntegration = true;
    defaultOptions = [ "--height=40%" "--layout=reverse" "--border" ];
  };

  programs.eza = {
    enable = true;
    enableZshIntegration = true;
    extraOptions = [ "--group-directories-first" ];
    git   = true;
    icons = "always";
  };

  services.tldr-update.enable = true;

  home.packages = with pkgs; [
    tldr
    fastfetch
    zoxide
  ];

  programs.zoxide = {
    enable = true;
    enableZshIntegration = true;
  };

  # Starship prompt — replaces oh-my-zsh "fox" theme; stylix themes it automatically
  programs.starship.enable = true;
}
