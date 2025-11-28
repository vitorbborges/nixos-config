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

  fonts.packages = [
    (builtins.getAttr fontPkg pkgs.nerd-fonts)
  ];
}
