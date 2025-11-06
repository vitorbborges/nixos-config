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

}
