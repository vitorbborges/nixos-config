{ ... }:

{

  programs.zsh = {
    enable = true;
    enableCompletion = true;
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

    oh-my-zsh = {
      enable = true;
      theme = "darkblood";
      plugins = [ "zsh-fzf-history-search" ];
    };
  };

  programs.fzf =
    {
      enable = true;
      enableZshIntegration = true;
    }

      shellAliases = {
  ls = "eza --icons -l -T -L=1";
  cat = "bat";
  mamba = "micromamba"
    };

  home.packages = with pkgs; [
    eza
    bat
    fzf
  ];

}
