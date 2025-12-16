{ config, pkgs, font, ... }:

{
  imports =
    [
      # Include the results of the hardware scan.
      ./hardware-configuration.nix
    ];

  # Bootloader.
  boot.loader.grub.enable = true;
  boot.loader.grub.device = "/dev/sda";
  boot.loader.grub.useOSProber = true;
  boot.initrd.checkJournalingFS = false; # TODO: VirtualBox config DELETE THIS WHEN MIGRATE TO BARE METAL 

  networking.hostName = "nixos"; # Define your hostname.
  # networking.wireless.enable = true;  # Enables wireless support via wpa_supplicant.

  # Configure network proxy if necessary
  # networking.proxy.default = "http://user:password@proxy:port/";
  # networking.proxy.noProxy = "127.0.0.1,localhost,internal.domain";

  # Enable networking
  networking.networkmanager.enable = true;

  # Set your time zone.
  time.timeZone = "Europe/Rome";

  # Select internationalisation properties.
  i18n.defaultLocale = "en_US.UTF-8";

  i18n.extraLocaleSettings = {
    LC_ADDRESS = "it_IT.UTF-8";
    LC_IDENTIFICATION = "it_IT.UTF-8";
    LC_MEASUREMENT = "it_IT.UTF-8";
    LC_MONETARY = "it_IT.UTF-8";
    LC_NAME = "it_IT.UTF-8";
    LC_NUMERIC = "it_IT.UTF-8";
    LC_PAPER = "it_IT.UTF-8";
    LC_TELEPHONE = "it_IT.UTF-8";
    LC_TIME = "it_IT.UTF-8";
  };

  # Configure keymap in X11
  services.xserver.xkb = {
    layout = "us";
    variant = "";
  };

  # Define a user account. Don't forget to set a password with ‘passwd’.
  users.users.vitorbborges = {
    # TODO: Move this to home-manager?
    isNormalUser = true;
    description = "Vitor Bandeira Borges";
    extraGroups = [ "networkmanager" "wheel" ];
    packages = with pkgs; [ ];
  };

  # Enable display manager with password authentication
  services.xserver.enable = true;
  services.displayManager = {
    sddm = {
      enable = true;
      wayland.enable = true;  # Enable Wayland support for Hyprland
    };
    defaultSession = "hyprland-uwsm";  # Set Hyprland as default session
  };

  # Allow unfree packages
  nixpkgs.config.allowUnfree = true;

  # List packages installed in system profile. To search, run:
  # $ nix search wget
  environment.systemPackages = with pkgs; [
    # vim # Do not forget to add an editor to edit configuration.nix! The Nano editor is also installed by default.
    wget
  ];

  # Use zsh
  programs.zsh.enable = true;
  environment.shells = with pkgs; [ zsh bash ]; # Use bash as fallback
  users.defaultUserShell = pkgs.zsh;

  # Some programs need SUID wrappers, can be configured further or are
  # started in user sessions.
  # programs.mtr.enable = true;
  programs.gnupg.agent = {
    enable = true;
    enableSSHSupport = false;
  };

  ecurity.pam.services.sddm.enableGnomeKeyring = true;
  
  # Ensure SSH agent environment variables are set
  programs.ssh.startAgent = false; # Disable system ssh-agent
  
  # Add auto-unlock for SSH keys
  security.pam.services.sddm-greeter.enableGnomeKeyring = true;

  # List services that you want to enable:

  # Enable the OpenSSH daemon.
  # services.openssh.enable = true;

  # Open ports in the firewall.
  # networking.firewall.allowedTCPPorts = [ ... ];
  # networking.firewall.allowedUDPPorts = [ ... ];
  # Or disable the firewall altogether.
  # networking.firewall.enable = false;

  # This value determines the NixOS release from which the default
  # settings for stateful data, like file locations and database versions
  # on your system were taken. It‘s perfectly fine and recommended to leave
  # this value at the release version of the first install of this system.
  # Before changing this value read the documentation for this option
  # (e.g. man configuration.nix or on https://nixos.org/nixos/options.html).

  system.stateVersion = "25.05"; # Did you read the comment?

  # System-wide neovim configuration  
  environment.variables = {
    EDITOR = "nvim";
    VISUAL = "nvim";
  };

  # Nix housekeeping
  nix = {
    settings = {
      experimental-features = [ "nix-command" "flakes" ];
      auto-optimise-store = true;
    };
    optimise.automatic = true;
    optimise.dates = [ "daily" ];

    gc = {
      automatic = true;
      dates = "weekly";
      options = "--delete-older-than 10d";
    };
  };

  # Auto updates
  system.autoUpgrade = {
    enable = true;
    allowReboot = false;
    flake = "/home/vitorbborges/.dotfiles";
    flags = [
      "--update-input"
      "nixpkgs"
      "--update-input"
      "home-manager"
      "--commit-lock-file"
    ];
    dates = "daily";
  };

  # Hardware housekeeping
  services = {
    fwupd.enable = true;
    fstrim.enable = true;
  };


  # TODO: Remove this in bare metal.
  virtualisation.virtualbox.guest.enable = true;

  environment.sessionVariables = {
    WLR_NO_HARDWARE_CURSOR = "1";
    WLR_RENDERER_ALLOW_SOFTWARE = "1";
  };
}
