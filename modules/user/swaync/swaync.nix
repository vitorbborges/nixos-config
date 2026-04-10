{ config, ... }:

let
  c    = config.lib.stylix.colors.withHashtag;
  font = config.stylix.fonts.monospace.name;
  sz   = toString config.stylix.fonts.sizes.applications;
  szSm = toString (config.stylix.fonts.sizes.applications - 1);
in

{
  services.swaync = {
    enable = true;

    settings = {
      positionX = "right";
      positionY = "top";
      layer = "overlay";
      control-center-layer = "top";
      layer-shell = true;
      cssPriority = "application";

      control-center-margin-top    = 8;
      control-center-margin-bottom = 8;
      control-center-margin-right  = 8;
      control-center-margin-left   = 0;

      notification-icon-size         = 48;
      notification-body-image-height = 100;
      notification-body-image-width  = 200;

      timeout          = 5;
      timeout-low      = 2;
      timeout-critical = 0;

      fit-to-screen       = true;
      relative-timestamps = true;

      widgets = [ "inhibitors" "title" "dnd" "notifications" ];

      widget-config = {
        inhibitors = {
          text             = "Inhibitors";
          button-text      = "Clear All";
          clear-all-button = true;
        };
        title = {
          text             = "Notifications";
          clear-all-button = true;
          button-text      = "Clear All";
        };
        dnd.text = "Do Not Disturb";
        notifications = {
          notification-icon-size         = 48;
          notification-body-image-height = 100;
          notification-body-image-width  = 200;
          max-notifications              = 5;
        };
      };
    };

    # All values derive from stylix:
    #   font/sizes → config.stylix.fonts.*
    #   colors     → config.lib.stylix.colors.withHashtag
    # Nothing is hardcoded — changing theme or font in flake.nix propagates here.
    style = ''
      * {
        font-family: "${font}", monospace;
        font-size: ${sz}px;
        transition: background-color 150ms ease-out,
                    color 150ms ease-out,
                    opacity 150ms ease-out;
      }

      /* ── Notification popup ─────────────────────────────────────── */
      .notification-row {
        outline: none;
        background: transparent;
        padding: 4px 12px;
      }

      .notification {
        background: ${c.base01};
        border-radius: 12px;
        border: 1px solid ${c.base02};
        padding: 0;
      }

      .notification-content {
        padding: 12px 14px;
      }

      .notification-default-action {
        background: transparent;
        border-radius: 12px;
        padding: 0;
        border: none;
      }

      .notification-default-action:hover {
        background: ${c.base02};
      }

      .notification.low    { border-left: 3px solid ${c.base0B}; }
      .notification.normal { border-left: 3px solid ${c.base0D}; }
      .notification.critical {
        border-left: 3px solid ${c.base08};
        animation: blink 1s steps(1) infinite;
      }

      @keyframes blink { 50% { opacity: 0.6; } }

      .notification-action {
        background: ${c.base02};
        color: ${c.base05};
        border-radius: 8px;
        border: none;
        margin: 0 4px 8px 4px;
        padding: 4px 12px;
        font-size: ${szSm}px;
      }

      .notification-action:hover { background: ${c.base03}; }

      .notification-action:first-child {
        margin-left: 8px;
        border-bottom-left-radius: 8px;
      }

      .notification-action:last-child {
        margin-right: 8px;
        border-bottom-right-radius: 8px;
      }

      .summary {
        font-weight: 700;
        color: ${c.base05};
        font-size: ${sz}px;
      }

      .body {
        color: ${c.base04};
        font-size: ${szSm}px;
        margin-top: 2px;
      }

      .time {
        color: ${c.base03};
        font-size: ${szSm}px;
      }

      .close-button {
        background: transparent;
        color: ${c.base03};
        border: none;
        border-radius: 100%;
        margin: 6px;
        padding: 2px 5px;
        font-size: ${szSm}px;
      }

      .close-button:hover {
        background: ${c.base08};
        color: ${c.base00};
      }

      /* ── Control center ─────────────────────────────────────────── */
      .control-center {
        background: ${c.base00};
        border-radius: 16px;
        border: 1px solid ${c.base02};
        padding: 8px 4px;
        box-shadow: 0 8px 32px rgba(0, 0, 0, 0.6);
      }

      .control-center-list { background: transparent; }

      .control-center-list-placeholder {
        opacity: 0.4;
        color: ${c.base03};
      }

      .widget-title {
        color: ${c.base05};
        font-size: ${sz}px;
        font-weight: 700;
        margin: 4px 8px 0 8px;
        padding: 8px 4px;
        border-bottom: 1px solid ${c.base02};
      }

      .widget-title > button {
        background: ${c.base02};
        color: ${c.base05};
        border-radius: 8px;
        border: none;
        padding: 4px 12px;
        font-size: ${szSm}px;
      }

      .widget-title > button:hover { background: ${c.base03}; }

      .widget-dnd {
        padding: 8px 12px;
        margin: 0 8px;
      }

      .widget-dnd > label {
        color: ${c.base05};
        font-size: ${sz}px;
      }

      .widget-dnd > switch {
        border-radius: 20px;
        background: ${c.base02};
        border: 1px solid ${c.base03};
        min-height: 22px;
        min-width: 44px;
      }

      .widget-dnd > switch:checked {
        background: ${c.base0D};
        border-color: ${c.base0D};
      }

      .widget-dnd > switch slider {
        border-radius: 20px;
        background: ${c.base05};
        min-width: 18px;
        min-height: 18px;
        margin: 2px;
      }

      .widget-inhibitors {
        padding: 4px 12px;
        margin: 0 8px;
        color: ${c.base04};
        font-size: ${szSm}px;
      }
    '';
  };
}
