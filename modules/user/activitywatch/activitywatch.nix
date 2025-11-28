{ pkgs, ... }:

{
  programs.activitywatch = {
    enable = true;
    package = pkgs.activitywatch;
  };
}
