{ config, pkgs, ... }:

let
  c    = config.lib.stylix.colors.withHashtag;
  font = config.stylix.fonts.monospace.name;
in

{
  home.packages = [ pkgs.satty ];

  # No stylix target for satty (yet) — colors/font are injected from
  # config.lib.stylix.colors into the templates at eval time (pattern c).
  xdg.configFile."satty/config.toml".text = builtins.replaceStrings
    [ "@font@" "@base08@" "@base0A@" "@base0B@" "@base0C@" "@base0D@" "@base0E@" ]
    [ font c.base08 c.base0A c.base0B c.base0C c.base0D c.base0E ]
    (builtins.readFile ./satty/config.toml.in);

  xdg.configFile."satty/overrides.css".text = builtins.replaceStrings
    [ "@base00@" "@base01@" "@base05@" "@base0D@" ]
    [ c.base00 c.base01 c.base05 c.base0D ]
    (builtins.readFile ./satty/overrides.css.in);
}
