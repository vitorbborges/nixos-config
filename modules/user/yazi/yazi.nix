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
          sha256 = "sha256-bavHcmeGZ49nNeM+0DSdKvxZDPVm3e6eaNmfmwfCid0=";
        } + "/dracula.yazi";
    };

  };
}
