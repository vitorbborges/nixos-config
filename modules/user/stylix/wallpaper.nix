{ pkgs, ... }:
{
  # stylix.image must be a Nix-store path (absolute /home paths fail in pure flake eval).
  # Colors come from base16Scheme (catppuccin-mocha), not from this image.
  # The actual runtime wallpaper is managed by swww — see hyprpaper.nix.
  stylix.image = pkgs.runCommand "default-wallpaper.png"
    { buildInputs = [ pkgs.imagemagick ]; } ''
    magick -size 1920x1080 gradient:"#0d0d0d-#000000" "$out"
  '';
}
