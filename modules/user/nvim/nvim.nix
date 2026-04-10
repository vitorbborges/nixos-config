{ pkgs, ... }:

{
  programs.nixvim = {
    enable = true;

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
