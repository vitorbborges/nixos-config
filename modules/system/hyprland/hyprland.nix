{ inputs, pkgs, config, lib, kbLayout, ... }:
{
  imports = [ inputs.hyprland.nixosModules.default ];

  programs.hyprland = {
    enable = true;
    withUWSM = true;
    xwayland.enable = true;
    package = inputs.hyprland.packages.${pkgs.stdenv.hostPlatform.system}.hyprland;
    portalPackage = inputs.hyprland.packages.${pkgs.stdenv.hostPlatform.system}.xdg-desktop-portal-hyprland;
  };

  nix.settings = {
    substituters = [ "https://hyprland.cachix.org" ];
    trusted-substituters = [ "https://hyprland.cachix.org" ];
    trusted-public-keys = [ "hyprland.cachix.org-1:a7pgxzMz7+chwVL3/pzj6jIBMioiJM7ypFP8PwtkuGc=" ];
  };

  # Power key suspends instead of shutting down; lid close also suspends
  services.logind.settings.Login = {
    HandlePowerKey = "suspend";
    HandleLidSwitch = "suspend";
    HandleLidSwitchExternalPower = "suspend"; # suspend even when plugged in
    # Without this, processes holding sleep inhibitors (Docker rootless, VirtualBox)
    # silently prevent lid-close from triggering suspend.
    LidSwitchIgnoreInhibited = "yes";
  };

  # Force xdg-open through the portal so file pickers behave consistently on Wayland
  xdg.portal.xdgOpenUsePortal = true;

  environment.systemPackages = [ pkgs.jq ];

  # greetd + tuigreet: X-free Wayland-native login manager
  services.greetd = {
    enable = true;
    settings.default_session = {
      command = lib.concatStringsSep " " [
        "${pkgs.tuigreet}/bin/tuigreet"
        "--time"
        "--remember"                # remember last username
        "--remember-user-session"   # remember last session per user
        "--asterisks"               # mask password with *
        "--sessions ${config.services.displayManager.sessionData.desktops}/share/wayland-sessions"
      ];
      user = "greeter";
    };
  };

  # Suppress "Starting …" / "Started …" status lines on the console so they
  # don't bleed onto tuigreet's TTY. Only errors are shown.
  systemd.settings.Manager.ShowStatus = "error";

  services.upower.enable = true;

  # xwayland
  services.xserver = {
    enable = true;
    xkb = {
      layout = kbLayout;
      variant = "";
      options = "caps:escape";
    };
    excludePackages = [ pkgs.xterm ];
  };

}