{ pkgs, config, ... }:

let
  zoneName = "vitorbborges.space";
  # A records that must always point at this box.
  #
  # wg.vitorbborges.space exists so WireGuard clients (desktop, phones) can
  # point their Endpoint at a hostname instead of the raw IP — do that and
  # a redeploy needs zero client-side changes. Until you switch client
  # configs over, they still hard-code the IP and need a manual update.
  records = [ "dns.vitorbborges.space" "vault.vitorbborges.space" "wg.vitorbborges.space" ];

  script = pkgs.writeShellApplication {
    name = "ddns-cloudflare";
    runtimeInputs = with pkgs; [ curl jq ];
    text = builtins.replaceStrings
      [ "@tokenPath@" "@zoneName@" "@records@" ]
      [ config.sops.secrets.cloudflare_api_token.path zoneName (toString records) ]
      (builtins.readFile ./scripts/ddns-cloudflare.sh);
  };
in
{
  # Keeps DNS pointed at whatever box is currently running this config —
  # runs on boot and periodically after, so a redeploy to a new VPS (or a
  # future migration to a bigger box / NAS) needs zero manual DNS step.
  systemd.services.ddns-cloudflare = {
    description = "Reconcile Cloudflare DNS with this box's current public IP";
    after = [ "network-online.target" ];
    wants = [ "network-online.target" ];
    serviceConfig = {
      Type = "oneshot";
      ExecStart = "${script}/bin/ddns-cloudflare";
    };
  };

  systemd.timers.ddns-cloudflare = {
    wantedBy = [ "timers.target" ];
    timerConfig = {
      OnBootSec = "1min";
      OnUnitActiveSec = "15min";
      Persistent = true;
    };
  };
}
