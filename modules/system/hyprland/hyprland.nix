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

  # Power key suspends instead of shutting down
  services.logind.settings.Login.HandlePowerKey = "suspend";

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