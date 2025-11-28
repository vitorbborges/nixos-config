{ pkgs, ... }:

{
  environment.systemPackages = with pkgs; [
    timeshift
    gparted
  ];
}
