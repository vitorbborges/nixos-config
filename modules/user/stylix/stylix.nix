{ config, lib, pkgs, inputs, theme, ... }:

{
  imports = [
    inputs.stylix.homeModules.stylix
  ];

  stylix = {
    enable = true;

    # image lives in wallpaper.nix (managed by wallpaper-switch script)
    # Colors are pinned to a named scheme — swapping wallpaper no longer changes the palette.
    # To change the full theme, edit `theme` in flake.nix (one variable, all apps).
    base16Scheme = "${pkgs.base16-schemes}/share/themes/${theme}.yaml";

    # OLED override: force true-black background regardless of the chosen scheme.
    # base00 drives kitty bg, hyprland borders, waybar pills, hyprlock bg, etc.
    override = {
      base00 = "000000";
      base01 = "0d0d0d";
    };

    cursor = {
      package = pkgs.bibata-cursors;
      name = "Bibata-Modern-Ice";
      size = 12;
    };

    fonts = {
      monospace = {
        package = pkgs.jetbrains-mono;
        name = "JetBrains Mono Nerd Font";
      };
      sansSerif = {
        package = pkgs.dejavu_fonts;
        name = "DejaVu Sans";
      };
      serif = {
        package = pkgs.dejavu_fonts;
        name = "DejaVu Serif";
      };
      sizes = {
        applications = 12;
        terminal = 14;
        desktop = 10;
        popups = 10;
      };
    };

    opacity = {
      applications = 1.0;
      terminal = 0.75;
      desktop = 1.0;
      popups = 1.0;
    };

    polarity = "dark";

    targets = {
      gtk.enable = true;
      hyprland.enable = true;
      kitty.enable = true;
      vim.enable = true;
      zathura.enable = true;
      yazi.enable = true;
      spicetify.enable = false;  # comfy theme set explicitly in spicetify.nix
      hyprpaper.enable = lib.mkForce false;  # using swww instead; wallpaper set via exec-once
      zen-browser = {
        enable = true;
        profileNames = [ "default-release" ];
      };
      # waybar: stylix injects @define-color base00..base0F into programs.waybar.style.
      # Our layout CSS (waybar/style.css) uses those variables — no hex values hardcoded.
      waybar.enable = true;
      # fuzzel: stylix themes colors automatically; border/radius come from fuzzel.nix.
      fuzzel.enable = true;
      # hyprlock: disabled — hyprlock.nix handles full theming via config.lib.stylix.colors.*
      hyprlock.enable = false;
    };
  };
}
