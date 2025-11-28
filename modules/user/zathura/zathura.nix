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
      "render-loading-fg" = "#C6D0F5";
      "font" = "${font} 12";
    };

    mappings = {
      "J" = "next";
      "K" = "previous";
      "h" = "scroll left";
      "l" = "scroll right";
      "<C-f>" = "scroll full-down";
      "<C-b>" = "scroll full-up";
      "<C-d>" = "scroll half-down";
      "<C-u>" = "scroll half-up";
      "gg" = "first-page";
      "G" = "last-page";
      "+" = "zoom in";
      "-" = "zoom out";
      "=" = "zoom 100%";
      "<C-t>" = "new-tab";
      "<C-w>" = "close-tab";
      ">" = "next-tab";
      "<" = "previous-tab";
      "Q" = "quit";
    };

    extraConfig = "unmap q";
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
