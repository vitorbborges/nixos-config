{ pkgs, ... }:
let
  maint = pkgs.writeShellApplication {
    name = "maint";
    runtimeInputs = with pkgs; [ sqlite coreutils ];
    text = builtins.readFile ./scripts/maint.sh;
  };

  maintenanceCheck = pkgs.writeShellApplication {
    name = "maintenance-check";
    runtimeInputs = with pkgs; [ sqlite coreutils libnotify ];
    text = builtins.readFile ./scripts/maintenance-check.sh;
  };
in
{
  home.packages = [ maint maintenanceCheck ];

  systemd.user.services.maintenance-check = {
    Unit.Description = "Calendar-based hardware maintenance reminder check";
    Service = {
      Type = "oneshot";
      ExecStart = "${maintenanceCheck}/bin/maintenance-check";
    };
  };

  systemd.user.timers.maintenance-check = {
    Unit.Description = "Hourly maintenance reminder check (escalates re-nag frequency the more overdue a task is)";
    Install.WantedBy = [ "timers.target" ];
    Timer = {
      OnCalendar = "hourly";
      Persistent = true;
    };
  };
}
