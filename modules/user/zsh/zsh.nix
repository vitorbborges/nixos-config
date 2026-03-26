{ pkgs, ... }:

{

  programs.zsh = {
    enable = true;
    enableCompletion = true;
    autosuggestion.enable = true;
    syntaxHighlighting.enable = true;
    
    oh-my-zsh = {
      enable = true;
      theme = "fox";
      plugins = [
        "dotenv"
        "emoji"
        "git-auto-fetch"
        "last-working-dir"
        "sudo" # Press Esc twice for sudo
      ]; # TODO: Check if you need any packages.
    };

    shellAliases = {
      ls = "eza --icons --git --group-directories-first -l -T -L=1";
      cat = "bat";
      mamba = "micromamba";
      man = "tldr";
      
      # Neovim update aliases
      nvim-update = "cd ~/nixos-config/modules/user/nvim && ./update-nvim-auto.sh";
      nu = "cd ~/nixos-config/modules/user/nvim && ./update-nvim-auto.sh";
    };

    history = {
      size = 10000;
      ignoreAllDups = true;
      path = "$HOME/.zsh_history";
    };

    plugins = [

      {
        name = "zsh-vi-mode";
        src = pkgs.zsh-vi-mode;
        file = "share/zsh-vi-mode/zsh-vi-mode.plugin.zsh";
      }

      {
        name = "zsh-nix-shell";
        src = pkgs.zsh-nix-shell;
        file = "share/zsh-nix-shell/nix-shell.plugin.zsh";
      }

      {
        name = "fzf-tab";
        src = pkgs.zsh-fzf-tab;
        file = "share/fzf-tab/fzf-tab.plugin.zsh";
      }

    ];

  };

  programs.fzf =
    {
      enable = true;
      enableZshIntegration = true;
    };

  programs.eza = {
    enable = true;
    enableZshIntegration = true;
    extraOptions = [
      "--group-directories-first"
    ];
    git = true;
    icons = "always";
    # Remove theme to let stylix handle colors
  };

  services.tldr-update = {
    enable = true;
  };

  home.packages = with pkgs; [
    tldr
    fastfetch
    zoxide
    atuin
  ];

  programs.zoxide = {
    enable = true;
    enableZshIntegration = true;
  };

  programs.atuin = {
    enable = true;
    enableZshIntegration = true;
  };

}
