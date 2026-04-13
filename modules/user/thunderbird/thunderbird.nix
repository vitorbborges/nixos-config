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
      userChrome = ''
        :root {
          /* surface layers */
          --sidebar-background-color:   ${c.base01} !important;
          --sidebar-text-color:         ${c.base05} !important;
          --sidebar-border-color:       ${c.base02} !important;

          /* toolbar / search field */
          --toolbar-bgcolor:                      ${c.base01} !important;
          --lwt-toolbar-field-background-color:   ${c.base00} !important;
          --lwt-toolbar-field-color:              ${c.base05} !important;
          --lwt-toolbar-field-border-color:       ${c.base03} !important;
          --lwt-toolbar-field-focus:              ${c.base01} !important;

          /* tabs */
          --tabline-color:                  ${c.base0D} !important;
          --tabs-tabbar-background-color:   ${c.base00} !important;

          /* buttons */
          --toolbarbutton-icon-fill:          ${c.base05} !important;
          --toolbarbutton-hover-background:   ${c.base02} !important;
          --toolbarbutton-active-background:  ${c.base03} !important;

          /* focus ring */
          --focus-outline-color: ${c.base0D} !important;

          /* font size from stylix */
          --default-font-size: ${fontSize}px !important;
        }

        /* Folder pane */
        #folderTree,
        #folderPaneBox {
          background-color: ${c.base00} !important;
          color:            ${c.base05} !important;
        }

        /* Thread pane */
        #threadTree {
          background-color: ${c.base00} !important;
          color:            ${c.base05} !important;
        }

        /* Selected row accent */
        .selected,
        [selected="true"],
        richlistitem[selected="true"] {
          background-color: ${c.base02} !important;
          color:            ${c.base05} !important;
          outline-color:    ${c.base0D} !important;
        }

        /* Unread count badge */
        .folderNameCell .unreadCount {
          color: ${c.base0D} !important;
        }

        /* Tag / label colors pulled from stylix */
        .tag-1 { color: ${c.base08} !important; } /* Important → red   */
        .tag-2 { color: ${c.base0A} !important; } /* Work      → yellow */
        .tag-3 { color: ${c.base0B} !important; } /* Personal  → green  */
        .tag-4 { color: ${c.base09} !important; } /* To Do     → orange */
        .tag-5 { color: ${c.base0E} !important; } /* Later     → purple */
      '';
    };
  };
}
