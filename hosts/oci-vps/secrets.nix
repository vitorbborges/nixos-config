{ ... }:

{
  # Decryption key is NOT nix-managed and NOT in git — it's a dedicated
  # infra age key (independent of any host's SSH key) so it survives a
  # move to a different VPS or a NAS. Provisioned via nixos-anywhere's
  # --extra-files on install; see ../../DISASTER_RECOVERY.md.
  sops.age.keyFile = "/var/lib/sops-nix/key.txt";

  sops.defaultSopsFile = ./secrets.yaml;

  sops.secrets.wireguard_private_key = { };
  sops.secrets.vaultwarden_env = { };
  sops.secrets.restic_password = { };
  sops.secrets.restic_b2_env = { };
  sops.secrets.cloudflare_api_token = { };
}
