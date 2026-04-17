{ pkgs, username, ... }:

{
  imports = [ ./hardware.nix ];

  boot.loader.systemd-boot.enable = true;
  boot.loader.efi.canTouchEfiVariables = true;

  networking = {
    hostName = "oci-vps";
    useDHCP = true;
    firewall = {
      enable = true;
      # Port 53 intentionally omitted — DNS amplification attack risk.
      # Plain DNS is only served over WireGuard (added in Phase 6).
      allowedTCPPorts = [ 22 80 443 853 ];
      allowedUDPPorts = [ 51820 ];
    };
  };

  services.openssh = {
    enable = true;
    settings = {
      PermitRootLogin = "prohibit-password";
      PasswordAuthentication = false;
    };
  };

  users.users.${username} = {
    isNormalUser = true;
    shell = pkgs.zsh;
    extraGroups = [ "wheel" "docker" ];
    openssh.authorizedKeys.keys = [
      # TODO: add your SSH public key here before deploying
    ];
  };

  # root access required by nixos-anywhere during initial install
  users.users.root.openssh.authorizedKeys.keys = [
    # TODO: add your SSH public key here before deploying
  ];

  programs.zsh.enable = true;

  virtualisation.docker = {
    enable = true;
    autoPrune.enable = true;
  };

  environment.systemPackages = with pkgs; [ git ];

  nix.settings.experimental-features = [ "nix-command" "flakes" ];

  system.stateVersion = "25.05";
}
