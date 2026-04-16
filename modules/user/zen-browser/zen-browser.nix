{ config, pkgs, inputs, system, ... }:

{
  imports = [
    inputs.zen-browser.homeModules.default
  ];

  programs.zen-browser = {
    enable = true;
    
    # Native messaging hosts for extensions
    nativeMessagingHosts = with pkgs; [
      # For Progressive Web Apps if needed
      # firefoxpwa
      
      # For password managers and other extensions that need native messaging
      # Add specific packages here based on your needs
      # Example: if you use Bitwarden desktop app with browser extension
      # bitwarden-cli
    ];
    
    policies = {
      DisableAppUpdate = true;
      DisableTelemetry = true;
      DontCheckDefaultBrowser = true;
      NoDefaultBookmarks = true;
      OfferToSaveLogins = false;
      AutofillAddressEnabled = false;
      AutofillCreditCardEnabled = false;
      DisableFeedbackCommands = true;
      DisableFirefoxStudies = true;
      DisablePocket = true;
      EnableTrackingProtection = {
        Value = true;
        Locked = true;
        Cryptomining = true;
        Fingerprinting = true;
      };
      
      # Set preferences for dark theme and other settings
      Preferences = let
        mkLockedAttrs = builtins.mapAttrs (_: value: {
          Value = value;
          Status = "locked";
        });
      in mkLockedAttrs {
        # Enable dark theme
        "extensions.activeThemeID" = "firefox-compact-dark@mozilla.org";
        "ui.systemUsesDarkTheme" = true;
        "devtools.theme" = "dark";
        
        # Additional dark mode preferences
        "browser.theme.content-theme" = 0; # 0 = auto, 1 = light, 2 = dark
        "browser.theme.toolbar-theme" = 0; # 0 = auto, 1 = light, 2 = dark
        
        # Disable VA-API: vaapitest subprocess crashes on NVIDIA Optimus PRIME
        "media.ffmpeg.vaapi.enabled" = false;

        # Other useful preferences
        "browser.tabs.warnOnClose" = false;
        "browser.startup.page" = 3; # 3 = restore previous session
        "browser.startup.homepage" = "about:blank";
        "browser.newtabpage.enabled" = false;
        "privacy.trackingprotection.enabled" = true;
        "privacy.trackingprotection.socialtracking.enabled" = true;
      };
      
      # Install extensions
      ExtensionSettings = let
        mkExtensionSettings = builtins.mapAttrs (_: pluginId: {
          install_url = "https://addons.mozilla.org/firefox/downloads/latest/${pluginId}/latest.xpi";
          installation_mode = "force_installed";
        });
      in mkExtensionSettings {
        # ActivityWatch Web Watcher
        "aw-watcher-web@activitywatch.net" = "aw-watcher-web";
        # LanguageTool Grammar Checker & Paraphraser
        "languagetool-webextension@languagetool.org" = "languagetool";
        # Bitwarden Password Manager
        "{446900e4-71c2-419f-a6a7-df9c091e268b}" = "bitwarden-password-manager";
        # Surfshark VPN Extension
        "{6ac85729-5d1f-4c24-8d41-5b7f262f31f7}" = "surfshark";
        # uBlock Origin
        "uBlock0@raymondhill.net" = "ublock-origin";
        # Unhook Remove YouTube Recommended and Shorts
        "myallychou@gmail.com" = "youtube-recommended-videos";
      };
    };
  };

  # Set zen as default browser for all web-related MIME types
  xdg.mimeApps = {
    enable = true;
    defaultApplications = {
      "text/html" = "zen-beta.desktop";
      "x-scheme-handler/http" = "zen-beta.desktop";
      "x-scheme-handler/https" = "zen-beta.desktop";
      "x-scheme-handler/about" = "zen-beta.desktop";
      "x-scheme-handler/unknown" = "zen-beta.desktop";
      "application/x-extension-htm" = "zen-beta.desktop";
      "application/x-extension-html" = "zen-beta.desktop";
      "application/x-extension-shtml" = "zen-beta.desktop";
      "application/x-extension-xht" = "zen-beta.desktop";
      "application/x-extension-xhtml" = "zen-beta.desktop";
      "application/xhtml+xml" = "zen-beta.desktop";
    };
  };

  # Force overwrite existing mimeapps.list
  xdg.configFile."mimeapps.list".force = true;
}
