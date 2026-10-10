{ pkgs, ... }:

let
  security-audit = pkgs.writeShellApplication {
    name = "security-audit";
    runtimeInputs = with pkgs; [
      lynis
      nix
      kernel-hardening-checker
      spectre-meltdown-checker
      vulnix
      systemd
      gawk
      coreutils
    ];
    text = builtins.readFile ./scripts/security-audit.sh;
  };
in
{
  environment.systemPackages = [
    security-audit
    pkgs.lynis
    pkgs.aide
  ];

  environment.etc."aide.conf".source = ./aide.conf;

  systemd.tmpfiles.rules = [
    "d /var/lib/aide 0700 root root -"
  ];
}
