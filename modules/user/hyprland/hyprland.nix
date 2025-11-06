{ inputs, pkgs, ... }:
{

  #imports = [ inputs.hyprland.nixosModules.default ];

  #programs.hyprland = {
  #  enable = true;
  #  withUWSM = true;
  #  xwayland.enable = true;
  #  package = inputs.hyprland.packages.${pkgs.stdenv.hostPlatform.system}.hyprland;
  #  portalPackage = inputs.hyprland.packages.${pkgs.stdenv.hostPlatform.system}.xdg-desktop-portal-hyprland;
  #};
}
