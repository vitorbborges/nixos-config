{ ... }:

{
  services.hypridle = {
    enable = true;
    settings = {
      general = {
        lock_cmd = "pidof hyprlock || hyprlock";
        before_sleep_cmd = "loginctl lock-session";  # lock before suspend (lid close / power key)
        after_sleep_cmd = "hyprctl dispatch dpms on";
        ignore_dbus_inhibit = false;
      };

      listener = [
        {
          # 5 min — lock screen
          timeout = 300;
          on-timeout = "pidof hyprlock || hyprlock";
        }
        {
          # 5.5 min — DPMS off (screen dark = OLED pixels off)
          timeout = 330;
          on-timeout = "hyprctl dispatch dpms off";
          on-resume = "hyprctl dispatch dpms on";
        }
      ];
    };
  };
}
