{ config, ... }:

{
  # Offsite backup (encrypted restic → Backblaze B2) so a single machine
  # dying doesn't take out the only copy. Covers state that isn't already
  # reproducible from this git repo: AdGuardHome's filter rules/config and
  # Vaultwarden's own backup dir. Credentials are sops-managed — see
  # ./secrets.nix.
  #
  # One-time setup still needed (can't be done from Nix):
  #   1. Create a Backblaze B2 bucket, e.g. "oci-vps-backup" (private).
  #   2. Create an application key scoped to that bucket WITHOUT delete
  #      capability (ransomware/blast-radius protection — a leaked key
  #      can't wipe existing snapshots).
  #   3. Fill in restic_password / restic_b2_env in secrets.yaml (see
  #      DISASTER_RECOVERY.md) and update the bucket name below if different.
  services.restic.backups.oci-vps = {
    repository = "b2:oci-vps-backup:restic";
    passwordFile = config.sops.secrets.restic_password.path;
    environmentFile = config.sops.secrets.restic_b2_env.path;
    initialize = true;

    paths = [
      "/var/lib/adguardhome/conf"
      "/var/lib/adguardhome/work"
      "/var/backup/vaultwarden"
    ];

    pruneOpts = [
      "--keep-daily 7"
      "--keep-weekly 5"
      "--keep-monthly 12"
    ];

    timerConfig = {
      OnCalendar = "daily";
      Persistent = true;
      RandomizedDelaySec = "30min";
    };
  };

  # Don't back up mid-write.
  systemd.services.restic-backups-oci-vps.after = [ "adguardhome.service" "vaultwarden.service" ];
}
