{ pkgs, ... }:

{
  home.packages = with pkgs; [
    nil
    nixd
    nixdoc
  ];
}
