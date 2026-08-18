{ pkgs, username, ... }:

{
  networking.wireguard.interfaces.wg0 = {
    ips = [ "10.10.0.2/32" ];
    privateKeyFile = "/etc/wireguard/private.key";

    peers = [
      {
        # oci-vps
        publicKey = "oPOvDkmppQ5sXZtCXgkw7NGf0QLf60JQUo9Eka13tjU=";
        endpoint = "150.230.145.134:443";
        allowedIPs = [ "10.10.0.0/24" ];
        persistentKeepalive = 25;
      }
    ];
  };

  # Open a browser automatically when NM detects a captive portal.
  # Dispatcher runs as root; we read WAYLAND_DISPLAY from the running Hyprland
  # process so we can open a window in the correct Wayland session.
  networking.networkmanager.dispatcherScripts = [
    {
      source = pkgs.writeShellApplication {
        name = "captive-portal-browser";
        runtimeInputs = with pkgs; [ procps util-linux xdg-utils ];
        text = builtins.replaceStrings
          [ "@username@" ]
          [ username ]
          (builtins.readFile ./scripts/captive-portal-browser.sh);
      };
      type = "basic";
    }
  ];
}
