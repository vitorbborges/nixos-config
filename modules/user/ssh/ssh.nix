{ pkgs, lib, ... }:

{

  programs.ssh = {
    enable = true;
    addKeysToAgent = "yes";
    enableDefaultConfig = false;
    matchBlocks = {
      "github.com" = {
        identityFile = "~/.ssh/id_ed25519";
      };
    };
  };

  home.packages = with pkgs; [
    openssh
  ];

}
