{ username, lib, pkgs, inputs, ... }:

{
  home.username = username;
  home.homeDirectory = lib.mkForce "/home/${username}";
  home.stateVersion = "25.05";
  programs.home-manager.enable = true;

  programs.zsh = {
    enable = true;
    autosuggestion.enable = true;
    syntaxHighlighting.enable = true;

    # Auto-attach to the persistent herdr session on interactive SSH login,
    # unless already inside one (HERDR_ENV) or in a non-interactive shell
    # (e.g. a scripted/deploy SSH command) — avoids nested-launch and
    # breaking non-interactive tooling like nixos-rebuild --target-host.
    initContent = builtins.readFile ./scripts/herdr-attach.zsh;
  };

  programs.git = {
    enable = true;
    settings = {
      user.name = "Vitor Borges";
      user.email = "vitorbborges31@gmail.com";
      init.defaultBranch = "main";
    };
  };

  home.packages = [
    pkgs.vim
    inputs.herdr.packages.${pkgs.stdenv.hostPlatform.system}.default
  ];

  xdg.configFile."herdr/config.toml".source = ./config/herdr.toml;
}
