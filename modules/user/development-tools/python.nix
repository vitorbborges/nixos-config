{ config, pkgs, ... }:

{
  home.packages = with pkgs; [
    micromamba
    uv
  ];
}
