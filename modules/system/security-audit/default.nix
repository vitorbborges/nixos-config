{ pkgs, ... }:

{
  environment.systemPackages = [
    pkgs.lynis
    pkgs.aide
  ];

  environment.etc."aide.conf".source = ./aide.conf;

  systemd.tmpfiles.rules = [
    "d /var/lib/aide 0700 root root -"
  ];
}
