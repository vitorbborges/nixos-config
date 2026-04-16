{ pkgs, ... }: {

  home.packages = with pkgs; [
    grim          # screenshot: capture to file (used by hl-screenshot-*)
    slurp         # screenshot: interactive area/window selection
    libnotify     # notify-send for volume/brightness/screenshot OSD feedback
    brightnessctl # screen & keyboard backlight (Fn brightness keys)
  ];

  wayland.windowManager.hyprland = {
    enable = true;
    settings = {
      monitor = [
        "eDP-1,3200x2000@120,0x0,2"          # built-in: 3200x2000 @ 2.0 scale 120Hz
        "HDMI-A-1,preferred,auto,1"           # external: auto-detect, verify name with `hyprctl monitors`
        "Unknown-1,disabled"                  # phantom monitor on NVIDIA hybrid systems
      ];

      "$mod" = "SUPER";

      # Polkit agent must be launched from exec-once — binary lives in libexec (not PATH)
      exec-once = [
        "${pkgs.hyprpolkitagent}/libexec/hyprpolkitagent"
      ];
    };
  };

  home.sessionVariables = {
    LIBVA_DRIVER_NAME = "nvidia";
    __GLX_VENDOR_LIBRARY_NAME = "nvidia";
    GBM_BACKEND = "nvidia-drm";
    WLR_NO_HARDWARE_CURSORS = "1";
    NIXOS_OZONE_WL = "1";
    ELECTRON_OZONE_PLATFORM_HINT = "auto";
    NVD_BACKEND = "direct";
    MOZ_ENABLE_WAYLAND = "1";
    QT_QPA_PLATFORM = "wayland";
    GDK_BACKEND = "wayland";
    XDG_SESSION_TYPE = "wayland";
    BROWSER = "xdg-open";
    XDG_CURRENT_DESKTOP = "Hyprland";
    EDITOR = "nvim";
    VISUAL = "nvim";
  };
}
