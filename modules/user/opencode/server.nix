# On-demand `opencode web` server.
#
# Two user services:
#   - opencode-web      : the actual web server (port 4096), started/stopped on
#                         demand — not enabled at login
#   - opencode-web-ctl  : control page on port 4097. Opening it auto-starts the
#                         server; a heartbeat from the page keeps it alive, and
#                         it stops ~90s after the last page closes (instantly
#                         when the closing tab can send a "stop" beacon)

{ config, lib, pkgs, ... }:

let
  c = config.lib.stylix.colors.withHashtag;
  font = config.stylix.fonts.sansSerif.name;

  webPort = 4096;
  ctlPort = 4097;

  # control page with the stylix palette injected at build time
  page = pkgs.writeText "opencode-web-control.html" (lib.replaceStrings
    [
      "@bg@" "@panel@" "@text@" "@muted@"
      "@primary@" "@success@" "@error@"
      "@font@" "@webPort@"
    ]
    [
      c.base00 c.base01 c.base05 c.base04
      c.base0D c.base0B c.base08
      font (toString webPort)
    ]
    (builtins.readFile ./control.html));

  # stdlib-only HTTP server; SYSTEMCTL overridable for testing
  ctl = pkgs.writeScript "opencode-web-ctl" ''
    #!${pkgs.python3}/bin/python3
    import json
    import os
    import subprocess
    import sys
    import threading
    import time
    from http.server import BaseHTTPRequestHandler, ThreadingHTTPServer

    SYSTEMCTL = os.environ.get("SYSTEMCTL", "${pkgs.systemd}/bin/systemctl")
    UNIT = "opencode-web"
    PAGE = open(sys.argv[1]).read()

    HEARTBEAT_TIMEOUT = 90  # stop the server this long after the page stops pinging
    HEARTBEAT_GUARD = 4     # closing one tab must not kill another tab's session

    last_heartbeat = 0.0
    lock = threading.Lock()

    def systemctl(*args):
        return subprocess.run([SYSTEMCTL, "--user", *args],
                              capture_output=True, text=True)

    def is_active():
        return systemctl("is-active", "--quiet", UNIT).returncode == 0

    def watch():
        global last_heartbeat
        while True:
            time.sleep(5)
            with lock:
                last = last_heartbeat
            if last and time.time() - last > HEARTBEAT_TIMEOUT and is_active():
                systemctl("stop", UNIT)
                with lock:
                    last_heartbeat = 0.0

    threading.Thread(target=watch, daemon=True).start()

    class Handler(BaseHTTPRequestHandler):
        def log_message(self, *args):
            pass

        def _send(self, code, body, ctype="application/json"):
            self.send_response(code)
            self.send_header("Content-Type", ctype)
            self.send_header("Content-Length", str(len(body)))
            self.end_headers()
            self.wfile.write(body)

        def do_GET(self):
            if self.path in ("/", "/index.html"):
                self._send(200, PAGE.encode(), "text/html; charset=utf-8")
            elif self.path == "/status":
                self._send(200, json.dumps({"active": is_active()}).encode())
            else:
                self._send(404, b"not found")

        def do_POST(self):
            global last_heartbeat
            length = int(self.headers.get("Content-Length") or 0)
            body = self.rfile.read(length).decode("utf-8", "replace") if length else ""

            if self.path == "/heartbeat":
                now = time.time()
                stop = False
                with lock:
                    if body == "stop":
                        # tab closing: only stop if no other tab is still pinging
                        stop = last_heartbeat and now - last_heartbeat > HEARTBEAT_GUARD
                    else:
                        last_heartbeat = now
                if stop:
                    systemctl("stop", UNIT)
                    with lock:
                        last_heartbeat = 0.0
                self._send(200, json.dumps({"active": is_active()}).encode())
                return

            if self.path == "/start":
                r = systemctl("start", UNIT)
                with lock:
                    last_heartbeat = time.time()
            elif self.path == "/stop":
                r = systemctl("stop", UNIT)
                with lock:
                    last_heartbeat = 0.0
            else:
                self._send(404, b"not found")
                return
            self._send(200, json.dumps({
                "ok": r.returncode == 0,
                "active": is_active(),
                "stderr": r.stderr,
            }).encode())

    ThreadingHTTPServer(("127.0.0.1", ${toString ctlPort}), Handler).serve_forever()
  '';
in
{
  systemd.user.services.opencode-web = {
    Unit.Description = "OpenCode web server";
    Service = {
      Type = "simple";
      ExecStart = "${pkgs.opencode}/bin/opencode web --port ${toString webPort}";
      Restart = "on-failure";
      RestartSec = 2;
      # don't try to open a browser from a headless service
      Environment = "BROWSER=${pkgs.coreutils}/bin/true";
      WorkingDirectory = "%h";
    };
    # no Install section → started/stopped on demand via the control page
  };

  systemd.user.services.opencode-web-ctl = {
    Unit.Description = "OpenCode web control page";
    Service = {
      Type = "simple";
      ExecStart = "${ctl} ${page}";
      Restart = "on-failure";
      RestartSec = 2;
    };
    Install.WantedBy = [ "default.target" ];
  };
}
