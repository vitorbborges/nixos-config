{ pkgs, ... }:

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

  home.packages = with pkgs; [
    git
    lazygit
    zsh-forgit
  ];
}
