{ pkgs, ... }: {

  home.packages = [ pkgs.pyprland ];

  # pyprland config — expose shows all windows as a visual overlay
  xdg.configFile."hypr/pyprland.toml".source = ./pyprland.toml;

  # Start pyprland daemon with Hyprland
  wayland.windowManager.hyprland.extraConfig = ''
    hl.on("hyprland.start", function()
      hl.exec_cmd("pyprland")
    end)
  '';
}
