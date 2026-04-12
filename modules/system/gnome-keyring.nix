{ config, pkgs, ... }:

{
  # Enable GNOME Keyring at system level
  services.gnome.gnome-keyring.enable = true;

  # Enable PAM integration for automatic keyring unlock on login
  security.pam.services.login.enableGnomeKeyring = true;
  security.pam.services.greetd.enableGnomeKeyring = true;

  # Disable GPG agent's SSH support to prevent conflicts
  programs.gnupg.agent.enableSSHSupport = false;

  # Disable system ssh-agent, as gnome-keyring will provide it
  programs.ssh.startAgent = false;

  # Declarative known hosts — avoids interactive fingerprint prompts
  programs.ssh.knownHosts = {
    "github.com" = {
      hostNames = [ "github.com" ];
      publicKey = "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIOMqqnkVzrm0SdG6UOoqKLsabgH5C9okWi0dh2l9GKJl";
    };
  };
}
