{...}: {
  imports = [./hardware-configuration.nix ./wireguard.nix ./secrets.nix];

  system.stateVersion = "25.05";
}
