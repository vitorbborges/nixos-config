{ pkgs, ... }:

let
  screenshot-area = pkgs.writeShellApplication {
    name = "hl-screenshot-area";
    runtimeInputs = with pkgs; [ grim slurp libnotify wl-clipboard ];
    text = builtins.readFile ./scripts/screenshot-area.sh;
  };
  screenshot-full = pkgs.writeShellApplication {
    name = "hl-screenshot-full";
    runtimeInputs = with pkgs; [ grim libnotify wl-clipboard ];
    text = builtins.readFile ./scripts/screenshot-full.sh;
  };
  kb-switch = pkgs.writeShellApplication {
    name = "hl-kb-switch";
    runtimeInputs = with pkgs; [ hyprland jq libnotify ];
    text = builtins.readFile ./scripts/kb-switch.sh;
  };
in

{
  # Binds themselves live in ./generated.lua (loaded via hyprland.nix's
  # extraConfig) now that configType = "lua" — these scripts just need to
  # stay on $PATH for the binds that exec them by name.
  home.packages = [ screenshot-area screenshot-full kb-switch ];
}
