{ pkgs, ... }:

{
  home.packages = with pkgs; [
    shared-mime-info

  ];
}
