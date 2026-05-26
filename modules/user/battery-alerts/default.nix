{ pkgs, ... }:
let
  sounds = pkgs.sound-theme-freedesktop;

  alert-script = pkgs.writeShellApplication {
    name = "battery-alert";
    runtimeInputs = with pkgs; [ libnotify pulseaudio ];
    text = ''
      state_dir="''${XDG_RUNTIME_DIR:-/tmp}"
      alert15="$state_dir/battery-alert-15"
      alert5="$state_dir/battery-alert-5"
      cap_file="/sys/class/power_supply/BAT0/capacity"
      status_file="/sys/class/power_supply/BAT0/status"

      [[ -f "$cap_file" ]] || exit 0

      level=$(cat "$cap_file")
      status=$(cat "$status_file")

      if [[ "$status" != "Discharging" ]]; then
        rm -f "$alert15" "$alert5"
        exit 0
      fi

      if [[ "$level" -le 5 ]] && [[ ! -f "$alert5" ]]; then
        notify-send --urgency=critical --expire-time=0 \
          "Battery Critical" "Only ''${level}% left — plug in now!"
        paplay "${sounds}/share/sounds/freedesktop/stereo/battery-low.oga" || true
        touch "$alert5"
      elif [[ "$level" -le 15 ]] && [[ ! -f "$alert15" ]]; then
        notify-send --urgency=normal --expire-time=15000 \
          "Battery Low" "''${level}% remaining — consider plugging in"
        paplay "${sounds}/share/sounds/freedesktop/stereo/dialog-warning.oga" || true
        touch "$alert15"
      fi
    '';
  };
in
{
  systemd.user.services.battery-alert = {
    Unit.Description = "Battery level alert check";
    Service = {
      Type = "oneshot";
      ExecStart = "${alert-script}/bin/battery-alert";
    };
  };

  systemd.user.timers.battery-alert = {
    Unit.Description = "Battery level alert timer";
    Install.WantedBy = [ "timers.target" ];
    Timer = {
      OnCalendar = "minutely";
      Persistent = false;
    };
  };
}
