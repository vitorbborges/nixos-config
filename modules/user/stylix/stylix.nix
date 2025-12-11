{ config, pkgs, inputs, ... }:

{
  imports = [
    inputs.stylix.homeManagerModules.stylix
  ];

  stylix = {
    enable = true;
    
    # Set the color scheme - you can change this to any base16 theme
    base16Scheme = "${pkgs.base16-schemes}/share/themes/catppuccin-mocha.yaml";
    
    # Set wallpaper (optional - you can remove this if you don't want one)
    # image = pkgs.fetchurl {
    #   url = "https://www.pixelstalk.net/wp-content/uploads/2016/05/Epic-Anime-Awesome-Wallpapers.jpg";
    #   sha256 = "enQo3wqhgf0FEPHj2coOCvo7DuZv+x5ruvjYwMKZGdu0ue4+cXrwYH5+vpg1C0tg2gGckPT1oMjXaOwDwvF7DqWG4lGZIy+iu4-TgXKKsGAhS0QmY5x-HK+sDwDxNE1ZDVoHLI0Yo7T8g=";
    # };
    
    # Configure cursor theme
    cursor = {
      package = pkgs.bibata-cursors;
      name = "Bibata-Modern-Ice";
      size = 24;
    };

    # Configure fonts
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
        terminal = 15;
        desktop = 10;
        popups = 10;
      };
    };

    # Configure opacity for different application types
    opacity = {
      applications = 1.0;
      terminal = 0.8;
      desktop = 1.0;
      popups = 1.0;
    };

    # Polarity - "dark" or "light"
    polarity = "dark";

    # Configure which applications to theme
    targets = {
      # Desktop environment theming
      gtk.enable = true;
      
      # Terminal applications
      kitty.enable = true;
      
      # Development tools
      vim.enable = true;
      
      # Other applications you might want to theme
      # firefox.enable = true;
      # rofi.enable = true;
      # waybar.enable = true;
    };
  };
}