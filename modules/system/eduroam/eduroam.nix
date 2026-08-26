# Bare Polimi eduroam profile (TTLS/PAP), per
# https://www.ict.polimi.it/wifi/permanent-connection/ttls-linux/?lang=en
# (settings cross-checked against the manual Android guide, which lists them
# in text: EAP TTLS, phase 2 PAP, identity PersonCode@polimi.it, anonymous
# identity anonymous@polimi.it, CA = the GÉANT/HARICA chain downloaded from
# the guide).
#
# Safety properties:
# - autoconnect = false: NetworkManager will NEVER activate this profile on
#   its own. It is invisible until you run `nmcli --ask connection up
#   eduroam` yourself, so it cannot interfere with other networks
#   (the earlier hotspot breakage was NM auto-connecting to the eduroam SSID
#   at EDF and knocking the active connection off — impossible now).
# - Password is agent-owned (password-flags=2): lives in gnome-keyring, not
#   in this repo. Polimi passwords expire periodically; when the connection
#   stops working, refresh it with: nmcli --ask connection up eduroam
#
# Rollback if anything misbehaves:
# - Immediate:      nmcli connection down eduroam
# - Fully remove:   git rm -r modules/system/eduroam && nr
{ ... }:

{
  # Link the CA bundle into the system closure (GC-safe, outside the nix
  # store path churn) so the declarative profile can reference a stable
  # /etc path. This file is only ever read by the eduroam profile below —
  # nothing else loads it, so it cannot affect other connections.
  environment.etc."NetworkManager/cacerts/eduroam-geant-harica.pem".source =
    ./cachain_geant_harica.pem;

  networking.networkmanager.ensureProfiles.profiles.eduroam = {
    connection = {
      id = "eduroam";
      type = "wifi";
      autoconnect = false;
    };
    wifi = {
      mode = "infrastructure";
      ssid = "eduroam";
    };
    wifi-security = {
      auth-alg = "open";
      key-mgmt = "wpa-eap";
    };
    "802-1x" = {
      eap = "ttls";
      phase2-auth = "pap";
      identity = "11034968@polimi.it";
      anonymous-identity = "anonymous@polimi.it";
      ca-cert = "/etc/NetworkManager/cacerts/eduroam-geant-harica.pem";
      password-flags = 2;
    };
    ipv4 = {
      method = "auto";
    };
    ipv6 = {
      addr-gen-mode = "default";
      method = "auto";
    };
  };
}
