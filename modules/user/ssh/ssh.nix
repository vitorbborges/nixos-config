{ pkgs, lib, ... }:

{

  programs.ssh = {
    enable = true;
    enableDefaultConfig = false;
    matchBlocks = {
      "github.com" = {
        identityFile = "~/.ssh/id_ed25519";
      };
    };
  };

  services.ssh-agent = {
    enable = false; # Disable home-manager ssh-agent to avoid conflicts
  };

  # Enable GNOME Keyring SSH agent integration
  services.gnome-keyring = {
    enable = true;
    components = [ "ssh" ];
  };

  home.packages = with pkgs; [
    openssh
  ];

}
