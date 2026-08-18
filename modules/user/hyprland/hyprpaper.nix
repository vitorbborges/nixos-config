{ config, pkgs, ... }:

let
  # Restore the last-used wallpaper on login, falling back to the stylix default.
  wallpaper-init = pkgs.writeShellApplication {
    name = "wallpaper-init";
    runtimeInputs = [ pkgs.awww ];
    text = builtins.replaceStrings
      [ "@stylixImage@" ]
      [ (toString config.stylix.image) ]
      (builtins.readFile ./scripts/wallpaper-init.sh);
  };
in
{
  home.packages = [ pkgs.awww wallpaper-init ];

  wayland.windowManager.hyprland.extraConfig = ''
    hl.on("hyprland.start", function()
      hl.exec_cmd("awww-daemon")
      hl.exec_cmd("wallpaper-init")
    end)
  '';
}
