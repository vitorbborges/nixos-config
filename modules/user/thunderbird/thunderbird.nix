{ config, ... }:

let
  c = config.lib.stylix.colors.withHashtag;
  fontSize = toString config.stylix.fonts.sizes.applications;
in

{
  programs.thunderbird = {
    enable = true;
    profiles."default" = {
      isDefault = true;

      settings = {
        # --- Dark mode: follow system (GTK dark theme via stylix) ---
        "ui.systemUsesDarkTheme" = 1;
        "layout.css.prefers-color-scheme.content-override" = 0;

        # --- Privacy ---
        "datareporting.healthreport.uploadEnabled" = false;
        "datareporting.policy.dataSubmissionEnabled" = false;
        "toolkit.telemetry.enabled" = false;
        "toolkit.telemetry.unified" = false;
        "toolkit.telemetry.archive.enabled" = false;
        "app.shield.optoutstudies.enabled" = false;
        "browser.crashReports.unsubmittedCheck.autoSubmit2" = false;
        # Block remote images by default (privacy + faster load)
        "mailnews.message_display.disable_remote_image" = true;

        # --- UX ---
        "mail.show_headers" = 1;                 # compact headers
        "mailnews.default_sort_type" = 18;       # sort by date
        "mailnews.default_sort_order" = 2;       # descending (newest first)
        "mail.tabs.drawInTitlebar" = true;
        "mail.pane_config.dynamic" = 2;          # vertical reading pane
        "mailnews.thread_without_re" = true;     # thread even if no "Re:"
      };

      # stylix has no Thunderbird target — inject colors manually.
      # GTK theme (stylix.targets.gtk) handles most chrome; this CSS
      # overrides the XUL-specific variables that GTK doesn't reach.
      # The CSS lives in ./userChrome.css.in with @placeholder@ tokens
      # substituted at eval time from stylix colors.
      userChrome = builtins.replaceStrings
        [ "@fontSize@" "@base00@" "@base01@" "@base02@" "@base03@" "@base05@" "@base08@" "@base09@" "@base0A@" "@base0B@" "@base0D@" "@base0E@" ]
        [ fontSize c.base00 c.base01 c.base02 c.base03 c.base05 c.base08 c.base09 c.base0A c.base0B c.base0D c.base0E ]
        (builtins.readFile ./userChrome.css.in);
    };
  };
}
