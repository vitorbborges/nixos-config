{ pkgs, ... }:

let
  wallpaper-switch = pkgs.writeShellApplication {
    name = "wallpaper-switch";
    runtimeInputs = with pkgs; [ matugen jq ];
    text = builtins.readFile ./scripts/wallpaper-switch.sh;
  };
in

{
  home.packages = with pkgs; [
    wallpaper-switch
    matugen  # fast Material You color extraction from images
    jq       # JSON parsing for matugen output
  ];
}
