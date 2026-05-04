{ pkgs, ... }:

{
  systemd.services.portainer = {
    description = "Portainer Docker management UI";
    after = [ "network-online.target" ];
    wants = [ "network-online.target" ];
    wantedBy = [ "multi-user.target" ];

    serviceConfig = {
      Type = "oneshot";
      RemainAfterExit = true;
      User = "vitor";
      # %U in system services always expands to 0 (root). Use id -u at runtime instead.
      ExecStart = pkgs.writeShellScript "portainer-start" ''
        export DOCKER_HOST="unix:///run/user/$(id -u)/docker.sock"
        /run/current-system/sw/bin/docker rm -f portainer 2>/dev/null || true
        exec /run/current-system/sw/bin/docker run -d \
          --name portainer \
          -p 9000:9000 \
          -v portainer_data:/data \
          -v /run/user/$(id -u)/docker.sock:/var/run/docker.sock \
          portainer/portainer-ce:latest
      '';
      ExecStop = pkgs.writeShellScript "portainer-stop" ''
        export DOCKER_HOST="unix:///run/user/$(id -u)/docker.sock"
        exec /run/current-system/sw/bin/docker stop portainer
      '';
      TimeoutStartSec = "10min"; # first-run image pull
    };
  };
}
