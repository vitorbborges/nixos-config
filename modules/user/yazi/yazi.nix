{ pkgs, ... }:

{

  programs.yazi = {
    enable = true;
    enableZshIntegration = true;
    flavors = {
      dark = "dracula";
    };
  };

}
