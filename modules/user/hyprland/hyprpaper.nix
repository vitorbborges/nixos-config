{ config, pkgs, ... }:

let
  # Restore the last-used wallpaper on login, falling back to the stylix default.
  wallpaper-init = pkgs.writeShellApplication {
    name = "wallpaper-init";
    runtimeInputs = [ pkgs.swww ];
    text = ''
      last="$HOME/.config/swww/last-wallpaper"
      default="${config.stylix.image}"
      if [[ -f "$last" && -f "$(cat "$last")" ]]; then
        swww img "$(cat "$last")" --transition-type none
      else
        swww img "$default" --transition-type none
      fi
    '';
  };
in
{
  home.packages = [ pkgs.swww wallpaper-init ];

  wayland.windowManager.hyprland.settings.exec-once = [
    "swww-daemon"
    "wallpaper-init"
  ];
}
