{ pkgs, config, lib, inputs, ... }:

{
  imports = [
    inputs.spicetify-nix.homeManagerModules.default
  ];

  programs.spicetify =
    let
      spicePkgs = inputs.spicetify-nix.legacyPackages.${pkgs.stdenv.hostPlatform.system};
    in
    {
      enable = true;
      theme = spicePkgs.themes.ziro;
      colorScheme = "Blue-dark";

      enabledExtensions = with spicePkgs.extensions; [
        shuffle
        keyboardShortcut
        ({
          # The source of the custom extension
          src = pkgs.fetchFromGitHub {
            owner = "abh80";
            repo = "Spicetify-Fullscreen-Canvas";
            rev = "30a0139";
            hash = ""; # Will be prompted by nix
          };
          # The actual file name of the custom extension
          name = "spotifyFullscreenCanvas.js";
        })
      ];
    };
}
