{ config, pkgs, lib, font, ... }:

{
  programs.zathura = {
    enable = true;
    package = pkgs.zathura.override {
      plugins = with pkgs.zathuraPkgs; [
        zathura_pdf_mupdf
        zathura_djvu
      ];
    };

    options = {
      # Catppuccin theme (Frappe)
      "default-bg" = "#303446";
      "default-fg" = "#C6D0F5";
      "statusbar-bg" = "#414559";
      "statusbar-fg" = "#C6D0F5";
      "inputbar-bg" = "#414559";
      "inputbar-fg" = "#C6D0F5";
      "notification-bg" = "#414559";
      "notification-fg" = "#C6D0F5";
      "notification-error-bg" = "#414559";
      "notification-error-fg" = "#E78284";
      "notification-warning-bg" = "#414559";
      "notification-warning-fg" = "#FAE3B0";
      "highlight-color" = "#575268";
      "highlight-fg" = "#F4B8E4";
      "highlight-active-color" = "#F4B8E4";
      "completion-bg" = "#414559";
      "completion-fg" = "#C6D0F5";
      "completion-highlight-bg" = "#575268";
      "completion-highlight-fg" = "#C6D0F5";
      "completion-group-bg" = "#414559";
      "completion-group-fg" = "#8CAAEE";
      "recolor-lightcolor" = "#303446";
      "recolor-darkcolor" = "#C6D0F5";
      "index-bg" = "#303446";
      "index-fg" = "#C6D0F5";
      "index-active-bg" = "#414559";
      "index-active-fg" = "#C6D0F5";
      "render-loading-bg" = "#303446";
      "render-loading-fg" = "#C6D0F5";
      "font" = "${font} 12";

      # nvim-like keybindings
      "map" = [
        # Navigation
        "map J next"
        "map K previous"
        "map h scroll left"
        "map l scroll right"
        "map <C-f> scroll full-down"
        "map <C-b> scroll full-up"
        "map <C-d> scroll half-down"
        "map <C-u> scroll half-up"
        "map gg first-page"
        "map G last-page"

        # Zoom
        "map + zoom in"
        "map - zoom out"
        "map = zoom 100%"

        # Tabs
        "map <C-t> new-tab"
        "map <C-w> close-tab"
        "map > next-tab"
        "map < previous-tab"

        # Custom
        "map Q quit"
        "unmap q"
      ];

      # Window dimensions
      "window-height" = 3000;
      "window-width" = 3000;

      # Clipboard
      "selection-clipboard" = "clipboard";

      # Enable synctex for LaTeX
      "synctex" = true;
      "synctex-editor-command" = "nvr --remote-silent +%{line} %{input}";
    };
  };

  xdg.mimeApps.defaultApplications = {
    "application/pdf" = [ "org.pwmt.zathura-pdf-mupdf.desktop" ];
    "application/djvu" = [ "org.pwmt.zathura-djvu.desktop" ];
  };

  # For synctex to work, you need neovim-remote
  home.packages = with pkgs; [
    neovim-remote
  ];
}
