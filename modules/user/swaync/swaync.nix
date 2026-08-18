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

      fit-to-screen       = false;
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
    # The CSS lives in ./style.css.in with @placeholder@ tokens substituted
    # at eval time — changing theme or font in flake.nix propagates here.
    style = builtins.replaceStrings
      [ "@font@" "@sz@" "@szSm@" "@base00@" "@base01@" "@base02@" "@base03@" "@base04@" "@base05@" "@base08@" "@base0B@" "@base0D@" ]
      [ font sz szSm c.base00 c.base01 c.base02 c.base03 c.base04 c.base05 c.base08 c.base0B c.base0D ]
      (builtins.readFile ./style.css.in);
  };
}
