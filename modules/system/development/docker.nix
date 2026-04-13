{ username, pkgs, ... }:

{
  # Rootless Docker: daemon runs as a user service, no docker group needed.
  # Note: rootful (enable = true) and rootless cannot both be true simultaneously.
  virtualisation.docker.rootless = {
    enable = true;
    setSocketVariable = true; # sets DOCKER_HOST automatically for the user
  };

  # Keep containers alive after logout (needed for background services)
  users.users.${username}.linger = true;

  environment.systemPackages = [ pkgs.docker-compose ];
}
