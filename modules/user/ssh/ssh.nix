{ pkgs, lib, ... }:

{

  programs.ssh = {
    enable = true;
    enableDefaultConfig = false;
    matchBlocks = {
      "github.com" = {
        identityFile = "~/.ssh/id_ed25519";
      };
    };
  };

  services.ssh-agent = {
    enable = true;
    enableZshIntegration = true;
  };

  home.packages = with pkgs; [
    openssh
  ];

}
