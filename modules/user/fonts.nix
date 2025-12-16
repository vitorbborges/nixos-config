{ pkgs, font, fontPkg, ... }:

{
  # Let stylix handle font configuration
  # fonts.fontconfig managed by stylix

  home.packages = [
    (builtins.getAttr fontPkg pkgs.nerd-fonts)
  ];
}
