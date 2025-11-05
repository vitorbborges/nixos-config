{ pkgs, ... }:

{

  programs.yazi = {
    enable = true;
    enableZshIntegration = true;
    flavor = {
      dark = "dracula";
    };
  };

}
