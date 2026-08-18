{...}: {
  # Systemd user socket-activated ssh-agent — reliable for Hyprland.
  # Sets SSH_AUTH_SOCK via systemd user environment, inherited by all processes
  # (including lazygit, git, etc.) without any PAM or keyring dependencies.
  services.ssh-agent.enable = true;

  programs.ssh = {
    enable = true;
    enableDefaultConfig = false;
    settings = {
      "*" = {
        # Automatically add keys to the agent on first use, caching them for the session.
        AddKeysToAgent = "yes";
      };
      "github.com" = {
        IdentityFile = "~/.ssh/id_ed25519";
      };
      "vps" = {
        HostName = "150.230.145.134";
        User = "vitor";
        IdentityFile = "~/.ssh/id_bitbucket";
        IdentitiesOnly = true;
      };
      "kafka-1" = {
        HostName = "51.103.132.227";
        User = "nsds-group";
        IdentityFile = "~/.ssh/nsds-key.pem";
        IdentitiesOnly = true;
      };
      "kafka-2" = {
        HostName = "20.250.53.240";
        User = "nsds-group";
        IdentityFile = "~/.ssh/nsds-key.pem";
        IdentitiesOnly = true;
      };
      "kafka-3" = {
        HostName = "20.250.74.170";
        User = "nsds-group";
        IdentityFile = "~/.ssh/nsds-key.pem";
        IdentitiesOnly = true;
      };
    };
  };
}
