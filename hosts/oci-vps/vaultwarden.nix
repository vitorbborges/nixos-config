{ config, ... }:

{
  # Owned by the vaultwarden service user so it can read its TLS cert;
  # populated by the shared certbot service in ./certbot.nix.
  systemd.tmpfiles.rules = [ "d /var/lib/vaultwarden-certs 0750 vaultwarden vaultwarden -" ];

  services.vaultwarden = {
    enable = true;

    # NixOS's built-in backup timer — safe (non-corrupting) sqlite backup,
    # no hand-rolled script needed. Offsite copy is pulled by a desktop-side
    # timer (modules/user/vaultwarden-backup/backup.nix) since this alone
    # only protects against local data loss, not losing the whole VPS.
    backupDir = "/var/backup/vaultwarden";

    # Holds ADMIN_TOKEN. sops-managed (hosts/oci-vps/secrets.nix) — encrypted
    # in git instead of hand-created on the VPS, so it survives a redeploy.
    environmentFile = config.sops.secrets.vaultwarden_env.path;

    config = {
      DOMAIN = "https://vault.vitorbborges.space:8443";

      # Public signups stay off — this is a single-user personal instance
      # exposed to the internet. The one account is created through
      # /admin, gated by ADMIN_TOKEN, instead of ever opening registration.
      SIGNUPS_ALLOWED = false;

      ROCKET_ADDRESS = "0.0.0.0";
      ROCKET_PORT = 8443;
      # Rocket's env-var config parser (Figment) expects TOML inline-table
      # syntax here, not JSON — unquoted keys, "=" not ":".
      ROCKET_TLS = ''{certs="/var/lib/vaultwarden-certs/fullchain.pem",key="/var/lib/vaultwarden-certs/privkey.pem"}'';
    };
  };
}
