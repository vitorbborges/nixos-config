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
}
