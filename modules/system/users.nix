{ username, ... }:

{
  users.users.${username} = {
    isNormalUser = true;
    description = "Vitor Bandeira Borges";
    extraGroups = [ "networkmanager" "wheel" ];
    # Password is set via passwd on first boot (preserved across rebuilds by mutableUsers)
  };

  # Root login disabled on baremetal; use sudo from the wheel group instead

  # Required for hyprlock PAM authentication
  security.pam.services.hyprlock = {};
}
