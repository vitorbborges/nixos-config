{ pkgs, ... }:

let
  pull = pkgs.writeShellApplication {
    name = "vaultwarden-backup-pull";
    runtimeInputs = with pkgs; [ rsync openssh ];
    text = builtins.readFile ./scripts/pull.sh;
  };
in
{
  # Offsite copy of the VPS's Vaultwarden backups (services.vaultwarden.backupDir
  # on oci-vps only protects against local data loss on the VPS itself — this
  # protects against losing the whole instance, e.g. Oracle Free Tier reclamation).
  systemd.user.services.vaultwarden-backup-pull = {
    Unit.Description = "Pull Vaultwarden backups from the VPS";
    Service = {
      Type = "oneshot";
      ExecStart = "${pull}/bin/vaultwarden-backup-pull";
    };
  };

  systemd.user.timers.vaultwarden-backup-pull = {
    Unit.Description = "Daily Vaultwarden offsite backup pull";
    Install.WantedBy = [ "timers.target" ];
    Timer = {
      OnCalendar = "daily";
      Persistent = true;
      RandomizedDelaySec = "30min";
    };
  };
}
