{ pkgs, ... }: {

  home.packages = [ pkgs.pyprland ];

  # pyprland config — expose shows all windows as a visual overlay
  xdg.configFile."hypr/pyprland.toml".text = ''
    [pyprland]
    plugins = ["expose"]

    [expose]
    include_special = false
  '';

  # Start pyprland daemon with Hyprland
  wayland.windowManager.hyprland.settings.exec-once = [
    "pyprland"
  ];
}
