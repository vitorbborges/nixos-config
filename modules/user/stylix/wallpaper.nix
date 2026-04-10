# Managed by wallpaper-switch script — do not edit manually
# Default: NixOS artwork (always available from nixpkgs, no local file needed)
# After first wallpaper-switch: replaced with an absolute path to your chosen image
{ pkgs, ... }:
{
  stylix.image = pkgs.nixos-artwork.wallpapers.nineish-dark-gray.gnomeFilePath;
}
