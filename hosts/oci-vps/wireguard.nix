{ ... }:

{
  networking.wireguard.interfaces.wg0 = {
    ips = [ "10.10.0.1/24" ];
    listenPort = 443;
    privateKeyFile = "/etc/wireguard/private.key";

    peers = [
      {
        # desktop
        publicKey = "h0apHCa5g+FBa/83jRwQBjUllEp+JQW35pR6R2QfPxg=";
        allowedIPs = [ "10.10.0.2/32" ];
      }
    ];
  };

  # Allow DNS from WireGuard clients (AGH listens on host port 53)
  networking.firewall.interfaces.wg0 = {
    allowedUDPPorts = [ 53 ];
    allowedTCPPorts = [ 53 ];
  };
}
