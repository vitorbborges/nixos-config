{ pkgs, ... }:

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

  # Replace the default x11-ssh-askpass (ugly Motif/XWayland dialog) with gcr4's
  # native GTK4 dialog — scales correctly on Wayland and integrates with gnome-keyring.
  # Only used as fallback; with SSH_AUTH_SOCK set, the agent handles auth silently.
  programs.ssh.askPassword = "${pkgs.gcr_4}/libexec/gcr-ssh-askpass";

  # Declarative known hosts — avoids interactive fingerprint prompts
  programs.ssh.knownHosts = {
    "github.com" = {
      hostNames = [ "github.com" ];
      publicKey = "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIOMqqnkVzrm0SdG6UOoqKLsabgH5C9okWi0dh2l9GKJl";
    };
  };
}
