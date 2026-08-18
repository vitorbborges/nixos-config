{ pkgs, ... }:

let
  checkScript = pkgs.writeShellApplication {
    name = "nix-update-check";
    runtimeInputs = with pkgs; [ libnotify coreutils ];
    text = builtins.readFile ./scripts/nix-update-check.sh;
  };
in
{
  systemd.user.services.nix-update-reminder = {
    Unit.Description = "NixOS flake update reminder";
    Service = {
      Type = "oneshot";
      ExecStart = "${checkScript}/bin/nix-update-check";
    };
  };

  systemd.user.timers.nix-update-reminder = {
    Unit.Description = "Daily NixOS flake update reminder";
    Timer = {
      OnCalendar = "daily";
      Persistent = true;
    };
    Install.WantedBy = [ "timers.target" ];
  };
}
