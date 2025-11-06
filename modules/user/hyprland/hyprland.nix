{ inputs, pkgs, ... }:
let
  hyprSystem = inputs.hyprland.${pkgs.stdenv.hostPlatform.system};
in
{

  programs.hyprland = {
    enable = true;
    withUWSM = true;
    xwayland.enable = true;
    package = hyprSystem.hyprland;
    portalPackage = hyprSystem.xdg-desktop-portal-hyprland;
  };

  environment.sessionVariables = {
    LIBVA_DRIVER_NAME = "nvidia";
    __GLX_VENDOR_LIBRARY_NAME = "nvidia";
    NIXOS_OZONE_WL = 1;
    ELECTRON_OZONE_PLATFORM_HINT = "auto";
    NVD_BACKEND = "direct";
  };
}
