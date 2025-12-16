{ config, pkgs, inputs, ... }:
# TODO: migrate to nixvim

{
  # Neovim configuration (modularized)
  programs.neovim = {
    enable = true;
    defaultEditor = true;
    viAlias = true;
    vimAlias = true;
    vimdiffAlias = true;
    
    plugins = with pkgs.vimPlugins; [
      # Install lazy.nvim through Nix to avoid bootstrap issues
      lazy-nvim
    ];
  };

  # Link nvim config from GitHub (excluding lazy-lock.json)
  # To update: get latest commit with: gh api repos/vitorbborges/nvim-config/commits/main --jq .sha
  xdg.configFile = let
    nvimConfig = pkgs.fetchFromGitHub {
      owner = "vitorbborges";
      repo = "nvim-config";
      rev = "39eced9eabf0b318b956123320ff107f928d6d64"; # Updated: 2025-11-28
      hash = "sha256-tBFKEAc1n+P7u5HDAVfzRgpD67/d30TT+Epl4PoRDhg=";
    };
  in {
    "nvim" = {
      source = pkgs.runCommand "nvim-config-filtered" {} ''
        cp -r ${nvimConfig} $out
        chmod -R u+w $out
        rm -f $out/lazy-lock.json
      '';
      recursive = true;
    };
  };

  # Neovim essential packages
  home.packages = with pkgs; [
    lua-language-server
    stylua
    git
    curl
    wget
    ripgrep
    fd
    tree-sitter
    nodejs
    unzip
    gcc
    
    # For updating neovim config automatically
    nix-prefetch-github
    jq
    
    # For nvim-obsidian plugin
    obsidian
  ];
}
