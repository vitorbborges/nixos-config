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

  environment.systemPackages = [ pkgs.docker-compose ];

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
}
