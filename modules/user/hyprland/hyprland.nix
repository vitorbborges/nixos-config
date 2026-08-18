{ pkgs, ... }: {

  home.packages = with pkgs; [
    grim          # screenshot: capture to file (used by hl-screenshot-*)
    slurp         # screenshot: interactive area/window selection
    libnotify     # notify-send for volume/brightness/screenshot OSD feedback
    brightnessctl # screen & keyboard backlight (Fn brightness keys)
  ];

  wayland.windowManager.hyprland = {
    enable = true;
    # Hyprland 0.55+ auto-generates ~/.config/hypr/hyprland.lua on first run and
    # unconditionally prefers it over hyprland.conf whenever it exists, with no
    # bridge back to hyprlang. configType = "lua" makes home-manager write the
    # file Hyprland actually loads. Binds/rules/animations/monitors live in
    # ./generated.lua (converted from the old hyprlang config via hyprlang2lua,
    # hand-reviewed) — edit that file directly, not a Nix attrset, to change them.
    configType = "lua";

    # Polkit agent must be launched from exec-once — binary lives in libexec (not
    # PATH) — so it needs a live Nix interpolation, not frozen text in generated.lua.
    extraConfig = (builtins.readFile ./generated.lua) + ''

      hl.on("hyprland.start", function()
        hl.exec_cmd("${pkgs.hyprpolkitagent}/libexec/hyprpolkitagent")
      end)
    '';
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
