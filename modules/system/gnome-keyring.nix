{ pkgs, ... }:
{
  # Secret Service provider for apps using libsecret (VSCodium/Copilot token storage).
  # SSH agent remains services.ssh-agent — gnome-keyring's ssh component is not used.
  services.gnome.gnome-keyring.enable = true;

  # Unlock the login keyring with the login password at tuigreet.
  security.pam.services.greetd.enableGnomeKeyring = true;

  # The daemon PAM starts inside the greeter's session dies during the greetd
  # handoff (observed: gone within minutes of login), so Codium — launched from
  # the Hyprland session — finds no org.freedesktop.secrets on the bus and falls
  # back to basic_text. Own the daemon as a user service bound to the graphical
  # session instead; dbus activation also maps to this unit via its BusName.
  systemd.user.services.gnome-keyring = {
    description = "GNOME Keyring daemon (Secret Service)";
    wantedBy = [ "graphical-session.target" ];
    partOf = [ "graphical-session.target" ];
    serviceConfig = {
      Type = "dbus";
      BusName = "org.freedesktop.secrets";
      ExecStart = "${pkgs.gnome-keyring}/bin/gnome-keyring-daemon --start --foreground --components=secrets";
    };
  };
}
