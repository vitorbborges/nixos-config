{ pkgs, ... }:

let
  aide-weekly = pkgs.writeShellApplication {
    name = "aide-weekly";
    runtimeInputs = with pkgs; [
      coreutils
      gnugrep
      libnotify
    ];
    text = builtins.replaceStrings
      [ "@AIDE@" ]
      [ "${pkgs.aide}" ]
      (builtins.readFile ./scripts/aide-weekly.sh.in);
  };
in
{
  systemd.user.services.aide-weekly = {
    Unit.Description = "Weekly AIDE integrity check";
    Service = {
      Type = "oneshot";
      ExecStart = "${aide-weekly}/bin/aide-weekly";
    };
  };

  systemd.user.timers.aide-weekly = {
    Unit.Description = "Weekly AIDE integrity check timer";
    Install.WantedBy = [ "timers.target" ];
    Timer = {
      OnCalendar = "weekly";
      Persistent = true;
      RandomizedDelaySec = "30min";
    };
  };
}
