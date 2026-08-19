{ pkgs, ... }: {

  # Interactive calendar popup opened by clicking the waybar clock: waybar
  # tooltips can't receive pointer input, so month browsing lives here instead.
  # Themed automatically via stylix.targets.gtk; positioned by a hyprland
  # window rule in modules/user/hyprland/generated.lua.
  home.packages = [ pkgs.gsimplecal ];

  xdg.configFile."gsimplecal/config" = {
    text = builtins.readFile ./gsimplecal.conf;
  };
}
