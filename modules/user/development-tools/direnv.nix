{ ... }:
{
  programs.direnv = {
    enable = true;
    nix-direnv.enable = true;    # caches devshell eval; prevents re-eval on every cd
    enableZshIntegration = true;
    silent = true;               # suppress the "export +VAR +VAR ..." line on cd
  };
}
