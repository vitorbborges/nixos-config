{ config, pkgs, ... }:

{
  services.syncthing = {
    enable = true;
    guiAddress = "127.0.0.1:8384";
    tray.enable = true;
  };
}
