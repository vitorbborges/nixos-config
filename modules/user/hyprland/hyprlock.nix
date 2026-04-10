{ config, lib, ... }:

let
  monoFont = config.stylix.fonts.monospace.name;
in

{
  programs.hyprlock = {
    enable = true;
    settings = {
      general = {
        hide_cursor = true;
        ignore_empty_input = true;
      };

      animations = {
        enabled = true;
        bezier = "easeOut, 0.05, 0.9, 0.1, 1.0";
        animation = [
          "fadeIn, 1, 5, easeOut"
          "fadeOut, 1, 5, easeOut"
          "inputFieldDots, 1, 2, easeOut"
        ];
      };

      # Wallpaper dimmed — OLED friendly (brightness 0.4 = ~40% pixel intensity)
      background = [{
        path = "${config.stylix.image}";
        blur_passes = 3;
        blur_size = 6;
        brightness = 0.4;
        contrast = 0.9;
        vibrancy = 0.1;
      }];

      label = [
        {
          # Dominant clock — mirrors astronaut theme's giant HH:mm
          text = "$TIME";
          color = "rgb(${config.lib.stylix.colors.base05})";
          font_size = 110;
          font_family = "${monoFont} Bold";
          position = "0, 130";
          halign = "center";
          valign = "center";
          shadow_passes = 3;
          shadow_size = 8;
          shadow_color = "rgba(${config.lib.stylix.colors.base00}cc)";
          shadow_boost = 1.2;
        }
        {
          # Date — snug below the clock, same style as astronaut theme
          text = ''cmd[update:43200000] date +"%A, %d %B"'';
          color = "rgb(${config.lib.stylix.colors.base04})";
          font_size = 24;
          font_family = monoFont;
          position = "0, 40";
          halign = "center";
          valign = "center";
          shadow_passes = 2;
          shadow_size = 4;
          shadow_color = "rgba(${config.lib.stylix.colors.base00}99)";
        }
      ];

      # Astronaut-style input: dark semi-transparent bg, 20px corners, accent border
      "input-field" = [{
        size = "300, 56";
        outline_thickness = 2;
        # Dark semi-transparent — mirrors astronaut's #222222 at 0.2 opacity
        inner_color = "rgba(${config.lib.stylix.colors.base00}bb)";
        # Accent border from wallpaper colorscheme
        outer_color = "rgb(${config.lib.stylix.colors.base0D})";
        font_color = "rgb(${config.lib.stylix.colors.base05})";
        check_color = "rgb(${config.lib.stylix.colors.base0B})";
        fail_color = "rgb(${config.lib.stylix.colors.base08})";
        capslock_color = "rgb(${config.lib.stylix.colors.base0A})";
        # 20px rounded corners — same as astronaut theme
        rounding = 20;
        dots_size = 0.22;
        dots_spacing = 0.3;
        dots_center = true;
        placeholder_text = ''<i><span foreground="#${config.lib.stylix.colors.base04}">password</span></i>'';
        fail_text = ''<i><span foreground="#${config.lib.stylix.colors.base08}">$FAIL</span></i>'';
        fade_on_empty = true;
        fade_timeout = 2000;
        position = "0, -50";
        halign = "center";
        valign = "center";
        shadow_passes = 2;
        shadow_size = 4;
        shadow_color = "rgba(${config.lib.stylix.colors.base00}99)";
      }];
    };
  };
}
