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

  # Allow wallpaper-switch to trigger nixos-rebuild without a password prompt
  security.sudo.extraRules = [{
    users = [ username ];
    commands = [{
      command = "/run/current-system/sw/bin/nixos-rebuild";
      options = [ "NOPASSWD" ];
    }];
  }];
}
