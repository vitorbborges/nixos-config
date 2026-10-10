{ pkgs, username, ... }:

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

  aideRebaseline = pkgs.writeShellApplication {
    name = "aide-rebaseline";
    runtimeInputs = with pkgs; [
      aide
      coreutils
    ];
    text = builtins.readFile ./scripts/aide-rebaseline.sh;
  };
in
{
  environment.systemPackages = [
    security-audit
    pkgs.lynis
    pkgs.aide
  ];

  environment.etc."aide.conf".source = ./aide.conf;

  system.activationScripts.aide-rebaseline = {
    deps = [ "etc" ];
    text = "${aideRebaseline}/bin/aide-rebaseline \"$systemConfig\"";
  };

  security.sudo.extraRules = [
    {
      users = [ username ];
      commands = [
        {
          command = "${pkgs.aide}/bin/aide --check --config /etc/aide.conf";
          options = [ "NOPASSWD" ];
        }
      ];
    }
  ];

  systemd.tmpfiles.rules = [
    "d /var/lib/aide 0700 root root -"
  ];
}
