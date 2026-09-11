{ pkgs, ... }:

{
  home.packages = [
    (pkgs.writeShellApplication {
      name = "journal-open";
      runtimeInputs = with pkgs; [ coreutils ];
      text = builtins.readFile ./journal-open.sh;
    })
  ];
}
