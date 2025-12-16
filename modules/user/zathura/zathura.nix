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
      # Remove all color options to let stylix handle theming
      # Only keep font setting since it's configuration, not theming
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
