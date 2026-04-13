{
  # setSocketVariable = true uses /etc/profile.d/ which zsh only reads in login
  # shells. Hyprland/UWSM terminal sessions are non-login, so set it here via
  # home.sessionVariables, which home-manager writes to ~/.zshenv (all shells).
  home.sessionVariables.DOCKER_HOST = "unix:///run/user/$UID/docker.sock";
}
