{ pkgs, ... }:

{
  programs.zsh.enable = true;
  environment.shells = with pkgs; [ zsh bash ];
  users.defaultUserShell = pkgs.zsh;
  environment.localBinInPath = true;
}
