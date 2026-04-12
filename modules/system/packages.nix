{ pkgs, ... }:

{
  environment.systemPackages = with pkgs; [
    timeshift
    gparted
    wget
  ];

  # gvfs: lets Nautilus (and other GTK apps) see and mount removable drives via udisks2
  services.gvfs.enable = true;

  # GameMode daemon — CPU/GPU scheduling boost when a game starts (Steam enables automatically)
  programs.gamemode.enable = true;
}
