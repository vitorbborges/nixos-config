{ config, lib, ... }:

# stylix.targets.fuzzel.enable = true (set in stylix.nix) handles all colors.
# Font: stylix defaults to sansSerif for fuzzel; mkForce overrides to monospace
# so the launcher matches the terminal aesthetic. Value still derives from stylix.
{
  programs.fuzzel = {
    enable = true;
    settings = {
      main = {
        font = lib.mkForce "${config.stylix.fonts.monospace.name}:size=${toString config.stylix.fonts.sizes.applications}";
        width          = 42;
        lines          = 10;
        horizontal-pad = 16;
        vertical-pad   = 8;
        inner-pad      = 8;
        tabs           = 4;
        prompt         = "  ";
        terminal       = "kitty -e";
        layer          = "overlay";
        icon-theme     = "hicolor";
      };
      border = {
        radius = 12;
        width  = 2;
      };
      dmenu = {
        exit-immediately-if-empty = true;
      };
    };
  };
}
