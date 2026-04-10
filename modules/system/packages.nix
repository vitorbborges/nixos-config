{ pkgs, ... }:

{
  environment.systemPackages = with pkgs; [
    timeshift
    gparted
    wget
  ];

  # GameMode daemon — CPU/GPU scheduling boost when a game starts (Steam enables automatically)
  programs.gamemode.enable = true;
}
