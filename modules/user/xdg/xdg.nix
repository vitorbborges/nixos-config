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

  # nixpkgs ships thunderbird.desktop with a trimmed MimeType list, so xdg-mime
  # can't find it as a handler for news/feed/calendar/net.thunderbird links and
  # Thunderbird's "set as default client" dialog reappears on every start.
  # Re-declare the entry with the full MimeType list (user dir shadows the store).
  xdg.desktopEntries.thunderbird = {
    name = "Thunderbird";
    genericName = "Email Client";
    comment = "Read and write e-mails or RSS feeds, or manage tasks on calendars.";
    exec = "thunderbird --name thunderbird %U";
    icon = "thunderbird";
    terminal = false;
    startupNotify = true;
    categories = [ "Network" "Chat" "Email" "Feed" "GTK" "News" ];
    mimeType = [
      # Email — nsGNOMEShellService checks BOTH mailto and mid
      "message/rfc822"
      "x-scheme-handler/mailto"
      "x-scheme-handler/mid"
      # Newsgroups — checks news, snews AND nntp
      "x-scheme-handler/news"
      "x-scheme-handler/snews"
      "x-scheme-handler/nntp"
      # Feeds
      "x-scheme-handler/feed"
      "application/rss+xml"
      # Calendar
      "x-scheme-handler/webcal"
      "x-scheme-handler/webcals"
      "text/calendar"
      "text/x-vcard"
      # Custom Thunderbird links
      "x-scheme-handler/net.thunderbird"
    ];
  };

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

      # LaTeX sources → nvim
      "text/x-tex" = [ "nvim.desktop" ];

      # Web → zen
      "text/html"              = [ "zen-beta.desktop" ];
      "x-scheme-handler/http"  = [ "zen-beta.desktop" ];
      "x-scheme-handler/https" = [ "zen-beta.desktop" ];
      "x-scheme-handler/ftp"   = [ "zen-beta.desktop" ];
      "application/xhtml+xml"  = [ "zen-beta.desktop" ];

      # Mail → thunderbird.
      # Thunderbird's default-client check (nsGNOMEShellService::checkDefault)
      # requires *every* protocol of a group to resolve to itself, so mailto
      # alone is not enough — mid must be registered too, or the "set as
      # default client" dialog reappears on every start.
      "message/rfc822" = [ "thunderbird.desktop" ];
      "x-scheme-handler/mailto" = [ "thunderbird.desktop" ];
      "x-scheme-handler/mid"    = [ "thunderbird.desktop" ];

      # Newsgroups → thunderbird (group is news + snews + nntp)
      "x-scheme-handler/news"  = [ "thunderbird.desktop" ];
      "x-scheme-handler/snews" = [ "thunderbird.desktop" ];
      "x-scheme-handler/nntp"  = [ "thunderbird.desktop" ];

      # Feeds → thunderbird
      "x-scheme-handler/feed" = [ "thunderbird.desktop" ];
      "application/rss+xml"   = [ "thunderbird.desktop" ];

      # Calendar → thunderbird
      "x-scheme-handler/webcal"  = [ "thunderbird.desktop" ];
      "x-scheme-handler/webcals" = [ "thunderbird.desktop" ];
      "text/calendar"            = [ "thunderbird.desktop" ];
      "text/x-vcard"             = [ "thunderbird.desktop" ];

      # Custom Thunderbird links → thunderbird
      "x-scheme-handler/net.thunderbird" = [ "thunderbird.desktop" ];

      # MATLAB deep links (Open-in-MATLAB from mathworks.com etc).
      # The mw-*.desktop files are written and version-bumped by the MathWorks
      # ServiceHost installer in ~/.local/share/applications — deliberately NOT
      # managed here, since their Exec carries a ServiceHost version that
      # MathWorks updates itself. Only the associations are declared, because
      # ServiceHost registered them in the mimeapps.list that home-manager took
      # over, and GIO (unlike the xdg-mime script) does not fall back to
      # scanning desktop files, so browsers could no longer resolve them.
      "x-scheme-handler/mw-matlab"          = [ "mw-matlab.desktop" ];
      "x-scheme-handler/mw-simulink"        = [ "mw-simulink.desktop" ];
      "x-scheme-handler/mw-matlabconnector" = [ "mw-matlabconnector.desktop" ];
    };
  };
}
