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
      source = pkgs.writeShellScript "captive-portal-browser" ''
        [ "$2" = "connectivity-change" ] || exit 0
        [ "$CONNECTIVITY_STATE" = "PORTAL" ] || exit 0

        uid=$(id -u "${username}")
        runtime_dir="/run/user/$uid"

        hyprland_pid=$(${pkgs.procps}/bin/pgrep -u "${username}" -x Hyprland 2>/dev/null | head -1)
        if [ -n "$hyprland_pid" ]; then
          wayland_display=$(tr '\0' '\n' < /proc/"$hyprland_pid"/environ 2>/dev/null \
            | grep ^WAYLAND_DISPLAY= | cut -d= -f2)
        fi
        wayland_display="''${wayland_display:-wayland-1}"

        ${pkgs.util-linux}/bin/runuser -u "${username}" -- \
          env XDG_RUNTIME_DIR="$runtime_dir" \
              WAYLAND_DISPLAY="$wayland_display" \
              DBUS_SESSION_BUS_ADDRESS="unix:path=$runtime_dir/bus" \
              ${pkgs.xdg-utils}/bin/xdg-open "http://neverssl.com" &
      '';
      type = "basic";
    }
  ];
}
