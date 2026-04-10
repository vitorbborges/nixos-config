{ ... }:

{
  networking.hostName = "vivobook";
  networking.networkmanager = {
    enable = true;
    wifi.powersave = true;  # battery-friendly on laptop
  };
}
