{ username, lib, ... }:

{
  home.username = username;
  home.homeDirectory = lib.mkForce "/home/${username}";
  home.stateVersion = "25.05";

  imports = [ ../../modules/server ];

  programs.home-manager.enable = true;
}
