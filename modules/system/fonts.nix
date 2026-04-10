{ pkgs, ... }:

{
  # Install nerd font system-wide; stylix manages fontconfig defaults
  # noto-fonts-emoji provides full-color emoji rendering for waybar/GTK/Wayland
  fonts.packages = [
    pkgs.nerd-fonts.jetbrains-mono
    pkgs.noto-fonts-color-emoji
  ];
}
