{ pkgs, username, ... }:

{
  imports = [ ./hardware.nix ./services.nix ./wireguard.nix ./swap.nix ./certbot.nix ./vaultwarden.nix ./secrets.nix ./ddns-cloudflare.nix ];

  boot.loader.systemd-boot.enable = true;
  boot.loader.efi.canTouchEfiVariables = true;

  networking = {
    hostName = "oci-vps";
    useDHCP = true;
    firewall = {
      enable = true;
      # Port 53 intentionally omitted — DNS amplification attack risk.
      # Plain DNS is only served over WireGuard (added in Phase 6).
      allowedTCPPorts = [ 22 80 443 853 8443 ];
      allowedUDPPorts = [ 443 ];
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
      "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIH2xDBZGkvHMRrb9qP+L23ZDtaNO6tIwX71tsSC/BOzL vitor.bandeira@mail.polimi.it"
      "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIPftvkxmQyP2JXL9NryOKMFPmWIFqGVLfzIDsAto+Csv vitorbborges31@gmail.com"
    ];
  };

  # root access required by nixos-anywhere during initial install
  users.users.root.openssh.authorizedKeys.keys = [
    "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIH2xDBZGkvHMRrb9qP+L23ZDtaNO6tIwX71tsSC/BOzL vitor.bandeira@mail.polimi.it"
    "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIPftvkxmQyP2JXL9NryOKMFPmWIFqGVLfzIDsAto+Csv vitorbborges31@gmail.com"
  ];

  programs.zsh.enable = true;

  virtualisation.docker = {
    enable = true;
    autoPrune.enable = true;
  };

  environment.systemPackages = with pkgs; [ git tcpdump ];

  nix.settings.experimental-features = [ "nix-command" "flakes" ];
  # Lets `vitor` deploy via `nixos-rebuild --target-host` without the nix
  # daemon rejecting the copied closure as an untrusted/unsigned store path.
  nix.settings.trusted-users = [ "vitor" ];

  system.stateVersion = "25.05";
}
