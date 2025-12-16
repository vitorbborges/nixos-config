{ config, pkgs, ... }:

{
  # Enable GNOME Keyring at system level
  services.gnome.gnome-keyring.enable = true;

  # Enable PAM integration for automatic keyring unlock
  security.pam.services.login.enableGnomeKeyring = true;
  security.pam.services.sddm.enableGnomeKeyring = true;

  # Add auto-unlock for SSH keys
  security.pam.services.sddm-greeter.enableGnomeKeyring = true;

  # Disable GPG agent's SSH support to prevent conflicts
  programs.gnupg.agent.enableSSHSupport = false;

  # Disable system ssh-agent, as gnome-keyring will provide it
  programs.ssh.startAgent = false;
}
