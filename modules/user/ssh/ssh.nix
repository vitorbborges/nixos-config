{ pkgs, lib, ... }:

{

  programs.ssh = {
    enable = true;
    enableDefaultConfig = false;
    matchBlocks = {
      "*" = {
        addKeysToAgent = "yes";
      };
      "github.com" = {
        identityFile = "~/.ssh/id_ed25519";
      };
    };
  };

  home.packages = with pkgs; [
    openssh
  ];

}
