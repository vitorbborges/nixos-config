{ pkgs, ... }:

{
  # AdGuardHome docker-compose managed by NixOS
  environment.etc."adguardhome/docker-compose.yml".text = ''
    services:
      adguardhome:
        image: adguard/adguardhome:latest
        network_mode: host
        volumes:
          - /var/lib/adguardhome/work:/opt/adguardhome/work
          - /var/lib/adguardhome/conf:/opt/adguardhome/conf
        restart: unless-stopped
  '';

  systemd.tmpfiles.rules = [
    "d /var/lib/adguardhome/work 0750 root root -"
    "d /var/lib/adguardhome/conf 0750 root root -"
  ];

  environment.systemPackages = [ pkgs.docker-compose pkgs.certbot ];

  systemd.services.adguardhome = {
    description = "AdGuardHome (docker-compose)";
    after = [ "docker.service" "network-online.target" ];
    requires = [ "docker.service" ];
    wants = [ "network-online.target" ];
    wantedBy = [ "multi-user.target" ];
    serviceConfig = {
      Type = "oneshot";
      RemainAfterExit = true;
      ExecStart = "${pkgs.docker-compose}/bin/docker-compose -f /etc/adguardhome/docker-compose.yml up -d --pull always";
      ExecStop = "${pkgs.docker-compose}/bin/docker-compose -f /etc/adguardhome/docker-compose.yml down";
    };
  };

  # Certbot: obtain/renew Let's Encrypt cert for dns.vitorrborges.space
  # Stops AGH briefly (frees port 80), runs standalone HTTP-01 challenge, then restarts AGH.
  # Certs are copied to /var/lib/adguardhome/conf/ where AGH reads them via
  # certificate_path and private_key_path in AdGuardHome.yaml.
  systemd.services.adguardhome-certbot = {
    description = "Certbot TLS renewal for dns.vitorrborges.space";
    after = [ "network-online.target" "adguardhome.service" ];
    wants = [ "network-online.target" ];
    script = ''
      compose="${pkgs.docker-compose}/bin/docker-compose -f /etc/adguardhome/docker-compose.yml"
      certbot="${pkgs.certbot}/bin/certbot"
      $compose stop || true
      $certbot certonly \
        --standalone \
        --non-interactive \
        --agree-tos \
        --email vitorbborges31@gmail.com \
        -d dns.vitorrborges.space \
        && {
          cp /etc/letsencrypt/live/dns.vitorrborges.space/fullchain.pem /var/lib/adguardhome/conf/fullchain.pem
          cp /etc/letsencrypt/live/dns.vitorrborges.space/privkey.pem   /var/lib/adguardhome/conf/privkey.pem
          chmod 640 /var/lib/adguardhome/conf/fullchain.pem /var/lib/adguardhome/conf/privkey.pem
        }
      $compose start
    '';
    serviceConfig = {
      Type = "oneshot";
      User = "root";
    };
  };

  systemd.timers.adguardhome-certbot = {
    wantedBy = [ "timers.target" ];
    timerConfig = {
      OnCalendar = "weekly";
      Persistent = true;
    };
  };
}
