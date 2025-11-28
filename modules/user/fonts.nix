{ pkgs, font, fontPkg, ... }:

{
  fonts.fontconfig = {
    enable = true;
    defaultFonts = {
      serif = [ font ];
      sansSerif = [ font ];
      monospace = [ font ];
    };
  };

  home.packages = [
    (builtins.getAttr fontPkg pkgs.nerd-fonts)
  ];
}
