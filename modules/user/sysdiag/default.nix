{ pkgs, ... }:
let
  sysdiag = pkgs.writeShellApplication {
    name = "sysdiag";
    runtimeInputs = with pkgs; [
      lm_sensors
      smartmontools
      nvme-cli
      stress-ng
      upower
      bc
      jq
      libnotify
    ];
    text = builtins.readFile ./scripts/sysdiag.sh;
  };

  snapshot = pkgs.writeShellScript "sysdiag-snapshot" ''
    dir="$HOME/.local/share/sysdiag"
    mkdir -p "$dir"
    stamp=$(date '+%Y-%m-%dT%H:%M:%S')
    printf '\n=== Snapshot %s ===\n' "$stamp" >> "$dir/snapshots.log"
    ${sysdiag}/bin/sysdiag --notify >> "$dir/snapshots.log" 2>&1 || true
  '';
in
{
  home.packages = [ sysdiag ];

  systemd.user.services.sysdiag-snapshot = {
    Unit.Description = "Weekly system diagnostics snapshot";
    Service = {
      Type = "oneshot";
      ExecStart = "${snapshot}";
    };
  };

  systemd.user.timers.sysdiag-snapshot = {
    Unit.Description = "Weekly system diagnostics snapshot timer";
    Install.WantedBy = [ "timers.target" ];
    Timer = {
      OnCalendar = "weekly";
      Persistent = true;
      RandomizedDelaySec = "30min";
    };
  };
}
