{ ... }:

{
  services.hypridle = {
    enable = true;
    settings = {
      general = {
        lock_cmd = "pidof hyprlock || hyprlock";
        before_sleep_cmd = "loginctl lock-session";  # lock before suspend (lid close / power key)
        # Lua-bridge syntax: raw `hyprctl dispatch dpms on` is broken in Hyprland
        # 0.56 (string not quoted when bridged to hl.dispatch), so use the dsp API.
        after_sleep_cmd = "hyprctl dispatch 'hl.dsp.dpms({ on = true })'";
        ignore_dbus_inhibit = false;
      };

      listener = [
        {
          # 2 min — lock screen
          timeout = 120;
          on-timeout = "pidof hyprlock || hyprlock";
        }
        {
          # 2.5 min — DPMS off (screen dark = OLED pixels off)
          timeout = 150;
          on-timeout = "hyprctl dispatch 'hl.dsp.dpms({ on = false })'";
          on-resume = "hyprctl dispatch 'hl.dsp.dpms({ on = true })'";
        }
      ];
    };
  };
}
