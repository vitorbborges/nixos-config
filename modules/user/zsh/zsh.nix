{ pkgs, config, ... }:

let
  cfg = "${config.home.homeDirectory}/nixos-config";
in
{
  programs.zsh = {
    enable = true;
    dotDir = config.home.homeDirectory;
    enableCompletion = true;
    autosuggestion.enable = true;
    syntaxHighlighting.enable = true;

    shellAliases = {
      ls    = "eza --icons --git --group-directories-first -l -T -L=1";
      cat   = "bat";
      mamba = "micromamba";
      man   = "tldr";
      nr    = "sudo nixos-rebuild switch --flake ${cfg}#desktop";
      nrc   = "git add ${cfg} && sudo nixos-rebuild switch --flake ${cfg}#desktop && git -C ${cfg} commit -m \"$(date '+%Y-%m-%d %H:%M:%S')\" && git -C ${cfg} push";
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

    # Custom functions, zstyle completions, vi-mode re-bindings, sudo widget
    # and git-auto-fetch hook live in ./init.zsh. The fzf key-bindings source
    # path is a Nix store path, injected at eval time via replaceStrings.
    initContent = builtins.replaceStrings
      [ "__ZVM_FZF_SOURCE__" ]
      [ "'source ${pkgs.fzf}/share/fzf/key-bindings.zsh'" ]
      (builtins.readFile ./init.zsh);
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
    bat
  ];

  programs.zoxide = {
    enable = true;
    enableZshIntegration = true;
  };

  # Starship prompt — replaces oh-my-zsh "fox" theme; stylix themes it automatically
  programs.starship.enable = true;
}
