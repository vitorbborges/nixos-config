{ config, pkgs, lib, ... }:
let
  c     = config.lib.stylix.colors;
  font  = config.stylix.fonts.monospace.name;
  icons = "${pkgs.wlogout}/share/wlogout/icons";

  # GTK3 CSS does not support 8-digit hex (#RRGGBBAA). Must use rgba().
  rgba = hex: alpha:
    let
      r = lib.fromHexString (builtins.substring 0 2 hex);
      g = lib.fromHexString (builtins.substring 2 2 hex);
      b = lib.fromHexString (builtins.substring 4 2 hex);
    in "rgba(${toString r}, ${toString g}, ${toString b}, ${toString alpha})";
in
{
  programs.wlogout = {
    enable = true;

    layout = [
      { label = "lock";     action = "loginctl lock-session"; text = ""; keybind = "l"; }
      { label = "logout";   action = "hyprctl dispatch exit"; text = ""; keybind = "e"; }
      { label = "suspend";  action = "systemctl suspend";     text = ""; keybind = "u"; }
      { label = "reboot";   action = "systemctl reboot";      text = ""; keybind = "r"; }
      { label = "shutdown"; action = "systemctl poweroff";    text = ""; keybind = "s"; }
    ];

    # CSS lives in ./wlogout.css.in; rgba() values are pre-computed here
    # because GTK3 CSS has no 8-digit hex support.
    style = builtins.replaceStrings
      [ "@font@" "@base05@" "@base00_88@" "@base00_65@" "@base02_30@" "@base0D_20@" "@icons@" ]
      [ font "#${c.base05}" (rgba c.base00 0.88) (rgba c.base00 0.65) (rgba c.base02 0.3) (rgba c.base0D 0.2) icons ]
      (builtins.readFile ./wlogout.css.in);
  };
}
