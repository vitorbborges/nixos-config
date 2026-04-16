{...}: {
  # Systemd user socket-activated ssh-agent — reliable for Hyprland.
  # Sets SSH_AUTH_SOCK via systemd user environment, inherited by all processes
  # (including lazygit, git, etc.) without any PAM or keyring dependencies.
  services.ssh-agent.enable = true;

  programs.ssh = {
    enable = true;
    enableDefaultConfig = false;
    matchBlocks = {
      "*" = {
        # Automatically add keys to the agent on first use, caching them for the session.
        addKeysToAgent = "yes";
      };
      "github.com" = {
        identityFile = "~/.ssh/id_ed25519";
      };
      "kafka-1" = {
        hostname = "51.103.132.227";
        user = "nsds-group";
        identityFile = "~/.ssh/nsds-key.pem";
        identitiesOnly = true;
      };
      "kafka-2" = {
        hostname = "20.250.53.240";
        user = "nsds-group";
        identityFile = "~/.ssh/nsds-key.pem";
        identitiesOnly = true;
      };
      "kafka-3" = {
        hostname = "20.250.74.170";
        user = "nsds-group";
        identityFile = "~/.ssh/nsds-key.pem";
        identitiesOnly = true;
      };
    };
  };
}
