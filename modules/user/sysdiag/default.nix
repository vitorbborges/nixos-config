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

  snapshot = pkgs.writeShellApplication {
    name = "sysdiag-snapshot";
    runtimeInputs = with pkgs; [ coreutils ];
    text = builtins.readFile ./scripts/sysdiag-snapshot.sh;
  };
in
{
  home.packages = [
    sysdiag
    pkgs.nvtopPackages.full
    pkgs.s-tui
    pkgs.inxi
    pkgs.powertop
  ];

  systemd.user.services.sysdiag-snapshot = {
    Unit.Description = "Weekly system diagnostics snapshot";
    Service = {
      Type = "oneshot";
      ExecStart = "${snapshot}/bin/sysdiag-snapshot";
      Environment = "SYSDIAG_BIN=${sysdiag}/bin/sysdiag";
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
