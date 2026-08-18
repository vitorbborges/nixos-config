{ pkgs, ... }:

{
  programs.nixvim = {
    enable = true;

    # Reuse the host's pkgs (useGlobalPkgs, allowUnfree=true) instead of
    # nixvim building its own nixpkgs instance from its pinned flake input —
    # otherwise unfree packages like copilot-language-server fail to evaluate.
    nixpkgs.useGlobalPackages = true;

    # General tools needed by nvim at runtime (search, navigation)
    extraPackages = with pkgs; [
      ripgrep  # fzf-lua live grep
      fd       # fzf-lua file finder
    ];
  };

  # General C/C++ build tools — kept here as they are useful beyond nvim
  home.packages = with pkgs; [
    gcc
    gnumake
    cmake
  ];
}
