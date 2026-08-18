{ pkgs, ... }:

{
  networking.hostName = "vivobook";
  networking.networkmanager = {
    enable = true;
    wifi.powersave = true;

    # Enable connectivity checking so NM emits CONNECTIVITY_STATE=PORTAL when
    # behind a captive portal. interval=300 covers both the on-connect check
    # and periodic re-checks when portal sessions expire mid-use.
    settings.connectivity = {
      uri = "http://nmcheck.gnome.org/check_network_status.txt";
      response = "NetworkManager is online";
      interval = 300;
    };

    # Dispatcher that toggles per-link DNS routing to handle captive portals
    # without sacrificing OCI VPS DoT privacy on normal networks.
    #
    # Problem: with Domains=~. on the global OCI VPS DNS, all queries go there
    # first. Captive portals block port 853 (DoT) until authenticated, so DoT
    # times out, then UDP to the VPS fails (port 53 intentionally closed).
    # resolved takes 10-15s to exhaust the VPS and try 1.1.1.1, which is too
    # slow for NM's connectivity check to detect PORTAL quickly.
    #
    # Solution:
    # - on "up":              give the per-link DHCP DNS the ~. routing domain
    #                         so it wins over the global VPS DNS immediately.
    #                         The captive portal's DNS server then handles all
    #                         queries at once, NM detects PORTAL in ~1s.
    # - on FULL connectivity: remove the per-link ~. so the global OCI VPS DoT
    #                         resumes for privacy/ad-blocking.
    # - on PORTAL re-detect:  restore per-link ~. (portal session expired).
    dispatcherScripts = [
      {
        source = pkgs.writeShellScript "captive-dns-routing" ''
          IFACE="$1"
          ACTION="$2"

          [ "$IFACE" = lo ] && exit 0

          case "$ACTION" in
            up)
              ${pkgs.systemd}/bin/resolvectl domain "$IFACE" "~." 2>/dev/null || true
              ;;
            connectivity-change)
              case "$CONNECTIVITY_STATE" in
                FULL)
                  ${pkgs.systemd}/bin/resolvectl domain "$IFACE" "" 2>/dev/null || true
                  ;;
                PORTAL)
                  ${pkgs.systemd}/bin/resolvectl domain "$IFACE" "~." 2>/dev/null || true
                  ;;
              esac
              ;;
          esac
        '';
        type = "basic";
      }
    ];
  };

  # Self-healing backstop for the captive-portal DNS routing above.
  #
  # Problem: the dispatcher's "connectivity-change" action only fires on
  # state *transitions*. On trusted networks the very first connectivity
  # check often already reports FULL, so there is no UNKNOWN->FULL
  # transition for the dispatcher to catch, and the per-link "~." override
  # set by the "up" action never gets cleared — silently routing all DNS
  # through the local (plaintext) DHCP resolver instead of the OCI VPS DoT
  # resolver. The dispatcher's D-Bus activation has also been observed to
  # fail intermittently at boot ("unit is invalid" in the NetworkManager
  # journal), which would drop a clear-override event on the floor too.
  #
  # Fix: poll every minute and clear the override on any up interface
  # whenever connectivity is FULL. Idempotent and a no-op while a portal
  # is active (state won't be "full", so the loop exits immediately).
  systemd.services.captive-dns-routing-reconcile = {
    description = "Clear stale per-link DNS routing domain when connectivity is FULL";
    script = ''
      STATE=$(${pkgs.networkmanager}/bin/nmcli -g CONNECTIVITY general 2>/dev/null || echo unknown)
      [ "$STATE" = "full" ] || exit 0

      for IFACE in $(${pkgs.iproute2}/bin/ip -o link show up | awk -F': ' '{print $2}'); do
        [ "$IFACE" = lo ] && continue
        ${pkgs.systemd}/bin/resolvectl domain "$IFACE" "" 2>/dev/null || true
      done
    '';
    serviceConfig.Type = "oneshot";
  };

  systemd.timers.captive-dns-routing-reconcile = {
    wantedBy = [ "timers.target" ];
    timerConfig = {
      OnBootSec = "30s";
      OnUnitActiveSec = "60s";
    };
  };

  # Syncthing (modules/user/syncthing) runs via home-manager, whose module has
  # no openFirewall option (that only exists on the NixOS system module). Without
  # these, the firewall silently drops LAN discovery and sync connections, so
  # devices can be paired but never actually connect.
  networking.firewall = {
    allowedTCPPorts = [ 22000 ]; # sync protocol
    allowedUDPPorts = [ 22000 21027 ]; # sync protocol (QUIC) + local discovery
  };

  # DoT to OCI AGH with ordered fallback:
  # 1. OCI VPS via DoT (port 853) — privacy + ad blocking
  # 2. 1.1.1.1 / 9.9.9.9 plain UDP — captive portal fallback (portal hijacks
  #    port 53 on these IPs to redirect to login page, which NM detects as PORTAL)
  #
  # FallbackDNS is NOT used here — it only activates when DNS= is empty.
  # Servers must be in DNS= for resolved to try them in order on failure.
  services.resolved = {
    enable = true;
    settings.Resolve = {
      DNS = [ "150.230.145.134#dns.vitorbborges.space" "1.1.1.1" "9.9.9.9" ];
      FallbackDNS = [];
      Domains = "~.";
      DNSSEC = false;
      DNSOverTLS = "opportunistic";
    };
  };
}
