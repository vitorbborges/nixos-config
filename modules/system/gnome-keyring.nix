{ ... }:
{
  # Secret Service provider for apps using libsecret (VSCodium/Copilot token storage).
  # SSH agent remains services.ssh-agent — gnome-keyring's ssh component is not used.
  services.gnome.gnome-keyring.enable = true;

  # Unlock the login keyring with the login password at tuigreet.
  security.pam.services.greetd.enableGnomeKeyring = true;
}
