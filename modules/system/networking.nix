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
