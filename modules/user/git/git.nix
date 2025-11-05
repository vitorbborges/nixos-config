{ config, pkgs, home-manager, ... }:

{
  programs.git = {
    enable = true;
    settings.user.name = "vitorbborges";
    settings.user.email = "vitorbborges31@gmail.com";
    settings.init.defaultBranch = "main";
    lfs.enable = true;
  };

  programs.lazygit = {
    enable = true;
    enableZshIntegration = true;
  };

  programs.ssh = {
    enable = true;
    enableDefaultConfig = false;
    matchBlocks = {
      "github.com" = {
        identityFile = "~/.ssh/id_ed25519";
      };
    };
  };

  home.packages = with pkgs; [
    git
    openssh
  ];
}
