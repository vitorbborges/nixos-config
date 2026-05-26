{ pkgs, ... }:

let
  screenrec-toggle = pkgs.writeShellApplication {
    name = "hl-screenrec-toggle";
    runtimeInputs = with pkgs; [ wl-screenrec procps libnotify ];
    text = builtins.readFile ./scripts/screenrec-toggle.sh;
  };
in

{
  home.packages = [ screenrec-toggle ];
}
