{ pkgs, ... }:

{

  programs.yazi = {
    enable = true;
    enableZshIntegration = true;
    flavors = {
      dracula = pkgs.fetchFromGitHub
        {
          owner = "yazi-rs";
          repo = "flavors";
          rev = "main";
          sha256 = "sha256-AAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAA=";
        } + "/dracula.yazi";
    };

  };
}
