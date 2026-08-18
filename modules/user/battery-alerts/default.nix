{ pkgs, ... }:
let
  sounds = pkgs.sound-theme-freedesktop;

  alert-script = pkgs.writeShellApplication {
    name = "battery-alert";
    runtimeInputs = with pkgs; [ libnotify pulseaudio ];
    text = builtins.replaceStrings
      [ "@soundBatteryLow@" "@soundDialogWarning@" ]
      [ "${sounds}/share/sounds/freedesktop/stereo/battery-low.oga" "${sounds}/share/sounds/freedesktop/stereo/dialog-warning.oga" ]
      (builtins.readFile ./scripts/battery-alert.sh);
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
