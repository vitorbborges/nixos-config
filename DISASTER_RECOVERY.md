# oci-vps disaster recovery / migration runbook

Covers: Oracle reclaims/kills the VPS, or you deliberately move to a bigger
VPS or a NAS. Same procedure either way — the goal is "new box, same
services" with no manual re-keying.

## What's already reproducible from this repo

- OS + all services: `nixos-anywhere` + disko (`hosts/oci-vps/hardware.nix`).
- Secrets: sops-encrypted in git (`hosts/oci-vps/secrets.yaml`), decrypted at
  boot via a dedicated age key — **not** derived from the box's SSH host key,
  so it works identically on any new box. See `hosts/oci-vps/secrets.nix`.
- DNS: `hosts/oci-vps/ddns-cloudflare.nix` repoints `dns.*` / `vault.*` /
  `wg.*` A records at whatever IP the box currently has, within ~1 minute of
  boot. No manual DNS step needed.
- Vaultwarden vault + AdGuardHome config: restored from the restic backup in
  `hosts/oci-vps/backup.nix` (Backblaze B2) or from the desktop-side pull in
   the restic backup described below.

## What's explicitly NOT covered (acceptable loss)

- ActivityWatch's local aggregated history — cosmetic, not backed up.
- Let's Encrypt's account/cert cache — cheap to reissue, not backed up.

## One-time setup (do this now, before you need it)

1. **Age key**: already generated, at `~/.config/sops/age/keys.txt` on this
   desktop (public key in `.sops.yaml`). Keep a second copy somewhere that
   survives this desktop dying too — e.g. an encrypted export in a password
   manager that *isn't* Vaultwarden (circular: Vaultwarden is one of the
   things you're recovering). This key is the one thing that isn't git-able.
2. **Backblaze B2**: create a private bucket (e.g. `oci-vps-backup`) and an
   application key scoped to it **without delete capability**. Update the
   bucket name in `hosts/oci-vps/backup.nix` if you name it differently.
3. **Cloudflare API token**: My Profile → API Tokens → create one scoped to
   `Zone.DNS: Edit` for `vitorbborges.space` only.
4. **Populate real secret values** (run locally, never paste these into
   chat/Claude):
   ```sh
   # existing WireGuard key + vaultwarden admin token, pulled from the live box
   ssh vps sudo cat /etc/wireguard/private.key
   ssh vps sudo cat /etc/vaultwarden.env

   # edit in place with your $EDITOR, sops re-encrypts on save
   sops hosts/oci-vps/secrets.yaml
   ```
   Fill in: `wireguard_private_key`, `vaultwarden_env` (the full file
   content), `restic_password` (make one up, this *is* the backup
   encryption key — store it alongside the age key), `restic_b2_env`
   (`B2_ACCOUNT_ID=...` / `B2_ACCOUNT_KEY=...`), `cloudflare_api_token`.
5. **DNS**: create the `wg.vitorbborges.space` A record in Cloudflare
   (any IP, the reconciler will fix it), and consider pointing your
   WireGuard client configs (desktop, phones) at `wg.vitorbborges.space`
   instead of the raw IP — then a redeploy needs *zero* client-side changes.
6. Rebuild once (`sudo nixos-rebuild switch --target-host vps --flake .#oci-vps`)
   so the current box picks up sops-nix and the new services.

## Recovery steps (when the box is actually gone)

1. Get a fresh box (new OCI instance, another provider, or a NAS running
   NixOS) with root SSH access. Check `hosts/oci-vps/hardware.nix` — disko
   assumes the disk is `/dev/sda`; adjust if the new box presents
   differently (e.g. `/dev/vda`, `/dev/nvme0n1`).
2. Stage the age key for `--extra-files`:
   ```sh
   mkdir -p /tmp/extra-files/var/lib/sops-nix
   cp ~/.config/sops/age/keys.txt /tmp/extra-files/var/lib/sops-nix/key.txt
   chmod 600 /tmp/extra-files/var/lib/sops-nix/key.txt
   ```
3. Deploy:
   ```sh
   nixos-anywhere --flake .#oci-vps --extra-files /tmp/extra-files root@<new-ip>
   ```
4. On first boot: sops-nix decrypts secrets, WireGuard comes up with the
   *same* key (existing peers reconnect once endpoint IP/hostname is
   updated), Vaultwarden starts with its admin token, and
   `ddns-cloudflare` repoints DNS at the new IP within ~1 minute.
5. Once DNS has propagated (TTL is 300s), issue fresh TLS certs:
   ```sh
   ssh vps systemctl start vps-certbot.service
   ```
6. Restore data:
   ```sh
   nix run nixpkgs#restic -- -r b2:oci-vps-backup:restic restore latest --target /
   systemctl restart adguardhome vaultwarden
   ```
   (run on the box itself, with `RESTIC_PASSWORD_FILE`/`B2_ACCOUNT_ID`/
   `B2_ACCOUNT_KEY` sourced from the same secrets — or just decrypt them
   locally and export as env vars for the one-off restore command.)
7. If any WireGuard client still hard-codes the old IP, update its Endpoint
   (or switch it to `wg.vitorbborges.space` now, per step 5 above, so this
   never has to happen again).
