{ pkgs, ... }:

let
  wallpaper-switch = pkgs.writeShellApplication {
    name = "wallpaper-switch";
    runtimeInputs = with pkgs; [ awww matugen jq libnotify hyprland ];
    text = builtins.readFile ./scripts/wallpaper-switch.sh;
  };
  wallpaper-picker = pkgs.writeShellApplication {
    name = "wallpaper-picker";
    runtimeInputs = [ pkgs.fzf wallpaper-switch ];
    text = builtins.readFile ./scripts/wallpaper-picker.sh;
  };
in

{
  home.packages = with pkgs; [
    wallpaper-switch
    wallpaper-picker
    matugen
    jq
    libnotify
  ];
}
