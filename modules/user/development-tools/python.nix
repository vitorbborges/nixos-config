{ config, pkgs, ... }:

{
  # For uv to correctly manage binaries, it's recommended to set
  # environment.localBinInPath = true;
  # in your system-wide configuration.nix.

  home.packages = with pkgs; [
    conda
    conda-install
    uv
  ];

  # To prevent uv from automatically downloading Python binaries,
  # you can set the following environment variable.
  # Remove or comment it out if you prefer the default behavior.
  programs.zsh.sessionVariables = {
    UV_PYTHON_DOWNLOADS = "never";
  };
}
