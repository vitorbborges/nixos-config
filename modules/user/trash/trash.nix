{ pkgs, ... }:

{
  # yazi (>= 26.8.15) trashes to the FreeDesktop location
  # (~/.local/share/Trash); trash-cli purges entries older than 30 days.
  systemd.user.services.trash-empty = {
    Unit.Description = "Purge trash entries older than 30 days";
    Service = {
      Type = "oneshot";
      ExecStart = "${pkgs.trash-cli}/bin/trash-empty -f 30";
    };
  };

  systemd.user.timers.trash-empty = {
    Unit.Description = "Daily purge of 30-day-old trash";
    Install.WantedBy = [ "timers.target" ];
    Timer = {
      OnCalendar = "daily";
      Persistent = true;
      RandomizedDelaySec = "30min";
    };
  };
}
