{ config, ... }:

{
  networking.wireguard.interfaces.wg0 = {
    ips = [ "10.10.0.1/24" ];
    listenPort = 443;
    # sops-managed (hosts/oci-vps/secrets.nix) so the same key — and thus
    # the existing peers below — survives a redeploy to a new box.
    privateKeyFile = config.sops.secrets.wireguard_private_key.path;

    peers = [
      {
        # desktop
        publicKey = "h0apHCa5g+FBa/83jRwQBjUllEp+JQW35pR6R2QfPxg=";
        allowedIPs = [ "10.10.0.2/32" ];
      }
      {
        # phone - personal profile (WG Tunnel app)
        publicKey = "1AtRIlgiFHlpa/uIjTJIxUg7OuoRdpxS66pSHT5VPxE=";
        allowedIPs = [ "10.10.0.3/32" ];
      }
      {
        # phone - work profile (WG Tunnel app, separate Android user/sandbox)
        publicKey = "22r9S6Brf3Sz5t4iULcURaZjusPFw03715DZBHnTp10=";
        allowedIPs = [ "10.10.0.4/32" ];
      }
    ];
  };

  # Allow DNS from WireGuard clients — AGH listens on host port 53, deliberately
  # NOT in the top-level public firewall, only reachable over this tunnel.
  networking.firewall.interfaces.wg0 = {
    allowedUDPPorts = [ 53 ];
    allowedTCPPorts = [ 53 ];
  };
}
