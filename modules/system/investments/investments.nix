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
      # `id -u vitor` looks up vitor's UID by name (1000), not the current process UID.
      # Required because system services run in root context even with User=vitor set.
      ExecStart = pkgs.writeShellScript "investments-start" ''
        export DOCKER_HOST="unix:///run/user/$(${pkgs.coreutils}/bin/id -u vitor)/docker.sock"
        exec /run/current-system/sw/bin/docker compose up -d --build
      '';
      ExecStop = pkgs.writeShellScript "investments-stop" ''
        export DOCKER_HOST="unix:///run/user/$(${pkgs.coreutils}/bin/id -u vitor)/docker.sock"
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
      ExecStart = pkgs.writeShellScript "investments-trigger" ''
        # Wait for n8n to finish booting (up to 90s) before calling the webhook.
        # docker compose up -d returns as soon as the container starts, but n8n
        # takes several seconds to initialize and register its webhooks.
        for i in $(${pkgs.coreutils}/bin/seq 1 30); do
          if ${pkgs.curl}/bin/curl -sf http://localhost:5678/healthz >/dev/null 2>&1; then
            break
          fi
          if [ "$i" -eq 30 ]; then
            echo "investments-trigger: n8n not ready after 90s" >&2
            exit 1
          fi
          sleep 3
        done
        exec ${pkgs.curl}/bin/curl -sf -X GET http://localhost:5678/webhook/f87c7d39-37da-4477-bdbf-3267700d01ca
      '';
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
