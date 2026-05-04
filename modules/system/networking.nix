{ ... }:

{
  networking.hostName = "vivobook";
  networking.networkmanager = {
    enable = true;
    wifi.powersave = true;  # battery-friendly on laptop
  };

  # Fallback to Cloudflare/Google when local router DNS fails
  networking.nameservers = [ "1.1.1.1" "8.8.8.8" ];
}
