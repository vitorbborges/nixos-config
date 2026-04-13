{ pkgs, ... }:

{
  systemd.services.investments = {
    description = "Investments n8n stack";
    after = [ "docker.service" "network-online.target" ];
    wants = [ "network-online.target" ];
    requires = [ "docker.service" ];
    wantedBy = [ "multi-user.target" ];

    serviceConfig = {
      Type = "oneshot";
      RemainAfterExit = true;
      WorkingDirectory = "/home/vitor/Investments/infra";
      ExecStart = "/run/current-system/sw/bin/docker compose up -d --build";
      ExecStop = "/run/current-system/sw/bin/docker compose down";
      TimeoutStartSec = "5min"; # image build can be slow
    };
  };

  systemd.services.investments-daily = {
    description = "Trigger daily investments n8n workflow";
    after = [ "investments.service" "network-online.target" ];
    requires = [ "investments.service" ];
    serviceConfig = {
      Type = "oneshot";
      ExecStart = "${pkgs.curl}/bin/curl -sf -X GET http://localhost:5678/webhook/f87c7d39-37da-4477-bdbf-3267700d01ca";
    };
  };

  systemd.timers.investments-daily = {
    description = "Daily investments workflow trigger";
    wantedBy = [ "timers.target" ];
    timerConfig = {
      OnCalendar = "09:00:00";
      Persistent = true; # runs immediately on boot if the scheduled time was missed
    };
  };
}
