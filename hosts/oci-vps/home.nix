{ username, lib, pkgs, ... }:

{
  home.username = username;
  home.homeDirectory = lib.mkForce "/home/${username}";
  home.stateVersion = "25.05";
  programs.home-manager.enable = true;

  programs.zsh = {
    enable = true;
    autosuggestion.enable = true;
    syntaxHighlighting.enable = true;
  };

  programs.git = {
    enable = true;
    settings = {
      user.name = "Vitor Borges";
      user.email = "vitorbborges31@gmail.com";
      init.defaultBranch = "main";
    };
  };

  home.packages = [ pkgs.vim ];
}
