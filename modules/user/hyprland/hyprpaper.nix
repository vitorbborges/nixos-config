{ config, ... }:

{
  services.hyprpaper = {
    enable = true;
    settings = {
      splash = false;
      # Always mirrors stylix.image — both updated together by wallpaper-switch
      preload  = [ "${config.stylix.image}" ];
      wallpaper = [ ",${config.stylix.image}" ]; # empty monitor = all monitors
    };
  };
}
