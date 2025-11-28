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
    (pkgs.nerdfonts.override { fonts = [ fontPkg ]; })
  ];
}
