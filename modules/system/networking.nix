{ ... }:

{
  networking.hostName = "vivobook";
  networking.networkmanager = {
    enable = true;
    wifi.powersave = true;
  };

  # DoT to AGH — same as Android "Private DNS". Opportunistic = falls back to
  # plain DNS when port 853 is blocked (captive portals), which the portal can
  # then intercept. Port 53 is intentionally closed on the VPS so plain DNS to
  # AGH fails too, pushing resolved to the fallback servers the portal hijacks.
  services.resolved = {
    enable = true;
    settings.Resolve = {
      DNS = [ "150.230.145.134#dns.vitorbborges.space" ];
      FallbackDNS = [ "1.1.1.1#cloudflare-dns.com" "9.9.9.9#dns.quad9.net" ];
      Domains = "~.";
      DNSSEC = false;
      DNSOverTLS = "opportunistic";
    };
  };
}
