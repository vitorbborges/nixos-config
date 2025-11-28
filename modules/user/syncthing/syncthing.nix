{ config, pkgs, ... }:

{
  services.syncthing = {
    enable = true;
    guiAddress = "0.0.0.0:8384";
    tray.enable = true;
  };
}
