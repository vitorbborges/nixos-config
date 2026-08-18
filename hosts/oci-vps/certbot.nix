{ pkgs, ... }:

{
  environment.systemPackages = [ pkgs.certbot ];

  # Certbot: obtain/renew a single Let's Encrypt cert covering both
  # dns.vitorbborges.space (AdGuardHome) and vault.vitorbborges.space
  # (Vaultwarden) as SANs. Stops both services briefly (frees port 80),
  # runs a standalone HTTP-01 challenge, copies the cert to each service's
  # own cert directory, then restarts both. One shared cert/timer avoids
  # two independent certbot runs racing for port 80.
  systemd.services.vps-certbot = {
    description = "Certbot TLS renewal for dns.vitorbborges.space + vault.vitorbborges.space";
    after = [ "network-online.target" "adguardhome.service" "vaultwarden.service" ];
    wants = [ "network-online.target" ];
    path = [ pkgs.docker-compose pkgs.certbot ];
    script = builtins.readFile ./scripts/certbot-renew.sh;
    serviceConfig = {
      Type = "oneshot";
      User = "root";
    };
  };

  systemd.timers.vps-certbot = {
    wantedBy = [ "timers.target" ];
    timerConfig = {
      OnCalendar = "weekly";
      Persistent = true;
    };
  };
}
