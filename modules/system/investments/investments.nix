{ pkgs, ... }:

{
  systemd.services.investments = {
    description = "Investments n8n stack";
    after = [ "network-online.target" ];
    wants = [ "network-online.target" ];
    # Not wantedBy multi-user.target — started lazily by investments-daily.service.
    # This prevents nixos-rebuild switch from hanging on first-run image pulls.

    serviceConfig = {
      Type = "oneshot";
      RemainAfterExit = true;
      User = "vitor";
      WorkingDirectory = "/home/vitor/Investments/infra";
      # %U in system services always expands to 0 (root). Use id -u at runtime instead.
      ExecStart = pkgs.writeShellScript "investments-start" ''
        export DOCKER_HOST="unix:///run/user/$(id -u)/docker.sock"
        exec /run/current-system/sw/bin/docker compose up -d --build
      '';
      ExecStop = pkgs.writeShellScript "investments-stop" ''
        export DOCKER_HOST="unix:///run/user/$(id -u)/docker.sock"
        exec /run/current-system/sw/bin/docker compose down
      '';
      TimeoutStartSec = "2h"; # first-run image pull can take ~90min on slow connections
    };
  };

  systemd.services.investments-daily = {
    description = "Trigger daily investments n8n workflow";
    after = [ "investments.service" ];
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
