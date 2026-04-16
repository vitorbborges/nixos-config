{ config, ... }:

{
  xdg.enable = true;
  xdg.userDirs = {
    enable = true;
    createDirectories = true;
    music = "${config.home.homeDirectory}/Media/Music";
    videos = "${config.home.homeDirectory}/Media/Videos";
    pictures = "${config.home.homeDirectory}/Media/Pictures";
    templates = "${config.home.homeDirectory}/Templates";
    download = "${config.home.homeDirectory}/Downloads";
    documents = "${config.home.homeDirectory}/Documents";
    desktop = null;
    publicShare = null;
    setSessionVariables = true;
    extraConfig = {
      DOTFILES = "${config.home.homeDirectory}/.dotfiles";
      PROJECTS = "${config.home.homeDirectory}/Projects";
      BOOK = "${config.home.homeDirectory}/Media/Books";
      NOTES = "${config.home.homeDirectory}/Notes";
      SCREENSHOT = "${config.home.homeDirectory}/Media/Pictures/Screenshots";
    };
  };
  xdg.mime.enable = true;
  xdg.mimeApps = {
    enable = true;
    defaultApplications = {
      # Images → imv
      "image/jpeg"    = [ "imv.desktop" ];
      "image/png"     = [ "imv.desktop" ];
      "image/gif"     = [ "imv.desktop" ];
      "image/webp"    = [ "imv.desktop" ];
      "image/svg+xml" = [ "imv.desktop" ];
      "image/tiff"    = [ "imv.desktop" ];
      "image/bmp"     = [ "imv.desktop" ];
      "image/avif"    = [ "imv.desktop" ];

      # Video → mpv
      "video/mp4"        = [ "mpv.desktop" ];
      "video/webm"       = [ "mpv.desktop" ];
      "video/x-matroska" = [ "mpv.desktop" ];
      "video/x-msvideo"  = [ "mpv.desktop" ];
      "video/quicktime"  = [ "mpv.desktop" ];
      "video/ogg"        = [ "mpv.desktop" ];

      # Audio → mpv
      "audio/mpeg"  = [ "mpv.desktop" ];
      "audio/ogg"   = [ "mpv.desktop" ];
      "audio/flac"  = [ "mpv.desktop" ];
      "audio/x-wav" = [ "mpv.desktop" ];
      "audio/aac"   = [ "mpv.desktop" ];
      "audio/mp4"   = [ "mpv.desktop" ];

      # Documents → zathura
      "application/pdf"      = [ "org.pwmt.zathura-pdf-mupdf.desktop" ];
      "application/epub+zip" = [ "org.pwmt.zathura-pdf-mupdf.desktop" ];

      # Web → zen
      "text/html"              = [ "zen-beta.desktop" ];
      "x-scheme-handler/http"  = [ "zen-beta.desktop" ];
      "x-scheme-handler/https" = [ "zen-beta.desktop" ];
      "x-scheme-handler/ftp"   = [ "zen-beta.desktop" ];
      "application/xhtml+xml"  = [ "zen-beta.desktop" ];
    };
  };
}
