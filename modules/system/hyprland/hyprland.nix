{ inputs, pkgs, config, lib, ... }:
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

  # Power key should not shut off computer by defaultPower key shuts of
  services.logind.settings.Login.HandlePowerKey = "suspend";

  # Necessary packages
  environment.systemPackages = with pkgs; [
    jq
    (sddm-astronaut.override {
      themeConfig = {
        ScreenWidth = 1920;
        ScreenHeight = 1080;
        blur = false;
      };
    })
  ];

  # Display manager
  services.displayManager.sddm = {
    enable = true;
    wayland.enable = true;
    enableHidpi = true;
    theme = "sddm-astronaut-theme";
    package = pkgs.kdePackages.sddm;
    extraPackages = with pkgs; [
      (sddm-astronaut.override {
        themeConfig = {
          ScreenWidth = 1920;
          ScreenHeight = 1080;
          blur = false;
        };
      })
    ];
  };
  services.displayManager.defaultSession = "hyprland-uwsm";

  services.upower.enable = true;

  # xwayland
  services.xserver = {
    enable = true;
    xkb = {
      layout = "us";
      variant = "";
      options = "caps:escape";
    };
    excludePackages = [ pkgs.xterm ];
  };

}