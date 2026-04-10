{ ... }:

{
  hardware.bluetooth = {
    enable = true;
    powerOnBoot = true; # auto-power BT adapter on startup
    settings.Policy.AutoEnable = "true"; # keep adapter enabled across reboots
  };

  services.blueman.enable = true; # blueman-applet for system tray (fallback GUI)
}
