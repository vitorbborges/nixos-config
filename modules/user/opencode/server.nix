# On-demand `opencode web` server.
#
#   opencode-web       : the real web server (127.0.0.1:40960), started/stopped
#                        on demand — not enabled at login
#   opencode-web-proxy : transparent TCP proxy on 127.0.0.1:4096. Opening
#                        http://localhost:4096 in a browser starts the backend
#                        automatically; when the last tab closes, the proxy
#                        stops the backend after IDLE_STOP seconds of zero
#                        connections. No control page, no second port.

{ lib, pkgs, ... }:

let
  webPort = 4096;
  backendPort = 40960;

  proxyScript = pkgs.writeText "opencode-web-proxy.py"
    (lib.replaceStrings
      [ "@SYSTEMCTL@" ]
      [ "${pkgs.systemd}/bin/systemctl" ]
      (builtins.readFile ./scripts/proxy.py));
in
{
  systemd.user.services.opencode-web = {
    Unit.Description = "OpenCode web server";
    Service = {
      Type = "simple";
      ExecStart = "${pkgs.opencode}/bin/opencode web --port ${toString backendPort}";
      Restart = "on-failure";
      RestartSec = 2;
      # don't try to open a browser from a headless service
      Environment = "BROWSER=${pkgs.coreutils}/bin/true";
      WorkingDirectory = "%h";
    };
    # no Install section → started/stopped on demand by the proxy
  };

  systemd.user.services.opencode-web-proxy = {
    Unit.Description = "OpenCode web proxy (auto start/stop on tab activity)";
    Service = {
      Type = "simple";
      ExecStart = "${pkgs.python3}/bin/python3 ${proxyScript}";
      Restart = "on-failure";
      RestartSec = 2;
      Environment = [
        "LISTEN_PORT=${toString webPort}"
        "BACKEND_PORT=${toString backendPort}"
        "IDLE_STOP=30"
      ];
    };
    Install.WantedBy = [ "default.target" ];
  };
}
