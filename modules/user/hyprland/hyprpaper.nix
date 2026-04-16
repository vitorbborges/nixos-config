{ config, pkgs, ... }:

let
  # Restore the last-used wallpaper on login, falling back to the stylix default.
  wallpaper-init = pkgs.writeShellApplication {
    name = "wallpaper-init";
    runtimeInputs = [ pkgs.awww ];
    text = ''
      # Wait for awww-daemon to be ready before setting wallpaper
      until awww query &>/dev/null; do sleep 0.1; done
      last="$HOME/.config/awww/last-wallpaper"
      default="${config.stylix.image}"
      if [[ -f "$last" && -f "$(cat "$last")" ]]; then
        awww img "$(cat "$last")" --transition-type none
      else
        awww img "$default" --transition-type none
      fi
    '';
  };
in
{
  home.packages = [ pkgs.awww wallpaper-init ];

  wayland.windowManager.hyprland.settings.exec-once = [
    "awww-daemon"
    "wallpaper-init"
  ];
}
