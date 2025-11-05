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
        "ssh-agent"
        "last-working-dir"
        "sudo" # Press Esc twice for sudo
      ]; # TODO: Check if you need any packages.
    };

    shellAliases = {
      ls = "eza --icons --git --group-directories-first -l -T -L=1";
      cat = "bat";
      mamba = "micromamba";
      man = "tldr";
    };

    history = {
      size = 10000;
      ignoreAllDups = true;
      path = "$HOME/.zsh_history";
    };

    plugins = [

      {
        name = "zsh-nix-shell";
        file = "nix-shell.plugin.zsh";
        src = pkgs.fetchFromGitHub {
          owner = "chisui";
          repo = "zsh-nix-shell";
          rev = "v0.8.0";
          sha256 = "1lzrn0n4fxfcgg65v0qhnj7wnybybqzs4adz7xsrkgmcsr0ii8b7";
        };
      }

      {
        name = "fzf-tab";
        src = pkgs.fetchFromGitHub {
          owner = "Aloxaf";
          repo = "fzf-tab";
          rev = "c2b4aa5ad2532cca91f23908ac7f00efb7ff09c9";
          sha256 = "1b4pksrc573aklk71dn2zikiymsvq19bgvamrdffpf7azpq6kxl2";
        };
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
    theme = "dracula";
  };

  services.tldr-update = {
    enable = true;
  };

  home.packages = with pkgs; [
    eza
    bat
    fzf
    tldr
    fastfetch
  ];

}
