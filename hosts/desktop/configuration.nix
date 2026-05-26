{...}: {
  imports = [./hardware-configuration.nix ./wireguard.nix];

  system.stateVersion = "25.05";
}
